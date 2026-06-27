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

    hidden const TOP_Y    = 0.095;   // steps (left) + distance (right)
    hidden const WEEK_BASE_Y = 0.490;   // bar baseline (0%)
    hidden const WEEK_MAX_H  = 0.250;   // plot height (120% of goal)
    hidden const TIME_CY  = 0.655;   // vertical centre of the time band
    hidden const DATE_DY  = 10;      // px each date line sits from the time centre
    hidden const BOTTOM_Y = 0.780;   // recovery / body battery / weather labels
    hidden const STAT_LABEL_DY = 16; // px from a top value down to its label
    hidden const STAT_VALUE_DY = 18; // px from a bottom label down to its value centre

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
    hidden var _lcd;     // DSEG7 LCD font for the time
    hidden var _small;   // DSEG7 for the small numeric readouts
    hidden var _word;    // condensed sans for words and units

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _width = dc.getWidth();
        _height = dc.getHeight();
        _cx = _width / 2;
        _cy = _height / 2;
        _lcd = Ui.loadResource(Rez.Fonts.LcdTime);
        _small = Ui.loadResource(Rez.Fonts.LcdSmall);
        _word = Ui.loadResource(Rez.Fonts.Word);
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
        drawTopStat(dc, _width * 0.28, y, steps.toString(), "STEPS");
        drawDistanceStat(dc, _width * 0.72, y, distanceCm);
    }

    // Distance needs a decimal point, which DSEG7 can't render on Garmin, so
    // the dot is drawn by hand between the whole and fractional DSEG7 digits.
    hidden function drawDistanceStat(dc, cx, y, distanceCm) {
        var km = distanceCm / CM_PER_KM;
        var whole = km.toNumber();
        var frac = ((km - whole) * 100 + 0.5).toNumber();
        var intPart = whole.toString();
        var fracPart = frac.format("%02d");

        var iw = dc.getTextWidthInPixels(intPart, _small);
        var fw = dc.getTextWidthInPixels(fracPart, _small);
        var dotW = 5;
        var x = cx - ((iw + dotW + fw) / 2);

        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, y, _small, intPart, Gfx.TEXT_JUSTIFY_LEFT);
        dc.fillRectangle(x + iw + 1, y + 11, 3, 3);
        dc.drawText(x + iw + dotW, y, _small, fracPart, Gfx.TEXT_JUSTIFY_LEFT);

        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, y + STAT_LABEL_DY, _word, "KM", Gfx.TEXT_JUSTIFY_CENTER);
    }

    // A top-corner stat: DSEG7 value (lit) over a small condensed label.
    hidden function drawTopStat(dc, cx, y, value, label) {
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, y, _small, value, Gfx.TEXT_JUSTIFY_CENTER);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, y + STAT_LABEL_DY, _word, label, Gfx.TEXT_JUSTIFY_CENTER);
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

        // No ghost skeleton: at the panel's 4 grayscale levels the only "faint"
        // option (#555) competes with the lit digits and muddies the time.
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, cy, _lcd, timeText, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);

        var dateX = x + segW + DATE_PAD;
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dateX, cy - DATE_DY, _word, line1, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dateX, cy + DATE_DY, _word, line2, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    // ---------- bottom readouts: recovery, body battery, weather ----------

    hidden function drawBottomRow(dc) {
        var y = (_height * BOTTOM_Y).toNumber();
        drawBottomStat(dc, _width * 0.265, y, "RECOV", Metrics.recoveryHours(), "H");
        drawBottomStat(dc, _width * 0.50, y, "BODY", Metrics.bodyBattery(), "%");
        drawBottomStat(dc, _width * 0.735, y, "TEMP", Metrics.temperature(), "°");
    }

    // A bottom stat: condensed label over a DSEG7 value + condensed unit,
    // group-centered. Shows "--" when the metric is absent.
    hidden function drawBottomStat(dc, cx, y, label, value, unit) {
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, y, _word, label, Gfx.TEXT_JUSTIFY_CENTER);

        var vcy = y + STAT_VALUE_DY;
        if (value == null) {
            dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
            dc.drawText(cx, vcy, _word, "--", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
            return;
        }
        var num = value.format("%d");
        var nw = dc.getTextWidthInPixels(num, _small);
        var uw = dc.getTextWidthInPixels(unit, _word);
        var sx = cx - ((nw + uw) / 2);
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(sx, vcy, _small, num, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(sx + nw, vcy, _word, unit, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
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

    hidden function maxWidth(dc, a, b) {
        var wa = dc.getTextWidthInPixels(a, _word);
        var wb = dc.getTextWidthInPixels(b, _word);
        return (wa > wb) ? wa : wb;
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
}
