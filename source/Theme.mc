using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.Lang as Lang;

// Stride color system. A G-Shock GBD-200 surface: midnight black, light-gray
// LCD segments, one red accent on today's data only. All grays are NEUTRAL
// (R=G=B) so nothing quantizes to a blue/purple tint on the 64-color MIP
// panel. Nothing here inverts.
module Theme {
    const BACKGROUND = 0x000000;   // true black for the MIP panel
    const SEG_LIT    = 0xFFFFFF;   // a lit LCD segment (time, distance)
    const SEG_GHOST  = 0x1A1A1A;   // an unlit segment, the faint LCD skeleton
    // Neutral-gray ramp (R=G=B), brightest to dimmest:
    const BAR_FILL   = 0xCCCCCC;   // a lit bar segment (a completed day)
    const MUTED      = 0x8C8C8C;   // labels, axis, date, weekday letters
    const MUTED_DIM  = 0x4A4A4A;   // axis ticks
    const BAR_TRACK  = 0x2E2E2E;   // an unlit bar segment (the gauge "ghost" track)
    const STUB       = 0x242424;   // empty-day baseline marks
    const BOX_EDGE   = 0x5A5A5A;   // boxed-label border

    const ACCENT_DEFAULT = 0xE0301A;   // GBD-200 "RUN" red

    // The accent is the only color the user can change. It marks today's data:
    // today's bar and today's date label. Everything else is mono.
    function accent() as Lang.Number {
        var c = App.Properties.getValue("AccentColor") as Lang.Number?;
        if (c == null) {
            return ACCENT_DEFAULT;
        }
        return c;
    }
}
