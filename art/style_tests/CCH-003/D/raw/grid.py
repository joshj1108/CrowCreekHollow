"""Contact sheet of candidates: python grid.py <dir> <out> [scale] [cols]"""
import sys, glob, os
from PIL import Image, ImageDraw
d, out = sys.argv[1], sys.argv[2]
sc = int(sys.argv[3]) if len(sys.argv) > 3 else 4
cols = int(sys.argv[4]) if len(sys.argv) > 4 else 16
fs = sorted(glob.glob(os.path.join(d, '*.png')))
w, h = Image.open(fs[0]).size
rows = (len(fs) + cols - 1) // cols
o = Image.new('RGBA', (cols * (w * sc + 4), rows * (h * sc + 14)), (110, 120, 105, 255))
dr = ImageDraw.Draw(o)
for i, f in enumerate(fs):
    x, y = (i % cols) * (w * sc + 4), (i // cols) * (h * sc + 14)
    o.alpha_composite(Image.open(f).convert('RGBA').resize((w * sc, h * sc), Image.NEAREST), (x, y + 12))
    dr.text((x + 2, y), os.path.basename(f)[:-4], fill='white')
o.save(out)
