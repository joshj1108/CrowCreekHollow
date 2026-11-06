# ART-005 C3 (non-production, zero generations): one reversible roof-VALUE variant of C2. Nothing is redrawn.
# Every roof pixel keeps its role (shake face, butt catch-light, under-butt shadow, joint, cast-shadow line, grain,
# chip, split, moss); only the ramp step of face and catch-light pixels moves, by one whole-shake amount taken from a
# broad, hand-authored plane-shading field. C2 (and C1, S3, P1) are read, hash-checked before and after, never written.
#   python tools/art005_c3.py
# Reads:  pl/g7/c2/32/house_day|night.png
# Writes (pl/g7/c3/, so the harness modes art=g7 var=c3 and house=g7:c3 draw it with no code change):
#   32/house_day.png, 32/house_night.png   C3
#   changed.png      every pixel C3 changed vs C2: orange = lifted, blue = deepened, white = catch-light strengthened
#   plan.png         the per-shake value shift (grey = 0, warm = +1/+2, blue = -1)
#   measure.json     the change record and the C2/C3 measurements
#
# What changes (all whole-shake, so no pixel noise is added):
#   * plane shading: the upper slope (courses 2-4) one step lighter, strongest left of centre where daylight from
#     the upper left lands; the lowest courses and the chimney lee one step darker where C2's face is not already at
#     the floor of the ramp. The ridge course stays in C2's shadow, which now separates more from the lit slope.
#   * catch-lights: on lit shakes in the upper half, the butt catch-light row goes one more step up.
# What does not change: joints, shadow lines and cast lines (ramp steps 0-2), moss, the chimney block, ridge,
# fascia, eave shadow, verges, the wall, doors, windows, corners, alpha and the night glass.
import hashlib
import json
import math
import os
import random
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_c2 as c2  # noqa: E402
import art005_m0 as m0  # noqa: E402

ROOT = m0.ROOT
C2D = os.path.join(ROOT, "pl", "g7", "c2")
OUT = os.path.join(ROOT, "pl", "g7", "c3")
GUARD = c2.GUARD + [os.path.join(C2D, "32", "house_day.png"), os.path.join(C2D, "32", "house_night.png")]

WARM = c2.WARM
SILVER = c2.SILVER[:7] + [(88, 76, 65)]   # C2's silver ramp repeats its top step; C3 adds ONE lighter silver step so a
                                          # silvered shake can carry a catch-light (the only new colour)
FACE_MIN, FACE_MAX, HI_MAX = 3, 6, 7

# ---- the hand-authored plane-shading field, in ramp steps, sampled once per shake at its centre ----
COURSE = [-0.45, 0.55, 0.95, 0.85, 0.45, 0.05, -0.2, -0.45, -0.7, -0.55]   # ridge course stays shaded; lit upper
                                                                           # slope; a falling plane toward the eave


def field(cx, k):
    v = COURSE[k]
    v += 0.40 * math.exp(-((cx - 150) / 125.0) ** 2) * (1.0 if k <= 5 else 0.4)   # daylight, upper left of centre
    v -= 0.25 * math.exp(-((cx - 300) / 70.0) ** 2) * (1.0 if k >= 3 else 0.0)    # the chimney's lee and runoff
    if cx < c2.FX0 + 24 or cx > c2.FX1 - 24:                                      # verge occlusion, a little deeper
        v -= 0.35
    return v


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def index_of():
    """colour -> (ramp name, step). Steps 0-1 are shared by both ramps (lines)."""
    m = {}
    for i, c in enumerate(WARM):
        m[c] = ("w", i)
    for i, c in enumerate(SILVER):
        m.setdefault(c, ("s", i))
    return m


def remap(day):
    idx = index_of()
    rows = c2.layout(random.Random(c2.SEED))     # C2's exact shake layout (the layout is drawn first from the seed)
    out = day.copy()
    plan = np.zeros(day.shape[:2] + (3,), np.uint8)
    kind = np.zeros(day.shape[:2], np.uint8)     # 1 lifted, 2 deepened, 3 catch-light strengthened
    cx0, cx1, cy0, cy1 = c2.CHIMNEY
    st = {"shakes_lifted": 0, "shakes_deepened": 0, "shakes_kept": 0, "catchlights_strengthened": 0,
          "shift_hist": {}}
    for k, (top, shad) in enumerate(c2.COURSES):
        y0, y1 = top, min(shad, 147)
        for x0, x1 in rows[k]:
            d = int(math.floor(field((x0 + x1) / 2.0, k) + 0.5))
            d = max(-1, min(1, d))
            st["shift_hist"][d] = st["shift_hist"].get(d, 0) + 1
            px = [(y, x) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1)
                  if not (cx0 <= x <= cx1 and cy0 <= y <= cy1)]
            steps = [idx.get(tuple(int(v) for v in day[y, x, :3])) for y, x in px]
            faces = [s[1] for s in steps if s and s[1] >= FACE_MIN]
            if not faces:
                continue
            face = max(set(faces), key=faces.count)
            # never let the ramp ends merge two steps inside a shake (soft joint, grain or under-butt row into the
            # face): shrink the shift until the shake keeps as many distinct steps as it had in C2
            body = {(s[0], s[1]) for s in steps if s and s[1] >= FACE_MIN}
            while d != 0:
                moved_steps = {(r, max(FACE_MIN, min(FACE_MAX if i <= face else HI_MAX, i + d))) for r, i in body}
                if len(moved_steps) == len(body):
                    break
                d += -1 if d > 0 else 1
            lit = d >= 1 and k <= 5
            moved = False
            for (y, x), s in zip(px, steps):
                if not s or s[1] < FACE_MIN:
                    continue                                  # lines, shadows, chips, splits and moss stay
                ramp = WARM if s[0] == "w" else SILVER
                catch = s[1] > face and y >= shad - 2         # the butt catch-light row (with its +-1 px drop)
                n = s[1] + d + (1 if (catch and lit) else 0)
                n = max(FACE_MIN, min(HI_MAX if catch else FACE_MAX, n))
                if catch and n <= face + d:
                    n = min(HI_MAX, face + d + 1)             # a catch-light never merges into its own face
                if n != s[1]:
                    out[y, x, :3] = ramp[n]
                    moved = True
                    kind[y, x] = 3 if (catch and lit) else (1 if n > s[1] else 2)
                    st["catchlights_strengthened"] += int(catch and lit)
            g = 128 + 40 * d
            plan[y0:y1 + 1, x0:x1 + 1] = (min(255, g + (40 if d > 0 else 0)), g, min(255, g + (60 if d < 0 else 0)))
            if moved:
                st["shakes_lifted" if d > 0 else ("shakes_deepened" if d < 0 else "shakes_kept")] += 1
            else:
                st["shakes_kept"] += 1
    return out, plan, kind, st


def metrics(img, wall_ref):
    m = c2.roof_metrics(img)
    r = img[57:148, c2.FX0:c2.FX1 + 1, :3].astype(float)
    L = 0.299 * r[:, :, 0] + 0.587 * r[:, :, 1] + 0.114 * r[:, :, 2]
    up = L[66 - 57:93 - 57].mean()        # courses 2-4, the lit upper plane
    lo = L[111 - 57:148 - 57].mean()      # courses 7-10, toward the eave
    rg = L[0:9].mean()                    # course 1, under the ridge
    m.update({"upper_plane_luma": round(float(up), 1), "lower_plane_luma": round(float(lo), 1),
              "ridge_course_luma": round(float(rg), 1), "upper_minus_lower": round(float(up - lo), 1),
              "upper_minus_ridge": round(float(up - rg), 1),
              "luma_p95": round(float(np.percentile(L, 95)), 1), "luma_p05": round(float(np.percentile(L, 5)), 1),
              "wall_minus_roof": round(float(wall_ref - L.mean()), 1)})
    return m


def main():
    for p in GUARD:
        assert os.path.exists(p), p
    before = {p: sha(p) for p in GUARD}
    day = np.array(Image.open(os.path.join(C2D, "32", "house_day.png")).convert("RGBA"))
    night = np.array(Image.open(os.path.join(C2D, "32", "house_night.png")).convert("RGBA"))
    assert (day[42:160] == night[42:160]).all()          # the roof is shared by both sprites
    out, plan, kind, st = remap(day)
    chg = (out != day).any(2)
    outside = chg.copy()
    outside[57:148, c2.FX0:c2.FX1 + 1] = False
    assert not outside.any(), "a pixel outside the roof field changed"
    assert (out[:, :, 3] == day[:, :, 3]).all(), "alpha changed"
    # structure check: every line/shadow pixel (steps 0-2) and every non-ramp pixel (moss) is C2's exactly
    idx = index_of()
    roof = day[57:148, c2.FX0:c2.FX1 + 1, :3]
    for y in range(roof.shape[0]):
        for x in range(roof.shape[1]):
            s = idx.get(tuple(int(v) for v in roof[y, x]))
            if not s or s[1] < FACE_MIN:
                assert not chg[57 + y, c2.FX0 + x], "a line, shadow or moss pixel moved"
    night2 = night.copy()
    night2[chg] = out[chg]
    os.makedirs(os.path.join(OUT, "32"), exist_ok=True)
    Image.fromarray(out).save(os.path.join(OUT, "32", "house_day.png"))
    Image.fromarray(night2).save(os.path.join(OUT, "32", "house_night.png"))
    vis = np.zeros(day.shape[:2] + (3,), np.uint8)
    vis[kind == 1] = (235, 150, 60)
    vis[kind == 2] = (70, 120, 235)
    vis[kind == 3] = (255, 255, 255)
    Image.fromarray(vis).save(os.path.join(OUT, "changed.png"))
    Image.fromarray(plan).save(os.path.join(OUT, "plan.png"))
    after = {p: sha(p) for p in GUARD}
    assert before == after, "a source file changed"
    wl = c2.luma(np.median(day[180:260, 60:320, :3].reshape(-1, 3), 0))
    rc = {tuple(int(v) for v in c) for c in roof.reshape(-1, 3)}
    new = {tuple(int(v) for v in c) for c in out[57:148, c2.FX0:c2.FX1 + 1, :3].reshape(-1, 3)} - rc
    rec = {"spend": "zero: no PixelLab, SpriteCook or other generation",
           "method": "per-shake ramp-step remap of C2; C2's layout recomputed from its seed; lines, shadows, moss kept",
           "course_field": COURSE, "pixels_changed": int(chg.sum()),
           "pixels_lifted": int((kind == 1).sum()), "pixels_deepened": int((kind == 2).sum()),
           "catchlight_pixels": int((kind == 3).sum()), "new_colours_vs_c2_roof": sorted(new),
           "shakes": st, "wall_luma_median": round(float(wl), 1),
           "c2_roof": metrics(day, wl), "c3_roof": metrics(out, wl), "sources_unchanged": True}
    with open(os.path.join(OUT, "measure.json"), "w") as f:
        json.dump(rec, f, indent=1, default=str)
    print(json.dumps(rec, indent=1, default=str))


if __name__ == "__main__":
    main()
