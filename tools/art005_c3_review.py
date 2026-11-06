# ART-005 C3 review panels (non-production): C2 (control) | C3 roof-value variant.
# Writes art/style_tests/ART-005/pl/g7/c3/review/.
# Frames: all rendered in ONE session in the clean export builds/review/ART-005/p1_export/ (the C1 export plus
# pl/g7/c2/32/ and pl/g7/c3/32/ copied in; no VIS-002 working-tree change), under its builds/review/ART-005/c3/:
#   tools/art005_density.gd density=32 task=stills art=g7 var=c2 | var=c3, hour=12 and 21.5,
#     res=1920x1080 framing=int and res=1280x720 framing=today
#   x/: tools/art003_wide.gd mode=wide layout=b grass=1 art=f2 size=1924x1080 at=45,10 house=g7:c2 | g7:c3,
#     hour=12 and 21.5 (R3-1 night)
#   python tools/art005_c3_review.py
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
C3 = os.path.join(m0.ROOT, "pl", "g7", "c3")
REV = os.path.join(C3, "review")
FR = os.path.join(HERE, "..", "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "c3")
TAGS = (("C2", "YC2"), ("C3", "YC3"))
NAMES = {"C2": "C2 (control, unchanged)", "C3": "C3 roof-value variant"}
SPR = {"C2": os.path.join(m0.ROOT, "pl", "g7", "c2", "32", "house_%s.png"),
       "C3": os.path.join(C3, "32", "house_%s.png")}
pr.REV = REV


def frame(tag, hr, fr):
    if fr == "int":
        return r2.load(os.path.join(FR, "%s32_%s_int_1080p.png" % (tag, hr))).crop((680, 0, 1500, 800))
    return r2.load(os.path.join(FR, "%s32_%s_today_720p.png" % (tag, hr))).crop((416, 0, 1056, 600))


def spr(v, scale=1, box=None):
    return r2.sprite_on(SPR[v] % "day", scale, box)


def harness():
    for fr, name, label in (("int", "c3_harness_1080p.png", "1080p, integer framing (2x), 1:1 crops"),
                            ("today", "c3_gamescale_720p.png", "actual 720p gameplay scale (tile = 48 px), 1:1 crops")):
        cells = []
        for hr, hl in (("day", "noon 12:00"), ("night", "harness night 21:30")):
            for k, t in TAGS:
                cells.append(("%s - %s" % (NAMES[k], hl), frame(t, hr, fr)))
        pr.grid(name, "ART-005 C3: C2 | C3 - " + label,
                "tools/art005_density.gd density=32, the same scene, camera and lights, both rendered in one session in "
                "a clean export. Only the roof's face and catch-light values differ; no line, joint or shape moved. "
                "Night = the ART-005 harness night, NOT R3-1. Trees, ground and props are the old placeholder harness art.",
                cells, 2)


def closeups():
    cells = []
    for lab, b in (("roof west + verge", (0, 40, 128, 162)), ("roof centre", (128, 40, 256, 162)),
                   ("roof east + chimney", (256, 14, 384, 162))):
        for k, _ in TAGS:
            cells.append(("%s  %s, 3x" % (k, lab), spr(k, 3, b)))
    for k, _ in TAGS:
        cells.append(("%s  whole roof + eave, 1:1" % k, spr(k, 1, (0, 14, 384, 172))))
    pr.grid("c3_details.png", "ART-005 C3: roof crops at 3x and the whole roof at 1:1, C2 | C3 (sprites, day)",
            "The roof is identical on the day and night sprites. Judge: does the lit upper plane read as a plane, "
            "do the catch-lights read as daylight on butts, does the ridge course separate, is anything noisier.",
            cells, 2)


def farm():
    v = lambda n: r2.load(os.path.join(FR, "x", n)).crop((0, 0, 1480, 1061))
    for t, lab, nm in (("day", "noon 12:00", "c3_farm_day.png"), ("night", r2.NIGHT_R31, "c3_farm_night.png")):
        pr.grid(nm, "ART-005 C3 homestead north (ART-003 W-4 + F2): house, golden oak, well, path - " + lab,
                "tools/art003_wide.gd mode=wide layout=b grass=1 art=f2, house=g7:c2 | g7:c3, rendered in one session. "
                "Cabin at half scale (1 art px = 1.5 screen px). Only the house roof differs; falling leaves and grass "
                "vary between runs. " +
                ("Night = R3-1, the ART-003 prototype night (not the ART-005 harness night)." if t == "night" else ""),
                [(NAMES[k], v("%s_n_%s.png" % (k.lower(), t))) for k in ("C2", "C3")], 2)


def roof_delta(a, b, box):
    """Mean roof luma difference between two rendered frames inside box (game-scale evidence, not opinion)."""
    A = np.asarray(a.crop(box).convert("L"), float)
    B = np.asarray(b.crop(box).convert("L"), float)
    return round(float(B.mean() - A.mean()), 1), round(float(np.abs(B - A).mean()), 2), round(float(A.std()), 1), \
        round(float(B.std()), 1)


def changes():
    m = json.load(open(os.path.join(C3, "measure.json")))
    a, b = m["c2_roof"], m["c3_roof"]
    sh = m["shakes"]
    rows = [
        "C3 - ZERO GENERATIONS (tools/art005_c3.py -> pl/g7/c3/measure.json). No PixelLab, SpriteCook or AI call.",
        "Sources (C2 day/night, C1, C1 masks, S3, P1) sha256-checked before and after: unchanged.",
        "",
        "METHOD - NOTHING REDRAWN: C2's shake layout is recomputed from its seed; each shake's face and catch-light",
        "  pixels move by ONE whole-shake ramp step from a broad hand-authored plane field. Joints, shadow and cast",
        "  lines (ramp steps 0-2), moss, chimney, ridge, fascia, eave, verges, walls, corners: C2's exactly (asserted).",
        "  %d px changed: %d lifted, %d deepened, %d catch-light px one step brighter." % (
            m["pixels_changed"], m["pixels_lifted"], m["pixels_deepened"], m["catchlight_pixels"]),
        "  Shakes: %d lifted, %d deepened, %d kept (deepening is blocked where C2's face is already at the ramp" % (
            sh["shakes_lifted"], sh["shakes_deepened"], sh["shakes_kept"]),
        "  floor or would merge a joint into its face). New colours: %d (one lighter silver step)." % len(
            m["new_colours_vs_c2_roof"]),
        "",
        "ROOF FIELD MEASURES (sprite)                      C2        C3",
        "luma mean / SD                                %5.1f/%4.1f  %5.1f/%4.1f" % (a["luma_mean"], a["luma_sd"],
                                                                                   b["luma_mean"], b["luma_sd"]),
        "upper plane (courses 2-4) luma                   %5.1f     %5.1f" % (a["upper_plane_luma"], b["upper_plane_luma"]),
        "lower plane (courses 7-10) luma                  %5.1f     %5.1f" % (a["lower_plane_luma"], b["lower_plane_luma"]),
        "upper minus lower plane                          %5.1f     %5.1f" % (a["upper_minus_lower"], b["upper_minus_lower"]),
        "upper plane minus ridge course                   %5.1f     %5.1f" % (a["upper_minus_ridge"], b["upper_minus_ridge"]),
        "broad mass contrast (SD of 24x18 block means)    %5.2f     %5.2f" % (a["mass_sd"], b["mass_sd"]),
        "pixel noise (mean neighbour step)                %5.2f     %5.2f" % (a["pixel_noise"], b["pixel_noise"]),
        "luma 5th / 95th percentile                   %5.1f/%4.1f  %5.1f/%4.1f" % (a["luma_p05"], a["luma_p95"],
                                                                                   b["luma_p05"], b["luma_p95"]),
        "wall minus roof (wall median %.0f)              %5.1f     %5.1f" % (m["wall_luma_median"], a["wall_minus_roof"],
                                                                            b["wall_minus_roof"]),
    ]
    g = m.get("gamescale")
    if g:
        rows += ["", "RENDERED ROOF, C3 minus C2 (mean luma shift / mean abs pixel change / roof SD C2 -> C3)"]
        rows += ["  %-34s %+5.1f   %5.2f   %4.1f -> %4.1f" % ((k,) + tuple(v)) for k, v in g.items()]
    im = Image.new("RGB", (1180, 30 + 20 * len(rows)), r2.BG)
    d = ImageDraw.Draw(im)
    for i, t in enumerate(rows):
        d.text((16, 14 + 20 * i), t, font=r2.FS, fill=r2.FG if t[:4].isupper() else r2.DIM)
    im.save(os.path.join(REV, "c3_receipt.png"))
    ch = r2.load(os.path.join(C3, "changed.png")).crop((0, 40, 384, 160)).resize((768, 240), Image.NEAREST)
    lay = r2.load(os.path.join(C3, "plan.png")).crop((0, 40, 384, 160)).resize((768, 240), Image.NEAREST)
    pr.grid("c3_changes.png", "ART-005 C3: exactly what changed (roof rows 40-160, 2x)",
            "Top: changed pixels (orange = face lifted one step, blue = face deepened one step, white = catch-light one "
            "step brighter, black = C2 untouched). Bottom: the per-shake shift plan (warm = +1, grey = 0, blue = -1).",
            [("changed pixels", ch), ("per-shake value shift", lay)], 1)


def gamescale():
    """Measure the roof's rendered change in every compared frame and store it in measure.json."""
    p = os.path.join(C3, "measure.json")
    m = json.load(open(p))
    g = {}
    for hr in ("day", "night"):
        for fr, box in (("int", (40, 160, 776, 324)), ("today", (44, 75, 596, 198))):
            a, b = frame("YC2", hr, fr), frame("YC3", hr, fr)
            g["harness %s %s" % (hr, "1080p" if fr == "int" else "720p")] = roof_delta(a, b, box)
    m["gamescale"] = g
    json.dump(m, open(p, "w"), indent=1, default=str)


def main():
    os.makedirs(REV, exist_ok=True)
    gi = os.path.join(REV, ".gdignore")
    if not os.path.exists(gi):
        open(gi, "w").close()
    if "--boxes" in sys.argv:          # helper: save the crops with the measured roof boxes outlined, to check them
        for fr, box in (("int", (40, 160, 776, 324)), ("today", (44, 75, 596, 198))):
            im = frame("YC2", "day", fr).convert("RGB")
            ImageDraw.Draw(im).rectangle(box, outline=(255, 0, 0))
            im.save(os.path.join(os.environ.get("TEMP", "."), "c3_box_%s.png" % fr))
        return
    gamescale()
    harness()
    closeups()
    farm()
    changes()


if __name__ == "__main__":
    main()
