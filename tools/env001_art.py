"""ENV-001 (zero-generation, NON-PRODUCTION): the hand-composed 16 px terrain family, ground accents and contact-shadow
masks for the whole-farm environment study. Every piece is placed by hand (coordinates below), not scattered by noise.
Writes art/style_tests/ENV-001/{terrain,shadows}/. The study harness (tools/env001_scene.gd) reads them; nothing in the
game reads them.
    python tools/env001_art.py
"""
import json
import math
import os

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "art", "style_tests", "ENV-001")

# --- Palette ---------------------------------------------------------------------------------------------------------
# Grass, matched to the control's grass (PixelLab meadow x1.15 = about 79,85,38) so the terrain study changes texture,
# not the value key. Five steps, warm highlights and cool darks.
G_DEEP = (40, 48, 28)
G_DARK = (56, 64, 32)
G_BASE = (72, 79, 35)
G_MID = (84, 90, 40)
G_LIT = (98, 102, 45)
G_TIP = (116, 114, 54)
BANK = (58, 52, 32)          # the turf's front face where it drops to a path
# Autumn and dry accents: muted, never near-white.
RUST = (138, 72, 38)
RUST_D = (96, 48, 30)
GOLD = (164, 116, 50)
STRAW = (126, 110, 64)
STRAW_D = (94, 82, 48)
CLOVER = (66, 84, 42)
CLOVER_L = (82, 100, 48)
# Dirt, matched to the control's path (about 115,84,56): a shaded rim, base, worn centre.
D_CREV = (58, 40, 28)
D_SH = (82, 60, 40)
D_BASE = (106, 78, 51)
D_WORN = (118, 88, 57)
D_LIT = (134, 102, 66)
PEB_L = (146, 134, 112)
PEB_M = (110, 102, 88)
PEB_D = (68, 60, 50)
CAP = (122, 78, 50)
CAP_L = (150, 100, 62)
STEM = (148, 136, 110)
T = (0, 0, 0, 0)


def rgba(c):
    return c if len(c) == 4 else c + (255,)


def blank(w, h, fill=T):
    return Image.new("RGBA", (w, h), rgba(fill))


def put(img, x, y, c, wrap=True):
    w, h = img.size
    if wrap:
        x %= w
        y %= h
    elif not (0 <= x < w and 0 <= y < h):
        return
    img.putpixel((x, y), rgba(c))


# --- Motifs (x, y, colour), drawn at a hand-chosen spot ---------------------------------------------------------------
def tuft_s(img, x, y):          # three short blades: lit tips over a dark root
    for dx, dy, c in [(0, 0, G_LIT), (2, 0, G_LIT), (1, 1, G_LIT), (0, 1, G_DARK), (2, 1, G_DARK), (1, 2, G_DARK)]:
        put(img, x + dx, y + dy, c)


def tuft_m(img, x, y):          # five blades, the middle one tallest, with a deep root shadow on the right
    for dx, dy, c in [(2, 0, G_TIP), (1, 1, G_LIT), (3, 1, G_LIT), (0, 2, G_LIT), (2, 2, G_DARK), (4, 2, G_LIT),
                      (1, 2, G_DARK), (3, 2, G_DARK), (1, 3, G_DARK), (2, 3, G_DEEP), (3, 3, G_DEEP)]:
        put(img, x + dx, y + dy, c)


def patch(img, x, y, rows, c):   # a soft broad patch: rows of (dx0, dx1) runs
    for dy, (a, b) in enumerate(rows):
        for dx in range(a, b + 1):
            put(img, x + dx, y + dy, c)


def leaf(img, x, y, c=RUST, d=RUST_D):
    for dx, dy, cc in [(0, 0, c), (1, 0, c), (1, 1, d), (2, 1, c), (0, 1, d)]:
        put(img, x + dx, y + dy, cc)


# --- Grass family -----------------------------------------------------------------------------------------------------
# G0 and G1 are the calm fills (most of the lawn, all of the calm zones); G2 has blade clumps; G3 is the autumn variant
# used toward the forest edge and under trees. Features keep a pixel clear of the tile's edge, so any two variants can
# sit side by side; the broad mid patches are placed differently in each, so neighbouring tiles don't line up.
def grass_tiles():
    tiles = []
    g0 = blank(16, 16, G_BASE)
    patch(g0, 3, 2, [(2, 5), (0, 6), (1, 6), (2, 4)], G_MID)
    patch(g0, 9, 12, [(0, 3), (1, 4)], G_DARK)
    patch(g0, 12, 5, [(0, 1), (0, 2)], G_DARK)
    tuft_s(g0, 10, 9)
    put(g0, 4, 12, G_DARK); put(g0, 5, 12, G_DARK); put(g0, 4, 11, G_LIT)
    tiles.append(g0)
    g1 = blank(16, 16, G_BASE)
    patch(g1, 8, 9, [(1, 4), (0, 5), (0, 5), (1, 3)], G_MID)
    patch(g1, 1, 12, [(1, 4), (0, 3)], G_DARK)
    patch(g1, 11, 2, [(0, 2), (1, 3)], G_DARK)
    tuft_s(g1, 3, 4)
    put(g1, 12, 3, G_LIT); put(g1, 12, 4, G_DARK)
    tiles.append(g1)
    g2 = blank(16, 16, G_BASE)
    patch(g2, 1, 9, [(1, 4), (0, 5), (1, 4)], G_MID)
    patch(g2, 7, 13, [(0, 4), (1, 5)], G_DARK)
    tuft_m(g2, 2, 2)
    tuft_m(g2, 9, 8)
    tuft_s(g2, 11, 2)
    tiles.append(g2)
    g3 = blank(16, 16, G_BASE)
    patch(g3, 6, 1, [(1, 5), (0, 6), (1, 5)], G_MID)
    patch(g3, 1, 13, [(0, 3), (1, 4)], G_DARK)
    tuft_s(g3, 2, 9)
    leaf(g3, 9, 10)
    put(g3, 5, 4, GOLD); put(g3, 6, 4, GOLD); put(g3, 6, 5, RUST_D)
    put(g3, 12, 4, G_DARK)
    tiles.append(g3)
    return tiles


# --- Dirt -------------------------------------------------------------------------------------------------------------
# One dirt fill, drawn in two keys: the shaded base near the verges and the worn, lighter centre of a trodden path.
def dirt_tile(base, low, high, pebble):
    d = blank(16, 16, base)
    for (x, y) in [(3, 3), (4, 3), (5, 4), (11, 11), (12, 11), (10, 12), (13, 6)]:   # short crevices
        put(d, x, y, low)
    for (x, y) in [(12, 3), (13, 3), (6, 10), (7, 10), (8, 10), (2, 13), (3, 13)]:   # lit grains
        put(d, x, y, high)
    for (px, py) in [pebble]:   # one pebble: lit top-left, dark lower-right (placed differently per key)
        put(d, px, py, PEB_L); put(d, px + 1, py, PEB_M); put(d, px, py + 1, PEB_M); put(d, px + 1, py + 1, PEB_D)
    return d


# --- Grass/path dual-grid set -----------------------------------------------------------------------------------------
# A tile on every vertex; its quadrants are the four map cells (NW NE SW SE), so cell boundaries run through the tile's
# middle and its edges are cell centres. The edge is a smooth field (corner values at the quadrant centres, clamped
# beyond them) plus a gentle periodic wobble, so every tile meets its neighbours exactly. The verge is then dressed by
# hand rules: the turf's front face and the shadow it throws on the path where grass lies north or west of the path,
# a lit lip where it lies south or east, a blade now and then over the edge, and a worn centre three pixels in.
def wobble(x, y, k):
    a = 0.20 * math.sin(2 * math.pi * (x / 16.0) + 1.3 + k) + 0.12 * math.sin(2 * math.pi * (2 * y / 16.0) + 0.4 + 2 * k)
    b = 0.16 * math.sin(2 * math.pi * (y / 16.0) + 2.1 - k) + 0.08 * math.sin(2 * math.pi * (3 * x / 16.0) + k)
    c = 0.07 * math.sin(2 * math.pi * ((x + 2 * y) / 16.0) + 0.9 * k)
    return a + b + c


def field(nw, ne, sw, se, x, y):
    fx = min(max((x + 0.5 - 2.0) / 12.0, 0.0), 1.0)
    fy = min(max((y + 0.5 - 2.0) / 12.0, 0.0), 1.0)
    fx = fx * fx * (3 - 2 * fx)   # smoothstep: rounder convex and concave corners
    fy = fy * fy * (3 - 2 * fy)
    top = nw + (ne - nw) * fx
    bot = sw + (se - sw) * fx
    return top + (bot - top) * fy


def path_tile(key, k, grass, dirt, worn):
    nw, ne, sw, se = (int(c) for c in key)
    P = 6   # padding, so verge rules see the neighbour tiles' pixels exactly
    n = 16 + 2 * P
    m = [[field(nw, ne, sw, se, x - P, y - P) + wobble(x - P, y - P, k) > 0.5 for x in range(n)] for y in range(n)]
    out = blank(16, 16)
    for y in range(16):
        for x in range(16):
            X, Y = x + P, y + P
            is_p = m[Y][X]
            g = lambda dx, dy: not m[Y + dy][X + dx]
            if not is_p:
                c = grass.getpixel((x, y))[:3]
                if m[Y + 1][X]:
                    c = BANK                                  # the turf's front face over a path to the south
                elif m[Y - 1][X] or m[Y][X - 1]:
                    c = G_LIT if (x * 7 + y * 3 + k) % 5 else G_TIP   # lit lip facing the light
                elif m[Y][X + 1]:
                    c = G_DARK                                # side in shade, toward a path to the east
                out.putpixel((x, y), rgba(c))
                continue
            # distance to the nearest grass, up to 4
            dist = 9
            for r in range(1, 5):
                if any(g(dx, dy) for dy in range(-r, r + 1) for dx in range(-r, r + 1) if max(abs(dx), abs(dy)) == r):
                    dist = r
                    break
            c = (worn if dist >= 4 else dirt).getpixel((x, y))[:3]
            if g(0, -1):
                c = D_CREV if (x + k) % 6 else G_DARK          # under the bank, a blade hanging over now and then
            elif g(0, -2) or g(-1, 0):
                c = D_SH
            elif dist == 1 and (x * 5 + y * 11 + k) % 4 == 0:
                c = D_SH
            out.putpixel((x, y), rgba(c))
    return out


def main():
    os.makedirs(os.path.join(OUT, "terrain"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "shadows"), exist_ok=True)
    gt = grass_tiles()
    sheet = blank(64, 16)
    for i, t in enumerate(gt):
        sheet.paste(t, (i * 16, 0))
    sheet.save(os.path.join(OUT, "terrain", "grass.png"))
    dirt = dirt_tile(D_BASE, D_SH, D_WORN, (8, 5))
    worn = dirt_tile(D_WORN, D_SH, D_LIT, (3, 9))
    ds = blank(32, 16)
    ds.paste(dirt, (0, 0)); ds.paste(worn, (16, 0))
    ds.save(os.path.join(OUT, "terrain", "dirt.png"))
    # 16 keys x 2 verge variants; index = NW*8 + NE*4 + SW*2 + SE
    wang = blank(256, 32)
    for v in range(2):
        for i in range(16):
            key = format(i, "04b")
            wang.paste(path_tile(key, 0.0 if v == 0 else 2.2, gt[0] if v == 0 else gt[1], dirt, worn), (i * 16, v * 16))
    wang.save(os.path.join(OUT, "terrain", "path_wang.png"))
    accents()
    shadows()
    pal = [G_DEEP, G_DARK, G_BASE, G_MID, G_LIT, G_TIP, BANK, RUST, RUST_D, GOLD, STRAW, STRAW_D, CLOVER, CLOVER_L,
           D_CREV, D_SH, D_BASE, D_WORN, D_LIT, PEB_L, PEB_M, PEB_D, CAP, CAP_L, STEM]
    p = blank(len(pal) * 4, 4)
    for i, c in enumerate(pal):
        for yy in range(4):
            for xx in range(4):
                p.putpixel((i * 4 + xx, yy), rgba(c))
    p.save(os.path.join(OUT, "terrain", "palette.png"))
    print("ENV-001 art written to", OUT)


# --- Accents: the only scatter on the lawn. Muted; no near-white tufts. -----------------------------------------------
def draw(rows, cmap):
    h = len(rows)
    w = max(len(r) for r in rows)
    img = blank(w, h)
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch in cmap:
                img.putpixel((x, y), rgba(cmap[ch]))
    return img


def accents():
    cm = {"*": G_TIP, "+": G_LIT, ",": G_DARK, ":": G_DEEP, "s": STRAW, "d": STRAW_D, "c": CLOVER, "C": CLOVER_L,
          "r": RUST, "R": RUST_D, "g": GOLD, "L": PEB_L, "M": PEB_M, "D": PEB_D, "k": CAP, "K": CAP_L, "t": STEM}
    pieces = [
        ["..*...*", ".*+.*+.", ".+,+,+.", ",:,:,:,"],          # 0 a full green clump (verges, forest edge)
        [".s..s", "sds.d", ".ddd."],                             # 1 a dry clump, straw not white
        [".C.C.", "CcCcC", ".c.c."],                             # 2 clover
        [".LM..", ".MD.L", "...MD"],                             # 3 two pebbles
        ["rr...", "Rrr.g", "..Rgg"],                             # 4 two fallen leaves
        [".KK..", "Kkkk.", ".t.Kk", ".t.t."],                    # 5 two small mushrooms (forest edge only)
    ]
    imgs = [draw(p, cm) for p in pieces]
    w = sum(i.width for i in imgs) + 2 * len(imgs)
    strip = blank(w, 4)
    x = 0
    for i in imgs:
        strip.paste(i, (x, 0))
        x += i.width + 2
    strip.save(os.path.join(OUT, "terrain", "accents.png"))


# --- Contact shadows --------------------------------------------------------------------------------------------------
# One convention: the key light is upper left (as the cabin's chimney and eave shadows), so shadows fall down and right.
# Two values per mask: 2 = contact (where the object meets the ground; kept, weaker, at night as occlusion) and
# 1 = cast (the sun's shadow; daytime only). Each mask is the sprite's canvas plus padding; anchor = padding (left, top).
# The harness darkens the ground under each mask pixel in the ground's own colours (a cool multiply), never as a blob.
def alpha_of(path, flip=False):
    im = Image.open(os.path.join(ROOT, path)).convert("RGBA")
    if flip:
        im = im.transpose(Image.FLIP_LEFT_RIGHT)
    return im.split()[3].load(), im.size


def bottoms(a, size, rows=None):
    w, h = size
    out = {}
    for x in range(w):
        for y in range(h - 1, -1, -1):
            if a[x, y] > 128:
                out[x] = y
                break
    return out


def save_mask(name, m, pad, notes):
    img = blank(len(m[0]), len(m))
    for y, row in enumerate(m):
        for x, v in enumerate(row):
            if v:
                img.putpixel((x, y), (255, 0, 0, 255) if v == 2 else (255, 0, 0, 128))
    img.save(os.path.join(OUT, "shadows", name + ".png"))
    return {"pad": pad, "note": notes}


def mask_grid(w, h):
    return [[0] * w for _ in range(h)]


def setv(m, x, y, v):
    if 0 <= y < len(m) and 0 <= x < len(m[0]) and v > m[y][x]:
        m[y][x] = v


def shadows():
    meta = {}
    # Cabin (VS16-P1, 192x160): a contact row under the whole footing and steps, a two-row cast band below it shifted
    # one pixel right, and a wedge on the ground east of the east wall, widening toward the base.
    a, (w, h) = alpha_of("art/style_tests/ART-005/vs16p1/cabin/house_day.png")
    pl, pt, pr, pb = 2, 0, 10, 6
    m = mask_grid(w + pl + pr, h + pt + pb)
    b = bottoms(a, (w, h))
    right = max(x for x in b)
    for x, y in b.items():
        if y < h - 14:
            continue
        setv(m, x + pl, y + pt + 1, 2)
        for k in (2, 3):
            setv(m, x + pl + 1, y + pt + k, 1)
        if (x * 3) % 7 == 0:
            setv(m, x + pl + 2, y + pt + 4, 1)   # a ragged lower edge
    for y in range(h - 34, h + 3):
        t = (y - (h - 34)) / 36.0
        width = int(round(1 + 7 * t))
        for k in range(1, width + 1):
            setv(m, right + pl + k, y + pt + (k // 3), 1)
        if y >= h - 12:
            setv(m, right + pl + 1, y + pt, 2)
    meta["cabin"] = save_mask("cabin", m, [pl, pt], "contact under the footing and steps; cast band below; wedge east")
    # Well (32x48): contact under the stone ring; an oval cast pool to the lower right.
    a, (w, h) = alpha_of("art/farm/prop_well.png")
    pl, pt, pr, pb = 2, 0, 8, 5
    m = mask_grid(w + pl + pr, h + pt + pb)
    b = bottoms(a, (w, h))
    xs = [x for x, y in b.items() if y >= h - 3]
    x0, x1 = min(xs), max(xs)
    cx, cy, rx, ry = (x0 + x1) / 2.0 + 4, h - 1.5, (x1 - x0) / 2.0 + 2, 3.6
    for y in range(h - 8, h + pb):
        for x in range(-pl, w + pr):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                setv(m, x + pl, y + pt, 1)
    for x, y in b.items():
        if y >= h - 3:
            setv(m, x + pl + 1, y + pt + 1, 2)
    meta["well"] = save_mask("well", m, [pl, pt], "contact under the ring; oval cast to the lower right")
    # The golden oak (192x192): a dappled noon pool under the crown, centred a little right of the trunk, and contact
    # under the trunk's foot and the ends of the surface roots.
    a, (w, h) = alpha_of("art/style_tests/ART-003/w3/oak/oak_w3.png")
    pl, pt, pr, pb = 8, 0, 16, 10
    m = mask_grid(w + pl + pr, h + pt + pb)
    b = bottoms(a, (w, h))
    low = max(b.values())
    foot = [x for x, y in b.items() if y >= low - 14]
    tcx = sum(foot) / len(foot)
    cx, cy, rx, ry = tcx + 12, low - 9, 70, 17
    holes = [(-40, -6, 3, 1), (-22, 5, 2, 1), (8, -10, 3, 2), (30, 3, 2, 1), (50, -4, 3, 1), (-55, 2, 2, 1),
             (18, 10, 3, 1), (-8, 12, 2, 1), (42, 9, 2, 1), (60, 6, 2, 1), (-30, -12, 2, 1)]
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            # a crown-shaped rim: the ellipse with three soft lobes, not a perfect oval
            ang = math.atan2(y - cy, x - cx)
            r = 1.0 + 0.07 * math.sin(3 * ang + 0.6) + 0.04 * math.sin(7 * ang)
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > r * r:
                continue
            if any(abs(x - (cx + hx)) <= hw and abs(y - (cy + hy)) <= hh - 1 for hx, hy, hw, hh in holes):
                continue
            setv(m, x + pl, y + pt, 1)
    for x, y in b.items():
        if y >= low - 14:
            setv(m, x + pl + 1, y + pt + 1, 2)
    meta["oak"] = save_mask("oak", m, [pl, pt], "dappled crown pool right of the trunk; contact under trunk and roots")
    # One orchard tree (apple_b, 48x64, not flipped): the same convention, smaller.
    a, (w, h) = alpha_of("art/style_tests/ART-003/w4/orchard/apple_b.png")
    pl, pt, pr, pb = 4, 0, 8, 6
    m = mask_grid(w + pl + pr, h + pt + pb)
    b = bottoms(a, (w, h))
    low = max(b.values())
    foot = [x for x, y in b.items() if y >= low - 3]
    tcx = sum(foot) / len(foot)
    cx, cy, rx, ry = tcx + 4, low - 1, 15, 4.6
    for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
        for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
            if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 > 1.0:
                continue
            if (x - int(cx), y - int(cy)) in [(-9, -2), (-8, -2), (6, 2), (7, 2), (10, -1)]:
                continue
            setv(m, x + pl, y + pt, 1)
    for x, y in b.items():
        if y >= low - 3:
            setv(m, x + pl + 1, y + pt + 1, 2)
    meta["apple_b"] = save_mask("apple_b", m, [pl, pt], "small dappled pool; contact under the trunk")
    # The log pile (19x16, drawn flipped at 35.5,15): contact under the bottom logs; a short cast of the pile's
    # outline, two rows deep, to the lower right.
    a, (w, h) = alpha_of("art/style_tests/ART-003/w4/props/logpile.png", flip=True)
    pl, pt, pr, pb = 1, 0, 5, 4
    m = mask_grid(w + pl + pr, h + pt + pb)
    b = bottoms(a, (w, h))
    for x, y in b.items():
        if y >= h - 4:
            setv(m, x + pl, y + pt + 1, 2)
            setv(m, x + pl + 1, y + pt + 2, 1)
            setv(m, x + pl + 2, y + pt + 2, 1)
            if x > w // 3:
                setv(m, x + pl + 3, y + pt + 3, 1)
    for y in range(h - 8, h):   # the pile's east end throws a short wedge
        setv(m, max(b) + pl + 1 + (y - (h - 8)) // 3, y + pt, 1)
    meta["logpile_flip"] = save_mask("logpile_flip", m, [pl, pt], "contact under the bottom logs; short wedge")
    meta["fence"] = {"pad": [0, 0], "note": "the fields' east-west fence runs: projected in the harness from each "
                     "rail sprite (a pixel h rows above the base falls h/2 right and h/4 down); contact under posts"}
    with open(os.path.join(OUT, "shadows", "shadows.json"), "w") as f:
        json.dump(meta, f, indent=1)


if __name__ == "__main__":
    main()
