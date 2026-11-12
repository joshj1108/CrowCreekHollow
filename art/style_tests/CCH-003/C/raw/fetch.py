"""Downloads every candidate of the jobs in jobs.txt into raw/<key>/NN.png and builds raw/<key>_sheet.png
(candidates at 3x on a mid grey, numbered). Usage: python fetch.py [key ...]"""
import os, sys, urllib.request
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))


def jobs():
    for line in open(os.path.join(HERE, 'jobs.txt')):
        if line.strip() and not line.startswith('#'):
            p = line.split()
            yield p[0], p[3]


def fetch(key, job):
    d = os.path.join(HERE, key)
    os.makedirs(d, exist_ok=True)
    i = 0
    while True:
        out = os.path.join(d, '%02d.png' % i)
        if not os.path.exists(out):
            try:
                url = 'https://api.pixellab.ai/mcp/images/%s/download?index=%d' % (job, i)
                data = urllib.request.urlopen(url, timeout=60).read()
            except Exception:
                break
            if data[:4] != b'\x89PNG':
                break
            open(out, 'wb').write(data)
        i += 1
        if i >= 64:
            break
    return sorted(f for f in os.listdir(d) if f.endswith('.png'))


def sheet(key, files):
    d = os.path.join(HERE, key)
    ims = [Image.open(os.path.join(d, f)).convert('RGBA') for f in files]
    w, h = ims[0].size
    s = 3 if w <= 32 else 2
    cols = 8
    cw, ch = w * s + 6, h * s + 14
    rows = (len(ims) + cols - 1) // cols
    out = Image.new('RGBA', (cols * cw, rows * ch), (110, 110, 118, 255))
    dr = ImageDraw.Draw(out)
    for i, im in enumerate(ims):
        x, y = (i % cols) * cw, (i // cols) * ch
        out.paste(im.resize((w * s, h * s), Image.NEAREST), (x + 3, y + 12), im.resize((w * s, h * s), Image.NEAREST))
        dr.text((x + 3, y), str(i), fill=(255, 255, 255, 255))
    out.save(os.path.join(HERE, key + '_sheet.png'))


if __name__ == '__main__':
    want = sys.argv[1:]
    for key, job in jobs():
        if want and key not in want:
            continue
        files = fetch(key, job)
        if files:
            sheet(key, files)
        print(key, len(files))
