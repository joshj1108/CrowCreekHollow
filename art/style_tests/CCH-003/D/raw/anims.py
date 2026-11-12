"""Lay out animations: python anims.py out.png [filter] â€” one row per state/animation/direction."""
import sys, os, glob
from PIL import Image, ImageDraw
flt = sys.argv[2] if len(sys.argv) > 2 else ''
rows = []
for d in sorted(glob.glob('group/*/animations/*/*')):
    if flt in d and os.path.isdir(d):
        rows.append(d)
sc, cell = 3, 80
o = Image.new('RGBA', (170 + 17 * cell * sc // 2, max(1, len(rows)) * cell * sc // 2), (110, 120, 105, 255))
dr = ImageDraw.Draw(o)
for r, d in enumerate(rows):
    y = r * cell * sc // 2
    dr.text((2, y + 50), d[6:].replace(os.sep, '/').replace('/animations', ''), fill='white')
    for i, f in enumerate(sorted(glob.glob(d + '/frame_*.png'))):
        im = Image.open(f).convert('RGBA')
        s = sc / 2
        im = im.resize((int(im.width * 1.5), int(im.height * 1.5)), Image.NEAREST)
        o.alpha_composite(im, (170 + i * cell * sc // 2 + (cell * sc // 2 - im.width) // 2, y + (cell * sc // 2 - im.height) // 2))
o.save(sys.argv[1])
print(len(rows), 'rows')
