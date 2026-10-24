#!/usr/bin/env python3
"""Turn a flat layout diagram of the farm into scripts/farm_layout.gd.

The diagram is a picture of the farm's walkable land (the yellow-green area), made of
flat colour blocks. The land is sampled into a 40 by 24 grid of inner farm tiles. Each
tile takes the colour that covers most of it, matched against PALETTE. The border of
trees is not read from the picture: the game draws it from code.

Usage:
  python3 tools/farm_layout.py DIAGRAM.png [--out scripts/farm_layout.gd]
                               [--drop-grove PX,PY] [--preview]

--drop-grove removes the grove tree nearest the given picture pixel, for when the
diagram has more grove trees than the design asks for.
"""
import argparse
import sys
from collections import deque

import numpy as np
from PIL import Image

INNER_W, INNER_H = 40, 24
BORDER_X, BORDER_Y = 14, 8

# Colours measured from the diagram. Each class has its own tile character.
PALETTE = {
    "grass": ((104, 162, 77), "."),
    "tree_big": ((45, 82, 52), "B"),
    "grove": ((35, 90, 62), "G"),
    "water": ((50, 108, 173), "~"),
    "roof": ((144, 86, 54), "H"),
    "body": ((105, 75, 56), "H"),
    "stall": ((171, 120, 54), "A"),
    "path": ((198, 166, 104), "P"),
    "fence": ((127, 101, 84), "X"),
    "brown": ((121, 76, 51), "S"),
    "olive": ((78, 91, 50), "F"),
    "grey": ((115, 114, 113), "K"),
    "cave": ((44, 42, 43), "C"),
}
NAMES = list(PALETTE)
COLOURS = np.array([PALETTE[n][0] for n in NAMES], dtype=float)
MAX_DIST = 40.0  # pixels further than this from every colour are ignored
MIN_FRACTION = {"fence": 0.15}  # thin strokes need a lower share than solid blocks
DEFAULT_FRACTION = 0.4


def grass_bounds(rgb):
    dist = np.linalg.norm(rgb - COLOURS[NAMES.index("grass")], axis=2)
    mask = dist < 22
    cols = np.where(mask.mean(axis=0) > 0.3)[0]
    rows = np.where(mask.mean(axis=1) > 0.3)[0]
    return cols.min(), rows.min(), cols.max() + 1, rows.max() + 1


def classify_pixels(rgb):
    d = np.linalg.norm(rgb[:, :, None, :] - COLOURS[None, None, :, :], axis=3)
    best = d.argmin(axis=2)
    best[d.min(axis=2) > MAX_DIST] = -1
    return best


def sample_grid(labels, bounds):
    x0, y0, x1, y1 = bounds
    cw = (x1 - x0) / INNER_W
    ch = (y1 - y0) / INNER_H
    grid = [["grass"] * INNER_W for _ in range(INNER_H)]
    for iy in range(INNER_H):
        for ix in range(INNER_W):
            a = int(round(y0 + iy * ch))
            b = int(round(y0 + (iy + 1) * ch))
            c = int(round(x0 + ix * cw))
            d = int(round(x0 + (ix + 1) * cw))
            cell = labels[a:b, c:d].ravel()
            total = cell.size
            best_name, best_share = "grass", 0.0
            for k, name in enumerate(NAMES):
                if name == "grass":
                    continue
                share = np.count_nonzero(cell == k) / total
                need = MIN_FRACTION.get(name, DEFAULT_FRACTION)
                if share >= need and share > best_share:
                    best_name, best_share = name, share
            grid[iy][ix] = best_name
    return grid


SMALL_FEATURES = {"grove": 1.6, "grey": 2.0, "stall": 2.5, "cave": 2.5}


def place_small_features(cells, labels, bounds):
    """Single trees, the well, the stall and the cave mouth are small, so they can straddle
    several cells. Each one goes to the cell under its centre instead of its majority."""
    import scipy.ndimage as nd
    x0, y0, x1, y1 = bounds
    cw = (x1 - x0) / INNER_W
    ch = (y1 - y0) / INNER_H
    for name, max_cells in SMALL_FEATURES.items():
        k = NAMES.index(name)
        lab, n = nd.label(labels == k)
        for sl_y, sl_x in nd.find_objects(lab):
            w = (sl_x.stop - sl_x.start) / cw
            h = (sl_y.stop - sl_y.start) / ch
            if w > max_cells or h > max_cells:
                continue
            area = (sl_x.stop - sl_x.start) * (sl_y.stop - sl_y.start)
            if area < 0.15 * cw * ch:
                continue
            cx = (sl_x.start + sl_x.stop) / 2
            cy = (sl_y.start + sl_y.stop) / 2
            ix = min(INNER_W - 1, max(0, int((cx - x0) / cw)))
            iy = min(INNER_H - 1, max(0, int((cy - y0) / ch)))
            # Clear the same feature from the cells it was sampled into, then set the centre cell.
            for yy in range(INNER_H):
                for xx in range(INNER_W):
                    if cells[yy][xx] == name and abs(xx - ix) <= 1 and abs(yy - iy) <= 1:
                        cells[yy][xx] = "grass"
            cells[iy][ix] = name


def snap_rectangles(cells, labels, bounds):
    """Rectangular features (house, plots, great tree) are filled as the rectangle their pixels
    cover, with edges rounded to the nearest tile boundary. Majority sampling loses their edges."""
    import scipy.ndimage as nd
    x0, y0, x1, y1 = bounds
    cw = (x1 - x0) / INNER_W
    ch = (y1 - y0) / INNER_H

    def to_cells(sx, sy):
        cx0 = max(0, int(round((sx.start - x0) / cw)))
        cx1 = min(INNER_W, int(round((sx.stop - x0) / cw)))
        cy0 = max(0, int(round((sy.start - y0) / ch)))
        cy1 = min(INNER_H, int(round((sy.stop - y0) / ch)))
        return cx0, cy0, cx1, cy1

    def fill(name, rect, clear_all=()):
        cx0, cy0, cx1, cy1 = rect
        for yy in range(INNER_H):
            for xx in range(INNER_W):
                if cells[yy][xx] in clear_all or (cells[yy][xx] == name and cx0 <= xx < cx1 and cy0 <= yy < cy1):
                    cells[yy][xx] = "grass"
        for yy in range(cy0, cy1):
            for xx in range(cx0, cx1):
                # Fence brackets sit on the edges of plots, so they are kept.
                if cells[yy][xx] != "fence":
                    cells[yy][xx] = name

    def biggest(names):
        mask = np.isin(labels, [NAMES.index(n) for n in names])
        lab, n = nd.label(mask)
        if n == 0:
            return []
        sizes = nd.sum(mask, lab, range(1, n + 1))
        order = np.argsort(sizes)[::-1]
        found = []
        slices = nd.find_objects(lab)
        for i in order:
            sl = slices[i]
            # The tree border shares the great tree's colour and touches the edge of the picture; skip it.
            if sl[0].start == 0 or sl[1].start == 0 or sl[0].stop >= labels.shape[0] or sl[1].stop >= labels.shape[1]:
                continue
            if sizes[i] > 0.02 * (x1 - x0) * (y1 - y0) / 100:
                found.append((lab, i + 1, sizes[i]))
        return found

    # House: roof and body together.
    # The roof and the body are separate pixel regions that meet at the house's wall line, so their boxes are joined.
    parts = biggest(["roof", "body"])
    if parts:
        lab = parts[0][0]
        boxes = [nd.find_objects(lab)[k - 1] for _, k, _ in parts]
        top = min(b[0].start for b in boxes)
        bottom = max(b[0].stop for b in boxes)
        left = min(b[1].start for b in boxes)
        right = max(b[1].stop for b in boxes)
        fill("body", to_cells(slice(left, right), slice(top, bottom)), clear_all=("roof", "body"))
    # Plots: each brown or olive block.
    for names in (["brown"], ["olive"]):
        mask = np.isin(labels, [NAMES.index(n) for n in names])
        lab, n = nd.label(mask)
        for sl in nd.find_objects(lab):
            if sl is None:
                continue
            area = (sl[1].stop - sl[1].start) * (sl[0].stop - sl[0].start)
            if area < 0.3 * cw * ch:
                continue
            fill(names[0], to_cells(sl[1], sl[0]))
    # Great tree: a 3 by 3 block at the centre of its footprint.
    for lab, k, _ in biggest(["tree_big"])[:1]:
        sl = nd.find_objects(lab)[k - 1]
        cx0, cy0, cx1, cy1 = to_cells(sl[1], sl[0])
        cx, cy = (cx0 + cx1) // 2, (cy0 + cy1) // 2
        for yy in range(INNER_H):
            for xx in range(INNER_W):
                if cells[yy][xx] == "tree_big":
                    cells[yy][xx] = "grass"
        for yy in range(cy - 1, cy + 2):
            for xx in range(cx - 1, cx + 2):
                cells[yy][xx] = "tree_big"


def components(cells, names):
    """4-connected groups of cells whose class is in names. Returns a list of sets."""
    seen, groups = set(), []
    for y in range(INNER_H):
        for x in range(INNER_W):
            if (x, y) in seen or cells[y][x] not in names:
                continue
            group, q = set(), deque([(x, y)])
            seen.add((x, y))
            while q:
                cx, cy = q.popleft()
                group.add((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < INNER_W and 0 <= ny < INNER_H and (nx, ny) not in seen and cells[ny][nx] in names:
                        seen.add((nx, ny))
                        q.append((nx, ny))
            groups.append(group)
    return groups


def bbox(group):
    xs = [p[0] for p in group]
    ys = [p[1] for p in group]
    return min(xs), min(ys), max(xs), max(ys)


def free_rect(terrain, w, h, target, margin=0):
    """Best w by h block of plain grass, nearest the target. The tile in front of its door
    (bottom middle) must also be open ground, so the door can be used."""
    best = None
    for y in range(margin, INNER_H - h - margin + 1):
        for x in range(margin, INNER_W - w - margin + 1):
            ok = True
            for yy in range(y, y + h):
                for xx in range(x, x + w):
                    if terrain[yy][xx] != ".":
                        ok = False
                        break
                if not ok:
                    break
            if ok and y + h < INNER_H and terrain[y + h][x + w // 2] in (".", "P"):
                pass
            else:
                ok = False
            if ok:
                d = abs(x + w / 2 - target[0]) + abs(y + h / 2 - target[1])
                if best is None or d < best[0]:
                    best = (d, x, y)
    if best is None:
        raise SystemExit("no free %dx%d grass for a farm building" % (w, h))
    return best[1], best[2]


def convert(path, drop_grove=None):
    img = Image.open(path).convert("RGB")
    rgb = np.asarray(img).astype(float)
    bounds = grass_bounds(rgb)
    labels = classify_pixels(rgb)
    cells = sample_grid(labels, bounds)
    place_small_features(cells, labels, bounds)
    snap_rectangles(cells, labels, bounds)
    warnings = []

    # Plot blocks: the upper brown block is soil, the lower one fallow, the olive one is plot three.
    browns = sorted(components(cells, {"brown"}), key=lambda g: bbox(g)[1])
    if len(browns) != 2:
        raise SystemExit("expected two brown plots, found %d" % len(browns))
    plot_one, plot_two = (bbox(g) for g in browns)
    olives = components(cells, {"olive"})
    if len(olives) != 1:
        raise SystemExit("expected one fallow plot (olive), found %d" % len(olives))
    plot_three = bbox(olives[0])
    for (bx0, by0, bx1, by1), code in ((plot_one, "S"), (plot_two, "F"), (plot_three, "F")):
        for y in range(by0, by1 + 1):
            for x in range(bx0, bx1 + 1):
                cells[y][x] = {"S": "brown", "F": "olive"}[code]

    # House: roof and body together, drawn as a rectangle.
    houses = components(cells, {"roof", "body"})
    if len(houses) != 1:
        raise SystemExit("expected one house, found %d" % len(houses))
    hx0, hy0, hx1, hy1 = bbox(houses[0])
    house_w, house_h = hx1 - hx0 + 1, hy1 - hy0 + 1
    if len(houses[0]) != house_w * house_h:
        warnings.append("house is not a full rectangle; using its bounding box")
    for y in range(hy0, hy1 + 1):
        for x in range(hx0, hx1 + 1):
            cells[y][x] = "body"

    # Stall, well, cave mouth.
    stalls = components(cells, {"stall"})
    if len(stalls) != 1:
        raise SystemExit("expected one stall, found %d group(s)" % len(stalls))
    if len(stalls[0]) > 1:
        warnings.append("stall covers %d tiles in the diagram; the game uses one, at its centre" % len(stalls[0]))
    sx0, sy0, sx1, sy1 = bbox(stalls[0])
    stall = ((sx0 + sx1) // 2, (sy0 + sy1) // 2)
    greys = components(cells, {"grey"})
    well, rocks = None, []
    for g in greys:
        if len(g) <= 2:
            if well is not None:
                raise SystemExit("more than one well")
            well = next(iter(g))
        else:
            rocks.extend(g)
    if well is None:
        raise SystemExit("no well found")
    caves = components(cells, {"cave"})
    if len(caves) != 1:
        raise SystemExit("expected one cave mouth, found %d" % len(caves))

    # Great tree: the diagram draws it bigger than the game's 3 by 3 tree, so the centre 3 by 3 is kept.
    big = components(cells, {"tree_big"})
    if len(big) != 1:
        raise SystemExit("expected one great tree, found %d" % len(big))
    bx0, by0, bx1, by1 = bbox(big[0])
    big_cx, big_cy = (bx0 + bx1) // 2, (by0 + by1) // 2
    big_inner = (big_cx - 1, big_cy - 1)

    # Grove trees: single cells of the grove colour.
    groves = [next(iter(g)) for g in components(cells, {"grove"}) if len(g) == 1]
    bad = [g for g in components(cells, {"grove"}) if len(g) != 1]
    if bad:
        warnings.append("%d grove tree group(s) are bigger than one tile" % len(bad))
    if drop_grove is not None:
        px, py = drop_grove
        ix = int((px - bounds[0]) / ((bounds[2] - bounds[0]) / INNER_W))
        iy = int((py - bounds[1]) / ((bounds[3] - bounds[1]) / INNER_H))
        nearest = min(groves, key=lambda g: abs(g[0] - ix) + abs(g[1] - iy))
        groves.remove(nearest)
        print("dropped grove tree at inner %s" % (nearest,))

    # Build the terrain grid.
    terrain = [["."] * INNER_W for _ in range(INNER_H)]
    for y in range(INNER_H):
        for x in range(INNER_W):
            name = cells[y][x]
            if name in ("grass",):
                terrain[y][x] = "."
            elif name in ("water",):
                terrain[y][x] = "~"
            elif name in ("path",):
                terrain[y][x] = "P"
            elif name == "fence":
                terrain[y][x] = "X"
            elif name == "brown":
                terrain[y][x] = "S"
            elif name == "olive":
                terrain[y][x] = "F"
            elif name == "cave":
                terrain[y][x] = "C"
            elif name in ("roof", "body", "stall"):
                terrain[y][x] = "A" if name == "stall" else "H"
            elif name == "grey":
                terrain[y][x] = "K"
            elif name == "tree_big":
                terrain[y][x] = "."
            elif name == "grove":
                terrain[y][x] = "."
    for x in range(hx0, hx1 + 1):
        for y in range(hy0, hy1 + 1):
            terrain[y][x] = "H"
    terrain[stall[1]][stall[0]] = "A"
    terrain[well[1]][well[0]] = "W"
    for (x, y) in rocks:
        terrain[y][x] = "K"
    for (x, y) in caves[0]:
        terrain[y][x] = "C"
    for g in groves:
        terrain[g[1]][g[0]] = "G"
    for dy in range(3):
        for dx in range(3):
            terrain[big_inner[1] + dy][big_inner[0] + dx] = "B"
    # Front door: the middle of the house's bottom row.
    door = (hx0 + 2, hy1)
    terrain[door[1]][door[0]] = "D"

    # Porch: four tiles of boards starting one row below the house, as before.
    porch = (door[0], door[1] + 1, 1, 1)
    for y in range(porch[1], porch[1] + porch[3]):
        for x in range(porch[0], porch[0] + porch[2]):
            if terrain[y][x] in (".", "P"):
                terrain[y][x] = "R"

    # Places for the farm buildings the player builds or unlocks later: workshop, cellar.
    wx, wy = free_rect(terrain, 5, 4, (24, 18))
    workshop = (wx, wy, 5, 4)
    for y in range(wy, wy + 4):
        for x in range(wx, wx + 5):
            terrain[y][x] = "."
    cellar = None
    for cand in ((hx0 - 2, hy0 + 2), (hx0 - 2, hy0 + 1), (hx0 - 2, hy0 + 3), (hx1 + 2, hy0 + 2)):
        cx, cy = cand
        if 0 <= cx < INNER_W and 0 <= cy < INNER_H and terrain[cy][cx] == "." and all(
            0 <= nx < INNER_W and 0 <= ny < INNER_H and terrain[ny][nx] in ".PS"
            for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1))
        ):
            cellar = cand
            break
    if cellar is None:
        raise SystemExit("no room for the cellar beside the house")

    # Brush and thicket piles on plain grass, spread out.
    def spread(count, avoid):
        picks = []
        cands = [(x, y) for y in range(1, INNER_H - 1) for x in range(1, INNER_W - 1)
                 if terrain[y][x] == "." and all(terrain[ny][nx] == "." for nx in range(x - 1, x + 2) for ny in range(y - 1, y + 2))]
        cands.sort(key=lambda p: (p[0] * 73 + p[1] * 151) % 997)
        for p in cands:
            if all(abs(p[0] - q[0]) + abs(p[1] - q[1]) >= 4 for q in picks + avoid):
                picks.append(p)
                if len(picks) == count:
                    break
        if len(picks) < count:
            raise SystemExit("not enough room for brush spots")
        return picks
    workshop_cells = {(x, y) for x in range(wx, wx + 5) for y in range(wy, wy + 4)}
    brush = spread(7, [cellar] + list(workshop_cells))
    thicket = spread(3, brush + [cellar])
    rocks_spots = spread(8, brush + thicket + [cellar] + list(workshop_cells))

    # Willows: grove trees near the water.
    water = [(x, y) for y in range(INNER_H) for x in range(INNER_W) if terrain[y][x] == "~"]
    willows = [g for g in groves if any(abs(g[0] - w[0]) <= 2 and abs(g[1] - w[1]) <= 2 for w in water)]
    lake_focus = (sum(p[0] for p in water) / len(water), sum(p[1] for p in water) / len(water))
    reserved = sorted(workshop_cells | {cellar})

    walk = set()
    blocking = set("GBXKWAH")
    start = (door[0], door[1] + 1)
    if terrain[start[1]][start[0]] not in ".PRSF":
        raise SystemExit("nothing walkable in front of the door")
    q = deque([start])
    walk.add(start)
    while q:
        cx, cy = q.popleft()
        for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if 0 <= nx < INNER_W and 0 <= ny < INNER_H and (nx, ny) not in walk:
                if terrain[ny][nx] in blocking or terrain[ny][nx] in "~D":
                    continue
                walk.add((nx, ny))
                q.append((nx, ny))
    # A well inside a fence pen needs a gap: open the fewest fence tiles that link the pen to open ground.
    wx_, wy_ = well
    pocket = [(wx_ + dx, wy_ + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))
              if 0 <= wx_ + dx < INNER_W and 0 <= wy_ + dy < INNER_H and terrain[wy_ + dy][wx_ + dx] in ".PRSF"]
    if not any(p in walk for p in pocket):
        prev = {}
        q = deque()
        for p in [(wx_ + dx, wy_ + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]:
            if 0 <= p[0] < INNER_W and 0 <= p[1] < INNER_H and terrain[p[1]][p[0]] == "X":
                prev[p] = None
                q.append(p)
        found = None
        while q and found is None:
            cx, cy = q.popleft()
            for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                if not (0 <= nx < INNER_W and 0 <= ny < INNER_H) or (nx, ny) in prev:
                    continue
                if (nx, ny) in walk:
                    found = (cx, cy)
                    break
                if terrain[ny][nx] == "X":
                    prev[(nx, ny)] = (cx, cy)
                    q.append((nx, ny))
        if found is None:
            warnings.append("the well cannot be reached even through the fence")
        else:
            cur = found
            opened = []
            while cur is not None:
                terrain[cur[1]][cur[0]] = "."
                opened.append(cur)
                cur = prev[cur]
            warnings.append("opened %d fence tile(s) at %s so the well can be reached" % (len(opened), opened))
            walk.update(opened)
            for p in opened:
                q.append(p)
            while q:
                cx, cy = q.popleft()
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if 0 <= nx < INNER_W and 0 <= ny < INNER_H and (nx, ny) not in walk and terrain[ny][nx] not in blocking and terrain[ny][nx] not in "~D":
                        walk.add((nx, ny))
                        q.append((nx, ny))

    targets = {"well": well, "stall": stall, "cave": caves[0], "door": door}
    for name, rect in (("plot one", plot_one), ("plot two", plot_two), ("plot three", plot_three)):
        targets[name] = [(x, y) for y in range(rect[1], rect[3] + 1) for x in range(rect[0], rect[2] + 1)]
    for name, t in targets.items():
        cells_t = t if isinstance(t, list) or isinstance(t, set) else [t]
        if isinstance(cells_t, set):
            cells_t = list(cells_t)
        if not any(p in walk or any(
                (p[0] + dx, p[1] + dy) in walk for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                for p in cells_t):
            warnings.append("%s cannot be reached on foot" % name)

    return {
        "terrain": ["".join(r) for r in terrain],
        "plot_one": plot_one, "plot_two": plot_two, "plot_three": plot_three,
        "house": (hx0, hy0, house_w, house_h), "porch": porch,
        "well": well, "stall": stall, "cellar": cellar, "big_inner": big_inner,
        "groves": groves, "willows": willows, "brush": brush, "thicket": thicket, "rocks": rocks_spots,
        "workshop": workshop, "lake_focus": lake_focus, "reserved": reserved,
        "door": door, "warnings": warnings, "bounds": bounds,
    }


def emit(d, out_path):
    rows = ",\n\t".join('"%s"' % r for r in d["terrain"])

    def v2(p):
        return "Vector2i(%d, %d)" % (p[0], p[1])

    def list_(items):
        return "[" + ", ".join(v2(p) for p in items) + "]"

    import hashlib
    stamp = hashlib.sha1(repr(sorted((k, repr(v)) for k, v in d.items() if k != "warnings")).encode()).hexdigest()[:8]
    x, y, w, h = d["workshop"]
    px, py, pw, ph = d["porch"]
    hx, hy, hw, hh = d["house"]
    reserved = d["reserved"]
    src = f'''class_name FarmLayout
extends RefCounted

# The farm layout. Generated from the layout diagram by tools/farm_layout.py; regenerate rather than editing by hand.
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

const PLOT_ONE := Rect2i({d["plot_one"][0]}, {d["plot_one"][1]}, {d["plot_one"][2] - d["plot_one"][0] + 1}, {d["plot_one"][3] - d["plot_one"][1] + 1})
const PLOT_TWO := Rect2i({d["plot_two"][0]}, {d["plot_two"][1]}, {d["plot_two"][2] - d["plot_two"][0] + 1}, {d["plot_two"][3] - d["plot_two"][1] + 1})
const PLOT_THREE := Rect2i({d["plot_three"][0]}, {d["plot_three"][1]}, {d["plot_three"][2] - d["plot_three"][0] + 1}, {d["plot_three"][3] - d["plot_three"][1] + 1})
const HOUSE_IX := {hx}
const HOUSE_IY := {hy}
const HOUSE_W := {hw}
const HOUSE_H := {hh}
const PORCH_RECT := Rect2i({px}, {py}, {pw}, {ph})
const WELL_IX := {v2(d["well"])}
const STALL_IX := {d["stall"][0]}
const STALL_IY := {d["stall"][1]}
const CELLAR_IX := {v2(d["cellar"])}
const SMOKEHOUSE_IX := {v2((x + 3, y + 1))}
const FURNACE_IX := {v2((x + 1, y + 1))}
const WORKSHOP_RECT := Rect2i({x}, {y}, {w}, {h})
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
const RESERVED := {list_(reserved)}
# Changes whenever the layout changes. Saves record it, so a save from another layout is migrated.
const VERSION := "{stamp}"
'''
    with open(out_path, "w") as f:
        f.write(src)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("diagram")
    ap.add_argument("--out", default="scripts/farm_layout.gd")
    ap.add_argument("--drop-grove", default=None, help="PX,PY of a grove tree to remove")
    ap.add_argument("--preview", action="store_true")
    a = ap.parse_args()
    drop = tuple(int(v) for v in a.drop_grove.split(",")) if a.drop_grove else None
    d = convert(a.diagram, drop)
    if a.preview:
        for i, row in enumerate(d["terrain"]):
            print("%2d %s" % (i, row))
    for w in d["warnings"]:
        print("WARNING:", w)
    emit(d, a.out)
    print("wrote %s (groves %d, brush %d, thicket %d)" % (a.out, len(d["groves"]), len(d["brush"]), len(d["thicket"])))


if __name__ == "__main__":
    sys.exit(main())
