# ART-005 S3 (non-production): two zero-generation roof materials on the S2 SA log cabin, revised interlocking
# hewn-timber corners, and the four schematic restoration stages redrawn on each roof. Every pixel is placed by
# this script; no generator is called.
#   python tools/art005_s3.py
# Reads (never writes) pl/g4/sa/ (SA sprite and roof labels) and reuses tools/art005_s2.py's log wall (same seed,
# so the wall is pixel-identical to S2 apart from the corners). Writes art/style_tests/ART-005/pl/g6/<var>/32/
# house_day.png + house_night.png for the harness (tools/art005_density.gd art=g6 var=<var>):
#   logc        S2 log house (SA slate roof) with only the corners revised: interlocking hand-hewn timbers
#   shake       logc + roof A: dark hand-laid wood shakes, organic widths, restrained weathering
#   slate       logc + roof B: dark blue-grey slate, wide slates, low contrast, no repeated motif
#   sh0..sh3    the four stages on the shake roof (0 dilapidated, 1 stabilized, 2 repaired, 3 restored)
#   sl0..sl3    the same four stages on the slate roof
# Fixed in every file: canvas 384 x 320, roofline, rake, fascia, chimney, door, windows (openings and centres),
# foundation, steps and footprint. The stages change condition only; they are schematics, not candidate art.
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402
import art005_s2 as s2  # noqa: E402

W, H = m0.W, m0.H
LID = m0.LID
SA = os.path.join(m0.ROOT, "pl", "g4", "sa")
G6 = os.path.join(m0.ROOT, "pl", "g6")
hx, ramp, INK = s2.hx, s2.ramp, s2.INK

# roof labels (tools/art005_s1.py R): 1 slate field, 2 ridge cap, 8 chimney shadow, 16 far slope above the ridge
R_FIELD, R_RIDGE, R_CHSH, R_BACK = 1, 2, 8, 16
ROOF_Y0, ROOF_Y1 = 56, 148

SHAKE = ramp("15100c", "1e1611", "281e17", "32261d", "3c2e23", "47372a", "534032", "604b3b")
SHAKE_GREY = ramp("2b2824", "35312c", "403b35", "4b453e")          # silvered, weathered shakes
SHAKE_NEW = ramp("1e1610", "2a1e15", "36281b", "433222", "513d29", "5f4831", "6d543a", "7c6145")   # fresh cedar, one step warmer
SLATE = ramp("14171c", "1b1f26", "22272f", "292f38", "303741", "38404b", "414a56", "4c5662")
SLATE_NEW = ramp("161a22", "1e2430", "262d3a", "2e3644", "35404f", "3d4959", "465365", "505e72")
END = ramp("2a1c14", "4a3222", "634530", "7a5a3e", "8c6c4c", "9e7e5a", "b0916a")   # hewn end grain, dark to light


# --- roof materials -------------------------------------------------------------------------------------------

def roof_material(kind, rlab, rng):
    """Returns (rgb, unit id map, row-in-course map, base tone per unit) for the whole roof region."""
    shake = kind == "shake"
    pal = SHAKE if shake else SLATE
    courses = [9, 9, 9, 9, 9, 9, 9, 9, 10, 11]
    wmin, wmax = (8, 18) if shake else (15, 26)
    out = np.zeros((H, W, 3), np.uint8)
    unit = -np.ones((H, W), int)
    rowc = -np.ones((H, W), int)
    yy, xx = np.mgrid[0:H, 0:W]
    patch = np.zeros((H, W))
    for _ in range(4 if shake else 3):   # a few large soft weathering patches, never per-tile noise
        px, py, r = rng.uniform(20, 360), rng.uniform(60, 140), rng.uniform(28, 60)
        patch += rng.uniform(0.4, 1.0) * np.exp(-((xx - px) ** 2 + (yy - py) ** 2) / (2 * r * r))
    base, hang = {}, {}
    starts = []
    y0 = ROOF_Y0
    for ci, h in enumerate(courses):
        starts.append((y0, h))
        x = -int(rng.integers(0, wmax))
        k = 0
        while x < W:
            w = int(rng.integers(wmin, wmax + 1))
            uid = ci * 1000 + k
            if shake:
                base[uid] = int(rng.choice([3, 4, 4, 4, 4, 5]))
                hang[uid] = int(rng.choice([-1, 0, 0, 0, 0, 0, 1]))
            else:
                base[uid] = int(rng.choice([4, 4, 4, 4, 4, 3, 5]))
                hang[uid] = int(rng.choice([0, 0, 0, 1]))
            grain = np.zeros(w, int)
            gtop = np.zeros(w, int)
            if shake:   # a few long grain streaks per shake, each starting at its own depth
                for _ in range(int(rng.integers(0, 3))):
                    gc = int(rng.integers(1, w - 1))
                    grain[gc] = int(rng.choice([-1, 1]))
                    gtop[gc] = int(rng.integers(2, 5))
            lip = shake and rng.random() < 0.4
            split = int(rng.integers(3, w - 2)) if shake and w >= 12 and rng.random() < 0.3 else -1
            for xi in range(max(0, x), min(W, x + w)):
                for yi in range(y0, y0 + h):
                    unit[yi, xi] = uid
                    rowc[yi, xi] = yi - y0
                    c = xi - x
                    r = yi - y0
                    b = base[uid]
                    if c == 0 and r >= 2:
                        t = 2                                      # the joint between neighbours
                    elif r == 0:
                        t = 1                                      # shadow under the course above
                    elif r == 1 and shake:
                        t = max(2, b - 1)
                    elif r == h - 1 and hang[uid] < 0:
                        t = 1                                      # a short shake: the shadow line shows
                    elif r == h - 1 and lip:
                        t = min(7, b + 1)                          # the lit butt lip, on some shakes
                    else:
                        t = b + (int(grain[c]) if gtop[c] <= r <= h - 2 else 0)
                        if c == split and r >= h // 2:
                            t = 2                                  # a split in a wide shake
                    if not shake and r == h - 1 and hang[uid] > 0:
                        t = min(7, b + 1)
                    out[yi, xi] = pal[max(0, min(7, t))]
            x += w
            k += 1
        y0 += h
    # a long shake or slate hangs 1 px over the next course's shadow row
    for ci, (y0, h) in enumerate(starts[:-1]):
        yb = y0 + h
        for xi in range(W):
            u = unit[y0 + h - 1, xi]
            if u >= 0 and hang.get(u, 0) > 0 and rowc[yb, xi] == 0:
                out[yb, xi] = pal[min(7, base[u] + (1 if shake else 0))]
    # weathering: shakes silver in soft patches and darken toward the eave; slate barely shifts
    for yi in range(ROOF_Y0, ROOF_Y1):
        for xi in range(W):
            u = unit[yi, xi]
            if u < 0 or rowc[yi, xi] == 0:
                continue
            p = patch[yi, xi]
            if shake and p > 0.55 and (u * 7919) % 5 < 3:
                c = out[yi, xi].astype(int)
                g = SHAKE_GREY[max(0, min(3, int(np.argmin([abs(int(c.sum()) - int(t.astype(int).sum())) for t in SHAKE]) - 2)))]
                out[yi, xi] = ((c * 0.45 + g.astype(int) * 0.55)).astype(np.uint8)
            elif not shake and p > 0.7 and (u * 7919) % 3 == 0:
                out[yi, xi] = (out[yi, xi].astype(int) * 0.92 + np.array([3, 4, 6])).clip(0, 255).astype(np.uint8)
    if shake:   # a little moss on the lowest courses only, in a few small clumps
        for _ in range(6):
            cx, cy = int(rng.integers(30, 350)), int(rng.integers(124, 146))
            for _ in range(int(rng.integers(4, 9))):
                xi, yi = cx + int(rng.integers(-3, 4)), cy + int(rng.integers(-1, 2))
                if rowc[yi, xi] > 0:
                    out[yi, xi] = s2.MOSS[int(rng.integers(0, 3))]
    # far slope, ridge and the chimney's shadow
    for yi in range(H):
        for xi in range(W):
            n = rlab[yi, xi]
            if n == R_BACK:
                r = yi - 44
                out[yi, xi] = pal[3 if r == 0 else (1 if (xi + 3 * (r // 3)) % (11 if shake else 21) == 0 else 2)]
            elif n == R_RIDGE:
                r = yi - 50
                j = (xi % (57 if shake else 41)) == 0
                out[yi, xi] = pal[1] if j and 1 <= r <= 4 else pal[[6, 5, 5, 4, 3, 1][r]]
            elif n == R_CHSH:
                c = out[yi, xi]
                k = int(np.argmin([abs(int(c.astype(int).sum()) - int(t.astype(int).sum())) for t in pal]))
                out[yi, xi] = pal[max(0, k - 2)]
    return out, unit, rowc, base


def apply_roof(img, rlab, roof):
    sel = np.isin(rlab, [R_FIELD, R_RIDGE, R_CHSH, R_BACK])
    img[sel, :3] = roof[sel]
    return img


# --- interlocking hewn corners --------------------------------------------------------------------------------

def corners(img, wall, rng):
    """Dovetailed hewn-log corners. At each corner the front logs run past the side wall by a varied 2-6 px and
    end in an axe-cut face; between them, straddling each seam, the squared end of a side-wall timber shows: its
    own width and height, an off-centre pith, squarish rings, a check crack, a waney (bark) edge on some, lit on its
    upper-left edges and shaded on its lower-right."""
    for side in (0, 1):
        X = (lambda x: x) if side == 0 else (lambda x: 383 - x)   # local x (west corner frame) -> canvas x
        # 1. front logs run past the corner
        y0 = s2.WALL_Y0
        for i, h in enumerate(s2.COURSES):
            p = int(rng.integers(5, 9))
            cut = [int(rng.integers(0, 2)) for _ in range(h)]
            for r in range(h):
                y = y0 + r
                xe = 16 - p - cut[r] * (1 if 3 < r < h - 3 else 0)
                for lx in range(xe, 16):
                    x = X(lx)
                    img[y, x, :3] = wall[y, X(24 + (lx - xe) + 3)]
                    img[y, x, 3] = 255
                # the axe-cut end face, two px, lit when it faces west (left), shaded when it faces east
                if r == 0:
                    c = s2.SEAM
                elif r == h - 1:
                    c = END[1]
                else:
                    c = END[5] if side == 0 else END[2]
                    if r == 1:
                        c = END[6] if side == 0 else END[3]
                img[y, X(xe), :3] = c
                img[y, X(xe + 1), :3] = END[4] if side == 0 and 0 < r < h - 1 else (END[1] if r in (0, h - 1) else END[3])
            y0 += h
        # 2. side-wall timber ends straddling each seam
        y0 = s2.WALL_Y0
        for i, h in enumerate(s2.COURSES[:-1]):
            seam = y0 + h
            y0 += h
            hb = int(rng.integers(12, 15))
            top = seam - hb // 2 + int(rng.integers(-1, 2))
            xl = 16 - int(rng.integers(6, 9))
            xr = 16 + int(rng.integers(3, 6))
            wb = xr - xl
            pcx = xl + wb / 2 + rng.uniform(-2, 2)
            pcy = top + hb / 2 + rng.uniform(-1.2, 1.2)
            waney = int(rng.integers(0, 4)) if rng.random() < 0.5 else -1   # which corner keeps its bark
            chamf = [int(rng.integers(1, 3)) for _ in range(4)]             # tl, tr, bl, br
            crack = (rng.uniform(-np.pi, np.pi), int(rng.integers(3, 6))) if rng.random() < 0.7 else None
            tone = int(rng.choice([0, 0, -1, 1, 1]))
            for y in range(top, top + hb):
                for lx in range(xl, xr):
                    ry, rx = y - top, lx - xl
                    corner_d = [(rx + ry), (wb - 1 - rx + ry), (rx + hb - 1 - ry), (wb - 1 - rx + hb - 1 - ry)]
                    if any(corner_d[k] < chamf[k] for k in range(4)):
                        continue
                    x = X(lx)
                    # screen-space edges for the light: top-left lit, bottom-right shaded
                    sx_left = (rx == 0) if side == 0 else (rx == wb - 1)
                    sx_right = (rx == wb - 1) if side == 0 else (rx == 0)
                    dx, dy = (lx - pcx) / (wb / 2), (y - pcy) / (hb / 2)
                    d = 0.55 * max(abs(dx), abs(dy)) + 0.45 * np.hypot(dx, dy)
                    ring = int(d * 3.2)
                    c = 4 + tone - (1 if ring % 2 == 1 else 0)
                    if d < 0.16:
                        c = 2
                    if ry == 1 or (sx_left_in := ((rx == 1) if side == 0 else (rx == wb - 2))):
                        c = 6 if ry == 1 else 5
                    if ry == hb - 2 or ((rx == wb - 2) if side == 0 else (rx == 1)):
                        c = 2
                    col = END[max(0, min(6, c))]
                    if ry in (0, hb - 1) or rx in (0, wb - 1) or any(corner_d[k] == chamf[k] for k in range(4)):
                        col = s2.SEAM          # the dark gap round the timber end
                    if waney >= 0 and corner_d[waney] < chamf[waney] + 2:
                        col = s2.LOG_B[2]
                    img[y, x, :3] = col
                    img[y, x, 3] = 255
            if crack:
                a, ln = crack
                for t in range(1, ln + 1):
                    lx = int(round(pcx + np.cos(a) * t))
                    y = int(round(pcy + np.sin(a) * t * 0.7))
                    if xl < lx < xr - 1 and top < y < top + hb - 1:
                        img[y, X(lx), :3] = END[1]
            # a dark gap where the timber's lower and outer edge meets the front logs
            for lx in range(xl, xr):
                y = top + hb
                if img[y, X(lx), 3] and s2.WALL_Y0 < y < s2.WALL_Y1:
                    img[y, X(lx), :3] = s2.SEAM
    return img


def build_log(day, lab0, rng):
    """S2's build_log with the new corners in place of the round end grain."""
    out = day.copy()
    wall, wmask = s2.log_wall(rng)   # first use of rng: identical to S2's wall
    sel = wmask & np.isin(lab0, [LID["wall"], LID["corner_post"]])
    out[sel, :3] = wall[sel]
    for w in m0.A["windows"]:
        x0, x1 = w["x"]
        y1 = w["y"][1] + 5
        for y in range(y1, min(y1 + 3, s2.WALL_Y1)):
            for x in range(x0 - 4, x1 + 4):
                if lab0[y, x] == LID["wall"]:
                    out[y, x, :3] = (out[y, x, :3].astype(int) * 0.78).astype(np.uint8)
        for y in range(w["y"][0], y1):
            for x in range(x1, x1 + 2):
                if lab0[y, x] == LID["wall"]:
                    out[y, x, :3] = (out[y, x, :3].astype(int) * 0.82).astype(np.uint8)
    for y in range(212, s2.WALL_Y1):
        for x in range(217, 220):
            if lab0[y, x] == LID["wall"]:
                out[y, x, :3] = (out[y, x, :3].astype(int) * 0.8).astype(np.uint8)
    for x0, x1 in m0.A["wall"]["posts_x"]:
        out[s2.WALL_Y0:s2.WALL_Y1, x0:x1, :3] = wall[s2.WALL_Y0:s2.WALL_Y1, 24:24 + (x1 - x0)] if x0 < 192 else \
            wall[s2.WALL_Y0:s2.WALL_Y1, 352:352 + (x1 - x0)]
    out[s2.WALL_Y0:s2.WALL_Y1, 14:16] = 0
    out[s2.WALL_Y0:s2.WALL_Y1, 368:370] = 0
    out = corners(out, wall, np.random.default_rng(57))
    out = s2.outline_new(out, None)
    out[160:162, :, :3] = np.where(out[160:162, :, 3:4] > 0, day[160:162, :, :3], out[160:162, :, :3])
    return out


# --- schematic stages -----------------------------------------------------------------------------------------

HOLES = [(72, 95, 44, 19), (240, 108, 34, 15), (150, 73, 20, 10)]   # cx, cy, rx, ry on the roof field


def hole_mask(unit, rowc, rlab, cx, cy, rx, ry, rng):
    """A hole made of whole missing shakes or slates inside a lobed, noisy outline, with broken units at its rim
    (their lower part snapped off on a slant), so it never reads as a rectangle."""
    field = rlab == R_FIELD
    ph = rng.uniform(0, 6.28, 3)
    m = np.zeros((H, W), bool)
    for u in np.unique(unit[field]):
        if u < 0:
            continue
        ys, xs = np.nonzero((unit == u) & field)
        ux, uy = xs.mean(), ys.mean()
        th = np.arctan2((uy - cy) / ry, (ux - cx) / rx)
        lobe = 1 + 0.28 * np.sin(3 * th + ph[0]) + 0.16 * np.sin(5 * th + ph[1]) + 0.1 * np.sin(2 * th + ph[2])
        d = np.hypot((ux - cx) / rx, (uy - cy) / ry) / lobe
        if d < 0.9 or (d < 1.2 and rng.random() < 0.6):
            m[ys, xs] = True
        elif d < 1.45 and rng.random() < 0.65:
            # a broken unit: the lower part is gone below a slanted break
            x0 = xs.min()
            top = ys.min() + int(rng.integers(2, 5))
            sl = rng.uniform(-0.5, 0.5)
            m[ys, xs] = ys > top + sl * (xs - x0)
    return m


def paint_hole(img, hole, rng):
    """Inside a hole: the skip-sheathing boards (laths) and rafters, and the dark attic beyond."""
    lath = rng.integers(0, 9)
    for y, x in zip(*np.nonzero(hole)):
        if (y - 56 + lath) % 9 in (0, 1, 2):
            c = hx("5a3c26") if (y - 56 + lath) % 9 == 0 else hx("3e2a1b")
            if (x * 5 + y) % 37 == 0:
                c = hx("120e0c")
        elif x % 32 in (0, 1, 2):
            c = hx("4a3220") if x % 32 == 0 else hx("33231a")
        else:
            c = hx("120e0c")
        img[y, x, :3] = c
    # the rim of the hole casts a 1 px shadow onto what is below it
    sh = hole[:-1] & ~hole[1:]
    ys, xs = np.nonzero(sh)
    for y, x in zip(ys + 1, xs):
        img[y, x, :3] = (img[y, x, :3].astype(int) * 0.6).astype(np.uint8)


def slip_units(img, unit, rowc, rlab, hole, n, rng, pal):
    """A few shakes or slates slid 2 px down the roof, leaving a dark gap above them."""
    field = (rlab == R_FIELD) & ~hole
    us = [u for u in np.unique(unit[field]) if u >= 1000]
    for u in rng.choice(us, size=min(n, len(us)), replace=False):
        sel = (unit == u) & field
        ys, xs = np.nonzero(sel)
        src = img.copy()
        for y, x in zip(ys, xs):
            if y + 2 < ROOF_Y1:
                img[y + 2, x, :3] = src[y, x, :3]
        for y, x in zip(ys, xs):
            if y - ys.min() < 2:
                img[y, x, :3] = pal[0]


def tarp(img, hole, rlab, rng):
    """A weighted canvas tarp with an uneven, draped outline and diagonal folds."""
    ys, xs = np.nonzero(hole)
    cx, cy = xs.mean(), ys.mean()
    rx = (np.percentile(xs, 95) - np.percentile(xs, 5)) / 2 + 4
    ry = (np.percentile(ys, 95) - np.percentile(ys, 5)) / 2 + 3
    yy, xx = np.mgrid[0:H, 0:W]
    th = np.arctan2((yy - cy) / ry, (xx - cx) / rx)
    lobe = 1 + 0.1 * np.sin(4 * th + 1.3) + 0.07 * np.sin(7 * th + 0.4)
    d = np.hypot((xx - cx) / rx, (yy - cy) / ry) / lobe
    m = (d <= 1.0) & np.isin(rlab, [R_FIELD])
    m |= hole
    for y, x in zip(*np.nonzero(m)):
        fold = int(((x - cx) * 0.55 + (y - cy)) // 6) % 3
        c = s2.CANVAS[[1, 0, 1][fold]]
        if d[y, x] > 0.88:
            c = s2.CANVAS[0]
        img[y, x, :3] = c
    edge = m & ~(np.roll(m, 1, 0) & np.roll(m, -1, 0) & np.roll(m, 1, 1) & np.roll(m, -1, 1))
    img[edge, :3] = INK
    # a rope across it and two stones holding the lower edge
    for x in range(int(cx - rx + 4), int(cx + rx - 4)):
        y = int(cy - 2 + (x - cx) * 0.12)
        if m[y, x]:
            img[y, x, :3] = hx("7a6a4c")
    for sx in (int(cx - rx * 0.55), int(cx + rx * 0.4)):
        sy = int(cy + ry * 0.7)
        for y in range(sy - 3, sy + 2):
            for x in range(sx - 3, sx + 3):
                if (x - sx) ** 2 / 9 + (y - sy + 1) ** 2 / 4 <= 1:
                    img[y, x, :3] = hx("6e6c66") if y < sy - 1 else hx("4a4844")
        img[sy + 2, sx - 2:sx + 3, :3] = INK


def boards_over(img, hole, rlab, rng):
    """Tarred boards nailed down the slope over a hole, of uneven lengths and ends."""
    ys, xs = np.nonzero(hole)
    x0, x1 = int(np.percentile(xs, 8)) - 2, int(np.percentile(xs, 92)) + 3
    ylo, yhi = int(np.percentile(ys, 5)), int(np.percentile(ys, 95))
    x = x0
    while x < x1:
        w = int(rng.integers(6, 9))
        top = ylo - int(rng.integers(1, 5))
        bot = yhi + int(rng.integers(1, 5))
        t = int(rng.choice([3, 3, 4, 4, 5]))
        for yy in range(top, bot):
            for xx in range(x, min(x + w, x1)):
                if rlab[yy, xx] != R_FIELD:
                    continue
                c = xx - x
                if c == 0 or c == w - 1:
                    col = s2.TAR[1]
                elif c == 1:
                    col = s2.TAR[t + 2]
                else:
                    col = s2.TAR[t + (1 if (xx * 3 + yy) % 13 == 0 else 0)]
                if yy in (top + 2, bot - 3) and c == w // 2:
                    col = hx("8a8a84")          # nails
                img[yy, xx, :3] = col
        for xx in range(x, min(x + w, x1)):
            if rlab[bot, xx] == R_FIELD:
                img[bot, xx, :3] = INK
        x += w + int(rng.integers(0, 2))


def recolor_units(img, sel, pal_from, pal_to):
    for y, x in zip(*np.nonzero(sel)):
        c = img[y, x, :3].astype(int)
        k = int(np.argmin([abs(int(c.sum()) - int(t.astype(int).sum())) for t in pal_from]))
        img[y, x, :3] = pal_to[k]


def make_stage(stage, kind, log_day, log_night, glass_diff, lab0, rlab, unit, rowc, seed):
    rng = np.random.default_rng(seed)
    R = s2.regions(lab0, rlab)
    pal = SHAKE if kind == "shake" else SLATE
    d = log_day.copy()
    holes = [hole_mask(unit, rowc, rlab, *h, rng) for h in HOLES]
    allh = np.any(holes, axis=0)
    # --- roof ---
    if stage == 0:
        for h in holes:
            paint_hole(d, h, rng)
        slip_units(d, unit, rowc, rlab, allh, 9, rng, pal)
        s2.moss(d, R["slate"] & ~allh, rng, 45, y_bias=105)
        d[18:30, 290:330, 3] = 0       # chimney: top courses broken, no cap (as S2)
        for x in range(290, 330):
            top = 30 - (abs(x - 304) % 7)
            d[top:30, x, :3] = d[34, x, :3] if d[34, x, 3] else INK
            d[top:30, x, 3] = d[34, x, 3]
    elif stage == 1:
        s2.moss(d, R["slate"] & ~allh, rng, 25, y_bias=115)
        boards_over(d, holes[0], rlab, rng)
        tarp(d, holes[1], rlab, rng)
        boards_over(d, holes[2], rlab, rng)
    elif stage == 2:
        s2.moss(d, R["slate"], rng, 6, y_bias=135)
        for i, h in enumerate(holes):
            if i == 2:
                boards_over(d, h, rlab, rng)   # one old patch is still waiting
                continue
            us = np.unique(unit[h])
            sel = np.isin(unit, us) & (rlab == R_FIELD) & (rowc > 0)
            recolor_units(d, sel, pal, SHAKE_NEW if kind == "shake" else SLATE_NEW)
    # --- walls, windows, door, steps, dressing: S2's matrix ---
    wall = R["wall"]
    if stage <= 1:
        a = 0.7 if stage == 0 else 0.4
        for y, x in zip(*np.nonzero(wall)):
            d[y, x, :3] = s2.blend(d[y, x, :3], s2.to_ramp(d[y, x, :3], s2.GREY), a)
        for sx in ([86, 104, 280, 296, 40, 340] if stage == 0 else [96, 290]):
            ln = int(rng.integers(18, 40))
            y0 = 253 if 60 < sx < 320 else 164
            for y in range(y0, min(y0 + ln, s2.WALL_Y1)):
                for x in range(sx, sx + int(rng.integers(2, 5))):
                    if wall[y, x]:
                        d[y, x, :3] = (d[y, x, :3].astype(int) * 0.62).astype(np.uint8)
        # the corner timbers weather grey too
        corner = (d[..., 3] > 0) & ~wall & (lab0 == 0) & (np.arange(H)[:, None] >= 160) & (np.arange(H)[:, None] < 280)
        for y, x in zip(*np.nonzero(corner)):
            d[y, x, :3] = s2.blend(d[y, x, :3], s2.to_ramp(d[y, x, :3], s2.GREY), a)
    if stage == 0:
        y0 = s2.WALL_Y0 + sum(s2.COURSES[:5])
        h = s2.COURSES[5]
        d[y0 + 2:y0 + h - 2, 128:156, :3] = hx("120e0c")
        d[y0 + 2:y0 + h - 2, 126:128, :3] = s2.GREY[6]
        d[y0 + 2:y0 + h - 2, 156:158, :3] = s2.GREY[5]
        d[y0 + 1, 132:150, :3] = s2.GREY[4]
    if stage == 1:
        y0 = s2.WALL_Y0 + sum(s2.COURSES[:4])
        sub = np.zeros((H, W, 4), np.uint8)
        s2.planks(sub, 128, y0, 160, y0 + 46, s2.FRESH, horizontal=False, gap=2, w=7)
        sel = sub[..., 3] > 0
        d[sel] = sub[sel]
    if stage == 2:
        for ci, xa, xb in ((5, 122, 166), (2, 26, 72), (6, 312, 358)):
            y0 = s2.WALL_Y0 + sum(s2.COURSES[:ci])
            for y in range(y0, y0 + s2.COURSES[ci]):
                for x in range(xa, xb):
                    if wall[y, x]:
                        d[y, x, :3] = s2.to_ramp(d[y, x, :3], s2.FRESH)
    wins = m0.A["windows"]
    if stage == 0:
        w = wins[0]
        for y in range(w["y"][0] + 6, w["y"][1] - 6):
            for x in range(w["x"][0] + 6, w["x"][1] - 6):
                d[y, x, :3] = hx("16120f")
        for k in range(26):
            d[w["y"][0] + 8 + (k * 7) % 22, w["x"][0] + 8 + k, :3] = hx("6e8088")
        w = wins[1]
        for y in range(w["y"][0] + 6, w["y"][1] - 6):
            for x in range(w["x"][0] + 6, w["x"][1] - 6):
                d[y, x, :3] = hx("16120f")
        s2.planks(d, w["x"][0] - 2, w["y"][0] + 2, w["x"][1] + 2, w["y"][1] - 2, s2.GREY, angle=0.75, w=7)
        s2.planks(d, w["x"][0] - 2, w["y"][0] + 18, w["x"][1] + 2, w["y"][1] + 2, s2.GREY, angle=-0.6, w=6)
    if stage == 1:
        for w in wins:
            s2.planks(d, w["x"][0] - 3, w["y"][0] + 2, w["x"][1] + 3, w["y"][1] - 1, s2.FRESH, horizontal=True, gap=2, w=8)
    door = R["door"]
    if stage == 0:
        for y, x in zip(*np.nonzero(door)):
            d[y, x, :3] = s2.blend(d[y, x, :3], s2.to_ramp(d[y, x, :3], s2.GREY), 0.7)
        for y in range(224, 246):
            for x in range(211 - (246 - y) // 2, 211):
                d[y, x, :3] = hx("0e0b09")
    if stage == 1:
        dx0, dx1 = m0.A["door"]["x"]
        for y in range(230, 292):
            x = int(dx0 + (dx1 - dx0) * (y - 230) / 62)
            d[y, max(dx0, x - 3):min(dx1, x + 3), :3] = s2.FRESH[6]
            d[y, min(dx1 - 1, x + 3), :3] = s2.FRESH[2]
    if stage == 0:
        d[300:309, 186:206, :3] = hx("120e0c")
        for k in range(14):
            d[310 + k % 9, 170 + k * 3, :3] = INK
        for y, x in zip(*np.nonzero(R["found"])):
            if rng.random() < 0.05:
                d[y, x, :3] = INK
    if stage == 1:
        s2.planks(d, 182, 299, 210, 308, s2.FRESH, horizontal=True, w=8, gap=1)
    if stage == 0:
        for x, y, ln in ((20, 296, 120), (30, 290, 80), (360, 296, 100), (226, 296, 60), (122, 296, 50)):
            s2.vine(d, x, y, ln, rng)
        s2.tufts(d, 319, list(range(10, 160, 9)) + list(range(226, 380, 9)), rng, tall=10)
        s2.planks(d, 236, 306, 290, 312, s2.GREY, angle=0.08, w=5)
    elif stage == 1:
        for x, y, ln in ((20, 296, 50), (362, 296, 40)):
            s2.vine(d, x, y, ln, rng)
        s2.tufts(d, 319, list(range(14, 150, 17)) + list(range(240, 376, 17)), rng, tall=7)
    elif stage == 2:
        s2.tufts(d, 319, [20, 70, 250, 330, 372], rng, tall=4)
    elif stage == 3:
        for w in wins:
            x0, x1 = w["x"][0] - 2, w["x"][1] + 2
            y0 = w["y"][1] + 5
            d[y0:y0 + 9, x0:x1, :3] = s2.LOG_A[5]
            d[y0, x0:x1, :3] = s2.LOG_A[7]
            d[y0 + 8, x0:x1, :3] = s2.LOG_A[2]
            d[y0:y0 + 9, x0, :3] = INK
            d[y0:y0 + 9, x1 - 1, :3] = INK
            for x in range(x0 + 2, x1 - 2):
                for j in range(int(rng.integers(4, 10))):
                    c = s2.VINE[2 + (j % 2)] if j < 2 or (x % 5 == 0 and rng.random() < 0.5) else s2.FLOWER[(x // 5 + j // 3) % 4]
                    d[y0 - j, x, :3] = c
        for cy, xs in ((292, range(132, 162, 8)), (285, range(136, 160, 8)), (278, range(140, 156, 8))):
            for x in xs:
                s2.end_grain(d, x, cy, 4.2, 3.6, False)
        for px in (152, 226):
            d[306:318, px:px + 10, :3] = hx("8a4a2a")
            d[306, px:px + 10, :3] = hx("a8643a")
            d[306:318, px, :3] = INK
            d[306:318, px + 9, :3] = INK
            d[317, px:px + 10, :3] = INK
            d[306:318, px:px + 10, 3] = 255
            for k in range(14):
                d[300 + k % 6, px + 1 + (k * 3) % 8, :3] = s2.FLOWER[k % 4] if k % 3 else s2.VINE[3]
                d[300 + k % 6, px + 1 + (k * 3) % 8, 3] = 255
    # --- night: every day change, except the glass that is lit at night (stages 2-3) ---
    n = log_night.copy()
    keep = glass_diff if stage >= 2 else np.zeros_like(glass_diff)
    changed = ((d != log_day).any(axis=2) | (stage <= 1) & glass_diff) & ~keep
    n[changed] = d[changed]
    if stage <= 1:
        n[door] = d[door]
    if stage == 1:
        # S2's defect fixed: a lamp is lit inside. Warm light shows in the 2 px gaps between the window boards
        # (centre of each gap brightest, fading to the board edges) and as a thin line under the door. Paired with
        # the harness's winlights=dim, a faint low light at each window instead of the full lamp.
        warm = [hx("5a3818"), hx("8a5a24"), hx("c08a3a"), hx("e8b860")]
        for w in wins:
            yb = w["y"][0] + 2
            for y in range(yb, w["y"][1] - 1):
                if (y - yb) % 10 >= 8:
                    for x in range(w["x"][0] + 2, w["x"][1] - 2):
                        e = min(x - (w["x"][0] + 2), (w["x"][1] - 3) - x)
                        n[y, x, :3] = warm[min(3, e // 4)]
        dx0, dx1 = m0.A["door"]["x"]
        n[297, dx0 + 3:dx1 - 3, :3] = warm[2]
    return d, n


def main():
    lab0 = m0.build_labels()
    rlab = np.array(Image.open(os.path.join(SA, "labels_roof.png")))
    sa_day = np.array(Image.open(os.path.join(SA, "32", "house_day.png")).convert("RGBA"))
    sa_night = np.array(Image.open(os.path.join(SA, "32", "house_night.png")).convert("RGBA"))
    logc_day = build_log(sa_day, lab0, np.random.default_rng(23))
    logc_night, glass_diff = s2.night_from(logc_day, sa_day, sa_night)
    out = {"logc": (logc_day, logc_night)}
    for kind, tag, seed in (("shake", "sh", 71), ("slate", "sl", 73)):
        roof, unit, rowc, _ = roof_material(kind, rlab, np.random.default_rng(seed))
        dday = apply_roof(logc_day.copy(), rlab, roof)
        dnight = apply_roof(logc_night.copy(), rlab, roof)
        out[kind] = (dday, dnight)
        for s in range(4):
            out["%s%d" % (tag, s)] = make_stage(s, kind, dday, dnight, glass_diff, lab0, rlab, unit, rowc, 300 + s)
    metrics = {}
    a0 = sa_day[..., 3] > 0
    s2log = np.array(Image.open(os.path.join(m0.ROOT, "pl", "g5", "log", "32", "house_day.png")).convert("RGBA"))
    roof_sel = np.isin(rlab, [R_FIELD, R_RIDGE, R_CHSH, R_BACK])
    for k, (dd, nn) in out.items():
        p = os.path.join(G6, k, "32")
        os.makedirs(p, exist_ok=True)
        Image.fromarray(dd, "RGBA").save(os.path.join(p, "house_day.png"))
        Image.fromarray(nn, "RGBA").save(os.path.join(p, "house_night.png"))
        a = dd[..., 3] > 0
        rpx = dd[roof_sel & a][:, :3].astype(int)
        lum = rpx @ np.array([299, 587, 114]) / 1000
        metrics[k] = {"opaque_px": int(a.sum()), "added_vs_sa": int((a & ~a0).sum()), "removed_vs_sa": int((a0 & ~a).sum()),
                      "colours": int(len(np.unique(dd[a][:, :3], axis=0))),
                      "roof_colours": int(len(np.unique(rpx, axis=0))), "roof_mean_luma": round(float(lum.mean()), 1),
                      "roof_luma_sd": round(float(lum.std()), 1)}
    for nm, img in (("sa", sa_day), ("s2_log", s2log)):
        a = img[..., 3] > 0
        rpx = img[roof_sel & a][:, :3].astype(int)
        lum = rpx @ np.array([299, 587, 114]) / 1000
        metrics[nm] = {"opaque_px": int(a.sum()), "colours": int(len(np.unique(img[a][:, :3], axis=0))),
                       "roof_colours": int(len(np.unique(rpx, axis=0))), "roof_mean_luma": round(float(lum.mean()), 1),
                       "roof_luma_sd": round(float(lum.std()), 1)}
    # wall pixels outside the corner zones must equal S2's log wall exactly
    zone = np.ones((H, W), bool)
    zone[:, :30] = zone[:, 354:] = False
    zone &= ~roof_sel
    metrics["logc_vs_s2_outside_corners_identical"] = bool((out["logc"][0][zone] == s2log[zone]).all())
    with open(os.path.join(G6, "s3_metrics.json"), "w") as f:
        json.dump(metrics, f, indent=1)
    print(json.dumps(metrics, indent=1))


if __name__ == "__main__":
    main()
