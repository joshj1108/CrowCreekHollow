# ART-005 S3 (non-production): a light polish of the S2 ground-level fields (tools/art003_f1.py), for the wide
# homestead prototype. Zero generation. Same four 7 x 4 tile fields, same soil states, same 3 px margin (118 x 70),
# same palettes; only the drawing changes:
#   - softer furrows: each ridge row has its own slow wobble (rows are no longer parallel), the dark furrow line is
#     broken where soil has slumped into it, and the lit ridge crest shows in runs, not as a continuous stripe;
#   - low-frequency tone drift along each ridge, so the field is not one even band pattern;
#   - a more irregular rim: a wider wobble, a few bites of trodden walk into the soil and soil spilt onto the walk,
#     and corners of differing radius;
#   - the watered field gets uneven wet patches instead of one flat dark tone.
#   python tools/art003_f2.py
# Writes art/style_tests/ART-003/f2/field_<dry|wet>_<id>.png (read by tools/art003_wide.gd art=f2). f1/ is untouched.
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art003_f1 as f1  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-003", "f2")
TW, TH, M = f1.TW, f1.TH, f1.M
DRY, WET, EDGE, GRASS, PEBBLE, STRAW = f1.DRY, f1.WET, f1.EDGE, f1.GRASS, f1.PEBBLE, f1.STRAW


def smooth_noise(rng, n, step, amp):
    """A slow 1-D wobble: random values every `step` px, linearly interpolated."""
    k = n // step + 2
    v = rng.uniform(-amp, amp, k)
    x = np.arange(n) / step
    return np.interp(x, np.arange(k), v)


def field(seed, wet, empty_rows=()):
    rng = np.random.default_rng(seed)
    pal = WET if wet else DRY
    w, h = TW * 16, TH * 16
    Wd, Hd = w + 2 * M, h + 2 * M
    img = np.zeros((Hd, Wd, 4), np.uint8)
    # outline: a wider wobble than F1, plus a few bites (walk worn into the soil)
    def wob(n):
        v = smooth_noise(rng, n, int(rng.integers(6, 11)), 2.6)
        for _ in range(int(rng.integers(1, 3))):
            c, ln = int(rng.integers(8, n - 8)), int(rng.integers(4, 9))
            v[c - ln // 2:c + ln // 2] += rng.uniform(1.5, 3.0)     # a bite inward
        return np.clip(np.round(v), -3, 3).astype(int)
    top, bot, lef, rig = wob(Wd), -wob(Wd), wob(Hd), -wob(Hd)
    rad = [int(rng.integers(2, 6)) for _ in range(4)]
    inside = np.zeros((Hd, Wd), bool)
    for y in range(Hd):
        for x in range(Wd):
            if y < M + top[x] or y >= M + h + bot[x] or x < M + lef[y] or x >= M + w + rig[y]:
                continue
            fx, fy = x - M, y - M
            for k, (cx, cy) in enumerate(((fx, fy), (w - 1 - fx, fy), (fx, h - 1 - fy), (w - 1 - fx, h - 1 - fy))):
                r = rad[k]
                if cx < r and cy < r and (r - cx) ** 2 + (r - cy) ** 2 > r * r:
                    break
            else:
                inside[y, x] = True
    # each ridge row wobbles on its own; tone drifts slowly along it
    roww = [np.round(smooth_noise(rng, Wd, int(rng.integers(10, 20)), 1.3)).astype(int) for _ in range(TH + 2)]
    drift = [smooth_noise(rng, Wd, int(rng.integers(12, 26)), 0.9) for _ in range(TH + 2)]
    slump = [smooth_noise(rng, Wd, int(rng.integers(5, 10)), 1.0) for _ in range(TH + 2)]
    crest = [smooth_noise(rng, Wd, int(rng.integers(4, 9)), 1.0) for _ in range(TH + 2)]
    wetp = np.zeros((Hd, Wd))
    if wet:
        yy, xx = np.mgrid[0:Hd, 0:Wd]
        for _ in range(5):
            px, py, r = rng.uniform(0, Wd), rng.uniform(0, Hd), rng.uniform(10, 24)
            wetp += np.exp(-((xx - px) ** 2 + (yy - py) ** 2) / (2 * r * r))
    for y in range(Hd):
        for x in range(Wd):
            if not inside[y, x]:
                continue
            row0 = (y - M) // 16 if y >= M else 0
            row0 = max(0, min(TH - 1, row0))
            fy = y - M + roww[row0 + 1][x]
            ry = fy % 16 if 0 <= fy < h else (0 if fy < 0 else 15)
            row = fy // 16 if 0 <= fy < h else -1
            ri = max(0, min(TH + 1, row + 1))
            k = f1.ridge_index(ry, x - M, w)
            if ry == 0 and slump[ri][x] > 0.35:
                k = 2                       # soil slumped into the furrow
            if ry == 2 and crest[ri][x] < -0.1:
                k = 4                       # the crest highlight in runs, not a stripe
            if ry == 1 and slump[ri][x] > 0.6:
                k = 3
            if 3 <= ry <= 13:
                k += int(np.round(drift[ri][x] * (0.6 if ry > 2 else 0)))
            if row in empty_rows and 3 <= ry <= 12:
                k = min(k, 4)
            p = pal
            if wet and wetp[y, x] < 0.45:
                p = DRY if wetp[y, x] < 0.2 else [((a.astype(int) + b.astype(int)) // 2).astype(np.uint8) for a, b in zip(DRY, WET)]
            img[y, x, :3] = p[max(0, min(7, k))]
            img[y, x, 3] = 255
    # clods, pebbles, straw, furrow weeds (as F1, slightly fewer clods)
    for _ in range(int(w * h / 70)):
        x, y = int(rng.integers(M + 2, M + w - 2)), int(rng.integers(M, M + h - 1))
        if inside[y, x] and inside[y + 1, x] and 4 <= (y - M) % 16 <= 11:
            img[y, x, :3] = pal[6]
            img[y + 1, x, :3] = pal[2]
    for _ in range(int(rng.integers(5, 9))):
        x, y = int(rng.integers(M + 2, M + w - 3)), int(rng.integers(M + 1, M + h - 2))
        if inside[y, x] and inside[y, x + 1]:
            img[y, x, :3] = PEBBLE[2]
            img[y, x + 1, :3] = PEBBLE[1]
            img[y + 1, x:x + 2, :3] = PEBBLE[0]
    for _ in range(int(rng.integers(3, 6))):
        x, y = int(rng.integers(M + 2, M + w - 5)), int(rng.integers(M + 1, M + h - 1))
        if inside[y, x:x + 3].all():
            img[y, x:x + 3, :3] = STRAW[int(rng.integers(0, 2))]
    for _ in range(int(rng.integers(4, 8))):
        x = int(rng.integers(M + 3, M + w - 3))
        y = M + 16 * int(rng.integers(1, TH)) + int(rng.integers(0, 2))
        if inside[y, x]:
            img[y, x, :3] = GRASS[2]
            img[y - 1, x, :3] = GRASS[3]
    # the rim: compacted soil in broken runs, the field's lip, soil spilt onto the walk, grass tufts at places
    rim = np.zeros_like(inside)
    rim[1:] |= inside[:-1] & ~inside[1:]
    rim[:-1] |= inside[1:] & ~inside[:-1]
    rim[:, 1:] |= inside[:, :-1] & ~inside[:, 1:]
    rim[:, :-1] |= inside[:, 1:] & ~inside[:, :-1]
    run = smooth_noise(rng, Wd + Hd, 5, 1.0)
    for y, x in zip(*np.nonzero(rim)):
        if run[x + y] > -0.2:
            img[y, x, :3] = EDGE[int(rng.integers(0, 3))]
            img[y, x, 3] = 255 if rng.random() < 0.7 else 0
    lip = inside.copy()
    lip[1:-1, 1:-1] = inside[1:-1, 1:-1] & ~(inside[:-2, 1:-1] & inside[2:, 1:-1] & inside[1:-1, :-2] & inside[1:-1, 2:])
    for y, x in zip(*np.nonzero(lip)):
        img[y, x, :3] = f1.blend_rim(img[y, x, :3])
    out = ~inside & ~rim
    ys, xs = np.nonzero(out)
    for _ in range(int(rng.integers(10, 18))):       # spilt clods on the walk, close to the field
        i = int(rng.integers(0, len(ys)))
        y, x = ys[i], xs[i]
        near = inside[max(0, y - 2):y + 3, max(0, x - 2):x + 3].any()
        if near:
            img[y, x, :3] = EDGE[int(rng.integers(0, 2))]
            img[y, x, 3] = 255
    for _ in range(int(rng.integers(6, 11))):
        ys2, xs2 = np.nonzero(rim)
        i = int(rng.integers(0, len(ys2)))
        cy, cx = ys2[i], xs2[i]
        for _ in range(int(rng.integers(3, 7))):
            x = cx + int(rng.integers(-2, 3))
            for j in range(int(rng.integers(1, 4))):
                y = cy - j
                if 0 <= y < Hd and 0 <= x < Wd:
                    img[y, x, :3] = GRASS[min(3, j + 1)]
                    img[y, x, 3] = 255
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    specs = {"field_dry_a": (131, False, ()), "field_dry_b": (137, False, ()), "field_wet_c": (141, True, ()),
             "field_dry_d": (143, False, (2, 3))}
    for name, (seed, wet, empty) in specs.items():
        Image.fromarray(field(seed, wet, empty), "RGBA").save(os.path.join(OUT, name + ".png"))
        print(name)


if __name__ == "__main__":
    main()
