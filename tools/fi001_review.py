"""FARMHOUSE-INTERIOR-001 review helpers: images for Review Sheet 7 (art and technical validation).

  python tools/fi001_review.py art   OUT.png             every new interior sprite at 3x, labelled with its
                                                         native size, on a mid grey; the fire's ten frames and the
                                                         window variants in rows of their own
  python tools/fi001_review.py grid  GRID.json OUT_DIR   collision and interaction maps for each house stage from
                                                         `tools/interior_test.gd -- dump=GRID.json`
  python tools/fi001_review.py crop  IN.png X,Y,W,H S OUT.png   a crop of a capture, enlarged S times (nearest)
"""
import json, os, sys
from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FI = os.path.join(ROOT, 'art/farm/fi')
BG = (96, 96, 108, 255)


def label(d, xy, text):
    d.text((xy[0] + 1, xy[1] + 1), text, fill=(0, 0, 0))
    d.text(xy, text, fill=(255, 255, 255))


def art(out):
    groups = [
        ('Architecture (per stage 0-3)', ['floor_0', 'floor_1', 'floor_2', 'floor_3', 'floor_dmg', 'wall_top', 'barricade']),
        ('Walls (128x48, stages 0-3)', ['wall_0', 'wall_1', 'wall_2', 'wall_3']),
        ('Hearth stages 0-3 and the clock case', ['hearth_0', 'hearth_1', 'hearth_2', 'hearth_3', 'clock_case']),
        ('Windows', ['win_frame', 'win_open', 'win_boards0', 'win_boards1', 'win_frost', 'web']),
        ('Fire: ten frames, played out of order', ['fire']),
        ('Props (PixelLab, cleaned)', ['bedside', 'chest', 'shelf', 'logbasket', 'barrel', 'sidetable', 'debris', 'brokenchair',
                                       'washtub', 'herbs', 'crates', 'wardrobe', 'rug_bed']),
    ]
    S = 3
    width = 1500
    rows = []
    for title, names in groups:
        ims = [(n, Image.open(os.path.join(FI, n + '.png')).convert('RGBA')) for n in names]
        rows.append((title, ims))
    # lay out
    y = 8
    placed = []
    for title, ims in rows:
        y += 18
        x = 8
        rowh = 0
        for n, im in ims:
            w, h = im.width * S, im.height * S
            if x + w > width - 8:
                x = 8
                y += rowh + 22
                rowh = 0
            placed.append((n, im, x, y))
            x += w + 14
            rowh = max(rowh, h)
        placed.append((title, None, 8, y - 16 - (0 if True else 0)))
        y += rowh + 26
    sheet = Image.new('RGBA', (width, y + 8), BG)
    d = ImageDraw.Draw(sheet)
    for n, im, x, yy in placed:
        if im is None:
            continue
        big = im.resize((im.width * S, im.height * S), Image.NEAREST)
        sheet.paste(big, (x, yy), big)
        label(d, (x, yy + big.height + 2), '%s %dx%d' % (n, im.width, im.height))
    y = 8
    for title, ims in rows:
        pass
    # titles: drawn at the first item of each group, above it
    first = {}
    i = 0
    for title, ims in rows:
        n0 = ims[0][0]
        for n, im, x, yy in placed:
            if im is not None and n == n0 and title not in first:
                first[title] = (x, yy - 16)
                break
    for title, (x, yy) in first.items():
        label(d, (x, yy), title)
    sheet.save(out)
    print('art sheet', sheet.size)


COLORS = {
    'WALL': (30, 24, 20), 'FLOOR': (150, 128, 100), 'TABLE': (110, 70, 40), 'BED': (70, 100, 160), 'DESK': (130, 80, 150),
    'FIREPLACE': (220, 110, 40), 'COOLER': (60, 170, 190), 'STATION': (60, 150, 120), 'EXIT': (70, 170, 70),
}


def grid(path, out_dir):
    data = json.load(open(path))
    kinds = data['kinds']
    T = 14
    names = ['Decrepit (0)', 'Boarded (1)', 'Patched (2)', 'Restored (3)']
    ims = []
    for s, rows in enumerate(data['stages']):
        h, w = len(rows), len(rows[0])
        im = Image.new('RGB', (w * T + 2, h * T + 20), (12, 10, 9))
        d = ImageDraw.Draw(im)
        for y in range(h):
            for x in range(w):
                k, reach = rows[y][x]
                name = kinds[k]
                c = COLORS.get(name, (200, 200, 200))
                if name == 'FLOOR' and not reach:
                    c = (120, 50, 50)          # floor that can't be reached: a room still shut
                r = (1 + x * T, 19 + y * T, x * T + T - 1, 19 + y * T + T - 2)
                d.rectangle(r, fill=c)
                if name == 'FLOOR' and reach:
                    d.point((1 + x * T + T // 2, 19 + y * T + T // 2), fill=(90, 200, 90))
        ex = (12, 12)
        d.rectangle((1 + 12 * T + 3, 19 + 12 * T + 3, 12 * T + T - 4, 19 + 12 * T + T - 5), outline=(255, 255, 255))
        label(d, (2, 2), names[s] + ' - every piece of furniture bought')
        ims.append(im)
    # legend
    leg = Image.new('RGB', (ims[0].width, 46), (12, 10, 9))
    d = ImageDraw.Draw(leg)
    items = list(COLORS.items()) + [('shut room', (120, 50, 50)), ('reachable (dot)', (90, 200, 90))]
    for i, (n, c) in enumerate(items):
        x, y = 4 + (i % 4) * 82, 4 + (i // 4) * 14
        d.rectangle((x, y, x + 10, y + 10), fill=c)
        d.text((x + 14, y), n.lower(), fill=(230, 230, 230))
    for s, im in enumerate(ims):
        im.save(os.path.join(out_dir, 'collision_s%d.png' % s))
    both = Image.new('RGB', (ims[0].width * 2 + 6, ims[0].height * 2 + 6 + leg.height), (12, 10, 9))
    for s, im in enumerate(ims):
        both.paste(im, ((s % 2) * (im.width + 6), (s // 2) * (im.height + 6)))
    both.paste(leg, (0, ims[0].height * 2 + 6))
    both = both.resize((both.width * 2, both.height * 2), Image.NEAREST)
    both.save(os.path.join(out_dir, 'collision_all.png'))
    print('collision maps', both.size)


def crop(src, box, scale, out):
    x, y, w, h = [int(v) for v in box.split(',')]
    im = Image.open(src).crop((x, y, x + w, y + h))
    im.resize((w * int(scale), h * int(scale)), Image.NEAREST).save(out)


if __name__ == '__main__':
    cmd = sys.argv[1]
    if cmd == 'art':
        art(sys.argv[2])
    elif cmd == 'grid':
        grid(sys.argv[2], sys.argv[3])
    elif cmd == 'crop':
        crop(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
