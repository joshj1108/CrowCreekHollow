"""ART-OVERHAUL-002 E5: seasonal variants of the world's deciduous art, chosen by the season at run time.

The farm and trek foliage was drawn for autumn (the game starts on October 1st), so autumn is the original art and
this script makes the other three seasons from it:
  - Foliage recolour (spring, summer): every warm, saturated leaf pixel (red, orange, amber, yellow; bark and wood are
    duller and are left alone) is mapped by its brightness onto a season ramp of muted greens. Spring is lighter and
    fresher, with a scatter of pale blossom on the orchard trees; summer is a fuller, deeper green. The ramps sit
    between the farm's firs and its meadow grass, so the trees stay in the approved palette.
  - Winter: the deciduous trees are bare. The great oak, the farm maple, the big trek maple, the orchard pears and the
    trek maples and apples are PixelLab edits of the autumn sprites (raw/ under art/style_tests/ART-OVERHAUL-002/E5);
    the orchard apples share the bare pears (the same small orchard tree). Stray near-white specks the edits left are painted bark. Other
    warm foliage (brambles, undergrowth, leaf litter) turns a dormant grey-brown.
  - Trek ground: the dual-grid grounds get the same grass shift the farm's ground shader applies
    (shaders/season_ground.gdshader; SEASON_GRASS here and in farm_scenery.gd hold the same numbers).
Outputs: art/farm/e5/<name>_<season>.png for farm sprites, art/farm/trek/e5/atlas_<season>.png and
ground_<g>_<season>.png for the treks. Alpha stays binary. Run from the repository root:
  python tools/aoh2_e5.py [preview]
"""
import colorsys, json, os, sys
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E5/raw')
OUT = os.path.join(ROOT, 'art/farm/e5')
TREK = os.path.join(ROOT, 'art/farm/trek')
SEASONS = ['Spring', 'Summer', 'Winter']

RAMPS = {
    'Spring': ['24382a', '34502f', '486a39', '61834a', '7f9a5c'],
    'Summer': ['1b2c1d', '27402a', '37552f', '4a6b38', '627f45'],
    'Winter': ['2e2722', '453b33', '5e5145', '786a5a', '8f8372'],   # dormant leaves that stay (brambles, litter)
}
BLOSSOM = ['d9c8c4', 'c9b0b0']
# HSV shift on grass (h added, s and v multiplied, then mixed toward a frost colour), the same numbers as the shader.
SEASON_GRASS = {'Spring': (0.02, 1.1, 1.06, 0.0), 'Summer': (0.0, 1.06, 1.0, 0.0),
                'Autumn': (-0.035, 0.88, 0.99, 0.0), 'Winter': (-0.02, 0.62, 0.9, 0.1)}
FROST = (0.62, 0.66, 0.70)

# Farm sprites with autumn foliage (scenery.json and the cave exterior), and what winter does to each:
# a bare edit (raw key, frame), 'apple_bare' (E3's), or None (dormant recolour).
FARM = {
    'concept/gen_833b1e3652': ('greattree_bare', 0),
    'concept/src_maple': ('maple_bare', 0),
    'concept/w4_orchard_pear_a': ('pear_bare', 0),
    'concept/w4_orchard_pear_b': ('pear_bare', 1),
    'concept/w4_orchard_apple_a': ('pear_bare', 0),   # E3's apple_bare is the decor sapling, too small here
    'concept/w4_orchard_apple_b': ('pear_bare', 1),
    'concept/src_undergrowth': None,
    'cave_ext/bramble_0': None, 'cave_ext/bramble_1': None,
    'cave_ext/ivy_0': None, 'cave_ext/ivy_1': None,
    'cave_ext/litter_0': None, 'cave_ext/litter_1': None, 'cave_ext/litter_2': None,
}
# Trek atlas kinds with foliage; maples and apples go bare in winter (frames of raw/trek_bare, in this order).
TREK_BARE = ['maple', 'apple']
TREK_RECOLOUR = ['maple', 'apple', 'u_forest', 'u_pasture', 'u_hollow', 'u_small', 'd_forest', 'd_pasture', 'd_hollow', 'reeds']
GROUNDS = ['forest', 'pasture', 'hollow']


def hexc(h):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def hsv_arrays(a):
    rgb = a[..., :3].astype(float) / 255
    mx, mn = rgb.max(-1), rgb.min(-1)
    d = mx - mn
    s = np.where(mx > 0, d / np.maximum(mx, 1e-6), 0)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    h = np.zeros_like(mx)
    dd = np.maximum(d, 1e-6)
    h = np.where(mx == r, ((g - b) / dd) % 6, h)
    h = np.where(mx == g, (b - r) / dd + 2, h)
    h = np.where(mx == b, (r - g) / dd + 4, h)
    h = np.where(d == 0, 0, h / 6.0)
    return h, s, mx


def leaf_mask(a, orange_v=0.62):
    """Warm, saturated leaf pixels: hue red to yellow, saturated and not too dark (bark and wood are duller)."""
    h, s, v = hsv_arrays(a)
    # Bark shares the orange hues but is darker, so each band needs its own brightness: deep reds (maple leaves) are
    # dark, oranges and yellows are bright.
    red = ((h < 0.045) | (h > 0.95)) & (s > 0.55) & (v > 0.35)
    orange = (h >= 0.045) & (h < 0.12) & (s > 0.5) & (v > orange_v)
    yellow = (h >= 0.12) & (h < 0.17) & (s > 0.45) & (v > 0.5)
    m = (a[..., 3] > 0) & (red | orange | yellow)
    # Thin warm streaks are bark highlights, not leaves: keep a pixel only with at least three leaf neighbours.
    p = np.pad(m, 1)
    n = sum(p[1 + dy:p.shape[0] - 1 + dy, 1 + dx:p.shape[1] - 1 + dx].astype(int)
            for dy in (-1, 0, 1) for dx in (-1, 0, 1) if dy or dx)
    return m & (n >= 3), v


def recolour(a, season, blossom=False, seed=0, orange_v=0.62):
    out = a.copy()
    m, v = leaf_mask(a, orange_v)
    if not m.any():
        return out
    ramp = [hexc(c) for c in RAMPS[season]]
    vals = v[m]
    lo, hi = np.percentile(vals, 3), np.percentile(vals, 97)
    t = np.clip((v - lo) / max(hi - lo, 1e-3), 0, 0.999)
    idx = (t * len(ramp)).astype(int)
    for y, x in zip(*np.nonzero(m)):
        out[y, x, :3] = ramp[idx[y, x]]
        if blossom and idx[y, x] >= 3 and (x * 7 + y * 13 + seed) % 11 == 0:
            out[y, x, :3] = hexc(BLOSSOM[(x + y) % 2])
    return out


def clean_specks(a):
    """Paint near-white, unsaturated specks (edit artefacts) with the mean of their non-speck neighbours."""
    out = a.copy()
    rgb = a[..., :3].astype(int)
    mx, mn = rgb.max(-1), rgb.min(-1)
    bad = (a[..., 3] > 0) & (mx > 190) & (mx - mn < 45)
    for y, x in zip(*np.nonzero(bad)):
        nb = [a[j, i, :3] for j in range(y - 1, y + 2) for i in range(x - 1, x + 2)
              if 0 <= j < a.shape[0] and 0 <= i < a.shape[1] and a[j, i, 3] > 0 and not bad[j, i]]
        if nb:
            out[y, x, :3] = np.mean(nb, 0).astype(np.uint8)
        else:
            out[y, x] = 0
    return out


def binary(im):
    a = np.array(im.convert('RGBA'))
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    return a


def fit(bare, shape):
    """A bare edit seated on a canvas of the source's size, bottom-centred, never rescaled."""
    if bare.shape[:2] == tuple(shape[:2]):
        return bare
    ys, xs = np.nonzero(bare[..., 3])
    box = bare[ys.min():ys.max() + 1, xs.min():xs.max() + 1]
    c = np.zeros((shape[0], shape[1], 4), np.uint8)
    h, w = min(box.shape[0], c.shape[0]), min(box.shape[1], c.shape[1])
    ox, bx = (c.shape[1] - w) // 2, (box.shape[1] - w) // 2
    c[c.shape[0] - h:, ox:ox + w] = box[box.shape[0] - h:, bx:bx + w]
    return c


def grass_weight(h, s):
    """1 on green grass, fading toward yellow-brown and blue-green; 0 on unsaturated pixels (stone, paths)."""
    ks = np.clip((s - 0.12) / 0.1, 0, 1)
    w = np.where((h >= 0.18) & (h <= 0.42), 1.0, 0.0)
    w = np.where((h >= 0.14) & (h < 0.18), (h - 0.14) / 0.04, w)
    w = np.where((h > 0.42) & (h <= 0.48), (0.48 - h) / 0.06, w)
    return w * ks


def grass_shift(a, season):
    dh, ks, kv, frost = SEASON_GRASS[season]
    out = a.copy()
    h, s, v = hsv_arrays(a)
    w = grass_weight(h, s) * (a[..., 3] > 0)
    for y, x in zip(*np.nonzero(w > 0)):
        k = w[y, x]
        c = np.array(colorsys.hsv_to_rgb((h[y, x] + dh * k) % 1.0, min(1, s[y, x] * (1 + (ks - 1) * k)),
                                         min(1, v[y, x] * (1 + (kv - 1) * k))))
        c = c + (np.array(FROST) - c) * frost * k
        out[y, x, :3] = np.clip(c * 255 + 0.5, 0, 255).astype(np.uint8)
    return out


def raw(key, i):
    return binary(Image.open(os.path.join(RAW, key, '%02d.png' % i)))


def farm():
    os.makedirs(OUT, exist_ok=True)
    made = {}
    for name, winter in FARM.items():
        src = binary(Image.open(os.path.join(ROOT, 'art/farm', name + '.png')))
        base = name.split('/')[-1]
        orchard = base.startswith('w4_orchard')
        made[name] = [src]
        for season in SEASONS:
            if season == 'Winter' and winter == 'apple_bare':
                a = fit(binary(Image.open(os.path.join(ROOT, 'art/farm/e3/apple_bare.png'))), src.shape)
            elif season == 'Winter' and winter is not None:
                a = fit(clean_specks(raw(*winter)), src.shape)
            else:
                a = recolour(src, season, blossom=orchard and season == 'Spring', seed=len(base))
            Image.fromarray(a).save(os.path.join(OUT, '%s_%s.png' % (base, season.lower())))
            made[name].append(a)
    return made


def trek():
    out = os.path.join(TREK, 'e5')
    os.makedirs(out, exist_ok=True)
    meta = json.load(open(os.path.join(TREK, 'trek.json')))
    atlas = binary(Image.open(os.path.join(TREK, 'atlas.png')))
    bare = [clean_specks(raw('trek_bare', i)) for i in range(13)]
    # The first four maple frames came back white-crowned (frost-like), so the eight maples reuse frames 4-7 twice.
    bares = {'maple': [bare[4 + (k % 4)] for k in range(8)], 'apple': bare[8:13]}
    bx, by, bw, bh = meta['pieces'][meta['kinds']['big'][1]]['r']
    big_bare = fit(clean_specks(raw('maple_bare', 1)), (bh, bw))
    for season in SEASONS:
        a = atlas.copy()
        for kind in TREK_RECOLOUR:
            for k, i in enumerate(meta['kinds'].get(kind, [])):
                x, y, w, h = meta['pieces'][i]['r']
                if season == 'Winter' and kind in TREK_BARE:
                    b = bares[kind][k]   # the edit canvas was 32x36 with the piece bottom-centred
                    ox = (32 - w) // 2
                    a[y:y + h, x:x + w] = b[36 - h:36, ox:ox + w]
                else:
                    # The trek's small maples are a duller orange than the farm's art: a lower brightness floor.
                    a[y:y + h, x:x + w] = recolour(atlas[y:y + h, x:x + w], season,
                                                   blossom=kind == 'apple' and season == 'Spring', seed=i, orange_v=0.4)
        a[by:by + bh, bx:bx + bw] = big_bare if season == 'Winter' else recolour(atlas[by:by + bh, bx:bx + bw], season)
        Image.fromarray(a).save(os.path.join(out, 'atlas_%s.png' % season.lower()))
    for season in SEASONS + ['Autumn']:
        for g in GROUNDS:
            src = os.path.join(TREK, 'ground_%s_df.png' % g)
            ga = binary(Image.open(src))
            Image.fromarray(grass_shift(ga, season)).save(os.path.join(out, 'ground_%s_%s.png' % (g, season.lower())))


def sheet(made):
    rows = []
    for ims in made.values():
        w = sum(i.shape[1] + 4 for i in ims)
        h = max(i.shape[0] for i in ims)
        r = Image.new('RGBA', (w, h), (96, 104, 92, 255))
        x = 0
        for i in ims:
            r.alpha_composite(Image.fromarray(i), (x, h - i.shape[0]))
            x += i.shape[1] + 4
        rows.append(r)
    s = Image.new('RGBA', (max(r.width for r in rows), sum(r.height + 4 for r in rows)), (96, 104, 92, 255))
    y = 0
    for r in rows:
        s.alpha_composite(r, (0, y))
        y += r.height + 4
    return s


if __name__ == '__main__':
    made = farm()
    trek()
    if 'preview' in sys.argv:
        d = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E5/')
        s = sheet(made)
        s.resize((s.width * 2, s.height * 2), Image.NEAREST).save(d + 'preview_farm.png')
        t = Image.new('RGBA', (512, 4 * 200), (96, 104, 92, 255))
        t.alpha_composite(Image.open(os.path.join(TREK, 'atlas.png')).convert('RGBA').crop((0, 0, 512, 200)), (0, 0))
        for k, season in enumerate(SEASONS):
            t.alpha_composite(Image.open(os.path.join(TREK, 'e5/atlas_%s.png' % season.lower())).crop((0, 0, 512, 200)), (0, 200 * (k + 1)))
        t.resize((1024, 1600), Image.NEAREST).save(d + 'preview_trek.png')
