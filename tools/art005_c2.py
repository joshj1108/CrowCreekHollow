# ART-005 C2 (non-production, zero generations): an artist-directed repaint of C1's wood-shake roof field plus a small
# palette harmonisation of the hewn corner timbers. No generative, paid or AI operation. C1 (and S3, P1) are read,
# hash-checked before and after, and never written.
#   python tools/art005_c2.py
# Reads:  pl/g7/c1/32/house_day|night.png, pl/g7/c1/masks.png (the S3 corner-timber pixels)
# Writes (pl/g7/c2/, so the harness modes art=g7 var=c2 and house=g7:c2 draw it with no code change):
#   32/house_day.png, 32/house_night.png   C2
#   changed.png      every pixel C2 changed: red = roof field, cyan = corner timbers (black = untouched)
#   layout.png       the authored shading plan: per-shake ramp step (grey = warm ramp, blue tint = silvered ramp)
#   measure.json     the change record and the C1/C2 roof and timber measurements
#
# What is authored by hand (constants below) and what is rule-driven:
#   * hand: the course rows (C1's ten courses, unchanged), the value masses (MASSES: ridge shadow, two sun-silvered
#     zones, the chimney runoff streak, damp eave corners, verge occlusion), the moss clusters (MOSS), the colour
#     ramps (C1's own roof colours only: no new colour enters the roof), and the preserved chimney block.
#   * rule-driven with a fixed seed (so it is reproducible, not re-rolled): the shake widths (6-16 px, no width
#     repeated twice in a row, every joint at least 3 px from the joints of the course below), which joints are
#     drawn hard, soft or as a value change only, the +-1 px butt drops, chips, splits and grain placement.
import colorsys
import hashlib
import json
import os
import random
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

ROOT = m0.ROOT
C1D = os.path.join(ROOT, "pl", "g7", "c1")
OUT = os.path.join(ROOT, "pl", "g7", "c2")
GUARD = [os.path.join(C1D, "32", "house_day.png"), os.path.join(C1D, "32", "house_night.png"),
         os.path.join(C1D, "masks.png"),
         os.path.join(ROOT, "pl", "g6", "shake", "32", "house_day.png"),
         os.path.join(ROOT, "pl", "g6", "shake", "32", "house_night.png"),
         os.path.join(ROOT, "pl", "g7", "p1", "32", "house_day.png")]

# ---- geometry (read off C1; unchanged) ----
FX0, FX1 = 8, 375           # shake field columns (left verge 2-7, right verge/outline 376-381 stay C1)
COURSES = [(57, 65), (66, 74), (75, 83), (84, 92), (93, 101), (102, 110), (111, 119), (120, 128), (129, 138),
           (139, 148)]      # (top row, shadow row); the last course butts onto the fascia (row 148 is fascia, kept)
CHIMNEY = (294, 333, 57, 66)  # x0, x1, y0, y1 inclusive: chimney stones, flashing and its cast shadow kept as C1

# ---- palette: C1's roof colours only ----
WARM = [(26, 20, 16), (30, 22, 17), (40, 30, 23), (50, 38, 29), (60, 46, 35), (71, 55, 42), (83, 64, 50),
        (106, 80, 64)]
SILVER = [(26, 20, 16), (30, 22, 17), (41, 35, 30), (51, 44, 37), (62, 53, 44), (73, 62, 53), (78, 66, 56),
          (78, 66, 56)]
MOSS_DK, MOSS_MD, MOSS_LT = (46, 52, 32), (63, 74, 38), (82, 96, 46)

# ---- the hand-authored value masses (in ramp steps; base step 4 = C1's dominant (60,46,35)) ----
COURSE_BIAS = [-0.9, 0.4, 0.5, 0.35, 0.05, 0.0, -0.15, -0.25, -0.3, 0.1]   # ridge shadow, lit upper slope, eave
MASSES = [  # (cx, course, rx, rcourses, delta, silver): broad soft ellipses, sampled once per shake
    (118, 2.6, 112, 2.6, 0.9, True),    # the big sun-silvered field, upper left-centre
    (238, 6.0, 64, 1.7, 0.45, True),     # a smaller bleached patch, lower centre-right
    (318, 2.0, 22, 5.5, -0.95, False),   # runoff streak under the chimney (narrow, long)
    (20, 9.0, 46, 2.4, -0.7, False),     # damp eave corner, left
    (362, 8.6, 50, 2.6, -0.75, False),   # damp eave corner, right
    (196, 8.4, 70, 1.2, -0.35, False),   # a broad slightly darker band low on the slope (reads as a shadow mass)
]
VERGE_AO = 14               # columns next to each verge board drop half a step
# hand-placed moss: (x, y) of a cluster's left pixel, pattern rows (d = dark, m = moss, l = light)
MOSS = [(14, 146, ["md", "dmm"]), (31, 137, ["dm"]), (47, 147, ["mm"]), (343, 146, ["dmm", "mm"]),
        (358, 137, ["md"]), (327, 92, ["d"]), (336, 101, ["dm"])]

SEED = 5   # chosen once from seeds 1-8 for the least repetitive joint rhythm; never re-rolled per run


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()


def luma(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def mass(x, k):
    v, silver = COURSE_BIAS[k], 0.0
    for cx, ck, rx, rk, dv, sv in MASSES:
        d = ((x - cx) / rx) ** 2 + ((k - ck) / rk) ** 2
        if d < 1.0:
            w = (1.0 - d) ** 1.5
            v += dv * w
            if sv:
                silver = max(silver, w)
    if x < FX0 + VERGE_AO or x > FX1 - VERGE_AO:
        v -= 0.5
    return v, silver


def layout(rng):
    """Per course, a list of (x0, x1) shakes covering FX0..FX1, staggered against the course below."""
    rows = [None] * len(COURSES)
    below = []
    for k in range(len(COURSES) - 1, -1, -1):          # eave first, so each course is staggered on the one below
        for _ in range(400):
            x, prev, sh, ok = FX0, -1, [], True
            while x <= FX1:
                w = rng.choice([6, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 13, 14, 15, 16])
                if w == prev:
                    continue
                if FX1 - (x + w - 1) < 5:                  # no sliver at the right verge
                    w = FX1 - x + 1
                j = x + w                                   # the joint column after this shake
                if j <= FX1 and any(abs(j - b) < 3 for b in below):
                    w2 = [ww for ww in range(6, 17) if not any(abs(x + ww - b) < 3 for b in below)
                          and ww != prev and FX1 - (x + ww - 1) >= 5]
                    if not w2:
                        ok = False
                        break
                    w = rng.choice(w2)
                sh.append((x, min(FX1, x + w - 1)))
                prev, x = w, x + w
            if ok:
                break
        rows[k] = sh
        below = [a for a, _ in sh[1:]]
    return rows


def build():
    for p in GUARD:
        assert os.path.exists(p), p
    before = {p: sha(p) for p in GUARD}
    day = np.array(Image.open(os.path.join(C1D, "32", "house_day.png")).convert("RGBA"))
    night = np.array(Image.open(os.path.join(C1D, "32", "house_night.png")).convert("RGBA"))
    roof_c1 = day[57:148, FX0:FX1 + 1].copy()
    assert (day[42:160] == night[42:160]).all()          # C1's roof is identical day and night
    rng = random.Random(SEED)
    rows = layout(rng)
    out = day.copy()
    plan = np.zeros((day.shape[0], day.shape[1], 3), np.uint8)
    yA, yB = COURSES[0][0], COURSES[-1][1] - 1
    out[yA:yB + 1, FX0:FX1 + 1, :3] = WARM[1]           # cleared to the shadow colour; every pixel is repainted
    stats = {"shakes": 0, "hard": 0, "soft": 0, "none": 0, "drop+1": 0, "drop-1": 0, "chips": 0, "splits": 0,
             "grain": 0, "silver": 0, "widths": []}

    def put(x, y, c):
        if FX0 <= x <= FX1 and yA <= y <= yB:
            out[y, x, :3] = c

    for k in range(len(COURSES) - 1, -1, -1):          # eave to ridge: upper butts overlap the course below
        top, shad = COURSES[k]
        last = k == len(COURSES) - 1
        steps = []
        for i, (x0, x1) in enumerate(rows[k]):
            v, silver = mass((x0 + x1) / 2.0, k)
            off = rng.choices([-1, 0, 1], [16, 62, 22])[0]
            if steps and steps[-1][0] == round(v) + 1 and off == 1:
                off = 0                                       # never two raised shakes side by side
            s = int(np.clip(np.floor(v + 4.0 + off * 0.75 + 0.5), 3, 6))
            ramp = SILVER if silver > 0.35 and rng.random() < 0.55 + 0.45 * silver else WARM
            drop = 0 if last else rng.choices([-1, 0, 1], [12, 70, 18])[0]
            steps.append((s, ramp, drop))
        for i, (x0, x1) in enumerate(rows[k]):
            s, ramp, drop = steps[i]
            w = x1 - x0 + 1
            stats["shakes"] += 1
            stats["widths"].append(w)
            stats["silver"] += ramp is SILVER
            stats["drop+1"] += drop == 1
            stats["drop-1"] += drop == -1
            hi = shad - 1 + drop                              # butt highlight row
            face0 = top + 1
            for x in range(x0, x1 + 1):
                put(x, top, ramp[max(2, s - 2)])              # under-butt shadow of the course above
                for y in range(face0, hi):
                    put(x, y, ramp[s])
                put(x, hi, ramp[min(7, s + 1)] if (w >= 8 or s <= 4) else ramp[s])
                if not last:
                    put(x, hi + 1, WARM[1])                   # the butt's cast shadow line
                    if drop == -1:
                        put(x, hi + 2, WARM[2])               # a short shake shows a deeper gap
                plan[top:hi + 1, x] = (40 + 30 * s, 40 + 30 * s, min(255, 40 + 30 * s + (70 if ramp is SILVER else 0)))
            # soft upper-face falloff: on wide shakes the top face row is one step darker, as one solid run
            if w >= 11:
                for x in range(x0 + 1, x1):
                    put(x, face0, ramp[s - 1])
            # grain: one interrupted streak, never to the butt
            if w >= 9 and rng.random() < 0.33:
                gx = x0 + max(2, min(w - 3, int(w * rng.choice([0.3, 0.4, 0.6, 0.7]))))
                for y in range(face0 + 1, hi - 2):
                    if y != face0 + 3:
                        put(gx, y, ramp[s - 1])
                stats["grain"] += 1
            # chipped butt corner
            if rng.random() < 0.12:
                put(x0 if rng.random() < 0.5 else x1, hi, WARM[2])
                stats["chips"] += 1
            # split shake: a crack up from the butt on wide shakes
            if w >= 13 and rng.random() < 0.25:
                cx = x0 + w // 2 + rng.choice([-1, 0, 1])
                for y in range(hi - rng.choice([3, 4, 5]), hi + 1):
                    put(cx, y, WARM[2])
                stats["splits"] += 1
            # the joint at this shake's left edge
            if i > 0:
                ps = steps[i - 1][0]
                kind = rng.choices(["hard", "soft", "none"], [32, 46, 22])[0]
                if kind == "none" and ps == s and steps[i - 1][1] is ramp:
                    kind = "soft"
                stats[kind] += 1
                if kind == "hard":
                    for y in range(top, hi + 1):
                        put(x0, y, WARM[2])
                elif kind == "soft":
                    for y in range(face0, hi):
                        put(x0, y, ramp[max(2, s - 1)])
    # hand-placed moss, only on shadow lines and butt rows of the lowest courses and the chimney lee
    pal = {"d": MOSS_DK, "m": MOSS_MD, "l": MOSS_LT}
    for x, y, pat in MOSS:
        for dy, row in enumerate(pat):
            for dx, ch in enumerate(row):
                put(x + dx, y + dy, pal[ch])
    # keep C1's chimney block exactly
    cx0, cx1, cy0, cy1 = CHIMNEY
    out[cy0:cy1 + 1, cx0:cx1 + 1] = day[cy0:cy1 + 1, cx0:cx1 + 1]
    stats["widths"] = {"min": min(stats["widths"]), "max": max(stats["widths"]),
                       "mean": round(float(np.mean(stats["widths"])), 2),
                       "distinct": len(set(stats["widths"]))}
    return day, night, out, plan, roof_c1, before, stats


def timbers(day, out):
    """Move the S3 corner-timber colours a little toward the wall courses (hue and saturation half way, luma a
    third of the way), per colour, so the timbers stay their own pieces but stop reading cooler than the logs."""
    m = np.array(Image.open(os.path.join(C1D, "masks.png")).convert("RGB"))
    grey = (m == (170, 170, 170)).all(2)       # masks.png: light grey = the S3 hewn-corner pixels
    sel = np.zeros(grey.shape, bool)
    sel[160:281, :26] = True
    sel[160:281, 358:] = True
    tm = grey & sel & (day[:, :, 3] > 0)
    wall = (m == (225, 140, 60)).all(2)
    wall[:160] = False
    wall[281:] = False

    def stats_of(mask):
        px = day[mask][:, :3].astype(float) / 255.0
        hsv = np.array([colorsys.rgb_to_hsv(*p) for p in px])
        lum = np.array([luma(p * 255) for p in px])
        wood = (hsv[:, 1] > 0.12) & (lum > 30)
        return (float(np.median(hsv[wood, 0])), float(np.median(hsv[wood, 1])), float(np.median(lum[wood])),
                float(np.percentile(lum[wood], 90)))

    th, ts, tl, t90 = stats_of(tm)
    wh, ws, wl, w90 = stats_of(wall)
    lut = {}
    for c in {tuple(int(v) for v in day[y, x, :3]) for y, x in zip(*np.where(tm))}:
        r, g, b = (v / 255.0 for v in c)
        h, s, v = colorsys.rgb_to_hsv(r, g, b)
        L0 = luma(c)
        if s <= 0.12 or L0 <= 30:          # outlines, end-grain cracks and grey mortar stay
            lut[c] = c
            continue
        h2 = h + (wh - th) * 0.5
        s2 = s + (ws - ts) * 0.5
        r2, g2, b2 = colorsys.hsv_to_rgb(h2, max(0.0, s2), v)
        rgb = np.array([r2, g2, b2]) * 255.0
        Lt = L0 + (wl - tl) * 0.33
        L1 = luma(rgb)
        rgb = np.clip(rgb * (Lt / L1 if L1 > 0 else 1.0), 0, 255)
        lut[c] = tuple(int(round(v)) for v in rgb)
    n = 0
    for y, x in zip(*np.where(tm)):
        c = tuple(int(v) for v in day[y, x, :3])
        if lut[c] != c:
            out[y, x, :3] = lut[c]
            n += 1
    after = stats_of(tm) if False else None
    return tm, n, {"timber_before": {"hue": round(th, 4), "sat": round(ts, 3), "luma_med": round(tl, 1),
                                     "luma_p90": round(t90, 1)},
                   "wall": {"hue": round(wh, 4), "sat": round(ws, 3), "luma_med": round(wl, 1),
                            "luma_p90": round(w90, 1)},
                   "colours_remapped": sum(1 for c in lut if lut[c] != c), "colours_kept": sum(1 for c in lut
                                                                                            if lut[c] == c)}


def roof_metrics(img):
    r = img[57:148, FX0:FX1 + 1, :3].astype(float)
    L = 0.299 * r[:, :, 0] + 0.587 * r[:, :, 1] + 0.114 * r[:, :, 2]
    # local noise: mean abs difference to the right and below neighbour (pixel busy-ness)
    noise = float((np.abs(np.diff(L, axis=1)).mean() + np.abs(np.diff(L, axis=0)).mean()) / 2)
    # large-mass contrast: SD of 24x18 px block means (how much broad value structure there is)
    bm = [L[y:y + 18, x:x + 24].mean() for y in range(0, L.shape[0] - 17, 18) for x in range(0, L.shape[1] - 23, 24)]
    # course regularity: how strongly the row-mean profile repeats every course (autocorrelation at lag 9)
    p = L.mean(1) - L.mean()
    ac = float((p[:-9] * p[9:]).sum() / (p * p).sum())
    hard = float((L < 26).mean())          # share of near-black line pixels
    cols = len({tuple(c) for c in r.reshape(-1, 3).astype(int)})
    return {"luma_mean": round(float(L.mean()), 1), "luma_sd": round(float(L.std()), 1),
            "pixel_noise": round(noise, 2), "mass_sd": round(float(np.std(bm)), 2),
            "course_repeat_ac9": round(ac, 3), "dark_line_share": round(hard, 3), "colours": cols}


def main():
    day, night, out, plan, roof_c1, before, stats = build()
    tm, ntim, tstats = timbers(day, out)
    night2 = night.copy()
    chg = (out != day).any(2)
    night2[chg] = out[chg]                                    # the same edits on the night sprite (roof is shared;
    os.makedirs(os.path.join(OUT, "32"), exist_ok=True)       # timbers are not lit at night, so identical too)
    Image.fromarray(out).save(os.path.join(OUT, "32", "house_day.png"))
    Image.fromarray(night2).save(os.path.join(OUT, "32", "house_night.png"))
    vis = np.zeros((day.shape[0], day.shape[1], 3), np.uint8)
    roofchg = chg.copy()
    roofchg[160:] = False
    vis[roofchg] = (230, 60, 50)
    vis[chg & tm] = (60, 210, 220)
    Image.fromarray(vis).save(os.path.join(OUT, "changed.png"))
    Image.fromarray(plan).save(os.path.join(OUT, "layout.png"))
    after = {p: sha(p) for p in GUARD}
    assert before == after, "a source file changed"
    assert (out[:, :, 3] == day[:, :, 3]).all(), "alpha changed"
    outside = chg.copy()
    outside[57:148, FX0:FX1 + 1] = False
    outside &= ~tm
    assert not outside.any(), "a pixel outside the roof field and timbers changed"
    rc = {tuple(c) for c in roof_c1.reshape(-1, 4)[:, :3]}
    new_cols = {tuple(int(v) for v in c) for c in out[57:148, FX0:FX1 + 1, :3].reshape(-1, 3)} - rc
    rec = {
        "spend": "zero: no PixelLab, SpriteCook or other generation",
        "seed": SEED,
        "roof_field": {"rows": [57, 147], "cols": [FX0, FX1], "chimney_block_kept": CHIMNEY,
                       "pixels_changed": int(roofchg.sum()),
                       "pixels_in_field": int((148 - 57) * (FX1 - FX0 + 1) - (CHIMNEY[1] - CHIMNEY[0] + 1) * 10),
                       "new_colours_vs_c1_roof": sorted(new_cols)},
        "timbers": dict(tstats, pixels_in_mask=int(tm.sum()), pixels_changed=int((chg & tm).sum())),
        "untouched": "everything else: ridge 42-56, fascia 148-154, eave shadow 155-159, verges, chimney block, "
                     "log wall, windows, door, lamp, foundation, steps, night glass, alpha",
        "shakes": stats,
        "c1_roof": roof_metrics(day),
        "c2_roof": roof_metrics(out),
        "sources_unchanged": True,
    }
    with open(os.path.join(OUT, "measure.json"), "w") as f:
        json.dump(rec, f, indent=1, default=str)
    print(json.dumps({k: rec[k] for k in ("roof_field", "timbers", "shakes", "c1_roof", "c2_roof")}, indent=1,
                     default=str))


if __name__ == "__main__":
    main()
