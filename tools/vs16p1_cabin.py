"""ART-005 VS16-P1 (zero-generation, NON-PRODUCTION): one bounded artistic finishing pass on the VS16 restored cabin.

A separate, reversible variant. tools/vs16_cabin.py and art/style_tests/ART-005/vs16/ are left unchanged; this file
started as a copy of that generator and only these parts are redrawn, on the same 192 x 160 canvas, footprint,
silhouette, door and window rectangles, chimney and footing:

  * roof: hand-laid shakes. Each shake has its own width and butt line (some hang a pixel lower, some sit a pixel
    short, a few have a worn corner). Courses are painted from the eave up, so every butt really overlaps the course
    below and casts its own one-step shadow there, instead of a uniform black "mortar" row. Joints are soft (one or
    two steps darker, not every one full length). Value comes from one broad light field (lighter toward the upper
    left key light, a slow drift across the roof), a warm-brown and a silvered zone, not per-pixel noise.
  * door: a wooden casing with depth (lit left board, shadowed rebate, lit right board) instead of a black frame;
    four planks of different widths with long, slightly kinked grain; two battens carrying iron strap hinges; a
    brass thumb latch; a threshold board on the upper step; the lintel log keeps its place.
  * foundation: fieldstones of mixed sizes (a few tall stones spanning the footing, smaller ones stacked), warm,
    neutral and cool greys, recessed dark mortar instead of outline black, lit upper-left clusters, a shadow under
    the logs and darker contact at the ground.
  * windows: a frame with depth (lit casing, recessed sash: the top and left reveals in shadow, the bottom and right
    reveals lit); day glass in a blue-grey ramp with one restrained diagonal sky glare; night glass graded per pane
    (lower panes and the panes toward the room's middle brighter), backlit dark muntins and warm spill on the reveals.
  * logs: the corner log ends get end grain (a pith and a ring arc) in the wall's own ramp, the left corner casts a
    one-pixel shadow onto the wall, and the repeated two-pixel axe-check ticks are removed.

    python tools/vs16p1_cabin.py   -> art/style_tests/ART-005/vs16p1/cabin/house_{day,night}.png (+ palette.png)
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "art/style_tests/ART-005/vs16p1/cabin"
W, H = 192, 160

# ---- VS16's draft palette (unchanged) ----
OL = (24, 17, 16)
L = [(52, 36, 30), (82, 59, 42), (110, 82, 57), (136, 104, 72), (160, 126, 87), (184, 152, 108), (206, 178, 130)]
CH = (38, 27, 25)
R = [(30, 23, 20), (42, 32, 27), (54, 42, 33), (64, 50, 38), (77, 60, 45), (93, 73, 53)]
RW = [(70, 58, 47), (84, 70, 56)]
M = [(46, 52, 36), (64, 72, 42), (88, 96, 52)]
T = [(58, 40, 33), (84, 59, 44), (112, 81, 56), (140, 104, 70)]
S = [(46, 40, 37), (76, 67, 58), (104, 93, 80), (132, 121, 104), (162, 151, 130)]
G = [(27, 30, 41), (44, 52, 70), (72, 88, 108), (140, 156, 166)]
N = [(112, 46, 20), (196, 118, 46), (242, 182, 92), (255, 228, 164)]
D = [(66, 45, 34), (96, 68, 47), (120, 88, 60), (144, 108, 73)]
BR, BR2, IR = (184, 150, 96), (122, 96, 60), (50, 46, 50)

# ---- P1 additions (each a short ramp, dark -> light) ----
RA = [(36, 26, 21), (48, 36, 28), (60, 45, 34), (72, 55, 40), (86, 66, 47), (102, 78, 55)]     # sun-warmed shakes
RWX = [R[1], RW[0], RW[1], (100, 86, 70)]                                                      # silvered shakes
D2 = [(46, 32, 25), (66, 45, 34), (96, 68, 47), (120, 88, 60), (144, 108, 73), (166, 128, 86)]  # door planks
SW = [(50, 40, 34), (82, 68, 56), (112, 96, 78), (140, 124, 102), (170, 154, 128)]               # warm fieldstone
SC = [(42, 41, 44), (70, 69, 71), (96, 95, 96), (124, 123, 120), (152, 151, 144)]                # cool fieldstone
MORTAR = (40, 34, 32)
GP = [(30, 34, 46), (44, 54, 72), (56, 70, 92), (70, 88, 108), (104, 124, 140), (156, 172, 178)]  # day glass
NP = [(92, 40, 20), (146, 72, 30), (200, 124, 50), (236, 170, 80), (250, 206, 124), (255, 234, 178)]  # lit glass
IRL = (104, 98, 98)                                                                              # nail head glint
RAMPS = [R, RA, RWX, M, L, D2, S, SW, SC, GP, NP, T]


def hsh(x, y, s=0):
    v = (x * 374761393 + y * 668265263 + s * 2246822519) & 0xFFFFFFFF
    v = ((v ^ (v >> 13)) * 1274126177) & 0xFFFFFFFF
    return (v ^ (v >> 16)) / 0xFFFFFFFF


def vnoise(x, y, cell, seed):
    gx, gy = x / cell, y / cell
    ix, iy = int(gx), int(gy)
    fx, fy = gx - ix, gy - iy
    u, v = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b, c, d = hsh(ix, iy, seed), hsh(ix + 1, iy, seed), hsh(ix, iy + 1, seed), hsh(ix + 1, iy + 1, seed)
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v


def step(c, k):
    """The colour k steps lighter (k > 0) or darker (k < 0) on whichever ramp holds c."""
    for ramp in RAMPS:
        if c in ramp:
            return ramp[max(0, min(len(ramp) - 1, ramp.index(c) + k))]
    return c


def build(night: bool) -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = im.load()

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            px[x, y] = tuple(c[:3]) + (255,)

    def get(x, y):
        return px[x, y][:3] if 0 <= x < W and 0 <= y < H and px[x, y][3] else None

    def rect(x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                put(x, y, c)

    def hline(x0, x1, y, c):
        rect(x0, y, x1, y, c)

    def shade(x, y, k):
        c = get(x, y)
        if c is not None and c != OL:
            put(x, y, step(c, k))

    def darken(x, y, ramp, steps=1):
        c = get(x, y)
        if c in ramp:
            put(x, y, ramp[max(0, ramp.index(c) - steps)])

    # =========================== ROOF (rows 21..80, C2's silhouette and chamfers: unchanged) ===========================
    span = {21: (3, 188), 22: (2, 189), 23: (2, 189), 24: (1, 190)}
    for y in range(21, 81):
        x0, x1 = span.get(y, (0, 191) if y >= 77 else (1, 190))
        hline(x0, x1, y, OL)

    # Ridge cap: two boards, lit on top, broadly lighter toward the key light (left) than the far end.
    for x in range(4, 188):
        far = x > 118
        put(x, 22, T[3] if not far or hsh(x // 6, 22, 1) > 0.5 else T[2])
    hline(3, 188, 23, T[2])
    hline(3, 188, 24, T[1])
    hline(2, 189, 25, R[0])
    for x in range(14, 186, 29):
        put(x, 23, T[1]); put(x, 24, T[0])

    # Shake field. Seven courses (VS16's), painted from the eave UP so each butt overlaps the course below.
    top, bottom = 26, 72
    heights = [6, 7, 6, 7, 6, 7, 7]
    courses, y = [], top
    for h in heights:
        courses.append((y, y + h - 1))
        y += h
    rect(3, top, 188, bottom, R[1])
    hline(3, 188, bottom, R[0])

    def light(x, y):                         # one broad field: key light from the upper left, a slow drift
        return 0.12 + 0.30 * (1 - x / 191) + 0.10 * (y - top) / (bottom - top) + 0.30 * vnoise(x + 7, y * 2.2, 56, 70) + 0.08

    def silvered(x, y):                      # two soft weathered zones, decided per shake (no speckle)
        best = 0.0
        for cx, cy, rx, ry in ((124, 60, 22, 8), (58, 34, 10, 4)):
            d = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            best = max(best, 1 - d)
        return best

    def warm(x, y):                          # a broad sun-warmed zone on the lit left half
        return vnoise(x, y * 2, 64, 77) > 0.58 and x < 120 and hsh(int(x), int(y), 78) > 0.45

    for ci in reversed(range(len(courses))):
        y0, y1 = courses[ci]
        x = 3 - int(hsh(ci, 1, 60) * 9)
        while x < 189:
            w = 5 + int(hsh(x, ci, 61) ** 0.7 * 7)                   # 5..11 px, most 8..10
            xa, xb = max(x, 3), min(x + w - 1, 188)                  # xb is the joint column
            cx, cy = (xa + xb) / 2, (y0 + y1) / 2
            lv = light(cx, cy) + (hsh(x, ci, 62) - 0.5) * 0.20
            ti = 2 if lv < 0.40 else 3 if lv < 0.66 else 4
            ramp = RA if warm(cx, cy) else R
            if silvered(cx, cy) > 0.25 + 0.55 * hsh(x, ci, 64):
                ramp, ti = RWX, (1 if ti <= 3 else 2)
            body = ramp[ti]
            r = hsh(x, ci, 65)
            drop = 1 if r < 0.26 else (-1 if r > 0.90 and ci > 0 else 0)
            yb = min(y1 + drop, bottom)                               # this shake's butt row
            rect(xa, y0, xb - 1, yb - 1, body)
            # the butt: lit edge; the brightest few, only where the field is lit, catch the top step (clustered)
            lit = step(body, 2 if (lv > 0.62 and hsh(x, ci, 66) > 0.40) else 1)
            hline(xa, xb - 1, yb, lit)
            if hsh(x, ci, 67) > 0.72 and xb - xa >= 6:              # a worn lower corner
                put(xb - 1, yb, step(body, -1))
            elif hsh(x, ci, 68) > 0.85 and xb - xa >= 6:            # or a butt that tapers a pixel at its left end
                put(xa, yb, step(body, -1))
            # the joint: a soft gap, darker near the top (in the shadow of the butt above), not always full length
            jl = (yb - y0) if hsh(x, ci, 69) > 0.35 else max(2, (yb - y0) // 2)
            for yy in range(y0, y0 + jl):
                put(xb, yy, step(body, -2 if yy < y0 + 2 else -1))
            if y0 + jl < yb:
                for yy in range(y0 + jl, yb + 1):
                    put(xb, yy, body if yy < yb else lit)
            # a grain split in some wide shakes, two or three pixels, one step darker
            if xb - xa >= 8 and hsh(x, ci, 70) > 0.62:
                sx = xa + 2 + int(hsh(x, ci, 71) * (xb - xa - 4))
                for yy in range(y0 + 2, min(yb - 1, y0 + 5)):
                    put(sx, yy, step(body, -1))
            # the butt's own shadow on the course below (already painted): one step, two under the joint
            if yb + 1 <= bottom:
                for xx in range(xa, xb + 1):
                    shade(xx, yb + 1, -3)
                    if yb + 2 <= bottom and hsh(xx // 3, ci, 72) > 0.25:   # a softer second row, broken here and there
                        shade(xx, yb + 2, -1)
            x += w
    # The ridge cap shades the first course's top row.
    for xx in range(3, 189):
        shade(xx, top, -1)

    # Moss: two soft clusters, low on the lower left and in the chimney's lee, following the courses' shadow rows.
    for cx, cy, rx, ry, seed in ((26, 68, 9, 3, 1), (170, 37, 4, 2, 3)):
        for yy in range(cy - ry - 1, cy + ry + 2):
            for xx in range(cx - rx - 1, cx + rx + 2):
                d = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
                c = get(xx, yy)
                if c is None or c == OL or yy > bottom or yy < top:
                    continue
                n = hsh(xx // 2, yy // 2, seed)
                if d < 0.45 + 0.4 * n:
                    put(xx, yy, M[1] if sum(c) > 170 else M[0])

    # Verge boards: lit on the left, shaded on the right (VS16's).
    for yy in range(25, 73):
        put(2, yy, T[2]); put(3, yy, T[1])
        put(189, yy, T[0]); put(188, yy, R[0])
    put(2, 25, T[3])

    # Fascia and soffit (VS16's), with the board lit a little more toward the key light.
    hline(1, 190, 73, OL)
    hline(2, 189, 74, T[3])
    hline(1, 190, 75, T[2])
    hline(1, 190, 76, T[1])
    hline(0, 191, 77, OL)
    hline(1, 190, 78, T[0])
    hline(1, 190, 79, R[0])
    hline(0, 191, 80, OL)
    for x in range(22, 190, 37):
        put(x, 74, T[1]); put(x, 75, T[1]); put(x, 76, T[0])
    for x in range(8, 190, 12):
        put(x, 75, T[1])
    for x in range(120, 190):
        if hsh(x // 5, 74, 2) > 0.5:
            put(x, 74, T[2])

    # =========================== CHIMNEY (x 146..164, y 10..32: VS16's) ===========================
    for yy in range(26, 40):
        for xx in range(163, 171 - max(0, yy - 33)):
            shade(xx, yy, -1)
    for xx in range(147, 165):
        shade(xx, 33, -2); shade(xx, 34, -1)
    rect(146, 10, 164, 14, OL)
    hline(147, 163, 11, S[4])
    hline(147, 163, 12, S[3])
    hline(147, 163, 13, S[1])
    put(147, 11, S[3])
    rect(148, 14, 162, 32, OL)
    rows = [(15, 18), (19, 22), (23, 26), (27, 29), (30, 32)]
    for ri, (a, b) in enumerate(rows):
        x = 149 + (0 if ri % 2 else -2)
        while x < 162:
            w = 5 + int(hsh(x, ri, 20) * 4)
            x0, x1 = max(x, 149), min(x + w - 2, 161)
            if x1 >= x0:
                rect(x0, a, x1, b, S[2] if hsh(x, ri, 21) > 0.3 else S[1])
                hline(x0, x1 - 1, a, S[3])
                put(x0, a, S[4]) if x1 - x0 >= 3 else None
                hline(x0, x1, b, S[0])
                for yy in range(a, b + 1):
                    put(x1, yy, S[0])
                put(x1 - 1, b - 1, S[1])
            x += w
    for yy in range(15, 18):
        for xx in range(149, 162):
            c = get(xx, yy)
            if c in S:
                put(xx, yy, S[max(0, S.index(c) - 1)])
    hline(149, 160, 15, S[1])

    # =========================== LOG WALLS (rows 81..140: VS16's, minus the axe-check ticks) ===========================
    seams = [81, 87, 94, 102, 109, 117, 124, 132, 140]
    rect(9, 81, 182, 140, L[3])
    for i in range(len(seams) - 1):
        t, b = seams[i], seams[i + 1]
        rows = list(range(t + 1, b))
        n = len(rows)
        tone = 0 if hsh(i, 0, 30) > 0.25 else -1
        ramp = {5: [5, 4, 3, 2, 1], 6: [5, 4, 3, 3, 2, 1], 7: [5, 4, 4, 3, 3, 2, 1]}[n]
        for k, yy in enumerate(rows):
            hline(9, 182, yy, L[max(1, ramp[k] + tone)])
        hline(9, 182, b, CH)
        x = 10 + int(hsh(i, 1, 31) * 8)
        while x < 178:
            r = hsh(x, i, 32)
            ln = 3 + int(hsh(x, i, 33) * 6)
            if r < 0.30:
                yy = rows[min(n - 2, 2 + int(hsh(x, i, 34) * (n - 3)))]
                base = get(x, yy)
                dk = L[max(0, L.index(base) - 1)] if base in L else L[1]
                hline(x, min(x + ln, 181), yy, dk)
            elif r < 0.42:
                yy = rows[1]
                base = get(x, yy)
                lt = L[min(6, L.index(base) + 1)] if base in L else L[5]
                hline(x, min(x + max(2, ln - 3), 181), yy, lt)
            elif r < 0.455 and n >= 6:
                kx, ky = x, rows[2]
                put(kx, ky, L[0]); put(kx + 1, ky, L[1]); put(kx, ky + 1, L[1])
                put(kx - 1, ky, L[2]); put(kx + 2, ky + 1, L[2])
            x += ln + 3 + int(hsh(x, i, 35) * 9)

    for xx in range(9, 183):
        for yy in range(82, 86):
            darken(xx, yy, L, 2 if yy < 84 else 1)
    hline(9, 182, 81, CH)

    # Corner log ends (VS16's stack and jog), now with end grain in the wall's ramp: a lit rim, a ring arc and a
    # pith; the left stack casts a one-pixel shadow onto the wall (the key light is upper left).
    for i in range(len(seams) - 1):
        t, b = seams[i] + (1 if i == 0 else 0), seams[i + 1]
        jog = i % 2
        for x0, x1, lit_side in ((3 + jog, 9 + jog, True), (182 - jog, 188 - jog, False)):
            rect(x0, t, x1, b, OL)
            body = L[4] if lit_side else L[3]
            rect(x0 + 1, t + 1, x1 - 1, b - 1, body)
            hline(x0 + 1, x1 - 2, t + 1, step(body, 1))
            for yy in range(t + 1, b):
                put(x0 + 1, yy, step(body, 1) if yy < b - 1 else body)
                put(x1 - 1, yy, step(body, -2))
            hline(x0 + 2, x1 - 1, b - 1, step(body, -2))
            cx, cy = (x0 + x1) // 2, (t + b) // 2
            put(cx, cy, step(body, -3))                                # pith
            put(cx - 1, cy - 1, step(body, -1)); put(cx + 1, cy + 1, step(body, -1))   # a ring arc
            if b - t >= 7:
                put(cx, cy - 2, step(body, -1))
            for cxx, cyy in ((x0, t), (x1, t), (x0, b), (x1, b)):
                px[cxx, cyy] = (0, 0, 0, 0)
            if i == 0:
                shade(x0 + 1, t + 1, -1)
            if lit_side:                                              # shadow on the wall beside the stack
                for yy in range(t + 1, b):
                    shade(x1 + 1, yy, -1)

    # =========================== WINDOWS (x 37..59 / 132..154, y 101..126: same rectangles) ===========================
    for wi, (wx0, wx1) in enumerate(((37, 59), (132, 154))):
        y0, y1 = 101, 126
        rect(wx0, y0, wx1, y1, OL)
        # casing: lit top and left, a mid body, shaded right and bottom
        rect(wx0 + 1, y0 + 1, wx1 - 1, y1 - 1, L[3])
        hline(wx0 + 1, wx1 - 1, y0 + 1, L[5])
        hline(wx0 + 2, wx1 - 2, y0 + 2, L[4])
        for yy in range(y0 + 1, y1):
            put(wx0 + 1, yy, L[4]); put(wx1 - 1, yy, L[1]); put(wx1 - 2, yy, L[2])
        put(wx0 + 1, y0 + 1, L[5])
        hline(wx0 + 2, wx1 - 1, y1 - 1, L[1])
        hline(wx0 + 2, wx1 - 2, y1 - 2, L[2])
        gx0, gy0, gx1, gy1 = wx0 + 4, y0 + 4, wx1 - 4, y1 - 4
        # the recessed sash: top and left reveals in shadow, bottom and right reveals catch the light
        hline(gx0 - 1, gx1 + 1, gy0 - 1, OL)
        for yy in range(gy0 - 1, gy1 + 2):
            put(gx0 - 1, yy, OL)
        hline(gx0, gx1 + 1, gy1 + 1, L[4] if not night else (176, 124, 72))
        for yy in range(gy0, gy1 + 2):
            put(gx1 + 1, yy, L[4] if not night else (176, 124, 72))
        put(gx1 + 1, gy0 - 1, L[2])
        mx, my = (gx0 + gx1) // 2, (gy0 + gy1) // 2
        panes = [(gx0, gy0, mx - 1, my - 1), (mx + 1, gy0, gx1, my - 1), (gx0, my + 1, mx - 1, gy1), (mx + 1, my + 1, gx1, gy1)]
        for pi, (qx0, py0, qx1, py1) in enumerate(panes):
            pw, ph = qx1 - qx0, py1 - py0
            if night:
                # lower panes and the panes toward the room's middle (the door side) burn brighter
                inner = (pi % 2 == 1) if wi == 0 else (pi % 2 == 0)
                base = (0.40 if pi < 2 else 0.64) + (0.12 if inner else 0.0)
                for yy in range(py0, py1 + 1):
                    for xx in range(qx0, qx1 + 1):
                        fy = (yy - py0) / max(1, ph)
                        fx = abs((xx - qx0) / max(1, pw) - (0.65 if inner == (wi == 0) else 0.35))
                        v = base + 0.30 * fy - 0.30 * fx
                        k = 1 if v < 0.25 else 2 if v < 0.48 else 3 if v < 0.70 else 4 if v < 0.86 else 5
                        put(xx, yy, NP[k])
                hline(qx0, qx1, py0, NP[1])                             # the sash rail shades the top row
                for yy in range(py0, py1 + 1):
                    put(qx0, yy, NP[1] if yy > py0 else NP[0])
            else:
                lighter = (pi == 1)                                    # one pane catches more sky
                for yy in range(py0, py1 + 1):
                    for xx in range(qx0, qx1 + 1):
                        put(xx, yy, GP[3] if (lighter and yy <= py0 + ph // 2) else GP[2] if yy <= py0 + ph // 2 + (1 if lighter else 0) else GP[1])
                hline(qx0, qx1, py0, GP[0])
                for yy in range(py0, py1 + 1):
                    put(qx0, yy, GP[0] if yy < py0 + ph // 2 else GP[1])
        if not night:
            # one restrained sky glare: a diagonal running across the panes (behind the muntins), core and fringe
            for yy in range(gy0 + 1, gy1 + 1):
                for xx in range(gx0 + 1, gx1 + 1):
                    if xx == mx or yy == my:
                        continue
                    u = (xx - gx0) + (yy - gy0)
                    if u == 12:
                        put(xx, yy, GP[5] if yy < my else GP[4])
                    elif u in (11, 13):
                        put(xx, yy, GP[4] if yy < my else GP[3])
                    elif u == 19 and yy < my + 3:
                        put(xx, yy, GP[4] if yy < my else GP[3])
        # muntins: wood by day; backlit and dark at night
        mc = L[3] if not night else L[1]
        hline(gx0, gx1, my, mc)
        for yy in range(gy0, gy1 + 1):
            put(mx, yy, mc)
        put(mx, my, L[4] if not night else L[2])
        # sill: a lit top, a front face, an outline, and its cast shadow on the log below (VS16's)
        hline(wx0 - 2, wx1 + 2, y1 + 1, L[5])
        hline(wx0 - 1, wx1 + 2, y1 + 2, L[2])
        hline(wx0 - 2, wx1 + 2, y1 + 3, OL)
        put(wx0 - 2, y1 + 2, OL); put(wx1 + 2, y1 + 2, OL)
        put(wx0 - 1, y1 + 1, L[6])
        for xx in range(wx0 - 1, wx1 + 3):
            darken(xx, y1 + 4, L, 2)
        if night:                                                     # warm spill on the sill, stronger mid-window
            for xx in range(gx0, gx1 + 1):
                put(xx, y1 + 1, (226, 170, 104) if abs(xx - mx) < 5 else (204, 156, 100))
            put(gx0 - 2, gy1, (150, 104, 62)); put(gx1 + 2, gy1, (150, 104, 62))
            put(gx0 - 2, gy1 - 1, (128, 90, 58)); put(gx1 + 2, gy1 - 1, (128, 90, 58))

    # =========================== DOOR (x 84..107, y 108..148: same rectangle) ===========================
    x0, y0, x1, y1 = 84, 108, 107, 148
    # hewn lintel log (VS16's place), with a little grain and a lit end
    rect(x0 - 3, y0 - 4, x1 + 3, y0, OL)
    hline(x0 - 2, x1 + 2, y0 - 3, L[5])
    hline(x0 - 2, x1 + 2, y0 - 2, L[4])
    hline(x0 - 2, x1 + 2, y0 - 1, L[2])
    hline(x0 + 4, x0 + 8, y0 - 2, L[3]); hline(x0 + 14, x0 + 19, y0 - 2, L[3]); put(x1, y0 - 3, L[6])
    put(x0 - 2, y0 - 3, L[6])
    rect(x0, y0 + 1, x1, y1, OL)
    # casing boards with depth: left board lit, right board catching the light on its left edge
    for yy in range(y0 + 1, y1 - 1):
        put(x0 + 1, yy, L[5]); put(x0 + 2, yy, L[4])
        put(x1 - 2, yy, L[4]); put(x1 - 1, yy, L[2])
    hline(x0 + 1, x1 - 1, y0 + 1, L[3])                           # head casing under the lintel's shadow
    hline(x0 + 1, x0 + 2, y0 + 1, L[4])
    bx0, by0, bx1, by1 = x0 + 4, y0 + 3, x1 - 4, y1 - 2           # door leaf 88..103 x 111..146
    for yy in range(y0 + 1, y1 - 1):                                # rebate gaps: dark wood, not outline black
        put(bx0 - 1, yy, CH); put(bx1 + 1, yy, CH)
    hline(bx0 - 1, bx1 + 1, by0 - 1, CH)
    planks = [(bx0, bx0 + 3), (bx0 + 4, bx0 + 8), (bx0 + 9, bx0 + 11), (bx0 + 12, bx1)]   # 4, 5, 3, 4 px
    tones = [3, 2, 3, 2]
    for pi, (a, b) in enumerate(planks):
        base = D2[tones[pi]]
        rect(a, by0, b, by1, base)
        for yy in range(by0, by1 + 1):
            put(a, yy, step(base, 1))
            put(b, yy, step(base, -2) if pi < 3 else step(base, -1))
        for k in range(3):                                          # long grain, kinked once
            gx = a + 1 + int(hsh(pi, k, 40) * max(1, b - a - 1))
            gy = by0 + 3 + int(hsh(pi, k, 41) * 22)
            ln = 6 + int(hsh(pi, k, 42) * 8)
            for yy in range(gy, min(gy + ln, by1)):
                kx = gx + (1 if yy > gy + ln // 2 and gx + 1 < b else 0)
                put(kx, yy, step(base, -1))
    put(bx0 + 6, by0 + 23, D2[1]); put(bx0 + 7, by0 + 23, D2[0]); put(bx0 + 6, by0 + 24, D2[2])   # a knot
    for xx in range(bx0, bx1 + 1):                                  # the head casing's shadow on the leaf
        shade(xx, by0, -2); shade(xx, by0 + 1, -1)
    for yy in range(by0, by1 + 1):                                  # the left casing's shadow on the leaf
        shade(bx0, yy, -1)
    # two battens across the leaf, each carrying an iron strap hinge from the left jamb
    for ty in (by0 + 5, by1 - 9):
        hline(bx0, bx1, ty, D2[5]); hline(bx0, bx1, ty + 1, D2[4]); hline(bx0, bx1, ty + 2, D2[3])
        put(bx1, ty + 1, D2[2]); put(bx1, ty + 2, D2[2])
        for xx in range(bx0, bx1 + 1):
            shade(xx, ty + 3, -1)
        hline(bx0 - 1, bx0 + 8, ty + 1, IR)
        put(bx0 + 9, ty + 1, (70, 64, 66))
        put(bx0 + 2, ty + 1, IRL); put(bx0 + 6, ty + 1, IRL)
        put(x0 + 3, ty + 1, IR); put(x0 + 3, ty + 2, OL)            # the hinge knuckle on the jamb
    # brass thumb latch: an iron back plate, a lit brass grip
    lx = bx1 - 2
    for yy in range(126, 132):
        put(lx + 1, yy, IR)
    put(lx, 127, BR); put(lx, 128, BR); put(lx, 129, BR2); put(lx - 1, 127, (226, 196, 128)); put(lx, 130, OL)
    put(lx + 1, 125, IRL)
    # threshold board on the upper step, lit on top
    hline(x0 + 1, x1 - 1, y1 - 1, L[5])
    hline(x0 + 1, x1 - 1, y1, L[2])
    put(x0 + 1, y1 - 1, L[6])

    # =========================== WALL LAMP (VS16's, unlit at night as C2's) ===========================
    put(114, 111, IR); put(114, 112, IR); hline(113, 115, 111, OL)
    rect(112, 113, 116, 120, OL)
    rect(113, 114, 115, 118, G[1])
    if not night:
        put(113, 114, G[2])
    hline(113, 115, 119, IR)
    hline(112, 116, 112, OL)

    # =========================== FOUNDATION (x 6..185, y 141..149: same footprint) ===========================
    rect(6, 141, 185, 149, OL)
    fx0, fx1, fy0, fy1 = 7, 184, 141, 148
    lab = {}
    stones = []

    def stone(xa, xb, ya, yb):
        sid = len(stones)
        stones.append((xa, xb, ya, yb))
        for yy in range(ya, yb + 1):
            for xx in range(xa, xb + 1):
                lab[(xx, yy)] = sid

    def band(a, b, ya, yb, wmin, wspan, seed):
        x = a
        while x <= b:
            w = wmin + int(hsh(x, ya, seed) * wspan)
            if b - (x + w) < wmin - 1:
                w = b - x + 1
            stone(x, min(x + w - 1, b), ya, yb)
            x += w

    x = fx0
    while x <= fx1:
        if hsh(x, 0, 80) < 0.58 and fx1 - x >= 7:                    # a big stone through the whole footing
            w = 7 + int(hsh(x, 0, 81) * 6)
            stone(x, x + w - 1, fy0, fy1)
            x += w
        else:                                                         # a run of smaller stones in two bands
            ln = min(8 + int(hsh(x, 0, 82) * 8), fx1 - x + 1)
            s = 144 if hsh(x, 0, 83) > 0.5 else 145
            band(x, x + ln - 1, fy0, s - 1, 4, 5, 84)
            band(x, x + ln - 1, s, fy1, 5, 5, 85)
            x += ln
    for sid, (xa, xb, ya, yb) in enumerate(stones):
        r = hsh(xa, ya, 86)
        ramp = SW if r < 0.36 else SC if r > 0.72 else S
        big = (xb - xa >= 7 and yb - ya >= 6)
        ti = 2 if hsh(xa, ya, 87) > 0.3 or big else 1
        body = ramp[ti]
        cells = []
        ly = yb if yb == fy1 else yb - 1                              # the right column and bottom row are mortar,
        lx = xb if xb == fx1 else xb - 1                              # except at the footing's own edges
        for yy in range(ya, ly + 1):
            for xx in range(xa, lx + 1):
                cut = ((xx, yy) in ((xa, ya), (lx, ya), (xa, ly), (lx, ly)))
                if big and ((xx, yy) in ((xa + 1, ya), (xa, ya + 1), (lx - 1, ya), (lx, ya + 1),
                                         (xa, ly - 1), (lx, ly - 1), (lx - 1, ly))):
                    cut = True
                if not cut:
                    cells.append((xx, yy))
        cs = set(cells)
        for xx, yy in cells:
            c = body
            if (xx, yy - 1) not in cs or (xx - 1, yy) not in cs:      # upper and left rim catch the light
                c = ramp[min(len(ramp) - 1, ti + 1)]
            if (xx, yy + 1) not in cs or (xx + 1, yy) not in cs:      # lower and right rim turn away
                c = ramp[max(0, ti - 1)]
            put(xx, yy, c)
        # a lit cluster on the upper left of the stone (2-4 px), the stone's one highlight
        hl = [(xx, yy) for xx, yy in cells if (xx, yy - 1) not in cs and (xx, yy + 1) in cs][:2 + (2 if big else 1)]
        for xx, yy in hl[1:]:
            put(xx, yy, ramp[min(len(ramp) - 1, ti + 2)])
    for (xx, yy), sid in lab.items():                               # mortar: recessed and dark, not outline black
        if get(xx, yy) == OL:
            put(xx, yy, MORTAR)
    for xx in range(fx0, fx1 + 1):                                  # the logs overhang the footing; ground contact
        shade(xx, 141, -2)
        if get(xx, 148) != MORTAR:
            shade(xx, 148, -1)
    for xx in range(fx0, fx1 + 1):
        if get(xx, 141) == MORTAR:
            put(xx, 141, OL)
    for mx_, wid in ((14, 3), (52, 2), (123, 3), (171, 2)):         # a little moss low on four stones
        for k in range(wid):
            if get(mx_ + k, 147) not in (MORTAR, None):
                put(mx_ + k, 147, M[1] if k else M[2])
        if get(mx_, 146) not in (MORTAR, None):
            put(mx_, 146, M[0])

    # =========================== STEPS (x 79..112, y 149..159: VS16's) ===========================
    rect(81, 149, 110, 153, OL)
    rect(82, 150, 109, 152, S[2])
    hline(82, 109, 150, S[3]); hline(83, 88, 150, S[4])
    hline(82, 109, 152, S[1])
    put(96, 150, S[1]); put(96, 151, S[1]); put(96, 152, S[0])
    rect(79, 154, 112, 159, OL)
    rect(80, 155, 111, 158, S[2])
    hline(80, 111, 155, S[3]); hline(81, 85, 155, S[4]); hline(100, 103, 155, S[4])
    hline(80, 111, 158, S[1])
    for xx in (89, 102):
        for yy in range(155, 159):
            put(xx, yy, S[1])
        put(xx, 158, S[0])
    hline(82, 109, 153, S[0])
    hline(x0 + 1, x1 - 1, 150, S[1])                               # the threshold's shadow on the upper step
    return im


def palette_strip() -> Image.Image:
    ramps = [("outline", [OL]), ("logs", L), ("chinking", [CH]), ("shakes", R), ("warm shakes", RA),
             ("silvered", RWX), ("moss", M), ("trim", T), ("stone", S), ("warm stone", SW), ("cool stone", SC),
             ("mortar", [MORTAR]), ("glass", GP), ("lit glass", NP), ("door", D2), ("metal", [BR2, BR, IR, IRL])]
    im = Image.new("RGBA", (8 * 8, len(ramps) * 8), (0, 0, 0, 0))
    for r, (_, cols) in enumerate(ramps):
        for i, c in enumerate(cols):
            for y in range(r * 8, r * 8 + 7):
                for x in range(i * 8, i * 8 + 7):
                    im.putpixel((x, y), c + (255,))
    return im


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, night in (("day", False), ("night", True)):
        im = build(night)
        im.save(OUT / f"house_{name}.png")
        cols = {c for c in im.getdata() if c[3]}
        print(name, im.size, len(cols), "colours")
    palette_strip().save(OUT / "palette.png")


if __name__ == "__main__":
    main()
