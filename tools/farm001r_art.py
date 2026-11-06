# FARM-001 refinement (ChatGPT review, 2026-11-06): procedural art made from the farm's existing sprites, no generation.
#   python tools/farm001r_art.py
# Writes into art/farm/concept/:
#   cave_mouth_natural.png  the NW cave entrance as a natural cleft: the timber frame is gone (its planks recoloured to
#                           the hill's stone), a wider, irregular opening that falls away to black, a mossy lip with
#                           hanging roots, ferns at its foot and a floor that slopes down into the dark.
#   hill_foot.png, fern_<a|b>.png and the matching records in scenery.json: where the NW hill meets the clearing,
#                           a mossy, leaf-strewn fringe on the ground with roots running out from under the rocks, and
#                           ferns standing over the rocks' foot so the hill's edge isn't a hard line.
#   (scenery.json) the concept's painted crops come out: corn stalks and bean poles along the fence above the fields
#                           and pumpkins west of them. They looked like crops but weren't; only planted crops show now.
#   f2_fallow_<a|b|d>.png   the fallow fields: the same field art, lighter and greener than the old flat tint, its
#                           rows broken up by grass, weeds and old stubble, and its rim softened into the meadow.
import random
from PIL import Image

SRC = "art/farm/"
OUT = "art/farm/concept/"


def hexc(s, a=255):
    return (int(s[0:2], 16), int(s[2:4], 16), int(s[4:6], 16), a)


# The cave mouth's own palette (art/farm/cave_mouth.png) and the hillside's dry grass.
ROCK_HI, ROCK_LT, ROCK_MID, ROCK_DK, ROCK_SH = map(hexc, ["879586", "738176", "5e6b64", "394443", "1f2928"])
MOSS_HI, MOSS, MOSS_MID, MOSS_DK, MOSS_SH = map(hexc, ["7f985d", "6b814b", "576b45", "405033", "2a372a"])
ROOT, ROOT_HI = hexc("3a2c24"), hexc("574740")
VOID, VOID_EDGE, WALL = hexc("050607"), hexc("0d1112"), hexc("1a2222")
# Frame planks → stone, by matching shade.
PLANK_TO_ROCK = {hexc("7e6e5c"): ROCK_HI, hexc("68584c"): ROCK_LT, hexc("574740"): ROCK_MID,
                 hexc("3e3130"): ROCK_DK, hexc("2b2322"): ROCK_SH}


def cave_mouth():
    rnd = random.Random(11)
    im = Image.open(SRC + "cave_mouth.png").convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(17, 44):
        for x in range(17, 47):
            if px[x, y] in PLANK_TO_ROCK:
                px[x, y] = PLANK_TO_ROCK[px[x, y]]
            elif px[x, y] == (0, 0, 0, 255) and not (24 <= x <= 37 and 24 <= y <= 42):
                px[x, y] = ROCK_SH   # the frame's outlines, outside the old doorway
    # The opening: an uneven arch, its crown pushed left like a split in the rock, a little wider at the floor.
    sill, top, cx = 42, 18, 31
    half = {}
    for y in range(top, sill + 1):
        t = (y - top) / 12.0
        if t < 1.0:
            hw = 12.5 * (1.0 - (1.0 - t) ** 2) ** 0.5
        else:
            hw = 12.5 + (y - top - 12) * 0.12
        lx = cx - hw - (1 if y > top + 6 else 0) + rnd.choice([0, 0, 1, -1])
        rx = cx + hw * 0.92 + rnd.choice([0, 0, 1, -1])
        half[y] = (round(lx), round(rx))
    inside = lambda x, y: y in half and half[y][0] <= x <= half[y][1]
    for y, (lx, rx) in half.items():
        for x in range(lx, rx + 1):
            if not (0 <= x < w):
                continue
            edge = not (inside(x - 1, y) and inside(x + 1, y) and inside(x, y - 1))
            depth = y - min(yy for yy in half if half[yy][0] <= x <= half[yy][1])   # rows below the arch's lip here
            if edge:
                px[x, y] = VOID_EDGE
            elif depth <= 2 and y < sill - 6:
                px[x, y] = WALL if depth == 1 else VOID_EDGE   # the underside of the overhang, in shadow
            else:
                px[x, y] = VOID
    # The floor sloping down into the dark: dithered stone near the sill, gone a few rows in.
    for y in range(sill - 5, sill + 1):
        lx, rx = half[y]
        k = (y - (sill - 5)) / 5.0
        for x in range(lx + 1, rx):
            if (x + y * 2) % 4 < round(k * 4):
                px[x, y] = ROCK_DK if y == sill and x % 3 == 0 else ROCK_SH
    # The lip over the opening: lit stone, then moss that spills over the edge.
    for x in range(min(v[0] for v in half.values()) - 1, max(v[1] for v in half.values()) + 2):
        ys = [y for y in half if half[y][0] <= x <= half[y][1]]
        if not ys:
            continue
        y0 = min(ys)
        if y0 > sill - 8:
            continue   # the sides, low down: no lip
        if 0 <= y0 - 1:
            px[x, y0 - 1] = ROCK_SH
        if 0 <= y0 - 2:
            px[x, y0 - 2] = ROCK_LT
        thick = rnd.choice([1, 2, 2, 3])
        for k in range(thick):
            yy = y0 - 2 - k
            if yy >= 0:
                px[x, yy] = [MOSS, MOSS_MID, MOSS_HI][min(k, 2)] if k < thick - 1 else MOSS_HI
        if rnd.random() < 0.35:
            for k in range(rnd.choice([1, 1, 2])):
                if inside(x, y0 + k):
                    px[x, y0 + k] = MOSS_DK if k == 0 else MOSS_SH
    # Roots hanging into the dark from the lip.
    for rx0, length in [(22, 6), (25, 10), (29, 5), (33, 9), (37, 7), (39, 4)]:
        ys = [y for y in half if half[y][0] <= rx0 <= half[y][1]]
        if not ys:
            continue
        x, y = rx0, min(ys)
        for k in range(length):
            if not inside(x, y + k):
                break
            px[x, y + k] = ROOT_HI if k < 2 else ROOT
            if k % 3 == 2:
                x += rnd.choice([-1, 0, 1])
                if inside(x, y + k):
                    px[x, y + k] = ROOT
    # Ferns at the foot of each side, and two fallen stones on the threshold.
    def fern(bx, by, flip):
        fronds = [(0, 0), (1, -1), (2, -2), (3, -3), (1, 0), (2, -1), (4, -2), (2, 0), (3, -1), (5, -1),
                  (-1, -1), (-2, -2), (0, -1), (0, -2), (1, -3), (-1, -3)]
        for dx, dy in fronds:
            x = bx + (-dx if flip else dx)
            y = by + dy
            if 0 <= x < w and 0 <= y < h:
                px[x, y] = MOSS_HI if dy <= -3 else (MOSS if dy <= -1 else MOSS_MID)
        for dx, dy in [(0, 1), (1, 1), (-1, 0), (2, 1)]:
            x, y = bx + (-dx if flip else dx), by + dy
            if 0 <= x < w and 0 <= y < h and px[x, y][3] > 0:
                px[x, y] = MOSS_SH
    fern(half[sill][0] - 1, sill, True)
    fern(half[sill][0] + 1, sill + 1, False)
    fern(half[sill][1] + 1, sill, False)
    fern(half[sill - 3][1] + 2, sill - 3, False)
    for sx, sy in [(27, 44), (34, 45)]:
        for dx, dy, c in [(0, 0, ROCK_HI), (1, 0, ROCK_LT), (0, 1, ROCK_MID), (1, 1, ROCK_MID), (2, 1, ROCK_SH),
                          (-1, 1, ROCK_SH), (0, 2, ROCK_SH), (1, 2, ROCK_SH)]:
            if 0 <= sx + dx < w and 0 <= sy + dy < h:
                px[sx + dx, sy + dy] = c
    # Set the face back into the hill: the stone a shade darker overall, and darker still close to the opening.
    void = [(x, y) for y in range(h) for x in range(w) if px[x, y] in (VOID, VOID_EDGE, WALL)]
    near = {}
    for vx, vy in void:
        for dy in range(-4, 5):
            for dx in range(-4, 5):
                d = max(abs(dx), abs(dy))
                k = (vx + dx, vy + dy)
                if d and (k not in near or near[k] > d):
                    near[k] = d
    for y in range(h):
        for x in range(w):
            c = px[x, y]
            if c[3] == 0 or c in (VOID, VOID_EDGE, WALL) or c in (ROOT, ROOT_HI):
                continue
            f = 0.9 * (0.72 + 0.07 * near[(x, y)] if (x, y) in near and y > 12 else 1.0)
            px[x, y] = (int(c[0] * f), int(c[1] * f), int(c[2] * f), c[3])
    im.save(OUT + "cave_mouth_natural.png")


# Fallow: grass taking back an old field. Lighter and greener than the old flat FALLOW_TINT multiply, so it reads as
# ground and not as a hole, but well short of the open field's tilled rows: the soil goes grey-brown, grass grows over
# it in soft patches (thickest at the rim), with tufts, old stubble and a ragged edge that lets the meadow in.
GRASS = list(map(hexc, ["44532f", "4f5f36", "5b6c3d", "687a45"]))
GRASS_DK = hexc("34402a")
DRY = list(map(hexc, ["8a7a4a", "9c8a52", "75683f"]))


def noise(rnd, w, h, cell):
    gw, gh = w // cell + 2, h // cell + 2
    g = [[rnd.random() for _ in range(gw)] for _ in range(gh)]
    def at(x, y):
        fx, fy = x / cell, y / cell
        ix, iy = int(fx), int(fy)
        tx, ty = fx - ix, fy - iy
        tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
        a = g[iy][ix] * (1 - tx) + g[iy][ix + 1] * tx
        b = g[iy + 1][ix] * (1 - tx) + g[iy + 1][ix + 1] * tx
        return a * (1 - ty) + b * ty
    return at


BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def fallow(name):
    rnd = random.Random(sum(map(ord, name)))
    src = Image.open(OUT + "f2_field_dry_" + name + ".png").convert("RGBA")
    w, h = src.size
    im = src.copy()
    px = im.load()
    sp = src.load()
    cover = noise(rnd, w, h, 9)
    shade = noise(rnd, w, h, 5)
    rim = noise(rnd, w, h, 4)
    for y in range(h):
        for x in range(w):
            r, g, b, a = sp[x, y]
            if a == 0:
                continue
            # Ragged rim: the meadow eats into the field's edge by up to four pixels.
            edge = min(x, y, w - 1 - x, h - 1 - y)
            if edge < rim(x, y) * 4.5 - 0.5:
                px[x, y] = (0, 0, 0, 0)
                continue
            # Grey-brown soil, keeping the furrows' light and shade.
            l = r * 0.35 + g * 0.5 + b * 0.15
            soil = (int(l * 0.95 + 8), int(l * 0.88 + 8), int(l * 0.7 + 6), a)
            # Grass cover: patches, heavier near the rim, dithered at their edges.
            c = cover(x, y) * 0.9 + max(0.0, 1.0 - edge / 9.0) * 0.55 - 0.18
            if c > (BAYER[y % 4][x % 4] + 0.5) / 16.0:
                k = shade(x, y)
                i = 0 if k < 0.3 else 1 if k < 0.55 else 2 if k < 0.8 else 3
                if l < 70 and i > 0:
                    i -= 1   # furrow shadows stay a shade darker under the grass
                px[x, y] = GRASS[i]
            else:
                px[x, y] = soil
    # Tufts: a dark root pixel under a lighter blade or two.
    for _ in range(w * h // 60):
        x, y = rnd.randrange(3, w - 3), rnd.randrange(4, h - 3)
        if px[x, y][3] == 0 or px[x, y - 2][3] == 0:
            continue
        px[x, y] = GRASS_DK
        px[x, y - 1] = GRASS[3]
        if rnd.random() < 0.5:
            px[x + rnd.choice([-1, 1]), y - 2] = GRASS[2]
    # Old stubble and a few dry seed heads, on the bare soil.
    for _ in range(w * h // 120):
        x, y = rnd.randrange(4, w - 4), rnd.randrange(5, h - 4)
        if px[x, y] in GRASS or px[x, y][3] == 0:
            continue
        c = rnd.choice(DRY)
        px[x, y] = c
        px[x, y - 1] = c
        if rnd.random() < 0.4:
            px[x + 1, y - 2] = DRY[1]
    # A dark grass outline where field meets meadow, broken up, so the edge reads without a hard box.
    out = im.copy()
    op = out.load()
    for y in range(h):
        for x in range(w):
            if px[x, y][3] == 0:
                continue
            n = [(x + dx, y + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
            if any(not (0 <= a < w and 0 <= b < h) or px[a, b][3] == 0 for a, b in n) and (x * 3 + y * 5) % 4:
                op[x, y] = GRASS_DK if (x + y) % 3 else GRASS[1]
    out.save(OUT + "f2_fallow_" + name + ".png")


# --- The hill's foot ------------------------------------------------------------------------------------------------
LEAVES = list(map(hexc, ["7a4128", "8e5230", "6a3a26", "9a6a34"]))
FOOT_BOX = (780, 400, 1760, 960)    # world px (3 per art px) covering the hill's foot
MOUTH_GAP = (1160, 1290)            # world x of the cave's opening and path: no ferns there
BORDER_Y = 8
FAKE_CROPS = ["r3_garden_props_clean_0.png", "r3_garden_props_clean_1.png", "r3_crops_b_clean_7.png"]


def _paste_mask(mask, rec, ox, oy):
    name = str(rec["t"])
    path = name.replace("res://", "") if name.startswith("res://") else OUT + name
    im = Image.open(path).convert("RGBA")
    if rec.get("fh"):
        im = im.transpose(Image.FLIP_LEFT_RIGHT)
    x, y = round(rec["x"] / 3 - ox), round(rec["y"] / 3 - oy)
    mask.paste(im, (x, y), im)


def fern_sprites():
    # Two small ferns from the moss palette: a dark stem-and-shadow base, fronds fanning up and out, lit tips.
    shapes = {
        "a": ["....h.....h..",
              "...hm...mh...",
              ".h..mm.mm..h.",
              "..mm.mmm..mm.",
              "hm..mdmdm..mh",
              ".mmmd.d.dmmm.",
              "..ddmdddmdd..",
              "...sddsdds...",
              "....sssss...."],
        "b": [".h.....h.",
              "..m...m..",
              "h.mm.mm.h",
              ".m.mdm.m.",
              "..mmdmm..",
              ".ddmdmdd.",
              "..sdsds..",
              "...sss..."],
    }
    pal = {"h": MOSS_HI, "m": MOSS, "d": MOSS_DK, "s": MOSS_SH}
    for k, rows in shapes.items():
        im = Image.new("RGBA", (len(rows[0]), len(rows)), (0, 0, 0, 0))
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch in pal:
                    im.putpixel((x, y), pal[ch])
        im.save(OUT + "fern_" + k + ".png")


def hill_foot():
    import json
    rnd = random.Random(8)
    data = json.load(open(OUT + "scenery.json"))
    # Drop what an earlier run added, so the script can be run again.
    data["sprites"] = [r for r in data["sprites"] if not r.get("farm001r")]
    data["sprites"] = [r for r in data["sprites"] if r["t"] not in FAKE_CROPS]
    for r in data["sprites"]:
        if r["t"] == "res://art/farm/cave_mouth.png":
            r["t"] = "cave_mouth_natural.png"
    ox, oy = FOOT_BOX[0] / 3, FOOT_BOX[1] / 3
    w, h = int((FOOT_BOX[2] - FOOT_BOX[0]) / 3), int((FOOT_BOX[3] - FOOT_BOX[1]) / 3)
    mask = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    hill = [r for r in data["sprites"] if str(r["t"]).endswith(("hillside.png", "cave_mouth_natural.png"))]
    for r in sorted(hill, key=lambda r: r["b"]):
        _paste_mask(mask, r, ox, oy)
    mp = mask.load()
    foot = {}
    for x in range(w):
        ys = [y for y in range(h) if mp[x, y][3] > 0]
        if ys:
            foot[x] = max(ys)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    op = out.load()
    depth = noise(rnd, w, 4, 7)
    for x, fy in foot.items():
        wx = FOOT_BOX[0] + x * 3
        if MOUTH_GAP[0] <= wx <= MOUTH_GAP[1]:
            continue   # the worn path into the cave stays bare
        d = 3 + depth(x, 1) * 7
        for k in range(1, int(d) + 2):
            y = fy + k
            if y >= h:
                break
            t = k / d
            if t < (BAYER[y % 4][x % 4] + 0.5) / 16.0 * 1.3:
                op[x, y] = MOSS_SH if t < 0.35 else (MOSS_DK if (x + y) % 3 else GRASS_DK)
        # Roots out from under the rock.
        if rnd.random() < 0.06:
            rx, ry = x, fy + 1
            for k in range(rnd.randint(2, 5)):
                if 0 <= rx < w and ry < h:
                    op[rx, ry] = ROOT if k else ROOT_HI
                ry += 1
                if k % 2:
                    rx += rnd.choice([-1, 1])
    # The cave breathes cold: a dithered shadow on the ground just outside the opening, deepest at the sill.
    for x, fy in foot.items():
        wx = FOOT_BOX[0] + x * 3
        if not MOUTH_GAP[0] + 15 <= wx <= MOUTH_GAP[1] - 15:
            continue
        mid = (MOUTH_GAP[0] + MOUTH_GAP[1]) / 2
        reach = 7 * (1.0 - abs(wx - mid) / ((MOUTH_GAP[1] - MOUTH_GAP[0]) / 2)) ** 0.5
        for k in range(1, int(reach) + 1):
            if fy + k < h and k / (reach + 0.01) < (BAYER[(fy + k) % 4][x % 4] + 0.5) / 16.0 * 1.4:
                op[x, fy + k] = (8, 10, 11, 150 if k > 2 else 200)
    # Fallen leaves along and just past the fringe.
    xs = [x for x in foot if not MOUTH_GAP[0] <= FOOT_BOX[0] + x * 3 <= MOUTH_GAP[1]]
    for _ in range(len(xs) // 4):
        x = rnd.choice(xs)
        y = foot[x] + rnd.randint(1, 12)
        if y < h - 1:
            c = rnd.choice(LEAVES)
            op[x, y] = c
            if rnd.random() < 0.5 and x + 1 < w:
                op[x + 1, y] = c
    out.save(OUT + "hill_foot.png")
    data["sprites"].append({"t": "hill_foot.png", "x": float(FOOT_BOX[0]), "y": float(FOOT_BOX[1]), "s": 3.0,
                            "fh": False, "m": "f2f2f0ff", "mn": "c2c2c0ff", "z": 0, "b": -1000.0, "tx": -1000,
                            "ty": -1000, "forest": False, "farm001r": True})
    # Ferns over the hill's foot, every few tiles, not in front of the cave.
    fern_sprites()
    x = 4
    while x < w - 4:
        wx = FOOT_BOX[0] + x * 3
        if x in foot and not MOUTH_GAP[0] - 30 <= wx <= MOUTH_GAP[1] + 30:
            k = rnd.choice("aab")
            fw, fh = (13, 9) if k == "a" else (9, 8)
            bottom = (foot[x] + 2 + oy) * 3
            data["sprites"].append({"t": "fern_%s.png" % k, "x": float(wx - fw * 1.5), "y": float(bottom - fh * 3),
                                    "s": 3.0, "fh": rnd.random() < 0.5, "m": "f2f2f0ff", "mn": "c2c2c0cc", "z": -1,
                                    "b": round(bottom / 48.0 - BORDER_Y, 3), "tx": int(wx // 48 - 14),
                                    "ty": int(bottom // 48 - BORDER_Y), "forest": False, "farm001r": True})
        x += rnd.randint(9, 16)
    with open(OUT + "scenery.json", "w") as f:
        json.dump(data, f, separators=(",", ":"))


if __name__ == "__main__":
    cave_mouth()
    for n in ["a", "b", "d"]:
        fallow(n)
    hill_foot()
    print("ok")
