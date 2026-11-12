"""Builds a review mosaic: for each key, its first N candidates at 2x in one row band, labelled. usage: mosaic.py out.png N key..."""
import os, sys
from PIL import Image, ImageDraw
import numpy as np
from unwrap import unwrap
HERE = os.path.dirname(os.path.abspath(__file__))
out, n, keys = sys.argv[1], int(sys.argv[2]), sys.argv[3:]
bands = []
for k in keys:
    fs = sorted(f for f in os.listdir(os.path.join(HERE, k)) if f.endswith('.png'))[:n]
    ims = [Image.fromarray(unwrap(np.array(Image.open(os.path.join(HERE, k, f)).convert("RGBA")))) for f in fs]
    w, h = ims[0].size
    s = 2
    cols = min(len(ims), max(1, 1600 // (w * s + 4)))
    rows = (len(ims) + cols - 1) // cols
    b = Image.new('RGBA', (cols * (w * s + 4), rows * (h * s + 12) + 12), (110, 110, 118, 255))
    d = ImageDraw.Draw(b)
    d.text((2, 0), k, fill=(255, 255, 0, 255))
    for i, im in enumerate(ims):
        x, y = (i % cols) * (w * s + 4), 12 + (i // cols) * (h * s + 12)
        big = im.resize((w * s, h * s), Image.NEAREST)
        b.paste(big, (x + 2, y + 10), big)
        d.text((x + 2, y), str(i), fill=(255, 255, 255, 255))
    bands.append(b)
W = max(b.width for b in bands); H = sum(b.height for b in bands)
o = Image.new('RGBA', (W, H), (60, 60, 66, 255)); y = 0
for b in bands:
    o.paste(b, (0, y)); y += b.height
o.save(out)
