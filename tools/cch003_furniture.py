"""CCH-CONSOLIDATED-003 Phase C: the farmhouse furniture family, cleaned for the game from PixelLab picks.

Reads art/style_tests/CCH-003/C/raw/<key>/NN.png (create_image_pro, style image raw/style.png built from the
FARMHOUSE-INTERIOR-001 hearth and props; job ids in raw/jobs.txt and pixellab-assets.json) and writes art/farm/fc/:
  bed_0..3.png      the house's own bed for each repair stage, from one pick: 3 red-and-cream patchwork (the pick),
                    2 the patchwork's red faded to blue, 1 a plain brown wool blanket, 0 stained ticking with a tear,
                    the frame greyed with dust. The top 8 rows are the headboard, which stands against the wall's face.
  bed_feather.png   the bought feather bed: the frame with a deep cream eiderdown, quilted, and plumper pillows
  desk, wash, wash_fine, cooler, table, chair_front, chair_back, dresser, armchair, clock_case, painting,
  bookshelf, bedside, sidetable, rug, firewood, crock, jug, books, cushion, plate, sampler, wreath
  props.json        sizes, candle wicks and the clock's pendulum pivot and bob (art pixels from the sprite's top-left)
Trims (rows or columns taken out of repeated parts, so the pieces sit at the FARMHOUSE-INTERIOR-001 props' scale):
the desk loses three columns from each drawer bank (32 wide, two tiles), the clock 8 rows of its trunk, the dresser
one of its three drawers, the cooler two rows of its door (so it clears the hall window's sill),
the dresser and the fine washstand one middle column each (so they stand inside their tile beside a wall and
the linen press), the armchair four plain middle columns (so it stands between the log basket and the side table), the chairs a slat and some leg.
Run from the repository root:  python tools/cch003_furniture.py
"""
import json, os, sys
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/CCH-003/C/raw')
OUT = os.path.join(ROOT, 'art/farm/fc')
sys.path.insert(0, RAW)
from unwrap import unwrap  # noqa: E402

PICKS = {
    'bed': ('bed2', 0), 'desk': ('desk', 0), 'wash': ('wash', 3), 'wash_fine': ('wash_fine', 1),
    'cooler': ('cooler', 8), 'table': ('table3', 0), 'chair_front': ('chair_front2', 0),
    'chair_back': ('chair_back3', 4), 'dresser': ('dresser2', 1), 'armchair': ('armchair2', 1),
    'clock_case': ('clock', 0), 'painting': ('painting', 1), 'bookshelf': ('bookshelf2', 1),
    'bedside': ('bedside', 4), 'sidetable': ('candlestand', 12), 'rug': ('rug', 1),
    'firewood': ('firewood', 25), 'crock': ('pottery16', 1), 'jug': ('pottery16', 26), 'books': ('books16', 16),
    'cushion': ('cushion16', 12), 'plate': ('mantel16', 0), 'sampler': ('wallorn', 1), 'wreath': ('wallorn', 3),
}


def load(key, idx):
    a = unwrap(np.array(Image.open(os.path.join(RAW, key, '%02d.png' % idx)).convert('RGBA')))
    return clean(a)


def clean(a, keep=0.2):
    a = a.copy()
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    h, w = a.shape[:2]
    seen = np.zeros((h, w), bool)
    comps = []
    for y in range(h):
        for x in range(w):
            if a[y, x, 3] and not seen[y, x]:
                stack, comp = [(y, x)], []
                seen[y, x] = True
                while stack:
                    cy, cx = stack.pop()
                    comp.append((cy, cx))
                    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < h and 0 <= nx < w and a[ny, nx, 3] and not seen[ny, nx]:
                            seen[ny, nx] = True
                            stack.append((ny, nx))
                comps.append(comp)
    big = max(len(c) for c in comps)
    for comp in comps:
        if len(comp) < big * keep:
            for cy, cx in comp:
                a[cy, cx] = 0
    return crop(a)


def crop(a):
    ys, xs = np.nonzero(a[..., 3])
    return a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def cut_rows(a, rows):
    return np.delete(a, list(rows), axis=0)


def cut_cols(a, cols):
    return np.delete(a, list(cols), axis=1)


def wick(a):
    """The candle's top: the highest pale (cream/white) pixel."""
    for y in range(a.shape[0]):
        for x in range(a.shape[1]):
            r, g, b, al = (int(v) for v in a[y, x])
            if al and r + g + b > 520 and abs(r - b) < 80:
                return [x, y]
    return None


def lum(p):
    return 0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2]


def ramp(cols, t):
    """A colour along a dark-to-light ramp of hex colours, t from 0 to 1, picked (not blended) so it stays pixel art."""
    i = int(round(np.clip(t, 0, 1) * (len(cols) - 1)))
    h = cols[i]
    return np.array([int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255], np.uint8)


# --- The bed's stages ---------------------------------------------------------------------------------------

def quilt_mask(a):
    """The quilt: rows below the pillows and above the footboard, inside the frame, the red and cream cloth."""
    h, w = a.shape[:2]
    m = np.zeros((h, w), bool)
    for y in range(14, h - 6):
        for x in range(2, w - 2):
            r, g, b, al = (int(v) for v in a[y, x])
            if not al or lum((r, g, b)) < 70:
                continue
            red = r > g + 25
            cream = r > 150 and g > 130 and abs(r - g) < 45
            if red or cream:
                m[y, x] = True
    return m


def pillow_mask(a):
    h, w = a.shape[:2]
    m = np.zeros((h, w), bool)
    for y in range(6, 18):
        for x in range(2, w - 2):
            r, g, b, al = (int(v) for v in a[y, x])
            if al and abs(r - b) < 20 and abs(g - b) < 20 and r > 85:
                m[y, x] = True
    return m


def is_red(p):
    return int(p[0]) > int(p[1]) + 25


def bed_stages(base):
    q, pil = quilt_mask(base), pillow_mask(base)
    lo, hi = 70.0, 245.0
    out = {}
    out[3] = base.copy()
    # 2: the red squares faded to blue, the cream squares left
    b2 = base.copy()
    blue = ['2e3448', '3e4a64', '52607e', '6a7896', '8692ac']
    for y, x in zip(*np.nonzero(q)):
        if is_red(base[y, x]):
            b2[y, x] = ramp(blue, (lum(base[y, x]) - lo) / (200 - lo))
    out[2] = b2
    # 1: a plain wool blanket, a dark stripe across its top, the pillows a little grey
    b1 = base.copy()
    wool = ['3a2e26', '4e3e32', '62503f', '76624e', '8a7660']
    top = min(y for y, x in zip(*np.nonzero(q)))
    for y, x in zip(*np.nonzero(q)):
        t = (lum(base[y, x]) - lo) / (hi - lo)
        t = 0.35 + 0.4 * t
        if y in (top + 2, top + 3):
            t -= 0.3
        b1[y, x] = ramp(wool, t)
    for y, x in zip(*np.nonzero(pil)):
        p = base[y, x].astype(int)
        b1[y, x, :3] = np.clip(p[:3] * 0.88 + np.array([6, 2, -4]), 0, 255)
    out[1] = b1
    # 0: stained ticking with a tear, grey pillows, the frame dusty
    b0 = base.copy()
    tick = ['4a443a', '625a4c', '7a705e', '8e836e']
    for y, x in zip(*np.nonzero(q)):
        t = 0.3 + 0.55 * (lum(base[y, x]) - lo) / (hi - lo)
        if x % 4 == 1:
            t -= 0.25   # the ticking's stripe
        b0[y, x] = ramp(tick, t)
    ys, xs = np.nonzero(q)
    cy, cx = int(ys.mean()) + 2, int(xs.mean()) + 3
    for (dy, dx) in [(0, 0), (0, 1), (1, 1), (1, 2), (-1, -1), (2, 2), (0, -1)]:
        if q[cy + dy, cx + dx]:
            b0[cy + dy, cx + dx] = [28, 22, 18, 255]   # the tear, to the straw
    for (dy, dx) in [(-4, -6), (-4, -5), (-3, -6), (-3, -5), (-3, -4), (3, -7), (4, -7), (4, -6)]:
        y, x = cy + dy, cx + dx
        if 0 <= y < b0.shape[0] and 0 <= x < b0.shape[1] and q[y, x]:
            b0[y, x, :3] = (b0[y, x, :3].astype(int) * 0.72).astype(np.uint8)   # stains
    for y, x in zip(*np.nonzero(pil)):
        p = base[y, x].astype(int)
        g = int(lum(p) * 0.66)
        b0[y, x, :3] = [g + 6, g + 2, g - 4]
    frame = (b0[..., 3] > 0) & ~q & ~pil
    for y, x in zip(*np.nonzero(frame)):
        p = b0[y, x].astype(int)
        g = lum(p)
        b0[y, x, :3] = np.clip(p[:3] * 0.6 + g * 0.4 + 6, 0, 255).astype(np.uint8)
    out[0] = b0
    # the feather bed: a deep cream eiderdown, quilted in the patchwork's squares, and fuller pillows
    bf = base.copy()
    cream = ['8a7a66', 'a8987e', 'c4b498', 'd8caae', 'e8dcc4']
    for y, x in zip(*np.nonzero(q)):
        t = 0.45 + 0.5 * (lum(base[y, x]) - lo) / (hi - lo)
        if is_red(base[y, x]):
            t -= 0.12   # the stitched squares read as faint quilting
        bf[y, x] = ramp(cream, t)
    for y, x in zip(*np.nonzero(pil)):
        p = base[y, x].astype(int)
        bf[y, x, :3] = np.clip(p[:3] * 1.04 + 4, 0, 255).astype(np.uint8)
    out['feather'] = bf
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    meta = {}
    art = {k: load(*v) for k, v in PICKS.items()}
    # trims
    d = art['desk']
    art['desk'] = cut_cols(d, list(range(9, 12)) + list(range(22, 25)))
    art['clock_case'] = crop(cut_rows(art['clock_case'], range(26, 34)))
    art['dresser'] = crop(cut_rows(art['dresser'], range(18, 24)))
    art['cooler'] = crop(cut_rows(art['cooler'], range(15, 17)))
    art['dresser'] = cut_cols(art['dresser'], [8])
    art['wash_fine'] = cut_cols(art['wash_fine'], [9])
    art['armchair'] = cut_cols(art['armchair'], range(8, 12))
    art['chair_front'] = crop(cut_rows(art['chair_front'], list(range(8, 14)) + list(range(29, 34))))
    art['chair_back'] = crop(cut_rows(art['chair_back'], list(range(9, 12)) + list(range(23, 27))))
    for k, a in art.items():
        if k == 'bed':
            continue
        Image.fromarray(a).save(os.path.join(OUT, k + '.png'))
        meta[k] = {'size': [int(a.shape[1]), int(a.shape[0])], 'pick': '%s/%02d' % PICKS[k]}
    for k in ('bedside', 'sidetable', 'bookshelf'):
        meta[k]['wick'] = wick(art[k])
    for st, a in bed_stages(art['bed']).items():
        name = 'bed_%s' % st
        Image.fromarray(a).save(os.path.join(OUT, name + '.png'))
        meta[name] = {'size': [int(a.shape[1]), int(a.shape[0])], 'pick': '%s/%02d' % PICKS['bed'], 'headboard': 8}
    # the clock's glass: the dark panel in the trunk; the pendulum hangs from its top to near its bottom
    c = art['clock_case']
    dark = (c[..., 3] > 0) & (c[..., :3].astype(int).sum(2) < 150)
    h = c.shape[0]
    rows = [y for y in range(h // 3, h - 6) if dark[y, 5:-5].sum() >= 3]
    cols = [x for x in range(c.shape[1]) if dark[rows[0]:rows[-1] + 1, x].sum() >= len(rows) * 0.6]
    cx = (min(cols) + max(cols)) // 2
    meta['clock_case']['pivot'] = [cx, rows[0] + 1]
    meta['clock_case']['bob'] = [cx, rows[-1] - 2]
    meta['clock_case']['glass'] = [min(cols), rows[0], max(cols) - min(cols) + 1, rows[-1] - rows[0] + 1]
    json.dump(meta, open(os.path.join(OUT, 'props.json'), 'w'), indent=1)
    for k, v in meta.items():
        print(k, v)


if __name__ == '__main__':
    main()
