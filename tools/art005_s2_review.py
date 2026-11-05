# ART-005 S2 review panels (non-production). Reads the harness frames and writes the panels to
# art/style_tests/ART-005/s2/review/:
#   house frames  builds/review/ART-005/s2/   (tools/art005_density.gd density=32, art=g4 var=sa and art=g5
#                 var=log|st0..st3, hour=12 and 21.5, framing=int at 1080p and framing=today at 720p)
#   field frames  builds/review/ART-005/s2_export/builds/x/ (tools/art003_wide.gd mode=wide layout=b grass=1, art=w4
#                 BEFORE and art=f1 AFTER, run in a git-archive export of HEAD, so no VIS-002 work is in them)
#   python tools/art005_s2_review.py
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
REV = os.path.join(m0.ROOT, "s2", "review")
HF = os.path.join(HERE, "..", "builds", "review", "ART-005", "s2")
FF = os.path.join(HERE, "..", "builds", "review", "ART-005", "s2_export", "builds", "x")
WIDE = os.path.join(HERE, "..", "art", "style_tests", "ART-003", "wide", "blueprint_wide_v1b_w3b.txt")
BG = (28, 30, 34)
FG = (232, 232, 228)
DIM = (170, 172, 176)
F = ImageFont.load_default(size=16)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=22)
NIGHT = "night 21:30, ART-005 harness night (production NIGHT_TINT, lantern, window lights; not R3-1)"
NIGHT_R31 = "night 21:30, R3-1 (the locked ART-003 prototype night)"


def load(p):
    return Image.open(p).convert("RGBA")


def grid(name, title, note, cells, cols):
    """cells: list of (caption, image). Laid out in rows of `cols`, each cell at 1:1."""
    w = max(im.width for _, im in cells)
    h = max(im.height for _, im in cells)
    gap, pad, head, cap = 12, 16, 70, 26
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGBA", (pad * 2 + cols * w + (cols - 1) * gap, head + rows * (cap + h + gap) + pad), BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((pad, 12), title, font=FB, fill=FG)
    d.text((pad, 42), note, font=FS, fill=DIM)
    for i, (c, im) in enumerate(cells):
        x = pad + (i % cols) * (w + gap)
        y = head + (i // cols) * (cap + h + gap)
        d.text((x, y + 4), c, font=F, fill=FG)
        out.alpha_composite(im, (x, y + cap))
    out.convert("RGB").save(os.path.join(REV, name))
    print(name, out.size)


def hframe(tag, hr, fr):
    if fr == "int":
        return load(os.path.join(HF, "%s32_%s_int_1080p.png" % (tag, hr))).crop((680, 0, 1500, 800))
    return load(os.path.join(HF, "%s32_%s_today_720p.png" % (tag, hr))).crop((416, 0, 1056, 600))


def sprite_on(path, scale=1, box=None):
    s = load(path)
    if box:
        s = s.crop(box)
    bg = Image.new("RGBA", s.size, (62, 78, 52, 255))
    bg.alpha_composite(s)
    return bg.resize((s.width * scale, s.height * scale), Image.NEAREST)


def house_panels():
    sa = os.path.join(m0.ROOT, "pl", "g4", "sa", "32")
    lg = os.path.join(m0.ROOT, "pl", "g5", "log", "32")
    for fr, name, label in (("int", "s2_house_1080p.png", "1080p, integer framing (2x), 1:1 crops"),
                            ("today", "s2_house_720p.png", "the game's own 720p zoom (tile = 48 px), 1:1 crops")):
        grid(name, "ART-005 S2: SA baseline | SA with provisional log-cabin wall, " + label,
             "Harness tools/art005_density.gd density=32. Same scene, camera, lights. SA's roof, windows, door, "
             "foundation, steps, canvas and footprint unchanged; only the wall and corners differ. Zero generation.",
             [("SA baseline (S1 materials) - day 12:00", hframe("SSA", "day", fr)),
              ("SA + log wall (S2) - day 12:00", hframe("VLOG", "day", fr)),
              ("SA baseline - " + NIGHT, hframe("SSA", "night", fr)),
              ("SA + log wall - " + NIGHT, hframe("VLOG", "night", fr))], 2)
    # 1:1 sprites and 3x close-ups of the corner, a window and the door
    cells = [("SA baseline sprite, 1:1 (384 x 320)", sprite_on(os.path.join(sa, "house_day.png"))),
             ("SA + log wall sprite, 1:1", sprite_on(os.path.join(lg, "house_day.png")))]
    for lab, box in (("west corner: notched log ends, 3x", (0, 150, 128, 300)),
                     ("window and logs, 3x", (60, 190, 188, 280)),
                     ("door, lamp and steps, 3x", (150, 200, 278, 320))):
        cells.append(("SA  " + lab, sprite_on(os.path.join(sa, "house_day.png"), 3, box)))
        cells.append(("LOG " + lab, sprite_on(os.path.join(lg, "house_day.png"), 3, box)))
    grid("s2_house_closeups.png", "ART-005 S2: SA | SA + log wall, sprites 1:1 and 3x close-ups (day)",
         "Logs: 8 courses (14-16 px) from the eave to the stone foundation, a dark recessed seam, lit upper curve, "
         "shaded underside, long grain streaks and a few knots; corners: alternating end grain. Upper-left light.",
         cells, 2)


def stage_panels():
    names = ["0 Dilapidated (Decrepit)", "1 Stabilized (Boarded)", "2 Repaired (Patched)", "3 Restored"]
    cells = [("Stage %s - day 12:00, 720p game zoom" % n, hframe("VST%d" % i, "day", "today")) for i, n in enumerate(names)]
    cells += [("Stage %s - night 21:30%s" % (n, ", window lights off" if i < 2 else ""), hframe("VST%d" % i, "night", "today"))
              for i, n in enumerate(names)]
    grid("s2_stages_720p.png", "ART-005 S2: four restoration stages on one fixed structure (SCHEMATIC mockups), 720p",
         "Same roofline, footprint, door, window openings and centres in every stage; only condition and dressing "
         "change. Schematic placeholders to test the plan, not candidate art. Night: ART-005 harness night (not R3-1).",
         cells, 4)
    cells = [("Stage %s, sprite 1:1" % n, sprite_on(os.path.join(m0.ROOT, "pl", "g5", "st%d" % i, "32", "house_day.png")))
             for i, n in enumerate(names)]
    # alpha check: silhouette difference from SA
    sa = np.array(load(os.path.join(m0.ROOT, "pl", "g4", "sa", "32", "house_day.png")))[..., 3] > 0
    for i, n in enumerate(names):
        a = np.array(load(os.path.join(m0.ROOT, "pl", "g5", "st%d" % i, "32", "house_day.png")))[..., 3] > 0
        sil = np.zeros((320, 384, 4), np.uint8)
        sil[...] = (62, 78, 52, 255)
        sil[a & sa] = (150, 150, 150, 255)
        sil[a & ~sa] = (90, 170, 230, 255)
        sil[sa & ~a] = (230, 80, 60, 255)
        cells.append(("Stage %s vs SA: grey same, blue added, red removed" % n.split(" ")[0],
                      Image.fromarray(sil, "RGBA")))
    grid("s2_stages_sprites.png", "ART-005 S2: stage sprites 1:1 and their silhouettes against SA",
         "Blue = pixels added (log ends at both corners; dressing below the wall; stage 0 vines/weeds); red = removed "
         "(stage 0's broken chimney top). The roofline, eave and openings never move.", cells, 4)


def field_panels():
    v = lambda a, h: load(os.path.join(FF, "%s_v2_%s.png" % (a, h)))
    grid("s2_fields_v2.png", "ART-005 S2 fields: ART-003 W-4 raised beds | ground-level tilled fields, 720p gameplay (V2)",
         "tools/art003_wide.gd mode=wide layout=b grass=1, art=w4 vs art=f1, 1280x720 at 3x (actual gameplay size), "
         "sunny autumn. Same 7x4 tiles per field, same walks, fence and gates; collision identical (reach check).",
         [("BEFORE  W-4 raised beds - day 12:00", v("w4", "day")), ("AFTER  F1 fields - day 12:00", v("f1", "day")),
          ("BEFORE - " + NIGHT_R31, v("w4", "night")), ("AFTER - " + NIGHT_R31, v("f1", "night"))], 2)
    a = lambda n: load(os.path.join(FF, n))
    grid("s2_fields_wide.png", "ART-005 S2 fields in the homestead: wide frames (3x, window 1924 x 1061)",
         "The fields beside the house, oak, well, crossroads, orchard, road, gate and pond. Only the field area "
         "differs between BEFORE and AFTER; the rest is the W-4 prototype unchanged.",
         [("BEFORE  W-4 - day 12:00, farmer at (31, 20)", a("w4_all_day.png")),
          ("AFTER  F1 - day 12:00, farmer at (31, 20)", a("f1_all_day.png")),
          ("AFTER  F1 - " + NIGHT_R31, a("f1_all_night.png")),
          ("AFTER  F1 - day 12:00, farmer at (44, 22): fields, road, gate side", a("f1_wide_day.png"))], 2)


def diagram():
    grid_rows = [l for l in open(WIDE).read().split("\n") if l]
    x0, x1, y0, y1 = 38, 63, 15, 33
    T = 34
    pad, head = 16, 70
    side = 620
    out = Image.new("RGBA", (pad * 2 + (x1 - x0) * T + 40 + side, head + (y1 - y0) * T + 60), BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((pad, 12), "ART-005 S2: tile-level field layout (proposal F1) on the ART-003 wide homestead grid", font=FB, fill=FG)
    d.text((pad, 42), "Source: art/style_tests/ART-003/wide/blueprint_wide_v1b_w3b.txt (unchanged). One square = one "
           "16 x 16 game tile. Coordinates are prototype inner-farm tiles.", font=FS, fill=DIM)
    fields = {(44, 20): ("A", (150, 110, 70)), (52, 20): ("B", (140, 104, 66)), (44, 25): ("C", (110, 84, 56)),
              (52, 25): ("D", (150, 116, 76))}
    def field_of(x, y):
        for (fx, fy), v in fields.items():
            if fx <= x < fx + 7 and fy <= y < fy + 4:
                return v
        return None
    col = {"X": (90, 70, 50), "g": (210, 170, 70), "w": (170, 150, 120), "P": (150, 132, 104), ".": (70, 96, 60),
           "T": (36, 58, 40), "L": (230, 200, 90), "c": (130, 130, 124)}
    ox, oy = pad + 30, head + 20
    for y in range(y0, y1):
        d.text((pad, oy + (y - y0) * T + 10), str(y), font=FS, fill=DIM)
        for x in range(x0, x1):
            c = grid_rows[y][x] if x < len(grid_rows[y]) else "T"
            f = field_of(x, y)
            fill = f[1] if f else col.get(c, (70, 96, 60))
            r = [ox + (x - x0) * T, oy + (y - y0) * T, ox + (x - x0 + 1) * T - 2, oy + (y - y0 + 1) * T - 2]
            d.rectangle(r, fill=fill)
            if f:
                rr = (y - [k for k in fields if field_of(*k) == f][0][1])
                d.line([(r[0] + 2, r[1] + 12), (r[2] - 2, r[1] + 12)], fill=(80, 56, 36))
                d.text((r[0] + 12, r[1] + 14), f[0], font=FS, fill=(250, 240, 220))
            elif c in "Xgwc":
                d.text((r[0] + 12, r[1] + 9), c, font=FS, fill=(20, 20, 20))
    for x in range(x0, x1, 2):
        d.text((ox + (x - x0) * T + 8, oy - 18), str(x), font=FS, fill=DIM)
    sx = ox + (x1 - x0) * T + 30
    lines = [
        ("Fields (ground-level tilled soil, code S)", FG),
        ("  A  NW  x 44-50, y 20-23   7 x 4 = 28 tiles", FG),
        ("  B  NE  x 52-58, y 20-23   7 x 4 = 28 tiles", FG),
        ("  C  SW  x 44-50, y 25-28   7 x 4 = 28 tiles", FG),
        ("  D  SE  x 52-58, y 25-28   7 x 4 = 28 tiles", FG),
        ("  total 112 plantable tiles (production PLOT_ONE: 15 x 7 = 105)", FG),
        ("  one crop per tile; each tile row is one ridge (furrow lines)", DIM),
        ("", FG),
        ("Walks (w, walkable dirt, 1 tile wide)", FG),
        ("  perimeter ring x 43 / 59, y 19 / 29, cross at x 51 and y 24", FG),
        ("  soil stays walkable (as in the game), so every tile is reachable;", DIM),
        ("  no field tile is more than 2 tiles from a walk", DIM),
        ("", FG),
        ("Fence X and gates g (unchanged)", FG),
        ("  west gate (42, 23-24) to the crossroads path", FG),
        ("  south gate (50-51, 30) to the road", FG),
        ("  L = garden lantern post (41, 22), unchanged", FG),
        ("", FG),
        ("Unchanged by F1: every tile code, the fence, gates, walks, collision", FG),
        ("(reach check identical), house, oak, well, orchard, road, gate, pond.", FG),
        ("F1 changes drawing only: the bed sprites become flat field soil,", FG),
        ("and the stone cross walk becomes trodden dirt.", FG),
        ("", FG),
        ("Soil states shown: A ripe (mixed), B growing (stages 1-2),", DIM),
        ("C just planted and watered (dark soil), D half harvested.", DIM),
    ]
    for i, (t, c) in enumerate(lines):
        d.text((sx, oy + i * 22), t, font=F, fill=c)
    out.convert("RGB").save(os.path.join(REV, "s2_field_diagram.png"))
    print("s2_field_diagram.png", out.size)


def main():
    os.makedirs(REV, exist_ok=True)
    gi = os.path.join(REV, ".gdignore")
    if not os.path.exists(gi):
        open(gi, "w").close()
    house_panels()
    stage_panels()
    field_panels()
    diagram()


if __name__ == "__main__":
    main()
