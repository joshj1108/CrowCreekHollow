"""FARMHOUSE-INTERIOR-001: the PixelLab props, cleaned for the game, plus the hearth's four stages and the clock
without its pendulum (the game swings it).

Reads the picks under art/style_tests/FARMHOUSE-INTERIOR-001/raw/<key>/NN.png (create_image_pro, style image
raw/int_style.png; job ids in raw/jobs.txt and pixellab-assets.json) and writes art/farm/fi/:
  <prop>.png        the pick, alpha made binary, stray specks (components under 6 px) dropped, cropped to its box
  hearth_0..3.png   48x64 fieldstone fireplace: 0 soot-black, cracked, a stone fallen and the mantel split;
                    1 soot washed back, the mantel a rough new beam; 2 clean; 3 clean, the mantel oiled darker
  clock_case.png    art/farm/e4/clock.png with the brass pendulum painted out (rod and bob)
  props.json        sizes, the hearth's firebox and the candle wicks (art pixels from each sprite's top-left)
Run from the repository root:  python tools/fi001_props.py
"""
import json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/FARMHOUSE-INTERIOR-001/raw')
OUT = os.path.join(ROOT, 'art/farm/fi')
PICKS = {'bedside': 0, 'chest': 4, 'shelf': 8, 'logbasket': 5, 'barrel': 0, 'sidetable': 1, 'debris': 1,
         'brokenchair': 3, 'washtub': 3, 'herbs': 0, 'crates': 0, 'wardrobe': 0}


def load(key, idx):
    return np.array(Image.open(os.path.join(RAW, key, '%02d.png' % idx)).convert('RGBA'))


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
    # keep the sprite: components at least `keep` of the largest (drops stray lines and specks)
    big = max(len(c) for c in comps)
    for comp in comps:
        if len(comp) < big * keep:
            for cy, cx in comp:
                a[cy, cx] = 0
    ys, xs = np.nonzero(a[..., 3])
    return a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def wick(a):
    """The candle's top: the highest pale (cream/white) pixel in the sprite."""
    best = None
    for y in range(a.shape[0]):
        for x in range(a.shape[1]):
            r, g, b, al = a[y, x]
            if al and int(r) + int(g) + int(b) > 560 and abs(int(r) - int(b)) < 70:
                return [x, y]
    return best


def firebox(a):
    """The dark mouth of the hearth: the box of near-black pixels in the lower half, ignoring the outline."""
    h, w = a.shape[:2]
    lum = a[..., :3].astype(int).sum(2)
    mask = (a[..., 3] > 0) & (lum < 110)
    mask[: h // 2] = False
    rows = [y for y in range(h) if mask[y].sum() >= 6]
    cols = [x for x in range(w) if mask[:, x].sum() >= 4]
    return [min(cols), min(rows), max(cols) - min(cols) + 1, max(rows) - min(rows) + 1]


def hearths(base):
    """Four stages from the one pick. Changes are painted onto copies, seeded, so they reproduce."""
    out = []
    r = np.random.default_rng(21)
    h, w = base.shape[:2]
    lum = base[..., :3].astype(int).sum(2)
    wood = (base[..., 0].astype(int) - base[..., 2].astype(int) > 25) & (base[..., 3] > 0)   # the mantel
    wood_rows = np.nonzero(wood.any(1))[0]
    m0, m1 = (wood_rows.min(), wood_rows.max()) if len(wood_rows) else (h // 2, h // 2 + 3)
    stone = (base[..., 3] > 0) & ~wood & (lum > 110)
    for stage in range(4):
        a = base.copy().astype(int)
        if stage <= 1:
            # soot: darken the stone, most over the firebox and up the breast
            k = 0.48 if stage == 0 else 0.74
            for y in range(h):
                for x in range(w):
                    if stone[y, x]:
                        near = max(0.0, 1.0 - abs(x - w / 2) / (w / 2))
                        f = k + (1 - k) * (1 - near) * 0.6
                        a[y, x, :3] = (a[y, x, :3] * f).astype(int)
            # the mantel: grey and split (0), or a rough unstained new beam (1)
            for y in range(m0, m1 + 1):
                for x in range(w):
                    if wood[y, x]:
                        if stage == 0:
                            g = int(a[y, x, :3].mean() * 0.8)
                            a[y, x, :3] = [g + 8, g + 2, g - 4]
                        else:
                            a[y, x, :3] = np.clip(a[y, x, :3] * [1.18, 1.12, 1.0] + 10, 0, 255)
            if stage == 0:
                mid = int(w * 0.58)
                for y in range(m0, m1 + 1):            # the split
                    a[y, mid] = [20, 14, 10, 255]
                    a[y, mid + 1] = [36, 26, 20, 255]
                for y in range(m0 + 2, h - 6):         # a crack down the stone
                    x = int(w * 0.30) + (y // 3) % 2
                    if a[y, x, 3]:
                        a[y, x, :3] = [18, 16, 20]
                # a fallen stone: a gap at the breast's edge
                ys, xs = np.nonzero(stone[: m0])
                if len(xs):
                    gx, gy = xs.max() - 4, ys.min() + 6
                    a[gy:gy + 3, gx:gx + 4, :3] = [22, 18, 22]
        if stage == 3:
            for y in range(m0, m1 + 1):
                for x in range(w):
                    if wood[y, x]:
                        a[y, x, :3] = np.clip(a[y, x, :3] * [0.92, 0.86, 0.82], 0, 255)
        out.append(np.clip(a, 0, 255).astype(np.uint8))
    return out, int(m0)


def clock_case():
    a = np.array(Image.open(os.path.join(ROOT, 'art/farm/e4/clock.png')).convert('RGBA'))
    h, w = a.shape[:2]
    brass = (a[..., 0].astype(int) > 150) & (a[..., 1].astype(int) > 110) & (a[..., 2].astype(int) < 110) & (a[..., 3] > 0)
    brass[: h // 2] = False                     # only the pendulum, not the face's brass
    ys, xs = np.nonzero(brass)
    # the rod is a thin line above the bob: take it as brass-ish thin pixels in the same column band
    rod = (a[..., 0].astype(int) > 120) & (a[..., 2].astype(int) < 120) & (a[..., 3] > 0)
    rod[: h // 2 - 4] = False
    cx = int(round(xs.mean()))
    case = a.copy()
    fill = None
    for y in range(h // 2 - 4, h):
        for x in range(max(0, cx - 3), min(w, cx + 4)):
            if rod[y, x] or brass[y, x]:
                if fill is None:
                    # the case's dark inside, from the pixel two to the left
                    fill = a[y, max(0, cx - 3)].copy()
                case[y, x] = fill
    rys = np.nonzero(rod[:, cx - 1:cx + 2].any(1))[0]
    pivot = [cx, int(rys.min())]
    bob = [int(round(xs.mean())), int(round(ys.mean()))]
    return case, pivot, bob


def main():
    os.makedirs(OUT, exist_ok=True)
    info = {}
    for key, idx in PICKS.items():
        a = clean(load(key, idx))
        Image.fromarray(a).save(os.path.join(OUT, key + '.png'))
        info[key] = {'size': [int(a.shape[1]), int(a.shape[0])], 'pick': '%s/%02d' % (key, idx)}
        if key == 'bedside':
            info[key]['wick'] = wick(a)
        if key == 'sidetable':
            info[key]['wick'] = [9, 1]   # the pick's taper is orange-cream, so it is set by eye
    base = clean(load('fireplace', 0))
    stages, mantel = hearths(base)
    # The pick's chimney breast stops short of the ceiling: carry its stone courses up EXTEND more rows (rows
    # 1-8 repeated, without the top outline), so the stack meets the ceiling beam once it stands on its row.
    EXTEND = 7
    for s, a in enumerate(stages):
        top = a[1:1 + EXTEND]
        a = np.concatenate([top, a], 0)
        Image.fromarray(a).save(os.path.join(OUT, 'hearth_%d.png' % s))
    # The firebox's mouth, measured on the pick's luminance (x 7-26, y 33-45), moved down by the extension.
    info['hearth'] = {'size': [int(base.shape[1]), int(base.shape[0]) + EXTEND], 'pick': 'fireplace/00',
                      'firebox': [7, 33 + EXTEND, 20, 13], 'mantel_y': mantel + EXTEND}
    case, pivot, bob = clock_case()
    Image.fromarray(case).save(os.path.join(OUT, 'clock_case.png'))
    info['clock'] = {'size': [int(case.shape[1]), int(case.shape[0])], 'pivot': pivot, 'bob': bob}
    json.dump(info, open(os.path.join(OUT, 'props.json'), 'w'), indent=1)
    print(json.dumps(info))


if __name__ == '__main__':
    main()
