"""ART-005 VS16 (zero-generation, NON-PRODUCTION): the polished 16 px restored-farmhouse prototype.

A deliberately composed 16 px cabin, not a downsample and not the HC2 scripted mockup. It keeps C2's architecture
(art/style_tests/ART-005/pl/g7/c2/32/, left unchanged) on the same 12 x 10 tile footprint (192 x 160 px at 16 px per
tile): the side-gable silhouette and chamfers, the chimney, the eight log courses on C2's seams, both windows, the
door, the lamp, the foundation and the steps all sit where C2's do, so it can be swapped onto C2's anchor.

What is composed for 16 px rather than copied:
  * roof: seven bold shake courses, each a shadow row (cast by the butt above), a body and a lit butt edge; staggered
    joints; weathering and moss as a few deliberate clusters, not per-shake noise; the chimney casts its shadow down
    and to the right; lit verge board on the left, shaded verge on the right
  * walls: every log is a rounded cylinder (lit top row, warm body, cool underside) with dark chinking; grain as
    sparse 3-8 px streaks and a few knots; a broad shadow band under the eave; stacked round log ends with end grain
  * windows and door: real recesses (shadow on the top and left inner edges, light from the upper left), sills that
    cast a row of shadow, a hewn lintel log over the door, iron strap hinges and a brass latch
  * foundation: rounded fieldstones with a lit upper-left cluster, a little moss low down, shadowed under the logs
  * night: only the window glass (and a little spill on the sills and reveals) changes, as C2's night does

    python tools/vs16_cabin.py   -> art/style_tests/ART-005/vs16/cabin/house_{day,night}.png (+ palette.png)
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "art/style_tests/ART-005/vs16/cabin"
W, H = 192, 160

# ---- The shared autumn palette (draft): ramps run dark -> light; shadows lean cool, highlights lean warm ----
OL = (24, 17, 16)                                                      # the one shared outline (C2's)
L = [(52, 36, 30), (82, 59, 42), (110, 82, 57), (136, 104, 72), (160, 126, 87), (184, 152, 108), (206, 178, 130)]
CH = (38, 27, 25)                                                      # log chinking / seams
R = [(30, 23, 20), (42, 32, 27), (54, 42, 33), (64, 50, 38), (77, 60, 45), (93, 73, 53)]   # wood shakes
RW = [(70, 58, 47), (84, 70, 56)]                                      # weathered, silvered shakes
M = [(46, 52, 36), (64, 72, 42), (88, 96, 52)]                         # moss
T = [(58, 40, 33), (84, 59, 44), (112, 81, 56), (140, 104, 70)]        # trim boards (verge, fascia, ridge)
S = [(46, 40, 37), (76, 67, 58), (104, 93, 80), (132, 121, 104), (162, 151, 130)]   # fieldstone
G = [(27, 30, 41), (44, 52, 70), (72, 88, 108), (140, 156, 166)]       # glass by day
N = [(112, 46, 20), (196, 118, 46), (242, 182, 92), (255, 228, 164)]   # lit glass at night
D = [(66, 45, 34), (96, 68, 47), (120, 88, 60), (144, 108, 73)]          # door planks
BR, BR2, IR = (184, 150, 96), (122, 96, 60), (50, 46, 50)              # brass, dark brass, iron


def hsh(x, y, s=0):
    v = (x * 374761393 + y * 668265263 + s * 2246822519) & 0xFFFFFFFF
    v = ((v ^ (v >> 13)) * 1274126177) & 0xFFFFFFFF
    return (v ^ (v >> 16)) / 0xFFFFFFFF


def build(night: bool) -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    px = im.load()

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            px[x, y] = tuple(c[:3]) + (255,)

    def get(x, y):
        return px[x, y][:3] if px[x, y][3] else None

    def rect(x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                put(x, y, c)

    def hline(x0, x1, y, c):
        rect(x0, y, x1, y, c)

    def darken(x, y, ramp, steps=1):
        c = get(x, y)
        if c in ramp:
            put(x, y, ramp[max(0, ramp.index(c) - steps)])

    # =========================== ROOF (rows 21..80, C2's silhouette and chamfers) ===========================
    span = {21: (3, 188), 22: (2, 189), 23: (2, 189), 24: (1, 190)}
    for y in range(21, 81):
        x0, x1 = span.get(y, (0, 191) if y >= 77 else (1, 190))
        hline(x0, x1, y, OL)

    # Ridge cap: a two-board cap, lit on top, a shadow row under it.
    hline(4, 187, 22, T[3])
    hline(3, 188, 23, T[2])
    hline(3, 188, 24, T[1])
    hline(2, 189, 25, R[0])
    for x in range(14, 186, 29):                                   # cap board joints
        put(x, 23, T[1]); put(x, 24, T[0])

    # Shake field: seven courses between the cap and the fascia.
    top, bottom = 26, 72
    heights = [6, 7, 6, 7, 6, 7, 7]
    y = top
    for ci, hgt in enumerate(heights):
        y0, y1 = y, min(y + hgt - 1, bottom)
        depth = ci / (len(heights) - 1)                            # 0 at the ridge, 1 at the eave
        x = 3 - int(hsh(ci, 1) * 9)
        while x < 189:
            w = 7 + int(hsh(x, ci, 2) * 6)                          # 7..12 px shakes
            r = hsh(x, ci, 3)
            # value: lower courses catch a touch more sky; a few shakes a step darker or lighter
            body = R[3] if r < 0.38 + 0.25 * depth else R[2]
            if r > 0.95:
                body = R[4]
            # weathering and moss as clusters (a field of low-frequency "patches"), not per-shake noise
            patch = hsh(x // 30, ci // 2, 9)
            if patch > 0.88 and ci >= 1:
                body = RW[0] if r < 0.6 else RW[1]
            xa, xb = max(x, 3), min(x + w - 2, 188)
            for yy in range(y0 + 1, y1):
                hline(xa, xb, yy, body)
            # lit butt edge (the shake's thick lower end) and the shadow row it throws on the course below
            bi = R.index(body) if body in R else 3
            lit = R[min(5, bi + 2)] if hsh(x, ci, 5) > 0.92 else R[min(5, bi + 1)]
            if body in RW:
                lit = RW[1]
            hline(xa, xb, y1, lit)
            if hsh(x, ci, 6) > 0.72 and y1 + 1 <= bottom:            # an uneven butt line: some shakes hang 1 px
                hline(xa + 1, xb - 1, y1 + 1, lit)
            hline(xa, xb + 1, y0, R[0])
            # the joint between shakes: dark, full height, a lit pixel at its top-left (the next shake's corner)
            gx = x + w - 1
            if 3 <= gx <= 188 and hsh(x, ci, 13) > 0.3:          # joints: soft, not every one, not full height
                for yy in range(y0 + 1, y1 - 1):
                    put(gx, yy, R[1] if body != R[2] else R[0])

            # a split or grain line in the wide shakes
            if w >= 10 and hsh(x, ci, 8) > 0.45:
                sx = x + 3 + int(hsh(x, ci, 10) * (w - 6))
                for yy in range(y0 + 2 + int(hsh(x, ci, 11) * 2), y1):
                    put(sx, yy, R[1] if body in (R[2], RW[0]) else R[2])
            x += w
        y = y1 + 1

    # Moss: two soft clusters low on the north (shaded) lower-left and in the chimney's lee, three tones.
    for cx, cy, rx, ry, seed in ((26, 68, 9, 3, 1), (170, 37, 4, 2, 3)):
        for yy in range(cy - ry - 1, cy + ry + 2):
            for xx in range(cx - rx - 1, cx + rx + 2):
                d = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
                c = get(xx, yy)
                if c is None or c == OL or yy > bottom or yy < top:
                    continue
                n = hsh(xx // 2, yy // 2, seed)
                if d < 0.45 + 0.4 * n:
                    put(xx, yy, M[1] if c in (R[4], R[5], RW[1]) else M[0])

    # Verge boards: lit on the left (light comes from the upper left), shaded on the right.
    for yy in range(25, 73):
        put(2, yy, T[2]); put(3, yy, T[1])
        put(189, yy, T[0]); put(188, yy, R[0])
    put(2, 25, T[3])

    # Fascia (the eave's front board) and the soffit's shadow.
    hline(1, 190, 73, OL)
    hline(2, 189, 74, T[3])
    hline(1, 190, 75, T[2])
    hline(1, 190, 76, T[1])
    hline(0, 191, 77, OL)
    hline(1, 190, 78, T[0])
    hline(1, 190, 79, R[0])
    hline(0, 191, 80, OL)
    for x in range(22, 190, 37):                                   # fascia board joints and nail heads
        put(x, 74, T[1]); put(x, 75, T[1]); put(x, 76, T[0])
    for x in range(8, 190, 12):
        put(x, 75, T[1])

    # =========================== CHIMNEY (x 146..164, y 10..32) ===========================
    # Cast shadow first, on the roof down and to the right of the stack.
    for yy in range(26, 40):
        for xx in range(163, 171 - max(0, yy - 33)):
            darken(xx, yy, R, 1)
            if get(xx, yy) in RW:
                put(xx, yy, R[2])
    for xx in range(147, 165):
        darken(xx, 33, R, 2); darken(xx, 34, R, 1)
    rect(146, 10, 164, 14, OL)                                     # cap stone
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
    for yy in range(15, 18):                                       # soot near the top
        for xx in range(149, 162):
            c = get(xx, yy)
            if c in S:
                put(xx, yy, S[max(0, S.index(c) - 1)])
    hline(149, 160, 15, S[1])

    # =========================== LOG WALLS (rows 81..140) ===========================
    seams = [81, 87, 94, 102, 109, 117, 124, 132, 140]
    rect(9, 81, 182, 140, L[3])
    for i in range(len(seams) - 1):
        t, b = seams[i], seams[i + 1]
        rows = list(range(t + 1, b))
        n = len(rows)
        tone = 0 if hsh(i, 0, 30) > 0.25 else -1                    # one or two logs a step darker: real timber
        ramp = {5: [5, 4, 3, 2, 1], 6: [5, 4, 3, 3, 2, 1], 7: [5, 4, 4, 3, 3, 2, 1]}[n]
        for k, yy in enumerate(rows):
            hline(9, 182, yy, L[max(1, ramp[k] + tone)])
        hline(9, 182, b, CH)
        # grain: sparse dark streaks in the body, a few short warm glints on the upper rows, knots
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
        # axe checks: a dark tick and a lit tick, sparse
        for _ in range(2):
            ax = 14 + int(hsh(i, _, 36) * 160)
            put(ax, rows[n // 2], L[1]); put(ax + 1, rows[n // 2], L[4])

    # The eave's shadow on the top of the wall (broad, soft in two steps), and a vertical shade at the far right.
    for xx in range(9, 183):
        for yy in range(82, 86):
            darken(xx, yy, L, 2 if yy < 84 else 1)
        for yy in range(81, 141):
            pass
    hline(9, 182, 81, CH)

    # Stacked round log ends at both corners, alternately jogged 1 px (as C2's), with end grain.
    for i in range(len(seams) - 1):
        t, b = seams[i] + (1 if i == 0 else 0), seams[i + 1]
        jog = i % 2
        for x0, x1, lit_side in ((3 + jog, 9 + jog, True), (182 - jog, 188 - jog, False)):
            rect(x0, t, x1, b, OL)
            rect(x0 + 1, t + 1, x1 - 1, b - 1, L[3] if lit_side else L[2])
            hline(x0 + 1, x1 - 2, t + 1, L[5] if lit_side else L[4])
            for yy in range(t + 1, b):
                put(x0 + 1, yy, L[4] if lit_side else L[3])
                put(x1 - 1, yy, L[2] if lit_side else L[1])
            hline(x0 + 2, x1 - 1, b - 1, L[1])
            cx, cy = (x0 + x1) // 2, (t + b) // 2                    # end-grain ring and pith
            put(cx, cy, L[1]); put(cx + 1, cy, L[2]) if lit_side else put(cx - 1, cy, L[2])
            if b - t >= 7:
                put(cx, cy - 1, L[2])
            for cxx, cyy in ((x0, t), (x1, t), (x0, b), (x1, b)):   # round the block's corners
                px[cxx, cyy] = (0, 0, 0, 0)
            if i == 0:
                darken(x0 + 1, t + 1, L, 1)

    # =========================== WINDOWS (x 37..59 / 132..154, y 101..126) ===========================
    for wx0, wx1 in ((37, 59), (132, 154)):
        y0, y1 = 101, 126
        rect(wx0, y0, wx1, y1, OL)
        rect(wx0 + 1, y0 + 1, wx1 - 1, y1 - 1, L[2])                # frame
        hline(wx0 + 1, wx1 - 1, y0 + 1, L[4])
        for yy in range(y0 + 1, y1):
            put(wx0 + 1, yy, L[3]); put(wx1 - 1, yy, L[1])
        hline(wx0 + 2, wx1 - 1, y1 - 1, L[1])
        gx0, gy0, gx1, gy1 = wx0 + 4, y0 + 4, wx1 - 4, y1 - 4
        rect(gx0 - 1, gy0 - 1, gx1 + 1, gy1 + 1, OL)
        mx, my = (gx0 + gx1) // 2, (gy0 + gy1) // 2
        for py0, py1 in ((gy0, my - 1), (my + 1, gy1)):
            for qx0, qx1 in ((gx0, mx - 1), (mx + 1, gx1)):
                if night:
                    rect(qx0, py0, qx1, py1, N[2])
                    rect(qx0 + 1, py0 + 2, qx1, py1, N[3]) if py0 > gy0 else rect(qx0 + 2, py0 + 2, qx1, py1, N[3])
                    hline(qx0, qx1, py0, N[1]);
                    for yy in range(py0, py1 + 1):
                        put(qx0, yy, N[1])
                    put(qx0, py0, N[0])
                else:
                    rect(qx0, py0, qx1, py1, G[1])
                    hline(qx0, qx1, py0, G[0])
                    for yy in range(py0, py1 + 1):
                        put(qx0, yy, G[0])
                    # sky reflection: a short diagonal streak, only in the two upper panes
                    if py0 == gy0:
                        for k in range(3):
                            put(qx0 + 2 + k, py1 - k, G[2])
                        put(qx1 - 1, py0 + 1, G[3]) if qx0 == gx0 else None
        hline(gx0, gx1, my, L[2])                                   # muntins
        for yy in range(gy0, gy1 + 1):
            put(mx, yy, L[2])
        put(mx, my, L[3])
        # sill: a lit top, an outline, and the shadow it casts on the log below
        hline(wx0 - 2, wx1 + 2, y1 + 1, L[5])
        hline(wx0 - 1, wx1 + 2, y1 + 2, L[2])
        hline(wx0 - 2, wx1 + 2, y1 + 3, OL)
        put(wx0 - 2, y1 + 2, OL); put(wx1 + 2, y1 + 2, OL)
        for xx in range(wx0 - 1, wx1 + 3):
            darken(xx, y1 + 4, L, 2)
        if night:                                                   # a little spill on the sill and the reveal
            for xx in range(gx0, gx1 + 1, 2):
                put(xx, y1 + 1, (226, 170, 104))
            put(gx0 - 2, gy1, (150, 104, 62)); put(gx1 + 2, gy1, (150, 104, 62))

    # =========================== DOOR (x 84..107, y 108..148) ===========================
    x0, y0, x1, y1 = 84, 108, 107, 148
    # hewn lintel log across the top, wider than the door
    rect(x0 - 3, y0 - 4, x1 + 3, y0, OL)
    hline(x0 - 2, x1 + 2, y0 - 3, L[5])
    hline(x0 - 2, x1 + 2, y0 - 2, L[4])
    hline(x0 - 2, x1 + 2, y0 - 1, L[2])
    put(x0 + 6, y0 - 2, L[2]); hline(x0 + 13, x0 + 17, y0 - 2, L[3])
    rect(x0, y0 + 1, x1, y1, OL)
    for yy in range(y0 + 1, y1 + 1):                               # jambs: lit left, shaded right
        put(x0 + 1, yy, L[4]); put(x0 + 2, yy, L[3])
        put(x1 - 1, yy, L[1]); put(x1 - 2, yy, L[2])
    bx0, by0, bx1 = x0 + 4, y0 + 2, x1 - 4
    rect(bx0 - 1, by0 - 1, bx1 + 1, y1, OL)
    planks = [(bx0, bx0 + 3), (bx0 + 5, bx0 + 8), (bx0 + 10, bx0 + 13), (bx0 + 15, bx1)]
    for pi, (a, b) in enumerate(planks):
        base = D[2] if pi in (0, 2) else D[1]
        rect(a, by0, b, y1, base)
        for yy in range(by0, y1 + 1):
            put(a, yy, D[3] if pi == 0 else D[2] if base == D[1] else D[3])
            put(b, yy, D[1] if base == D[2] else D[0])
        for k in range(3):                                          # grain streaks
            gy = by0 + 5 + int(hsh(pi, k, 40) * 28)
            for yy in range(gy, min(gy + 3 + int(hsh(pi, k, 41) * 4), y1)):
                put(a + 1 + int(hsh(pi, k, 42) * max(1, b - a - 1)), yy, D[0] if base == D[1] else D[1])
    for yy in range(by0, y1 + 1):                                  # plank gaps
        for (a, b), (c, _) in zip(planks, planks[1:]):
            for gx in range(b + 1, c):
                put(gx, yy, OL)
    hline(bx0, bx1, by0, D[0])                                     # recess shadow under the lintel
    hline(bx0, bx1, by0 + 1, D[1])
    for yy in range(by0, y1 + 1):
        put(bx0, yy, D[1])
    for by in (by0 + 6, y1 - 9):                                   # iron strap hinges on the left, nails
        hline(bx0, bx0 + 9, by, IR)
        hline(bx0, bx0 + 7, by + 1, OL)
        put(bx0 + 2, by, (92, 88, 90)); put(bx0 + 6, by, (92, 88, 90))
    put(bx1 - 2, 129, BR); put(bx1 - 2, 130, BR2); put(bx1 - 1, 129, BR2); put(bx1 - 2, 128, OL)   # latch

    # =========================== WALL LAMP (x 112..116, y 113..120) ===========================
    put(114, 111, IR); put(114, 112, IR); hline(113, 115, 111, OL)
    rect(112, 113, 116, 120, OL)
    if night:
        rect(113, 114, 115, 118, G[1])                            # unlit, as C2's (the porch light is not this task)
    else:
        rect(113, 114, 115, 118, G[1])
        put(113, 114, G[2])
    hline(113, 115, 119, IR)
    hline(112, 116, 112, OL)

    # =========================== FOUNDATION (x 6..185, y 141..149) ===========================
    rect(6, 141, 185, 149, OL)
    for course, (a, b, wmin, wspan, off) in enumerate(((141, 145, 7, 5, 0), (146, 149, 5, 5, 4))):
        x = 7 - off
        while x < 185:
            w = wmin + int(hsh(x, course, 50) * wspan)
            xa, xb = max(x, 7), min(x + w - 2, 184)
            if xb - xa >= 1:
                tone = 1 if hsh(x, course, 51) > 0.7 else 0
                body = S[2 - tone - course]
                rect(xa, a, xb, b, body)
                hline(xa + 1, xb - 1, a, S[3 - tone - course])     # lit top
                if xb - xa >= 4:
                    hline(xa + 1, xa + 2 + int(hsh(x, course, 52) * 2), a, S[4 - tone - course])
                for yy in range(a + 1, b + 1):
                    put(xa, yy, S[3 - tone - course] if yy == a + 1 else body)
                    put(xb, yy, S[1 - min(1, tone + course)])
                hline(xa + 1, xb, b, S[1 - min(1, tone + course)])
                px[xa, a] = OL + (255,); px[xb, a] = OL + (255,)    # rounded corners
                px[xa, b] = OL + (255,); px[xb, b] = OL + (255,)
                if course == 1 and hsh(x, course, 53) > 0.62:          # a little moss low on the stones
                    hline(xa + 1, min(xb, xa + 3), b, M[1]); put(xa + 1, b - 1, M[0])
            x += w
    for xx in range(7, 185):                                       # the logs overhang the footing: a shadow row
        c = get(xx, 141)
        if c in S:
            put(xx, 141, S[max(0, S.index(c) - 2)])

    # =========================== STEPS (x 79..112, y 149..159) ===========================
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
    hline(82, 109, 153, S[0])                                      # the upper step's shadow on the lower one
    hline(x0, x1, 148, OL)                                         # the door's sill sits on the upper step
    hline(bx0, bx1, 149, L[2])
    return im


def palette_strip() -> Image.Image:
    ramps = [("outline", [OL]), ("logs", L), ("chinking", [CH]), ("shakes", R), ("weathered", RW), ("moss", M),
             ("trim", T), ("stone", S), ("glass", G), ("lit glass", N), ("door", D), ("metal", [BR2, BR, IR])]
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
