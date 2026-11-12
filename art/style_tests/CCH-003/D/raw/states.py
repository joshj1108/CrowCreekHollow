"""Lay out every state's rotations: python states.py out.png"""
import sys, os
from PIL import Image, ImageDraw
st = sorted(d for d in os.listdir('group') if os.path.isdir('group/' + d))
sc = 3
o = Image.new('RGBA', (4 * 64 * sc + 90, len(st) * 64 * sc), (110, 120, 105, 255))
dr = ImageDraw.Draw(o)
for r, s in enumerate(st):
    dr.text((4, r * 64 * sc + 80), s, fill='white')
    for c, d in enumerate(['south', 'east', 'north', 'west']):
        p = 'group/%s/rotations/%s.png' % (s, d)
        if os.path.exists(p):
            im = Image.open(p).convert('RGBA')
            o.alpha_composite(im.resize((im.width * sc, im.height * sc), Image.NEAREST), (90 + c * 64 * sc, r * 64 * sc))
o.save(sys.argv[1])
