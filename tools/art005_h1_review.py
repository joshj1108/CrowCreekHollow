# ART-005 H1 review panels (non-production). Reads pl/g3/h1/ (tools/art005_h1.py), the M0 mockup (pl/g2/32/) and
# the harness frames in builds/review/ART-005/h1/ (tools/art005_density.gd art=g2|g3), and writes PNGs to
# pl/g3/review/: harness crops for review_sheet.ps1, the full-facade panel, 1:1 and 3x material crops, the
# architectural coordinate overlay, and the receipt + measurement panel.
#   python tools/art005_h1_review.py
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

ROOT = m0.ROOT
H1 = os.path.join(ROOT, "pl", "g3", "h1")
REV = os.path.join(ROOT, "pl", "g3", "review")
FR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "builds", "review", "ART-005", "h1")
BG = (28, 30, 34)
FG = (232, 232, 228)
DIM = (170, 172, 176)
F = ImageFont.load_default(size=15)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=20)


def load(p):
    return Image.open(p).convert("RGBA")


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def flat(im, col=(46, 52, 44, 255)):
    b = Image.new("RGBA", im.size, col)
    b.alpha_composite(im)
    return b


def panel(w, h):
    im = Image.new("RGBA", (w, h), BG + (255,))
    return im, ImageDraw.Draw(im)


M0 = load(os.path.join(m0.G2, "32", "house_day.png"))
VP = load(os.path.join(H1, "valuepass.png"))
RAW = load(os.path.join(H1, "raw_edit.png"))
SNAP = load(os.path.join(H1, "h1_snap_day.png"))
SNAPN = load(os.path.join(H1, "h1_snap_night.png"))
MS = json.load(open(os.path.join(H1, "measure.json")))
A = m0.A


def harness_crops():
    os.makedirs(os.path.join(REV, "frames"), exist_ok=True)
    for t in ("G", "H"):
        for h in ("day", "night"):
            im = load(os.path.join(FR, "%s32_%s_int_1080p.png" % (t, h)))
            im.crop((640, 0, 1536, 720)).save(os.path.join(REV, "frames", "%s_%s_1080p_crop.png" % (t, h)))


def facade():
    k = 2
    items = [("Value pass (input, free script)", VP), ("Raw edit (unchanged PixelLab output)", RAW),
             ("H1 adjusted: M0 alpha only", SNAP), ("M0 mockup (c1 materials, baseline)", M0)]
    cw, ch = 384 * k, 320 * k
    im, d = panel(32 + 2 * cw + 24, 70 + 2 * (ch + 40) + 330)
    d.text((16, 14), "ART-005 H1: full facade at 2x (art px x2, nearest). Same 384 x 320 canvas and origin.", font=FB, fill=FG)
    for i, (t, src) in enumerate(items):
        x = 16 + (i % 2) * (cw + 24)
        y = 60 + (i // 2) * (ch + 40)
        d.text((x, y), t, font=F, fill=FG)
        im.paste(up(flat(src), k), (x, y + 22))
    # difference map raw vs adjusted, at 1x, and what changed
    y = 60 + 2 * (ch + 40)
    ra, sa = np.array(RAW), np.array(SNAP)
    add = (ra[..., 3] > 0) & (sa[..., 3] == 0)
    fil = (ra[..., 3] == 0) & (sa[..., 3] > 0)
    dm = np.zeros((320, 384, 4), np.uint8)
    dm[..., 3] = 255
    dm[..., :3] = (np.array(flat(SNAP))[..., :3] * 0.35).astype(np.uint8)
    dm[add] = (255, 40, 200, 255)
    dm[fil] = (60, 230, 255, 255)
    d.text((16, y), "Raw vs adjusted (1x): magenta = raw pixels cut outside M0's silhouette, cyan = pixels filled inside it",
           font=F, fill=FG)
    im.paste(Image.fromarray(dm, "RGBA"), (16, y + 22))
    ad = MS["adjustment"]
    lines = ["Technical adjustment (free, the only one):",
             "M0's exact alpha replaces the raw alpha.",
             "cut outside M0 silhouette: %d px" % ad["alpha_snap_cut_px"],
             "  (a second foundation course the edit added",
             "   under the wall base, y 298-314, all columns)",
             "filled inside: %d px (%.2f%% of the house)," % (ad["alpha_snap_filled_px"], ad["pct_of_house"]),
             "  from the nearest raw pixel on the row.",
             "No palette snap, no repaint, no inpainting.",
             "Everything inside the silhouette is the raw edit.",
             "Raw file sha256/16: " + ad["raw_sha"]]
    for i, t in enumerate(lines):
        d.text((420, y + 26 + i * 20), t, font=FS, fill=FG if i == 0 else DIM)
    im.save(os.path.join(REV, "h1_facade.png"))


CROPS = [("Roof, front plane", (128, 44, 208, 124)), ("West hip + ridge end", (0, 12, 80, 92)),
         ("Timber siding (west of door)", (120, 164, 168, 222)), ("Door + lamp", (160, 214, 236, 298)),
         ("Window (west)", (66, 196, 128, 256)), ("Foundation + steps", (136, 272, 248, 320)),
         ("Chimney + base", (290, 0, 338, 60))]


def crops():
    k = 3
    rows = []
    for t, box in CROPS:
        a, b = flat(M0).crop(box), flat(SNAP).crop(box)
        rows.append((t, a, b))
    W1 = max(r[1].width for r in rows)
    H1r = [max(r[1].height * k, 60) for r in rows]
    w = 16 + 180 + 2 * (W1 + 12) + 2 * (W1 * k + 16)
    im, d = panel(w, 70 + sum(h + 28 for h in H1r))
    d.text((16, 14), "ART-005 H1: material crops. Left pair 1:1 (M0 | H1), right pair 3x (M0 | H1). H1 = raw edit, M0 alpha.",
           font=FB, fill=FG)
    y = 56
    for (t, a, b), hh in zip(rows, H1r):
        d.text((16, y + 6), t, font=F, fill=FG)
        x = 196
        for lbl, src, kk, ww in (("M0", a, 1, W1), ("H1", b, 1, W1), ("M0 3x", a, k, W1 * k), ("H1 3x", b, k, W1 * k)):
            d.text((x, y), lbl, font=FS, fill=DIM)
            im.paste(up(src, kk), (x, y + 18))
            x += ww + (12 if kk == 1 else 16)
        y += hh + 28
    im.save(os.path.join(REV, "h1_crops.png"))


def overlay():
    k = 3
    big = up(flat(SNAP), k)
    d = ImageDraw.Draw(big)
    cy, mg, yl, gr, rd, og = (0, 255, 255), (255, 0, 255), (255, 255, 0), (80, 255, 80), (255, 80, 80), (255, 170, 0)

    def R(x0, y0, x1, y1, c):
        d.rectangle([x0 * k, y0 * k, x1 * k - 1, y1 * k - 1], outline=c, width=1)

    R(A["door"]["x"][0], A["door"]["y"][0], A["door"]["x"][1], A["door"]["y"][1], cy)
    R(A["door"]["x"][0] - 6, A["door"]["y"][0] - 6, A["door"]["x"][1] + 6, A["door"]["y"][1], og)
    for w in A["windows"]:
        R(w["x"][0], w["y"][0], w["x"][1], w["y"][1], cy)
        R(w["x"][0] + 6, w["y"][0] + 6, w["x"][1] - 6, w["y"][1] - 6, mg)
    R(164, 298, 220, 309, yl)
    R(160, 309, 224, 320, yl)
    R(300, 6, 328, 52, cy)
    R(297, 0, 331, 6, og)
    for y, c in ((12, og), (20, og), (148, og), (160, rd), (280, gr), (298, gr)):
        d.line([0, y * k, big.width, y * k], fill=c)
    d.line([16 * k, 160 * k, 16 * k, 298 * k], fill=rd)
    d.line([368 * k, 160 * k, 368 * k, 298 * k], fill=rd)
    for x in range(0, 384, 32):
        d.line([x * k, 318 * k, x * k, 320 * k], fill=FG)
    tw = 600
    im, dd = panel(big.width + tw + 48, big.height + 80)
    dd.text((16, 14), "ART-005 H1: architectural coordinate overlay (H1 adjusted, 3x). Lines = M0 anchors.", font=FB, fill=FG)
    im.paste(big, (16, 56))
    x0 = big.width + 36
    leg = ["cyan: door opening, window frames, chimney body", "magenta: window glass (feeds the emissive layer)",
           "orange: door trim, ridge cap 12/20, fascia top 148, chimney cap", "red: eave line 160, wall x 16 / 368",
           "green: foundation top 280, wall base 298", "yellow: steps (two treads)", "",
           "Measured in the raw edit (art px, + = right/down):"]
    rows = [
        ("Silhouette below the eave", "IoU %.3f vs M0; +%d / -%d px" % (MS["raw_edit"]["silhouette"]["iou"],
                                                                  MS["raw_edit"]["silhouette"]["px_added"],
                                                                  MS["raw_edit"]["silhouette"]["px_removed"])),
        ("Wall base (outside steps)", "y %d (M0 298): +16, stones added" % MS["raw_edit"]["silhouette"]["wall_base_y_median"]),
        ("Wall west / east", "x %d / %d (M0 16 / 368)" % (MS["raw_edit"]["silhouette"]["wall_west_x_median"],
                                                          MS["raw_edit"]["silhouette"]["wall_east_x_median"])),
        ("Door opening", "x 173-210, top y 224 (M0 173-211, 224): 0 / -1"),
        ("Door trim", "x 167-216, top y 217-218 (M0 167-217, 218): <= 1"),
        ("Glass, west / east", "x 79-112 / 269-302, y 207-240: -1, -1"),
        ("Window frames", "on the M0 frame lines, +-1 (read on overlay)"),
        ("Steps", "upper tread ~x 165-218 (M0 164-220), split y 308-309"),
        ("", "upper tread partly drawn as foundation stone"),
        ("Eave line / fascia", "eave 160 (0); fascia board y 152-155,"),
        ("", "thinner than M0's 148-156, roof lip over it"),
        ("Ridge cap", "y 12-20 (0)"),
        ("Chimney", "x ~299-328, y 0-52 (<= 1); cap not separate"),
        ("Foundation top", "y 280 (0); second course added below"),
    ]
    for i, t in enumerate(leg):
        dd.text((x0, 60 + i * 20), t, font=FS, fill=FG if i == len(leg) - 1 else DIM)
    y = 60 + len(leg) * 20 + 6
    for a, b in rows:
        dd.text((x0, y), a, font=FS, fill=FG)
        dd.text((x0 + 200, y), b, font=FS, fill=DIM)
        y += 20
    note = ["Method: glass by colour segmentation (bounding box);", "door, trim, steps, eave, ridge and foundation read from",
            "luminance profiles along fixed rows/columns and this overlay.", "The automatic profile matcher passed a synthetic",
            "+3/+2 px shift test but gives low-confidence matches when", "shading differs (even on M0), so it is not used for",
            "the verdict; its numbers are in measure.json.", "",
            "Interior anchors were measured on the raw edit, not", "assumed fixed by the alpha snap."]
    for i, t in enumerate(note):
        dd.text((x0, y + 16 + i * 18), t, font=FS, fill=DIM)
    im.save(os.path.join(REV, "h1_overlay.png"))


def receipt():
    im, d = panel(1500, 900)
    d.text((16, 14), "ART-005 H1: generation receipt, parameters and measurements", font=FB, fill=FG)
    L = ["Operation: PixelLab edit_image (Pro), reference mode, ONE call. Job 7b583538-f90b-43d8-9ed0-bdb3dbefe71a,",
         "  asset 18d7ca65-b776-5c12-a147-e6c0e2e6110f, seed 4210, 384 x 320, transparent (follows input), 112 s.",
         "Inputs: image = valuepass.png (upload), reference = ref_v2.png (64 x 64: slate | timber / stone | window",
         "  from M1 anchor_v2). ref_c1.png made from c1 for the record, not used. Description = brief s2.2 draft.",
         "Expected cost: 25 generations (tool doc: >341 px band; help agent confirmed 384 x 320).",
         "Receipt: balance 4,938 -> 4,913 generations = 25. Credits USD 0.00 before and after. No purchase.",
         "Remaining: 4,913 of 5,000 this cycle (resets 2026-12-03). No second edit, no inpaint, no repair.", ""]
    for i, t in enumerate(L):
        d.text((16, 52 + i * 20), t, font=F, fill=FG if i in (0, 5) else DIM)
    y = 52 + len(L) * 20
    cols = ["", "value pass", "M0 mockup", "raw edit", "H1 adjusted"]
    keys = ["valuepass", "m0_mockup", "raw_edit", "h1_snap"]
    rows = [
        ("Silhouette IoU vs M0", lambda r: "%.3f" % r["silhouette"]["iou"]),
        ("Px added / removed", lambda r: "%d / %d" % (r["silhouette"]["px_added"], r["silhouette"]["px_removed"])),
        ("Wall base y (median)", lambda r: str(r["silhouette"]["wall_base_y_median"])),
        ("Roof course period (px, strength)", lambda r: "%d, %.2f" % (r["roof_course_period"]["px"], r["roof_course_period"]["strength"])),
        ("Wall lap period (px, strength)", lambda r: "%d, %.2f" % (r["wall_lap_period"]["px"], r["wall_lap_period"]["strength"])),
        ("Roof self-match (8-64 px shift)", lambda r: "%.2f @ dx %d" % (r["roof_repetition"]["max_self_match"], r["roof_repetition"]["at_dx"])),
        ("Wall self-match", lambda r: "%.2f @ dx %d" % (r["wall_repetition"]["max_self_match"], r["wall_repetition"]["at_dx"])),
        ("Noise roof / wall", lambda r: "%.1f / %.1f" % (r["noise_by_surface"]["roof"], r["noise_by_surface"]["wall"])),
        ("Noise found. / door+win", lambda r: "%.1f / %.1f" % (r["noise_by_surface"]["foundation"], r["noise_by_surface"]["door_windows"])),
        ("Mean lum roof / wall", lambda r: "%.0f / %.0f" % (r["mean_lum"]["roof"], r["mean_lum"]["wall"])),
        ("Lum under eave / mid wall", lambda r: "%.0f / %.0f" % (r["mean_lum"]["wall_top_160_166"], r["mean_lum"]["wall_mid_200_240_clear"])),
        ("Colours / orphans / partial a", lambda r: "%d / %.2f%% / %d" % (r["format"]["colours"], r["format"]["orphan_pct"], r["format"]["partial_alpha_px"])),
    ]
    cx = [16, 330, 520, 710, 900]
    for i, c in enumerate(cols):
        d.text((cx[i], y), c, font=F, fill=FG)
    y += 24
    for name, fn in rows:
        d.text((cx[0], y), name, font=FS, fill=FG)
        for i, k in enumerate(keys):
            d.text((cx[i + 1], y), fn(MS[k]), font=FS, fill=DIM)
        y += 20
    notes = ["Self-match: strongest normalised correlation of a 64 x 64 roof block (40 x 24 wall block) with itself shifted",
             "8-64 px sideways and +-24 px vertically. 1.0 = exact tiling. The value pass is 1.0 by design (flat planes and",
             "lines, no texture). Noise = mean |lum - 3x3 mean| per M0 region. 2x2 grid uniformity is 49-55% at all four",
             "offsets, so the edit is not a 2x upscale (it has 2 px clusters, as the brief asked)."]
    for i, t in enumerate(notes):
        d.text((16, y + 10 + i * 18), t, font=FS, fill=DIM)
    im = im.crop((0, 0, 1500, y + 10 + len(notes) * 18 + 16))
    im.save(os.path.join(REV, "h1_receipt_measure.png"))


if __name__ == "__main__":
    os.makedirs(REV, exist_ok=True)
    harness_crops()
    facade()
    crops()
    overlay()
    receipt()
    print("written", sorted(os.listdir(REV)))
