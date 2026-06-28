using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.ActivityMonitor as Act;
using Toybox.Application as App;

// The Stride watch face. Steps (left) and distance (right) ride the top, the
// seven-day step bars are the hero, the time sits below with the date beside
// it, and recovery / body battery / temp run along the bottom. One JetBrains
// Mono typeface throughout; pure mono on black with one amber accent on today.
// Positions are fractions of width/height so the same code renders on the
// simulator and the 240x240 device.
class StrideView extends Ui.WatchFace {

    // Vertical rhythm: ~equal whitespace between the four bands (top row,
    // chart, time, bottom row). The chart sits lower than its content needs so
    // the top->chart gap matches the others.
    hidden const TOP_Y    = 0.155;   // centre of the steps / distance row
    hidden const WEEK_BASE_Y = 0.495;   // bar baseline (0%)
    hidden const WEEK_MAX_H  = 0.250;   // plot height (= the goal / ceiling)

    hidden const TIME_CY  = 0.685;   // vertical centre of the time band
    hidden const DATE_DY  = 10;      // px each date line sits from the time centre
    hidden const BOTTOM_Y = 0.850;   // centre of the recovery / body / temp row

    hidden const DATE_PAD   = 8;     // px between the time and the date block
    hidden const CM_PER_KM  = 100000.0;
    hidden const SECONDS_PER_DAY = 86400;
    hidden const DEFAULT_GOAL = 10000;
    hidden const HISTORY_DAYS = 7;

    hidden const WDAY = ["", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    hidden var _width;
    hidden var _height;
    hidden var _cx;
    hidden var _lcd;     // large — the time
    hidden var _small;   // small — every number, word, and unit
    hidden var _word;    // alias of _small (one typeface throughout)
    hidden var _day;     // tiny — the day numbers under the bars
    hidden var _fontStyle = -1;   // which FontStyle the fonts are currently loaded for

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        _width = dc.getWidth();
        _height = dc.getHeight();
        _cx = _width / 2;
        loadFonts(settingNumber("FontStyle", 0));
    }

    // Load the chosen font's three sizes, only when the FontStyle changes.
    // The whole face uses one typeface, so _small and _word are the same font.
    hidden function loadFonts(style) {
        if (style == _fontStyle) { return; }
        _fontStyle = style;
        if (style == 1) {
            _lcd = Ui.loadResource(Rez.Fonts.F1Time);
            _small = Ui.loadResource(Rez.Fonts.F1Text);
            _day = Ui.loadResource(Rez.Fonts.F1Day);
        } else if (style == 2) {
            _lcd = Ui.loadResource(Rez.Fonts.F2Time);
            _small = Ui.loadResource(Rez.Fonts.F2Text);
            _day = Ui.loadResource(Rez.Fonts.F2Day);
        } else {
            _lcd = Ui.loadResource(Rez.Fonts.F0Time);
            _small = Ui.loadResource(Rez.Fonts.F0Text);
            _day = Ui.loadResource(Rez.Fonts.F0Day);
        }
        _word = _small;
        WeekChart.dayFont = _day;
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
        loadFonts(settingNumber("FontStyle", 0));
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
        if (StepHistory.DEMO) {        // populate the face for simulator screenshots
            steps = 9340;
            distanceCm = 684000;
        }

        var days = StepHistory.lastSevenDays(steps, dayNumber);

        drawTopMetrics(dc, steps, distanceCm);
        WeekChart.draw(dc, accent, days, dayLabels(now), goal, _width,
            (_height * WEEK_BASE_Y).toNumber(), (_height * WEEK_MAX_H).toNumber(),
            settingNumber("BarStyle", 0) == 1);
        drawTimeAndDate(dc, clock, greg, accent);
        if (settingBool("ShowMetrics", true)) {
            drawBottomRow(dc);
        }
    }

    // ---------- top corners: steps (left), distance (right) ----------

    hidden function drawTopMetrics(dc, steps, distanceCm) {
        var cy = (_height * TOP_Y).toNumber();
        drawSteps(dc, (_width * 0.30).toNumber(), cy, steps);
        drawDistance(dc, (_width * 0.70).toNumber(), cy, distanceCm);
    }

    // Steps: the bare number — it's the hero metric, no unit needed.
    hidden function drawSteps(dc, cx, cy, steps) {
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, _small, steps.toString(), Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    // A number + its small unit, group-centered on cy.
    hidden function drawNumUnit(dc, cx, cy, num, unit) {
        var nw = dc.getTextWidthInPixels(num, _small);
        var uw = dc.getTextWidthInPixels(unit, _word);
        var sx = cx - ((nw + 1 + uw) / 2);
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(sx, cy, _small, num, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(sx + nw + 1, cy, _word, unit, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    // Distance + "km" — the font has a real decimal point now.
    hidden function drawDistance(dc, cx, cy, distanceCm) {
        drawNumUnit(dc, cx, cy, (distanceCm / CM_PER_KM).format("%.2f"), "km");
    }

    // ---------- time with the date stacked beside it ----------

    hidden function drawTimeAndDate(dc, clock, greg, accent) {
        var ds = Sys.getDeviceSettings();
        var hour = clock.hour;
        if (!ds.is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var padHour = ds.is24Hour || settingBool("LeadingZero", false);
        var hourStr = padHour ? hour.format("%02d") : hour.format("%d");
        var minStr = clock.min.format("%02d");
        var colon = settingNumber("TimeStyle", 0) == 0;   // else colored minutes, no colon

        var line1 = greg.month.format("%d") + "/" + greg.day.format("%d");
        var line2 = WDAY[greg.day_of_week];
        var dateW = maxWidth(dc, line1, line2);

        var hw = dc.getTextWidthInPixels(hourStr, _lcd);
        var sepW = colon ? dc.getTextWidthInPixels(":", _lcd) : 0;
        var mw = dc.getTextWidthInPixels(minStr, _lcd);
        var segW = hw + sepW + mw;

        var x = _cx - ((segW + DATE_PAD + dateW) / 2);
        var cy = (_height * TIME_CY).toNumber();

        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(x, cy, _lcd, hourStr, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        var mx = x + hw;
        if (colon) {
            dc.drawText(mx, cy, _lcd, ":", Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
            mx += sepW;
        }
        var minColor = colon ? Theme.SEG_LIT
            : (settingNumber("MinutesColor", 0) == 1 ? accent : Theme.MUTED);
        dc.setColor(minColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(mx, cy, _lcd, minStr, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);

        var dateX = x + segW + DATE_PAD;
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dateX, cy - DATE_DY, _word, line1, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dateX, cy + DATE_DY, _word, line2, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    // ---------- bottom readouts: recovery, body battery, weather ----------

    hidden function drawBottomRow(dc) {
        var cy = (_height * BOTTOM_Y).toNumber();
        drawRecovery(dc, (_width * 0.255).toNumber(), cy, Metrics.recoveryHours());
        drawBody(dc, (_width * 0.50).toNumber(), cy, Metrics.bodyBattery());
        drawTemp(dc, (_width * 0.745).toNumber(), cy, Metrics.temperature());
    }

    // Recovery: hours + "h", no label.
    hidden function drawRecovery(dc, cx, cy, hours) {
        if (hours == null) { drawDashes(dc, cx, cy); return; }
        drawNumUnit(dc, cx, cy, hours.toString(), "h");
    }

    // Body Battery: percentage + "%", no label.
    hidden function drawBody(dc, cx, cy, pct) {
        if (pct == null) { drawDashes(dc, cx, cy); return; }
        drawNumUnit(dc, cx, cy, pct.toString(), "%");
    }

    // Just the degrees — the ° is the label. Celsius from the API, converted
    // to Fahrenheit when the TempUnit setting asks for it.
    hidden function drawTemp(dc, cx, cy, deg) {
        if (deg == null) { drawDashes(dc, cx, cy); return; }
        if (settingNumber("TempUnit", 0) == 1) { deg = (deg * 9 / 5) + 32; }
        var num = deg.toString();
        var nw = dc.getTextWidthInPixels(num, _small);
        var uw = dc.getTextWidthInPixels("°", _word);
        var sx = cx - ((nw + 1 + uw) / 2);
        dc.setColor(Theme.SEG_LIT, Gfx.COLOR_TRANSPARENT);
        dc.drawText(sx, cy, _small, num, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(sx + nw + 1, cy - 4, _word, "°", Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
    }

    hidden function drawDashes(dc, cx, cy) {
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, _word, "--", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
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

    hidden function settingBool(key, fallback) {
        var v = App.Properties.getValue(key);
        return v == null ? fallback : v;
    }

    // Local day index: whole days since the epoch in the wearer's time zone.
    hidden function localDayNumber(now, clock) {
        var secs = now.value() + clock.timeZoneOffset;
        return (secs / SECONDS_PER_DAY).toNumber();
    }
}
