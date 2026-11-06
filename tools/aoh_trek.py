"""ART-OVERHAUL-001 Stage D: the treks' PixelLab art.

Turns the kept PixelLab outputs in art/style_tests/ART-OVERHAUL-001/D/raw/ into the game's files:
  art/farm/trek/ground_<biome>.png  forest, pasture, hollow: the trail on the dual grid (the tile for corner mask m
                                    at column m%4, row m/4; bits NW 1, NE 2, SW 4, SE 8 = trail), plus at x 64 the
                                    open-ground tile (row 0) and the all-trail tile (row 1) in four mirrorings each
  art/farm/trek/ground_creek.png    creek water (mask bits = water) with its banks, the same layout
  art/farm/trek/atlas.png           every other piece, packed in rows
  art/farm/trek/trek.json           each piece's rect and kind (and the hollow tree's hole)
Run from the repository root:  python tools/aoh_trek.py

Rules (AI_COLLAB/ART_OVERHAUL_001_PLAN.md section 2): 16 px tiles drawn at 3x, binary alpha, no light baked in,
pieces cropped to their opaque pixels, fragments of neighbouring candidates dropped.
"""
import json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-001/D')
RAW = os.path.join(SRC, 'raw')
OUT = os.path.join(ROOT, 'art/farm/trek')
EXT = os.path.join(ROOT, 'art/farm/cave_ext')
FARM = os.path.join(ROOT, 'art/farm/concept')
BIT = {'NW': 1, 'NE': 2, 'SW': 4, 'SE': 8}

# Ground: the tileset kept for each biome, colour fixes (old hex -> new hex), and which terrain the mask bits mean.
TRAIL_BROWN = {'#8a8878': '#9a8460', '#7b7760': '#86704e', '#676458': '#6e5a40', '#4c4644': '#52422f', '#403e37': '#433628'}
HOLLOW_PATH = {'#7b7760': '#5f5c4e', '#676458': '#524f45', '#8a8878': '#6b6858'}
GROUND = {'forest': ('forest2', TRAIL_BROWN, 'upper'), 'pasture': ('pasture2', {}, 'upper'),
          'hollow': ('hollow2', HOLLOW_PATH, 'upper'), 'creek': ('creek', {}, 'lower')}

# Picks: kind -> [(sheet, index) or ('ext', Stage B file)]. Where the game puts them (scripts/trek_art.gd):
#   big                              the farm's own fir and maple (FARM-001 concept), deep in the wood
#   fir maple dead apple ancient     trees on the wood's tiles
#   hollowtree                       the hollow-tree event (its hole's centre is recorded)
#   u_<biome>                        undergrowth: wood's tiles where a tree would hide open ground
#   d_<biome>                        flat floor decals on open ground
#   reeds, stepstones                creek banks
#   u_small                          one-tile undergrowth where nothing larger fits
#   log log_short sign cairn bridge stone wheel mill chapel stile    events and destinations
PICKS = {
    'big': [('farm', 'src_fir'), ('farm', 'src_maple')],
    'fir': [('fir', n) for n in (0, 8, 17, 18, 24, 26, 27, 23)],
    'maple': [('maple', n) for n in (4, 7, 10, 13, 25, 27, 19, 30)],
    'dead': [('dead', n) for n in (0, 1, 6, 13, 15, 16, 25, 26)],
    'apple': [('apple', n) for n in (13, 14, 26, 28, 29)],
    'ancient': [('ancient', n) for n in (0, 5, 9, 10)],
    'hollowtree': [('dead', 29), ('dead', 3)],
    'u_forest': [('ext', 'fern_0'), ('ext', 'fern_1'), ('ext', 'fern_2'), ('ext', 'fern_3'), ('ext', 'bramble_0'),
                 ('ext', 'bramble_1'), ('ext', 'boulder_1'), ('dec_forest', 48), ('dec_forest', 52),
                 ('dec_forest', 56), ('dec_forest', 59), ('dec_forest', 1), ('dec_forest', 8)],
    'd_forest': [('dec_forest', n) for n in (3, 7, 11, 13, 16, 22, 24, 26, 29, 31, 32, 33, 37, 41, 49)]
                + [('ext', 'litter_0'), ('ext', 'litter_1'), ('ext', 'litter_2'), ('ext', 'pebbles_0'), ('ext', 'pebbles_1')],
    'u_pasture': [('dec_pasture', n) for n in (2, 3, 7, 9, 11, 13, 17, 21, 25, 29, 32, 33, 34, 35, 52, 54)],
    'd_pasture': [('dec_pasture', n) for n in (41, 43, 46, 56, 59)] + [('dec_forest', n) for n in (29, 31, 33)],
    'u_hollow': [('dec_hollow', n) for n in (0, 2, 3, 8, 9, 11, 13, 20, 22, 33, 35, 49, 51, 56, 57)],
    'd_hollow': [('dec_hollow', n) for n in (41, 43, 45)] + [('dec_forest', n) for n in (11, 13, 16, 22)],
    'reeds': [('dec_creek', n) for n in (0, 2, 6, 10, 14, 15, 25, 28, 30, 40, 44, 48, 52)],
    'stepstones': [('dec_creek', n) for n in (16, 19, 22, 37)],
    'log': [('log', n) for n in (0, 3, 8)],
    'sign': [('sign', 6)],
    'cairn': [('cairn2', n) for n in (0, 3, 18)],
    'log_short': [('logshort', n) for n in (1, 5, 20)],
    'u_small': [('small', n) for n in (1, 3, 9, 16, 18, 23, 26, 29, 33, 36, 41, 45, 46, 49, 52)],
    'bridge': [('bridge', 2)],
    'stone': [('stone', n) for n in (1, 3, 14, 26, 35)],
    'wheel': [('wheel', 9)],
    'mill': [('mill3', 13)],
    'chapel': [('chapel3', 9)],
    'stile': [('stile', 3)],
}
# Pieces made of many small separate bits by design (keep every part the canvas edge didn't cut).
SCATTER = {'d_forest', 'd_pasture', 'd_hollow', 'stepstones', 'cairn'}


def hexrgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def recolour(im, table):
    a = np.array(im.convert('RGBA'))
    for old, new in table.items():
        o, n = hexrgb(old), hexrgb(new)
        m = (a[:, :, 0] == o[0]) & (a[:, :, 1] == o[1]) & (a[:, :, 2] == o[2])
        a[m, :3] = n
    return Image.fromarray(a)


def ground(key, table, bit_on):
    m = json.load(open(os.path.join(RAW, key, 'meta.json')))
    sh = recolour(Image.open(os.path.join(RAW, key, 'sheet.png')), table)
    out = Image.new('RGBA', (128, 64))
    tiles = {}
    for t in m['tileset_data']['tiles']:
        mask = sum(BIT[c] for c, v in t['corners'].items() if v == bit_on)
        b = t['bounding_box']
        tiles[mask] = sh.crop((b['x'], b['y'], b['x'] + 16, b['y'] + 16))
    for mask, tile in tiles.items():
        out.paste(tile, ((mask % 4) * 16, (mask // 4) * 16))
    for row, mask in enumerate((0, 15)):
        t = tiles[mask]
        for i, f in enumerate((t, t.transpose(Image.FLIP_LEFT_RIGHT), t.transpose(Image.FLIP_TOP_BOTTOM),
                               t.transpose(Image.FLIP_LEFT_RIGHT).transpose(Image.FLIP_TOP_BOTTOM))):
            out.paste(f, (64 + i * 16, row * 16))
    a = np.array(out)
    a[:, :, 3] = np.where(a[:, :, 3] >= 128, 255, 0)
    return Image.fromarray(a), sorted(tiles)


def components(alpha):
    """8-connected opaque regions: (labels array, count)."""
    h, w = alpha.shape
    lab = np.zeros((h, w), int)
    n = 0
    for y in range(h):
        for x in range(w):
            if alpha[y, x] and not lab[y, x]:
                n += 1
                stack = [(y, x)]
                lab[y, x] = n
                while stack:
                    cy, cx = stack.pop()
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            ny, nx = cy + dy, cx + dx
                            if 0 <= ny < h and 0 <= nx < w and alpha[ny, nx] and not lab[ny, nx]:
                                lab[ny, nx] = n
                                stack.append((ny, nx))
    return lab, n


def piece(sheet, n, kind):
    if sheet in ('ext', 'farm'):
        im = Image.open(os.path.join(EXT if sheet == 'ext' else FARM, n + '.png')).convert('RGBA')
    else:
        im = Image.open(os.path.join(RAW, sheet, '%02d.png' % n)).convert('RGBA')
    a = np.array(im)
    alpha = a[:, :, 3] >= 128
    a[:, :, 3] = np.where(alpha, 255, 0)
    if sheet not in ('ext', 'farm'):
        lab, cnt = components(alpha)
        sizes = [(lab == i).sum() for i in range(cnt + 1)]
        big = int(np.argmax(sizes[1:])) + 1 if cnt else 0
        h, w = alpha.shape
        keep = np.zeros_like(alpha)
        for i in range(1, cnt + 1):
            ys, xs = np.nonzero(lab == i)
            edge = ys.min() == 0 or xs.min() == 0 or ys.max() == h - 1 or xs.max() == w - 1
            if i == big or (not edge and (kind in SCATTER or sizes[i] >= 6)):
                keep |= lab == i
        a[~keep] = 0
    im = Image.fromarray(a)
    return im.crop(im.getbbox())


def hole_centre(im):
    """The middle of the darkest blob in the trunk's lower two thirds (the hollow tree's hole)."""
    a = np.array(im).astype(int)
    lum = a[:, :, 0] + a[:, :, 1] + a[:, :, 2]
    h = a.shape[0]
    dark = (a[:, :, 3] > 0) & (lum < 60)
    dark[: h // 3] = False
    inner = dark & np.roll(dark, 1, 1) & np.roll(dark, -1, 1) & np.roll(dark, 1, 0) & np.roll(dark, -1, 0)
    ys, xs = np.nonzero(inner if inner.any() else dark)
    return [int(round(xs.mean())), int(round(ys.mean()))] if len(xs) else [im.width // 2, int(h * 0.7)]


def main():
    os.makedirs(OUT, exist_ok=True)
    meta = {'tile': 16, 'ground': {}, 'kinds': {}, 'pieces': []}
    for biome, (key, table, on) in GROUND.items():
        im, masks = ground(key, table, on)
        im.save(os.path.join(OUT, 'ground_%s.png' % biome))
        meta['ground'][biome] = {'file': 'ground_%s.png' % biome, 'source': key, 'masks': len(masks)}
    pieces = []
    for kind, picks in PICKS.items():
        for sheet, n in picks:
            pieces.append((kind, sheet, n, piece(sheet, n, kind)))
    # Shelf packing, tallest first, 512 px wide, 1 px gaps.
    order = sorted(range(len(pieces)), key=lambda i: -pieces[i][3].height)
    W, x, y, row_h, at = 512, 0, 0, 0, {}
    for i in order:
        im = pieces[i][3]
        if x + im.width > W:
            x, y, row_h = 0, y + row_h + 1, 0
        at[i] = (x, y)
        x += im.width + 1
        row_h = max(row_h, im.height)
    atlas = Image.new('RGBA', (W, y + row_h))
    for i, (kind, sheet, n, im) in enumerate(pieces):
        atlas.paste(im, at[i])
        rec = {'kind': kind, 'src': '%s/%s' % (sheet, n), 'r': [at[i][0], at[i][1], im.width, im.height]}
        if kind == 'hollowtree':
            rec['hole'] = hole_centre(im)
        meta['kinds'].setdefault(kind, []).append(len(meta['pieces']))
        meta['pieces'].append(rec)
    atlas.save(os.path.join(OUT, 'atlas.png'))
    json.dump(meta, open(os.path.join(OUT, 'trek.json'), 'w'), indent=1)
    print('atlas', atlas.size, len(pieces), 'pieces')
    for k, v in meta['kinds'].items():
        print(' ', k, [tuple(meta['pieces'][i]['r'][2:]) for i in v])


if __name__ == '__main__':
    main()
