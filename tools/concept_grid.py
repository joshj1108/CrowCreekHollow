"""FARM-001 (one-off): write tools/farm_grid.txt from the playable concept farm.

Reads tools/concept_layout.json (written by tools/concept_export.gd: the W-4 grid with the cave approach, the gate
overlay and every tile a concept prop blocks) and translates it to the production legend (see the header of
scripts/farm_layout.gd). After this, tools/farm_grid.txt is the source of the layout again; edit it, then run
python3 tools/hand_layout.py.
Usage: python3 tools/concept_grid.py
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

# W-4 code -> production code.
W4 = {
    ".": ".", "T": "T", "O": "O", "H": "H", "D": "D", "R": "R", "W": "W", "X": "X", "~": "~",
    "P": "P", "c": "P", "w": "P", "g": "P",   # cobbles, garden walkways and open gates are path
    "K": "k",                                  # the W-3 dock over the pond (walkable)
    "b": "b", "B": "B", "o": "o",
    "d": "Z", "r": "Z", "L": "Z",              # house dressing, boulders round the oak, the lantern post
    "S": "S",
}


def main():
    src = json.load(open(os.path.join(HERE, "concept_layout.json")))
    grid = [list(r.strip()) for r in src["grid"]]
    out = [[W4[ch] for ch in row] for row in grid]
    # The closed east gate (posts and leaves) blocks; the avenue beyond it is drawn only and stays forest.
    for key, ch in src["overlay"].items():
        x, y = map(int, key.split(","))
        if 0 <= x < 64 and 0 <= y < 40 and ch in "QG":
            out[y][x] = "X"
    # The concept's props and hillside: the hill north-west of the cave is rock, the rest are props.
    for x, y in src["blocks"]:
        if out[y][x] not in ".P":
            continue
        out[y][x] = "K" if (x <= 21 and y <= 10) else "Z"
    cx, cy = src["cave"]
    out[cy][cx] = "C"
    sx, sy = src["stall"]
    for y in range(sy, sy + 2):
        for x in range(sx, sx + 3):
            out[y][x] = "A"
    # The garden's beds: the north-west field is soil from the start, the other three fallow until they open.
    beds = sorted({(x, y) for y, r in enumerate(out) for x, c in enumerate(r) if c == "S"})
    nw = min(beds)
    for x, y in beds:
        if not (nw[0] <= x < nw[0] + 7 and nw[1] <= y < nw[1] + 4):
            out[y][x] = "F"
    with open(os.path.join(HERE, "farm_grid.txt"), "w", newline="\n") as f:
        for r in out:
            f.write("".join(r) + "\n")
    print("wrote tools/farm_grid.txt")


if __name__ == "__main__":
    main()
