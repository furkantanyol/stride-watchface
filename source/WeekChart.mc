using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;

// The last-seven-days step chart — the hero. Each day is a stack of 10% blocks
// (the G-Shock segment grain). The goal is the ceiling: 10 blocks fill the plot
// and a day at or over the goal fills to the dashed line at the top. A day that
// cleared the goal is lit white, one that fell short is muted gray, today is
// the accent. A run of full bars reads as a streak.
module WeekChart {

    const BAR_W_RATIO = 0.066;
    const GAP_RATIO   = 0.022;
    const BLOCK_GAP = 1;
    const BLOCKS = 10;       // the goal is the ceiling: 10 x 10% fills the plot

    var dayFont = null;   // the day-number font, set by the view (matches FontStyle)

    function draw(dc as Gfx.Dc, accent as Lang.Number, days as Lang.Array<Lang.Number>,
                  labels as Lang.Array<Lang.String>, goal as Lang.Number,
                  width as Lang.Number, baseY as Lang.Number, maxH as Lang.Number,
                  solid as Lang.Boolean) as Void {
        var n = days.size();
        var todayIndex = n - 1;
        var barW = (width * BAR_W_RATIO).toNumber();
        var gap = (width * GAP_RATIO).toNumber();
        if (barW < 7) { barW = 7; }
        if (gap < 2) { gap = 2; }

        var totalW = (n * barW) + ((n - 1) * gap);
        var startX = (width / 2) - (totalW / 2);
        var unit = maxH / BLOCKS;        // height of one 10% block; 10 blocks = goal = full plot
        var blockH = unit - BLOCK_GAP;

        var goalY = baseY - (BLOCKS * unit);   // the goal is the ceiling, at the top
        dc.setPenWidth(1);
        dc.setColor(Theme.SEG_GHOST, Gfx.COLOR_TRANSPARENT);
        dashedLine(dc, startX, startX + totalW, goalY);

        for (var i = 0; i < n; i += 1) {
            var x = startX + (i * (barW + gap));
            var value = days[i];
            var isToday = (i == todayIndex);

            var pct = (goal > 0) ? (value * 100 / goal) : 0;
            if (pct > 100) { pct = 100; }            // capped at the goal
            var blocks = (pct + 5) / 10;             // round to the nearest 10%
            if (value > 0 && blocks < 1) { blocks = 1; }
            if (blocks > BLOCKS) { blocks = BLOCKS; }

            var color = isToday ? accent : ((value >= goal && value > 0) ? Theme.SEG_LIT : Theme.MUTED);
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);
            if (solid) {
                var h = (blocks * unit) - BLOCK_GAP;
                if (h > 0) { dc.fillRectangle(x, baseY - h, barW, h); }
            } else {
                for (var b = 0; b < blocks; b += 1) {
                    dc.fillRectangle(x, baseY - ((b + 1) * unit) + BLOCK_GAP, barW, blockH);
                }
            }

            dc.setColor(isToday ? accent : Theme.MUTED, Gfx.COLOR_TRANSPARENT);
            dc.drawText(x + (barW / 2), baseY + 3, dayFont, labels[i], Gfx.TEXT_JUSTIFY_CENTER);
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
