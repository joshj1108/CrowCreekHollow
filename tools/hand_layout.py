"""Regenerate scripts/farm_layout.gd from tools/farm_grid.txt, the hand-read grid of the layout diagram.

Each character is one inner tile (see the TERRAIN codes in scripts/farm_layout.gd). Anchors are read
from the grid; brush, thicket and rock spots are the previous spots that still sit on open grass.
Usage: python3 tools/hand_layout.py [--out scripts/farm_layout.gd]
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import farm_layout as fl  # noqa: E402  (reuses the emitter)

ROOT = os.path.dirname(HERE)
INNER_W, INNER_H = 64, 40
WORKSHOP = (39, 31, 7, 6)  # walls included; the back wall is two rows, the floor 5 by 3
OLD_SPOTS = {
    "brush": [(48, 20), (19, 2), (29, 30), (61, 25), (42, 2), (35, 5), (43, 23)],
    "thicket": [(11, 7)],
    "rocks": [(56, 28), (31, 7), (34, 18), (2, 2), (61, 17), (26, 2), (24, 37), (58, 20)],
}


def components(grid, code):
    cells = {(c, r) for r, row in enumerate(grid) for c, ch in enumerate(row) if ch == code}
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
    return (min(xs), min(ys), max(xs), max(ys))


def find(grid, code):
    return [(c, r) for r, row in enumerate(grid) for c, ch in enumerate(row) if ch == code]


def build(grid):
    assert len(grid) == INNER_H and all(len(row) == INNER_W for row in grid), "grid must be %d rows of %d" % (INNER_H, INNER_W)
    fallow = components(grid, "F")
    fallow.sort(key=lambda p: (rect_of(p)[1], rect_of(p)[0]))
    soil = sorted(components(grid, "S"), key=lambda p: rect_of(p)[1])
    plot_one = rect_of(soil[0])
    plot_two = rect_of(soil[1])
    plot_three = rect_of(fallow[0])
    house = rect_of(find(grid, "H") + find(grid, "O"))  # roof and body together
    porch = find(grid, "R")[0]
    well = min(find(grid, "W"))  # the well's top-left tile; it covers 2 by 2
    stall = find(grid, "A")[0]
    big = rect_of(find(grid, "B") + find(grid, "b"))  # the 3 by 3 footprint, including its walkable top row
    groves = find(grid, "G")
    water = find(grid, "~")
    # The cellar stands two tiles west of the house, two rows down from the roof's top.
    cellar = (house[0] - 2, house[1] + 2)
    wx, wy, ww, wh = WORKSHOP
    reserved = sorted([cellar] + [(c, r) for r in range(wy, wy + wh) for c in range(wx, wx + ww)])
    grass = lambda p: grid[p[1]][p[0]] == "."  # noqa: E731
    free = lambda p: grass(p) and p not in reserved  # noqa: E731
    d = {
        "terrain": grid,
        "plot_one": plot_one,
        "plot_two": plot_two,
        "plot_three": plot_three,
        "house": (house[0], house[1], house[2] - house[0] + 1, house[3] - house[1] + 1),
        "porch": (porch[0], porch[1], 1, 1),
        "well": well,
        "stall": stall,
        "cellar": cellar,
        "workshop": WORKSHOP,
        "big_inner": (big[0], big[1]),
        "lake_focus": (sum(p[0] for p in water) / len(water), sum(p[1] for p in water) / len(water)),
        "groves": groves,
        # Willows are the grove trees within two tiles of the water.
        "willows": [g for g in groves if any(abs(g[0] - w[0]) <= 2 and abs(g[1] - w[1]) <= 2 for w in water)],
        "brush": [p for p in OLD_SPOTS["brush"] if free(p)],
        "thicket": [p for p in OLD_SPOTS["thicket"] if free(p)],
        "rocks": [p for p in OLD_SPOTS["rocks"] if free(p)],
        "reserved": reserved,
    }
    return d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--grid", default=os.path.join(HERE, "farm_grid.txt"))
    ap.add_argument("--out", default=os.path.join(ROOT, "scripts", "farm_layout.gd"))
    a = ap.parse_args()
    grid = [line.rstrip("\n") for line in open(a.grid) if line.strip()]
    fl.emit(build(grid), a.out)
    print("wrote", a.out)


if __name__ == "__main__":
    main()
