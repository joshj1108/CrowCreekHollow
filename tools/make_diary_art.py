# UI-OVERHAUL-001 Phase 5 (the Diary): draws the diary's pixel art by hand, no generation credits.
# Everything is drawn at 1 native pixel and saved at 2x (nearest), the UI's detail density (as the HUD icons).
#   art/ui/diary/cover.png       leather cover 9-slice: 40x40 native, 14 px corners (28 at 2x); brass corner caps,
#                                saddle stitching, worn lighter scuffs at the corners, a 12 px periodic grain centre
#   art/ui/diary/page_l.png      left page 9-slice: 44x48 native; outer 10, top 10, bottom 10, spine 14; deckled outer
#   art/ui/diary/page_r.png      edge, worn corners, foxing, a faint ring stain in the outer foot, and the gutter's
#                                stepped shadow toward the spine; fibre flecks kept sparse so text stays clean
#   art/ui/diary/spine.png       the sewn gutter between the pages: 4x8 native, tiled down; a thread every 8 px
#   art/ui/diary/ribbon.png      a bookmark ribbon 9-slice (grey, tinted per section): 30x19 native, swallowtail end
#   art/ui/diary/grommet.png     the brass eyelet on the open ribbon: 5x5 native
#   art/ui/diary/endpaper.png    the muted marbled endpaper a torn-out page leaves bare: 48x48 native tile
#   art/ui/diary/torn_l.png      the torn remnant at the binding, tiled down: 18x48 native (torn_r mirrored)
#   art/ui/diary/feather.png     a small faded-ink sketch of a crow feather for a blank page: 24x24 native
#   art/ui/diary/fleuron.png     the ornament at the centre of a page's title rule: 11x5 native
# Run: python tools/make_diary_art.py   (then import once with Godot --import)
import os
import random

from PIL import Image

SCALE = 2
OUT = os.path.join("art", "ui", "diary")

# The approved palette (UI-OVERHAUL-001 brief) and the few in-betweens the art needs.
SHADOW = "151009"
WALNUT = "3b2417"
WOOD = "6b5340"
BRASS = "8a6a3a"
PARCH = "c4ae84"
EDGE = "8f7a54"
INK = "2b2016"
IVORY = "e8dcc0"
LEATHER = {"d2": "24150d", "d": "2f1c12", "b": WALNUT, "m": "45291a", "l": "55361f", "s": "6b4a32"}
BRASSES = {"d": "5a4424", "b": BRASS, "l": "b0904e", "g": "d8c08a"}
PAPER = {"x": "6b5a40", "4": EDGE, "3": "a08a62", "2": "b29c74", "b": PARCH, "l": "cdb88f", "h": "d6c39c"}


def rgba(hex_, a=255):
    return (int(hex_[0:2], 16), int(hex_[2:4], 16), int(hex_[4:6], 16), a)


def canvas(w, h):
    return Image.new("RGBA", (w, h), (0, 0, 0, 0))


def save(img, name):
    os.makedirs(OUT, exist_ok=True)
    big = img.resize((img.width * SCALE, img.height * SCALE), Image.NEAREST)
    path = os.path.join(OUT, name)
    big.save(path)
    print("wrote %s (%dx%d native, %dx%d saved)" % (path, img.width, img.height, big.width, big.height))


def periodic(seed, w, h):
    rng = random.Random(seed)
    return [[rng.random() for _ in range(w)] for _ in range(h)]


# --- The leather cover -----------------------------------------------------------

def cover():
    n, m = 40, 14
    p = m  # the grain repeats every (n - 2m) = 12 px, so tiled edges and the centre meet without a seam
    period = n - 2 * m
    grain = periodic(11, period, period)
    img = canvas(n, n)
    px = img.load()
    for y in range(n):
        for x in range(n):
            g = grain[(y - p) % period][(x - p) % period]
            tone = "b"
            if g < 0.10:
                tone = "d"
            elif g > 0.93:
                tone = "m"
            px[x, y] = rgba(LEATHER[tone])
    # The edge: outline, a lit bevel on the top and left, a dark one on the bottom and right.
    for i in range(n):
        for (x, y) in ((i, 0), (i, n - 1), (0, i), (n - 1, i)):
            px[x, y] = rgba(SHADOW)
    for i in range(1, n - 1):
        px[i, 1] = rgba(LEATHER["l"])
        px[1, i] = rgba(LEATHER["l"])
        px[i, n - 2] = rgba(LEATHER["d2"])
        px[n - 2, i] = rgba(LEATHER["d2"])
        px[i, 2] = rgba(LEATHER["m"])
        px[2, i] = rgba(LEATHER["m"])
    # Saddle stitching four px in: two on, one off (the period, 3, divides the 12 px centre).
    for i in range(4, n - 4):
        on = (i - p) % 3 != 2
        for (x, y) in ((i, 4), (i, n - 5), (4, i), (n - 5, i)):
            px[x, y] = rgba("8a6e4e" if on else LEATHER["d"])
        if on:  # the stitch holes' shade just below and right of each stitch
            px[i, 5] = rgba(LEATHER["d"])
            px[5, i] = rgba(LEATHER["d"])
    # The inner edge where the page block sits: a dark seat line around the inside of the margin.
    # Brass corner caps: a right triangle over each corner, lit from the top left, with one rivet.
    cap = 10
    for corner in range(4):
        fx = corner in (1, 3)
        fy = corner in (2, 3)
        for y in range(cap):
            for x in range(cap - y):
                X = n - 1 - x if fx else x
                Y = n - 1 - y if fy else y
                edge = x + y == cap - 1
                lit = (x == 1 and not fx) or (y == 1 and not fy)
                dark = (x == 1 and fx) or (y == 1 and fy)
                if x == 0 or y == 0 or edge:
                    col = SHADOW
                elif lit:
                    col = BRASSES["l"]
                elif dark:
                    col = BRASSES["d"]
                else:
                    col = BRASSES["b"]
                px[X, Y] = rgba(col)
        # rivet
        rx, ry = 3, 3
        X = n - 1 - rx if fx else rx
        Y = n - 1 - ry if fy else ry
        px[X, Y] = rgba(BRASSES["g"])
        px[X + (-1 if fx else 1), Y + (-1 if fy else 1)] = rgba(BRASSES["d"])
        # wear just past the cap's hypotenuse: the leather rubbed lighter
        for k in range(1, cap - 1, 2):
            x, y = k, cap - k
            X = n - 1 - x if fx else x
            Y = n - 1 - y if fy else y
            if 0 < X < n - 1 and 0 < Y < n - 1:
                px[X, Y] = rgba(LEATHER["s"])
    save(img, "cover.png")


# --- The pages ------------------------------------------------------------------

def page(left):
    outer, top, bottom, spine = 10, 10, 10, 14
    cw, ch = 20, 28
    w, h = outer + cw + spine, top + ch + bottom
    fib = periodic(23, cw, ch)
    img = canvas(w, h)
    px = img.load()
    # Drawn as the right page (spine on the left); the left page is its mirror.
    # x: 0 at the spine side, w-1 at the outer edge.
    for y in range(h):
        for x in range(w):
            f = fib[(y - top) % ch][(x - spine) % cw]
            tone = "b"
            if f > 0.975:
                tone = "l"
            elif f < 0.025:
                tone = "2"
            px[x, y] = rgba(PAPER[tone])
            # short horizontal fibres: a darker fleck runs one more pixel right
            if 0.025 <= f < 0.04:
                px[x, y] = rgba(PAPER["2"])
    # The gutter: stepped shade toward the spine, each step dithered into the next.
    steps = [(0, "x"), (1, "4"), (3, "3"), (6, "2"), (10, "b")]
    for y in range(h):
        for x in range(spine):
            tone = None
            for start, t in steps:
                if x >= start:
                    tone = t
            if tone == "b":
                continue
            # dither the boundary into the next step
            nxt = None
            for start, t in steps:
                if start == x + 1 and (x + y) % 2 == 0:
                    nxt = t
            px[x, y] = rgba(PAPER[nxt or tone])
    # Top and bottom: a light lip on top, the page's shade at the foot.
    for x in range(w):
        px[x, 0] = rgba(PAPER["3"])
        px[x, 1] = rgba(PAPER["h"]) if x > spine // 2 else px[x, 1]
        px[x, h - 1] = rgba(PAPER["4"])
        px[x, h - 2] = rgba(PAPER["3"])
    # The deckled outer edge: a few pixels nibbled away, with the paper's edge colour inside them.
    nib = periodic(31, 1, ch)
    for y in range(h):
        k = nib[(y - top) % ch][0]
        cut = 1 if k < 0.35 else 0
        for x in range(w - cut, w):
            px[x, y] = (0, 0, 0, 0)
        px[w - 1 - cut, y] = rgba(PAPER["4"])
        if k > 0.8:
            px[w - 2 - cut, y] = rgba(PAPER["3"])
    # Worn outer corners: rounded off, with a darker crease line.
    for (cx, cy, dy) in ((w - 1, 0, 1), (w - 1, h - 1, -1)):
        for (ox, oy) in ((0, 0), (1, 0), (0, 1), (2, 0), (0, 2), (1, 1)):
            x, y = cx - ox, cy + dy * oy
            px[x, y] = (0, 0, 0, 0) if ox + oy <= 2 else rgba(PAPER["4"])
        for (ox, oy) in ((3, 0), (0, 3), (2, 1), (1, 2)):
            x, y = cx - ox, cy + dy * oy
            px[x, y] = rgba(PAPER["4"])
        # a dog-ear crease just in from the corner
        for k in range(4, 7):
            x, y = cx - k, cy + dy * (7 - k)
            px[x, y] = rgba(PAPER["3"])
    # Foxing: a few age spots in the outer top corner, a faint ring stain in the outer foot.
    for (x, y, t) in ((w - 5, 4, "2"), (w - 7, 6, "3"), (w - 4, 7, "2"), (w - 8, 3, "2")):
        px[x, y] = rgba(PAPER[t])
    ring_c = (w - 6, h - 6)
    for y in range(h - 10, h - 1):
        for x in range(w - 10, w - 1):
            d2 = (x - ring_c[0]) ** 2 + (y - ring_c[1]) ** 2
            if 9 <= d2 <= 15 and px[x, y][3] and (x + y) % 3 != 0:
                px[x, y] = rgba(PAPER["2"])
    if left:
        img = img.transpose(Image.FLIP_LEFT_RIGHT)
    save(img, "page_l.png" if left else "page_r.png")


def spine():
    img = canvas(4, 8)
    px = img.load()
    cols = ["4a3826", INK, SHADOW, INK]
    for y in range(8):
        for x in range(4):
            px[x, y] = rgba(cols[x])
    # the sewing thread crossing the fold
    px[1, 3] = rgba("8a7a5a")
    px[2, 3] = rgba("a89c80")
    px[2, 4] = rgba("6a5c44")
    save(img, "spine.png")


# --- Ribbons, eyelet, endpaper, sketches ------------------------------------------

def ribbon():
    w, h = 30, 19
    img = canvas(w, h)
    px = img.load()
    notch = 5
    for y in range(h):
        mid = abs(y - (h - 1) / 2.0)
        cut = int(round(notch * (1.0 - mid / ((h - 1) / 2.0))))  # the swallowtail V
        for x in range(w - cut):
            g = 0.86
            if y == 1:
                g = 1.0
            elif y in (2, 3):
                g = 0.94
            elif y == h - 2:
                g = 0.6
            elif y == h - 3:
                g = 0.72
            elif y % 3 == 0:
                g = 0.8  # the weave
            if x < 3:
                g *= 0.55 + 0.12 * x  # tucked under the cover's edge
            v = int(255 * g)
            px[x, y] = (v, v, v, 255)
        # outline the V and the ends
        if w - cut - 1 >= 0:
            px[w - cut - 1, y] = (40, 40, 40, 255)
    for x in range(w):
        for y in (0, h - 1):
            if px[x, y][3]:
                px[x, y] = (40, 40, 40, 255)
    save(img, "ribbon.png")


def grommet():
    img = canvas(5, 5)
    px = img.load()
    shape = [".OOO.", "OlbdO", "Ob.dO", "OddDO", ".OOO."]
    cols = {"O": SHADOW, "l": BRASSES["g"], "b": BRASSES["l"], "d": BRASSES["b"], "D": BRASSES["d"], ".": None}
    for y, row in enumerate(shape):
        for x, c in enumerate(row):
            if cols[c]:
                px[x, y] = rgba(cols[c])
    px[2, 2] = rgba(LEATHER["d2"])
    save(img, "grommet.png")


def endpaper():
    # Finishing pass: a muted marbled endpaper, the kind glued inside an old journal's board: a warm umber ground
    # with a few thin wandering veins (contour lines of a warped field) in one close tone, the odd darker pool,
    # and no repeating figure, so it reads as old paper rather than wood or cloth. 48x48 native tile, periodic
    # both ways (every wave fits the tile's period).
    import math
    n = 48
    img = canvas(n, n)
    px = img.load()
    a = 2 * math.pi / n
    speck = periodic(43, n, n)
    for y in range(n):
        for x in range(n):
            wx = 3.0 * math.sin(a * y + 0.7) + 2.0 * math.sin(a * (2 * y + x) + 2.1)
            wy = 2.5 * math.sin(a * x + 1.9) + 1.5 * math.sin(a * (x - 2 * y) + 0.3)
            v = (math.sin(a * (x + wx) + 0.3) + 0.8 * math.sin(a * (y + wy) * 2 + 1.1)
                 + 0.5 * math.sin(a * (x + y + wx - wy) + 2.6))
            tone = "302419"
            if v < -1.6:
                tone = "2a1f16"          # a darker pool
            for c in (-0.6, 0.35, 1.2):
                if abs(v - c) < 0.07:
                    tone = "3a2c1f"      # a vein
            if abs(v - 1.2) < 0.03:
                tone = "44352a"          # the vein's lighter heart, rarely
            if speck[y][x] > 0.992:
                tone = "3e3024"
            px[x, y] = rgba(tone)
    save(img, "endpaper.png")


def torn_stub(left):
    # The remnant a torn-out page leaves at the binding, tiled down the page: 18x48 native, the spine on the
    # right for the left page. Parchment with the gutter's shade, a ragged tear (a slow wobble plus a fixed jitter,
    # periodic down the tile), the torn paper's paler core showing as the sheet's thickness, loose fibres past
    # the tear, a broken dark outline, and a two-step shadow on the endpaper. Transparent beyond, so the endpaper
    # shows through.
    import math
    w, h = 18, 48
    img = canvas(w, h)
    px = img.load()
    rng = random.Random(57)
    jitter = [rng.choice([0, 0, 0, 1, -1, 1]) for _ in range(h)]
    fibres = {}
    for y in range(h):
        if rng.random() < 0.28:
            fibres[y] = rng.choice([1, 1, 2, 3])
    for y in range(h):
        wob = 1.6 * math.sin(2 * math.pi * y / h + 0.5) + 1.0 * math.sin(2 * math.pi * 3 * y / h + 2.0)
        edge = 9 + int(round(wob)) + jitter[y]          # the tear's distance from the spine, in native px
        for d in range(w):
            x = (w - 1 - d) if left else d               # d counts out from the spine
            if d < edge - 1:
                if d < 2:
                    tone = PAPER["3"]                    # deep in the gutter
                elif d < 4:
                    tone = PAPER["2"]
                else:
                    tone = PAPER["b"] if (d + y) % 7 else PAPER["2"]
                px[x, y] = rgba(tone)
            elif d == edge - 1:
                px[x, y] = rgba(PAPER["h"])              # the torn core: the sheet's thickness, paler
            elif d == edge:
                if (y + d) % 5 != 0:
                    px[x, y] = rgba("5a4632")            # the broken outline along the tear
                else:
                    px[x, y] = rgba(PAPER["l"])
            elif d <= edge + fibres.get(y, 0):
                px[x, y] = rgba(PAPER["l"] if d == edge + 1 else PAPER["2"], 220)   # a loose fibre
            elif d <= edge + 2:
                px[x, y] = (12, 8, 4, 105)               # the remnant's shadow on the endpaper
            elif d <= edge + 4:
                px[x, y] = (12, 8, 4, 50)
    save(img, "torn_l.png" if left else "torn_r.png")


def feather():
    # A crow's feather in faded ink, drawn as a sketch: the quill, the vane's outline and a few barbs.
    rows = [
        "........................",
        "...................oo...",
        ".................oo..o..",
        "...............oo...o...",
        ".............oo.-..o....",
        "............o..-..o.....",
        "..........oo.-...o......",
        ".........o..-...o.......",
        "........o.-.-..o........",
        ".......o.-.-..o.........",
        "......o.-.-..o..........",
        ".....o.-.-..o...........",
        ".....o-.-..o............",
        "....o.-...o.............",
        "....o-...o..............",
        "....o-..o...............",
        "....oo.o................",
        "....-oo.................",
        "...-....................",
        "..-.....................",
        ".-......................",
        "........................",
        "........................",
        "........................",
    ]
    img = canvas(24, 24)
    px = img.load()
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c == "o":
                px[x, y] = rgba("6a573c")
            elif c == "-":
                px[x, y] = rgba("8a7656")
    save(img, "feather.png")


def fleuron():
    shape = ["....o....", "..o.o.o..", "ooo.O.ooo", "..o.o.o..", "....o...."]
    img = canvas(9, 5)
    px = img.load()
    for y, row in enumerate(shape):
        for x, c in enumerate(row):
            if c == "o":
                px[x, y] = rgba(EDGE)
            elif c == "O":
                px[x, y] = rgba("8a3424")
    save(img, "fleuron.png")


if __name__ == "__main__":
    cover()
    page(False)
    page(True)
    spine()
    ribbon()
    grommet()
    endpaper()
    torn_stub(True)
    torn_stub(False)
    feather()
    fleuron()
