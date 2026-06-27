using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;

// Tiny drawn glyphs that label a readout in place of a word — a footprint for
// steps, a battery (filled to level) for Body Battery. Vector shapes only, no
// image assets.
module Icons {

    // A footprint ~7w x 13h with its top-left at (x, y).
    function footprint(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, color as Lang.Number) as Void {
        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x, y + 3, 6, 10, 3);   // sole
        dc.fillCircle(x + 6, y + 2, 2);                 // big toe
    }

    // A battery ~14w x 7h filled to `pct` (0-100), top-left at (x, y).
    function battery(dc as Gfx.Dc, x as Lang.Number, y as Lang.Number, pct as Lang.Number,
                     frame as Lang.Number, fill as Lang.Number) as Void {
        dc.setPenWidth(1);
        dc.setColor(frame, Gfx.COLOR_TRANSPARENT);
        dc.drawRectangle(x, y, 12, 7);
        dc.fillRectangle(x + 12, y + 2, 2, 3);          // terminal nub
        var w = pct * 10 / 100;
        if (w > 10) { w = 10; }
        if (w < 1 && pct > 0) { w = 1; }
        dc.setColor(fill, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(x + 1, y + 1, w, 5);
    }
}
