"""ART-OVERHAUL-002 E2: the treks' remaining sprites (walkers, dog, the tall one, rope crossing, trail works).

Builds art/farm/trek/e2/ from the PixelLab outputs kept under art/style_tests/ART-OVERHAUL-002/E2/raw/:
  walker_<route>.png   rows south, north, east (west mirrors east); column 0 the standing frame, 1-6 the walk;
                       32 x 32 cells, feet on each cell's bottom opaque row (same for every frame)
  dog.png              one row: standing + 6 trot frames, facing right, 32 x 24 cells
  <prop>.png           tall, stake, rope, steps, tins, hut: cropped to their opaque pixels
Binary alpha everywhere (alpha >= 128 kept). Characters are fetched once into raw/chars/<name>.zip.
Run from the repository root:  python tools/aoh2_e2.py
"""
import io, json, os, zipfile, urllib.request, time
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E2/raw')
OUT = os.path.join(ROOT, 'art/farm/trek/e2')
CHARS = {  # route id -> PixelLab character id
    'mill': '5480705b-f1ff-4321-bed4-ce62133da50d',      # Old Maren (also the wood's edge)
    'orchard': 'e4c2f014-820c-44fe-b597-0834113e2155',   # the Tull boy
    'chapel': 'ec670c71-b934-4a45-9c5d-b424c33afd69',    # the vicar
    'post': 'f1d37094-d727-441a-8820-726a72c11b76',      # the postman
    'grove': 'af62770c-e04c-49ec-81a3-fdfafcfa9ac5',     # the woman in the grey shawl
}
PROPS = {'tall': 'tall/12', 'stake': 'stake/01', 'rope': 'rope/00', 'steps': 'steps/11', 'tins': 'tins/03', 'hut': 'hut/09'}
DOG_JOB = '98a45cca-decd-4d5b-9a75-0a958ac4f381'


def get(url):
    for _ in range(40):
        try:
            return urllib.request.urlopen(urllib.request.Request(url, headers={'User-Agent': 'aoh2'}), timeout=60).read()
        except urllib.error.HTTPError as e:
            if e.code in (423, 429, 502, 503):
                time.sleep(8)
                continue
            raise
    raise SystemExit('timeout ' + url)


def binary(im):
    a = np.array(im.convert('RGBA'))
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    return Image.fromarray(a)


def crop(im):
    """Binary alpha, then only the largest 8-connected shape (drops fragments of neighbouring candidates)."""
    im = binary(im)
    a = np.array(im)
    on = a[..., 3] > 0
    lab = np.zeros(on.shape, int)
    best, best_n, n = 0, 0, 0
    for y, x in zip(*np.nonzero(on)):
        if lab[y, x]:
            continue
        n += 1
        stack, size = [(y, x)], 0
        lab[y, x] = n
        while stack:
            cy, cx = stack.pop()
            size += 1
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < on.shape[0] and 0 <= nx < on.shape[1] and on[ny, nx] and not lab[ny, nx]:
                        lab[ny, nx] = n
                        stack.append((ny, nx))
        if size > best_n:
            best, best_n = n, size
    a[lab != best] = 0
    im = Image.fromarray(a)
    return im.crop(im.getbbox())


def walker(route, cid):
    z = os.path.join(RAW, 'chars', route + '.zip')
    os.makedirs(os.path.dirname(z), exist_ok=True)
    if not os.path.exists(z):
        open(z, 'wb').write(get('https://api.pixellab.ai/mcp/characters/%s/download' % cid))
    zf = zipfile.ZipFile(z)
    names = zf.namelist()
    rows = []
    for d in ('south', 'north', 'east'):
        rot = [n for n in names if n.endswith('rotations/%s.png' % d)][0]
        walk = sorted(n for n in names if '/animations/' in n and '/%s/frame_' % d in n)
        frames = [binary(Image.open(io.BytesIO(zf.read(n)))) for n in [rot] + walk[:6]]
        rows.append(frames)
    # Each frame stands on the cell's bottom row by its own lowest opaque pixel, centred across by its canvas.
    sheet = Image.new('RGBA', (32 * 7, 32 * 3))
    for y, r in enumerate(rows):
        for x, f in enumerate(r):
            bb = f.getbbox()
            sheet.paste(f, (x * 32 + (32 - f.width) // 2, y * 32 + 32 - bb[3]), f)
    sheet.save(os.path.join(OUT, 'walker_%s.png' % route))
    return sheet.size


def dog():
    frames = []
    for i in range(7):
        p = os.path.join(RAW, 'dog_trot', '%02d.png' % i)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        if not os.path.exists(p):
            open(p, 'wb').write(get('https://api.pixellab.ai/mcp/images/%s/download?index=%d' % (DOG_JOB, i)))
        frames.append(binary(Image.open(p)))
    w, h = frames[0].size
    sheet = Image.new('RGBA', (w * 7, h))
    for i, f in enumerate(frames):
        sheet.paste(f, (i * w, 0))
    sheet.save(os.path.join(OUT, 'dog.png'))
    return sheet.size


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    info = {}
    for route, cid in CHARS.items():
        info['walker_' + route] = walker(route, cid)
    info['dog'] = dog()
    for name, src in PROPS.items():
        im = crop(Image.open(os.path.join(RAW, src + '.png')))
        im.save(os.path.join(OUT, name + '.png'))
        info[name] = im.size
    json.dump({k: list(v) for k, v in info.items()}, open(os.path.join(OUT, 'sizes.json'), 'w'), indent=1)
    print(info)
