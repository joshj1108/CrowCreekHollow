# ART-005 C2 review panels (non-production): C1 unchanged | C2 roof polish + timber harmonisation.
# Writes art/style_tests/ART-005/pl/g7/c2/review/.
# Frames: all rendered in ONE session in the clean export builds/review/ART-005/p1_export/ (the C1 export, plus
# pl/g7/c2/32/ copied in; no VIS-002 working-tree change), under its builds/review/ART-005/c2/:
#   tools/art005_density.gd density=32 task=stills art=g7 var=c1 | var=c2, hour=12 and 21.5,
#     res=1920x1080 framing=int and res=1280x720 framing=today
#   x/: tools/art003_wide.gd mode=wide layout=b grass=1 art=f2 size=1924x1080 at=45,10 house=g7:c1 | g7:c2,
#     hour=12 and 21.5 (R3-1 night)
#   python tools/art005_c2_review.py
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402
import art005_p1_review as pr  # noqa: E402
import art005_s2_review as r2  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
C2 = os.path.join(m0.ROOT, "pl", "g7", "c2")
REV = os.path.join(C2, "review")
FR = os.path.join(HERE, "..", "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "c2")
TAGS = (("C1", "YC1"), ("C2", "YC2"))
NAMES = {"C1": "C1 unchanged (control)", "C2": "C2 roof polish + timber tone (proposed)"}
SPR = {"C1": os.path.join(m0.ROOT, "pl", "g7", "c1", "32", "house_%s.png"),
       "C2": os.path.join(C2, "32", "house_%s.png")}
pr.REV = REV


def frame(tag, hr, fr):
    if fr == "int":
        return r2.load(os.path.join(FR, "%s32_%s_int_1080p.png" % (tag, hr))).crop((680, 0, 1500, 800))
    return r2.load(os.path.join(FR, "%s32_%s_today_720p.png" % (tag, hr))).crop((416, 0, 1056, 600))


def spr(v, scale=1, box=None, night=False):
    return r2.sprite_on(SPR[v] % ("night" if night else "day"), scale, box)


def harness():
    for fr, name, label in (("int", "c2_harness_1080p.png", "1080p, integer framing (2x), 1:1 crops"),
                            ("today", "c2_gamescale_720p.png", "actual 720p gameplay scale (tile = 48 px), 1:1 crops")):
        cells = []
        for hr, hl in (("day", "noon 12:00"), ("night", "harness night 21:30")):
            for k, t in TAGS:
                cells.append(("%s - %s" % (NAMES[k], hl), frame(t, hr, fr)))
        pr.grid(name, "ART-005 C2: C1 | C2 - " + label,
                "tools/art005_density.gd density=32, the same scene, camera and lights, both rendered in one session in "
                "a clean export. Only the roof shake field (rows 57-147) and the hewn corner timbers differ. Night = the "
                "ART-005 harness night, NOT R3-1. Trees, ground and props are the old placeholder harness art.", cells, 2)


DETAILS = [("roof west + verge", (0, 40, 128, 162), 3), ("roof centre", (128, 40, 256, 162), 3),
           ("roof east + chimney", (256, 14, 384, 162), 3), ("eave, fascia, wall top", (100, 126, 228, 172), 3),
           ("west timber corner", (0, 156, 48, 290), 3), ("east timber corner", (336, 156, 384, 290), 3)]


def closeups():
    cells = []
    for lab, b, sc in DETAILS[:4]:
        for k, _ in TAGS:
            cells.append(("%s  %s, %dx" % (k, lab, sc), spr(k, sc, b)))
    pr.grid("c2_details_3x.png", "ART-005 C2: roof and eave crops at 3x, C1 | C2 (sprites, day)",
            "The roof is identical on the day and night sprites. Judge: shake read vs brick/tile read, course rhythm, "
            "broad value masses, butt edges, joint weight, eave/fascia/ridge construction.", cells, 2)
    cells = []
    for lab, b, sc in DETAILS[4:]:
        for k, _ in TAGS:
            cells.append(("%s  %s, %dx" % (k, lab, sc), spr(k, sc, b)))
    pr.grid("c2_corners_3x.png", "ART-005 C2: hewn timber corners at 3x, C1 | C2 (sprites, day)",
            "Timber colours moved half way to the wall's hue and saturation, a third of the way in luma.", cells, 4)
    one = []
    for lab, b in (("roof + eave, 1:1", (0, 14, 384, 172)), ("west corner, 1:1", (0, 156, 60, 300)),
                   ("east corner, 1:1", (324, 156, 384, 300))):
        for k, _ in TAGS:
            one.append(("%s  %s" % (k, lab), spr(k, 1, b)))
    pr.grid("c2_details_1x.png", "ART-005 C2: the same areas at 1:1 (sprite pixels), C1 | C2",
            "1:1 is the sprite's own size; the game shows it at 1.5 screen px per art px at 720p.", one, 2)


def farm():
    v = lambda n: r2.load(os.path.join(FR, "x", n)).crop((0, 0, 1480, 1061))
    for t, lab, nm in (("day", "noon 12:00", "c2_farm_day.png"), ("night", r2.NIGHT_R31, "c2_farm_night.png")):
        pr.grid(nm, "ART-005 C2 homestead north (ART-003 W-4 + F2): house, golden oak, well, path - " + lab,
                "tools/art003_wide.gd mode=wide layout=b grass=1 art=f2, house=g7:c1 | g7:c2, rendered in one session. "
                "Cabin at half scale (1 art px = 1.5 screen px). Only the house differs. " +
                ("Night = R3-1, the ART-003 prototype night (not the ART-005 harness night)." if t == "night" else ""),
                [("%s" % NAMES[k], v("%s_n_%s.png" % (k.lower(), t))) for k in ("C1", "C2")], 2)


def changes():
    m = json.load(open(os.path.join(C2, "measure.json")))
    a, b = m["c1_roof"], m["c2_roof"]
    sh, rf, tb = m["shakes"], m["roof_field"], m["timbers"]
    rows = [
        "C2 - ZERO GENERATIONS (tools/art005_c2.py -> pl/g7/c2/measure.json). No PixelLab, SpriteCook or AI call.",
        "Sources (C1 day/night, C1 masks, S3 day/night, P1 day) sha256-checked before and after: unchanged.",
        "",
        "CHANGED REGION 1 - ROOF SHAKE FIELD: rows 57-147, columns 8-375, minus C1's chimney block x294-333 y57-66.",
        "  %d of %d field px changed. Palette: C1's own roof colours only (new colours: %d)." % (
            rf["pixels_changed"], rf["pixels_in_field"], len(rf["new_colours_vs_c1_roof"])),
        "  Kept: the 10 course rows; ridge 42-56, fascia 148-154, eave shadow 155-159, both verges, chimney.",
        "  %d shakes, widths %d-%d px (mean %.1f, %d distinct); every joint >= 3 px off the joints below." % (
            sh["shakes"], sh["widths"]["min"], sh["widths"]["max"], sh["widths"]["mean"], sh["widths"]["distinct"]),
        "  Joints: %d hard, %d soft, %d value change only. Butts: %d drop 1 px, %d sit 1 px short." % (
            sh["hard"], sh["soft"], sh["none"], sh["drop+1"], sh["drop-1"]),
        "  Edge wear: %d chipped butt corners, %d split shakes, %d grain streaks; 7 hand-placed moss clusters." % (
            sh["chips"], sh["splits"], sh["grain"]),
        "  Value masses (hand-authored, one value per shake): ridge shadow, lit upper slope, a large silvered",
        "  field upper left-centre (%d shakes on C1's grey ramp), a smaller bleached patch, chimney runoff," % sh["silver"],
        "  damp eave corners, a low shadow band, verge occlusion.",
        "CHANGED REGION 2 - HEWN CORNER TIMBERS (S3 pixels in C1's mask, rows 160-280, x<26 and x>357):",
        "  %d of %d px; %d colours moved half way to the wall's hue/saturation and a third of the way in" % (
            tb["pixels_changed"], tb["pixels_in_mask"], tb["colours_remapped"]),
        "  luma (timber hue %.3f sat %.2f luma %.0f -> wall hue %.3f sat %.2f luma %.0f); outlines kept." % (
            tb["timber_before"]["hue"], tb["timber_before"]["sat"], tb["timber_before"]["luma_med"],
            tb["wall"]["hue"], tb["wall"]["sat"], tb["wall"]["luma_med"]),
        "Everything else is C1's pixels exactly (asserted), and alpha is identical.",
        "",
        "ROOF FIELD MEASURES                               C1        C2",
        "luma mean / SD                                %5.1f/%4.1f  %5.1f/%4.1f" % (a["luma_mean"], a["luma_sd"],
                                                                                   b["luma_mean"], b["luma_sd"]),
        "pixel noise (mean neighbour step)                %5.2f     %5.2f" % (a["pixel_noise"], b["pixel_noise"]),
        "broad mass contrast (SD of 24x18 block means)    %5.2f     %5.2f" % (a["mass_sd"], b["mass_sd"]),
        "course repetition (row autocorrelation @9 px)    %5.3f     %5.3f" % (a["course_repeat_ac9"],
                                                                            b["course_repeat_ac9"]),
        "near-black line share                            %5.3f     %5.3f" % (a["dark_line_share"],
                                                                            b["dark_line_share"]),
        "colours                                          %5d     %5d" % (a["colours"], b["colours"]),
    ]
    im = Image.new("RGB", (1180, 30 + 20 * len(rows)), r2.BG)
    d = ImageDraw.Draw(im)
    for i, t in enumerate(rows):
        d.text((16, 14 + 20 * i), t, font=r2.FS, fill=r2.FG if t[:4].isupper() else r2.DIM)
    im.save(os.path.join(REV, "c2_receipt.png"))
    ch = r2.load(os.path.join(C2, "changed.png")).resize((768, 640), Image.NEAREST)
    lay = r2.load(os.path.join(C2, "layout.png")).crop((0, 40, 384, 160)).resize((768, 240), Image.NEAREST)
    pr.grid("c2_changes.png", "ART-005 C2: exactly what changed",
            "Left: every changed pixel (red = roof field, cyan = corner timbers, black = C1 untouched). Right: the "
            "authored shading plan, one value per shake (brighter = lighter step; blue tint = C1's silvered grey ramp).",
            [("changed pixels, 2x", ch), ("shading plan (roof rows 40-160), 2x", lay)], 2)


def main():
    os.makedirs(REV, exist_ok=True)
    gi = os.path.join(REV, ".gdignore")
    if not os.path.exists(gi):
        open(gi, "w").close()
    harness()
    closeups()
    farm()
    changes()


if __name__ == "__main__":
    main()
