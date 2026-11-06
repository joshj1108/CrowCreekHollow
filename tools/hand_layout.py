"""Regenerate scripts/farm_layout.gd from tools/farm_grid.txt, the hand-kept grid of the farm.

Each character is one inner tile (see the TERRAIN codes in the header this writes). Since FARM-001 the grid is the
playable concept farm (written once by tools/concept_grid.py from the W-4 layout and tools/concept_farm.gd); edit
the grid, then run this. Anchors are read from the grid; grove trees, brush, thicket and rock spots are picked by a
fixed hash so the output is stable.
Usage: python3 tools/hand_layout.py [--out scripts/farm_layout.gd]
"""
import argparse
import hashlib
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
INNER_W, INNER_H = 64, 40
WALK = ".PRbkSF"   # codes the farmer walks on (the door and cave mouth are step triggers)
# Quiet ground kept clear of brush and rocks: the cabin front and well, round the garden, the road by the gate,
# and the orchard (its floor is for windfalls).
CALM = [(33, 9, 56, 18), (40, 17, 62, 31), (12, 32, 59, 36), (6, 17, 21, 27)]
# Fixed spots, in inner tiles, checked against the grid below.
WALKER = (58, 34)    # walkers wait on the road just inside the east gate
ARRIVE = (55, 34)    # back from a trek (or a fall) on the road inside the gate
PEDLAR = (57, 33)    # the pedlar's cart beside the farm stand


def h(x, y, k=0):
    return int(hashlib.md5(("%d,%d,%d" % (x, y, k)).encode()).hexdigest()[:8], 16)


def components(grid, codes):
    cells = {(c, r) for r, row in enumerate(grid) for c, ch in enumerate(row) if ch in codes}
    out = []
    while cells:
        seed = cells.pop()
        stack, comp = [seed], [seed]
        while stack:
            c, r = stack.pop()
            for n in ((c + 1, r), (c - 1, r), (c, r + 1), (c, r - 1)):
                if n in cells:
                    cells.remove(n)
                    stack.append(n)
                    comp.append(n)
        out.append(comp)
    return out


def rect_of(cells):
    xs = [c for c, _ in cells]
    ys = [r for _, r in cells]
    return (min(xs), min(ys), max(xs) - min(xs) + 1, max(ys) - min(ys) + 1)


def find(grid, code):
    return [(c, r) for r, row in enumerate(grid) for c, ch in enumerate(row) if ch == code]


def at(grid, p):
    x, y = p
    return grid[y][x] if 0 <= x < INNER_W and 0 <= y < INNER_H else "T"


def calm(p):
    return any(x0 <= p[0] <= x1 and y0 <= p[1] <= y1 for x0, y0, x1, y1 in CALM)


def spread(cands, n, gap, k, taken=()):
    """Up to n candidates, at least `gap` tiles (Chebyshev) from each other and from `taken`, in hash order."""
    out = []
    for p in sorted(cands, key=lambda p: h(p[0], p[1], k)):
        if all(max(abs(p[0] - q[0]), abs(p[1] - q[1])) >= gap for q in out + list(taken)):
            out.append(p)
            if len(out) == n:
                break
    return sorted(out, key=lambda p: (p[1], p[0]))


def build(grid):
    assert len(grid) == INNER_H and all(len(row) == INNER_W for row in grid), "grid must be %d rows of %d" % (INNER_H, INNER_W)
    beds = sorted(components(grid, "SF"), key=lambda p: (rect_of(p)[1], rect_of(p)[0]))
    assert len(beds) == 4, "expected four fields, found %d" % len(beds)
    plots = [rect_of(b) for b in beds]   # NW, NE, SW, SE
    house = rect_of(find(grid, "H") + find(grid, "O"))
    porch = find(grid, "R")[0]
    door = find(grid, "D")
    assert door == [(house[0] + house[2] // 2, house[1] + house[3] - 1)], "the door must sit mid-way along the bottom wall"
    well = min(find(grid, "W"))
    stall = min(find(grid, "A"), key=lambda p: (p[1], p[0]))
    big = rect_of(find(grid, "B") + find(grid, "b"))
    water = find(grid, "~")
    orchard = sorted(find(grid, "o"), key=lambda p: (p[1], p[0]))
    cellar = (house[0] - 2, house[1] + 2)
    for name, p, ok in [("cellar", cellar, "."), ("walker", WALKER, "P"), ("arrive", ARRIVE, "P"), ("pedlar", PEDLAR, ".P")]:
        assert at(grid, p) in ok, "%s spot %s is on %r" % (name, p, at(grid, p))
    # Grove trees: forest tiles on the clearing's edge, facing open grass the farmer can reach from the porch, away
    # from the cave, the house and the gate.
    reach = {(porch[0], porch[1] + 1)}
    todo = list(reach)
    while todo:
        cx, cy = todo.pop()
        for n in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if n not in reach and at(grid, n) in WALK:
                reach.add(n)
                todo.append(n)
    edge = [(x, y) for y in range(INNER_H) for x in range(INNER_W) if grid[y][x] == "T"
            and any(at(grid, n) == "." and n in reach for n in ((x, y + 1), (x + 1, y), (x - 1, y), (x, y - 1)))
            and not (x <= 23 and y <= 10) and not (x >= 52 and y >= 30) and not (36 <= x <= 54 and y <= 4)]
    groves = spread(edge, 12, 6, 1)
    # Brush, a thicket and breakable rocks on open grass with grass all round, out of the calm zones.
    free = [(x, y) for y in range(1, INNER_H - 1) for x in range(1, INNER_W - 1)
            if all(grid[y + dy][x + dx] == "." for dy in (-1, 0, 1) for dx in (-1, 0, 1)) and not calm((x, y)) and (x, y) in reach
            and (x, y) != cellar]
    thicket = spread(free, 1, 4, 2)
    brush = spread(free, 7, 4, 3, thicket)
    rocks = spread(free, 8, 4, 4, thicket + brush)
    # The workshop's first spot (kept only for very old saves): the 7 by 6 open-grass block nearest the door.
    ww, wh = 7, 6
    best = None
    for y in range(INNER_H - wh):
        for x in range(INNER_W - ww):
            if all(grid[y + j][x + i] == "." for j in range(wh) for i in range(ww)):
                d = abs(x + 3 - door[0][0]) + abs(y - door[0][1])
                if best is None or d < best[0]:
                    best = (d, (x, y, ww, wh))
    assert best, "no 7 by 6 block of open grass for the workshop"
    workshop = best[1]
    wx, wy, _, _ = workshop
    reserved = sorted([cellar] + [(c, r) for r in range(wy, wy + wh) for c in range(wx, wx + ww)])
    return {
        "terrain": grid, "plots": plots, "house": house, "porch": porch, "well": well, "stall": stall,
        "cellar": cellar, "workshop": workshop, "big_inner": (big[0], big[1]),
        "lake_focus": (sum(p[0] for p in water) / len(water), sum(p[1] for p in water) / len(water)),
        "groves": groves,
        "willows": [g for g in groves if any(abs(g[0] - w[0]) <= 2 and abs(g[1] - w[1]) <= 2 for w in water)],
        "orchard": orchard, "brush": [p for p in brush if p not in thicket], "thicket": thicket, "rocks": rocks,
        "reserved": reserved, "walker": WALKER, "arrive": ARRIVE, "pedlar": PEDLAR,
    }


def emit(d, out_path):
    def v2(p):
        return "Vector2i(%d, %d)" % (p[0], p[1])

    def list_(items):
        return "[" + ", ".join(v2(p) for p in items) + "]"

    def r2(r):
        return "Rect2i(%d, %d, %d, %d)" % r

    stamp = hashlib.sha1(repr(sorted((k, repr(v)) for k, v in d.items())).encode()).hexdigest()[:8]
    rows = ",\n\t".join('"%s"' % "".join(r) for r in d["terrain"])
    x, y, w, hh = d["workshop"]
    hx, hy, hw, hh2 = d["house"]
    p1, p2, p3, p4 = d["plots"]
    src = f'''class_name FarmLayout
extends RefCounted

# The farm layout. Generated from tools/farm_grid.txt by tools/hand_layout.py; regenerate rather than editing by hand.
# Coordinates are inner farm tiles: 0,0 is the top-left inner tile, inside the border. Since FARM-001 this is the
# concept farm (W-4 layout b): its own forest rings the clearing inside the inner area.
#
# TERRAIN codes, one character per tile:
#   . grass     T forest (blocks)      G grove tree (blocks, felled for wood)
#   P path (cobbles, walkways, open gates)     ~ water     k dock over the water (walkable)     R porch boards
#   H house wall     O roof (walkable, drawn over the farmer)     D door     A farm stand (3 by 2)     W well (2 by 2)
#   S soil (field one)     F fallow (fields two to four, opened by Farming level)
#   C cave mouth     K hillside rock (blocks)     X fence and the closed east gate (blocks)
#   Z prop (blocks: boulders, log piles, the mailbox, the lantern post, the house's dressing)
#   o orchard tree (blocks)     B great oak base (3 by 3, not felled)     b the oak's walkable top row (grass)

const TERRAIN := [
	{rows},
]

const PLOT_ONE := {r2(p1)}
const PLOT_TWO := {r2(p2)}
const PLOT_THREE := {r2(p3)}
const PLOT_FOUR := {r2(p4)}
const HOUSE_IX := {hx}
const HOUSE_IY := {hy}
const HOUSE_W := {hw}
const HOUSE_H := {hh2}
const PORCH_RECT := Rect2i({d["porch"][0]}, {d["porch"][1]}, 1, 1)
const WELL_IX := {v2(d["well"])}
const STALL_IX := {d["stall"][0]}
const STALL_IY := {d["stall"][1]}
const CELLAR_IX := {v2(d["cellar"])}
const WORKSHOP_RECT := Rect2i({x}, {y}, {w}, {hh})
const BIG_TREE_INNER := {v2(d["big_inner"])}
const LAKE_FOCUS := Vector2({d["lake_focus"][0]:.1f}, {d["lake_focus"][1]:.1f})
const GROVE_SPOTS := {list_(d["groves"])}
const WILLOW_TREES := {list_(d["willows"])}
const DEAD_TREES := []
const ORCHARD_TREES := {list_(d["orchard"])}
const BRUSH_SPOTS := {list_(d["brush"])}
const THICKET_SPOTS := {list_(d["thicket"])}
const ROCK_SPOTS := {list_(d["rocks"])}
# Where walkers wait for a trek (on the road inside the east gate), where you come back to, and the pedlar's cart.
const WALKER_SPOT := {v2(d["walker"])}
const ARRIVE_IX := {v2(d["arrive"])}
const PEDLAR_SPOT := {v2(d["pedlar"])}
# Farm tiles that the coop and barn must not be placed on, so they never overlap a building the player unlocks later.
const RESERVED := {list_(d["reserved"])}
# Changes whenever the layout changes. Saves record it, so a save from another layout is migrated.
const VERSION := "{stamp}"
'''
    with open(out_path, "w", newline="\n") as f:
        f.write(src)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--grid", default=os.path.join(HERE, "farm_grid.txt"))
    ap.add_argument("--out", default=os.path.join(ROOT, "scripts", "farm_layout.gd"))
    a = ap.parse_args()
    grid = [line.rstrip("\r\n") for line in open(a.grid) if line.strip()]
    grid = [list(r) for r in grid]
    d = build(grid)
    for gx, gy in d["groves"]:
        grid[gy][gx] = "G"
    emit(d, a.out)
    print("wrote", a.out)
    print("plots", d["plots"], "groves", len(d["groves"]), "brush", len(d["brush"]), "rocks", len(d["rocks"]), "workshop", d["workshop"])


if __name__ == "__main__":
    main()
