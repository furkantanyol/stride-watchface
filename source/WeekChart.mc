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

            if (value <= 0) {
                dc.setColor(Theme.STUB, Gfx.COLOR_TRANSPARENT);
                dc.fillRectangle(x, baseY - 3, barW, 3);
            } else {
                var h = ((value.toFloat() / goal) * maxH).toNumber();
                if (h > maxH) { h = maxH; }
                if (h < 3) { h = 3; }
                dc.setColor(isToday ? accent : Theme.BAR_FILL, Gfx.COLOR_TRANSPARENT);
                dc.fillRectangle(x, baseY - h, barW, h);
            }

            dc.setColor(isToday ? accent : Theme.MUTED, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x + (barW / 2), baseY + 3, dayFont, labels[i], Gfx.TEXT_JUSTIFY_CENTER);
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
