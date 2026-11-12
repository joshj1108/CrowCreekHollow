"""Zoomed rows: python zoom.py out.png scale dir1 dir2 ... (each an animations/<name>/<dir> folder)"""
import sys, glob
from PIL import Image, ImageDraw
out, sc, ds = sys.argv[1], int(sys.argv[2]), sys.argv[3:]
rows = [sorted(glob.glob(d + '/frame_*.png')) for d in ds]
W = max(Image.open(r[0]).width for r in rows)
H = max(Image.open(r[0]).height for r in rows)
n = max(len(r) for r in rows)
o = Image.new('RGBA', (n * W * sc, len(rows) * H * sc), (110, 120, 105, 255))
for y, r in enumerate(rows):
    for x, f in enumerate(r):
        im = Image.open(f).convert('RGBA')
        im = im.resize((im.width * sc, im.height * sc), Image.NEAREST)
        o.alpha_composite(im, (x * W * sc + (W * sc - im.width) // 2, y * H * sc + (H * sc - im.height) // 2))
o.save(out)
