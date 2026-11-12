"""All game sheets of art/player/d/ in one picture, a red line on FEET: python sheetview.py out.png [filter] [scale]"""
import sys, glob, os
from PIL import Image, ImageDraw
flt = sys.argv[2] if len(sys.argv) > 2 else ''
sc = int(sys.argv[3]) if len(sys.argv) > 3 else 1
fs = [f for f in sorted(glob.glob('art/player/d/*_*.png')) if flt in os.path.basename(f)]
C, FEET = 96, 65
o = Image.new('RGBA', (150 + 9 * C * sc, len(fs) * C * sc), (110, 120, 105, 255))
d = ImageDraw.Draw(o)
for r, f in enumerate(fs):
    im = Image.open(f).convert('RGBA')
    im = im.resize((im.width * sc, im.height * sc), Image.NEAREST)
    o.alpha_composite(im, (150, r * C * sc))
    d.text((2, r * C * sc + 40 * sc), os.path.basename(f)[:-4], fill='white')
    d.line((150, r * C * sc + (FEET + 1) * sc, o.width, r * C * sc + (FEET + 1) * sc), fill=(200, 60, 60, 120))
o.save(sys.argv[1])
