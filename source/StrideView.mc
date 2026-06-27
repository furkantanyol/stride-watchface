using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as Act;
using Toybox.Application as App;

// The Stride watch face: a round take on the Casio G-Shock GBD-200 LCD.
// Small steps (left) and distance (right) ride the top, the seven-day step
// bars are the hero, and the time (a real DSEG7 LCD font) sits below with the
// date beside it and motivating readouts under that. Pure mono on black, one
// red accent on today. Positions are fractions of width/height so the same
// code renders on the simulator and the 240x240 device.
class StrideView extends Ui.WatchFace {

    hidden const TOP_Y    = 0.130;   // steps (left) + km (right)
    hidden const WEEK_BASE_Y = 0.510;   // bar baseline (0%)
    hidden const WEEK_MAX_H  = 0.250;   // 100% sits this far above the baseline
    hidden const TIME_CY  = 0.690;   // vertical centre of the time band
    hidden const DATE_DY  = 10;      // px each date line sits from the time centre
    hidden const BOTTOM_Y = 0.810;   // recovery / body battery / weather

    hidden const DATE_PAD   = 8;     // px between the time and the date block
    hidden const CM_PER_KM  = 100000.0;
    hidden const SECONDS_PER_DAY = 86400;
    hidden const DEFAULT_GOAL = 10000;
    hidden const HISTORY_DAYS = 7;

    hidden const WDAY = ["", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    hidden var _width;
    hidden var _height;
    hidden var _cx;
    hidden var _cy;
    hidden var _lcd;   // DSEG7 LCD font for the time

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _width = dc.getWidth();
        _height = dc.getHeight();
        _cx = _width / 2;
        _cy = _height / 2;
        _lcd = Ui.loadResource(Rez.Fonts.LcdTime);
    }

    function onShow() {
    }

    function onHide() {
    }

    function onExitSleep() {
    }

    function onEnterSleep() {
    }

    // Seconds are intentionally disabled to protect battery. Kept as a no-op
    // so enabling them later is one deliberate, isolated change.
    function onPartialUpdate(dc) {
    }

    function onUpdate(dc) {
        var goal = settingNumber("StepGoal", DEFAULT_GOAL);
        var accent = Theme.accent();

        dc.setColor(Theme.BACKGROUND, Theme.BACKGROUND);
        dc.clear();

        var now = Time.now();
        var greg = Gregorian.info(now, Time.FORMAT_SHORT);
        var clock = Sys.getClockTime();
        var dayNumber = localDayNumber(now, clock);

        var info = Act.getInfo();
        var steps = (info != null && info.steps != null) ? info.steps : 0;
        var distanceCm = (info != null && info.distance != null) ? info.distance : 0;

        var days = StepHistory.lastSevenDays(steps, dayNumber);

        drawTopMetrics(dc, steps, distanceCm);
        WeekChart.draw(dc, accent, days, dayLabels(now), goal, _cx, _width,
            (_height * WEEK_BASE_Y).toNumber(), (_height * WEEK_MAX_H).toNumber());
        drawTimeAndDate(dc, clock, greg);
        drawBottomRow(dc);
    }

    // ---------- top corners: steps (left), distance (right) ----------

    hidden function drawTopMetrics(dc, steps, distanceCm) {
        var y = (_height * TOP_Y).toNumber();
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(_width * 0.30, y, Gfx.FONT_TINY, commafy(steps), Gfx.TEXT_JUSTIFY_CENTER);
        var km = (distanceCm / CM_PER_KM).format("%.2f") + "km";
        dc.drawText(_width * 0.70, y, Gfx.FONT_TINY, km, Gfx.TEXT_JUSTIFY_CENTER);
    }

    // ---------- time (DSEG7) with the date stacked beside it ----------

    hidden function drawTimeAndDate(dc, clock, greg) {
        var ds = Sys.getDeviceSettings();
        var hour = clock.hour;
        if (!ds.is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var hourStr = ds.is24Hour ? hour.format("%02d") : hour.format("%d");
        var timeText = hourStr + ":" + clock.min.format("%02d");

        var segW = dc.getTextWidthInPixels(timeText, _lcd);
        var line1 = greg.month.format("%d") + "/" + greg.day.format("%d");
        var line2 = WDAY[greg.day_of_week];
        var dateW = maxWidth(dc, line1, line2);

        var x = _cx - ((segW + DATE_PAD + dateW) / 2);
        var cy = (_height * TIME_CY).toNumber();

        // The unlit "88:88" skeleton, then the lit time on top — the LCD look.
        dc.setColor(Theme.SEG_GHOST, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, cy, _lcd, ghostOf(timeText), Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, cy, _lcd, timeText, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);

        var dateX = x + segW + DATE_PAD;
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dateX, cy - DATE_DY, Gfx.FONT_XTINY, line1, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dateX, cy + DATE_DY, Gfx.FONT_XTINY, line2, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    // ---------- bottom readouts: recovery, body battery, weather ----------

    hidden function drawBottomRow(dc) {
        var parts = "";
        var recovery = Metrics.recoveryHours();
        if (recovery != null) { parts = append(parts, "RCV " + recovery.format("%d") + "h"); }
        var battery = Metrics.bodyBattery();
        if (battery != null) { parts = append(parts, "BB " + battery.format("%d")); }
        var temp = Metrics.temperature();
        if (temp != null) { parts = append(parts, temp.format("%d") + "°"); }
        if (parts.equals("")) { return; }

        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(_cx, _height * BOTTOM_Y, Gfx.FONT_XTINY, parts, Gfx.TEXT_JUSTIFY_CENTER);
    }

    // ---------- helpers ----------

    // Day-of-month labels for the last seven days, oldest first, today last.
    hidden function dayLabels(now) {
        var labels = new [HISTORY_DAYS];
        for (var i = 0; i < HISTORY_DAYS; i += 1) {
            var offset = HISTORY_DAYS - 1 - i;
            var moment = new Time.Moment(now.value() - (offset * SECONDS_PER_DAY));
            labels[i] = Gregorian.info(moment, Time.FORMAT_SHORT).day.format("%d");
        }
        return labels;
    }

    // The all-segments "88:88" skeleton for a given time string.
    hidden function ghostOf(text) {
        var out = "";
        for (var i = 0; i < text.length(); i += 1) {
            var c = text.substring(i, i + 1);
            out += c.equals(":") ? ":" : "8";
        }
        return out;
    }

    hidden function maxWidth(dc, a, b) {
        var wa = dc.getTextWidthInPixels(a, Gfx.FONT_XTINY);
        var wb = dc.getTextWidthInPixels(b, Gfx.FONT_XTINY);
        return (wa > wb) ? wa : wb;
    }

    hidden function append(acc, piece) {
        return acc.equals("") ? piece : acc + "   " + piece;
    }

    hidden function settingNumber(key, fallback) {
        var v = App.Properties.getValue(key);
        return v == null ? fallback : v;
    }

    // Local day index: whole days since the epoch in the wearer's time zone.
    hidden function localDayNumber(now, clock) {
        var secs = now.value() + clock.timeZoneOffset;
        return (secs / SECONDS_PER_DAY).toNumber();
    }

    hidden function commafy(n) {
        var s = n.toString();
        var out = "";
        var count = 0;
        for (var i = s.length() - 1; i >= 0; i -= 1) {
            out = s.substring(i, i + 1) + out;
            count += 1;
            if (count % 3 == 0 && i > 0) {
                out = "," + out;
            }
        }
        return out;
    }
}
