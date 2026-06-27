# Fonts

Stride ships two small bitmap fonts, generated from TTFs by `tools/genfont.py`
(white-on-transparent glyphs that Garmin tints with `setColor`). Everything
else uses Garmin system fonts to stay inside the FR245M memory budget.

| Resource id | Files                     | Source TTF                | Use                    |
|-------------|---------------------------|---------------------------|------------------------|
| `LcdTime`   | `stride_lcd.fnt` / `.png` | DSEG7 Classic Bold, ~38px | The time (7-seg LCD)   |
| `DayNum`    | `stride_num.fnt` / `.png` | Arial Narrow regular, ~14 | Day numbers under bars |

DSEG7 is the open-source LCD font by keshikan (SIL Open Font License):
https://github.com/keshikan/DSEG

To regenerate either, see `tools/README.md`. The time font carries the digits
and `:`; the ghost "88:88" skeleton behind the live time relies on DSEG7
lighting every segment for `8`.
