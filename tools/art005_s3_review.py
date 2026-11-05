# ART-005 S3 review panels (non-production). Reads the harness frames and writes the panels to
# art/style_tests/ART-005/s3/review/:
#   house frames  builds/review/ART-005/s3/ (tools/art005_density.gd density=32 art=g6 var=..., hour=12 and 21.5,
#                 framing=int at 1080p and framing=today at 720p; stage 0 with winlights=0, stage 1 winlights=dim)
#                 and S2's builds/review/ART-005/s2/ (the S2 log house and stages, for BEFORE)
#   field/farm    builds/review/ART-005/s3_export/builds/x/ (tools/art003_wide.gd mode=wide layout=b grass=1, run in
#                 a git-archive export of HEAD plus the S3 tools and mockup art, so no VIS-002 work is in them)
#   python tools/art005_s3_review.py
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402
import art005_s2_review as r2  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
REV = os.path.join(m0.ROOT, "s3", "review")
HF3 = os.path.join(HERE, "..", "builds", "review", "ART-005", "s3")
HF2 = r2.HF
FF = os.path.join(HERE, "..", "builds", "review", "ART-005", "s3_export", "builds", "x")
G6 = os.path.join(m0.ROOT, "pl", "g6")
NIGHT = r2.NIGHT
NIGHT_R31 = r2.NIGHT_R31
r2.REV = REV   # grid() writes into REV


def hf(tag, hr, fr):
    base = HF3 if tag.startswith("X") else HF2
    if fr == "int":
        return r2.load(os.path.join(base, "%s32_%s_int_1080p.png" % (tag, hr))).crop((680, 0, 1500, 800))
    return r2.load(os.path.join(base, "%s32_%s_today_720p.png" % (tag, hr))).crop((416, 0, 1056, 600))


def spr(v, scale=1, box=None, night=False):
    p = os.path.join(G6, v, "32", "house_%s.png" % ("night" if night else "day")) if not v.startswith("s2:") else \
        os.path.join(m0.ROOT, "pl", "g5", v[3:], "32", "house_%s.png" % ("night" if night else "day"))
    return r2.sprite_on(p, scale, box)


def roofs():
    for fr, name, label in (("today", "s3_roofs_720p.png", "the game's own 720p zoom (tile = 48 px), 1:1 crops"),
                            ("int", "s3_roofs_1080p.png", "1080p, integer framing (2x), 1:1 crops")):
        r2.grid(name, "ART-005 S3 roofs: S2 slate | A dark wood shakes | B quiet dark slate - " + label,
                "Harness tools/art005_density.gd density=32, same scene, camera and lights. A and B also carry the revised "
                "hewn corners. Roofline, rake, fascia, chimney, door, windows, foundation, footprint: SA's. Zero generation.",
                [("S2 log house, SA slate - day 12:00", hf("VLOG", "day", fr)),
                 ("A  wood shakes - day 12:00", hf("XSHAKE", "day", fr)),
                 ("B  quiet slate - day 12:00", hf("XSLATE", "day", fr)),
                 ("S2 - " + NIGHT.split(" (")[0], hf("VLOG", "night", fr)),
                 ("A - night 21:30, harness night", hf("XSHAKE", "night", fr)),
                 ("B - night 21:30, harness night", hf("XSLATE", "night", fr))], 3)


def closeups():
    cells = []
    for lab, box in (("west corner, 3x", (0, 150, 110, 300)), ("east corner, 3x", (274, 150, 384, 300))):
        cells.append(("S2  " + lab + ": round end grain", spr("s2:log", 3, box)))
        cells.append(("S3  " + lab + ": interlocking hewn timbers", spr("logc", 3, box)))
    r2.grid("s3_corners.png", "ART-005 S3: log corners, S2 | S3 (sprites, 3x, day)",
            "S3: front logs run 5-8 px past the corner with an axe-cut end; between them, straddling each seam, a side-wall "
            "timber's squared end (own width/height, off-centre pith, check crack, some bark), dark gap all round. "
            "Wall outside the corners is byte-identical to S2.", cells, 2)
    box = (0, 40, 200, 160)
    r2.grid("s3_roof_closeups.png", "ART-005 S3: roof material close-ups, 3x (day, west half)",
            "A: 10 courses (9-11 px), shakes 8-18 px wide, 1 px joints in the lower part, long grain streaks on some, a "
            "lit butt on ~40%, soft silvered patches, moss only in 6 small clumps near the eave. B: 10 courses, slates "
            "15-26 px, one base tone with sparse +-1 steps, joints only below the top 2 rows, no moss or motif.",
            [("S2 SA slate", spr("s2:log", 3, box)), ("A  wood shakes", spr("shake", 3, box)),
             ("B  quiet slate", spr("slate", 3, box))], 3)


def stages():
    names = ["0 Dilapidated", "1 Stabilized", "2 Repaired", "3 Restored"]
    for kind, tag, lab in (("shake", "SH", "A wood shakes"), ("slate", "SL", "B quiet slate")):
        cells = [("Stage %s - day 12:00" % n, hf("X%s%d" % (tag, i), "day", "today")) for i, n in enumerate(names)]
        cells += [("Stage %s - night 21:30%s" % (n, [", window lights off", ", one dim lamp inside", "", ""][i]),
                   hf("X%s%d" % (tag, i), "night", "today")) for i, n in enumerate(names)]
        r2.grid("s3_stages_%s_720p.png" % kind,
                "ART-005 S3: four restoration stages (SCHEMATIC), roof %s, 720p game zoom" % lab,
                "Same roofline, footprint, door and window centres in every stage. Night: ART-005 harness night (not R3-1); "
                "stage 0 no window lights, stage 1 winlights=dim (0.3 energy, 1-tile radius), stages 2-3 full.", cells, 4)
    # the two fixes: stage 1 at night, stage 0 roof damage
    cells = [("S2 stage 0 - night (window lights off)", hf("VST0", "night", "today")),
             ("S2 stage 1 - night: the same dark house", hf("VST1", "night", "today")),
             ("S3 stage 0 - night (window lights off)", hf("XSH0", "night", "today")),
             ("S3 stage 1 - night: lamplight between the boards", hf("XSH1", "night", "today"))]
    r2.grid("s3_stage_fix_night.png", "ART-005 S3 fix: stage 1 is now inhabited at night (720p, harness night)",
            "S3 stage 1: warm light in the 2 px gaps between the window boards (brightest mid-gap), a thin line under the "
            "door, and a faint low light at each window (winlights=dim). Stage 0 stays dark.", cells, 4)
    rb = (20, 44, 300, 150)
    wb = (60, 190, 330, 260)
    r2.grid("s3_stage_fix_closeups.png", "ART-005 S3 fixes, sprites 2x: stage 0 roof holes and stage 1 windows",
            "Stage 0 holes are now whole missing shakes or slates inside a lobed, noisy outline, with broken units "
            "snapped on a slant at the rim and a few slipped units; laths, rafters and the dark attic inside.",
            [("S2 stage 0 roof: rectangular holes", spr("s2:st0", 2, rb)), ("S3 stage 0, roof A", spr("sh0", 2, rb)),
             ("S3 stage 0, roof B", spr("sl0", 2, rb)), ("S3 stage 1 roof A: boards and draped tarp", spr("sh1", 2, rb)),
             ("S2 stage 1 windows, night sprite", spr("s2:st1", 2, wb, night=True)),
             ("S3 stage 1 windows, night sprite", spr("sh1", 2, wb, night=True))], 2)
    cells = [("Stage %s, roof A, sprite 1:1" % n, spr("sh%d" % i)) for i, n in enumerate(names)]
    sa = np.array(r2.load(os.path.join(m0.ROOT, "pl", "g4", "sa", "32", "house_day.png")))[..., 3] > 0
    for i, n in enumerate(names):
        a = np.array(r2.load(os.path.join(G6, "sh%d" % i, "32", "house_day.png")))[..., 3] > 0
        sil = np.zeros((320, 384, 4), np.uint8)
        sil[...] = (62, 78, 52, 255)
        sil[a & sa] = (150, 150, 150, 255)
        sil[a & ~sa] = (90, 170, 230, 255)
        sil[sa & ~a] = (230, 80, 60, 255)
        cells.append(("Stage %s vs SA: grey same, blue added, red removed" % n.split(" ")[0], Image.fromarray(sil, "RGBA")))
    r2.grid("s3_stages_sprites.png", "ART-005 S3: stage sprites (roof A) 1:1 and silhouettes against SA",
            "Blue = added (corner timbers, dressing below the wall, stage 0 vines/weeds); red = removed (stage 0's "
            "broken chimney top only). The roofline, eave and openings never move.", cells, 4)


def fields():
    v = lambda n: r2.load(os.path.join(FF, n))
    r2.grid("s3_fields_v2.png", "ART-005 S3 fields: S2 F1 | S3 F2 polish, 720p gameplay (V2)",
            "tools/art003_wide.gd mode=wide layout=b grass=1, art=f1 vs art=f2, 1280x720 at 3x. Same four 7x4 fields, "
            "walks, fence, gates; reachable tiles identical (1,608, check=reach). Drawing only.",
            [("BEFORE  F1 - day 12:00", v("f1_v2_day.png")), ("AFTER  F2 - day 12:00", v("f2_v2_day.png")),
             ("BEFORE - " + NIGHT_R31, v("f1_v2_night.png")), ("AFTER - " + NIGHT_R31, v("f2_v2_night.png"))], 2)
    cells = []
    for n, lab in (("field_dry_a", "A ripe"), ("field_dry_b", "B growing"), ("field_wet_c", "C planted, watered"),
                   ("field_dry_d", "D partly harvested")):
        for d in ("f1", "f2"):
            im = r2.load(os.path.join(HERE, "..", "art", "style_tests", "ART-003", d, n + ".png"))
            bg = Image.new("RGBA", im.size, (120, 100, 75, 255))
            bg.alpha_composite(im)
            cells.append(("%s  %s soil, 4x" % (d.upper(), lab), bg.resize((im.width * 4, im.height * 4), Image.NEAREST)))
    r2.grid("s3_fields_soil.png", "ART-005 S3: field soil images F1 | F2, 4x (no crops)",
            "F2: each ridge row wobbles on its own, furrow broken where soil slumped, crest highlight in runs, slow tone "
            "drift; rim wobble +-3 px with bites and spilt clods, corners of differing radius; patchy wet soil in C.",
            cells, 2)


def farm():
    v = lambda n: r2.load(os.path.join(FF, n))
    for half, at, desc in (("north", "(45, 10)", "house, golden oak, well and crossroads"),
                           ("south", "(50, 30)", "the four fields, walks, gates, road and the closed east gate")):
        t = half[0]
        r2.grid("s3_farm_%s.png" % half,
                "ART-005 S3 homestead, %s: %s (W-4 layout, 3x, window 1924 x 1061)" % (half, desc),
                "BEFORE = S2 prototype (art=f1, the W-3p house sprite). AFTER = art=f2 with the S3 cabin drawn at half scale "
                "(1 art px = 1.5 screen px, as the 720p house frames); house dressing tiles left bare. Farmer at %s." % at,
                [("BEFORE  S2 (F1 fields, W-3p house) - day 12:00", v("f1_%s_day.png" % t)),
                 ("AFTER  F2 + cabin, roof A shakes - day 12:00", v("sh_%s_day.png" % t)),
                 ("AFTER  F2 + cabin, roof B slate - day 12:00", v("sl_%s_day.png" % t)),
                 ("AFTER  roof A - " + NIGHT_R31, v("sh_%s_night.png" % t))], 2)


def main():
    os.makedirs(REV, exist_ok=True)
    gi = os.path.join(REV, ".gdignore")
    if not os.path.exists(gi):
        open(gi, "w").close()
    roofs()
    closeups()
    stages()
    fields()
    farm()


if __name__ == "__main__":
    main()
