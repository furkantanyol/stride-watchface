# Fonts

Stride ships with no custom font. It uses Garmin system fonts to stay inside the FR245 memory budget. The time uses `Graphics.FONT_NUMBER_THAI_HOT`, everything else uses the tiny and small system fonts. See `docs/DESIGN.md` for the exact mapping.

## Optional custom font (enhancement, not required)

If you want a more refined numeral for the time, add a single `.fnt` plus its `.png` glyph sheet here and register it in a `resources/fonts/fonts.xml`:

```xml
<fonts>
    <font id="TimeFont" filename="stride_time.fnt"/>
</fonts>
```

Then swap `FONT_NUMBER_THAI_HOT` in `StrideView.mc` for `Ui.loadResource(Rez.Fonts.TimeFont)`. Only do this after confirming the memory headroom in the simulator. A custom font is the first thing to cut if the face gets close to the limit.
