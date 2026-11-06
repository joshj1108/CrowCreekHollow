"""ART-OVERHAUL-001 Stage C: the mining cave's interior.

Turns the kept PixelLab outputs in art/style_tests/ART-OVERHAUL-001/C/raw/ into the game's files:
  art/farm/cave_int/walls.png    three PixelLab transition (cliff) tilesets side by side (sets E, F and G, 64x128
                                 each), all on one floor tile, so a cell can take its tile from any set
  art/farm/cave_int/floor.png    the shared floor tile (16x16)
  art/farm/cave_int/atlas.png    every other piece (decals, dressings, props, ore, the exit steps), packed in rows
  art/farm/cave_int/cave_int.json  the tiles' pattern_4x4 and rects, and each piece's rect and kind
  pixellab-assets.json           the registry: every Stage C job with its ids, prompt, seed and settings
Run from the repository root:  python tools/aoh_cave_int.py

Rules it enforces (AI_COLLAB/ART_OVERHAUL_001_PLAN.md section 2): 16 px tiles drawn at 3x, binary alpha only,
no light baked in, and pieces cropped to their opaque pixels.
"""
import json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-001/C')
RAW = os.path.join(SRC, 'raw')
OUT = os.path.join(ROOT, 'art/farm/cave_int')
SETS = ['e', 'f', 'g']   # the three cliff tilesets that share set C's floor (tiles/ts_<k>.png and .json)

# Picks from the candidate sheets (raw/<sheet>/<NN>.png). kind decides where the game places a piece:
#   small, crack, gravel, puddle            flat decals on floor tiles, anywhere
#   roots, leaves, pebbles                  flat decals on floor tiles near the way out (leaves and two pebble
#                                           pieces are Stage B's, from art/farm/cave_ext/)
#   moss, drip                              hung from the top of a wall face (moss near the way out, drip deeper)
#   fern                                    low plants at the foot of a face near the way out
#   foot                                    a low rubble heap at the foot of a face, inside the wall tile
#   spire, boulder, mossrock                stood on the north lip of a wall (front layer); mossrock near the way out
#   copper, iron                            ore, one per ore tile
#   steps                                   the way out
PICKS = {
    'small': [('small', n) for n in (0, 2, 3, 4, 8, 10, 12, 48, 52, 50, 53, 56, 60)],
    'crack': [('decals', n) for n in (0, 2)],
    'gravel': [('decals', n) for n in (8, 9, 10, 11)],
    'puddle': [('small', n) for n in (37, 41, 45)],
    'pebbles': [('rocks', n) for n in (0, 61)] + [('cave_ext', 'pebbles_0'), ('cave_ext', 'pebbles_1')],
    'roots': [('decals', n) for n in (40, 42, 44)],
    'leaves': [('cave_ext', 'litter_%d' % n) for n in range(2)],
    'moss': [('mossfringe', n) for n in (48, 49, 50, 51)],
    'drip': [('drip', n) for n in (28, 30, 44, 46)],
    'fern': [('dress', n) for n in (50, 54, 58)],
    'foot': [('rocks', n) for n in (24, 25, 33, 34)],
    'spire': [('rocks', n) for n in (16, 17, 18, 19)],
    'boulder': [('rocks', n) for n in (1, 2, 3)],
    'mossrock': [('rocks', n) for n in (49, 51)],
    'copper': [('copper', n) for n in (16, 22, 3)],
    'iron': [('iron', n) for n in (0, 7, 28)],
    'steps': [('steps2', 34)],
}


OUTLINE = (31, 27, 29)   # #1f1b1d, the farm's dark outline step


def key_drip(im):
    """The drip candidates came on an opaque near-black backing (the wall). Keep the pale stone points, drop the
    backing, and outline what is left in the dark outline colour."""
    lum = 0.3 * im[..., 0] + 0.55 * im[..., 1] + 0.15 * im[..., 2]
    keep = (im[..., 3] > 0) & (lum > 40)
    # only what hangs from the top edge (the backing's bottom row leaves a stray line)
    seen = np.zeros_like(keep)
    stack = [(0, x) for x in range(keep.shape[1]) if keep[0, x]]
    while stack:
        y, x = stack.pop()
        if 0 <= y < keep.shape[0] and 0 <= x < keep.shape[1] and keep[y, x] and not seen[y, x]:
            seen[y, x] = True
            stack += [(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)]
    keep = seen
    out = np.zeros_like(im)
    out[keep] = im[keep]
    ring = np.zeros_like(keep)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        ring |= np.roll(np.roll(keep, dy, 0), dx, 1)
    ring &= ~keep
    ring[0, :] = False   # the top edge meets the rock's lip, so no outline there
    out[ring] = (*OUTLINE, 255)
    return out


def load(sheet, n):
    if sheet == 'cave_ext':   # Stage B's own pieces, so the floor by the way out shares the hill's litter
        im = np.array(Image.open(os.path.join(ROOT, 'art/farm/cave_ext', n + '.png')).convert('RGBA'))
    else:
        im = np.array(Image.open(os.path.join(RAW, sheet, '%02d.png' % n)).convert('RGBA'))
    if sheet == 'drip':
        im = key_drip(im)
    im[..., 3] = np.where(im[..., 3] >= 128, 255, 0)     # binary alpha, no partial transparency
    im[im[..., 3] == 0] = 0
    return im


def crop(im):
    ys, xs = np.nonzero(im[..., 3])
    return im[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def main():
    os.makedirs(OUT, exist_ok=True)
    # Walls: the three sets side by side. Each set's 25 tiles are found by pattern_4x4, which all three share.
    metas = [json.load(open(os.path.join(RAW, 'tiles', 'ts_%s.json' % k)))['tileset_data']['tiles'] for k in SETS]
    sheets = [Image.open(os.path.join(RAW, 'tiles', 'ts_%s.png' % k)).convert('RGBA') for k in SETS]
    walls = Image.new('RGBA', (64 * len(SETS), 128))
    for i, sh in enumerate(sheets):
        a = np.array(sh)
        assert set(np.unique(a[..., 3])) <= {255}, 'tileset %s has transparency' % SETS[i]
        walls.paste(sh, (64 * i, 0))
    walls.save(os.path.join(OUT, 'walls.png'))
    key = lambda t: json.dumps(t['pattern_4x4'], sort_keys=True)
    tiles = []
    for t in metas[0]:
        rects = []
        for i, m in enumerate(metas):
            match = [u for u in m if key(u) == key(t)]
            assert len(match) == 1, 'set %s lacks a tile' % SETS[i]
            b = match[0]['bounding_box']
            rects.append([b['x'] + 64 * i, b['y']])
        p = t['pattern_4x4']
        tiles.append({'p': p['row_0'] + p['row_1'] + p['row_2'] + p['row_3'], 'r': rects})
    # The floor: set E's all-lower tile (the three sets were made on set C's floor tile, pasted exactly).
    floor = next(t for t in metas[0] if all(v == 'lower' for v in t['corners'].values()))['bounding_box']
    for i, m in enumerate(metas[1:], 1):
        b = next(t for t in m if all(v == 'lower' for v in t['corners'].values()))['bounding_box']
        same = np.array_equal(np.array(sheets[0].crop((floor['x'], floor['y'], floor['x'] + 16, floor['y'] + 16))),
                              np.array(sheets[i].crop((b['x'], b['y'], b['x'] + 16, b['y'] + 16))))
        assert same, 'set %s floor differs' % SETS[i]
    sheets[0].crop((floor['x'], floor['y'], floor['x'] + 16, floor['y'] + 16)).save(os.path.join(OUT, 'floor.png'))
    # Pieces, packed in shelf rows 256 px wide.
    pieces, ims = [], []
    for kind, picks in PICKS.items():
        for sheet, n in picks:
            im = crop(load(sheet, n))
            ims.append(im)
            pieces.append({'kind': kind, 'src': '%s/%s' % (sheet, n if isinstance(n, str) else '%02d' % n), 'w': int(im.shape[1]), 'h': int(im.shape[0])})
    W, x, y, row_h, pos = 256, 0, 0, 0, []
    for im in ims:
        h, w = im.shape[:2]
        if x + w > W:
            x, y, row_h = 0, y + row_h + 1, 0
        pos.append((x, y))
        x += w + 1
        row_h = max(row_h, h)
    atlas = np.zeros((y + row_h, W, 4), np.uint8)
    for im, (px, py), p in zip(ims, pos, pieces):
        h, w = im.shape[:2]
        atlas[py:py + h, px:px + w] = im
        p['x'], p['y'] = px, py
    assert set(np.unique(atlas[..., 3])) <= {0, 255}
    Image.fromarray(atlas, 'RGBA').save(os.path.join(OUT, 'atlas.png'))
    json.dump({'tiles': tiles, 'sets': len(SETS), 'pieces': pieces}, open(os.path.join(OUT, 'cave_int.json'), 'w'),
              indent=0)
    print('walls %d tiles x %d sets, %d pieces, atlas %dx%d' % (len(tiles), len(SETS), len(pieces), W, atlas.shape[0]))


if __name__ == '__main__':
    main()
