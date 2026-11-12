"""Downloads a PixelLab image job's images into raw/<key>/NN.png and writes raw/<key>_contact.png.

  python fetch.py <key> <job_id> [count]
Images come from the no-auth download URL (?index=N). The contact sheet shows every candidate at 4x on a cave-dark
ground, numbered, so one look picks one.
"""
import io, os, sys, urllib.request, urllib.error
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))


def get(url):
    for _ in range(3):
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                return r.read()
        except urllib.error.HTTPError as e:
            if e.code in (404, 400, 416):
                return None
    return None


def main():
    key, job = sys.argv[1], sys.argv[2]
    count = int(sys.argv[3]) if len(sys.argv) > 3 else 64
    out = os.path.join(HERE, key)
    os.makedirs(out, exist_ok=True)
    ims = []
    for i in range(count):
        p = os.path.join(out, '%02d.png' % i)
        if not os.path.exists(p):
            data = get('https://api.pixellab.ai/mcp/images/%s/download?index=%d' % (job, i))
            if data is None:
                break
            Image.open(io.BytesIO(data)).convert('RGBA').save(p)
        ims.append(Image.open(p).convert('RGBA'))
    if not ims:
        print('nothing downloaded'); return
    s = 4
    w, h = ims[0].width * s + 8, ims[0].height * s + 16
    cols = 8
    rows = (len(ims) + cols - 1) // cols
    sheet = Image.new('RGBA', (cols * w, rows * h), (34, 32, 30, 255))
    d = ImageDraw.Draw(sheet)
    for i, im in enumerate(ims):
        x, y = (i % cols) * w + 4, (i // cols) * h + 12
        sheet.alpha_composite(im.resize((im.width * s, im.height * s), Image.NEAREST), (x, y))
        d.text((x, y - 11), str(i), fill=(220, 210, 180, 255))
    sheet.save(os.path.join(HERE, key + '_contact.png'))
    print(key, len(ims), 'images', ims[0].size)


if __name__ == '__main__':
    main()
