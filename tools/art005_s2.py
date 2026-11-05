# ART-005 S2 (non-production): the owner's chosen SA farmhouse (side gable, one roofline) with a provisional
# log-cabin wall, plus four schematic restoration stages on the same alpha-compatible structure. Zero generation:
# every pixel is placed by this script from hand-picked ramps (logs, end grain, weathered grey, moss, vines) and the
# SA sprite's own roof, windows, door, foundation and steps.
#   python tools/art005_s2.py
# Reads (never writes) pl/g4/sa/32/house_day.png + house_night.png and M0's label map (tools/art005_m0.py).
# Writes art/style_tests/ART-005/pl/g5/<var>/32/house_day.png, house_night.png for the harness (art=g5 var=<var>):
#   log      SA with the log wall: stacked hand-hewn logs, dark recessed seams, notched corners with end grain
#   st0..st3 schematic stages on the log house: 0 dilapidated, 1 stabilized, 2 repaired, 3 restored
# The canvas (384 x 320), roofline, door, window openings and centres, foundation, steps and footprint are SA's.
# The stages change condition only. They are schematic mockups for the restoration plan, not candidate art.
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

W, H = m0.W, m0.H
SA = os.path.join(m0.ROOT, "pl", "g4", "sa")
G5 = os.path.join(m0.ROOT, "pl", "g5")
LID = m0.LID


def hx(s):
    return np.array([int(s[i:i + 2], 16) for i in (0, 2, 4)], np.uint8)


def ramp(*cols):
    return [hx(c) for c in cols]


INK = hx("1a1410")
# Warm hewn-log ramp (dark to light), muted autumn browns in the wall-A family (D-010), and a slightly greyer twin
# so neighbouring logs differ without noise.
LOG_A = ramp("1a1410", "2c1f17", "3f2a1d", "533826", "664831", "795a3c", "8d6c48", "a07f56", "b49466")
LOG_B = ramp("1a1410", "2a1f18", "3d2c20", "514028", "64503a", "786246", "8c7352", "a0865f", "b49a72")
GREY = ramp("1a1410", "28241f", "3a3530", "4c4640", "5e5750", "706960", "837b70", "968e80", "aaa190")
FRESH = ramp("1a1410", "33221a", "4c3220", "684629", "855c33", "9d723f", "b4884c", "c79c5b", "d8b06c")
END = ramp("2c1e16", "5a3c24", "765034", "8f6a44", "a8845a", "c09c6e", "d2b282")   # end grain, bark rim first
SEAM = hx("1f1712")
MOSS = ramp("2e3420", "3f4a26", "52602e", "6a7838", "84904a")
VINE = ramp("26301c", "364426", "4a5c2e", "62743a")
AUTUMN = ramp("6a2a18", "8a3a20", "b0562a", "c87a34")
FLOWER = ramp("8a2a2a", "b84a34", "d88a3a", "e8c060", "c8a0d0")
TAR = ramp("1a1410", "201c18", "2a2520", "34302a", "3e3932", "48423a", "524b42", "5e564c", "6a6156")
CANVAS = ramp("4a463c", "6a6450", "857e66", "a09878")

COURSES = [15, 14, 16, 15, 14, 16, 15, 15]   # log heights from the eave (y 160) to the foundation (y 280)
WALL_Y0, WALL_Y1 = 160, 280
LEFT_END_CX, RIGHT_END_CX = 15, 368          # end-grain centres at the notched corners


def course_of(y):
    y0 = WALL_Y0
    for i, h in enumerate(COURSES):
        if y < y0 + h:
            return i, y - y0, h, y0
        y0 += h
    return len(COURSES) - 1, y - (y0 - COURSES[-1]), COURSES[-1], y0 - COURSES[-1]


def log_wall(rng):
    """Returns (rgb image of the log wall over the whole canvas, mask of where it applies)."""
    out = np.zeros((H, W, 3), np.uint8)
    mask = np.zeros((H, W), bool)
    # per log: ramp, tone shift, a long low-frequency grain profile, and 1-2 knots
    logs = []
    for i, h in enumerate(COURSES):
        r = LOG_A if rng.random() < 0.6 else LOG_B
        grain = np.zeros((h, W), int)
        for rr in range(2, h - 3):
            x = int(rng.integers(0, 30))
            while x < W:
                ln = int(rng.integers(6, 34))
                if rng.random() < 0.45:
                    grain[rr, x:x + ln] = 1 if rng.random() < 0.5 else -1
                x += ln + int(rng.integers(4, 20))
        knots = [(int(rng.integers(40, 340)), int(rng.integers(4, max(5, h - 6)))) for _ in range(int(rng.integers(1, 3)))]
        logs.append((r, int(rng.choice([-1, 0, 0, 1])), grain, knots))
    for y in range(WALL_Y0, WALL_Y1):
        i, rr, h, _ = course_of(y)
        r, shift, grain, knots = logs[i]
        for x in range(24, 360):
            if rr == 0:
                c = SEAM                      # recessed dark joint between logs
            elif rr == 1:
                c = r[7 + (1 if shift > 0 else 0)]   # the log's lit upper curve
            elif rr == 2:
                c = r[6 + shift // 2]
            elif rr >= h - 1:
                c = r[1]                      # underside in shadow, falling into the next seam
            elif rr >= h - 3:
                c = r[3]
            else:
                k = 5 + shift + int(grain[rr, x])
                if rr >= h - 5:
                    k -= 1
                c = r[max(2, min(7, k))]
            for kx, ky in knots:
                d = (x - kx) ** 2 / 9.0 + (rr - ky) ** 2 / 2.25
                if d <= 1.0:
                    c = r[2] if d < 0.4 else r[3]
                elif d <= 1.9 and x < kx and rr <= ky:
                    c = r[7]
            if y < 168:                       # soft shadow under the eave
                c = r[max(1, int(np.argmin([abs(int(t.astype(int).sum()) - int(c.astype(int).sum())) for t in r])) - 2)]
            out[y, x] = c
            mask[y, x] = True
    return out, mask


def end_grain(img, cx, cy, rw, rh, flip):
    """An elliptical log end (bark rim, rings, a lit upper-left edge) centred on (cx, cy)."""
    for y in range(int(cy - rh) - 1, int(cy + rh) + 2):
        for x in range(int(cx - rw) - 1, int(cx + rw) + 2):
            if not (0 <= x < W and 0 <= y < H):
                continue
            d = ((x - cx) / rw) ** 2 + ((y - cy) / rh) ** 2
            if d > 1.0:
                continue
            if d > 0.72:
                c = END[0] if (x - cx) * (-1 if flip else 1) > 0 or y > cy else END[1]
            else:
                ring = int(np.sqrt(d) * 5)
                c = END[3 + (ring % 2)] if ring > 0 else END[5]
                if (x - cx) + (y - cy) < -rh * 0.9 and d > 0.3:
                    c = END[6]
                elif (x - cx) + (y - cy) > rh * 0.9:
                    c = END[2]
            img[y, x, :3] = c
            img[y, x, 3] = 255


def outline_new(img, before_alpha):
    op = img[..., 3] > 0
    nb = np.zeros_like(op)
    nb[1:] |= op[:-1]
    nb[:-1] |= op[1:]
    nb[:, 1:] |= op[:, :-1]
    nb[:, :-1] |= op[:, 1:]
    edge = nb & ~op
    img[edge, :3] = INK
    img[edge, 3] = 255
    return img


def build_log(day, lab0, rng):
    out = day.copy()
    wall, wmask = log_wall(rng)
    sel = wmask & np.isin(lab0, [LID["wall"], LID["corner_post"]])
    out[sel, :3] = wall[sel]
    # ambient occlusion: logs darken a step just under the sills and right of the window and door trims
    for w in m0.A["windows"]:
        x0, x1 = w["x"]
        y1 = w["y"][1] + 5
        for y in range(y1, min(y1 + 3, WALL_Y1)):
            for x in range(x0 - 4, x1 + 4):
                if lab0[y, x] == LID["wall"]:
                    out[y, x, :3] = (out[y, x, :3].astype(int) * 0.78).astype(np.uint8)
        for y in range(w["y"][0], y1):
            for x in range(x1, x1 + 2):
                if lab0[y, x] == LID["wall"]:
                    out[y, x, :3] = (out[y, x, :3].astype(int) * 0.82).astype(np.uint8)
    for y in range(212, WALL_Y1):
        for x in range(217, 220):
            if lab0[y, x] == LID["wall"]:
                out[y, x, :3] = (out[y, x, :3].astype(int) * 0.8).astype(np.uint8)
    # notched corners: the corner posts go; each course ends in a log end, alternating in and out by 3 px
    for x0, x1 in m0.A["wall"]["posts_x"]:
        out[WALL_Y0:WALL_Y1, x0:x1, :3] = wall[WALL_Y0:WALL_Y1, 24:24 + (x1 - x0)] if x0 < 192 else \
            wall[WALL_Y0:WALL_Y1, 352:352 + (x1 - x0)]
    out[WALL_Y0:WALL_Y1, 14:16] = 0      # the old outline at the wall's west edge (re-drawn below)
    out[WALL_Y0:WALL_Y1, 368:370] = 0
    before = out[..., 3].copy()
    y0 = WALL_Y0
    for i, h in enumerate(COURSES):
        cy = y0 + h / 2.0
        if y0 + h <= 168:
            y0 += h
            continue
        o = 3 if i % 2 == 0 else 0
        end_grain(out, LEFT_END_CX - o + 4, cy, 7.5, h / 2.0 - 0.5, False)
        end_grain(out, RIGHT_END_CX + o - 4, cy, 7.5, h / 2.0 - 0.5, True)
        y0 += h
    # the top course meets the eave: tuck its ends under the fascia shadow
    out = outline_new(out, before)
    out[160:162, :, :3] = np.where(out[160:162, :, 3:4] > 0, day[160:162, :, :3], out[160:162, :, :3])
    return out


def night_from(day_new, sa_day, sa_night):
    diff = (sa_day != sa_night).any(axis=2)
    out = day_new.copy()
    out[diff] = sa_night[diff]
    return out, diff


# --- schematic stages ---------------------------------------------------------------------------------------------

def blend(c, t, a):
    return (c.astype(float) * (1 - a) + t.astype(float) * a).astype(np.uint8)


def to_ramp(c, r):
    lum = int(c.astype(int) @ np.array([299, 587, 114])) // 1000
    lums = [int(t.astype(int) @ np.array([299, 587, 114])) // 1000 for t in r]
    return r[int(np.argmin([abs(lum - l) for l in lums]))]


def regions(lab0, rlab):
    return {
        "slate": np.isin(rlab, [1]),
        "wall": np.isin(lab0, [LID["wall"], LID["corner_post"]]),
        "glass": lab0 == LID["glass"],
        "win": np.isin(lab0, [LID["glass"], LID["mullion"]]),
        "door": np.isin(lab0, [LID["door_leaf"], LID["batten"], LID["knob"]]),
        "steps": lab0 == LID["steps"],
        "found": lab0 == LID["foundation"],
    }


ROOF_HOLES = [(70, 92, 54, 22), (236, 104, 40, 18), (150, 70, 26, 12)]   # cx, cy, rx, ry on the slate


def ellipse_mask(cx, cy, rx, ry, rng=None, rough=0.0):
    yy, xx = np.mgrid[0:H, 0:W]
    d = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
    if rough and rng is not None:
        d = d + rough * (np.sin(xx * 0.9 + rng.uniform(0, 6)) * np.cos(yy * 1.3 + rng.uniform(0, 6)))
    return d <= 1.0


def stepped_hole(cx, cy, rx, ry, rng):
    """A hole in the slate that follows the slate courses: each 12 px course loses a run of slates."""
    m = np.zeros((H, W), bool)
    for y0 in range(56, 148, 12):
        yc = y0 + 6
        if abs(yc - cy) > ry:
            continue
        half = rx * np.sqrt(max(0.0, 1 - ((yc - cy) / ry) ** 2))
        a = int(cx - half + rng.integers(-6, 7))
        b = int(cx + half + rng.integers(-6, 7))
        m[y0 + 1:y0 + 12, max(0, a):max(0, b)] = True
    return m


def paint_battens(img, hole):
    ys, xs = np.nonzero(hole)
    for y, x in zip(ys, xs):
        if (y - 56) % 12 in (5, 6):
            c = hx("5a3c26") if (y - 56) % 12 == 5 else hx("3a281a")   # a lath across the gap
        elif x % 24 in (0, 1, 2):
            c = hx("4a3220") if x % 24 == 0 else hx("33231a")          # a rafter
        else:
            c = hx("120e0c")                                             # the dark attic beyond
        img[y, x, :3] = c


def moss(img, region, rng, n, y_bias=None):
    ys, xs = np.nonzero(region)
    if len(ys) == 0:
        return
    for _ in range(n):
        k = int(rng.integers(0, len(ys)))
        cy, cx = ys[k], xs[k]
        if y_bias is not None and cy < y_bias and rng.random() < 0.6:
            continue
        for _ in range(int(rng.integers(6, 18))):
            y, x = cy + int(rng.integers(-2, 3)), cx + int(rng.integers(-4, 5))
            if 0 <= y < H and 0 <= x < W and region[y, x]:
                img[y, x, :3] = MOSS[int(rng.integers(1, 5))]


def planks(img, x0, y0, x1, y1, r, horizontal=True, gap=1, w=7, rng=None, angle=0.0):
    """Boards nailed over an opening; with angle != 0 a single diagonal board."""
    for y in range(y0, y1):
        for x in range(x0, x1):
            if angle:
                t = (y - y0) - (x - x0) * angle
                if not (0 <= t < w):
                    continue
                rr = int(t)
            else:
                rr = (y - y0) % (w + gap) if horizontal else (x - x0) % (w + gap)
                if rr >= w:
                    img[y, x, :3] = INK
                    img[y, x, 3] = 255
                    continue
            c = r[7] if rr == 0 else (r[2] if rr == w - 1 else r[5 - ((x * 7 + y * 3) % 11 == 0)])
            img[y, x, :3] = c
            img[y, x, 3] = 255
        # nails
    return img


def vine(img, x, y, length, rng, up=True, leaves=AUTUMN):
    for i in range(length):
        y2 = y - i if up else y + i
        x += int(rng.integers(-1, 2)) if i % 3 == 0 else 0
        if not (0 <= y2 < H and 0 <= x < W) or img[y2, x, 3] == 0:
            break
        img[y2, x, :3] = VINE[1]
        if i % 4 == 0:
            for dx, dy in ((-1, 0), (1, 0), (-2, 1), (2, -1), (0, -1)):
                xx, yy = x + dx, y2 + dy
                if 0 <= yy < H and 0 <= xx < W and img[yy, xx, 3] > 0:
                    img[yy, xx, :3] = VINE[int(rng.integers(2, 4))] if rng.random() < 0.8 else leaves[int(rng.integers(0, 4))]


def tufts(img, y_base, xs, rng, cols=MOSS, tall=6):
    for x in xs:
        for k in range(int(rng.integers(3, 7))):
            hgt = int(rng.integers(2, tall))
            xx = x + int(rng.integers(-3, 4))
            for j in range(hgt):
                yy = y_base - j
                if 0 <= yy < H and 0 <= xx < W:
                    img[yy, xx, :3] = cols[min(len(cols) - 1, 1 + j * 3 // hgt)]
                    img[yy, xx, 3] = 255


def make_stage(stage, log_day, log_night, glass_diff, lab0, rlab, seed):
    rng = np.random.default_rng(seed)
    R = regions(lab0, rlab)
    d = log_day.copy()
    n = log_night.copy()
    lit_glass = stage >= 2
    if stage <= 1:
        # windows and lamp unlit: night = day for every glass pixel
        n[glass_diff] = d[glass_diff]
    if stage == 3:
        pass
    # --- roof ---
    holes = [stepped_hole(cx, cy, rx, ry, rng) & R["slate"] for cx, cy, rx, ry in ROOF_HOLES]
    if stage == 0:
        for h in holes:
            paint_battens(d, h)
        moss(d, R["slate"], rng, 70, y_bias=100)
        # slipped slates: a few lighter, offset slates
        for _ in range(14):
            x, y = int(rng.integers(20, 360)), 56 + 12 * int(rng.integers(1, 7))
            d[y:y + 10, x:x + 14, :3][R["slate"][y:y + 10, x:x + 14]] = hx("56606a")
            d[y + 10:y + 12, x:x + 14, :3][R["slate"][y + 10:y + 12, x:x + 14]] = hx("1e2230")
        # chimney: top courses broken, no cap
        d[18:30, 290:330, 3] = 0
        for x in range(290, 330):
            top = 30 - (abs(x - 304) % 7)
            d[top:30, x, :3] = d[34, x, :3] if d[34, x, 3] else INK
            d[top:30, x, 3] = d[34, x, 3]
    elif stage == 1:
        moss(d, R["slate"], rng, 40, y_bias=110)
        for i, h in enumerate(holes):
            ys, xs = np.nonzero(h)
            x0, x1, y0, y1 = xs.min() - 4, xs.max() + 5, ys.min() - 2, ys.max() + 3
            if i == 1:   # a weighted canvas tarp
                for y in range(y0, y1):
                    for x in range(x0, x1):
                        if R["slate"][y, x]:
                            fold = ((x - x0) // 9) % 2
                            d[y, x, :3] = CANVAS[1 + fold + (1 if y < y0 + 3 else 0)]
                d[y0:y1, x0, :3] = INK
                d[y0:y1, x1 - 1, :3] = INK
                d[y0, x0:x1, :3] = INK
                d[y1 - 1, x0:x1, :3] = INK
                for x in (x0 + 6, x1 - 8):
                    d[y1 - 4:y1 + 1, x:x + 4, :3] = hx("6a6a64")   # stones holding it down
            else:        # tarred planks nailed over the hole, running down the slope
                sub = np.zeros((H, W, 4), np.uint8)
                planks(sub, x0, y0, x1, y1, TAR, horizontal=False, gap=1, w=8)
                sel = (sub[..., 3] > 0) & R["slate"]
                d[sel] = sub[sel]
    elif stage == 2:
        moss(d, R["slate"], rng, 10, y_bias=130)
        # new slate where the holes were: a fresher, bluer tone of the same courses; one old patch remains
        for i, h in enumerate(holes):
            if i == 2:
                sub = np.zeros((H, W, 4), np.uint8)
                ys, xs = np.nonzero(h)
                planks(sub, xs.min() - 2, ys.min(), xs.max() + 3, ys.max() + 2, TAR, horizontal=False, w=8)
                sel = (sub[..., 3] > 0) & R["slate"]
                d[sel] = sub[sel]
                continue
            grow = h.copy()
            for _ in range(3):
                grow[1:] |= grow[:-1]
                grow[:, 1:] |= grow[:, :-1]
                grow[:, :-1] |= grow[:, 1:]
            sel = grow & R["slate"]
            d[sel, :3] = np.clip(d[sel, :3].astype(int) * np.array([0.98, 1.04, 1.12]) + 6, 0, 255).astype(np.uint8)
    # --- walls ---
    wall = R["wall"]
    if stage <= 1:
        a = 0.7 if stage == 0 else 0.4
        ys, xs = np.nonzero(wall)
        for y, x in zip(ys, xs):
            d[y, x, :3] = blend(d[y, x, :3], to_ramp(d[y, x, :3], GREY), a)
        # rot: dark streaks running down from under the windows and the eave
        for sx in ([86, 104, 280, 296, 40, 340] if stage == 0 else [96, 290]):
            ln = int(rng.integers(18, 40))
            y0 = 253 if 60 < sx < 320 else 164
            for y in range(y0, min(y0 + ln, WALL_Y1)):
                for x in range(sx, sx + int(rng.integers(2, 5))):
                    if wall[y, x]:
                        d[y, x, :3] = (d[y, x, :3].astype(int) * 0.62).astype(np.uint8)
    if stage == 0:
        # a broken log: a gap with the dark interior showing, split ends either side
        y0 = WALL_Y0 + sum(COURSES[:5])
        h = COURSES[5]
        d[y0 + 2:y0 + h - 2, 128:156, :3] = hx("120e0c")
        d[y0 + 2:y0 + h - 2, 126:128, :3] = GREY[6]
        d[y0 + 2:y0 + h - 2, 156:158, :3] = GREY[5]
        d[y0 + 1, 132:150, :3] = GREY[4]
    if stage == 1:
        # the broken log braced with two vertical boards nailed across it
        y0 = WALL_Y0 + sum(COURSES[:4])
        sub = np.zeros((H, W, 4), np.uint8)
        planks(sub, 128, y0, 160, y0 + 46, FRESH, horizontal=False, gap=2, w=7)
        sel = sub[..., 3] > 0
        d[sel] = sub[sel]
    if stage == 2:
        # replaced logs: fresh timber runs in three courses
        for ci, xa, xb in ((5, 122, 166), (2, 26, 72), (6, 312, 358)):
            y0 = WALL_Y0 + sum(COURSES[:ci])
            for y in range(y0, y0 + COURSES[ci]):
                for x in range(xa, xb):
                    if wall[y, x]:
                        d[y, x, :3] = to_ramp(d[y, x, :3], FRESH)
    # --- windows ---
    wins = m0.A["windows"]
    if stage == 0:
        w = wins[0]
        g = R["win"]
        for y in range(w["y"][0] + 6, w["y"][1] - 6):
            for x in range(w["x"][0] + 6, w["x"][1] - 6):
                d[y, x, :3] = hx("16120f")
        for k in range(26):   # cracks and the last shards
            x = w["x"][0] + 8 + k
            y = w["y"][0] + 8 + (k * 7) % 22
            d[y, x, :3] = hx("6e8088")
        w = wins[1]   # the right window half boarded with two crossed boards
        for y in range(w["y"][0] + 6, w["y"][1] - 6):
            for x in range(w["x"][0] + 6, w["x"][1] - 6):
                d[y, x, :3] = hx("16120f")
        planks(d, w["x"][0] - 2, w["y"][0] + 2, w["x"][1] + 2, w["y"][1] - 2, GREY, angle=0.75, w=7)
        planks(d, w["x"][0] - 2, w["y"][0] + 18, w["x"][1] + 2, w["y"][1] + 2, GREY, angle=-0.6, w=6)
    if stage == 1:
        for w in wins:
            planks(d, w["x"][0] - 3, w["y"][0] + 2, w["x"][1] + 3, w["y"][1] - 1, FRESH, horizontal=True, gap=2, w=8)
        # at night, lamplight leaks between the boards
        n = d.copy()
        for w in wins:
            for y in range(w["y"][0] + 2, w["y"][1] - 1):
                if (y - (w["y"][0] + 2)) % 10 >= 8:
                    n[y, w["x"][0] + 6:w["x"][1] - 6, :3] = m0.LANTERN[2]
    # --- door ---
    door = R["door"]
    if stage == 0:
        ys, xs = np.nonzero(door)
        for y, x in zip(ys, xs):
            d[y, x, :3] = blend(d[y, x, :3], to_ramp(d[y, x, :3], GREY), 0.7)
        # hanging off its top hinge: a dark wedge at the top right
        for y in range(224, 246):
            for x in range(211 - (246 - y) // 2, 211):
                d[y, x, :3] = hx("0e0b09")
    if stage == 1:
        dx0, dx1 = m0.A["door"]["x"]
        for y in range(230, 292):   # a Z brace across the leaf
            x = int(dx0 + (dx1 - dx0) * (y - 230) / 62)
            d[y, max(dx0, x - 3):min(dx1, x + 3), :3] = FRESH[6]
            d[y, min(dx1 - 1, x + 3), :3] = FRESH[2]
    if stage <= 1:
        n[door] = d[door]
    # --- steps and foundation ---
    st = R["steps"]
    if stage == 0:
        d[300:309, 186:206, :3] = hx("120e0c")   # a missing tread
        for k in range(14):
            d[310 + k % 9, 170 + k * 3, :3] = INK
        for y, x in zip(*np.nonzero(R["found"])):
            if rng.random() < 0.05:
                d[y, x, :3] = INK
    if stage == 1:
        planks(d, 182, 299, 210, 308, FRESH, horizontal=True, w=8, gap=1)
    # --- vines, weeds, debris, dressing ---
    if stage == 0:
        for x, y, ln in ((20, 296, 120), (30, 290, 80), (360, 296, 100), (226, 296, 60), (122, 296, 50)):
            vine(d, x, y, ln, rng)
        tufts(d, 319, list(range(10, 160, 9)) + list(range(226, 380, 9)), rng, tall=10)
        planks(d, 236, 306, 290, 312, GREY, angle=0.08, w=5)   # a fallen board
    elif stage == 1:
        for x, y, ln in ((20, 296, 50), (362, 296, 40)):
            vine(d, x, y, ln, rng)
        tufts(d, 319, list(range(14, 150, 17)) + list(range(240, 376, 17)), rng, tall=7)
    elif stage == 2:
        tufts(d, 319, [20, 70, 250, 330, 372], rng, tall=4)
    elif stage == 3:
        for w in wins:   # flower boxes under both sills
            x0, x1 = w["x"][0] - 2, w["x"][1] + 2
            y0 = w["y"][1] + 5
            d[y0:y0 + 9, x0:x1, :3] = LOG_A[5]
            d[y0, x0:x1, :3] = LOG_A[7]
            d[y0 + 8, x0:x1, :3] = LOG_A[2]
            d[y0:y0 + 9, x0, :3] = INK
            d[y0:y0 + 9, x1 - 1, :3] = INK
            for x in range(x0 + 2, x1 - 2):
                for j in range(int(rng.integers(4, 10))):
                    yy = y0 - j
                    c = VINE[2 + (j % 2)] if j < 2 or (x % 5 == 0 and rng.random() < 0.5) else FLOWER[(x // 5 + j // 3) % 4]
                    d[yy, x, :3] = c
        # a firewood stack between the west window and the door, end grain out
        for row, (cy, xs) in enumerate(((292, range(132, 162, 8)), (285, range(136, 160, 8)), (278, range(140, 156, 8)))):
            for x in xs:
                end_grain(d, x, cy, 4.2, 3.6, False)
        # pots by the steps
        for px in (152, 226):
            d[306:318, px:px + 10, :3] = hx("8a4a2a")
            d[306, px:px + 10, :3] = hx("a8643a")
            d[306:318, px, :3] = INK
            d[306:318, px + 9, :3] = INK
            d[317, px:px + 10, :3] = INK
            d[306:318, px:px + 10, 3] = 255
            for k in range(14):
                d[300 + k % 6, px + 1 + (k * 3) % 8, :3] = FLOWER[k % 4] if k % 3 else VINE[3]
                d[300 + k % 6, px + 1 + (k * 3) % 8, 3] = 255
    # copy all day changes into the night image, except the glass that is lit at night
    keep = glass_diff if lit_glass else np.zeros_like(glass_diff)
    if stage == 1:
        keep = (n != d).any(axis=2) & np.isin(lab0, [LID["glass"], LID["mullion"], LID["window_frame"], 0, LID["wall"]]) & (np.arange(W)[None, :] > 60)
        keep &= (np.arange(H)[:, None] >= 200) & (np.arange(H)[:, None] <= 252)
    changed = (d != log_day).any(axis=2) & ~keep
    n[changed] = d[changed]
    return d, n


def main():
    rng = np.random.default_rng(23)
    lab0 = m0.build_labels()
    rlab = np.array(Image.open(os.path.join(SA, "labels_roof.png")))
    sa_day = np.array(Image.open(os.path.join(SA, "32", "house_day.png")).convert("RGBA"))
    sa_night = np.array(Image.open(os.path.join(SA, "32", "house_night.png")).convert("RGBA"))
    log_day = build_log(sa_day, lab0, rng)
    log_night, glass_diff = night_from(log_day, sa_day, sa_night)
    out = {"log": (log_day, log_night)}
    for s in range(4):
        out["st%d" % s] = make_stage(s, log_day, log_night, glass_diff, lab0, rlab, 100 + s)
    metrics = {}
    a0 = sa_day[..., 3] > 0
    for k, (d, n) in out.items():
        p = os.path.join(G5, k, "32")
        os.makedirs(p, exist_ok=True)
        Image.fromarray(d, "RGBA").save(os.path.join(p, "house_day.png"))
        Image.fromarray(n, "RGBA").save(os.path.join(p, "house_night.png"))
        a = d[..., 3] > 0
        metrics[k] = {"opaque_px": int(a.sum()), "added_vs_sa": int((a & ~a0).sum()), "removed_vs_sa": int((a0 & ~a).sum()),
                      "colours": int(len(np.unique(d[a][:, :3], axis=0)))}
    metrics["sa"] = {"opaque_px": int(a0.sum()), "colours": int(len(np.unique(sa_day[a0][:, :3], axis=0)))}
    with open(os.path.join(G5, "s2_metrics.json"), "w") as f:
        json.dump(metrics, f, indent=1)
    print(json.dumps(metrics))


if __name__ == "__main__":
    main()
