"""grid.py out.png key/NN ... : each candidate cleaned and cropped at 8x with a grid every 4 px and row/col labels."""
import os, sys
import numpy as np
from PIL import Image, ImageDraw
from unwrap import unwrap
HERE = os.path.dirname(os.path.abspath(__file__))
S = 8
ims = []
for arg in sys.argv[2:]:
    a = unwrap(np.array(Image.open(os.path.join(HERE, arg + '.png')).convert('RGBA')))
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    ys, xs = np.nonzero(a[..., 3]); a = a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    im = Image.fromarray(a).resize((a.shape[1] * S, a.shape[0] * S), Image.NEAREST)
    c = Image.new('RGBA', (im.width + 24, im.height + 24), (96, 92, 88, 255))
    c.paste(im, (20, 20), im); d = ImageDraw.Draw(c)
    for x in range(0, a.shape[1] + 1, 4):
        d.line([(20 + x * S, 20), (20 + x * S, 20 + im.height)], fill=(0, 255, 255, 120)); d.text((20 + x * S, 6), str(x), fill=(255, 255, 0, 255))
    for y in range(0, a.shape[0] + 1, 4):
        d.line([(20, 20 + y * S), (20 + im.width, 20 + y * S)], fill=(0, 255, 255, 120)); d.text((0, 20 + y * S), str(y), fill=(255, 255, 0, 255))
    ims.append(c)
W = sum(i.width for i in ims) + 8 * len(ims); H = max(i.height for i in ims)
o = Image.new('RGBA', (W, H), (60, 60, 60, 255)); x = 0
for i in ims:
    o.paste(i, (x, 0)); x += i.width + 8
o.save(sys.argv[1])
