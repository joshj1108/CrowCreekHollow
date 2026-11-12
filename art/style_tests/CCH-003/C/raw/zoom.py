"""zoom.py out.png scale key:i,j,k ... : the named candidates, cleaned (binary alpha, cropped), side by side, labelled."""
import os, sys
import numpy as np
from PIL import Image, ImageDraw
from unwrap import unwrap
HERE = os.path.dirname(os.path.abspath(__file__))
out, s = sys.argv[1], int(sys.argv[2])
items = []
for arg in sys.argv[3:]:
    k, idx = arg.split(':')
    for i in idx.split(','):
        a = unwrap(np.array(Image.open(os.path.join(HERE, k, '%02d.png' % int(i))).convert('RGBA')))
        a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
        ys, xs = np.nonzero(a[..., 3])
        a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
        items.append(('%s/%s %dx%d' % (k, i, a.shape[1], a.shape[0]), Image.fromarray(a)))
W = 1900
x = y = 0; rowh = 0; pos = []
for lab, im in items:
    w, h = im.width * s + 8, im.height * s + 16
    w = max(w, 90)
    if x + w > W:
        x, y = 0, y + rowh; rowh = 0
    pos.append((x, y)); x += w; rowh = max(rowh, h)
o = Image.new('RGBA', (W, y + rowh), (96, 92, 88, 255)); d = ImageDraw.Draw(o)
for (lab, im), (x, y) in zip(items, pos):
    big = im.resize((im.width * s, im.height * s), Image.NEAREST)
    o.paste(big, (x + 4, y + 14), big); d.text((x + 4, y + 1), lab, fill=(255, 255, 255, 255))
o.save(out)
