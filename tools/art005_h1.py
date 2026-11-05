# ART-005 H1 (non-production): free preparation for the one controlled PixelLab Pro edit of the 32 px farmhouse.
#   python tools/art005_h1.py prep
# Writes under art/style_tests/ART-005/pl/g3/h1/:
#   valuepass.png  the M0 blockout (same labels, same alpha, same anchors) plus only the large value decisions of the
#                  H1 brief section 1: roof gradient and hip planes, 16 px course lines and lips, ridge cap, hip caps,
#                  fascia, eave shadow and its fade, 12 px lap lines and the wall's weathering gradient, foundation and
#                  chimney stone outlines, sill/door/chimney contact shadows, selective silhouette outline.
#                  No micro texture, no noise.
#   ref_c1.png / ref_v2.png  64 x 64: slate | timber over stone | window, 32 px cells cut from G1 board c1 and M1
#                  anchor_v2 (no leaves, wheat, soil or water).
# It imports M0's build_labels() and A; M0's own files are never written (checked by hash in the log).
import hashlib
import json
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

ROOT = m0.ROOT
G2 = m0.G2
H1 = os.path.join(ROOT, "pl", "g3", "h1")
W, H = m0.W, m0.H
LID = m0.LID


def hexc(h):
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.float64)


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()[:16]


def valuepass(lab):
    rgb = np.zeros((H, W, 3), np.float64)
    for n, h in m0.FLAT.items():
        rgb[lab == LID[n]] = hexc(h)
    f = np.ones((H, W))                      # multiplicative value factor per pixel
    yy, xx = np.mgrid[0:H, 0:W]
    is_ = lambda *ns: np.isin(lab, [LID[n] for n in ns])

    # roof front: lighter near the ridge, darker toward the eave, one more step in the bottom two courses
    front = is_("roof_front")
    t = np.clip((yy - 20) / 128.0, 0, 1)
    f[front] *= (1.14 - 0.24 * t)[front]
    f[front & (yy >= 116)] *= 0.94
    # course lines every 16 px (1 px seam + 2 px lip shadow); hips offset by 8 px so courses break at the hip line
    for sel, off in ((front, 0), (is_("roof_lhip"), 8), (is_("roof_rhip"), 8)):
        k = (yy - 20 - off) % 16
        f[sel & (k == 15)] *= 0.74
        f[sel & ((k == 13) | (k == 14))] *= 0.9
        f[sel & (k == 0)] *= 1.06
    # two large soft weathering patches (value only), east side and below the chimney
    for cx, cy, rx, ry in ((300, 76, 34, 14), (352, 120, 20, 16), (120, 128, 30, 10)):
        e = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
        sel = is_("roof_front", "roof_rhip", "roof_lhip") & (e < 1)
        f[sel] *= 0.9
    # ridge cap: lit top row, dark underside
    rc = is_("ridge_cap")
    f[rc & (yy <= 13)] *= 1.18
    f[rc & (yy >= 18)] *= 0.72
    # hip caps: lit on the west, dark on the east
    hl = is_("hip_line")
    rgb[hl & (xx < W // 2)] = hexc("a7b0b8")
    rgb[hl & (xx >= W // 2)] = hexc("323940")
    # fascia: solid lit board, dark lower edge
    fa = is_("fascia")
    f[fa & (yy == 148)] *= 1.22
    f[fa & (yy >= 154)] *= 0.8
    # wall: weathering gradient (silver-grey under the eave, warm in the middle, dark near the foundation)
    wall = is_("wall")
    grey = rgb.mean(axis=2, keepdims=True)
    mix = np.clip(1.0 - (yy - 160) / 50.0, 0, 1)[..., None] * 0.55
    rgb = np.where(wall[..., None], rgb * (1 - mix) + (grey * 1.04) * mix, rgb)
    f[wall & (yy >= 266)] *= 0.86
    # 12 px lap boards: shadow under the lap above, lit lower lip
    k = (yy - 160) % 12
    lap = wall | is_("corner_post")
    f[wall & (k == 0)] *= 0.72
    f[wall & (k == 1)] *= 0.88
    f[wall & (k == 11)] *= 1.1
    # two replaced boards, one value step off
    for bx0, bx1, row in ((40, 112, 3), (236, 330, 7)):
        f[wall & (xx >= bx0) & (xx < bx1) & ((yy - 160) // 12 == row) & (k >= 2)] *= 0.93
    # eave shadow fade over the wall's top 10 px
    fade = np.clip((yy - 160) / 10.0, 0, 1)
    f[lap & (yy < 170)] *= (0.55 + 0.45 * fade)[lap & (yy < 170)]
    # corner posts: lit west face
    cp = is_("corner_post")
    f[cp & ((xx == 16) | (xx == 17) | (xx == 360) | (xx == 361))] *= 1.15
    f[cp & ((xx == 23) | (xx == 367))] *= 0.8
    # sills: lit top, 3 px contact shadow on the wall below
    si = is_("sill")
    for w in m0.A["windows"]:
        y1 = w["y"][1]
        f[si & (yy == y1)] *= 1.2
        f[si & (yy == y1 + 4)] *= 0.8
        s = wall & (yy >= y1 + 5) & (yy < y1 + 8) & (xx >= w["x"][0] - 4) & (xx < w["x"][1] + 4)
        f[s] *= np.where(yy[s] == y1 + 5, 0.66, np.where(yy[s] == y1 + 6, 0.78, 0.9))
    # window frames: lit top/west, glass darker at the bottom, 2-3 px glints at the top-left of each pane
    wf = is_("window_frame")
    gl = is_("glass")
    for w in m0.A["windows"]:
        x0, x1 = w["x"]
        y0, y1 = w["y"]
        inside = (xx >= x0) & (xx < x1) & (yy >= y0) & (yy < y1)
        f[wf & inside & ((yy < y0 + 2) | (xx < x0 + 2))] *= 1.2
        f[wf & inside & ((yy >= y1 - 2) | (xx >= x1 - 2))] *= 0.78
        f[wf & inside & ((yy == y0 + 5) | (xx == x0 + 5))] *= 0.7       # inner bevel shadow
        f[gl & inside] *= (1.08 - 0.22 * np.clip((yy - y0 - 6) / 33.0, 0, 1))[gl & inside]
        cx, cy = w["centre"]
        for px0, py0 in ((x0 + 6, y0 + 6), (cx + 2, y0 + 6), (x0 + 6, cy + 2), (cx + 2, cy + 2)):
            for d in range(3):
                for yy0, xx0 in ((py0 + 2 + d, px0 + 5 - d), (py0 + 2 + d, px0 + 6 - d)):
                    if lab[yy0, xx0] == LID["glass"]:
                        rgb[yy0, xx0] = hexc("a9c0c4")
    # door: lit trim west/top, recessed leaf (dark top and east jamb), plank seams
    dx0, dx1 = m0.A["door"]["x"]
    dy0, dy1 = m0.A["door"]["y"]
    dt = is_("door_trim")
    f[dt & ((yy < dy0 - 4) | (xx < dx0 - 4))] *= 1.18
    f[dt & (xx >= dx1 + 4)] *= 0.8
    leaf = is_("door_leaf", "batten")
    for px in (dx0 + 13, dx0 + 25):
        f[is_("door_leaf") & (xx == px)] *= 0.7
    f[leaf & (yy < dy0 + 4)] *= 0.62
    f[leaf & (xx >= dx1 - 3)] *= 0.72
    f[is_("batten") & (yy == dy0 + 12)] *= 1.15
    f[is_("batten") & (yy == dy1 - 16)] *= 1.15
    # foundation: irregular stones in two courses, mortar seams, lit top edges, ground contact
    fo = is_("foundation")
    rng = np.random.default_rng(31)
    for ry0, ry1 in ((280, 289), (289, 298)):
        x = 16 - int(rng.integers(0, 8))
        f[fo & (yy == ry0)] *= 0.66
        f[fo & (yy == ry0 + 1)] *= 1.12
        while x < 368:
            x += int(rng.integers(10, 17))
            f[fo & (yy >= ry0) & (yy < ry1) & (xx == x)] *= 0.66
            f[fo & (yy > ry0) & (yy < ry1) & (xx == x + 1)] *= 1.1
    f[fo & (yy >= 296)] *= 0.78
    # chimney: lit west face, shaded east face, small stone courses, cap overhang shadow, flashing at the base
    ch = is_("chimney")
    c = m0.A["chimney"]
    f[ch & (xx < c["x"][0] + 7)] *= 1.12
    f[ch & (xx >= c["x"][1] - 7)] *= 0.8
    rng = np.random.default_rng(5)
    for ry0 in range(6, 52, 7):
        f[ch & (yy == ry0)] *= 0.7
        x = c["x"][0] - int(rng.integers(0, 6))
        while x < c["x"][1]:
            x += int(rng.integers(6, 11))
            f[ch & (yy >= ry0) & (yy < ry0 + 7) & (xx == x)] *= 0.72
    f[ch & (yy >= 6) & (yy < 9)] *= 0.62
    f[ch & (yy >= 48)] = 1.0
    rgb[ch & (yy >= 48)] = hexc("6f7880")
    f[ch & (yy == 48)] *= 1.15
    cc = is_("chimney_cap")
    f[cc & (yy <= 2)] *= 1.15
    # steps: lit tread fronts, darker risers
    st = is_("steps")
    for ty0 in (298, 309):
        f[st & (yy >= ty0) & (yy < ty0 + 3)] *= 1.14
        f[st & (yy >= ty0 + 8) & (yy < ty0 + 11)] *= 0.8

    rgb = np.clip(rgb * f[..., None], 0, 255)
    alpha = lab > 0
    # selective outline: one pixel inside the silhouette; lit (top/west) edges a darker step of their own colour,
    # bottom/east edges ink
    pad = np.pad(alpha, 1)
    up, dn = ~pad[:-2, 1:-1], ~pad[2:, 1:-1]
    lf, rt = ~pad[1:-1, :-2], ~pad[1:-1, 2:]
    edge = alpha & (up | dn | lf | rt)
    ink = hexc("2a2420")
    lit_edge = edge & (up | lf) & ~(dn | rt)
    rgb[lit_edge] = rgb[lit_edge] * 0.55
    rgb[edge & ~lit_edge] = ink
    out = np.zeros((H, W, 4), np.uint8)
    out[..., :3] = np.round(rgb).astype(np.uint8)
    out[..., 3] = np.where(alpha, 255, 0)
    out[~alpha, :3] = 0
    return out


def ref_crop(board):
    b = np.array(Image.open(board).convert("RGB"))
    sw = lambda r, c: b[r * 32:(r + 1) * 32, c * 32:(c + 1) * 32]
    top = np.concatenate([sw(0, 0), sw(0, 1)], axis=1)
    bot = np.concatenate([sw(0, 2), sw(2, 1)], axis=1)
    return np.concatenate([top, bot], axis=0)


def prep():
    os.makedirs(H1, exist_ok=True)
    m0_files = [os.path.join(G2, "m0", n) for n in ("blockout.png", "labels.png", "anchors.json")]
    before = {os.path.basename(p): sha(p) for p in m0_files}
    lab = m0.build_labels()
    stored = np.array(Image.open(os.path.join(G2, "m0", "labels.png")))
    assert (lab == stored).all(), "labels differ from M0"
    vp = valuepass(lab)
    blk = np.array(Image.open(os.path.join(G2, "m0", "blockout.png")).convert("RGBA"))
    assert ((vp[..., 3] > 0) == (blk[..., 3] > 0)).all(), "alpha differs from the M0 blockout"
    Image.fromarray(vp, "RGBA").save(os.path.join(H1, "valuepass.png"))
    Image.fromarray(ref_crop(os.path.join(ROOT, "pl", "anchors", "board_c1.png")), "RGB").save(
        os.path.join(H1, "ref_c1.png"))
    Image.fromarray(ref_crop(os.path.join(G2, "m1", "anchor_v2.png")), "RGB").save(os.path.join(H1, "ref_v2.png"))
    after = {os.path.basename(p): sha(p) for p in m0_files}
    log = {"m0_hashes_before": before, "m0_hashes_after": after, "m0_unchanged": before == after,
           "valuepass": {"size": [W, H], "opaque_px": int((vp[..., 3] > 0).sum()),
                         "colours": int(len(np.unique(vp[vp[..., 3] > 0][:, :3], axis=0))),
                         "alpha_identical_to_blockout": True, "labels_identical_to_m0": True,
                         "sha": sha(os.path.join(H1, "valuepass.png"))},
           "refs": {n: sha(os.path.join(H1, n)) for n in ("ref_c1.png", "ref_v2.png")}}
    with open(os.path.join(H1, "prep_log.json"), "w") as fh:
        json.dump(log, fh, indent=1)
    print(json.dumps(log, indent=1))


# --- Measurement (free) ------------------------------------------------------------------------------------------
#   python tools/art005_h1.py measure    -> h1/measure.json, printed; compares valuepass, M0 mockup, raw edit, snap
# Edge offsets: for each protected anchor edge, the luminance step summed along the edge is searched within +-8 px of
# its M0 position; the offset is where the strongest step is (0 = on the anchor). On the value pass it must be 0 for
# every edge, which validates the method. A ratio below ~1.6 (peak step / mean step in the window) means no clear
# edge was found there, so the offset is unreliable and the anchor counts as missing or blurred.
WIN = 8
EDGES = [  # name, axis ('x' = vertical edge at x, 'y' = horizontal edge at y), position, span along the edge
    ("door_opening_left", "x", 173, (236, 292)), ("door_opening_right", "x", 211, (236, 292)),
    ("door_opening_top", "y", 224, (178, 206)), ("door_trim_left", "x", 167, (224, 292)),
    ("door_trim_right", "x", 217, (224, 292)), ("door_trim_top", "y", 218, (172, 212)),
    ("winL_frame_left", "x", 74, (206, 243)), ("winL_frame_right", "x", 119, (206, 243)),
    ("winL_frame_top", "y", 202, (78, 115)), ("winL_frame_bottom", "y", 247, (78, 115)),
    ("winL_glass_left", "x", 80, (210, 239)), ("winL_glass_right", "x", 113, (210, 239)),
    ("winL_glass_top", "y", 208, (82, 111)), ("winL_glass_bottom", "y", 241, (82, 111)),
    ("winR_frame_left", "x", 264, (206, 243)), ("winR_frame_right", "x", 309, (206, 243)),
    ("winR_frame_top", "y", 202, (268, 305)), ("winR_frame_bottom", "y", 247, (268, 305)),
    ("winR_glass_left", "x", 270, (210, 239)), ("winR_glass_right", "x", 303, (210, 239)),
    ("winR_glass_top", "y", 208, (272, 301)), ("winR_glass_bottom", "y", 241, (272, 301)),
    ("steps_top", "y", 298, (168, 216)), ("steps_upper_left", "x", 164, (300, 308)),
    ("steps_upper_right", "x", 220, (300, 308)), ("steps_lower_left", "x", 160, (311, 319)),
    ("steps_lower_right", "x", 224, (311, 319)), ("steps_tread_split", "y", 309, (166, 218)),
    ("foundation_top_W", "y", 280, (28, 160)), ("foundation_top_E", "y", 280, (226, 356)),
    ("eave_line", "y", 160, (28, 356)), ("fascia_top", "y", 148, (28, 356)),
    ("ridge_cap_top", "y", 12, (80, 290)), ("ridge_cap_bottom", "y", 20, (80, 290)),
    ("chimney_left", "x", 300, (10, 46)), ("chimney_right", "x", 328, (10, 46)), ("chimney_cap_bottom", "y", 6, (302, 326)),
]


def lumi(im):
    a = im.astype(np.float64)
    return a[..., 0] * 0.299 + a[..., 1] * 0.587 + a[..., 2] * 0.114


def _prof(L, axis, pos, span, r):
    L = np.pad(L, r, mode="edge")
    pos, span = pos + r, (span[0] + r, span[1] + r)
    if axis == "x":
        return L[span[0]:span[1], pos - r:pos + r].mean(axis=0)
    return L[pos - r:pos + r, span[0]:span[1]].mean(axis=1)


def edge_offset(L, axis, pos, span, Lref):
    """Shift (px) of the edge-normal gradient profile of L against the same profile of the reference (the value pass,
    whose edges are M0's anchors by construction), searched in -WIN..WIN over a +-10 px window. Returns the shift and
    the normalised correlation at it (below ~0.5: no matching structure, i.e. the anchor is missing or redrawn)."""
    r = 10 + WIN + 1
    gt = np.diff(_prof(L, axis, pos, span, r))
    gr = np.diff(_prof(Lref, axis, pos, span, r))
    c0 = r - 1
    ref = gr[c0 - 10:c0 + 10]
    best = (-2.0, 0)
    for d in range(-WIN, WIN + 1):
        t = gt[c0 - 10 + d:c0 + 10 + d]
        a, b = ref - ref.mean(), t - t.mean()
        c = float((a * b).sum() / (np.sqrt((a * a).sum() * (b * b).sum()) + 1e-9))
        if c > best[0]:
            best = (c, d)
    return best[1], round(best[0], 2)


def period(sig, lo, hi):
    s = sig - sig.mean()
    ac = np.array([np.dot(s[:-k], s[k:]) / (np.dot(s, s) + 1e-9) for k in range(lo, hi + 1)])
    k = int(np.argmax(ac))
    return lo + k, float(ac[k])


def repetition(L, x0, x1, y0, y1):
    """Strongest normalised self-match of a block when shifted 8..64 px sideways and -24..24 px vertically:
    1.0 = an exact repeat (a tiled texture), ~0.3 or less = no repeating motif."""
    best = (0.0, 0, 0)
    blk = L[y0:y1, x0:x1]
    for dy in range(-24, 25, 2):
        for dx in range(8, 65):
            yy0, yy1 = y0 + dy, y1 + dy
            if yy0 < 0 or yy1 > L.shape[0] or x1 + dx > L.shape[1]:
                continue
            o = L[yy0:yy1, x0 + dx:x1 + dx]
            a, b = blk - blk.mean(), o - o.mean()
            c = float((a * b).sum() / (np.sqrt((a * a).sum() * (b * b).sum()) + 1e-9))
            if c > best[0]:
                best = (c, dx, dy)
    return best


def noise(L, mask):
    from numpy.lib.stride_tricks import sliding_window_view
    p = np.pad(L, 1, mode="edge")
    box = sliding_window_view(p, (3, 3)).mean(axis=(2, 3))
    return float(np.abs(L - box)[mask].mean())


def fmt(im):
    a = im[..., 3]
    op = a > 0
    rgb = im[..., :3].astype(np.int32)
    key = (rgb[..., 0] << 16) | (rgb[..., 1] << 8) | rgb[..., 2]
    key = np.where(op, key, -1)
    p = np.pad(key, 1, constant_values=-2)
    same = np.zeros(key.shape, bool)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dy or dx:
                same |= p[1 + dy:1 + dy + key.shape[0], 1 + dx:1 + dx + key.shape[1]] == key
    return {"colours": int(len(np.unique(key[op]))), "partial_alpha_px": int(((a > 0) & (a < 255)).sum()),
            "orphan_pct": round(float((op & ~same).sum() / op.sum() * 100), 2)}


def measure_one(im, lab, m0_alpha, Lref):
    L = lumi(im)
    r = {"edges": {}}
    for n, ax, pos, span in EDGES:
        off, ratio = edge_offset(L, ax, pos, span, Lref)
        r["edges"][n] = {"offset_px": off, "match": ratio}
    op = im[..., 3] > 0
    r["silhouette"] = {"px_added": int((op & ~m0_alpha).sum()), "px_removed": int((~op & m0_alpha).sum()),
                       "iou": round(float((op & m0_alpha).sum() / (op | m0_alpha).sum()), 4)}
    # wall base: lowest opaque row per column outside the steps
    cols = [x for x in range(24, 360) if not 156 <= x < 228]
    base = [int(np.nonzero(op[:, x])[0].max()) if op[:, x].any() else -1 for x in cols]
    r["silhouette"]["wall_base_y_median"] = int(np.median(base)) + 1
    r["silhouette"]["wall_base_y_range"] = [min(base) + 1, max(base) + 1]
    ys = range(170, 290)
    r["silhouette"]["wall_west_x_median"] = int(np.median([np.nonzero(op[y])[0].min() for y in ys if op[y].any()]))
    r["silhouette"]["wall_east_x_median"] = int(np.median([np.nonzero(op[y])[0].max() for y in ys if op[y].any()])) + 1
    # periods
    roof_rows = L[24:144, 120:270].mean(axis=1)
    r["roof_course_period"] = dict(zip(("px", "strength"), period(roof_rows, 6, 32)))
    wall_rows = np.concatenate([L[172:276, 30:66], L[172:276, 322:356]], axis=1).mean(axis=1)
    r["wall_lap_period"] = dict(zip(("px", "strength"), period(wall_rows, 6, 30)))
    c, dx, dy = repetition(L, 120, 184, 40, 104)
    r["roof_repetition"] = {"max_self_match": round(c, 3), "at_dx": dx, "at_dy": dy}
    c, dx, dy = repetition(L, 28, 68, 172, 196)
    r["wall_repetition"] = {"max_self_match": round(c, 3), "at_dx": dx, "at_dy": dy}
    is_ = lambda *ns: np.isin(lab, [LID[n] for n in ns])
    r["noise_by_surface"] = {k: round(noise(L, is_(*v)), 2) for k, v in
                             {"roof": ("roof_front", "roof_lhip", "roof_rhip"), "wall": ("wall",),
                              "foundation": ("foundation",), "door_windows": ("window_frame", "glass", "door_leaf",
                                                                              "door_trim")}.items()}
    r["mean_lum"] = {k: round(float(L[is_(*v)].mean()), 1) for k, v in
                     {"roof": ("roof_front", "roof_lhip", "roof_rhip"), "wall": ("wall",),
                      "eave_band_160_164": None}.items() if v}
    r["mean_lum"]["wall_top_160_166"] = round(float(L[160:166, 30:356][op[160:166, 30:356]].mean()), 1)
    r["mean_lum"]["wall_mid_200_240_clear"] = round(float(L[200:240, 28:66].mean()), 1)
    r["format"] = fmt(im)
    return r


def post(raw, lab):
    """Free technical adjustment: M0's exact alpha. Pixels the edit made transparent inside M0's silhouette are
    filled from the nearest opaque raw pixel on the same row; pixels it added outside are cut. Nothing else."""
    m0a = lab > 0
    out = raw.copy()
    out[..., 3] = np.where(m0a, 255, 0)
    out[~m0a, :3] = 0
    fill = m0a & (raw[..., 3] == 0)
    for y, x in zip(*np.nonzero(fill)):
        row = np.nonzero(raw[y, :, 3] > 0)[0]
        if len(row):
            out[y, x, :3] = raw[y, row[np.argmin(np.abs(row - x))], :3]
    return out, int(fill.sum()), int(((raw[..., 3] > 0) & ~m0a).sum())


def night(day, lab):
    """Night = day + an emissive layer from M0's glass mask (the harness applies the night grade). Glass pixels are
    mapped by their luminance rank to the E0 lantern ramp; mullions stay dark."""
    g = lab == LID["glass"]
    L = lumi(day)
    out = day.copy()
    v = L[g]
    q = np.argsort(np.argsort(v)) / max(len(v) - 1, 1)
    cols = np.array([m0.LANTERN[min(int(qq * 5), 4)] if qq > 0.1 else m0.LANTERN[0] for qq in q])
    out[g, :3] = cols
    em = np.zeros_like(day)
    em[g] = out[g]
    return out, em


def measure():
    lab = np.array(Image.open(os.path.join(G2, "m0", "labels.png")))
    m0a = lab > 0
    raw = np.array(Image.open(os.path.join(H1, "raw_edit.png")).convert("RGBA"))
    snap, filled, cut = post(raw, lab)
    Image.fromarray(snap, "RGBA").save(os.path.join(H1, "h1_snap_day.png"))
    nt, em = night(snap, lab)
    Image.fromarray(nt, "RGBA").save(os.path.join(H1, "h1_snap_night.png"))
    Image.fromarray(em, "RGBA").save(os.path.join(H1, "h1_emissive.png"))
    g3 = os.path.join(ROOT, "pl", "g3", "32")
    os.makedirs(g3, exist_ok=True)
    Image.fromarray(snap, "RGBA").save(os.path.join(g3, "house_day.png"))
    Image.fromarray(nt, "RGBA").save(os.path.join(g3, "house_night.png"))
    ims = {"valuepass": os.path.join(H1, "valuepass.png"), "m0_mockup": os.path.join(G2, "32", "house_day.png"),
           "raw_edit": os.path.join(H1, "raw_edit.png"), "h1_snap": os.path.join(H1, "h1_snap_day.png")}
    Lref = lumi(np.array(Image.open(ims["valuepass"]).convert("RGBA")))
    vp = np.array(Image.open(ims["valuepass"]).convert("RGBA"))
    res = {k: measure_one(np.array(Image.open(p).convert("RGBA")), lab, m0a, Lref) for k, p in ims.items()}
    # method check: the value pass shifted 3 px right and 2 px down must read +3 on x edges, +2 on y edges
    sh = np.roll(np.roll(vp, 3, axis=1), 2, axis=0)
    chk = measure_one(sh, lab, m0a, Lref)["edges"]
    res["method_check_shift_x3_y2"] = {n: e["offset_px"] for n, e in chk.items()}
    diff = np.abs(snap[..., :3].astype(int) - raw[..., :3].astype(int)).sum(axis=2) > 0
    res["adjustment"] = {"alpha_snap_filled_px": filled, "alpha_snap_cut_px": cut,
                         "rgb_px_changed_inside_m0_alpha": int((diff & m0a).sum()),
                         "pct_of_house": round(float((diff & m0a).sum() / m0a.sum() * 100), 2),
                         "raw_sha": sha(os.path.join(H1, "raw_edit.png"))}
    with open(os.path.join(H1, "measure.json"), "w") as fh:
        json.dump(res, fh, indent=1)
    # compact print
    for k in ("valuepass", "m0_mockup", "raw_edit", "h1_snap"):
        r = res[k]
        bad = {n: (e["offset_px"], e["match"]) for n, e in r["edges"].items() if e["offset_px"] != 0 or e["match"] < 0.5}
        print("==", k, "silhouette", r["silhouette"], "\n  course", r["roof_course_period"], "lap", r["wall_lap_period"],
              "\n  roof_rep", r["roof_repetition"], "wall_rep", r["wall_repetition"],
              "\n  noise", r["noise_by_surface"], "lum", r["mean_lum"], "\n  fmt", r["format"],
              "\n  edges off/unclear:", bad)
    print("adjust", res["adjustment"])
    print("method check (expect x:3, y:2):", res["method_check_shift_x3_y2"])


if __name__ == "__main__":
    {"prep": prep, "measure": measure}[sys.argv[1]]()
