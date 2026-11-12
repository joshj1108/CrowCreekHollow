"""Download a PixelLab character's rotations and lay them out: python rots.py <key> <char_id> [out.png]"""
import sys, os, urllib.request
from PIL import Image
key, cid = sys.argv[1], sys.argv[2]
os.makedirs('states/' + key, exist_ok=True)
ims = []
for d in ['south', 'east', 'north', 'west']:
    url = 'https://backblaze.pixellab.ai/file/pixellab-characters/f5b6c0fc-020e-48ed-b177-910e7d73a6c2/%s/rotations/%s.png' % (cid, d)
    p = 'states/%s/%s.png' % (key, d)
    try:
        open(p, 'wb').write(urllib.request.urlopen(url, timeout=60).read())
        ims.append(Image.open(p).convert('RGBA'))
    except Exception as e:
        print(key, d, e)
if len(sys.argv) > 3:
    w, h = ims[0].size
    o = Image.new('RGBA', (w * 4 * 4, h * 4), (110, 120, 105, 255))
    for i, im in enumerate(ims):
        o.alpha_composite(im.resize((w * 4, h * 4), Image.NEAREST), (i * w * 4, 0))
    o.save(sys.argv[3])
