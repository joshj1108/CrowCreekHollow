# ART-005 M0 (non-production): the complete 32 px farmhouse blockout and a no-credit mockup built from it.
# Every edge comes from the game's anchors (scripts/farm_layout.gd, main.gd HOUSE_SPRITE_*, estate_system.gd
# _draw_outside), scaled to 32 art px per tile. One label map is the single source of truth: it is written as the
# flat blockout, as region masks, and then "skinned" with materials sampled from the frozen G1 style board c1
# (pl/anchors/board_c1.png, read only). No generation; G1 files are never written.
#   python tools/art005_m0.py [--mat c1|v2]
# --mat v2 skins the same blockout with M1's anchor_v2 instead (comparison only, written with a _v2mat suffix).
# Writes under art/style_tests/ART-005/pl/g2/: m0/ (blockout, masks, anchors.json) and 32/ (harness files).
import argparse
import json
import os

import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-005")
G2 = os.path.join(ROOT, "pl", "g2")
W, H = 384, 320
T = 32

# --- Anchors (art px at 32 px per tile; x right, y down from the sprite's top-left) ----------------------------
# Sprite: 12 x 10 tiles, left edge 0.5 tile west of the footprint (HOUSE_SPRITE_OFFSET_X = -0.5), walls ending
# 9.3125 tiles below its top (HOUSE_WALL_BOTTOM_TILES). Footprint: map rows 5-9 roof (O), 10-11 walls (H, D at
# column 24), porch row 12 (P R P). The sprite's top is 2.3125 tiles above the footprint's top row.
A = {
    "canvas": [W, H],
    "tile": T,
    "footprint": {"x": [16, 368], "roof_rows_y": [74, 234], "wall_rows_y": [234, 298], "porch_row_y": [298, 330]},
    "overhang": {"west": [0, 16], "east": [368, 384]},
    "roof": {"ridge_y": 20, "ridge_cap_y": [12, 20], "ridge_x": [64, 320], "hip_back_corner_y": 60,
             "shingle_y": [20, 148], "course": 16, "eave_band_y": [148, 160], "eave_y": 160},
    "chimney": {"x": [300, 328], "y": [0, 52], "cap_x": [297, 331], "cap_y": [0, 6]},
    "wall": {"x": [16, 368], "y": [160, 298], "plank": 12, "posts_x": [[16, 24], [360, 368]]},
    "foundation_y": [280, 298],
    "door": {"x": [173, 211], "y": [224, 298], "centre_x": 192, "trim": 6},
    "steps": {"x": [164, 220], "y": [298, 320], "tread2_x": [160, 224], "tread_split_y": 309},
    "windows": [{"x": [74, 119], "y": [202, 247], "centre": [96, 224]},
                {"x": [264, 309], "y": [202, 247], "centre": [286, 224]}],
    "door_lamp": {"x": [224, 232], "y": [228, 242]},
    # production extension geometry, from estate_system.gd _draw_outside with rect = 384 x 320, px = 32
    "dormer_zone_production": {"wall": [96, 96, 288, 124.8], "gable_apex": [192, 60.8], "outline_grow": 2,
                               "windows": [[134.4, 102.4, 150.4, 116.8], [220.8, 102.4, 236.8, 116.8]]},
    "porch_production": {"deck": [16, 315.6, 368, 328.4], "roof": [9.6, 286.8, 374.4, 293.84],
                         "posts": [[19, 293.84, 23, 315.6], [361, 293.84, 365, 315.6]]},
    # lights, as centres in sprite px
    "lights": {
        "intended_HOUSE_SPRITE_WINDOWS": [[96.0, 224.0], [286.08, 224.0]],
        "production_measured": [[96.0, 298.0], [286.08, 298.0]],
        "production_measured_with_spill": [[96.0, 330.0], [286.08, 330.0]],
        "e1_harness": [[92.8, 230.4], [291.2, 230.4]],
    },
}

# Region labels. Draw order below is back to front.
L_NAMES = ["empty", "roof_lhip", "roof_front", "roof_rhip", "ridge_cap", "hip_line", "fascia", "eave_shadow",
           "chimney", "chimney_cap", "wall", "corner_post", "foundation", "window_frame", "glass", "mullion", "sill",
           "door_trim", "door_leaf", "batten", "steps", "door_lamp", "lamp_glass", "knob", "chimney_shadow"]
LID = {n: i for i, n in enumerate(L_NAMES)}
FLAT = {  # blockout plane colours: lit / front / shaded steps of a neutral ramp per material
    "roof_lhip": "7a8590", "roof_front": "5d6873", "roof_rhip": "434c56", "ridge_cap": "8d98a2",
    "hip_line": "9aa4ad", "fascia": "8a6a4c", "eave_shadow": "2a2420", "chimney": "807a70",
    "chimney_cap": "a29c90", "wall": "a58a66", "corner_post": "7e5a36", "foundation": "6e6a62",
    "window_frame": "6b4b33", "glass": "4e6f7a", "mullion": "4a3526", "sill": "8a6a4c", "door_trim": "6b4b33",
    "door_leaf": "5c4128", "batten": "4a3526", "steps": "8a867a", "door_lamp": "2a1f18", "lamp_glass": "c8a868",
    "knob": "d0a040", "chimney_shadow": "38404a"}


def build_labels():
    img = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(img)
    r = lambda n, x0, y0, x1, y1: d.rectangle([x0, y0, x1 - 1, y1 - 1], fill=LID[n])
    ro = A["roof"]
    rx0, rx1 = ro["ridge_x"]
    ry, by, ey = ro["ridge_y"], ro["hip_back_corner_y"], ro["eave_band_y"][0]
    # roof planes: the front plane is the trapezoid ridge -> eave; the hips are the triangles outside it
    d.polygon([(rx0, ry), (rx1, ry), (W - 2, ey - 1), (1, ey - 1)], fill=LID["roof_front"])
    d.polygon([(rx0, ry), (1, by), (1, ey - 1)], fill=LID["roof_lhip"])
    d.polygon([(rx1, ry), (W - 2, by), (W - 2, ey - 1)], fill=LID["roof_rhip"])
    d.line([(rx0, ry), (1, ey - 1)], fill=LID["hip_line"], width=2)
    d.line([(rx1, ry), (W - 2, ey - 1)], fill=LID["hip_line"], width=2)
    r("ridge_cap", rx0 - 4, ro["ridge_cap_y"][0], rx1 + 4, ro["ridge_cap_y"][1])
    r("fascia", 1, 148, W - 1, 156)
    r("eave_shadow", 1, 156, W - 1, 160)
    # chimney (east of the production dormer zone, x 94-290) and its cast shadow on the roof (light upper left)
    c = A["chimney"]
    d.polygon([(c["x"][1], 8), (c["x"][1] + 7, 12), (c["x"][1] + 7, c["y"][1] + 2), (c["x"][1], c["y"][1])],
              fill=LID["chimney_shadow"])
    r("chimney", c["x"][0], c["cap_y"][1], c["x"][1], c["y"][1])
    r("chimney_cap", c["cap_x"][0], 1, c["cap_x"][1], c["cap_y"][1])
    # walls
    r("wall", 16, 160, 368, 298)
    for x0, x1 in A["wall"]["posts_x"]:
        r("corner_post", x0, 160, x1, 298)
    r("foundation", 16, 280, 368, 298)
    # windows: 45 x 45, 6 px frame, 3 px mullions on the exact centre column/row, sill below
    for w in A["windows"]:
        x0, x1 = w["x"]
        y0, y1 = w["y"]
        r("sill", x0 - 4, y1, x1 + 4, y1 + 5)
        r("window_frame", x0, y0, x1, y1)
        r("glass", x0 + 6, y0 + 6, x1 - 6, y1 - 6)
        cx, cy = w["centre"]
        r("mullion", cx - 1, y0 + 6, cx + 2, y1 - 6)
        r("mullion", x0 + 6, cy - 1, x1 - 6, cy + 2)
    # door: 38 x 74 opening, 6 px trim outside it, three planks, two battens, a knob; the restored-stage lamp
    dx0, dx1 = A["door"]["x"]
    dy0, dy1 = A["door"]["y"]
    r("door_trim", dx0 - 6, dy0 - 6, dx1 + 6, dy1)
    r("door_leaf", dx0, dy0, dx1, dy1)
    r("batten", dx0, dy0 + 12, dx1, dy0 + 16)
    r("batten", dx0, dy1 - 16, dx1, dy1 - 12)
    r("knob", dx1 - 8, 262, dx1 - 6, 264)
    lx0, lx1 = A["door_lamp"]["x"]
    ly0, ly1 = A["door_lamp"]["y"]
    r("door_lamp", lx0, ly0, lx1, ly1)
    r("lamp_glass", lx0 + 2, ly0 + 4, lx1 - 2, ly1 - 3)
    # steps: two treads centred on the door, inside the porch row's top 22 px (the canvas ends at y 320)
    s = A["steps"]
    r("steps", s["tread2_x"][0], s["tread_split_y"], s["tread2_x"][1], s["y"][1])
    r("steps", s["x"][0], s["y"][0], s["x"][1], s["tread_split_y"])
    return np.array(img)


# --- Materials ---------------------------------------------------------------------------------------------------

def lum(rgb):
    rgb = rgb.astype(np.float64)
    return rgb[..., 0] * 0.299 + rgb[..., 1] * 0.587 + rgb[..., 2] * 0.114


class Mat:
    """A material sampled from a 32 x 32 G1 swatch: its pixels, and its colours sorted by luminance with their
    frequency, so tone(q) returns the swatch colour at luminance percentile q (always an existing G1 colour)."""

    def __init__(self, px):
        self.px = px
        flat = px.reshape(-1, 3)
        cols, counts = np.unique(flat, axis=0, return_counts=True)
        order = np.argsort(lum(cols))
        self.cols = cols[order]
        self.cum = np.cumsum(counts[order]) / counts.sum()
        lq = {}
        for i, c in enumerate(self.cols):
            lq[tuple(c)] = (self.cum[i] - counts[order][i] / counts.sum() * 0.5)
        self.q_of = lq

    def tone(self, q):
        q = min(max(q, 0.0), 1.0)
        return self.cols[min(int(np.searchsorted(self.cum, q)), len(self.cols) - 1)]

    def sample(self, y, x):
        return self.px[y % self.px.shape[0], x % self.px.shape[1]]

    def q(self, c):
        return self.q_of[tuple(c)]


def load_mats(board):
    b = np.array(Image.open(board).convert("RGB"))
    sw = lambda r, c: b[r * 32:(r + 1) * 32, c * 32:(c + 1) * 32]
    m = {"slate": Mat(sw(0, 0)), "timber": Mat(sw(0, 1)), "stone": Mat(sw(0, 2)), "window": Mat(sw(2, 1)),
         "timber_h": Mat(np.ascontiguousarray(np.rot90(sw(0, 1))))}
    win = sw(2, 1)
    frame = np.concatenate([win[:5].reshape(-1, 3), win[-5:].reshape(-1, 3), win[:, :5].reshape(-1, 3),
                            win[:, -5:].reshape(-1, 3)])
    m["trim"] = Mat(frame.reshape(-1, 1, 3))
    inner = win[6:26, 6:26].reshape(-1, 3)
    glass = inner[(inner[:, 2].astype(int) > inner[:, 0].astype(int) + 6)]
    m["glass"] = Mat(glass.reshape(-1, 1, 3))
    m["ink"] = b.reshape(-1, 3)[np.argmin(lum(b.reshape(-1, 3)))]
    return m


LANTERN = [np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], np.uint8)
           for h in ["8a3a12", "d97a22", "f4b850", "f6c45a", "fff0c0"]]   # e0 palette lantern ramp


def is_moss(c):
    return int(c[1]) > int(c[0]) + 6 and int(c[1]) >= int(c[2])


def render(lab, m, seed=7):
    rng = np.random.default_rng(seed)
    out = np.zeros((H, W, 4), np.uint8)
    night_mask = np.zeros((H, W), bool)
    slate, tim, timh, stone, trim, glass = m["slate"], m["timber"], m["timber_h"], m["stone"], m["trim"], m["glass"]
    plank_joints = {}
    for row in range(0, 12):
        xs, x = [], 24 + int(rng.integers(0, 60))
        while x < 360:
            xs.append(x)
            x += int(rng.integers(64, 120))
        plank_joints[row] = (xs, int(rng.integers(0, 32)), int(rng.integers(0, 32)))
    course_joints = []
    for ci in range(9):
        js, x = [], -int(rng.integers(0, 24))
        while x < W + 30:
            js.append(x)
            x += int(rng.integers(18, 30))
        course_joints.append(np.array(js))
    ys, xs = np.nonzero(lab)
    for y, x in zip(ys, xs):
        n = L_NAMES[lab[y, x]]
        c = None
        if n in ("roof_lhip", "roof_front", "roof_rhip"):
            s = {"roof_lhip": 1, "roof_front": 0, "roof_rhip": -1}[n]
            ci, rr = (y - 20) // 16, (y - 20) % 16
            joints = course_joints[ci % len(course_joints)]
            k = int(np.searchsorted(joints, x, side="right"))
            j0 = joints[k - 1] if k > 0 else -40
            sid, col = k + ci * 31, x - j0
            if y < 20:
                c = slate.tone(0.3 + 0.25 * s)
            elif rr == 0:
                c = slate.tone(0.82 + 0.12 * s)
            elif rr == 13:
                c = slate.tone(0.12 + 0.06 * s)
            elif rr >= 14:
                c = slate.tone(0.03)
            elif col <= 1:
                c = slate.tone(0.04 if col == 0 else 0.2 + 0.1 * s)
            else:
                t = slate.sample(rr + sid * 5, col + sid * 11)
                c = t if is_moss(t) else slate.tone(0.42 + 0.3 * slate.q(t) + 0.22 * s)
        elif n == "hip_line":
            c = slate.tone(0.88) if x < W // 2 else slate.tone(0.4)
        elif n == "ridge_cap":
            rr = y - 12
            c = slate.tone(0.98 if rr <= 1 else (0.6 if rr <= 5 else 0.12))
        elif n == "chimney_shadow":
            t = slate.sample(y, x)
            c = slate.tone(0.06 + 0.12 * slate.q(t))
        elif n == "fascia":
            rr = y - 148
            c = trim.tone(0.92 if rr <= 1 else (0.55 if rr <= 6 else 0.12))
        elif n == "eave_shadow":
            c = m["ink"] if y >= 158 else trim.tone(0.03)
        elif n in ("chimney", "foundation", "steps"):
            t = stone.sample(y + (3 if n == "foundation" else 0), x + (5 if n == "steps" else 0))
            q = stone.q(t)
            if n == "chimney" and x >= 320:
                q -= 0.25
            if n == "steps" and (y in (298, 299, 309, 310)):
                q = max(q, 0.85)
            if n == "foundation" and y == 280:
                q = 0.02
            c = stone.tone(q)
        elif n == "chimney_cap":
            c = stone.tone(0.95 if y <= 1 else (0.7 if y <= 3 else 0.15))
        elif n == "wall":
            row, rr = (y - 160) // 12, (y - 160) % 12
            joints, oy, ox = plank_joints[row]
            jd = min((abs(x - j) for j in joints), default=99)
            under_eave = -0.25 if y < 166 else 0.0
            if rr == 0:
                c = timh.tone(0.82 + under_eave)
            elif rr >= 10:
                c = timh.tone(0.03 if rr == 11 else 0.12)
            elif jd == 0:
                c = timh.tone(0.03)
            elif jd == 1 and any(x - j == 1 for j in joints):
                c = timh.tone(0.14)
            else:
                t = timh.sample(rr + oy, x + ox)
                c = timh.tone(0.32 + 0.45 * timh.q(t) + under_eave)
        elif n == "corner_post":
            px = x - (16 if x < 192 else 360)
            c = trim.tone(0.88 if px <= 1 else (0.5 if px <= 5 else 0.18))
        elif n in ("window_frame", "door_trim", "sill"):
            box = None
            if n == "door_trim":
                box = (167, 218, 217, 298)
            else:
                for w in A["windows"]:
                    if w["x"][0] - 4 <= x < w["x"][1] + 4 and w["y"][0] <= y < w["y"][1] + 5:
                        box = (w["x"][0], w["y"][0], w["x"][1], w["y"][1]) if n == "window_frame" else \
                              (w["x"][0] - 4, w["y"][1], w["x"][1] + 4, w["y"][1] + 5)
            x0, y0, x1, y1 = box
            if n == "sill":
                rr = y - y0
                c = trim.tone(0.92 if rr <= 1 else (0.5 if rr <= 3 else 0.08))
            else:
                l, t_, rgt, b = x - x0, y - y0, x1 - 1 - x, y1 - 1 - y
                if min(l, t_, rgt, b) == 0:
                    c = m["ink"]
                elif min(l, t_, rgt, b) == 5 and n == "window_frame":
                    c = trim.tone(0.04)
                elif l <= 1 or t_ <= 1:
                    c = trim.tone(0.9)
                elif rgt <= 1 or b <= 1:
                    c = trim.tone(0.15)
                else:
                    c = trim.tone(0.55)
        elif n == "mullion":
            c = trim.tone(0.3)
        elif n == "glass":
            night_mask[y, x] = True
            for w in A["windows"]:
                if w["x"][0] <= x < w["x"][1] and w["y"][0] <= y < w["y"][1]:
                    gx0, gy0 = w["x"][0] + 6, w["y"][0] + 6
            cxp, cyp = A["windows"][0]["centre"][0] - A["windows"][0]["x"][0], 0
            px, py = x - gx0, y - gy0
            # pane-local coordinates (panes 15 px, mullion 3 px)
            lx, ly = px % 18, py % 18
            if ly <= 1:
                c = glass.tone(0.05)
            elif 2 <= lx <= 3 and 3 <= ly <= 4:
                c = glass.tone(0.99)
            elif 9 <= (lx + ly) <= 11:
                c = glass.tone(0.85)
            elif (lx + ly) >= 22:
                c = glass.tone(0.18)
            else:
                c = glass.tone(0.45)
        elif n == "door_leaf":
            px = x - 173
            plank = px // 13
            lx = px % 13
            if lx == 12 or px == 37:
                c = tim.tone(0.03)
            elif lx == 0:
                c = tim.tone(0.75)
            else:
                t = tim.sample(y + plank * 9, x + plank * 5)
                c = tim.tone(0.15 + 0.45 * tim.q(t))
            if y >= 296:
                c = m["ink"]
        elif n == "batten":
            rr = y - (236 if y < 260 else 282)
            c = tim.tone(0.8 if rr == 0 else (0.45 if rr <= 2 else 0.05))
        elif n == "knob":
            c = LANTERN[1]
        elif n == "door_lamp":
            c = m["ink"]
        elif n == "lamp_glass":
            night_mask[y, x] = True
            c = glass.tone(0.7 if y < 236 else 0.4)
        out[y, x, :3] = c
        out[y, x, 3] = 255
    # outer outline: every transparent pixel touching the house becomes ink, except below the steps
    op = out[..., 3] > 0
    nb = np.zeros_like(op)
    nb[1:] |= op[:-1]
    nb[:-1] |= op[1:]
    nb[:, 1:] |= op[:, :-1]
    nb[:, :-1] |= op[:, 1:]
    edge = nb & ~op
    out[edge, :3] = m["ink"]
    out[edge, 3] = 255
    return out, night_mask


def night_of(day, mask, m):
    out = day.copy()
    g = m["glass"]
    ys, xs = np.nonzero(mask)
    for y, x in zip(ys, xs):
        q = g.q(day[y, x, :3])
        out[y, x, :3] = LANTERN[min(int(q * 5), 4)] if q > 0.1 else LANTERN[0]
    em = np.zeros_like(day)
    em[mask] = out[mask]
    return out, em


def blockout(lab):
    out = np.zeros((H, W, 4), np.uint8)
    for i, n in enumerate(L_NAMES):
        if i == 0:
            continue
        sel = lab == i
        out[sel, :3] = [int(FLAT[n][k:k + 2], 16) for k in (0, 2, 4)]
        out[sel, 3] = 255
    return out


# --- Extensions (separate layers, never baked into the house) ------------------------------------------------------
# Dormer: the production second-storey geometry (estate_system.gd), skinned in the same materials.
# Porch: a PROPOSED 32 px porch, kept inside the porch row (deck) and under the eave (shed roof), clear of the door
# opening, the windows and the steps' centre line. Its canvas is 384 x 336 (16 px taller than the house) so the deck's
# front edge and outline fit; it shares the house's top-left origin.
EXT = {
    "dormer": {"wall": [96, 96, 288, 125], "apex": [192, 61], "windows": [[134, 102, 150, 117], [221, 102, 237, 117]]},
    "porch": {"canvas": [384, 336], "roof": [4, 164, 380, 194], "fascia": [4, 194, 380, 200],
              "posts": [[24, 32], [136, 144], [240, 248], [352, 360]], "post_y": [200, 322],
              "deck": [20, 298, 364, 322], "deck_front": [20, 322, 364, 330], "step": [164, 322, 220, 330]},
}


def _outline(out, ink):
    op = out[..., 3] > 0
    nb = np.zeros_like(op)
    nb[1:] |= op[:-1]
    nb[:-1] |= op[1:]
    nb[:, 1:] |= op[:, :-1]
    nb[:, :-1] |= op[:, 1:]
    e = nb & ~op
    out[e, :3] = ink
    out[e, 3] = 255


def render_ext(m):
    slate, timh, trim, glass, stone = m["slate"], m["timber_h"], m["trim"], m["glass"], m["stone"]
    res = {}
    # dormer
    out = np.zeros((H, W, 4), np.uint8)
    em = np.zeros((H, W), bool)
    dz = EXT["dormer"]
    x0, y0, x1, y1 = dz["wall"]
    ax, ay = dz["apex"]
    tri = Image.new("L", (W, H), 0)
    ImageDraw.Draw(tri).polygon([(x0, y0 - 1), (x1 - 1, y0 - 1), (ax, ay)], fill=1)
    tri = np.array(tri) > 0
    for y in range(H):
        for x in range(W):
            c = None
            if x0 <= x < x1 and y0 <= y < y1:
                rr = (y - y0) % 12
                if any(wx0 <= x < wx1 and wy0 <= y < wy1 for wx0, wy0, wx1, wy1 in dz["windows"]):
                    wx0, wy0, wx1, wy1 = next(w for w in dz["windows"] if w[0] <= x < w[2] and w[1] <= y < w[3])
                    if x in (wx0, wx1 - 1) or y in (wy0, wy1 - 1):
                        c = trim.tone(0.2)
                    else:
                        em[y, x] = True
                        c = glass.tone(0.85 if (x - wx0 + y - wy0) in (6, 7) else 0.45)
                elif x - x0 <= 1:
                    c = trim.tone(0.85)
                elif x1 - 1 - x <= 1:
                    c = trim.tone(0.15)
                elif rr == 0:
                    c = timh.tone(0.8)
                elif rr >= 10:
                    c = timh.tone(0.05)
                else:
                    c = timh.tone(0.3 + 0.45 * timh.q(timh.sample(y, x)))
            elif tri[y, x]:
                # rake edges: 3 px trim along each sloping side; inside, slate in 8 px courses (a small gable)
                lft = (x - x0) * (y0 - ay) / (ax - x0) if x <= ax else (x1 - x) * (y0 - ay) / (x1 - ax)
                if (y0 - 1 - y) > lft - 3:
                    c = trim.tone(0.9 if x <= ax else 0.2)
                elif y >= y0 - 3:
                    c = trim.tone(0.12)
                else:
                    rr = (y - ay) % 8
                    c = slate.tone(0.85) if rr == 0 else (slate.tone(0.06) if rr == 7 else
                        slate.tone(0.4 + 0.3 * slate.q(slate.sample(y, x)) + (0.1 if x <= ax else -0.1)))
            if c is not None:
                out[y, x, :3] = c
                out[y, x, 3] = 255
    _outline(out, m["ink"])
    night = out.copy()
    ys, xs = np.nonzero(em)
    for y, x in zip(ys, xs):
        night[y, x, :3] = LANTERN[min(int(glass.q(out[y, x, :3]) * 5), 4)]
    res["ext_dormer_day"], res["ext_dormer_night"] = out, night
    # porch
    pz = EXT["porch"]
    cw, ch = pz["canvas"]
    out = np.zeros((ch, cw, 4), np.uint8)
    for y in range(ch):
        for x in range(cw):
            c = None
            inr = lambda r: r[0] <= x < r[2] and r[1] <= y < r[3]
            if inr(pz["roof"]):
                rr = (y - pz["roof"][1]) % 16
                c = slate.tone(0.82) if rr == 0 else (slate.tone(0.12) if rr == 13 else (slate.tone(0.03) if rr >= 14
                    else slate.tone(0.42 + 0.3 * slate.q(slate.sample(rr + x // 22 * 5, x)))))
                if (x + (y - 164) // 16 * 11) % 22 in (0, 1) and 1 <= rr <= 12:
                    c = slate.tone(0.04)
            elif inr(pz["fascia"]):
                rr = y - pz["fascia"][1]
                c = trim.tone(0.92 if rr <= 1 else (0.5 if rr <= 3 else 0.1))
            elif any(px0 <= x < px1 for px0, px1 in pz["posts"]) and pz["post_y"][0] <= y < pz["post_y"][1]:
                px0 = next(p0 for p0, p1 in pz["posts"] if p0 <= x < p1)
                lx = x - px0
                c = trim.tone(0.88 if lx <= 1 else (0.5 if lx <= 5 else 0.15))
            elif inr(pz["step"]):
                c = stone.tone(max(stone.q(stone.sample(y, x)), 0.85 if y <= 323 else 0))
            elif inr(pz["deck"]):
                rr = (y - 298) % 6
                c = timh.tone(0.78) if rr == 0 else (timh.tone(0.06) if rr == 5 else
                    timh.tone(0.35 + 0.4 * timh.q(timh.sample(rr + y // 6 * 7, x + y // 6 * 13))))
            elif inr(pz["deck_front"]):
                rr = y - 322
                c = trim.tone(0.75 if rr == 0 else (0.35 if rr <= 5 else 0.06))
            if c is not None:
                out[y, x, :3] = c
                out[y, x, 3] = 255
    _outline(out, m["ink"])
    res["ext_porch_day"] = out
    res["ext_porch_night"] = out
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mat", default="c1")
    args = ap.parse_args()
    os.makedirs(os.path.join(G2, "m0"), exist_ok=True)
    os.makedirs(os.path.join(G2, "32"), exist_ok=True)
    lab = build_labels()
    board = os.path.join(ROOT, "pl", "anchors", "board_c1.png") if args.mat == "c1" else \
        os.path.join(G2, "m1", "anchor_v2.png")
    m = load_mats(board)
    day, mask = render(lab, m)
    night, em = night_of(day, mask, m)
    sfx = "" if args.mat == "c1" else "_v2mat"
    if args.mat == "c1":
        Image.fromarray(blockout(lab), "RGBA").save(os.path.join(G2, "m0", "blockout.png"))
        Image.fromarray(lab, "L").save(os.path.join(G2, "m0", "labels.png"))
        with open(os.path.join(G2, "m0", "anchors.json"), "w") as f:
            json.dump({"anchors": A, "extensions_proposed": EXT, "labels": L_NAMES}, f, indent=1)
        Image.fromarray(day, "RGBA").save(os.path.join(G2, "32", "house_day.png"))
        Image.fromarray(night, "RGBA").save(os.path.join(G2, "32", "house_night.png"))
        Image.fromarray(em, "RGBA").save(os.path.join(G2, "m0", "house_emissive.png"))
        for k, v in render_ext(m).items():
            Image.fromarray(v, "RGBA").save(os.path.join(G2, "32", k + ".png"))
    else:
        Image.fromarray(day, "RGBA").save(os.path.join(G2, "m0", "house_day" + sfx + ".png"))
        Image.fromarray(night, "RGBA").save(os.path.join(G2, "m0", "house_night" + sfx + ".png"))
    print("M0 written", args.mat, "opaque px", int((day[..., 3] > 0).sum()))


if __name__ == "__main__":
    main()
