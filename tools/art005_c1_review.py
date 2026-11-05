# ART-005 C1 review panels (non-production): S3 | P1 | C1 composite. Writes art/style_tests/ART-005/pl/g7/c1/review/.
# Frames: all rendered in ONE session in the clean git-archive export builds/review/ART-005/p1_export/ (HEAD's tools
# and art, plus pl/g7/c1/32/; no VIS-002 working-tree change), under its builds/review/ART-005/c1/:
#   tools/art005_density.gd density=32 task=stills art=g6 var=shake | art=g7 var=p1 | art=g7 var=c1,
#     hour=12 and 21.5, res=1920x1080 framing=int and res=1280x720 framing=today
#   x/: tools/art003_wide.gd mode=wide layout=b grass=1 art=f2 size=1924x1080 at=45,10 house=g6:shake|g7:p1|g7:c1,
#     hour=12 and 21.5 (R3-1 night)
#   python tools/art005_c1_review.py
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
C1 = os.path.join(m0.ROOT, "pl", "g7", "c1")
REV = os.path.join(C1, "review")
FR = os.path.join(HERE, "..", "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "c1")
TAGS = (("S3", "XSHAKE"), ("P1", "YP1"), ("C1", "YC1"))
NAMES = {"S3": "S3 roof A (original)", "P1": "P1 PixelLab edit (complete)", "C1": "C1 composite (proposed)"}
SPR = {"S3": os.path.join(m0.ROOT, "pl", "g6", "shake", "32", "house_%s.png"),
       "P1": os.path.join(m0.ROOT, "pl", "g7", "p1", "32", "house_%s.png"),
       "C1": os.path.join(C1, "32", "house_%s.png")}
pr.REV = REV


def frame(tag, hr, fr):
    if fr == "int":
        return r2.load(os.path.join(FR, "%s32_%s_int_1080p.png" % (tag, hr))).crop((680, 0, 1500, 800))
    return r2.load(os.path.join(FR, "%s32_%s_today_720p.png" % (tag, hr))).crop((416, 0, 1056, 600))


def spr(v, scale=1, box=None, night=False):
    return r2.sprite_on(SPR[v] % ("night" if night else "day"), scale, box)


def harness():
    for fr, name, label in (("int", "c1_harness_1080p.png", "1080p, integer framing (2x), 1:1 crops"),
                            ("today", "c1_gamescale_720p.png", "actual 720p gameplay scale (tile = 48 px), 1:1 crops")):
        cells = []
        for hr, hl in (("day", "noon 12:00"), ("night", "harness night 21:30")):
            for k, t in TAGS:
                cells.append(("%s - %s" % (NAMES[k], hl), frame(t, hr, fr)))
        pr.grid(name, "ART-005 C1: S3 | P1 | S3/P1 composite - " + label,
                "tools/art005_density.gd density=32, the same scene, camera and lights, all three rendered in one session "
                "in a clean export. C1 = S3 roof, fascia, eave shadow, chimney, hewn corners, foundation and steps + P1 "
                "log wall, window frames, door and lamp with a per-colour palette fix (less orange, softer dark grain, "
                "lower highlights); night glass re-fitted to P1's frames. Night = the ART-005 harness night, NOT R3-1. "
                "The trees, ground and props are the old placeholder harness art.", cells, 3)


DETAILS = [("eave + wall top (W)", (0, 128, 150, 200), 3), ("west corner", (0, 156, 60, 300), 3),
           ("east corner", (324, 156, 384, 300), 3), ("west window, day", (66, 196, 128, 256), 3),
           ("west window, night sprite", (66, 196, 128, 256), 3), ("door + lamp", (156, 210, 244, 300), 3),
           ("foundation + steps", (110, 270, 270, 320), 2), ("chimney", (280, 14, 340, 76), 3)]


def closeups():
    cells = []
    for lab, b, sc in DETAILS:
        for k, _ in TAGS:
            cells.append(("%s  %s, %dx" % (k, lab, sc), spr(k, sc, b, night="night" in lab)))
    pr.grid("c1_details.png", "ART-005 C1: details S3 | P1 | C1 (sprites, 2-3x)",
            "Seams to inspect: the eave shadow over the P1 wall (row 160), the S3 timber ends against the P1 logs, the "
            "door down into the S3 foundation (rows 281-297), and the night glass under P1's frames and mullions. "
            "The P1 night glass is S3's pasted on (P1 package); C1's is fitted to P1's own panes.", cells, 6)
    one = Image.new("RGBA", (3 * 392, 320), r2.BG + (255,))
    for i, (k, _) in enumerate(TAGS):
        one.alpha_composite(spr(k), (i * 392, 0))
    big = Image.new("RGBA", (3 * 392 * 2, 640), r2.BG + (255,))
    for i, (k, _) in enumerate(TAGS):
        big.alpha_composite(spr(k, 2), (i * 784, 0))
    pr.grid("c1_sprites.png", "ART-005 C1: whole sprites S3 | P1 | C1, 1:1 and 2x (day)",
            "1:1 is the sprite's own size (32 art px per tile mockup density; the game would show it at 1.5 screen px "
            "per art px at 720p).", [("1:1  S3 | P1 | C1", one), ("2x  S3 | P1 | C1", big)], 1)


def overlay():
    lines_y = [42, 56, 148, 155, 160, 202, 208, 241, 247, 218, 224, 280, 298, 309, 20]
    lines_x = [74, 80, 113, 119, 264, 270, 303, 309, 167, 173, 211, 217, 164, 220, 291, 329]
    cells = []
    for k in ("S3", "C1"):
        a = np.array(spr(k, 2))
        for y in lines_y:
            a[2 * y, :, :3] = (0, 230, 230)
        for x in lines_x:
            a[:, 2 * x, :3] = (230, 0, 230)
        cells.append(("%s on S3's anchor lines (2x)" % k, Image.fromarray(a, "RGBA")))
    mk = r2.load(os.path.join(C1, "masks.png")).resize((768, 640), Image.NEAREST)
    cells.append(("C1 source map: dark grey S3, light grey S3 timbers, orange P1 (remapped), blue night glass", mk))
    pal = r2.load(os.path.join(C1, "palette.png"))
    pal = pal.resize((pal.width * 2, pal.height * 2), Image.NEAREST)
    cells.append(("the palette fix: each P1 colour used (left) -> C1 (right), by luma", pal))
    pr.grid("c1_overlay.png", "ART-005 C1: geometry overlay, source map and palette fix",
            "Cyan rows: ridge 42, ridge-board shadow 56, fascia top 148, eave shadow 155, wall top 160, window frame "
            "202/247, glass 208/241, door trim 218, opening 224, foundation 280, wall base 298, step split 309, "
            "chimney top 20. Magenta columns: window frames and glass, door trim and opening, steps, chimney sides. "
            "C1's roof, fascia, chimney, corners, foundation and steps are S3's pixels; the wall, windows and door are "
            "P1's (P1 measured within 0-1 px of these anchors). Silhouette = S3's exactly.", cells, 2)


def farm():
    v = lambda n: r2.load(os.path.join(FR, "x", n)).crop((0, 0, 1480, 1061))
    for t, lab, nm in (("day", "noon 12:00", "c1_farm_day.png"), ("night", r2.NIGHT_R31, "c1_farm_night.png")):
        pr.grid(nm, "ART-005 C1 homestead north (ART-003 W-4 + F2): house, golden oak, well, path - " + lab,
                "tools/art003_wide.gd mode=wide layout=b grass=1 art=f2, house=g6:shake | g7:p1 | g7:c1, rendered in "
                "one session. Cabin at half scale (1 art px = 1.5 screen px). Only the house differs; the oak, well, "
                "ground and trees are the older ART-003 prototype art. " +
                ("Night = R3-1, the ART-003 prototype night (not the ART-005 harness night)." if t == "night" else ""),
                [("%s" % NAMES[k], v("%s_n_%s.png" % (p, t))) for k, p in (("S3", "sh"), ("P1", "p1"), ("C1", "c1"))], 2)


def receipt():
    m = json.load(open(os.path.join(C1, "measure.json")))
    s, p, c = m["s3"], m["p1"], m["c1"]
    f = lambda r, k: r["wall_colour"][k]
    rows = [
        "C1 COMPOSITE - ZERO GENERATIONS (tools/art005_c1.py -> pl/g7/c1/measure.json)",
        "Operations: masks, pixel copies and one per-colour palette remap. No PixelLab, SpriteCook or other AI call.",
        "Originals (S3 day/night, P1 day/night, P1 raw edit) sha256-checked before and after: unchanged = %s" % m["originals_unchanged"],
        "",
        "MASKS: S3 %d px (roof, fascia, eave shadow 155-159, chimney, %d px of hewn timbers, foundation, steps);" % (
            m["masks"]["s3_px"], m["masks"]["corner_px"]),
        "P1 %d px (rows 160-280 between the timbers, and the door down to row 297); night glass %d px (S3 had %d;" % (
            m["masks"]["p1_px"], m["masks"]["night_glass_px"], m["masks"]["s3_night_glass_px"]),
        "%d S3 glass px are P1 frame/mullion and stay unlit; none lit outside S3's pane boxes)." % (
            m["masks"]["s3_glass_px_kept_as_p1_frame"]),
        "PALETTE FIX on the %d P1 colours used: wood hues 0.069 -> 0.083, saturation x0.80; luma <= 24 kept (outlines," % (
            m["palette"]["p1_colours_remapped"]),
        "log seams); the 24-90 grain band lifted by up to 12 (largest at 57); luma above 130 compressed x0.75.",
        "",
        "WALL (clear panels)                          S3              P1              C1",
        "mean RGB                          %-16s%-16s%s" % (f(s, "mean_rgb"), f(p, "mean_rgb"), f(c, "mean_rgb")),
        "saturation mean / hue median      %.3f / %.3f   %.3f / %.3f   %.3f / %.3f" % (
            f(s, "sat_mean"), f(s, "hue_median"), f(p, "sat_mean"), f(p, "hue_median"), f(c, "sat_mean"), f(c, "hue_median")),
        "luma p5 / p50 / p95               %-16s%-16s%s" % (f(s, "luma_p5_p50_p95"), f(p, "luma_p5_p50_p95"), f(c, "luma_p5_p50_p95")),
        "luma mean / SD                    %5.1f / %4.1f    %5.1f / %4.1f    %5.1f / %4.1f" % (
            s["wall"]["mean_luma"], s["wall"]["luma_sd"], p["wall"]["mean_luma"], p["wall"]["luma_sd"],
            c["wall"]["mean_luma"], c["wall"]["luma_sd"]),
        "log course period px (strength)   %d (%.2f)         %d (%.2f)         %d (%.2f)" % (
            s["wall"]["log_period"]["px"], s["wall"]["log_period"]["strength"], p["wall"]["log_period"]["px"],
            p["wall"]["log_period"]["strength"], c["wall"]["log_period"]["px"], c["wall"]["log_period"]["strength"]),
        "wall noise                        %5.2f           %5.2f           %5.2f" % (s["wall"]["noise"], p["wall"]["noise"], c["wall"]["noise"]),
        "ROOF luma SD / pale specks        %4.1f / %d        %4.1f / %d       %4.1f / %d" % (
            s["roof"]["luma_sd"], s["roof"]["pale_specks_px"], p["roof"]["luma_sd"], p["roof"]["pale_specks_px"],
            c["roof"]["luma_sd"], c["roof"]["pale_specks_px"]),
        "eave shadow rows 155-159 luma     %5.1f           %5.1f           %5.1f" % (
            s["eave_shadow_155_160_luma"], p["eave_shadow_155_160_luma"], c["eave_shadow_155_160_luma"]),
        "colours (whole sprite)            %d              %d              %d" % (
            s["format"]["colours"], p["format"]["colours"], c["format"]["colours"]),
        "silhouette vs S3                  IoU %.4f      IoU %.4f      IoU %.4f" % (
            s["silhouette"]["iou"], p["silhouette"]["iou"], c["silhouette"]["iou"]),
        "glass W / E                       %s %s" % (s["glass_bbox"]["west"], s["glass_bbox"]["east"]),
        "                                  P1 %s %s   C1 %s %s" % (p["glass_bbox"]["west"], p["glass_bbox"]["east"],
                                                                 c["glass_bbox"]["west"], c["glass_bbox"]["east"]),
        "",
        "Note: the matcher's +5 px on C1 window right edges and +8 'wall top' are the P1 false matches already explained",
        "in the P1 report (lighter frames; P1's deeper eave shadow runs to row ~167). Direct glass segmentation: 0-1 px.",
    ]
    im = Image.new("RGB", (1180, 30 + 20 * len(rows)), r2.BG)
    d = ImageDraw.Draw(im)
    for i, t in enumerate(rows):
        d.text((16, 14 + 20 * i), t, font=r2.FS, fill=r2.FG if t[:4].isupper() else r2.DIM)
    im.save(os.path.join(REV, "c1_receipt.png"))
    print("c1_receipt.png", im.size)


def main():
    os.makedirs(REV, exist_ok=True)
    for d in (REV, C1):
        gi = os.path.join(d, ".gdignore")
        if not os.path.exists(gi) and d == REV:
            open(gi, "w").close()
    harness()
    closeups()
    overlay()
    farm()
    receipt()


if __name__ == "__main__":
    main()
