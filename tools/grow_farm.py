#!/usr/bin/env python3
"""Spread the 40 by 24 farm layout out to 64 by 40 and write scripts/farm_layout.gd.

The farmer sprite is a full tile wide, so the old farm felt cramped. The features move to spots
scaled up to the new farm, so there is more open ground between them. The farmhouse, the plots and
the well are bigger to suit the farmer (HOUSE_*, PLOTS, WELL_*); the stall, cave and great tree keep
their size. The pond is scaled up 1.4 times. The main path is redrawn to join the cave, the porch
and the dock. Brush, rocks and trees are moved the same way and nudged onto open grass; a few more
grove trees fill the extra room.

Usage:
  git show 1f113a0:scripts/farm_layout.gd > old_layout.gd
  python tools/grow_farm.py --old old_layout.gd [--out scripts/farm_layout.gd] [--preview]

--old must be the 40 by 24 layout. This was a one-off resize: its terrain became tools/farm_grid.txt.
From here, edit the grid and regenerate with tools/hand_layout.py.
"""
import argparse
import hashlib
import re
import sys
from collections import deque

OLD_W, OLD_H = 40, 24
W, H = 64, 40
SX, SY = W / OLD_W, H / OLD_H
POND_SCALE = 1.4
EXTRA_GROVES = 8
# The farmhouse sprite is 12 tiles wide; its walls cover 11 tiles. Five rows of roof, two of wall.
HOUSE_W, HOUSE_ROOF_ROWS, HOUSE_WALL_ROWS = 11, 5, 2
STALL_AT = (35, 11)
# Plot one, plot two and plot three: x, y, width, height.
PLOTS =[(3, 19, 15, 7), (3, 31, 15, 6), (29, 23, 12, 6)]
WELL_AT, WELL_SIZE = (22, 24), 2
BLOCKING = set("GBXKWAHOCD~")


def read_old(path):
    src = open(path, encoding="utf-8").read()
    rows = re.findall(r'^\t"([^"]*)",$', src, re.M)
    assert len(rows) == OLD_H and all(len(r) == OLD_W for r in rows), "old layout is not 40 by 24"

    def rect(name):
        m = re.search(r"const %s := Rect2i\((\d+), (\d+), (\d+), (\d+)\)" % name, src)
        return tuple(int(v) for v in m.groups())

    def vec(name):
        m = re.search(r"const %s := Vector2i\((\d+), (\d+)\)" % name, src)
        return tuple(int(v) for v in m.groups())

    def vecs(name):
        m = re.search(r"const %s := \[(.*)\]" % name, src)
        return [tuple(int(v) for v in p) for p in re.findall(r"Vector2i\((\d+), (\d+)\)", m.group(1))]

    def num(name):
        return int(re.search(r"const %s := (\d+)" % name, src).group(1))

    return {
        "rows": rows,
        "plots": [rect("PLOT_ONE"), rect("PLOT_TWO"), rect("PLOT_THREE")],
        "house": (num("HOUSE_IX"), num("HOUSE_IY"), num("HOUSE_W"), num("HOUSE_H")),
        "porch": rect("PORCH_RECT"),
        "well": vec("WELL_IX"),
        "stall": (num("STALL_IX"), num("STALL_IY")),
        "cellar": vec("CELLAR_IX"),
        "workshop": rect("WORKSHOP_RECT"),
        "big": vec("BIG_TREE_INNER"),
        "groves": vecs("GROVE_SPOTS"),
        "brush": vecs("BRUSH_SPOTS"),
        "thicket": vecs("THICKET_SPOTS"),
        "rocks": vecs("ROCK_SPOTS"),
    }


def scaled(p):
    return (min(W - 1, round(p[0] * SX)), min(H - 1, round(p[1] * SY)))


def grow(old):
    rows = old["rows"]
    grid = [["."] * W for _ in range(H)]

    def copy_block(x0, y0, x1, y1, nx, ny, keep="", skip_grass=True):
        # Copies old tiles x0..x1, y0..y1 to nx, ny. Only the codes in keep are copied (all when empty).
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                c = rows[y][x]
                if (keep and c not in keep) or (skip_grass and c == "."):
                    continue
                grid[ny + y - y0][nx + x - x0] = c

    # Cave and its rocks stay on the west edge, lower down. Its path stub is kept.
    cave_at = (0, 5)
    copy_block(0, 3, 5, 8, *cave_at, keep="KCP")
    # The house: HOUSE_ROOF_ROWS of walkable roof (the sprite is drawn over the player there), then
    # HOUSE_WALL_ROWS of wall with the door in the middle of the bottom row, then the porch below the door.
    hx, hy = old["house"][:2]
    house_at = (19, 5)
    hw, hh = HOUSE_W, HOUSE_ROOF_ROWS + HOUSE_WALL_ROWS
    for y in range(hh):
        for x in range(hw):
            grid[house_at[1] + y][house_at[0] + x] = "O" if y < HOUSE_ROOF_ROWS else "H"
    door = (house_at[0] + hw // 2, house_at[1] + hh - 1)
    grid[door[1]][door[0]] = "D"
    grid[door[1] + 1][door[0]] = "R"
    dx, dy = house_at[0] - hx, house_at[1] - hy
    house = (house_at[0], house_at[1], hw, hh)
    porch = (door[0], door[1] + 1, 1, 1)
    cellar = (house_at[0] - 2, house_at[1] + 2)
    # Market stall, 2 by 2.
    sx, sy = old["stall"]
    stall_at = STALL_AT
    copy_block(sx, sy, sx + 1, sy + 1, *stall_at, keep="A")
    stall = stall_at

    # Pond: the block from column 26 to the east edge, scaled up, against the north-east corner.
    px0, py0, px1, py1 = 26, 0, OLD_W - 1, 11
    pw, ph = round((px1 - px0 + 1) * POND_SCALE), round((py1 - py0 + 1) * POND_SCALE)
    pond_at = (W - pw, 0)
    for y in range(ph):
        for x in range(pw):
            c = rows[py0 + int(y / POND_SCALE)][px0 + int(x / POND_SCALE)]
            if c in "~P":
                grid[pond_at[1] + y][pond_at[0] + x] = c
    # Clear any pond tiles on the farm's top row and east column, so the edge stays walkable.
    dock = [(x, y) for y in range(H) for x in range(W) if grid[y][x] == "P" and x >= pond_at[0]]
    water = [(x, y) for y in range(H) for x in range(W) if grid[y][x] == "~"]

    # Plots, the well and the workshop's reserved ground move to their spots. The plots are bigger
    # than before, filled with the old plot's soil or fallow.
    plots = []
    for (x, y, w, h), (nx, ny, nw, nh) in zip(old["plots"], PLOTS):
        code = rows[y][x]
        for yy in range(ny, ny + nh):
            for xx in range(nx, nx + nw):
                grid[yy][xx] = code
        plots.append((nx, ny, nw, nh))
    well = WELL_AT
    for yy in range(well[1], well[1] + WELL_SIZE):
        for xx in range(well[0], well[0] + WELL_SIZE):
            grid[yy][xx] = "W"
    big = (50, 28)
    # BIG_TREE_INNER is the top-left of the 3 by 3 block: the walkable top row, then two rows of base.
    copy_block(old["big"][0], old["big"][1], old["big"][0] + 2, old["big"][1] + 2, *big, keep="bB")
    workshop = (40, 32, old["workshop"][2], old["workshop"][3])

    # The main path: from the cave's stub east along one row, past the porch, to the dock.
    path_y = porch[1] + 1
    cave_path = [(x, y) for y in range(H) for x in range(12) if grid[y][x] == "P"]
    start_x = min(x for x, y in cave_path if y == max(yy for _, yy in cave_path))
    for y in range(max(y for _, y in cave_path), path_y + 1):
        grid[y][start_x] = "P"
    dock_x = min(x for x, _ in dock)
    dock_y = max(y for _, y in dock)
    path_end = max([x for x, y in dock if y == path_y] + [dock_x])
    for x in range(start_x, path_end + 1):
        if grid[path_y][x] in ".P":
            grid[path_y][x] = "P"
    for y in range(min(dock_y, path_y), max(dock_y, path_y) + 1):
        if grid[y][dock_x] == ".":
            grid[y][dock_x] = "P"
    # The porch steps down onto the path.
    grid[porch[1]][porch[0] + 1] = "P"

    def free(x, y, r=1):
        return all(0 <= xx < W and 0 <= yy < H and grid[yy][xx] == "." for xx in range(x - r, x + r + 1) for yy in range(y - r, y + r + 1))

    workshop_cells = {(x, y) for x in range(workshop[0], workshop[0] + workshop[2]) for y in range(workshop[1], workshop[1] + workshop[3])}
    taken = set(workshop_cells) | {cellar}
    # Keep the ground around the start tile, the portal and the homestead arrival open.
    keep_open = {(W // 2, H // 2), (W - 1, H // 2), (W - 3, H // 2), (W - 2, H // 2)}
    for (x, y) in keep_open:
        assert grid[y][x] == ".", "start, portal or arrival tile is not open: %s" % ((x, y),)

    def place(points, r=1, gap=3):
        out = []
        for p in points:
            p = scaled(p)
            best = None
            for d in range(0, 8):
                for yy in range(p[1] - d, p[1] + d + 1):
                    for xx in range(p[0] - d, p[0] + d + 1):
                        if max(abs(xx - p[0]), abs(yy - p[1])) != d or not (1 <= xx < W - 1 and 1 <= yy < H - 1):
                            continue
                        if not free(xx, yy, r) or (xx, yy) in taken or any(abs(xx - a) + abs(yy - b) < gap for a, b in taken | keep_open):
                            continue
                        best = (xx, yy)
                        break
                    if best:
                        break
                if best:
                    break
            if best is None:
                raise SystemExit("no room near %s" % (p,))
            out.append(best)
            taken.add(best)
        return out

    groves = place(old["groves"], r=0, gap=3)
    for g in groves:
        grid[g[1]][g[0]] = "G"
    # More grove trees for the extra room, spread over open grass.
    cands = [(x, y) for y in range(1, H - 1) for x in range(1, W - 1) if free(x, y, 1)]
    cands.sort(key=lambda p: (p[0] * 73 + p[1] * 151) % 997)
    added = 0
    for p in cands:
        if added == EXTRA_GROVES:
            break
        if p in taken or any(abs(p[0] - a) + abs(p[1] - b) < 6 for a, b in taken | keep_open):
            continue
        grid[p[1]][p[0]] = "G"
        groves.append(p)
        taken.add(p)
        added += 1
    brush = place(old["brush"])
    thicket = place(old["thicket"])
    rocks = place(old["rocks"])

    willows = [g for g in groves if any(abs(g[0] - w[0]) <= 2 and abs(g[1] - w[1]) <= 2 for w in water)]
    lake_focus = (sum(p[0] for p in water) / len(water), sum(p[1] for p in water) / len(water))
    door = next((x, y) for y in range(H) for x in range(W) if grid[y][x] == "D")

    # Everything the player needs must be reachable on foot from the porch.
    walk = set()
    q = deque([(porch[0], porch[1])])
    walk.add(q[0])
    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if 0 <= nx < W and 0 <= ny < H and (nx, ny) not in walk and grid[ny][nx] not in BLOCKING:
                walk.add((nx, ny))
                q.append((nx, ny))
    targets = {"well": [well], "stall": [stall], "door": [door], "dock": dock, "start": [(W // 2, H // 2)], "portal": [(W - 1, H // 2)]}
    for i, (x, y, w, h) in enumerate(plots):
        targets["plot %d" % (i + 1)] = [(xx, yy) for yy in range(y, y + h) for xx in range(x, x + w)]
    for name, cells in targets.items():
        if not any(p in walk or any((p[0] + a, p[1] + b) in walk for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))) for p in cells):
            raise SystemExit("%s cannot be reached on foot" % name)

    return {
        "terrain": ["".join(r) for r in grid],
        "plots": plots, "house": house, "porch": porch, "well": well, "stall": stall, "cellar": cellar,
        "workshop": workshop, "big_inner": big, "lake_focus": lake_focus, "groves": groves, "willows": willows,
        "brush": brush, "thicket": thicket, "rocks": rocks, "reserved": sorted(workshop_cells | {cellar}),
    }


def emit(d, out_path):
    rows = ",\n\t".join('"%s"' % r for r in d["terrain"])

    def v2(p):
        return "Vector2i(%d, %d)" % (p[0], p[1])

    def list_(items):
        return "[" + ", ".join(v2(p) for p in items) + "]"

    def r2(r):
        return "Rect2i(%d, %d, %d, %d)" % r

    stamp = hashlib.sha1(repr(sorted((k, repr(v)) for k, v in d.items())).encode()).hexdigest()[:8]
    x, y, w, h = d["workshop"]
    hx, hy, hw, hh = d["house"]
    src = f'''class_name FarmLayout
extends RefCounted

# The farm layout, 64 by 40 inner tiles. Spread out from the old 40 by 24 farm by tools/grow_farm.py;
# edit by hand from here.
# Coordinates are inner farm tiles: 0,0 is the top-left walkable tile, inside the tree border.
#
# TERRAIN codes, one character per tile:
#   . grass     S soil (plot one)     F fallow (plots two and three, cleared later)
#   P path      ~ water               R porch boards
#   H house     O roof (house top)    D door    A market stall     W well
#   C cave mouth                      K rock (blocks)    X fence (blocks)
#   G grove tree (felled for wood)    B great tree base (3 by 3, not felled)
#   b great tree's walkable top row (grass)

const TERRAIN := [
	{rows},
]

const PLOT_ONE := {r2(d["plots"][0])}
const PLOT_TWO := {r2(d["plots"][1])}
const PLOT_THREE := {r2(d["plots"][2])}
const HOUSE_IX := {hx}
const HOUSE_IY := {hy}
const HOUSE_W := {hw}
const HOUSE_H := {hh}
const PORCH_RECT := {r2(d["porch"])}
const WELL_IX := {v2(d["well"])}
const STALL_IX := {d["stall"][0]}
const STALL_IY := {d["stall"][1]}
const CELLAR_IX := {v2(d["cellar"])}
const SMOKEHOUSE_IX := {v2((x + 3, y + 1))}
const FURNACE_IX := {v2((x + 1, y + 1))}
const WORKSHOP_RECT := {r2(d["workshop"])}
const WORKSHOP_DOOR := {v2((x + 2, y + h - 1))}
const WOODSTORE_IX := {v2((x + 1, y + 2))}
const CHOPLOG_IX := {v2((x + 3, y + 2))}
const BIG_TREE_INNER := {v2(d["big_inner"])}
const LAKE_FOCUS := Vector2({d["lake_focus"][0]:.1f}, {d["lake_focus"][1]:.1f})
const GROVE_SPOTS := {list_(d["groves"])}
const WILLOW_TREES := {list_(d["willows"])}
const DEAD_TREES := []
const BRUSH_SPOTS := {list_(d["brush"])}
const THICKET_SPOTS := {list_(d["thicket"])}
const ROCK_SPOTS := {list_(d["rocks"])}
# Farm tiles that the coop and barn must not be placed on, so they never overlap a building the player unlocks later.
const RESERVED := {list_(d["reserved"])}
# Changes whenever the layout changes. Saves record it, so a save from another layout is migrated.
const VERSION := "{stamp}"
'''
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(src)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--old", default="scripts/farm_layout.gd")
    ap.add_argument("--out", default="scripts/farm_layout.gd")
    ap.add_argument("--preview", action="store_true")
    a = ap.parse_args()
    d = grow(read_old(a.old))
    if a.preview:
        for i, row in enumerate(d["terrain"]):
            print("%2d %s" % (i, row))
    else:
        emit(d, a.out)
        print("wrote %s (groves %d, brush %d, thicket %d, rocks %d)" % (a.out, len(d["groves"]), len(d["brush"]), len(d["thicket"]), len(d["rocks"])))


if __name__ == "__main__":
    sys.exit(main())
