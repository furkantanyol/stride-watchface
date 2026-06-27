using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Lang as Lang;

// Stride color system, from the Claude Design tokens. The MIP panel quantizes
// each channel to one of four levels (00 / 55 / AA / FF) → 64 colors, so every
// token is held on that grid and nothing shifts on-panel. Grays are strictly
// R=G=B (any blue tint quantizes to purple). One accent, no gradients.
module Theme {
    const BACKGROUND = 0x000000;   // panel base / off pixels
    const SEG_LIT    = 0xFFFFFF;   // time, readouts, days that cleared the goal
    const MUTED      = 0xAAAAAA;   // labels, axis, day numbers, days under goal
    const SEG_GHOST  = 0x555555;   // unlit "88:88" shadow behind the time; goal line

    const ACCENT_DEFAULT = 0xFFAA00;   // amber — today's bar and date number

    // The accent is the only color the user can change. It marks today's data.
    function accent() as Lang.Number {
        var c = App.Properties.getValue("AccentColor") as Lang.Number?;
        if (c == null) {
            return ACCENT_DEFAULT;
        }
        return c;
    }
}
