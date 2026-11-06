"""ART-OVERHAUL-001 Stage B: the farm's north-west cave exterior.

Turns the kept PixelLab outputs in art/style_tests/ART-OVERHAUL-001/B/raw/ into the game's pieces:
  art/farm/cave_ext/*.png         the cliff (top strip, west and east sections), the mouth, the lip, props, decals
  art/farm/cave_ext/pieces.json   their placements, in scenery.json's record format, drawn by farm_scenery.gd
                                  when CAVE_EXT_V2 is on
  pixellab-assets.json            the registry: every PixelLab job with its ids, prompt, seed and settings
Run from the repository root:  python tools/aoh_cave_ext.py

Rules it enforces (AI_COLLAB/ART_OVERHAUL_001_PLAN.md section 2): 16 px tiles drawn at 3x, binary alpha only,
no lighting baked in beyond form shading, the opening's dark core centred on the doorway column (11), the cliff's
foot on the bottom of row 8, and nothing opaque on a walkable tile south of row 8 except flat decals and low ferns.
"""
import json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-001/B')
RAW = os.path.join(SRC, 'raw')
# B2 (Stage B corrections): the cliff re-inpainted as irregular rock, the jambs too, and hand-drawn roots
# (B2/scripts/roots.py), built from B/raw/mouth_a.png.
RAW_B2 = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-001/B2/raw')
OUT = os.path.join(ROOT, 'art/farm/cave_ext')
RES = 'res://art/farm/cave_ext/'
T = 16                       # art px per tile
BORDER_X, BORDER_Y = 14, 8   # main.gd: the farm's layout sits this many tiles inside the map
S = 3                        # SCALE
DOOR_X = 11                  # the C tile (11, 8)
FOOT_Y = 9 * T               # the cliff stands on the bottom edge of row 8
# Day and night modulates: the FARM-001R hillside's (f2f2f0 / c2c2c0) and its mouth's (ffffff / cccccc), kept
# opaque at night (the old hillside faded to 80% alpha at night, which let the ground show through rock).
M_ROCK, MN_ROCK = 'f2f2f0ff', 'c2c2c0ff'
M_MOUTH, MN_MOUTH = 'ffffffff', 'ccccccff'
# The throat: the opening's core steps down to these by depth (px in from the core's edge). CAVE_TINT is 050508.
THROAT = [(3, (14, 12, 16)), (6, (5, 5, 8))]
SHADOW = (20, 16, 18)        # the threshold decal's core colour, the farm's darkest outline step


def load(rel):
    im = np.array(Image.open(os.path.join(RAW, rel)).convert('RGBA'))
    im[..., 3] = np.where(im[..., 3] >= 128, 255, 0)     # binary alpha, no partial transparency
    im[im[..., 3] == 0] = 0
    return im


def save(name, im):
    assert set(np.unique(im[..., 3])) <= {0, 255}, name
    Image.fromarray(im.astype(np.uint8), 'RGBA').save(os.path.join(OUT, name))
    return name


def crop(im):
    ys, xs = np.nonzero(im[..., 3])
    return im[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def luma(im):
    return 0.3 * im[..., 0] + 0.55 * im[..., 1] + 0.15 * im[..., 2]


def erode(mask, n=1):
    for _ in range(n):
        m = mask.copy()
        m[1:, :] &= mask[:-1, :]; m[:-1, :] &= mask[1:, :]
        m[:, 1:] &= mask[:, :-1]; m[:, :-1] &= mask[:, 1:]
        mask = m
    return mask


def dilate(mask, n=1):
    for _ in range(n):
        m = mask.copy()
        m[1:, :] |= mask[:-1, :]; m[:-1, :] |= mask[1:, :]
        m[:, 1:] |= mask[:, :-1]; m[:, :-1] |= mask[:, 1:]
        mask = m
    return mask


def component(mask, seed):
    """The 4-connected region of mask containing seed (y, x)."""
    out = np.zeros_like(mask)
    stack = [seed]
    while stack:
        y, x = stack.pop()
        if 0 <= y < mask.shape[0] and 0 <= x < mask.shape[1] and mask[y, x] and not out[y, x]:
            out[y, x] = True
            stack += [(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)]
    return out


def depth(mask):
    """Steps from the outside of mask, 1 on its edge."""
    d = np.zeros(mask.shape, int)
    m = mask.copy(); k = 0
    while m.any():
        k += 1
        d[m] = k
        m = erode(m)
    return d


pieces = []


def place(name, im, ax, ay, base, m=M_ROCK, mn=MN_ROCK, flat=False, fh=False):
    """ax, ay: the art's top-left in layout art px. base: its sort row (tiles); flat pieces lie on the ground."""
    save(name, im)
    ax, ay, base = int(ax), int(ay), float(base)
    pieces.append({'t': RES + name, 'x': (BORDER_X * T + ax) * S, 'y': (BORDER_Y * T + ay) * S, 's': S,
                   'fh': fh, 'm': m, 'mn': mn, 'z': 0 if flat else -1, 'b': -1000.0 if flat else round(base, 3),
                   'tx': int((ax + im.shape[1] / 2) // T), 'ty': int((ay + im.shape[0]) // T), 'forest': False,
                   'cave_ext': True, 'w': int(im.shape[1]), 'h': int(im.shape[0])})


def prop(name, rel, cx, foot, base=None, flat=False, fh=False):
    im = crop(load(rel))
    if fh:
        im = im[:, ::-1]
    place(name, im, cx - im.shape[1] // 2, foot - im.shape[0], foot / T if base is None else base, flat=flat)


def threshold(w=50, h=16, seed=7):
    """The doorway's shadow on row 9 (B2): a ragged half-ellipse in three solid tones, darkest at the mouth and
    easing to a dark soil brown at its edge. Each band's edge is wobbled by smooth noise so it reads as worn earth
    sliding into the dark, not a pattern; no dither, no partial alpha, no lone pixels."""
    rng = np.random.default_rng(seed)
    def wobble(n, amp):                      # smooth 1-D noise along x, one value per column
        k = rng.normal(0, 1, n // 6 + 3)
        xs = np.arange(n) / 6.0
        return amp * np.interp(xs, np.arange(len(k)), k)
    edge = [wobble(w, a) for a in (0.10, 0.08, 0.07)]
    tones = [SHADOW, (36, 28, 33), (50, 38, 30)]   # the threshold, then two palette darks (241c21, 322619)
    limits = [0.30, 0.62, 1.0]
    im = np.zeros((h, w, 4), np.uint8)
    for y in range(h):
        for x in range(w):
            r = ((x + 0.5 - w / 2) / (w / 2)) ** 2 + ((y + 0.5) / h) ** 2
            for band in range(3):
                if r < limits[band] + edge[band][x] * (1.0 + y / h):
                    im[y, x] = (*tones[band], 255)
                    break
    a = im[..., 3] > 0                       # drop lone pixels on the outer edge
    n = np.zeros(a.shape, int)
    n[1:] += a[:-1]; n[:-1] += a[1:]; n[:, 1:] += a[:, :-1]; n[:, :-1] += a[:, 1:]
    im[a & (n <= 1)] = 0
    return im


def main():
    os.makedirs(OUT, exist_ok=True)
    for f in os.listdir(OUT):
        if f.endswith('.png'):
            os.remove(os.path.join(OUT, f))
    # --- the cliff with its mouth (cliff_v1, mouth_a inpainted into x 56-152, y 16-96, then the B2 rock and roots) ---
    full = load(os.path.join(RAW_B2, 'cliff_b2.png'))
    H, W = full.shape[:2]
    MX0, MX1, MY0 = 56, 152, 16
    L = luma(full)
    dark = (L < 20) & (full[..., 3] == 255)
    core = dilate(erode(dark, 2), 2) & dark                      # drop thin outlines, keep the opening's body
    core = component(core, (72, 107))
    ys, xs = np.nonzero(core)
    cx = int(round(xs.mean()))
    ax = DOOR_X * T + T // 2 - cx                                # centre the core on the doorway column
    ay = FOOT_Y - H
    # The throat: deeper inside the core, darker, down to the cave's own black.
    d = depth(core)
    for k, col in THROAT:
        full[(d >= k) & core, :3] = col
    # The lip: the brow and the roots and vines hanging over the opening, its own layer in front of the mouth.
    oy0 = int(ys.min())
    lip = np.zeros_like(full)
    region = np.zeros(full.shape[:2], bool)
    region[MY0:oy0 + 6, xs.min() - 8:xs.max() + 9] = True
    lipmask = region & (full[..., 3] == 255) & (L >= 32)
    lip[lipmask] = full[lipmask]
    body = full.copy(); body[lipmask] = 0
    top = body.copy(); top[MY0:] = 0
    west = body.copy(); west[:MY0] = 0; west[:, MX0:] = 0
    mouth = body.copy(); mouth[:MY0] = 0; mouth[:, :MX0] = 0; mouth[:, MX1:] = 0
    east = body.copy(); east[:MY0] = 0; east[:, :MX1] = 0

    def put(name, im, base, m=M_ROCK, mn=MN_ROCK):
        ys2, xs2 = np.nonzero(im[..., 3])
        place(name, im[ys2.min():ys2.max() + 1, xs2.min():xs2.max() + 1], ax + xs2.min(), ay + ys2.min(), base, m, mn)
    put('cliff_top.png', top, 4.0)          # the brim on row 3: behind a farmer walking the ridge path
    put('cliff_w.png', west, 8.97)
    put('cliff_e.png', east, 8.98)
    put('mouth.png', mouth, 8.99, M_MOUTH, MN_MOUTH)
    put('lip.png', lip, 9.0, M_MOUTH, MN_MOUTH)
    # --- the foot: flat leaf-and-moss strips (their top rows are the generator's straight black edge) ---
    for i, (rel, x0, y0, fh) in enumerate([('foot/04.png', 92, 139, False), ('foot/09.png', 214, 138, False),
                                          ('foot/21.png', 268, 132, True)]):
        im = crop(load(rel))[3:]
        if fh:
            im = im[:, ::-1]
        place('foot_%d.png' % i, im, x0, y0, 0, flat=True)
    place('threshold.png', threshold(), DOOR_X * T + T // 2 - 25, FOOT_Y, 0, flat=True)
    # --- flat litter and pebbles ---
    prop('litter_0.png', 'under/32.png', 200, 168, flat=True)
    prop('litter_1.png', 'under/37.png', 236, 170, flat=True)
    prop('litter_2.png', 'under/34.png', 86, 172, flat=True)
    prop('pebbles_0.png', 'rubble/41.png', 206, 158, flat=True)
    prop('pebbles_1.png', 'rubble/47.png', 152, 176, flat=True)
    # --- rubble, boulders and undergrowth on the blocking rock of row 9 (columns 6-10) and the east end ---
    prop('boulder_0.png', 'rubble/00.png', 104, 158)
    prop('rubble_0.png', 'rubble/18.png', 126, 159)
    prop('boulder_1.png', 'rubble/10.png', 146, 156)
    prop('bramble_0.png', 'under/17.png', 162, 157)
    prop('fern_0.png', 'under/07.png', 88, 156)
    prop('boulder_2.png', 'rubble/06.png', 325, 126)
    prop('boulder_3.png', 'rubble/55.png', 330, 100)
    prop('bramble_1.png', 'under/19.png', 316, 116)
    # --- low ferns along the cliff foot (one on the walkable (13, 9), sorted by its base) ---
    prop('fern_1.png', 'under/06.png', 152, 146)
    prop('fern_2.png', 'under/02.png', 218, 147)
    prop('fern_3.png', 'under/07.png', 240, 146, fh=True)
    # --- ivy on the cliff face, to break up the strata ---
    prop('ivy_0.png', 'under/25.png', 110, 96, base=9.01)
    prop('ivy_1.png', 'under/30.png', 272, 110, base=9.01)
    json.dump({'task': 'ART-OVERHAUL-001 Stage B', 'tool': 'tools/aoh_cave_ext.py',
               'core': {'x': int(ax + cx), 'y0': int(ay + ys.min()), 'y1': int(ay + ys.max())},
               'sprites': pieces}, open(os.path.join(OUT, 'pieces.json'), 'w'), indent=1)
    check()
    registry()
    print('cliff at', ax, ay, 'core x', ax + cx, 'rows', (ay + ys.min()) / T, (ay + ys.max()) / T, '-', len(pieces), 'pieces')


def check():
    """Guardrail B-4: no opaque, sorted, non-fern piece over a walkable tile south of row 8."""
    import re
    lay = open(os.path.join(ROOT, 'scripts/farm_layout.gd')).read()
    rows = re.findall(r'^\t"([^"]+)",?$', lay[lay.index('const TERRAIN'):], re.M)
    for p in pieces:
        if p['b'] < -999 or 'fern' in p['t']:
            continue
        x0, y0 = p['x'] / S - BORDER_X * T, p['y'] / S - BORDER_Y * T
        im = np.array(Image.open(os.path.join(OUT, p['t'][len(RES):])))
        ys, xs = np.nonzero(im[..., 3])
        for ty in range(9, 12):
            for tx in range(int(x0 // T), int((x0 + im.shape[1]) // T) + 1):
                if rows[ty][tx] in 'KTC':
                    continue
                sub = (ys + y0 >= ty * T) & (ys + y0 < (ty + 1) * T) & (xs + x0 >= tx * T) & (xs + x0 < (tx + 1) * T)
                assert sub.sum() <= 12, '%s covers walkable (%d, %d) with %d px' % (p['t'], tx, ty, sub.sum())


def registry():
    jobs = [json.loads(l) for l in open(os.path.join(RAW, 'jobs.jsonl')) if l.strip()]
    path = os.path.join(ROOT, 'pixellab-assets.json')
    reg = json.load(open(path)) if os.path.exists(path) else {}
    reg['_about'] = ('PixelLab assets used in production (ART-OVERHAUL-001). Each entry: the job, its PixelLab ids, '
                     'prompt, seed and settings, and the game files made from it. Sources and cleanup scripts live '
                     'under art/style_tests/ART-OVERHAUL-001/<stage>/.')
    used = {}
    for p in pieces:
        used.setdefault(p['t'], True)
    reg['ART-OVERHAUL-001/B'] = {
        'tool': 'tools/aoh_cave_ext.py', 'sources': 'art/style_tests/ART-OVERHAUL-001/B/',
        'generations': sum(j.get('cost', 0) for j in jobs), 'jobs': jobs,
        'game_files': sorted(used) + [RES + 'pieces.json']}
    jobs2 = [json.loads(l) for l in open(os.path.join(RAW_B2, 'jobs.jsonl')) if l.strip()]
    reg['ART-OVERHAUL-001/B2'] = {
        'tool': 'tools/aoh_cave_ext.py', 'sources': 'art/style_tests/ART-OVERHAUL-001/B2/',
        'note': 'Stage B corrections: irregular cliff rock, solid-tone threshold, varied roots (hand-drawn)',
        'generations': sum(j.get('cost', 0) for j in jobs2), 'jobs': jobs2,
        'game_files': [RES + 'cliff_top.png', RES + 'cliff_w.png', RES + 'cliff_e.png', RES + 'mouth.png',
                       RES + 'lip.png', RES + 'threshold.png']}
    json.dump(reg, open(path, 'w'), indent=1)


if __name__ == '__main__':
    main()
