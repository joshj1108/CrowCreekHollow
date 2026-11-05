# ART-005 S1 review panels (non-production). Reads the harness frames in builds/review/ART-005/s1/
# (tools/art005_density.gd density=32 art=g2 | g3 | g4 var=sa | g4 var=sb, hour=12 and 21.5, framing=int at 1080p
# and framing=today at 720p) and the four 384 x 320 sprites, and writes to art/style_tests/ART-005/pl/g4/review/:
#   s1_harness_1080p.png   M0 | H1 | SA | SB, day row and night row, 1:1 crops of the integer-scaled 1080p frame
#   s1_gamescale_720p.png  the same at the game's own 720p zoom (tile = 48 px), 1:1
#   s1_silhouette.png      the four sprites 1:1 and 2x, their silhouettes, and the measured roof share
#   s1_metrics.json        the measurements printed on the silhouette panel
#   python tools/art005_s1_review.py
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

ROOT = m0.ROOT
REV = os.path.join(ROOT, "pl", "g4", "review")
FR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "builds", "review", "ART-005", "s1")
BG = (28, 30, 34)
FG = (232, 232, 228)
DIM = (170, 172, 176)
F = ImageFont.load_default(size=16)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=22)
COLS = [("G", "M0  blockout mockup (hipped)"), ("H", "H1  PixelLab Pro edit (hipped)"),
        ("SSA", "SA  side gable, low roof (mockup)"), ("SSB", "SB  side gable + front gable (mockup)")]
SPR = {"G": ("g2", "32"), "H": ("g3", "32"), "SSA": ("g4", "sa/32"), "SSB": ("g4", "sb/32")}


def load(p):
    return Image.open(p).convert("RGBA")


def sheet(name, frame_fmt, box, title, note):
    w, h = box[2] - box[0], box[3] - box[1]
    gap, pad, head, cap = 12, 16, 70, 26
    out = Image.new("RGBA", (pad * 2 + 4 * w + 3 * gap, head + 2 * (cap + h) + gap + pad), BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((pad, 12), title, font=FB, fill=FG)
    d.text((pad, 42), note, font=FS, fill=DIM)
    for r, hr in enumerate(("day", "night")):
        y = head + r * (cap + h + gap)
        for c, (t, lab) in enumerate(COLS):
            x = pad + c * (w + gap)
            d.text((x, y + 4), "%s  -  %s" % (lab, "day 12:00" if hr == "day" else "night 21:30"), font=F, fill=FG)
            out.alpha_composite(load(os.path.join(FR, frame_fmt % (t, hr))).crop(box), (x, y + cap))
    out.convert("RGB").save(os.path.join(REV, name))
    print(name, out.size)


def silhouette():
    sprites = {t: load(os.path.join(ROOT, "pl", SPR[t][0], SPR[t][1], "house_day.png")) for t, _ in COLS}
    metrics = {}
    lab0 = m0.build_labels()
    m0_roof = np.isin(lab0, [m0.LID[n] for n in ("roof_lhip", "roof_front", "roof_rhip", "ridge_cap", "hip_line",
                                                   "chimney_shadow")])
    for t, _ in COLS:
        a = np.array(sprites[t])[..., 3] > 0
        rows = np.nonzero(a.any(1))[0]
        roof = a[:160].sum()   # everything above the eave line y 160 (roof, ridge, chimney, gable)
        if t in ("G", "H"):
            covering = m0_roof & a
        else:
            rl = np.array(Image.open(os.path.join(ROOT, "pl", "g4", SPR[t][1].split("/")[0], "labels_roof.png")))
            covering = np.isin(rl, [1, 2, 8, 9, 10, 16]) & a   # slate, ridge, chimney shadow, gable slopes, far slope
        metrics[t] = {"roof_covering_px": int(covering.sum()), "roof_covering_share": round(covering.sum() / a.sum(), 3),
                      "opaque_px": int(a.sum()), "above_eave_px": int(roof), "roof_share": round(roof / a.sum(), 3),
                      "top_y": int(rows.min()), "roof_height_px": int(160 - rows.min()),
                      "roof_to_wall_height": round((160 - rows.min()) / 138.0, 2)}
    gap, pad, head = 16, 16, 64
    cw = 384 * 2
    out = Image.new("RGBA", (pad * 2 + 4 * cw + 3 * gap, head + 26 + 320 * 2 + 12 + 320 + 120), BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((pad, 12), "ART-005 S1: farmhouse silhouette and roof share (sprites 2x, then 1:1 and silhouette)",
           font=FB, fill=FG)
    d.text((pad, 40), "Same 384 x 320 canvas, same facade pixels (y >= 160 copied from M0), same window and door "
           "centres, same footprint. Only the roof differs. Grey line = eave y 160; red = footprint top y 74.",
           font=FS, fill=DIM)
    for c, (t, lab) in enumerate(COLS):
        x = pad + c * (cw + gap)
        d.text((x, head + 2), lab, font=F, fill=FG)
        y = head + 26
        bg = Image.new("RGBA", (384, 320), (62, 78, 52, 255))
        bg.alpha_composite(sprites[t])
        out.alpha_composite(bg.resize((cw, 640), Image.NEAREST), (x, y))
        y2 = y + 652
        out.alpha_composite(bg, (x, y2))
        a = np.array(sprites[t])[..., 3] > 0
        sil = np.zeros((320, 384, 4), np.uint8)
        sil[..., :3] = 62, 78, 52
        sil[..., 3] = 255
        sil[a & (np.arange(320)[:, None] < 160)] = (150, 160, 175, 255)
        sil[a & (np.arange(320)[:, None] >= 160)] = (120, 96, 70, 255)
        si = Image.fromarray(sil, "RGBA")
        sd = ImageDraw.Draw(si)
        sd.line([(0, 160), (383, 160)], fill=(200, 200, 200, 255))
        sd.line([(0, 74), (383, 74)], fill=(220, 70, 60, 255))
        out.alpha_composite(si, (x + 384, y2))
        mt = metrics[t]
        d.text((x, y2 + 330), "roofing (slate) share of the silhouette: %d%%  (%d of %d px)"
               % (round(mt["roof_covering_share"] * 100), mt["roof_covering_px"], mt["opaque_px"]), font=F, fill=FG)
        d.text((x, y2 + 396), "everything above the eave (roof, chimney, gable face): %d%%"
               % round(mt["roof_share"] * 100), font=FS, fill=DIM)
        d.text((x, y2 + 352), "roof height %d px over a 138 px wall  (roof : wall %.2f)"
               % (mt["roof_height_px"], mt["roof_to_wall_height"]), font=F, fill=FG)
        d.text((x, y2 + 374), "[Measured] from the sprite's alpha and its label map", font=FS, fill=DIM)
    out.convert("RGB").save(os.path.join(REV, "s1_silhouette.png"))
    with open(os.path.join(REV, "s1_metrics.json"), "w") as f:
        json.dump(metrics, f, indent=1)
    print("s1_silhouette.png", out.size, json.dumps(metrics))


def main():
    os.makedirs(REV, exist_ok=True)
    sheet("s1_harness_1080p.png", "%s32_%s_int_1080p.png", (680, 0, 1500, 800),
          "ART-005 S1: M0 | H1 | SA | SB at 1080p (integer framing, 2x), day and night - 1:1 crops",
          "Harness tools/art005_density.gd density=32; same scene, camera, lights and window light positions in "
          "every column. SA/SB are zero-generation mockups; facade pixels identical to M0.")
    sheet("s1_gamescale_720p.png", "%s32_%s_today_720p.png", (416, 0, 1056, 600),
          "ART-005 S1: M0 | H1 | SA | SB at the game's own 720p zoom (tile = 48 px), day and night - 1:1 crops",
          "framing=today: the world drawn at today's zoom, as the player sees it. At this zoom the camera cuts the "
          "top of M0/H1's taller roof (as in the H1 package); SA/SB fit.")
    silhouette()


if __name__ == "__main__":
    main()
