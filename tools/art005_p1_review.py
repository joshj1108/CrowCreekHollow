# ART-005 P1 review panels (non-production). Reads the harness frames and the sprites, writes the panels to
# art/style_tests/ART-005/pl/g7/review/:
#   house frames  builds/review/ART-005/p1/ (tools/art005_density.gd density=32 art=g7 var=p1|raw, hour=12 and 21.5,
#                 framing=int at 1920x1080 and framing=today at 1280x720) and S3's builds/review/ART-005/s3/ (XSHAKE,
#                 the same command with art=g6 var=shake) for BEFORE
#   homestead     builds/review/ART-005/p1_export/builds/x/ (tools/art003_wide.gd mode=wide layout=b grass=1 art=f2
#                 size=1924x1080, house=g6:shake (sh_*) and house=g7:p1 (p1_*), at=45,10 (n) and 50,30 (s), hour=12
#                 and 21.5), rendered in one session in a git-archive export of HEAD plus the P1 tools and art, so no
#                 VIS-002 work is in them
#   python tools/art005_p1_review.py
import json
import os
import sys
import textwrap

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_h1 as h1  # noqa: E402
import art005_m0 as m0  # noqa: E402
import art005_s2_review as r2  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
G7 = os.path.join(m0.ROOT, "pl", "g7")
REV = os.path.join(G7, "review")
HFP = os.path.join(HERE, "..", "builds", "review", "ART-005", "p1")
HFS = os.path.join(HERE, "..", "builds", "review", "ART-005", "s3")
FF = os.path.join(HERE, "..", "builds", "review", "ART-005", "p1_export", "builds", "x")
S3IN = os.path.join(m0.ROOT, "pl", "g6", "shake", "32")
NIGHT = r2.NIGHT
NIGHT_R31 = r2.NIGHT_R31
BG, FG, DIM = r2.BG, r2.FG, r2.DIM


def grid(name, title, note, cells, cols):
    """r2.grid with the note wrapped to the sheet width."""
    w = max(im.width for _, im in cells)
    h = max(im.height for _, im in cells)
    gap, pad, cap = 12, 16, 26
    width = pad * 2 + cols * w + (cols - 1) * gap
    lines = []
    for para in note.split("\n"):
        lines += textwrap.wrap(para, max(40, int((width - 2 * pad) / 7.2))) or [""]
    head = 48 + 18 * len(lines) + 8
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGBA", (width, head + rows * (cap + h + gap) + pad), BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((pad, 12), title, font=r2.FB, fill=FG)
    for i, ln in enumerate(lines):
        d.text((pad, 44 + 18 * i), ln, font=r2.FS, fill=DIM)
    for i, (c, im) in enumerate(cells):
        x = pad + (i % cols) * (w + gap)
        y = head + (i // cols) * (cap + h + gap)
        d.text((x, y + 4), c, font=r2.F, fill=FG)
        out.alpha_composite(im, (x, y + cap))
    out.convert("RGB").save(os.path.join(REV, name))
    print(name, out.size)


def hf(tag, hr, fr):
    base = HFP if tag.startswith("Y") else HFS
    if fr == "int":
        return r2.load(os.path.join(base, "%s32_%s_int_1080p.png" % (tag, hr))).crop((680, 0, 1500, 800))
    return r2.load(os.path.join(base, "%s32_%s_today_720p.png" % (tag, hr))).crop((416, 0, 1056, 600))


SPR = {"s3": os.path.join(S3IN, "house_%s.png"), "raw": os.path.join(G7, "raw", "32", "house_%s.png"),
       "p1": os.path.join(G7, "p1", "32", "house_%s.png")}


def spr(v, scale=1, box=None, night=False):
    return r2.sprite_on(SPR[v] % ("night" if night else "day"), scale, box)


def harness():
    for fr, name, label in (("int", "p1_harness_1080p.png", "1080p, integer framing (2x), 1:1 crops"),
                            ("today", "p1_gamescale_720p.png", "the game's own 720p zoom (tile = 48 px), 1:1 crops")):
        grid(name, "ART-005 P1: S3 roof A (input) | PixelLab Pro edit (P1) - " + label,
             "Harness tools/art005_density.gd density=32: the same scene, camera and lights. P1 = the raw edit with the "
             "input's alpha restored (0.17% of the house changed). The night glass is S3's, pasted on (scripted). "
             "Night = the ART-005 harness night (production NIGHT_TINT, lantern, window lights), NOT the ART-003 R3-1 "
             "prototype night. The trees, ground and props around the house are the old placeholder harness art, not "
             "part of this test.",
             [("BEFORE  S3 roof A - day 12:00", hf("XSHAKE", "day", fr)),
              ("AFTER  P1 PixelLab edit - day 12:00", hf("YP1", "day", fr)),
              ("BEFORE  S3 roof A - harness night 21:30", hf("XSHAKE", "night", fr)),
              ("AFTER  P1 - harness night 21:30", hf("YP1", "night", fr))], 2)


def sprites():
    raw = r2.load(SPR["raw"] % "day")
    p1 = r2.load(SPR["p1"] % "day")
    s3 = r2.load(SPR["s3"] % "day")
    a_in = np.array(s3)[..., 3] > 0
    ra = np.array(raw)[..., 3] > 0
    diff = (np.array(p1)[..., :3] != np.array(raw)[..., :3]).any(axis=2) & a_in
    m = np.zeros((320, 384, 4), np.uint8)
    m[...] = (40, 44, 50, 255)
    m[a_in] = (110, 110, 110, 255)
    m[diff] = (90, 170, 230, 255)
    m[ra & ~a_in] = (230, 80, 60, 255)
    dm = Image.fromarray(m, "RGBA")
    grid("p1_sprites.png", "ART-005 P1: input | raw PixelLab output | free adjustment, sprites 2x (day)",
         "Input: pl/g6/shake/32/house_day.png (S3 roof A, unchanged, hash-checked). Raw: pl/g7/p1/raw_edit.png exactly "
         "as downloaded (sha256 377eadb3...). Adjusted: the input's exact alpha (503 raw px outside it cut, 163 px "
         "inside it filled from the nearest raw pixel on the row). No palette snap, repaint or inpaint.\n"
         "Map: grey = the house, blue = px filled by the adjustment, red = raw px cut (the 1 px higher ridge row, "
         "chimney edges).",
         [("INPUT  S3 roof A", spr("s3", 2)), ("RAW  PixelLab edit, unchanged", spr("raw", 2)),
          ("ADJUSTED  input alpha restored", spr("p1", 2)),
          ("raw vs adjusted (blue filled, red cut)", dm.resize((768, 640), Image.NEAREST))], 2)


def closeups():
    rb = (0, 36, 200, 166)
    wb = (24, 156, 200, 300)
    grid("p1_roof_wall.png", "ART-005 P1: roof and log wall close-ups, S3 | P1, 1:1 and 3x (day sprites)",
         "Roof: west half, ridge board to wall top. Wall: west corner to the door. 1:1 is the sprite's own size (the "
         "game shows it at 1.5 screen px per art px at 720p).",
         [("S3 roof, 3x", spr("s3", 3, rb)), ("P1 roof, 3x", spr("p1", 3, rb)),
          ("S3 wall, 3x", spr("s3", 3, wb)), ("P1 wall, 3x", spr("p1", 3, wb))], 2)
    one = Image.new("RGBA", (600, 390), BG + (255,))
    for i, v in enumerate(("s3", "p1")):
        one.alpha_composite(spr(v, 1, rb), (0 + i * 210, 0))
        one.alpha_composite(spr(v, 1, wb), (0 + i * 210, 140))
    d = ImageDraw.Draw(one)
    d.text((0, 290), "left S3, right P1: roof (top) and wall (bottom) at 1:1", font=r2.FS, fill=DIM)
    grid("p1_roof_wall_1x.png", "ART-005 P1: roof and wall at 1:1", "Same crops at 1:1.", [("1:1", one.crop((0, 0, 420, 300)))], 1)


def details():
    boxes = [("west corner", (0, 156, 60, 300)), ("east corner", (324, 156, 384, 300)),
             ("west window", (66, 196, 128, 256)), ("door + lamp", (158, 212, 240, 300)),
             ("foundation + steps", (120, 272, 260, 320)), ("chimney", (280, 14, 340, 76))]
    cells = []
    for lab, b in boxes:
        sc = 3 if (b[2] - b[0]) <= 90 else 2
        cells.append(("S3  " + lab + ", %dx" % sc, spr("s3", sc, b)))
        cells.append(("P1  " + lab + ", %dx" % sc, spr("p1", sc, b)))
    cells.append(("S3  west window, night sprite 3x", spr("s3", 3, boxes[2][1], night=True)))
    cells.append(("P1  west window, night sprite 3x (S3 glass)", spr("p1", 3, boxes[2][1], night=True)))
    grid("p1_details.png", "ART-005 P1: details, S3 | P1 (day sprites)",
         "Corners, window, door, foundation and steps, chimney. The P1 night glass is S3's own night glass pasted on "
         "(1,828 px), not PixelLab's.", cells, 4)


def overlay():
    meas = json.load(open(os.path.join(G7, "p1", "measure.json")))
    p1 = np.array(spr("p1", 2))
    lines_y = [42, 56, 148, 155, 160, 202, 208, 241, 247, 218, 224, 280, 298, 309, 20]
    lines_x = [74, 80, 113, 119, 264, 270, 303, 309, 167, 173, 211, 217, 164, 220, 291, 329]
    for y in lines_y:
        p1[2 * y, :, :3] = (0, 230, 230)
    for x in lines_x:
        p1[:, 2 * x, :3] = (230, 0, 230)
    s3 = np.array(spr("s3", 2))
    for y in lines_y:
        s3[2 * y, :, :3] = (0, 230, 230)
    for x in lines_x:
        s3[:, 2 * x, :3] = (230, 0, 230)
    grid("p1_overlay.png", "ART-005 P1: geometry overlay - the S3 input's anchor lines on S3 and on P1 (sprites 2x)",
         "Cyan rows: ridge top 42, ridge-board shadow 56, fascia top 148, eave shadow 155, wall top 160, window frame "
         "202/247 and glass 208/241, door trim top 218 and opening 224, foundation top 280, wall base 298, step split "
         "309, chimney top 20. Magenta columns: window frames and glass, door trim and opening, steps, chimney sides.\n"
         "Measured on the RAW edit (direct dark-outline profiles + glass colour segmentation): every window, glass, "
         "door, step, foundation and chimney edge within 0-1 px. Roofline: ridge top 1 px higher over 315 of 384 "
         "columns (silhouette IoU %.4f). Ridge-board shadow line 56 -> 53 (3 px higher, the board is thinner). "
         "Fascia board (148-154) repainted as a row of hanging shake butts; eave shadow 155-159 kept." %
         meas["raw_edit"]["silhouette"]["iou"],
         [("S3 input with its anchors", Image.fromarray(s3, "RGBA")),
          ("P1 (adjusted) on the same anchors", Image.fromarray(p1, "RGBA"))], 2)


def receipt():
    meas = json.load(open(os.path.join(G7, "p1", "measure.json")))
    a, b = meas["input_s3_shake"], meas["raw_edit"]
    rows = [
        "GENERATION RECEIPT",
        "Tool: PixelLab edit_image (Pro), reference mode, 384 x 320, seed 5317, transparency following the input",
        "Job 0ceb4ff0-69be-461b-8575-787e6f135ff7  asset 2286075d-3e02-5fa9-8a54-e20e01dbe4c5  79 s",
        "Input: upload of pl/g6/shake/32/house_day.png (sha256 474073e4...)  reference: pl/g7/p1/ref_s3.png 64x64 "
        "(ART-003 PixelLab oak bark + boulders)",
        "Expected 25, cap 25, CHARGED 25: 4,913 -> 4,888 generations; credits USD 0.00 before and after",
        "One call. No retry, no reroll, no inpainting, no other seed, no SpriteCook call.",
        "",
        "MEASUREMENTS (tools/art005_p1.py -> pl/g7/p1/measure.json)          S3 input      P1 raw",
        "Roof mean luma / SD                                                   %5.1f / %4.1f   %5.1f / %4.1f" % (
            a["roof"]["mean_luma"], a["roof"]["luma_sd"], b["roof"]["mean_luma"], b["roof"]["luma_sd"]),
        "Roof pale speck px (> mean + 3 SD)                                      %5d          %5d" % (
            a["roof"]["pale_specks_px"], b["roof"]["pale_specks_px"]),
        "Roof course period px (strength)                                      %d (%.2f)      %d (%.2f)" % (
            a["roof"]["course_period"]["px"], a["roof"]["course_period"]["strength"],
            b["roof"]["course_period"]["px"], b["roof"]["course_period"]["strength"]),
        "Roof self-match within 8-64 px                                        %.2f @%d      %.2f @%d" % (
            a["roof"]["self_match"]["max"], a["roof"]["self_match"]["dx"],
            b["roof"]["self_match"]["max"], b["roof"]["self_match"]["dx"]),
        "Roof noise                                                            %5.2f          %5.2f" % (
            a["roof"]["noise"], b["roof"]["noise"]),
        "Wall mean luma / SD                                                   %5.1f / %4.1f   %5.1f / %4.1f" % (
            a["wall"]["mean_luma"], a["wall"]["luma_sd"], b["wall"]["mean_luma"], b["wall"]["luma_sd"]),
        "Wall log period px (strength)                                         %d (%.2f)     %d (%.2f)" % (
            a["wall"]["log_period"]["px"], a["wall"]["log_period"]["strength"],
            b["wall"]["log_period"]["px"], b["wall"]["log_period"]["strength"]),
        "Wall minus roof luma                                                  %5.1f          %5.1f" % (
            a["wall_minus_roof_luma"], b["wall_minus_roof_luma"]),
        "Colours / orphan %% / partial alpha                                    %d / %.2f / %d   %d / %.2f / %d" % (
            a["format"]["colours"], a["format"]["orphan_pct"], a["format"]["partial_alpha_px"],
            b["format"]["colours"], b["format"]["orphan_pct"], b["format"]["partial_alpha_px"]),
        "Silhouette vs input: +%d / -%d px, IoU %.4f; glass W %s E %s (input W %s E %s)" % (
            b["silhouette"]["px_added"], b["silhouette"]["px_removed"], b["silhouette"]["iou"],
            b["glass_bbox"]["west"], b["glass_bbox"]["east"], a["glass_bbox"]["west"], a["glass_bbox"]["east"]),
        "",
        "STOP RULE: TRIGGERED - the roof stays a grid of near-uniform rectangles (reads as bricks at 720p), with ~70 "
        "px of pale blotches;",
        "the fascia board became hanging shake butts. Not a convincing professional improvement of the roof. No "
        "further generation.",
        "",
        "FILES: pl/g7/p1/raw_edit.png (raw, read-only), ref_s3.png, p1_snap_day.png, p1_snap_night.png, measure.json,",
        "pl/g7/p1/32/house_day|night.png, pl/g7/raw/32/house_day|night.png, pl/g7/review/*; tools/art005_p1.py, "
        "tools/art005_p1_review.py;",
        "harness: tools/art005_density.gd art=g7, tools/art003_wide.gd house=g7:<var> (other modes unchanged).",
    ]
    im = Image.new("RGB", (1200, 30 + 20 * len(rows)), BG)
    d = ImageDraw.Draw(im)
    for i, t in enumerate(rows):
        d.text((16, 14 + 20 * i), t, font=r2.FS, fill=FG if t.isupper() or t.startswith("STOP") else DIM)
    im.save(os.path.join(REV, "p1_receipt.png"))
    print("p1_receipt.png", im.size)


def farm():
    v = lambda n: r2.load(os.path.join(FF, n))
    for half, t, desc in (("north", "n", "house, golden oak, well and crossroads"),
                          ("south", "s", "the four ground-level fields, walks, gates and road")):
        grid("p1_farm_%s.png" % half,
             "ART-005 P1 homestead, %s: %s (ART-003 W-4 layout + F2 fields, 3x)" % (half, desc),
             "tools/art003_wide.gd mode=wide layout=b grass=1 art=f2; BEFORE house=g6:shake, AFTER house=g7:p1, both "
             "rendered in the same session. The cabin is drawn at half scale (1 art px = 1.5 screen px). Only the house "
             "is new: the oak, well, fields, trees and ground are the older ART-003 prototype art. Night = R3-1, the "
             "ART-003 prototype night (NOT the ART-005 harness night of the house sheets).",
             [("BEFORE  S3 roof A - day 12:00", v("sh_%s_day.png" % t)),
              ("AFTER  P1 - day 12:00", v("p1_%s_day.png" % t)),
              ("BEFORE  S3 roof A - " + NIGHT_R31, v("sh_%s_night.png" % t)),
              ("AFTER  P1 - " + NIGHT_R31, v("p1_%s_night.png" % t))], 2)


def main():
    os.makedirs(REV, exist_ok=True)
    gi = os.path.join(REV, ".gdignore")
    if not os.path.exists(gi):
        open(gi, "w").close()
    harness()
    sprites()
    closeups()
    details()
    overlay()
    receipt()
    farm()


if __name__ == "__main__":
    main()
