"""Contact sheet of a folder of candidates: python contact.py DIR OUT SCALE [bg]  (index labels in the corner)."""
import sys, os
from PIL import Image, ImageDraw
d, out, s = sys.argv[1], sys.argv[2], int(sys.argv[3])
bg = tuple(int(sys.argv[4][i:i+2], 16) for i in (0, 2, 4)) if len(sys.argv) > 4 else (60, 70, 60)
fs = sorted(f for f in os.listdir(d) if f.endswith('.png'))
ims = [Image.open(os.path.join(d, f)).convert('RGBA') for f in fs]
w = max(i.width for i in ims) * s + 4; h = max(i.height for i in ims) * s + 12
cols = 8; rows = (len(ims) + cols - 1) // cols
sheet = Image.new('RGB', (cols * w, rows * h), bg); dr = ImageDraw.Draw(sheet)
for k, im in enumerate(ims):
    x, y = (k % cols) * w, (k // cols) * h
    sheet.paste(im.resize((im.width * s, im.height * s), Image.NEAREST), (x + 2, y + 10), im.resize((im.width * s, im.height * s), Image.NEAREST))
    dr.text((x + 2, y), fs[k][:-4], fill=(255, 255, 0))
sheet.save(out)
