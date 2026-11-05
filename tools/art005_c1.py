# ART-005 C1 (non-production, zero generations): the S3/P1 farmhouse composite. Masks, a per-colour palette remap and
# copies only; no generative, paid or AI operation. The S3 and P1 sprites are read, hash-checked before and after,
# and never written.
#   python tools/art005_c1.py
# Reads:
#   pl/g6/shake/32/house_day|night.png   S3 roof A (roof, fascia, eave shadow, chimney, corners, foundation, steps)
#   pl/g6/logc/32/house_day.png and pl/g5/log/32/house_day.png   only to derive the exact S3 hewn-corner mask
#   pl/g7/p1/32/house_day.png            P1 (log wall courses, window frames, door, lamp)
# Writes (pl/g7/c1/, so the existing harness modes art=g7 var=c1 and house=g7:c1 draw it with no code change):
#   32/house_day.png, 32/house_night.png   the composite
#   32n/house_day.png, 32n/house_night.png the same composite with P1's colours un-remapped (the "no palette fix"
#                                           control, to show what the remap does)
#   masks.png       source map: grey S3, orange P1 remapped, blue night glass
#   palette.png     every P1 colour used, before -> after the remap
#   measure.json    the P1 measurements (tools/art005_p1.py) for S3, P1 and C1, plus seam and palette checks
import colorsys
import hashlib
import json
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402
import art005_p1 as p1  # noqa: E402

ROOT = m0.ROOT
S3D = os.path.join(ROOT, "pl", "g6", "shake", "32")
P1D = os.path.join(ROOT, "pl", "g7", "p1", "32")
OUT = os.path.join(ROOT, "pl", "g7", "c1")
W, H = 384, 320

# Regions (S3/P1 anchor rows, tools/art005_p1.py EDGES; door read off the luma profiles at row 250 and column 190).
WALL_TOP = 160          # first row under S3's eave shadow (155-159)
WALL_BOT = 281          # first S3 foundation row; the wall's bottom log shadow (276-280) stays P1
DOOR = (164, 223, 214, 298)   # x0, x1, y0, y1: door trim and leaf down to the top step (P1 down to the sill)
WINDOWS = ((70, 125), (259, 314))   # glass + frame zones (x), rows 196-252

# The palette remap (applied once to each P1 colour, so the colour count cannot grow).
HUE_TO = 0.083          # P1 wood median hue 0.069 (orange) -> S3's 0.087 side: a weathered, less orange brown
SAT_K = 0.80            # P1 wood saturation 0.55 -> about 0.44 (S3 0.46)
OUTLINE_L = 24          # luma at or below this is an outline or log seam: left as dark as it is
GRAIN_LIFT = 12.0       # the lift of the dark grain band (24-90 luma), largest at 57: softens the harsh streaks
HI_KNEE, HI_K = 130.0, 0.75   # highlights above 130 compressed by a quarter (P1 p95 164 vs S3 137)


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def rgba(p):
    return np.array(Image.open(p).convert("RGBA"))


def luma(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def remap_colour(c):
    """One P1 colour -> its corrected colour. Wood-range hues (orange/brown) are nudged and desaturated; the luma
    keeps outlines, lifts the dark grain band and compresses highlights. Cool glass colours keep their hue."""
    r, g, b = (v / 255.0 for v in c)
    h, s, v = colorsys.rgb_to_hsv(r, g, b)
    if h < 0.16 and s > 0.08:
        h = h + (HUE_TO - 0.069) * min(1.0, s / 0.3)
        s = s * SAT_K
    r, g, b = colorsys.hsv_to_rgb(h, s, v)
    rgb = np.array([r, g, b]) * 255.0
    L0 = luma(c)
    L1 = luma(rgb)
    if L0 <= OUTLINE_L:
        Lt = L0
    elif L0 < 90:
        Lt = L0 + GRAIN_LIFT * np.sin(np.pi * (L0 - OUTLINE_L) / (90 - OUTLINE_L))
    elif L0 > HI_KNEE:
        Lt = HI_KNEE + (L0 - HI_KNEE) * HI_K
    else:
        Lt = L0
    if L1 > 0:
        rgb = rgb * (Lt / L1)
    return tuple(int(round(min(255, max(0, x)))) for x in rgb)


def build_masks(s3d, alpha):
    logc = rgba(os.path.join(ROOT, "pl", "g6", "logc", "32", "house_day.png"))
    log = rgba(os.path.join(ROOT, "pl", "g5", "log", "32", "house_day.png"))
    corner = (logc != log).any(axis=2)          # the S3 hewn-timber edit (rows 162-280, x 6-26 and 357-377)
    # That edit also repainted plain S3 wall between the timber ends. Those pixels use S3 wall colours, which read as
    # grey-green blotches beside the remapped P1 wall, so they go to P1 too: only the timber colours (and dark
    # outlines) stay S3.
    wz = np.zeros((H, W), bool)
    for s in p1.WALL_CLEAR:
        wz[s] = True
    wall_cols = {tuple(c) for c in s3d[wz][:, :3].tolist()}
    is_wall_col = np.array([[tuple(s3d[y, x, :3].tolist()) in wall_cols for x in range(W)] for y in range(H)])
    dark = p1.h1.lumi(s3d) < 40
    corner &= ~(is_wall_col & ~dark)
    p1m = np.zeros((H, W), bool)
    p1m[WALL_TOP:WALL_BOT] = True
    x0, x1, y0, y1 = DOOR
    p1m[y0:y1, x0:x1] = True
    p1m &= alpha & ~corner
    return corner, p1m


def glass_mask(day, s3_glass):
    """Night glass for the composite: inside each S3 glass pane box, every pixel that is not a warm frame/mullion
    colour of the composite's own (P1) window. So the light follows P1's frames and mullions, not S3's."""
    g = np.zeros((H, W), bool)
    ys, xs = np.nonzero(s3_glass)
    for wx0, wx1 in WINDOWS:
        sel = (xs >= wx0) & (xs < wx1)
        bx0, bx1, by0, by1 = xs[sel].min(), xs[sel].max() + 1, ys[sel].min(), ys[sel].max() + 1
        c = day[by0:by1, bx0:bx1, :3].astype(int)
        L = c @ np.array([0.299, 0.587, 0.114])
        warm = (c[..., 0] > c[..., 2] + 35) | (L < 24)   # brown frame/mullion or outline; glints and glass stay
        g[by0:by1, bx0:bx1] = ~warm
    return g


def night_from(day, s3_day, s3_night, s3_glass, gmask):
    out = day.copy()
    ys, xs = np.nonzero(s3_glass)
    for y, x in zip(*np.nonzero(gmask)):
        if s3_glass[y, x]:
            out[y, x] = s3_night[y, x]
        else:   # a pane pixel S3 had as frame: the nearest S3 night-glass colour on the same row of the same window
            row = xs[(ys == y) & (np.abs(xs - x) < 30)]
            if len(row):
                out[y, x] = s3_night[y, row[np.argmin(np.abs(row - x))]]
    return out


def seam_score(im, rows):
    """Mean absolute luma step across given row boundaries (y-1 -> y), over the opaque wall width."""
    L = p1.h1.lumi(im)
    return {str(y): round(float(np.abs(L[y, 40:345] - L[y - 1, 40:345]).mean()), 1) for y in rows}


def main():
    paths = [os.path.join(S3D, "house_day.png"), os.path.join(S3D, "house_night.png"), os.path.join(P1D, "house_day.png"),
             os.path.join(P1D, "house_night.png"), os.path.join(ROOT, "pl", "g7", "p1", "raw_edit.png")]
    before = {os.path.relpath(p, ROOT): sha(p) for p in paths}
    s3d, s3n, p1d = rgba(paths[0]), rgba(paths[1]), rgba(paths[2])
    alpha = s3d[..., 3] > 0
    s3_glass = (s3d != s3n).any(axis=2)
    corner, p1m = build_masks(s3d, alpha)

    cols = np.unique(p1d[p1m][:, :3], axis=0)
    lut = {tuple(int(v) for v in c): remap_colour(c) for c in cols}
    fixed = p1d.copy()
    for y, x in zip(*np.nonzero(p1m)):
        fixed[y, x, :3] = lut[tuple(int(v) for v in p1d[y, x, :3])]

    outs = {}
    for tag, src in (("32", fixed), ("32n", p1d)):
        day = s3d.copy()
        day[p1m] = src[p1m]
        day[..., 3] = np.where(alpha, 255, 0)
        gm = glass_mask(day, s3_glass)
        night = night_from(day, s3d, s3n, s3_glass, gm)
        os.makedirs(os.path.join(OUT, tag), exist_ok=True)
        Image.fromarray(day, "RGBA").save(os.path.join(OUT, tag, "house_day.png"))
        Image.fromarray(night, "RGBA").save(os.path.join(OUT, tag, "house_night.png"))
        outs[tag] = (day, night, gm)

    day, night, gm = outs["32"]
    mk = np.zeros((H, W, 4), np.uint8)
    mk[...] = (40, 44, 50, 255)
    mk[alpha] = (120, 120, 120, 255)
    mk[corner] = (170, 170, 170, 255)
    mk[p1m] = (225, 140, 60, 255)
    mk[gm] = (90, 170, 230, 255)
    Image.fromarray(mk, "RGBA").save(os.path.join(OUT, "masks.png"))

    # palette swatch: before | after per used P1 colour, sorted by luma
    items = sorted(lut.items(), key=lambda kv: luma(kv[0]))
    sw = Image.new("RGB", (2 * 24 + 8, 14 * len(items) + 4), (30, 32, 36))
    d = ImageDraw.Draw(sw)
    for i, (a, b) in enumerate(items):
        d.rectangle((2, 2 + 14 * i, 25, 13 + 14 * i), fill=a)
        d.rectangle((32, 2 + 14 * i, 55, 13 + 14 * i), fill=b)
    sw.save(os.path.join(OUT, "palette.png"))

    Lref = p1.h1.lumi(s3d)
    res = {"s3": p1.measure_one(s3d, alpha, Lref), "p1": p1.measure_one(p1d, alpha, Lref),
           "c1": p1.measure_one(day, alpha, Lref), "c1_no_remap": p1.measure_one(outs["32n"][0], alpha, Lref)}
    wm = np.zeros((H, W), bool)
    for s in p1.WALL_CLEAR:
        wm[s] = True
    for k, im in (("s3", s3d), ("p1", p1d), ("c1", day)):
        c = im[wm][:, :3]
        hsv = np.array([colorsys.rgb_to_hsv(*(x / 255.0)) for x in c])
        L = c @ [0.299, 0.587, 0.114]
        res[k]["wall_colour"] = {"mean_rgb": [round(float(v), 1) for v in c.mean(axis=0)],
                                 "sat_mean": round(float(hsv[:, 1].mean()), 3), "hue_median": round(float(np.median(hsv[:, 0])), 3),
                                 "luma_p5_p50_p95": [round(float(v)) for v in np.percentile(L, [5, 50, 95])]}
        res[k]["seams_luma_step"] = seam_score(im, [WALL_TOP, WALL_BOT])
    res["masks"] = {"p1_px": int(p1m.sum()), "s3_px": int((alpha & ~p1m).sum()), "corner_px": int(corner.sum()),
                    "night_glass_px": int(gm.sum()), "s3_night_glass_px": int(s3_glass.sum()),
                    "glass_px_not_in_s3_glass": int((gm & ~s3_glass).sum()),
                    "s3_glass_px_kept_as_p1_frame": int((s3_glass & ~gm).sum())}
    res["palette"] = {"p1_colours_remapped": len(lut), "c1_total_colours": int(len(np.unique(day[alpha][:, :3], axis=0)))}
    res["remap_params"] = {"hue_to": HUE_TO, "sat_k": SAT_K, "outline_luma": OUTLINE_L, "grain_lift": GRAIN_LIFT,
                           "hi_knee": HI_KNEE, "hi_k": HI_K}
    res["night_differs_only_inside_glass_mask"] = bool(((day != night).any(axis=2) & ~gm).sum() == 0)
    after = {os.path.relpath(p, ROOT): sha(p) for p in paths}
    res["originals_unchanged"] = before == after
    res["hashes"] = after
    with open(os.path.join(OUT, "measure.json"), "w") as fh:
        json.dump(res, fh, indent=1)
    for k in ("s3", "p1", "c1"):
        r = res[k]
        bad = {n: e["offset_px"] for n, e in r["edges"].items() if e["offset_px"] != 0}
        print(k, "wall", r["wall"], r["wall_colour"], "seams", r["seams_luma_step"], "glass", r["glass_bbox"],
              "roof sd", r["roof"]["luma_sd"], "edges off", bad)
    print("masks", res["masks"], res["palette"], "originals unchanged", res["originals_unchanged"])


if __name__ == "__main__":
    main()
