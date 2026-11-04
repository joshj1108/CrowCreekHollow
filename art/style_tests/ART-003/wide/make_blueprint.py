# ART-003 wider homestead: writes blueprint_wide.txt, the proposed non-production layout on the live 64x40 inner grid.
# Codes (as tools/farm_grid.txt where they exist): . grass  T forest  O roof  H wall  D door  R porch  d house dressing
# b/B oak base (walkable top row / blocking)  r boulders round the oak  W well  c cobbles  P path  X fence  g gate
# S garden bed  w garden walkway  o orchard tree  ~ water  k dock  K dock over water (W-3 pond)  L lantern post
# (stand-in for an earned lamp)
import sys
W, H = 64, 40
# Optional V1 framing variant: python3 make_blueprint.py OUT HOUSE_DY OAK_DX (default blueprint_wide.txt 0 0).
# A fourth argument, w3, gives ART-003 W-3's irregular pond with a dock instead of W-1's ellipse:
#   python3 make_blueprint.py blueprint_wide_v1b_w3.txt 1 1 w3
OUT = sys.argv[1] if len(sys.argv) > 1 else 'blueprint_wide.txt'
HD = int(sys.argv[2]) if len(sys.argv) > 2 else 0
OD = int(sys.argv[3]) if len(sys.argv) > 3 else 0
W3 = len(sys.argv) > 4 and sys.argv[4] == 'w3'
g = [['.'] * W for _ in range(H)]

def put(x, y, c):
    if 0 <= x < W and 0 <= y < H:
        g[y][x] = c

def rect(x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            put(x, y, c)

def h(x, y, k=0):
    return (x * 73856093 ^ y * 19349663 ^ k * 83492791) & 0xffff

# Forest frame: two tiles all round, biting in by up to three more, irregularly.
for x in range(W):
    for y in range(2 + h(x, 0) % 3):
        put(x, y, 'T')
    for y in range(2 + h(x, 1) % 3):
        put(x, H - 1 - y, 'T')
for y in range(H):
    for x in range(2 + h(0, y, 2) % 3):
        put(x, y, 'T')
    for x in range(2 + h(1, y, 3) % 3):
        put(W - 1 - x, y, 'T')
# Bigger bites, so the edge reads as forest and not a wall.
for (x0, y0, x1, y1) in [(2, 2, 5, 9), (58, 2, 61, 6), (2, 14, 4, 18), (59, 31, 61, 36), (24, 2, 27, 4), (30, 35, 34, 37)]:
    rect(x0, y0, x1, y1, 'T')

# Pond (south-west) with a dock.
if not W3:
    for y in range(29, 37):
        for x in range(3, 18):
            if ((x - 10) / 7.2) ** 2 + ((y - 32.6) / 3.6) ** 2 <= 1.0:
                put(x, y, '~')
    rect(15, 31, 18, 31, 'k')
else:
    # W-3: water spans per row, stepped so no shore runs straight for more than 3 tiles: two coves on the north
    # shore, a point at the north-east, a lobe running south-west, and a notch where the dock (2 x 4 tiles, K, water
    # underneath, walkable) meets the road's end at row 34.
    SPANS = {28: [(7, 9), (12, 14)], 29: [(5, 15)], 30: [(3, 15)], 31: [(3, 16)], 32: [(2, 16)],
             33: [(3, 11), (13, 14)], 34: [(4, 8)], 35: [(5, 7)]}
    for y, spans in SPANS.items():
        for (x0, x1) in spans:
            for x in range(x0, x1 + 1):
                if g[y][x] == '.':
                    put(x, y, '~')
    rect(13, 30, 14, 33, 'K')
    # Check: no straight shore run longer than 3 tiles, along rows or columns.
    wet = lambda x, y: 0 <= x < W and 0 <= y < H and g[y][x] in '~K'
    worst = 0
    for y in range(H):
        for side in (-1, 1):
            run = 0
            for x in range(W + 1):
                run = run + 1 if x < W and wet(x, y) and not wet(x, y + side) else 0
                worst = max(worst, run)
    for x in range(W):
        for side in (-1, 1):
            run = 0
            for y in range(H + 1):
                run = run + 1 if y < H and wet(x, y) and not wet(x + side, y) else 0
                worst = max(worst, run)
    assert worst <= 3, 'pond shore has a straight run of %d tiles' % worst
    print('pond: longest straight shore run %d tiles' % worst, file=sys.stderr)

def line(pts, w=2):
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        n = int(max(abs(bx - ax), abs(by - ay)) * 2) + 1
        for i in range(n + 1):
            x = ax + (bx - ax) * i / n
            y = ay + (by - ay) * i / n
            for dy in range(w):
                for dx in range(w):
                    if g[int(y) + dy][int(x) + dx] in '.':
                        put(int(x) + dx, int(y) + dy, 'P')

# Paths: porch to well, well to the oak, the garden gate, the orchard, the pond and the road along the bottom.
line([(44.5, 11 + HD), (44, 13 + HD), (41, 14.5), (39.5, 15)])
line([(36, 16), (33, 16.5), (30.5 + OD, 16)])
line([(38, 18), (38.5, 21), (40, 23.5), (41, 23.5)])
line([(35.5, 17.5), (30, 19), (25, 20.5), (22, 21.5)])
line([(19, 27.5), (18.5, 29.5), (18.5, 30.5)])
# (W-3: the road ends at the dock instead of running on into the forest.)
line([(39, 24.5), (36, 28), (33, 31), (29, 33.5), (22, 34), (12 if W3 else 2, 34.5)])
line([(51, 30), (51, 32.5), (48, 34), (36, 34), (29, 33.5)])
line([(48, 34), (60, 34.5)])

# Orchard (west of centre), fenced, gate on its east side.
rect(6, 17, 21, 17, 'X'); rect(6, 27, 21, 27, 'X'); rect(6, 17, 6, 27, 'X'); rect(21, 17, 21, 27, 'X')
put(21, 21, 'g'); put(21, 22, 'g'); put(19, 27, 'g'); put(18, 27, 'g')
for (x, y) in [(9, 19), (13, 19), (17, 19), (9, 23), (13, 24), (17, 23)]:
    put(x, y, 'o')

# The garden: a fenced 19 x 13 square, four beds (two by two) with walkways between, gate on the west.
rect(42, 18, 60, 18, 'X'); rect(42, 30, 60, 30, 'X'); rect(42, 18, 42, 30, 'X'); rect(60, 18, 60, 30, 'X')
rect(43, 19, 59, 29, 'w')
for (x0, y0) in [(44, 20), (52, 20), (44, 25), (52, 25)]:
    rect(x0, y0, x0 + 6, y0 + 3, 'S')
put(42, 23, "g"); put(42, 24, "g"); put(51, 30, "g"); put(50, 30, "g")

# The oak: its 3 x 3 base (top row walkable) inside scattered boulders, in front of the house's west side.
for (x, y) in [(26, 11), (25, 13), (26, 15), (29, 16), (33, 15), (35, 13), (34, 11), (27, 9), (33, 9)]:
    put(x + OD, y, 'r')
rect(29 + OD, 11, 31 + OD, 11, 'b'); rect(29 + OD, 12, 31 + OD, 13, 'B')

# The well on a cobbled ring where the paths meet.
for y in range(14, 19):
    for x in range(35, 41):
        if ((x - 37.5) / 2.8) ** 2 + ((y - 16) / 2.2) ** 2 <= 1.0:
            put(x, y, 'c')
rect(37, 15, 38, 16, 'W')

# The farmhouse: the live footprint (11 wide; 5 roof rows, 2 wall rows, door in the middle), porch below.
rect(40, 4 + HD, 50, 8 + HD, 'O'); rect(40, 9 + HD, 50, 10 + HD, 'H'); put(45, 10 + HD, 'D'); put(45, 11 + HD, 'R')
for (x, y) in [(39, 9), (39, 10), (51, 9), (51, 10), (41, 11), (42, 11), (48, 11), (49, 11), (52, 8)]:
    put(x, y + HD, 'd')

# Lantern posts: stand-ins for lamps the player builds (no new permanent lights).
for (x, y) in [(43, 12 + HD), (41, 22)]:
    put(x, y, 'L')

open(OUT, 'w').write('\n'.join(''.join(r) for r in g) + '\n')
print('\n'.join(''.join(r) for r in g))
