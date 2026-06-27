using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;

// The last-seven-days step bars — the GBD-200's central chart and the hero of
// the face. A left axis runs 0% to 100% (100% is the goal) with tick marks at
// each quarter. Each bar is one day, numbered by date below in a tiny font.
// Today is the accent; consecutive bars reaching the top are your streak.
module WeekChart {

    const BAR_W_RATIO = 0.066;   // thinner bars, more breathing room
    const GAP_RATIO   = 0.022;
    const SIDE_MARGIN = 0.075;   // keep the chart off the round edges
    const SEG_H   = 4;           // height of one LCD bar segment
    const SEG_GAP = 2;           // gap between bar segments
    const TICKS = [0, 25, 50, 75, 100];

    var dayFont = null;

    function draw(dc as Gfx.Dc, accent as Lang.Number, days as Lang.Array<Lang.Number>,
                  labels as Lang.Array<Lang.String>, goal as Lang.Number, cx as Lang.Number,
                  width as Lang.Number, baseY as Lang.Number, maxH as Lang.Number) as Void {
        if (dayFont == null) { dayFont = Ui.loadResource(Rez.Fonts.DayNum); }

        var n = days.size();
        var todayIndex = n - 1;
        var barW = (width * BAR_W_RATIO).toNumber();
        var gap = (width * GAP_RATIO).toNumber();
        if (barW < 7) { barW = 7; }
        if (gap < 2) { gap = 2; }

        var totalW = (n * barW) + ((n - 1) * gap);
        var axisRoom = (width * 0.075).toNumber();
        var startX = cx - (totalW / 2) + (axisRoom / 2);
        var axisX = startX - 7;
        var topY = baseY - maxH;

        drawAxis(dc, axisX, topY, baseY, maxH);

        for (var i = 0; i < n; i += 1) {
            var x = startX + (i * (barW + gap));
            var value = days[i];
            var isToday = (i == todayIndex);

            var frac = value.toFloat() / goal;
            if (frac > 1.0) { frac = 1.0; }
            drawGaugeBar(dc, x, baseY, barW, maxH, frac, isToday ? accent : Theme.BAR_FILL);

            dc.setColor(isToday ? accent : Theme.MUTED, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x + (barW / 2), baseY + 3, dayFont, labels[i], Gfx.TEXT_JUSTIFY_CENTER);
        }
    }

    // A bar drawn as a stack of LCD segments: lit up to `frac` of the goal in
    // `litColor`, the rest a faint ghost track — like the unlit segments behind
    // the time, and like the GBD bar gauges. Every bar shows the full track, so
    // an empty day reads as an empty gauge, not a glitch.
    function drawGaugeBar(dc as Gfx.Dc, x as Lang.Number, baseY as Lang.Number, w as Lang.Number,
                          maxH as Lang.Number, frac as Lang.Float, litColor as Lang.Number) as Void {
        var unit = SEG_H + SEG_GAP;
        var total = maxH / unit;
        if (total < 1) { total = 1; }
        var lit = (frac * total + 0.5).toNumber();
        if (frac > 0.0 && lit < 1) { lit = 1; }
        if (lit > total) { lit = total; }
        for (var u = 0; u < total; u += 1) {
            var top = baseY - ((u + 1) * unit) + SEG_GAP;
            dc.setColor(u < lit ? litColor : Theme.BAR_TRACK, Gfx.COLOR_TRANSPARENT);
            dc.fillRectangle(x, top, w, SEG_H);
        }
    }

    function drawAxis(dc as Gfx.Dc, axisX as Lang.Number, topY as Lang.Number,
                      baseY as Lang.Number, maxH as Lang.Number) as Void {
        dc.setPenWidth(1);
        dc.setColor(Theme.MUTED, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(axisX, topY, axisX, baseY);
        for (var k = 0; k < TICKS.size(); k += 1) {
            var ty = baseY - ((TICKS[k] * maxH) / 100);
            dc.drawLine(axisX - 3, ty, axisX, ty);
        }
        dc.drawText(axisX - 5, topY - 6, Gfx.FONT_XTINY, "100", Gfx.TEXT_JUSTIFY_RIGHT);
        dc.drawText(axisX - 5, baseY - 11, Gfx.FONT_XTINY, "0%", Gfx.TEXT_JUSTIFY_RIGHT);
    }
}
