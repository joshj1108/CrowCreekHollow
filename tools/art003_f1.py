# ART-003 F1 (non-production): ground-level tilled fields for the wide homestead prototype, in place of the four
# raised garden beds. Zero generation: every pixel is placed by this script from a hand-picked soil ramp.
#   python tools/art003_f1.py
# Writes art/style_tests/ART-003/f1/field_<dry|wet>_<seed>.png: one flat image per 7 x 4 tile field, 16 px per tile,
# with a 3 px organic margin on each side (118 x 70). Each tile row is one planted ridge (one crop per tile, as the
# game plants), with the dark furrow between ridges, clods, pebbles and straw, and an irregular trodden edge where
# the soil meets the walk. The harness (tools/art003_wide.gd art=f1) lays these flat under the crops.
import os

import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-003", "f1")
TW, TH, M = 7, 4, 3


def hx(s):
    return np.array([int(s[i:i + 2], 16) for i in (0, 2, 4)], np.uint8)


DRY = [hx(c) for c in ("2a2018", "3a2c21", "48382a", "554433", "614e3b", "6d5944", "7a654e", "887258")]
WET = [hx(c) for c in ("1d1713", "28201a", "332820", "3d3025", "47392c", "524233", "5d4c3b", "6a5844")]
EDGE = [hx(c) for c in ("4e4234", "5e5040", "6e604c")]          # trodden, compacted soil at the field's rim
GRASS = [hx(c) for c in ("2f3a22", "3e4b2a", "4e5c32", "5f6c3a")]
PEBBLE = [hx(c) for c in ("4a4640", "6a6660", "8a857a")]
STRAW = [hx("8a7650"), hx("a08a5c")]
INK = hx("1a1410")


def blend_rim(c):
    return ((c.astype(int) + EDGE[1].astype(int)) // 2).astype(np.uint8)


def ridge_index(ry, x, w):
    """Soil tone index within one 16 px tile row: furrow, lit ridge top, body, shaded south slope."""
    if ry == 0:
        k = 1
    elif ry == 1:
        k = 2
    elif ry == 2:
        k = 5
    elif ry <= 11:
        k = 4
    elif ry <= 13:
        k = 3
    else:
        k = 2
    # ridges round off toward the field's ends
    if x < 2 or x > w - 3:
        k = max(1, k - 1)
    return k


def field(seed, wet, empty_rows=()):
    rng = np.random.default_rng(seed)
    pal = WET if wet else DRY
    w, h = TW * 16, TH * 16
    W, H = w + 2 * M, h + 2 * M
    img = np.zeros((H, W, 4), np.uint8)
    # an irregular outline: each side wobbles 0-3 px in and out of the tile edge, with rounded corners
    def wob(n):
        v = np.cumsum(rng.integers(-1, 2, n))
        return np.clip(v - v.mean(), -2, 2).round().astype(int)
    top, bot, lef, rig = wob(W), wob(W), wob(H), wob(H)
    inside = np.zeros((H, W), bool)
    for y in range(H):
        for x in range(W):
            if y < M + top[x] or y >= M + h + bot[x] or x < M + lef[y] or x >= M + w + rig[y]:
                continue
            cx = min(x - M, w - 1 - (x - M))
            cy = min(y - M, h - 1 - (y - M))
            if cx < 3 and cy < 3 and (3 - cx) ** 2 + (3 - cy) ** 2 > 10:
                continue
            inside[y, x] = True
    shift = np.zeros(W, int)
    x = 0
    while x < W:
        n = int(rng.integers(5, 16))
        shift[x:x + n] = int(rng.choice([-1, 0, 0, 1]))
        x += n
    for y in range(H):
        for x in range(W):
            if not inside[y, x]:
                continue
            fy, fx = y - M + shift[x], x - M
            ry = fy % 16 if 0 <= fy < h else (0 if fy < 0 else 15)
            k = ridge_index(ry, fx, w)
            row = fy // 16 if 0 <= fy < h else -1
            if row in empty_rows and 3 <= ry <= 12:
                k = min(k, 4)          # an unplanted ridge: lower and flatter
            img[y, x, :3] = pal[max(0, min(7, k))]
            img[y, x, 3] = 255
    # clods on the ridges: a lit pixel with its shadow below
    for _ in range(int(w * h / 55)):
        x, y = int(rng.integers(M + 2, M + w - 2)), int(rng.integers(M, M + h - 1))
        ry = (y - M) % 16
        if 4 <= ry <= 11 and inside[y, x] and inside[y + 1, x]:
            img[y, x, :3] = pal[6]
            if rng.random() < 0.5 and inside[y, x + 1]:
                img[y, x + 1, :3] = pal[5]
            img[y + 1, x, :3] = pal[2]
    # pebbles, straw and a few weeds in the furrows
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
            if rng.random() < 0.5:
                img[y, x + 1, :3] = GRASS[1]
    # the rim: compacted lighter soil one pixel wide, then the field's own dark lip, then grass tufts at places
    rim = np.zeros_like(inside)
    rim[1:] |= inside[:-1] & ~inside[1:]
    rim[:-1] |= inside[1:] & ~inside[:-1]
    rim[:, 1:] |= inside[:, :-1] & ~inside[:, 1:]
    rim[:, :-1] |= inside[:, 1:] & ~inside[:, :-1]
    for y, x in zip(*np.nonzero(rim)):
        img[y, x, :3] = EDGE[int(rng.integers(0, 3))]
        img[y, x, 3] = 255 if rng.random() < 0.6 else 0
    lip = inside.copy()
    lip[1:-1, 1:-1] = inside[1:-1, 1:-1] & ~(inside[:-2, 1:-1] & inside[2:, 1:-1] & inside[1:-1, :-2] & inside[1:-1, 2:])
    for y, x in zip(*np.nonzero(lip)):
        img[y, x, :3] = blend_rim(img[y, x, :3])
    for _ in range(int(rng.integers(6, 11))):
        ys, xs = np.nonzero(rim)
        i = int(rng.integers(0, len(ys)))
        cy, cx = ys[i], xs[i]
        for _ in range(int(rng.integers(3, 7))):
            x = cx + int(rng.integers(-2, 3))
            hgt = int(rng.integers(1, 4))
            for j in range(hgt):
                y = cy - j
                if 0 <= y < H and 0 <= x < W:
                    img[y, x, :3] = GRASS[min(3, j + 1)]
                    img[y, x, 3] = 255
    return img


def main():
    os.makedirs(OUT, exist_ok=True)
    # four fields, each with its own outline and soil, and the soil states the game needs: dry tilled, watered
    specs = {"field_dry_a": (31, False, ()), "field_dry_b": (37, False, ()), "field_wet_c": (41, True, ()),
             "field_dry_d": (43, False, (2, 3))}
    for name, (seed, wet, empty) in specs.items():
        Image.fromarray(field(seed, wet, empty), "RGBA").save(os.path.join(OUT, name + ".png"))
        print(name)


if __name__ == "__main__":
    main()
