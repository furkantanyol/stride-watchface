#!/usr/bin/env python3
"""Rasterize DSEG7 Classic into a Garmin (AngelCode BMFont) bitmap font.

Glyphs are rendered white-on-transparent so Garmin uses the alpha as a mask
and tints with setColor() — which lets the view draw a dim "88:88" ghost and
the lit time on top for the real LCD look.
"""
import sys
from PIL import Image, ImageFont, ImageDraw

ttf, out_png, out_fnt, size = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
chars = sys.argv[5] if len(sys.argv) > 5 else "0123456789:"
PAD = 2

font = ImageFont.truetype(ttf, size)
ascent, descent = font.getmetrics()
line_height = ascent + descent

# Render each glyph to its own tight bitmap, recording placement metrics.
glyphs = []
for ch in chars:
    x0, y0, x1, y1 = font.getbbox(ch)
    w, h = x1 - x0, y1 - y0
    img = Image.new("RGBA", (max(w, 1), max(h, 1)), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.text((-x0, -y0), ch, font=font, fill=(255, 255, 255, 255))
    glyphs.append({
        "ch": ch, "img": img, "w": w, "h": h,
        "xoff": x0, "yoff": y0, "xadv": round(font.getlength(ch)),
    })

atlas_w = sum(g["w"] + PAD for g in glyphs) + PAD
atlas_h = max(g["h"] for g in glyphs) + 2 * PAD
atlas = Image.new("RGBA", (atlas_w, atlas_h), (0, 0, 0, 0))

cur = PAD
lines = []
for g in glyphs:
    atlas.paste(g["img"], (cur, PAD))
    lines.append(
        "char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d "
        "xadvance=%d page=0 chnl=15"
        % (ord(g["ch"]), cur, PAD, g["w"], g["h"], g["xoff"], g["yoff"], g["xadv"])
    )
    cur += g["w"] + PAD

atlas.save(out_png)

png_name = out_png.split("/")[-1]
header = [
    'info face="DSEG7Classic" size=%d bold=1 italic=0 charset="" unicode=0 '
    'stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1' % size,
    "common lineHeight=%d base=%d scaleW=%d scaleH=%d pages=1 packed=0"
    % (line_height, ascent, atlas_w, atlas_h),
    'page id=0 file="%s"' % png_name,
    "chars count=%d" % len(glyphs),
]
with open(out_fnt, "w") as f:
    f.write("\n".join(header + lines) + "\n")

print("digit '8' height=%dpx  lineHeight=%d  atlas=%dx%d"
      % (next(g["h"] for g in glyphs if g["ch"] == "8"), line_height, atlas_w, atlas_h))
