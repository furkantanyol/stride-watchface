using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Lang as Lang;

// The last-seven-days step chart — the hero. Each day is a stack of 10% LCD
// blocks (the G-Shock segment grain). A day that cleared the goal is lit white,
// one that fell short is muted gray, today is the accent. The dashed goal line
// sits below the top with headroom so an over-goal day visibly crosses it — a
// run of bars over the line reads as a streak.
module WeekChart {

    const BAR_W_RATIO = 0.066;
    const GAP_RATIO   = 0.022;
    const BLOCK_H   = 4;
    const BLOCK_GAP = 1;
    const SCALE_PCT = 120;   // plot tops out at 120% of goal (12 blocks)
    const GOAL_PCT  = 100;
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
        var axisRoom = (width * 0.06).toNumber();
        var startX = cx - (totalW / 2) + (axisRoom / 2);
        var axisX = startX - 7;
        var topY = baseY - maxH;
        var unit = BLOCK_H + BLOCK_GAP;
        var maxBlocks = maxH / unit;

        drawAxis(dc, axisX, topY, baseY, maxH);

        var goalY = baseY - ((GOAL_PCT * maxH) / SCALE_PCT);
        dc.setColor(Theme.SEG_GHOST, Gfx.COLOR_TRANSPARENT);
        dashedLine(dc, startX, startX + totalW, goalY);

        for (var i = 0; i < n; i += 1) {
            var x = startX + (i * (barW + gap));
            var value = days[i];
            var isToday = (i == todayIndex);

            var pct = (goal > 0) ? (value * 100 / goal) : 0;
            if (pct > SCALE_PCT) { pct = SCALE_PCT; }
            var blocks = (pct + 5) / 10;            // round to the nearest 10%
            if (value > 0 && blocks < 1) { blocks = 1; }
            if (blocks > maxBlocks) { blocks = maxBlocks; }

            var color = isToday ? accent : ((value >= goal && value > 0) ? Theme.SEG_LIT : Theme.MUTED);
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
            for (var b = 0; b < blocks; b += 1) {
                dc.fillRectangle(x, baseY - ((b + 1) * unit) + BLOCK_GAP, barW, BLOCK_H);
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
            var ty = baseY - ((TICKS[k] * maxH) / SCALE_PCT);
            dc.drawLine(axisX - 3, ty, axisX, ty);
        }
    }

    function dashedLine(dc as Gfx.Dc, x1 as Lang.Number, x2 as Lang.Number, y as Lang.Number) as Void {
        var x = x1;
        while (x < x2) {
            var xe = (x + 3 > x2) ? x2 : x + 3;
            dc.drawLine(x, y, xe, y);
            x += 6;
        }
    }
}
