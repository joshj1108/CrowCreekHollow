"""ART-005 HC1 Step 2 (zero-generation, non-production): a deliberately constructed 32 px STUDY of the 16 px well.

Not finished artist-authored art. The production well (art/farm/prop_well.png, 32x48 at 16 px per tile, unchanged) is
rebuilt at 32 art px per tile (64x96: the same 2x3-tile world size) the way a 2x re-author starts:
  1. its shapes are laid out on the doubled grid (silhouette, roof, posts, rope, crank, ring, buckets kept in place);
  2. every outline and mortar line is thinned from 2 px back to 1 px (one 32-density pixel), keeping solid dark masses
     (the shaft's opening, the shadow under the roof) solid;
  3. each stone, shingle, post and stave is re-shaded at the finer density: a lit top-left edge, a shaded bottom-right
     edge one step down its own ramp, a few speckles and grain lines, a rope twist and a glint on the water;
  4. its ramps gain the in-between steps 32 px shading needs (the 16 px well has 17 colours).

    python tools/hc2_well32.py      -> art/style_tests/ART-005/hc2/well32/prop_well_32.png
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "art/farm/prop_well.png"
OUT = ROOT / "art/style_tests/ART-005/hc2/well32"

K = (0, 0, 0)
STONE = [(33, 32, 31), (50, 49, 46), (61, 61, 58), (79, 80, 70), (91, 91, 78), (102, 101, 86), (118, 115, 98),
         (136, 132, 113), (153, 149, 127), (177, 169, 145), (194, 187, 162)]
WOOD = [(48, 36, 28), (64, 47, 36), (71, 60, 50), (93, 73, 55), (106, 83, 60), (120, 93, 64), (136, 106, 72),
        (159, 129, 88), (179, 147, 108), (196, 166, 124)]
GREY = [(90, 90, 92), (112, 111, 109), (125, 125, 126), (150, 150, 152)]   # the bucket's iron band


def ramp_of(c):
    for r in (STONE, WOOD, GREY):
        if c in r:
            return r
    return None


def step(c, d):
    r = ramp_of(c)
    if r is None:
        return c
    return r[max(0, min(len(r) - 1, r.index(c) + d))]


def h(x, y, s=0):
    v = (x * 374761393 + y * 668265263 + s * 2246822519) & 0xFFFFFFFF
    v = ((v ^ (v >> 13)) * 1274126177) & 0xFFFFFFFF
    return (v ^ (v >> 16)) / 0xFFFFFFFF


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    sw, sh = src.size
    sp = src.load()
    W, H = sw * 2, sh * 2

    def col(x, y):
        if 0 <= x < sw and 0 <= y < sh and sp[x, y][3] > 0:
            return sp[x, y][:3]
        return None

    # Connected same-colour clusters in the 16 px source (4-connected), for per-cluster shading.
    cid = {}
    sizes = {}
    n = 0
    for y in range(sh):
        for x in range(sw):
            c = col(x, y)
            if c is None or (x, y) in cid:
                continue
            stack = [(x, y)]
            cid[(x, y)] = n
            cnt = 0
            while stack:
                a, b = stack.pop()
                cnt += 1
                for na, nb in ((a + 1, b), (a - 1, b), (a, b + 1), (a, b - 1)):
                    if (na, nb) not in cid and col(na, nb) == c:
                        cid[(na, nb)] = n
                        stack.append((na, nb))
            sizes[n] = cnt
            n += 1

    # 1. The doubled grid.
    g = [[col(x // 2, y // 2) for x in range(W)] for y in range(H)]
    cl = [[cid.get((x // 2, y // 2)) for x in range(W)] for y in range(H)]

    def at(x, y):
        return g[y][x] if 0 <= x < W and 0 <= y < H else None

    DARK = (K, STONE[0])   # outline black and mortar

    # 2. Thin 2 px lines to 1 px: a dark pixel whose one side is material and whose other side is the line's second
    #    pixel (with material beyond it) takes its material neighbour's colour one step darker. Silhouette pixels
    #    (touching transparency) stay; their inner twin is thinned when it faces material.
    out = [row[:] for row in g]
    for y in range(H):
        for x in range(W):
            c = g[y][x]
            if c not in DARK:
                continue
            for (dx, dy) in ((0, -1), (-1, 0)):        # thin towards the bottom/right: the top/left twin goes
                m = at(x + dx, y + dy)
                t1 = at(x - dx, y - dy)
                t2 = at(x - 2 * dx, y - 2 * dy)
                if m is not None and m not in DARK and t1 == c and t2 is not None and t2 not in DARK:
                    out[y][x] = step(m, -1)
                    cl[y][x] = cl[y + dy][x + dx]
                    break
            else:
                # inner twin of a silhouette outline: outside on one side, material on the other
                for (dx, dy) in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    o1 = at(x - dx, y - dy)
                    m = at(x + dx, y + dy)
                    if o1 in DARK and at(x - 2 * dx, y - 2 * dy) is None and m is not None and m not in DARK \
                            and c == K:
                        out[y][x] = step(m, -1)
                        cl[y][x] = cl[y + dy][x + dx]
                        break
    g = out

    # 3. Per-cluster bevel at the finer density (clusters of 3+ source pixels; tiny ones stay flat).
    out = [row[:] for row in g]
    for y in range(H):
        for x in range(W):
            c = g[y][x]
            if c is None or c in DARK or ramp_of(c) is None:
                continue
            k = cl[y][x]
            if k is None or sizes.get(k, 0) < 3:
                continue
            same = lambda a, b: 0 <= a < W and 0 <= b < H and cl[b][a] == k and g[b][a] not in DARK
            d = 0
            lit_ok = ramp_of(c) is not STONE or STONE.index(c) >= 5   # the shaft's dark stones only take shade
            if lit_ok and (not same(x, y - 1) or not same(x - 1, y)):
                d += 1
            if not same(x, y + 1) or not same(x + 1, y):
                d -= 1
            if d == 0 and h(x, y, 1) < 0.06:   # speckle / grain
                d = -1
            out[y][x] = step(c, d)
    g = out

    # 4. A few details only the finer grid can hold.
    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H and g[y][x] is not None:
            g[y][x] = c
    # the rope: a 1 px twisted line down the shaft's centre (source column 16, rows 15..22)
    for y in range(30, 46):
        x = 32 + (1 if (y // 2) % 2 else 0)
        put(32, y, WOOD[3]); put(33, y, WOOD[1])
        put(x, y, WOOD[5])
    # a dull glint on the water far down the shaft
    for x in range(22, 28):
        put(x, 48, STONE[2])
    put(23, 47, STONE[3]); put(24, 47, STONE[3])

    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    p = im.load()
    for y in range(H):
        for x in range(W):
            if g[y][x] is not None:
                p[x, y] = g[y][x] + (255,)
    OUT.mkdir(parents=True, exist_ok=True)
    im.save(OUT / "prop_well_32.png")
    print(im.size, len({p[x, y] for x in range(W) for y in range(H) if p[x, y][3]}), "colours")


if __name__ == "__main__":
    main()
