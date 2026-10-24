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
RESERVED = [(10, 5)] + [(c, r) for r in range(19, 23) for c in range(25, 30)]
CELLAR = (10, 5)
OLD_SPOTS = {
    "brush": [(30, 12), (12, 1), (18, 18), (38, 15), (26, 1), (22, 3), (27, 14)],
    "thicket": [(29, 19), (26, 21), (7, 4)],
    "rocks": [(35, 17), (19, 5), (21, 11), (1, 1), (38, 10), (16, 1), (15, 22), (36, 12)],
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
    assert len(grid) == 24 and all(len(row) == 40 for row in grid), "grid must be 24 rows of 40"
    plots = sorted(components(grid, "S") + components(grid, "F"), key=lambda p: (rect_of(p)[1], rect_of(p)[0]))
    fallow = components(grid, "F")
    fallow.sort(key=lambda p: (rect_of(p)[1], rect_of(p)[0]))
    soil = sorted(components(grid, "S"), key=lambda p: rect_of(p)[1])
    plot_one = rect_of(soil[0])
    plot_two = rect_of(soil[1])
    plot_three = next(rect_of(p) for p in fallow if rect_of(p)[1] < 17)
    house = rect_of(find(grid, "H") + find(grid, "O"))  # roof and body together
    porch = find(grid, "R")[0]
    well = find(grid, "W")[0]
    stall = find(grid, "A")[0]
    big = rect_of(find(grid, "B"))
    groves = find(grid, "G")
    grass = lambda p: grid[p[1]][p[0]] == "."  # noqa: E731
    free = lambda p: grass(p) and p not in RESERVED  # noqa: E731
    d = {
        "terrain": grid,
        "plot_one": plot_one,
        "plot_two": plot_two,
        "plot_three": plot_three,
        "house": (house[0], house[1], house[2] - house[0] + 1, house[3] - house[1] + 1),
        "porch": (porch[0], porch[1], 1, 1),
        "well": well,
        "stall": stall,
        "cellar": CELLAR,
        "workshop": (25, 19, 5, 4),
        "big_inner": (big[0], big[1]),
        "lake_focus": (32.6, 5.6),
        "groves": groves,
        "willows": [p for p in [(24, 4), (28, 11), (32, 13)] if p in groves],
        "brush": [p for p in OLD_SPOTS["brush"] if free(p)],
        "thicket": [p for p in OLD_SPOTS["thicket"] if free(p)],
        "rocks": [p for p in OLD_SPOTS["rocks"] if free(p)],
        "reserved": RESERVED,
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
