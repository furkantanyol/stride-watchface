# tools

Helper scripts for building and deploying Stride. Neither is needed for a
normal `monkeyc` build — the generated fonts in `resources/fonts/` are already
checked in. These exist to reproduce those assets and to sideload to the watch.

## genfont.py — regenerate the LCD / number bitmap fonts

Rasterizes a TTF into a Garmin (AngelCode BMFont) `.fnt` + `.png`. Glyphs are
white-on-transparent so Garmin tints them with `setColor()`, which lets the
view layer a dim `88:88` ghost under the lit time.

```sh
python3 -m venv venv && ./venv/bin/pip install Pillow
# time font (DSEG7 Classic Bold):
./venv/bin/python genfont.py DSEG7Classic-Bold.ttf ../resources/fonts/stride_lcd.png ../resources/fonts/stride_lcd.fnt 38 "0123456789:"
# day-number font (Arial Narrow regular):
./venv/bin/python genfont.py "/System/Library/Fonts/Supplemental/Arial Narrow.ttf" ../resources/fonts/stride_num.png ../resources/fonts/stride_num.fnt 14 "0123456789"
```

DSEG7 is the open-source LCD font by keshikan (SIL OFL): https://github.com/keshikan/DSEG

## mtpsend.c — sideload the .prg to the FR245 Music

The FR245 **Music** connects via MTP (not a mountable drive), and the stock
`mtp-sendfile` can't target a folder. This sends to a specific parent folder id.

```sh
brew install libmtp
cc mtpsend.c -I"$(brew --prefix libmtp)/include" -L"$(brew --prefix libmtp)/lib" -lmtp -o mtpsend
# quit Garmin Express first (it claims exclusive USB ownership), then:
mtp-folders                       # find the GARMIN/APPS folder id
./mtpsend ../bin/Stride.prg Stride.PRG <APPS_folder_id>
```
