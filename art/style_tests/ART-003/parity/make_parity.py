# ART-003 W-4 Task B (documentation only): a layout-parity blueprint for the 64x40 inner farm. It starts from the
# ART-003 prototype (wide/blueprint_wide_v1b_w3b.txt, the Batch C props and the W-4 gate), translates its codes
# to one production key, places every live gameplay feature, and checks the result. Nothing here is read by
# the game; scripts/farm_layout.gd is untouched.
#   python art/style_tests/ART-003/parity/make_parity.py
# Writes parity_blueprint.txt, parity_blueprint.png and parity_report.json (all positions and checks) next to it.
import json
import os
import re
from collections import Counter, deque
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", "..", ".."))
W, H = 64, 40

# --- live layout ---------------------------------------------------------------------------------------------
src = open(os.path.join(ROOT, "scripts", "farm_layout.gd"), encoding="utf-8").read()
LIVE = re.findall(r'^\t"(.{64})",$', src, re.M)
assert len(LIVE) == H


def vec_list(name):
    m = re.search(name + r' := \[(.*?)\]\n', src)
    return [tuple(map(int, p)) for p in re.findall(r'Vector2i\((-?\d+), (-?\d+)\)', m.group(1))] if m else []


def vec(name):
    m = re.search(name + r' := Vector2i\((-?\d+), (-?\d+)\)', src)
    return (int(m.group(1)), int(m.group(2)))


def rect(name):
    m = re.search(name + r' := Rect2i\((\d+), (\d+), (\d+), (\d+)\)', src)
    return tuple(map(int, m.groups()))


live = {
    "PLOT_ONE": rect("PLOT_ONE"), "PLOT_TWO": rect("PLOT_TWO"), "PLOT_THREE": rect("PLOT_THREE"),
    "WELL_IX": vec("WELL_IX"), "CELLAR_IX": vec("CELLAR_IX"), "BIG_TREE_INNER": vec("BIG_TREE_INNER"),
    "WORKSHOP_RECT": rect("WORKSHOP_RECT"), "GROVE_SPOTS": vec_list("GROVE_SPOTS"), "WILLOW_TREES": vec_list("WILLOW_TREES"),
    "BRUSH_SPOTS": vec_list("BRUSH_SPOTS"), "THICKET_SPOTS": vec_list("THICKET_SPOTS"), "ROCK_SPOTS": vec_list("ROCK_SPOTS"),
}
for k in ["HOUSE_IX", "HOUSE_IY", "STALL_IX", "STALL_IY"]:
    live[k] = int(re.search(k + r' := (\d+)', src).group(1))
live["LAKE_FOCUS"] = tuple(map(float, re.search(r'LAKE_FOCUS := Vector2\(([\d.]+), ([\d.]+)\)', src).groups()))
live["CAVE_MOUTH"] = next((x, y) for y, r in enumerate(LIVE) for x, c in enumerate(r) if c == "C")
live["SCARECROW"] = next((x, y) for y, r in enumerate(LIVE) for x, c in enumerate(r) if c == "Y")
live["WALKER_SPOTS"] = {"edge": (25, 1), "mill": (25, 1), "route_152": (22, 1), "route_244": (28, 1), "route_336": (31, 1), "grove": (19, 1)}
live["PEDLAR_SPOT"] = (37, 12)
live["HOMESTEAD_ARRIVE"] = (W - 3, H // 2)                 # main.gd:407: BORDER + (INNER_W - 3, INNER_H / 2)
live["SHADOW_FROM"] = (W - 2, H // 2 - 4)                  # night_system.gd:1039-1043
live["NEW_GAME_START"] = (W // 2, H // 2)                  # main.gd:1942, also the fallback after a layout change

# --- the prototype, in the production key ------------------------------------------------------------------------
# Production key = every live code with its live meaning, plus:
#   T inner forest (Tile.TREE, never felled)   o orchard fruit tree (Tile.TREE, never felled)
#   J dock over water (walkable, fish from its end)   p standing prop (blocks; no interaction)
#   Q east gate, posts and closed leaves (blocks; NOT a fence, so it never breaks at night)
PROTO = [l.rstrip("\n") for l in open(os.path.join(ROOT, "art/style_tests/ART-003/wide/blueprint_wide_v1b_w3b.txt"))]
TRANSLATE = {"T": "T", "O": "O", "H": "H", "D": "D", "R": "R", "d": "p", "r": "K", "b": "b", "B": "B", "c": "P",
             "W": "W", "P": "P", "X": "X", "w": "P", "S": ".", "g": "P", "o": "o", "L": ".", "~": "~", "K": "J", ".": "."}
g = [[TRANSLATE[c] for c in row] for row in PROTO]
# Batch C props (tools/art003_wide.gd _c_props) block their tiles.
BATCH_C = {"woodcutting": [(34, 14), (35, 14), (33, 14)], "signpost": [(31, 21)], "handcart": [(36, 21), (37, 21)],
           "boulders_v3": [(29, 23), (30, 23), (30, 24)], "dead_tree": [(56, 32), (57, 32)], "arrival_boulders": [(54, 36), (55, 36)],
           "mailbox": [(53, 32)], "rain_barrel_compost": [(41, 30), (40, 30)], "apple_barrel": [(14, 20)]}
for k, ts in BATCH_C.items():
    for x, y in ts:
        g[y][x] = "p"
# W-4 gate (x 59, rows 33-36) inside the inner grid; the avenue beyond it is border art, not layout.
for y in range(33, 37):
    g[y][59] = "Q"

changes = []


def put(x, y, c, why):
    changes.append({"tile": [x, y], "from": g[y][x], "to": c, "why": why})
    g[y][x] = c


def fill(r, c, why):
    x0, y0, w, h = r
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            put(x, y, c, why)


prop = {}
# House: the prototype's house has the live shape exactly (11x7: roof rows 5-9, wall rows 10-11, door mid-bottom).
prop["HOUSE_IX"], prop["HOUSE_IY"] = 40, 5
# Plot one (open from the start, 15x7) fills the prototype's fenced garden; its walkways stay as path.
prop["PLOT_ONE"] = (44, 21, 15, 7)
fill(prop["PLOT_ONE"], "S", "plot one")
for y in range(19, 30):
    for x in range(43, 60):
        if g[y][x] == "." and not (44 <= x < 59 and 21 <= y < 28):
            put(x, y, "P", "garden walkways round plot one")
prop["SCARECROW"] = (59, 24)
put(59, 24, "Y", "scarecrow, on the garden's east walkway beside plot one")
# Plot two (fallow, 15x6) in the north-west meadow; plot three (fallow, 12x6) south of the crossroads.
prop["PLOT_TWO"] = (8, 4, 15, 6)
fill(prop["PLOT_TWO"], "F", "plot two")
prop["PLOT_THREE"] = (23, 23, 12, 6)
for t in BATCH_C["boulders_v3"]:
    put(t[0], t[1], ".", "Batch C boulders moved off plot three")
fill(prop["PLOT_THREE"], "F", "plot three")
for t in [(27, 21), (28, 21), (27, 22)]:
    put(t[0], t[1], "p", "the V3 boulder group, moved north of plot three")
# Cave mouth: a rock outcrop cut into the west forest edge, entered from the tile south of C.
prop["CAVE_MOUTH"] = (5, 8)
for t in [(4, 6), (5, 6), (6, 6), (3, 7), (4, 7), (5, 7), (6, 7), (3, 8), (4, 8), (6, 8), (3, 9), (4, 9)]:
    put(t[0], t[1], "K", "cave outcrop")
put(5, 8, "C", "cave mouth")
for t in [(5, 9), (5, 10), (6, 10), (7, 10), (8, 10), (9, 10), (10, 10), (11, 10)]:
    put(t[0], t[1], "P", "cave path to the meadow")
# Market stall (3x2) facing the road at the arrival, its back to the garden fence; the pedlar beside it.
prop["STALL_IX"], prop["STALL_IY"] = 44, 31
fill((44, 31, 3, 2), "A", "market stall")
prop["PEDLAR_SPOT"] = (47, 32)
# Well, great tree (the golden oak), cellar: the prototype's positions.
prop["WELL_IX"] = (37, 15)
prop["BIG_TREE_INNER"] = (30, 12)
prop["CELLAR_IX"] = (38, 7)
# Workshop default (the old-save fallback and RESERVED block): east of the house.
prop["WORKSHOP_RECT"] = (53, 8, 7, 6)
prop["LAKE_FOCUS"] = (9.5, 31.5)
prop["WALKER_SPOTS"] = {"edge": (51, 2), "mill": (51, 2), "route_152": (48, 2), "route_244": (54, 2), "route_336": (56, 2), "grove": (46, 2)}
prop["HOMESTEAD_ARRIVE"] = (57, 34)
prop["SHADOW_FROM"] = (61, 16)
prop["NEW_GAME_START"] = (45, 13)

# --- grove trees, brush, thicket, rocks --------------------------------------------------------------------------
WALK = set(".SFPRbJ")   # walkable codes (D enters the house; C enters the cave)


def walkable(c):
    return c in WALK


def near(x, y, codes, r):
    return any(0 <= x + dx < W and 0 <= y + dy < H and g[y + dy][x + dx] in codes
               for dy in range(-r, r + 1) for dx in range(-r, r + 1))


reserved = set()
wx, wy, ww, wh = prop["WORKSHOP_RECT"]
reserved |= {(x, y) for y in range(wy, wy + wh) for x in range(wx, wx + ww)}
reserved.add(prop["CELLAR_IX"])
for s in prop["WALKER_SPOTS"].values():
    reserved |= {s, (s[0], s[1] + 1)}
reserved |= {prop["HOMESTEAD_ARRIVE"], prop["PEDLAR_SPOT"], (prop["STALL_IX"] + 1, prop["STALL_IY"] + 3), prop["NEW_GAME_START"]}
reserved.add((wx + 3, wy + 6))   # the workshop door's outside step
taken = set()


def flood_g(start, block):
    seen = {start}
    q = deque([start])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if 0 <= n[0] < W and 0 <= n[1] < H and n not in seen and g[n[1]][n[0]] in WALK and n not in block:
                seen.add(n)
                q.append(n)
    return seen


PORCH = (prop["HOUSE_IX"] + 5, prop["HOUSE_IY"] + 7)


def pick(n, want, spacing, label):
    # Greedy, spread out, on reachable open grass; a spot is only taken if, with it and every spot taken so far
    # standing (grown back), every other reachable tile can still be reached: no spot ever closes a corridor.
    out = []
    base = flood_g(PORCH, set())
    cands = [(x, y) for y in range(H) for x in range(W) if g[y][x] == "." and (x, y) in base and (x, y) not in reserved
             and want(x, y) and not near(x, y, "PSFAWDRCYJQb", 1)]

    def gap(c):
        return min([abs(c[0] - o[0]) + abs(c[1] - o[1]) for o in taken] or [99])
    while len(out) < n and cands:
        best = max(cands, key=lambda c: (gap(c), -c[1], c[0]))
        cands.remove(best)
        if gap(best) < spacing:
            break
        block = (taken | {best}) - set(prop.get("GROVE_SPOTS", []))
        trees = {t for t in taken if g[t[1]][t[0]] == "G"}
        r = flood_g(PORCH, block | trees)
        if len(r) < len(base - block - trees):
            continue
        out.append(best)
        taken.add(best)
    assert len(out) == n, (label, len(out))
    return out


# Walkable pockets the prototype draws but nobody can reach (grass east of the garden fence, by the pond's west
# bank, a gap in the south trees). In production forage and brush can grow on any open grass, so these become forest.
pockets = sorted(set((x, y) for y in range(H) for x in range(W) if g[y][x] in WALK) - flood_g(PORCH, set()))
for x, y in pockets:
    put(x, y, "T", "unreachable prototype pocket closed")
prop["WILLOW_TREES"] = [(17, 32)]
taken.add((17, 32))
grove = pick(19, lambda x, y: near(x, y, "T", 1), 4, "grove")
prop["GROVE_SPOTS"] = sorted(grove + prop["WILLOW_TREES"], key=lambda t: (t[1], t[0]))
for x, y in prop["GROVE_SPOTS"]:
    put(x, y, "G", "grove tree (felled for wood)")
prop["ROCK_SPOTS"] = pick(8, lambda x, y: True, 3, "rocks")
prop["BRUSH_SPOTS"] = pick(7, lambda x, y: True, 3, "brush")
prop["THICKET_SPOTS"] = pick(1, lambda x, y: True, 2, "thicket")

# --- checks ------------------------------------------------------------------------------------------------------
rows = ["".join(r) for r in g]
checks = {}


def flood(start, extra_block=()):
    seen = {start}
    q = deque([start])
    while q:
        x, y = q.popleft()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy)
            if 0 <= n[0] < W and 0 <= n[1] < H and n not in seen and walkable(rows[n[1]][n[0]]) and n not in extra_block:
                seen.add(n)
                q.append(n)
    return seen


porch = (prop["HOUSE_IX"] + 5, prop["HOUSE_IY"] + 7)
assert rows[porch[1]][porch[0]] == "R", rows[porch[1]][porch[0]]
# Worst case: every brush, rock and thicket spot grown back at once.
blocked_spots = set(prop["ROCK_SPOTS"]) | set(prop["BRUSH_SPOTS"]) | set(prop["THICKET_SPOTS"])
reach = flood(porch, blocked_spots)


def reached(t):
    return t in reach


def any_side(t):
    return any((t[0] + dx, t[1] + dy) in reach for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))


checks["reachable_tiles"] = len(reach)
checks["walkable_tiles_total"] = sum(1 for r in rows for c in r if walkable(c))
checks["unreachable_walkable"] = sorted([(x, y) for y in range(H) for x in range(W)
                                         if walkable(rows[y][x]) and (x, y) not in reach and (x, y) not in blocked_spots])
checks["door_below_roof_mid"] = rows[prop["HOUSE_IY"] + 6][prop["HOUSE_IX"] + 5] == "D"
checks["cave_entry_tile_reached"] = reached((prop["CAVE_MOUTH"][0], prop["CAVE_MOUTH"][1] + 1))
checks["stall_front_reached"] = reached((prop["STALL_IX"] + 1, prop["STALL_IY"] + 3))
checks["pedlar_spot_open"] = rows[prop["PEDLAR_SPOT"][1]][prop["PEDLAR_SPOT"][0]] == "." and reached(prop["PEDLAR_SPOT"])
checks["well_side_reached"] = any(any_side((prop["WELL_IX"][0] + dx, prop["WELL_IX"][1] + dy)) for dx in (0, 1) for dy in (0, 1))
checks["great_tree_front_reached"] = any_side((prop["BIG_TREE_INNER"][0] + 1, prop["BIG_TREE_INNER"][1] + 1))
checks["great_tree_b_row_and_3x2_base"] = all(rows[prop["BIG_TREE_INNER"][1] - 1 + dy][prop["BIG_TREE_INNER"][0] + dx] == ("b" if dy == 0 else "B")
                                              for dy in range(3) for dx in range(3))
checks["scarecrow_beside_plot_one"] = any_side(prop["SCARECROW"])
for k in ["PLOT_ONE", "PLOT_TWO", "PLOT_THREE"]:
    x0, y0, w, h = prop[k]
    want = "S" if k == "PLOT_ONE" else "F"
    tiles = [(x, y) for y in range(y0, y0 + h) for x in range(x0, x0 + w)]
    checks[k + "_size_matches_live"] = (w, h) == tuple(live[k][2:])
    checks[k + "_all_" + want] = all(rows[y][x] == want for x, y in tiles)
    checks[k + "_every_tile_reached"] = all(reached(t) for t in tiles)
checks["grove_each_has_reachable_side"] = all(any_side(t) for t in prop["GROVE_SPOTS"])
checks["grove_count_matches_live"] = len(prop["GROVE_SPOTS"]) == len(live["GROVE_SPOTS"])
checks["rock_brush_thicket_counts_match"] = [len(prop[k]) == len(live[k]) for k in ["ROCK_SPOTS", "BRUSH_SPOTS", "THICKET_SPOTS"]]
checks["spots_have_reachable_side"] = all(any_side(t) for t in blocked_spots)
checks["walker_spots_and_step_reached"] = all(reached(s) and reached((s[0], s[1] + 1)) for s in prop["WALKER_SPOTS"].values())
checks["arrive_reached"] = reached(prop["HOMESTEAD_ARRIVE"])
checks["new_game_start_reached"] = reached(prop["NEW_GAME_START"])
checks["shadow_from_open"] = rows[prop["SHADOW_FROM"][1]][prop["SHADOW_FROM"][0]] == "."
checks["workshop_default_all_grass"] = all(rows[y][x] == "." for y in range(wy, wy + wh) for x in range(wx, wx + ww))
checks["workshop_door_outside_reached"] = reached((wx + 3, wy + 6))
checks["cellar_on_grass_beside_house"] = rows[prop["CELLAR_IX"][1]][prop["CELLAR_IX"][0]] == "."
water = [(x, y) for y in range(H) for x in range(W) if rows[y][x] == "~"]
checks["water_tiles"] = len(water)
checks["water_tiles_live"] = sum(r.count("~") for r in LIVE)
checks["water_fishable_from_shore"] = sum(1 for t in water if any_side(t))
checks["water_fishable_live"] = None
checks["codes_used"] = sorted(set("".join(rows)))
checks["fence_tiles"] = "".join(rows).count("X")
checks["fence_tiles_live"] = "".join(LIVE).count("X")
checks["prop_tiles"] = "".join(rows).count("p")
checks["open_grass_tiles"] = "".join(rows).count(".")
checks["open_grass_tiles_live"] = "".join(LIVE).count(".")
# Shore-fishable water in the live layout, for comparison.
lw = set(".SFPRb")
checks["water_fishable_live"] = sum(1 for y in range(H) for x in range(W) if LIVE[y][x] == "~" and any(
    0 <= x + dx < W and 0 <= y + dy < H and LIVE[y + dy][x + dx] in lw for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))))

# --- what the prototype has on each live feature's tiles (why the live coordinates can't stay) --------------------
proto_rows = ["".join(TRANSLATE[c] for c in r) for r in PROTO]


def under(ts):
    return dict(Counter(proto_rows[y][x] for x, y in ts))


def rect_tiles(r):
    return [(x, y) for y in range(r[1], r[1] + r[3]) for x in range(r[0], r[0] + r[2])]


identity = {
    "PLOT_ONE": under(rect_tiles(live["PLOT_ONE"])), "PLOT_TWO": under(rect_tiles(live["PLOT_TWO"])),
    "PLOT_THREE": under(rect_tiles(live["PLOT_THREE"])), "HOUSE": under(rect_tiles((live["HOUSE_IX"], live["HOUSE_IY"], 11, 7))),
    "STALL": under(rect_tiles((live["STALL_IX"], live["STALL_IY"], 3, 2))), "WELL": under(rect_tiles((*live["WELL_IX"], 2, 2))),
    "CAVE_MOUTH": under([live["CAVE_MOUTH"]]), "SCARECROW": under([live["SCARECROW"]]),
    "GREAT_TREE": under(rect_tiles((live["BIG_TREE_INNER"][0], live["BIG_TREE_INNER"][1] - 1, 3, 3))),
    "WORKSHOP_RECT": under(rect_tiles(live["WORKSHOP_RECT"])), "GROVE_SPOTS": under(live["GROVE_SPOTS"]),
    "ROCK_SPOTS": under(live["ROCK_SPOTS"]), "BRUSH_SPOTS": under(live["BRUSH_SPOTS"]),
    "LAKE": under([(x, y) for y, r in enumerate(LIVE) for x, c in enumerate(r) if c == "~"]),
    "WALKER_SPOTS": under(list(set(live["WALKER_SPOTS"].values()))), "HOMESTEAD_ARRIVE": under([live["HOMESTEAD_ARRIVE"]]),
    "SHADOW_FROM": under([live["SHADOW_FROM"]]), "NEW_GAME_START": under([live["NEW_GAME_START"]]),
    "CELLAR_IX": under([live["CELLAR_IX"]]), "PEDLAR_SPOT": under([live["PEDLAR_SPOT"]]),
}

# --- outputs -----------------------------------------------------------------------------------------------------
with open(os.path.join(HERE, "parity_blueprint.txt"), "w", newline="\n") as f:
    f.write("    " + "".join(str(x // 10) for x in range(W)) + "\n    " + "".join(str(x % 10) for x in range(W)) + "\n")
    for y, r in enumerate(rows):
        f.write(f"{y:2d}  {r}\n")
with open(os.path.join(HERE, "parity_report.json"), "w", newline="\n") as f:
    json.dump({"live": live, "proposed": prop, "checks": checks, "pockets_closed": pockets, "identity_conflicts": identity,
               "changes_from_prototype": len(changes), "rows": rows}, f, indent=1, default=list)

COL = {".": (106, 159, 75), "T": (38, 62, 40), "S": (122, 82, 52), "F": (88, 100, 52), "P": (201, 166, 107), "~": (63, 111, 168),
       "H": (107, 83, 64), "O": (144, 86, 54), "D": (36, 24, 15), "R": (138, 106, 70), "A": (181, 121, 61), "W": (110, 106, 100),
       "C": (20, 20, 26), "K": (127, 127, 128), "X": (138, 106, 74), "Y": (230, 200, 60), "G": (20, 110, 70), "B": (230, 170, 40),
       "b": (200, 190, 90), "o": (220, 90, 40), "J": (150, 110, 70), "p": (90, 60, 120), "Q": (240, 240, 240)}


def draw(rows_, path, title, marks):
    S = 14
    img = Image.new("RGB", (W * S + 300, H * S + 24), (24, 24, 28))
    d = ImageDraw.Draw(img)
    for y, r in enumerate(rows_):
        for x, c in enumerate(r):
            d.rectangle([x * S, y * S + 20, x * S + S - 1, y * S + 20 + S - 1], fill=COL.get(c, (255, 0, 255)))
    for i in range(0, W, 8):
        d.text((i * S + 1, 8), str(i), fill=(150, 150, 150))
    if marks:
        for x, y in prop["ROCK_SPOTS"]:
            d.ellipse([x * S + 3, y * S + 23, x * S + 10, y * S + 30], fill=(190, 190, 195))
        for x, y in prop["BRUSH_SPOTS"] + prop["THICKET_SPOTS"]:
            d.ellipse([x * S + 3, y * S + 23, x * S + 10, y * S + 30], fill=(150, 210, 80))
        d.rectangle([wx * S, wy * S + 20, (wx + ww) * S - 1, (wy + wh) * S + 19], outline=(255, 120, 200), width=2)
        for s in set(prop["WALKER_SPOTS"].values()):
            d.rectangle([s[0] * S + 1, s[1] * S + 21, s[0] * S + S - 2, s[1] * S + 20 + S - 2], outline=(255, 255, 255), width=2)
        for t, col in [(prop["HOMESTEAD_ARRIVE"], (255, 60, 60)), (prop["NEW_GAME_START"], (60, 200, 255)),
                       (prop["PEDLAR_SPOT"], (255, 160, 0)), (prop["SHADOW_FROM"], (0, 0, 0))]:
            d.ellipse([t[0] * S + 2, t[1] * S + 22, t[0] * S + S - 3, t[1] * S + 20 + S - 3], fill=col)
        labels = [("PLOT ONE 15x7", (prop["PLOT_ONE"][0], prop["PLOT_ONE"][1] + 3)), ("PLOT TWO 15x6", (prop["PLOT_TWO"][0] + 1, prop["PLOT_TWO"][1] + 2)),
                  ("PLOT THREE 12x6", (prop["PLOT_THREE"][0], prop["PLOT_THREE"][1] + 2)), ("HOUSE", (prop["HOUSE_IX"] + 3, prop["HOUSE_IY"] + 2)),
                  ("CAVE", (prop["CAVE_MOUTH"][0] - 3, prop["CAVE_MOUTH"][1] + 2)), ("STALL", (prop["STALL_IX"], prop["STALL_IY"] - 1)),
                  ("WORKSHOP", (wx + 1, wy + 2)), ("POND", (6, 31)), ("ORCHARD", (9, 21)), ("OAK=GREAT TREE", (25, 9)), ("WELL", (34, 16)),
                  ("GATE", (60, 32)), ("TREK GAP", (46, 3)), ("ROAD", (30, 34))]
    else:
        labels = [("CAVE", live["CAVE_MOUTH"]), ("PLOT ONE", (5, 22)), ("PLOT TWO", (5, 33)), ("PLOT THREE", (31, 25)), ("HOUSE", (21, 7)),
                  ("STALL", (33, 13)), ("LAKE", (50, 9)), ("GREAT TREE", (47, 30)), ("WORKSHOP (default)", (39, 30)), ("WELL", (20, 26))]
    for t, (x, y) in labels:
        d.text((x * S + 2, y * S + 22), t, fill=(255, 255, 255), stroke_width=2, stroke_fill=(0, 0, 0))
    d.text((180, 3), title, fill=(255, 255, 255))
    key = ["T forest (not felled)", "G grove tree (felled)", "o orchard tree", "B great tree / b its top row", ". grass", "P path",
           "S plot one soil", "F fallow (plots 2, 3)", "~ water", "J dock", "H house / O roof", "D door / R porch", "A stall", "W well",
           "C cave mouth", "K rock (blocks)", "X fence", "Y scarecrow", "p prop (blocks)", "Q gate (blocks)"]
    if marks:
        key += ["grey dot: rock spot", "green dot: brush, thicket", "pink box: workshop default", "white box: walker spots",
                "red: arrive  blue: start", "orange: pedlar  black: shadow start"]
    for i, t in enumerate(key):
        c = t.split(" ")[0]
        if c in COL:
            d.rectangle([W * S + 12, 24 + i * 18, W * S + 24, 36 + i * 18], fill=COL[c])
        d.text((W * S + 30, 24 + i * 18), t, fill=(230, 230, 230))
    img.save(path)


draw(rows, os.path.join(HERE, "parity_blueprint.png"), "PROPOSED layout-parity blueprint (documentation only; not built)", True)
draw(LIVE, os.path.join(HERE, "live_layout.png"), "LIVE layout today (scripts/farm_layout.gd, VERSION 61ea46f7)", False)
draw(proto_rows, os.path.join(HERE, "prototype_layout.png"), "ART-003 prototype (Batch C + W-4 gate), production key", False)
bad = {k: v for k, v in checks.items() if v is False or (isinstance(v, list) and False in v) or (k == "unreachable_walkable" and v)}
print("checks failing:", bad if bad else "none")
print({k: checks[k] for k in ["reachable_tiles", "walkable_tiles_total", "water_tiles", "water_tiles_live", "water_fishable_from_shore",
                              "water_fishable_live", "fence_tiles", "fence_tiles_live", "prop_tiles", "open_grass_tiles",
                              "open_grass_tiles_live", "codes_used"]})
