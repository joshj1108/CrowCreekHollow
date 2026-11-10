"""Stage D: download a PixelLab job's candidates into raw/<key>/NN.png and make a numbered contact sheet.
   python fetch.py img <key> <job_id> <count>      python fetch.py ts <key> <tileset_id>"""
import sys, os, io, json, time, urllib.request
from PIL import Image, ImageDraw
D = os.path.dirname(os.path.abspath(__file__))
def get(url):
    for _ in range(30):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'aoh-fetch'}), timeout=60).read()
        except urllib.error.HTTPError as e:
            if e.code in (423, 429, 502, 503): time.sleep(10); continue
            raise
    raise SystemExit('timeout ' + url)
kind, key = sys.argv[1], sys.argv[2]
out = os.path.join(D, 'raw', key); os.makedirs(out, exist_ok=True)
if kind == 'ts':
    tid = sys.argv[3]
    open(os.path.join(out, 'sheet.png'), 'wb').write(get('https://api.pixellab.ai/mcp/tilesets/%s/image?inline=true' % tid))
    open(os.path.join(out, 'meta.json'), 'wb').write(get('https://api.pixellab.ai/mcp/tilesets/%s/metadata' % tid))
    im = Image.open(os.path.join(out, 'sheet.png')); im.resize((im.width * 4, im.height * 4), Image.NEAREST).save(os.path.join(out, 'preview.png'))
    print(key, im.size); sys.exit()
job, n = sys.argv[3], int(sys.argv[4])
ims = []
for i in range(n):
    p = os.path.join(out, '%02d.png' % i)
    if not os.path.exists(p):
        open(p, 'wb').write(get('https://api.pixellab.ai/mcp/images/%s/download?index=%d' % (job, i)))
    ims.append(Image.open(p).convert('RGBA'))
w, h = ims[0].size; s = 3 if w <= 48 else 2; cols = min(n, 8 if w <= 48 else 4)
rows = (n + cols - 1) // cols
sheet = Image.new('RGBA', (cols * (w * s + 4), rows * (h * s + 14)), (120, 128, 112, 255))
d = ImageDraw.Draw(sheet)
for i, im in enumerate(ims):
    x, y = (i % cols) * (w * s + 4), (i // cols) * (h * s + 14)
    big = im.resize((w * s, h * s), Image.NEAREST); sheet.paste(big, (x, y + 12), big); d.text((x + 2, y), str(i), fill=(255, 255, 0, 255))
sheet.save(os.path.join(D, 'raw', key + '_sheet.png')); print(key, n, sheet.size)
