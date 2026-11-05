# ART-005 M1 (non-production): anchor v2, a non-destructive refined copy of the frozen G1 style board c1.
# c1 (pl/anchors/board_c1.png) is only read. Each 32 x 32 swatch is processed on its own (no colour crosses a swatch
# border), in logged steps:
#   1 ramp  - merge near-duplicate colours: each swatch keeps at most N of its own G1 colours (medoids, so no new
#             colour is invented); every pixel maps to the nearest kept colour in Lab
#   2 orphan- a pixel whose colour none of its 8 neighbours share takes its neighbours' majority colour
#   3 speck - 4-connected clusters smaller than 4 px (less than a 2 x 2 mark) take the colour that surrounds them,
#             except in protected structural lines (the darkest tone forming lines >= 3 px: mortar, course and
#             plank seams, the window frame's outline)
#   4 manual- the hand-chosen touches listed in EDITS (pixel rectangles), applied last
# Writes pl/g2/m1/anchor_v2.png, a before/after diff and m1_log.json (pixels changed per step and swatch, orphan %,
# colour counts, mark measurements, wall-clock time).
#   python tools/art005_m1.py
import json
import os
import time

import numpy as np
from PIL import Image

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-005")
SRC = os.path.join(ROOT, "pl", "anchors", "board_c1.png")
OUT = os.path.join(ROOT, "pl", "g2", "m1")
NAMES = [["slate", "timber", "fieldstone"], ["bark", "maple", "grass"], ["soil", "window", "water"]]
# colours kept per swatch after step 1 (c1 has 13-30 per swatch)
KEEP = {"slate": 9, "timber": 7, "fieldstone": 8, "bark": 6, "maple": 8, "grass": 8, "soil": 8, "window": 9,
        "water": 7}
# Step 4: deliberate touches, in swatch-local pixels: (swatch, x0, y0, x1, y1, action). Recorded with a reason.
# Chosen after inspecting the step 1-3 result at 5x (2026-11-05): the speck rule read the window's deliberate
# 1 px glints and the lit row of the horizontal mullion as noise. Those are restored from c1; nothing else is touched.
EDITS = [
    ("window", 5, 15, 27, 18, "copy:5,15"),    # horizontal mullion: its lit middle row was flattened
    ("window", 18, 5, 27, 15, "copy:18,5"),    # top-right pane: glint diagonal and corner shading
    ("window", 5, 18, 15, 27, "copy:5,18"),    # bottom-left pane: glint diagonal and edge shading
    ("window", 18, 18, 27, 27, "copy:18,18"),  # bottom-right pane: glint diagonal
]


def to_lab(rgb):
    c = rgb.astype(np.float64) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    m = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = c @ m.T / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)


def lum(rgb):
    rgb = rgb.astype(np.float64)
    return rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114


def ids(sw):
    """Swatch pixels as colour indices (and the colour table)."""
    cols, inv = np.unique(sw.reshape(-1, 3), axis=0, return_inverse=True)
    return cols, inv.reshape(sw.shape[:2])


def orphan_mask(idx):
    h, w = idx.shape
    same = np.zeros((h, w), int)
    nb = np.zeros((h, w), int)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dy == dx == 0:
                continue
            ys = slice(max(dy, 0), h + min(dy, 0))
            yd = slice(max(-dy, 0), h + min(-dy, 0))
            xs = slice(max(dx, 0), w + min(dx, 0))
            xd = slice(max(-dx, 0), w + min(-dx, 0))
            nb[yd, xd] += 1
            same[yd, xd] += idx[ys, xs] == idx[yd, xd]
    return (same == 0) & (nb >= 3)


def step_ramp(sw, keep):
    cols, idx = ids(sw)
    counts = np.bincount(idx.ravel(), minlength=len(cols))
    lab = to_lab(cols)
    if len(cols) <= keep:
        return sw.copy()
    # weighted k-medoids (greedy init by frequency, then a few swaps)
    chosen = [int(np.argmax(counts))]
    while len(chosen) < keep:
        d = np.min(np.linalg.norm(lab[:, None] - lab[chosen][None], axis=2), axis=1)
        chosen.append(int(np.argmax(d * np.sqrt(counts))))
    for _ in range(6):
        assign = np.argmin(np.linalg.norm(lab[:, None] - lab[chosen][None], axis=2), axis=1)
        new = []
        for k in range(len(chosen)):
            mem = np.nonzero(assign == k)[0]
            cost = [(counts[mem] * np.linalg.norm(lab[mem] - lab[c], axis=1)).sum() for c in mem]
            new.append(int(mem[int(np.argmin(cost))]))
        if new == chosen:
            break
        chosen = new
    assign = np.argmin(np.linalg.norm(lab[:, None] - lab[chosen][None], axis=2), axis=1)
    return cols[np.array(chosen)[assign]][idx]


def step_orphans(sw, passes=3):
    out = sw.copy()
    for _ in range(passes):
        cols, idx = ids(out)
        om = orphan_mask(idx)
        if not om.any():
            break
        h, w = idx.shape
        new = idx.copy()
        for y, x in zip(*np.nonzero(om)):
            nbv = [idx[yy, xx] for yy in range(max(0, y - 1), min(h, y + 2)) for xx in range(max(0, x - 1), min(w, x + 2))
                   if (yy, xx) != (y, x)]
            vals, cnt = np.unique(nbv, return_counts=True)
            best = vals[cnt == cnt.max()]
            # tie: the neighbour colour closest in luminance to the orphan
            new[y, x] = best[np.argmin(np.abs(lum(cols[best]) - lum(cols[idx[y, x]])))]
        out = cols[new]
    return out


def protected_lines(sw):
    """The darkest tone's pixels that form horizontal or vertical runs of >= 3 px."""
    cols, idx = ids(sw)
    dark = idx == int(np.argmin(lum(cols)))
    prot = np.zeros_like(dark)
    h, w = dark.shape
    for y in range(h):
        run = 0
        for x in range(w + 1):
            if x < w and dark[y, x]:
                run += 1
            else:
                if run >= 3:
                    prot[y, x - run:x] = True
                run = 0
    for x in range(w):
        run = 0
        for y in range(h + 1):
            if y < h and dark[y, x]:
                run += 1
            else:
                if run >= 3:
                    prot[y - run:y, x] = True
                run = 0
    return prot


def step_specks(sw, min_size=4):
    out = sw.copy()
    for _ in range(3):
        cols, idx = ids(out)
        prot = protected_lines(out)
        h, w = idx.shape
        seen = np.zeros((h, w), bool)
        new = idx.copy()
        changed = False
        for sy in range(h):
            for sx in range(w):
                if seen[sy, sx]:
                    continue
                comp, stack = [], [(sy, sx)]
                seen[sy, sx] = True
                while stack:
                    y, x = stack.pop()
                    comp.append((y, x))
                    for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                        if 0 <= yy < h and 0 <= xx < w and not seen[yy, xx] and idx[yy, xx] == idx[sy, sx]:
                            seen[yy, xx] = True
                            stack.append((yy, xx))
                if len(comp) >= min_size or any(prot[y, x] for y, x in comp):
                    continue
                border = []
                cs = set(comp)
                for y, x in comp:
                    for yy, xx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                        if 0 <= yy < h and 0 <= xx < w and (yy, xx) not in cs:
                            border.append(idx[yy, xx])
                if not border:
                    continue
                vals, cnt = np.unique(border, return_counts=True)
                best = vals[cnt == cnt.max()]
                pick = best[np.argmin(np.abs(lum(cols[best]) - lum(cols[idx[sy, sx]])))]
                for y, x in comp:
                    new[y, x] = pick
                changed = True
        out = cols[new]
        if not changed:
            break
    return out


def orphan_pct(sw):
    _, idx = ids(sw)
    return float(orphan_mask(idx).mean())


def course_period(sw, axis):
    """Mean distance between the darkest rows (axis 0) or columns (axis 1): the course / plank spacing."""
    prof = lum(sw).mean(axis=1 - axis)
    mins = [i for i in range(1, len(prof) - 1) if prof[i] < prof[i - 1] and prof[i] <= prof[i + 1]
            and prof[i] < np.percentile(prof, 35)]
    return float(np.mean(np.diff(mins))) if len(mins) > 1 else None, mins


def main():
    t0 = time.time()
    os.makedirs(OUT, exist_ok=True)
    src = np.array(Image.open(SRC).convert("RGB"))
    out = src.copy()
    log = {"source": "pl/anchors/board_c1.png (read only)", "steps": {}, "swatches": {}}
    for r in range(3):
        for c in range(3):
            name = NAMES[r][c]
            sw0 = src[r * 32:(r + 1) * 32, c * 32:(c + 1) * 32]
            rec = {"colours_before": int(len(ids(sw0)[0])), "orphans_before": orphan_pct(sw0)}
            sw = sw0
            for step, fn in (("ramp", lambda s: step_ramp(s, KEEP[name])), ("orphan", step_orphans),
                             ("speck", step_specks)):
                ts = time.time()
                nsw = fn(sw)
                rec[step + "_px"] = int((nsw != sw).any(-1).sum())
                rec[step + "_s"] = round(time.time() - ts, 2)
                sw = nsw
            rec["colours_after"] = int(len(ids(sw)[0]))
            rec["orphans_after"] = orphan_pct(sw)
            rec["changed_px_total"] = int((sw != sw0).any(-1).sum())
            if name in ("slate", "fieldstone"):
                rec["course_period_before"] = course_period(sw0, 0)[0]
                rec["course_period_after"] = course_period(sw, 0)[0]
            if name == "timber":
                rec["plank_period_before"] = course_period(sw0, 1)[0]
                rec["plank_period_after"] = course_period(sw, 1)[0]
            out[r * 32:(r + 1) * 32, c * 32:(c + 1) * 32] = sw
            log["swatches"][name] = rec
    # step 4: manual touches
    manual = []
    for name, x0, y0, x1, y1, act in EDITS:
        if act == "none":
            continue
        r, c = next((i, row.index(name)) for i, row in enumerate(NAMES) if name in row)
        ox, oy = c * 32, r * 32
        before = out[oy + y0:oy + y1, ox + x0:ox + x1].copy()
        if act.startswith("fill:"):
            out[oy + y0:oy + y1, ox + x0:ox + x1] = [int(act[5 + k:7 + k], 16) for k in (0, 2, 4)]
        elif act.startswith("copy:"):
            sx, sy = (int(v) for v in act[5:].split(","))
            out[oy + y0:oy + y1, ox + x0:ox + x1] = src[oy + sy:oy + sy + (y1 - y0), ox + sx:ox + sx + (x1 - x0)]
        manual.append({"swatch": name, "rect": [x0, y0, x1, y1], "action": act,
                       "px": int((out[oy + y0:oy + y1, ox + x0:ox + x1] != before).any(-1).sum())})
    log["manual_edits"] = manual
    Image.fromarray(out, "RGB").convert("RGBA").save(os.path.join(OUT, "anchor_v2.png"))
    diff = np.where((out != src).any(-1, keepdims=True), np.array([255, 0, 160], np.uint8), (src * 0.35).astype(np.uint8))
    Image.fromarray(diff, "RGB").save(os.path.join(OUT, "anchor_v2_diff.png"))
    log["board"] = {"orphans_before": orphan_pct(src), "orphans_after": orphan_pct(out),
                    "colours_before": int(len(ids(src)[0])), "colours_after": int(len(ids(out)[0])),
                    "changed_px": int((out != src).any(-1).sum()), "of_px": 96 * 96}
    log["script_wall_s"] = round(time.time() - t0, 1)
    with open(os.path.join(OUT, "m1_log.json"), "w") as f:
        json.dump(log, f, indent=1)
    print(json.dumps(log["board"]), "script", log["script_wall_s"], "s")
    for k, v in log["swatches"].items():
        print(k, {kk: (round(vv, 3) if isinstance(vv, float) else vv) for kk, vv in v.items()})


if __name__ == "__main__":
    main()
