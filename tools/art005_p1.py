# ART-005 P1 (non-production): measurement and free technical adjustment of the ONE PixelLab Pro edit_image of the
# approved S3 Roof A log cabin (owner authorization of 2026-11-05, hard limit 25 generations, no retry).
#   python tools/art005_p1.py
# Reads (never writes):
#   pl/g6/shake/32/house_day.png, house_night.png   the S3 input (hash-checked before and after)
#   pl/g7/p1/raw_edit.png                           the PixelLab output, kept exactly as downloaded (read-only file)
# Writes:
#   pl/g7/p1/p1_snap_day.png    the raw edit with the input's exact alpha: pixels outside the input silhouette cut,
#                               pixels made transparent inside it filled from the nearest raw pixel on the same row.
#                               No palette snap, repaint or inpaint.
#   pl/g7/p1/p1_snap_night.png  snap_day plus the S3 night glass: the 1,828 px where the S3 input's night sprite
#                               differs from its day sprite (window glass only) take the S3 night colours
#   pl/g7/p1/32/house_day|night.png  the same two, for tools/art005_density.gd art=g7 var=p1
#   pl/g7/raw/32/house_day.png  the raw edit unchanged (night = raw + the same glass), for art=g7 var=raw
#   pl/g7/p1/measure.json
import hashlib
import json
import os
import shutil
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_h1 as h1  # noqa: E402  (lumi, edge_offset, period, repetition, noise, fmt)
import art005_m0 as m0  # noqa: E402

ROOT = m0.ROOT
IN = os.path.join(ROOT, "pl", "g6", "shake", "32")
P1 = os.path.join(ROOT, "pl", "g7", "p1")
RAWD = os.path.join(ROOT, "pl", "g7", "raw", "32")
W, H = 384, 320

# Anchors. Interior anchors are M0's (S3 keeps M0's door, windows, steps and foundation, tools/art005_s3.py uses
# m0.build_labels()); roof anchors are read off the S3 input's own luminance profiles (SA side gable).
EDGES = [e for e in h1.EDGES if not e[0].startswith(("eave_line", "fascia_top", "ridge_cap", "chimney"))] + [
    ("ridge_top", "y", 42, (60, 280)), ("ridge_board_bottom", "y", 56, (60, 280)),
    ("fascia_top", "y", 148, (40, 350)), ("eave_shadow_top", "y", 155, (40, 350)),
    ("wall_top", "y", 160, (40, 350)),
    ("chimney_left", "x", 291, (22, 40)), ("chimney_right", "x", 329, (22, 40)), ("chimney_top", "y", 20, (295, 325)),
]
ROOF = (slice(58, 146), slice(20, 364))           # roof field, below the ridge board, above the fascia
CHIM = (slice(0, 70), slice(286, 334))
WALL_CLEAR = [(slice(172, 276), slice(34, 70)), (slice(172, 276), slice(316, 350))]   # between corner and window


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def rgba(p):
    return np.array(Image.open(p).convert("RGBA"))


def glass_bbox(im, x0, x1):
    """Bounding box of the bluish glass pixels in a window zone (colour segmentation)."""
    c = im[196:252, x0:x1, :3].astype(int)
    g = (c[..., 2] > c[..., 0] + 12) & (im[196:252, x0:x1, 3] > 0)
    ys, xs = np.nonzero(g)
    if not len(xs):
        return None
    return [int(xs.min() + x0), int(xs.max() + x0), int(ys.min() + 196), int(ys.max() + 196)]


def roof_mask(im):
    m = np.zeros((H, W), bool)
    m[ROOF] = True
    m[CHIM] = False
    return m & (im[..., 3] > 0)


def measure_one(im, alpha_in, Lref):
    L = h1.lumi(im)
    op = im[..., 3] > 0
    r = {"edges": {}}
    for n, ax, pos, span in EDGES:
        off, c = h1.edge_offset(L, ax, pos, span, Lref)
        r["edges"][n] = {"offset_px": off, "match": c}
    top = lambda A: np.array([np.nonzero(A[:, x])[0].min() if A[:, x].any() else -1 for x in range(W)])
    dtop = top(op) - top(alpha_in)
    r["silhouette"] = {"px_added": int((op & ~alpha_in).sum()), "px_removed": int((~op & alpha_in).sum()),
                       "iou": round(float((op & alpha_in).sum() / (op | alpha_in).sum()), 4),
                       "roofline_top_shift_px": {str(int(k)): int(v) for k, v in zip(*np.unique(dtop, return_counts=True))}}
    r["glass_bbox"] = {"west": glass_bbox(im, 70, 124), "east": glass_bbox(im, 260, 314)}
    rm = roof_mask(im)
    rl = L[rm]
    r["roof"] = {"mean_luma": round(float(rl.mean()), 1), "luma_sd": round(float(rl.std()), 1),
                 "colours": int(len(np.unique(im[rm][:, :3], axis=0))),
                 "pale_specks_px": int((rm & (L > rl.mean() + 3 * rl.std())).sum()),
                 "noise": round(h1.noise(L, rm), 2)}
    rows = L[58:146, 40:280].mean(axis=1)
    r["roof"]["course_period"] = dict(zip(("px", "strength"), [round(v, 3) for v in h1.period(rows, 6, 24)]))
    c, dx, dy = h1.repetition(L, 120, 184, 80, 120)
    r["roof"]["self_match"] = {"max": round(c, 3), "dx": dx, "dy": dy}
    wm = np.zeros((H, W), bool)
    for s in WALL_CLEAR:
        wm[s] = True
    wl = L[wm & op]
    r["wall"] = {"mean_luma": round(float(wl.mean()), 1), "luma_sd": round(float(wl.std()), 1),
                 "noise": round(h1.noise(L, wm & op), 2)}
    wrows = np.concatenate([L[s] for s in WALL_CLEAR], axis=1).mean(axis=1)
    r["wall"]["log_period"] = dict(zip(("px", "strength"), [round(v, 3) for v in h1.period(wrows, 8, 30)]))
    r["wall_minus_roof_luma"] = round(r["wall"]["mean_luma"] - r["roof"]["mean_luma"], 1)
    r["eave_shadow_155_160_luma"] = round(float(L[155:160, 40:350].mean()), 1)
    r["format"] = h1.fmt(im)
    return r


def post(raw, alpha_in):
    out = raw.copy()
    out[..., 3] = np.where(alpha_in, 255, 0)
    out[~alpha_in, :3] = 0
    fill = alpha_in & (raw[..., 3] == 0)
    for y, x in zip(*np.nonzero(fill)):
        row = np.nonzero(raw[y, :, 3] > 0)[0]
        if len(row):
            out[y, x, :3] = raw[y, row[np.argmin(np.abs(row - x))], :3]
    return out, int(fill.sum()), int(((raw[..., 3] > 0) & ~alpha_in).sum())


def main():
    pin, pinn, praw = os.path.join(IN, "house_day.png"), os.path.join(IN, "house_night.png"), os.path.join(P1, "raw_edit.png")
    before = {"input_day": sha(pin), "input_night": sha(pinn), "raw_edit": sha(praw)}
    d_in, n_in, raw = rgba(pin), rgba(pinn), rgba(praw)
    a_in = d_in[..., 3] > 0
    glass = (d_in != n_in).any(axis=2)
    snap, filled, cut = post(raw, a_in)
    snap_n = snap.copy()
    snap_n[glass] = n_in[glass]
    raw_n = raw.copy()
    raw_n[glass] = n_in[glass]
    os.makedirs(os.path.join(P1, "32"), exist_ok=True)
    os.makedirs(RAWD, exist_ok=True)
    for im, p in ((snap, os.path.join(P1, "p1_snap_day.png")), (snap_n, os.path.join(P1, "p1_snap_night.png")),
                  (raw_n, os.path.join(RAWD, "house_night.png"))):
        Image.fromarray(im, "RGBA").save(p)
    shutil.copyfile(os.path.join(P1, "p1_snap_day.png"), os.path.join(P1, "32", "house_day.png"))
    shutil.copyfile(os.path.join(P1, "p1_snap_night.png"), os.path.join(P1, "32", "house_night.png"))
    shutil.copyfile(praw, os.path.join(RAWD, "house_day.png"))
    Lref = h1.lumi(d_in)
    res = {"input_s3_shake": measure_one(d_in, a_in, Lref), "raw_edit": measure_one(raw, a_in, Lref),
           "p1_snap": measure_one(snap, a_in, Lref)}
    sh = np.roll(np.roll(d_in, 3, axis=1), 2, axis=0)
    res["method_check_shift_x3_y2"] = {n: e["offset_px"] for n, e in measure_one(sh, a_in, Lref)["edges"].items()}
    diff = (snap[..., :3] != raw[..., :3]).any(axis=2) & a_in
    after = {"input_day": sha(pin), "input_night": sha(pinn), "raw_edit": sha(praw)}
    res["adjustment"] = {"alpha_snap_filled_px": filled, "alpha_snap_cut_px": cut,
                         "rgb_px_changed_inside_input_alpha": int(diff.sum()),
                         "pct_of_house": round(float(diff.sum() / a_in.sum() * 100), 3),
                         "night_glass_px_from_s3_night": int(glass.sum())}
    res["hashes_before"], res["hashes_after"] = before, after
    res["inputs_and_raw_unchanged"] = before == after
    with open(os.path.join(P1, "measure.json"), "w") as fh:
        json.dump(res, fh, indent=1)
    for k in ("input_s3_shake", "raw_edit", "p1_snap"):
        r = res[k]
        bad = {n: (e["offset_px"], e["match"]) for n, e in r["edges"].items() if e["offset_px"] != 0 or e["match"] < 0.5}
        print("==", k, "\n  sil", r["silhouette"], "\n  glass", r["glass_bbox"], "\n  roof", r["roof"],
              "\n  wall", r["wall"], "sep", r["wall_minus_roof_luma"], "eave", r["eave_shadow_155_160_luma"],
              "\n  fmt", r["format"], "\n  edges off/unclear:", bad)
    print("adjust", res["adjustment"], "unchanged", res["inputs_and_raw_unchanged"])
    print("method check (expect x:3, y:2):", res["method_check_shift_x3_y2"])


if __name__ == "__main__":
    main()
