"""ART-005 HC1 Step 2 (zero-generation, non-production): EXPERIMENTAL 16 px approximation of the C2 farmhouse.

Not finished artist-authored art and not a downsample: every part is redrawn here at 16 art px per tile, on the C2
cabin's own coordinates halved (C2 = art/style_tests/ART-005/pl/g7/c2/32/, 384x320 at 32 px per tile, left unchanged),
in a reduced set of C2's own colours. Same world size (12 x 10 tiles -> 192 x 160), same silhouette, door, windows,
lamp, chimney, foundation and steps. The night variant lights only the window glass, as C2's does.

    python tools/hc2_house16.py      -> art/style_tests/ART-005/hc2/house16/house_{day,night}.png
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "art/style_tests/ART-005/hc2/house16"
W, H = 192, 160

# A reduced C2 palette (C2 itself has 59 colours).
O = (24, 17, 16)        # outline
R0, R1, R2, R3, R4 = (30, 22, 17), (40, 30, 23), (50, 38, 29), (60, 46, 35), (71, 55, 42)
RM = (62, 53, 44)       # weathered, greyed shakes (C2's mottled patches)
T1, T2 = (79, 58, 46), (95, 68, 54)                     # roof trim boards
LS = (40, 30, 23)       # log seam
L1, L2, L3, L4, L5 = (88, 63, 50), (106, 78, 57), (125, 94, 65), (155, 119, 81), (169, 132, 89)
L6 = (184, 151, 104)    # log top highlight
LK = (75, 51, 35)       # knot / grain dark
S0, S1, S2, S3 = (51, 44, 37), (73, 62, 53), (110, 98, 80), (138, 134, 122)
G0, G1, G2 = (36, 28, 34), (54, 56, 71), (135, 131, 136)
N0, N1, N2 = (138, 58, 18), (244, 184, 80), (255, 240, 192)   # C2's lit-glass colours
D0, D1, D2, D3 = (75, 53, 43), (99, 70, 50), (114, 85, 61), (138, 105, 73)
BR = (176, 147, 108)    # brass


def h(x, y, s=0):
    v = (x * 374761393 + y * 668265263 + s * 2246822519) & 0xFFFFFFFF
    v = ((v ^ (v >> 13)) * 1274126177) & 0xFFFFFFFF
    return (v ^ (v >> 16)) / 0xFFFFFFFF


def build(night: bool) -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = im.load()

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            px[x, y] = c + (255,)

    def rect(x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                put(x, y, c)

    # ---- Roof: C2 rows 42..160 -> 21..80, silhouette chamfered as C2's ----
    span = {21: (3, 188), 22: (2, 189), 23: (2, 189), 24: (1, 190)}
    for y in range(21, 81):
        x0, x1 = span.get(y, (0, 191) if y >= 79 else (1, 190))
        rect(x0, y, x1, y, O)
    # ridge cap boards
    rect(3, 22, 188, 22, T2)
    rect(2, 23, 189, 25, T1)
    rect(2, 26, 189, 26, R1)
    for x in range(10, 186, 23):   # board joints on the cap
        put(x, 23, R2); put(x, 24, R2)
    rect(2, 27, 189, 27, R0)
    # shakes: eight courses of 6 rows, staggered, 4..8 px wide, with a cast-shadow row under each butt
    y = 28
    course = 0
    while y < 74:
        x = 2 - int(h(course, 1) * 5)
        while x < 190:
            w = 7 + int(h(x, course, 2) * 7)
            r = h(x, course, 3)
            c = R2 if r < 0.5 else R3 if r < 0.93 else R4
            if h(x // 34, course // 2, 9) > 0.8 and r > 0.4:   # a few weathered, greyed patches
                c = RM
            for yy in range(y + 1, min(y + 6, 74)):
                for xx in range(max(x, 2), min(x + w - 1, 190)):
                    put(xx, yy, c)
            drop = 1 if h(x, course, 6) > 0.7 and y + 6 < 74 else 0   # some butts hang 1 px lower: an uneven course line
            for xx in range(max(x, 2), min(x + w - 1, 190)):   # butt-edge shadow of the course above
                put(xx, y, R1 if c != R2 else R0)
                if drop:
                    put(xx, y + 6, c if c != RM else R3)
            if drop:
                put(max(x, 2), y + 6, R1)
            if x + w - 1 < 190 and x + w - 1 >= 2:             # 1 px gap between shakes, not always full height
                for yy in range(y + (2 if h(x, course, 7) > 0.5 else 1), min(y + 6, 74)):
                    put(x + w - 1, yy, R0 if c != RM else R1)
            if w >= 8:                                          # a vertical split / grain line in wide shakes
                gx = x + 2 + int(h(x, course, 8) * (w - 4))
                if 2 <= gx < 190:
                    for yy in range(y + 3, min(y + 6, 74)):
                        put(gx, yy, R1 if c in (R2, R3) else R2)
            if c in (R3, R4) and w >= 7 and h(x, course, 4) > 0.5:   # light catch on the upper left of some shakes
                put(max(x, 2), y + 1, R4 if c == R3 else (83, 64, 50))
                put(max(x, 2) + 1, y + 1, R4 if c == R3 else (83, 64, 50))
            x += w
        y += 6
        course += 1
    # eave fascia
    rect(1, 74, 190, 74, O)
    rect(1, 75, 190, 75, T2)
    rect(1, 76, 190, 77, T1)
    rect(0, 78, 191, 78, O)
    rect(1, 79, 190, 79, R0)
    rect(1, 80, 190, 80, O)
    for xx in (2, 189):   # the roof's side edge
        for yy in range(25, 78):
            put(xx, yy, R1)

    # ---- Chimney: C2 x 292..328, y 20..65 -> 146..164, 10..32 ----
    rect(146, 10, 164, 14, O)
    rect(147, 11, 163, 13, S1)
    rect(148, 11, 161, 11, S2)
    rect(148, 14, 162, 32, O)
    stones = [(149, 15, 154, 19), (156, 15, 161, 19), (149, 21, 152, 25), (154, 21, 161, 25),
              (149, 27, 155, 31), (157, 27, 161, 31)]
    for x0, y0, x1, y1 in stones:
        rect(x0, y0, x1, y1, S1)
        rect(x0 + 1, y0, x1 - 2, y0, S2)
        put(x0, y0 + 1, S2)
        rect(x0 + 1, y1, x1, y1, S0)
        for cx, cy in ((x0, y0), (x1, y0), (x0, y1), (x1, y1)):
            put(cx, cy, O)
    rect(162, 15, 162, 32, S0)   # right side in shade

    # ---- Log walls: C2 y 162..280 -> 81..140, x 7..376 -> 3..188; eight courses as C2's seams ----
    seams = [81, 87, 94, 102, 109, 117, 124, 132, 140]
    rect(9, 81, 183, 140, L3)
    for i in range(len(seams) - 1):
        t, b = seams[i], seams[i + 1]
        rows = list(range(t + 1, b))
        ramp = [L4, L6, L5, L4, L3, L3, L2, L1][-len(rows):] if len(rows) < 8 else [L4, L6, L5, L5, L4, L3, L2, L1]
        if i == 0:
            ramp = [L1, L2, L3, L4, L3][: len(rows)]   # top course in the eave's shadow
        for k, yy in enumerate(rows):
            rect(9, yy, 183, yy, ramp[k % len(ramp)])
        rect(9, b, 183, b, LS)
        # grain: short darker and lighter streaks, 3..7 px, sparse
        for xx in range(9, 183):
            r = h(xx, i, 5)
            if r < 0.06 and len(rows) > 3:
                yy = rows[1 + int(h(xx, i, 6) * (len(rows) - 2))]
                ln = 3 + int(h(xx, i, 7) * 5)
                col = L3 if px[xx, yy][:3] in (L5, L6, L4) else L2
                for k in range(ln):
                    if xx + k < 183:
                        put(xx + k, yy, col)
            elif r > 0.988 and len(rows) > 4:   # a knot
                yy = rows[2]
                put(xx, yy, LK); put(xx + 1, yy, LK); put(xx, yy + 1, L2)
    rect(9, 81, 183, 81, LS)   # under the eave
    # log ends, both corners: rounded 6 px blocks, alternately jogged 1 px (C2's stacked corner)
    for i in range(len(seams) - 1):
        t, b = seams[i] + 1, seams[i + 1] - 1
        for side, xL in ((0, 3 + (i % 2)), (1, 183 - (i + 1) % 2)):
            x0, x1 = xL, xL + 6
            rect(x0, t, x1, b, O)
            rect(x0 + 1, t + 1, x1 - 1, b - 1, L3)
            rect(x0 + 1, t + 1, x1 - 2, t + 1, L5)
            rect(x0 + 1, t + 1, x0 + 1, b - 1, L4)
            rect(x1 - 1, t + 2, x1 - 1, b - 1, L2)
            cy = (t + b) // 2
            put(x0 + 3, cy, L1); put(x0 + 3, cy + 1 if b - t > 5 else cy, L1); put(x0 + 4, cy, L2)
            for cx, cyy in ((x0, t), (x1, t), (x0, b), (x1, b)):   # round the block corners
                px[cx, cyy] = (0, 0, 0, 0) if (cx < 9 or cx > 183) else LS + (255,)

    # ---- Windows: C2 x 75..118 / 264..308, y 202..250 -> 37..59 / 132..154, 101..126 ----
    for wx in (37, 132):
        x0, x1, y0, y1 = wx, wx + 22, 101, 124
        rect(x0, y0, x1, y1, O)
        rect(x0 + 1, y0 + 1, x1 - 1, y1 - 1, L2)
        rect(x0 + 1, y0 + 1, x1 - 1, y0 + 1, L3)          # frame top lit
        rect(x0 + 1, y0 + 1, x0 + 1, y1 - 1, L3)
        gx0, gx1, gy0, gy1 = x0 + 3, x1 - 3, y0 + 3, y1 - 3
        rect(gx0 - 1, gy0 - 1, gx1 + 1, gy1 + 1, O)
        mx, my = (gx0 + gx1) // 2, (gy0 + gy1) // 2
        for (a0, a1, b0, b1) in ((gx0, mx - 1, gy0, my - 1), (mx + 1, gx1, gy0, my - 1),
                                 (gx0, mx - 1, my + 1, gy1), (mx + 1, gx1, my + 1, gy1)):
            if night:
                rect(a0, b0, a1, b1, N1)
                rect(a0, b0, a1, b0, N0)
                rect(a0, b0, a0, b1, N0)
                put(a1 - 2, b0 + 2, N2); put(a1 - 3, b0 + 3, N2); put(a1 - 1, b0 + 1, N2)
            else:
                rect(a0, b0, a1, b1, G1)
                rect(a0, b0, a1, b0, G0)
                rect(a0, b0, a0, b1, G0)
                put(a1 - 2, b0 + 2, G2); put(a1 - 3, b0 + 3, G2); put(a1 - 1, b0 + 1, G2)
        rect(mx, gy0, mx, gy1, L2)    # muntins
        rect(gx0, my, gx1, my, L2)
        put(mx, my, L3)
        # sill
        rect(x0 - 2, y1 + 1, x1 + 2, y1 + 1, L5)
        rect(x0 - 2, y1 + 2, x1 + 2, y1 + 2, O)
        put(x0 - 2, y1 + 1, O); put(x1 + 2, y1 + 1, O)

    # ---- Door: C2 x 167..216, y 217..298 -> 84..107, 108..148 ----
    x0, x1, y0, y1 = 84, 107, 108, 148
    rect(x0, y0, x1, y1, O)
    rect(x0 + 1, y0 + 1, x1 - 1, y1, L2)        # frame
    rect(x0 + 1, y0 + 1, x1 - 1, y0 + 1, L4)
    rect(x0 + 1, y0 + 1, x0 + 1, y1, L3)
    bx0, bx1, by0 = x0 + 3, x1 - 3, y0 + 3
    rect(bx0 - 1, by0 - 1, bx1 + 1, y1, O)
    boards = [(bx0, bx0 + 4), (bx0 + 6, bx0 + 10), (bx0 + 12, bx1)]
    for i, (a, b) in enumerate(boards):
        rect(a, by0, b, y1, D1 if i != 1 else D0)
        rect(a, by0, a, y1, D2)
        rect(b, by0, b, y1, D0 if i != 1 else (58, 42, 36))
        for yy in range(by0 + 2, y1, 7):   # grain
            if h(a, yy, 11) > 0.5:
                put(a + 2, yy, D1 if i != 1 else D0); put(a + 2, yy + 1, D1 if i != 1 else D0)
    for a, b in zip(boards, boards[1:]):
        rect(a[1] + 1, by0, b[0] - 1, y1, O)
    for yy in (by0 + 3, y1 - 6):   # battens
        rect(bx0, yy, bx1, yy + 2, D2)
        rect(bx0, yy, bx1, yy, D3)
        rect(bx0, yy + 3, bx1, yy + 3, D0)
        put(bx0 + 1, yy + 1, O); put(bx1 - 1, yy + 1, O)   # nails
    put(bx1 - 2, 129, BR); put(bx1 - 2, 130, BR); put(bx1 - 1, 130, D0)   # latch

    # ---- Wall lamp: C2 x 224..233, y 227..241 -> 112..116, 113..120 ----
    rect(112, 113, 116, 120, O)
    rect(113, 114, 115, 119, G1)   # unlit day and night, as C2's
    put(113, 114, G2)
    rect(113, 119, 115, 119, S1)
    put(114, 112, O)

    # ---- Foundation: C2 y 281..298, x 14..369 -> 141..149, 7..184 ----
    rect(6, 140, 185, 149, O)
    x = 7
    k = 0
    while x < 185:   # upper course, 7..10 px stones
        w = 7 + int(h(x, 1, 13) * 4)
        a, b = x, min(x + w - 2, 184)
        rect(a, 141, b, 145, S2)
        rect(a, 144, b, 145, S1)
        rect(a + 1, 142, a + 2 + int(h(x, 5, 13) * 2), 142, S3)
        rect(b, 142, b, 145, S1)
        put(a + 1, 145, S0)
        for cx, cy in ((a, 141), (b, 141), (a, 145), (b, 145)):
            put(cx, cy, O)
        x += w
        k += 1
    x = 5
    while x < 185:   # lower course, smaller and darker
        w = 4 + int(h(x, 4, 13) * 3)
        a, b = max(x, 7), min(x + w - 2, 184)
        if b >= a:
            rect(a, 147, b, 148, S1)
            rect(a + 1, 147, b - 1, 147, S2)
            put(a, 148, S0)
        x += w
    rect(9, 140, 183, 140, LS)   # the bottom log's shadow on the footing

    # ---- Steps: C2 x 158..225, y 299..320 -> 79..112, 149..159 ----
    rect(81, 149, 110, 153, O)
    rect(82, 150, 109, 152, S1)
    rect(83, 150, 107, 150, S2)
    rect(95, 150, 95, 152, S0)
    rect(79, 154, 112, 159, O)
    rect(80, 155, 111, 158, S1)
    rect(81, 155, 110, 155, S2)
    rect(80, 158, 111, 158, S0)
    for xx in (88, 101):
        rect(xx, 155, xx, 158, S0)
    # the door's bottom stays over the upper step, as C2's
    rect(x0, 148, x1, 149, O)
    return im


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, night in (("day", False), ("night", True)):
        im = build(night)
        im.save(OUT / f"house_{name}.png")
        cols = {c for c in im.getdata() if c[3]}
        print(name, im.size, len(cols), "colours")


if __name__ == "__main__":
    main()
