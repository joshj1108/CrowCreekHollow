# ART-003 W-3 polish pass (non-production, no generation): hand paint-over of the Batch B Restored house.
# ../../w3b/house/house_w3b.png (candidate C as registered) -> house_w3p_<wall>_<day|night>.png and the counts.
# The silhouette, size (192x160), door, windows, porch posts, footing line (y 149), steps and light positions are
# untouched: only colours change, plus a plank porch deck on the landing in front of the door and stone treads.
#   python polish.py   ->  three wall variants (a warm weathered, b dark weathered, c grey weathered), each with a
#                          day sprite (unlit glass, curtains) and a night sprite (the Batch B lit glass, kept)
from PIL import Image

SRC = Image.open('../../w3b/house/house_w3b.png').convert('RGBA')
W, H = SRC.size


def hsh(x, y, k=0):
    n = (x * 73856093) ^ (y * 19349663) ^ (k * 83492791)
    n = (n ^ (n >> 13)) * 1274126177
    return (n ^ (n >> 16)) & 0xFFFF


def mul(c, f, warm=0):
    return (max(0, min(255, round(c[0] * f + warm))), max(0, min(255, round(c[1] * f))),
            max(0, min(255, round(c[2] * f - warm))))


# Regions, from the colour map of house_w3b.png.
CHIMNEY = (123, 0, 143, 62)                       # x0, y0, x1, y1: the stone stack, left as it is
WINDOWS = [(39, 100, 58, 123), (134, 100, 153, 124)]   # glass of the two front windows (bounding boxes)
GABLE = (79, 71, 104, 80)                          # the gable window's glass
EAVE = 97                                         # roof above, walls below (the gable is wall-coloured)
DECK = (62, 140, 128, 146)                        # the porch floor between and past the posts: planks on the footing
LANDING = (82, 147, 111, 149)                     # Batch B's flat landing below it, stoned like the rest of the footing
STEPS_Y = 150

GLASS = {(246, 196, 90), (244, 184, 80)}
# The wall family: boards light to dark. Trim and outlines (59,42,30), (42,31,24), (36,28,34), (26,20,16) stay.
BOARD = (160, 122, 76)
WALL = [(178, 140, 92), BOARD, (154, 109, 66), (126, 90, 54), (122, 84, 52), (92, 65, 40), (90, 61, 38)]
# The roof family: Batch B's slate (grey, teal-grey, warm grey, purple flecks, olive flecks).
ROOF = {(44, 58, 68): (36, 40, 52), (58, 58, 58): (46, 51, 64), (94, 92, 86): (64, 70, 84),
        (138, 134, 122): (88, 94, 108), (90, 58, 106): (42, 46, 60), (30, 42, 28): (36, 40, 52),
        (46, 63, 36): (36, 40, 52), (154, 154, 74): (64, 70, 84), (156, 152, 138): (88, 94, 108),
        (76, 76, 74): (46, 51, 64)}
WORN = (28, 31, 40)          # a darker, weathered shingle
# Wall variants: brightness factor and warm push on the board family.
VARIANTS = {'a': (0.74, 6), 'b': (0.62, 4), 'c': (0.70, -2)}


def in_rect(x, y, r):
    return r[0] <= x <= r[2] and r[1] <= y <= r[3]


def build(var, day):
    f, warm = VARIANTS[var]
    img = SRC.copy()
    px = img.load()
    for y in range(H):
        for x in range(W):
            p = px[x, y]
            if p[3] < 200:
                continue
            c = p[:3]
            if in_rect(x, y, CHIMNEY) and c not in WALL:
                continue
            if c in GLASS:
                if day:
                    px[x, y] = day_glass(x, y) + (255,)
                continue
            if c in WALL and y < STEPS_Y:
                if var == 'c':   # grey weathered: half the saturation
                    g = sum(c) / 3
                    c = tuple(round(v * 0.5 + g * 0.5) for v in c)
                k = f
                if c == BOARD or p[:3] == BOARD:   # board-to-board tone, so the siding looks worn, not printed
                    board = y // 5
                    seg = (x + board * 7) // 17
                    k *= [1.0, 0.91, 1.05, 0.95][hsh(seg, board, 3) % 4]
                    if hsh(x, y, 5) % 100 < 3:
                        k *= 0.78
                px[x, y] = mul(c, k, warm) + (255,)
                continue
            if y <= EAVE and c in ROOF:
                q = ROOF[c]
                if c == (44, 58, 68) and hsh(x // 3, y // 2, 9) % 100 < 14:
                    q = WORN
                px[x, y] = q + (255,)
    deck(px)
    steps(px)
    return img


def day_glass(x, y):
    for (x0, y0, x1, y1) in WINDOWS + [GABLE]:
        if in_rect(x, y, (x0, y0, x1, y1)):
            dx, dy = x - x0, y - y0
            # Curtains drawn back to the outer edges of each front window.
            if (x0, y0) != GABLE[:2] and (dx <= 2 or x1 - x <= 3):
                return (118, 58, 46) if (dx + y) % 3 else (96, 46, 38)
            if 6 <= (dx + dy) % 22 <= 8:      # a sky reflection across the panes
                return (104, 118, 132)
            return (54, 64, 78) if dy > 2 else (40, 48, 60)
    return (54, 64, 78)


def deck(px):
    # Planks across the porch, three boards deep, on top of the stone footing; posts and outline kept.
    x0, y0, x1, y1 = DECK
    plank, light, seam = (104, 72, 44), (124, 88, 54), (58, 41, 29)
    keep = {(26, 20, 16), (36, 28, 34)}
    for y in range(y0, y1):
        for x in range(x0, x1 + 1):
            if px[x, y][3] < 200 or (px[x, y][:3] in keep and y == y0):
                continue
            row = (y - y0) // 2
            c = light if (y - y0) % 2 == 0 else plank
            if (x + row * 11) % 15 == 0:
                c = seam
            elif hsh(x // 5, row, 4) % 4 == 0:
                c = mul(c, 0.9)
            px[x, y] = c + (255,)
    for x in range(x0, x1 + 1):   # the deck's front edge
        if px[x, y1][3] > 200:
            px[x, y1] = (42, 31, 24, 255)
    lx0, ly0, lx1, ly1 = LANDING  # stone under the deck where Batch B had a flat slab: the footing's own pattern
    for y in range(ly0, ly1 + 1):
        for x in range(lx0, lx1 + 1):
            px[x, y] = px[x - 30, y]


def steps(px):
    # Three stone treads: a pale top row, mid-grey risers with joints, the outline kept.
    top, riser, joint = (146, 142, 132), (108, 104, 98), (70, 66, 62)
    for y in range(STEPS_Y, H):
        for x in range(W):
            p = px[x, y]
            if p[3] < 200 or p[:3] in {(26, 20, 16), (36, 28, 34), (42, 31, 24)}:
                continue
            tread = (y - STEPS_Y) % 3 == 0
            c = top if tread else riser
            if not tread and (x + (y - STEPS_Y) // 3 * 5) % 9 == 0:
                c = joint
            if hsh(x, y, 2) % 100 < 10:
                c = mul(c, 0.88)
            px[x, y] = c + (255,)


changed = {}
for var in VARIANTS:
    for day in (True, False):
        out = build(var, day)
        name = 'house_w3p_%s_%s.png' % (var, 'day' if day else 'night')
        out.save(name)
        a, b = SRC.load(), out.load()
        changed[name] = sum(1 for y in range(H) for x in range(W) if a[x, y] != b[x, y])
total = sum(1 for p in SRC.getdata() if p[3] > 0)
for k, v in changed.items():
    print(k, v, 'px changed of', total, '(%.1f%%, colour only except the deck and treads)' % (100 * v / total))
