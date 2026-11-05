# ART-005 E0 (non-production): the proposed master palette, the shared layout of the 16/32/64 px density test, the
# size-correct placeholder art for every density, the common design sheet and the composition blueprint.
#   python tools/art005_e0.py            writes everything under art/style_tests/ART-005/
# Nothing here is production art. The placeholders are drawn by formula, natively at each density from one
# design in logical tile units (never resampled), so the E1 harness compares density and presentation, not
# designs. They are engineering stand-ins and must not be judged as artwork.
import json
import math
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-005")
E0 = os.path.join(ROOT, "e0")
PH = os.path.join(ROOT, "placeholder")
DENSITIES = (16, 32, 64)

# ---------------------------------------------------------------------------------------------------------------
# Master palette: material ramps, darkest first. "c" marks a colour taken from the approved concept palette
# (art/style_tests/ART-003/src/concept_palette.png, 32 colours); "n" is a proposed addition. Shadows shift toward
# blue-violet, highlights toward warm yellow (hue shifting), so a ramp never just darkens toward black.
RAMPS = {
    "ink":     [("1a1410", "c"), ("241c22", "c"), ("2a1f18", "c")],
    "moss":    [("1e2a1c", "c"), ("2e3f24", "c"), ("43552c", "c"), ("5e6e34", "c"), ("7d8a3e", "c"), ("9a9a4a", "c")],
    "leaf":    [("6e1a16", "c"), ("9c2a1e", "c"), ("c4402a", "c"), ("d0641c", "c"), ("f0a030", "c"), ("f6c45a", "c")],
    "bark":    [("2a1f18", "c"), ("3b2a1e", "c"), ("5a3d26", "c"), ("7a5434", "c"), ("9a6d42", "c")],
    "timber":  [("3b2a1e", "c"), ("5c4128", "c"), ("7e5a36", "c"), ("a07a4c", "c"), ("c8b89a", "c")],
    "soil":    [("241c22", "c"), ("3a2a24", "n"), ("4f3a2e", "n"), ("6a5040", "n")],
    "path":    [("4a4038", "n"), ("6e6250", "n"), ("8a867a", "c"), ("a8a088", "n"), ("c8b89a", "c")],
    "stone":   [("2c3a44", "c"), ("3a3a3a", "c"), ("5e5c56", "c"), ("8a867a", "c"), ("b4b0a2", "n")],
    "shingle": [("1e2230", "n"), ("2c3a44", "c"), ("46525a", "n"), ("66707a", "n")],
    "skin":    [("5a3d26", "c"), ("9a6d42", "c"), ("c88a62", "n"), ("e8b48a", "n")],
    "coat":    [("1e2a2c", "n"), ("2c3a44", "c"), ("46606a", "n"), ("6a8a8a", "n")],
    "accent":  [("6e1a16", "c"), ("9c2a1e", "c"), ("c4402a", "c")],
    "pumpkin": [("8a3a12", "c"), ("b8561a", "c"), ("d97a22", "c"), ("f0a030", "c")],
    "lantern": [("8a3a12", "c"), ("d97a22", "c"), ("f4b850", "c"), ("f6c45a", "c"), ("fff0c0", "n")],
    "night":   [("241c22", "c"), ("2c3a44", "c"), ("5a3a6a", "c"), ("8a86a8", "n")],
    "water":   [("1e2a3a", "n"), ("2c3a44", "c"), ("3e5a64", "n"), ("6a8a8a", "n"), ("a8bcb4", "n")],
}
RAMP_USE = {
    "ink": "outer outlines against light ground, deepest contact shadow",
    "moss": "grass, ground cover, crop leaves",
    "leaf": "autumn oak crown, leaf litter",
    "bark": "trunks, roots",
    "timber": "house planks, fence, bed edging, door",
    "soil": "tilled beds and field",
    "path": "packed-earth path and porch apron",
    "stone": "foundation, steps, chimney, pebbles",
    "shingle": "roof",
    "skin": "farmer's face and hands",
    "coat": "farmer's coat and hat",
    "accent": "scarf, berries, small red accents",
    "pumpkin": "pumpkins and gourds",
    "lantern": "emissive only: lantern glass, lit windows (never key-lit)",
    "night": "cold accents, fog, night-only details",
    "water": "glass by day, water",
}
SHADOW = (0x1e, 0x22, 0x30)      # the one contact-shadow colour, drawn as its own layer at SHADOW_ALPHA
SHADOW_ALPHA = 96
NIGHT_TINT = (0x3a, 0x3f, 0x6e)  # production NIGHT_TINT (main.gd), a multiply on the whole world
LIGHT = np.array([-1.0, -1.0, 1.25])  # key light from the upper left, in screen x/y and out of the screen
LIGHT = LIGHT / np.linalg.norm(LIGHT)


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def ramp(name):
    return [rgb(h) for h, _ in RAMPS[name]]


def palette_unique():
    seen, out = set(), []
    for name, cols in RAMPS.items():
        for h, src in cols:
            if h not in seen:
                seen.add(h)
                out.append((h, src, name))
    return out


# ---------------------------------------------------------------------------------------------------------------
# Value-noise and drawing helpers. Every pattern is defined in logical tile units, so a texture keeps the same
# design at every density and only gains texels.
def _hash(i, j, seed):
    v = np.sin(i * 127.1 + j * 311.7 + seed * 74.7) * 43758.5453
    return v - np.floor(v)


def vnoise(x, y, freq, seed):
    xf, yf = x * freq, y * freq
    i, j = np.floor(xf), np.floor(yf)
    fx, fy = xf - i, yf - j
    fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b = _hash(i, j, seed), _hash(i + 1, j, seed)
    c, d = _hash(i, j + 1, seed), _hash(i + 1, j + 1, seed)
    return (a * (1 - fx) + b * fx) * (1 - fy) + (c * (1 - fx) + d * fx) * fy


class Canvas:
    """An RGBA image at density D for an object w x h tiles; X, Y are texel centres in tile units."""

    def __init__(self, w, h, d):
        self.d = d
        self.W, self.H = int(round(w * d)), int(round(h * d))
        xs = (np.arange(self.W) + 0.5) / d
        ys = (np.arange(self.H) + 0.5) / d
        self.X, self.Y = np.meshgrid(xs, ys)
        self.rgb = np.zeros((self.H, self.W, 3), np.uint8)
        self.a = np.zeros((self.H, self.W), np.uint8)
        self.mat = np.full((self.H, self.W), -1, np.int16)   # material id per texel, for outlines

    def put(self, mask, col, mat=None):
        self.rgb[mask] = col
        self.a[mask] = 255
        if mat is not None:
            self.mat[mask] = mat

    def put_ramp(self, mask, ramp_cols, idx, mat=None):
        idx = np.clip(idx, 0, len(ramp_cols) - 1).astype(int)
        pal = np.array(ramp_cols, np.uint8)
        self.rgb[mask] = pal[idx[mask]] if np.ndim(idx) else pal[idx]
        self.a[mask] = 255
        if mat is not None:
            self.mat[mask] = mat

    def rect(self, x0, y0, x1, y1):
        return (self.X >= x0) & (self.X < x1) & (self.Y >= y0) & (self.Y < y1)

    def ellipse(self, cx, cy, rx, ry):
        return ((self.X - cx) / rx) ** 2 + ((self.Y - cy) / ry) ** 2 <= 1.0

    def outline(self, outer_cols, lit_cols=None):
        """Selective 1-texel outline: opaque texels with a transparent 4-neighbour become the material's darkest
        tone; on the lit (upper-left) side, one step lighter. outer_cols / lit_cols map material id -> colour."""
        op = self.a > 0
        pad = np.pad(op, 1)
        up, down = ~pad[:-2, 1:-1], ~pad[2:, 1:-1]
        left, right = ~pad[1:-1, :-2], ~pad[1:-1, 2:]
        edge = op & (up | down | left | right)
        lit = edge & (up | left) & ~(down | right)
        for m, col in outer_cols.items():
            self.rgb[edge & (self.mat == m)] = col
        if lit_cols:
            for m, col in lit_cols.items():
                self.rgb[lit & (self.mat == m)] = col

    def save(self, path):
        img = np.dstack([self.rgb, self.a])
        Image.fromarray(img, "RGBA").save(path)


# ---------------------------------------------------------------------------------------------------------------
# The shared layout (tiles). The 30 x 17 vignette sits at (MX, MY) inside a 50 x 25 map, so the walk can pan
# without showing an edge. Codes: G grass, P path, S tilled soil.
MW, MH, MX, MY = 50, 25, 10, 4
VW, VH = 30, 17


def build_layout():
    g = [["G"] * MW for _ in range(MH)]

    def fill(x0, y0, x1, y1, c):          # vignette coordinates, inclusive-exclusive
        for y in range(y0 + MY, y1 + MY):
            for x in range(x0 + MX, x1 + MX):
                if 0 <= x < MW and 0 <= y < MH:
                    g[y][x] = c
    fill(-MX, 12, VW + MX, 14, "P")       # the lane, through the margins
    fill(16, 10, 18, 12, "P")             # porch apron down to the lane
    fill(2, 14, 9, 17, "S")               # a tilled field south of the lane (grass -> soil transition)
    fill(23, 2, 30, 6, "S")               # garden bed 1 (7 x 4)
    fill(23, 6, 30, 10, "S")              # garden bed 2
    # objects: name, anchor x, anchor y (vignette tiles; anchor = the image's bottom centre, the sort base)
    objs = [
        ("oak", 6.0, 11.2), ("house", 17.0, 10.5),
        ("bed", 26.5, 6.0), ("bed", 26.5, 10.0),
        ("crop_a1", 24.5, 4.0), ("crop_a2", 26.5, 4.0), ("crop_b1", 28.5, 4.0),
        ("crop_b2", 24.5, 8.0), ("crop_a2", 26.5, 8.0), ("crop_b2", 28.5, 8.0),
    ]
    for x in range(22, 30):
        if x not in (26,):                 # a gap in the fence: the garden gate
            objs.append(("fence", x + 0.5, 11.0))
    route = [(6.0, 12.6), (24.0, 12.6), (27.0, 15.6)]
    still = (15.0, 12.6)
    return g, objs, route, still


def write_layout(g, objs, route, still):
    lines = ["# ART-005 shared layout. Generated by tools/art005_e0.py; do not edit by hand.",
             f"map {MW} {MH} vignette {MX} {MY} {VW} {VH}"]
    lines += ["row " + "".join(r) for r in g]
    for n, x, y in objs:
        lines.append(f"obj {n} {x} {y}")
    lines.append("route " + " ".join(f"{x},{y}" for x, y in route))
    lines.append(f"still {still[0]},{still[1]}")
    with open(os.path.join(E0, "layout.txt"), "w", newline="\n") as f:
        f.write("\n".join(lines) + "\n")


# ---------------------------------------------------------------------------------------------------------------
# Placeholders, one design per object, rasterised natively at density d.
def ph_ground(g, d):
    c = Canvas(MW, MH, d)
    X, Y = c.X, c.Y
    codes = np.array(g)
    # organic edges: sample the tile map at a noise-displaced point (amplitude 0.22 tile)
    dx = (vnoise(X, Y, 1.6, 1) - 0.5) * 0.44
    dy = (vnoise(X, Y, 1.6, 2) - 0.5) * 0.44
    tx = np.clip(np.floor(X + dx).astype(int), 0, MW - 1)
    ty = np.clip(np.floor(Y + dy).astype(int), 0, MH - 1)
    cls = codes[ty, tx]
    grass, path, soil = cls == "G", cls == "P", cls == "S"
    # grass: three octaves -> moss 1..4, a few warm blade tips
    v = 0.55 * vnoise(X, Y, 2, 3) + 0.3 * vnoise(X, Y, 5, 4) + 0.15 * vnoise(X, Y, 11, 5)
    gi = 1 + np.floor(np.clip((v - 0.3) / 0.4, 0, 0.999) * 3.0)
    tips = vnoise(X, Y, 9, 6) > 0.86
    gi = np.where(tips, 4, gi)
    c.put_ramp(grass, ramp("moss"), gi)
    # path: path 1..3 with pebbles (stone 3, lit) and their shadow one 1/16 tile down-right
    pv = 0.6 * vnoise(X, Y, 3, 7) + 0.4 * vnoise(X, Y, 8, 8)
    pi = 1 + np.floor(np.clip((pv - 0.3) / 0.4, 0, 0.999) * 3.0)
    c.put_ramp(path, ramp("path"), pi)
    peb = path & (vnoise(X, Y, 7, 9) > 0.8)
    peb_sh = path & (vnoise(X - 1 / 16, Y - 1 / 16, 7, 9) > 0.8) & ~peb
    c.put(peb_sh, ramp("path")[0])
    c.put(peb, ramp("stone")[3])
    # soil: furrows with a 1/3-tile period, the lower quarter in shade
    sv = vnoise(X, Y, 4, 10)
    si = np.where(((Y + 0.05 * sv) % (1 / 3)) > 0.25, 0, 2 + (sv > 0.55))
    c.put_ramp(soil, ramp("soil"), si)
    # grass lip: path/soil just below-right of grass is in the grass's contact shadow (1/16 tile)
    o = 1 / 16
    tx2 = np.clip(np.floor(X - o + dx).astype(int), 0, MW - 1)
    ty2 = np.clip(np.floor(Y - o + dy).astype(int), 0, MH - 1)
    above_grass = codes[ty2, tx2] == "G"
    c.put(path & above_grass, ramp("path")[0])
    c.put(soil & above_grass, ramp("soil")[0])
    # leaf litter round the oak's foot: leaves of 1/8 tile, lit on their upper-left texel row
    ox, oy = 6.0 + MX, 11.0 + MY
    near = ((X - ox) / 4.2) ** 2 + ((Y - oy) / 1.8) ** 2 < 1
    cell = np.floor(X * 8) * 1000 + np.floor(Y * 8)
    leaf = near & grass & (_hash(np.floor(X * 8), np.floor(Y * 8), 11) > 0.72)
    li = 2 + (_hash(np.floor(X * 8), np.floor(Y * 8), 12) > 0.5).astype(int)
    c.put_ramp(leaf, ramp("leaf"), li)
    del cell
    return c


def ph_house(d, night):
    c = Canvas(12, 10, d)
    X, Y = c.X, c.Y
    sh, tb, st = ramp("shingle"), ramp("timber"), ramp("stone")
    # roof: a trapezoid from y 0.6 to 5.0, eaves overhanging; shingle rows of 0.5 tile, staggered seams
    t = (Y - 0.6) / 4.4
    roof = (Y >= 0.6) & (Y < 5.0) & (X >= 1.4 - t * 1.0) & (X < 10.6 + t * 1.0)
    row = np.floor((Y - 0.6) / 0.5)
    ry = (Y - 0.6) % 0.5
    seam_x = ((X + (row % 2) * 0.375) % 0.75) < (1.0 / d)
    ri = 2 + (X < 4.0).astype(int) - (X > 9.0).astype(int)
    ri = np.where(ry < 1.0 / d * 1.01, 3, ri)               # top texel of each row catches the light
    ri = np.where(ry > 0.5 - 1.0 / d * 1.01, 0, ri)         # bottom texel: the row's own shadow
    ri = np.where(seam_x & (ry < 0.4), 1, ri)
    c.put_ramp(roof, sh, ri, mat=0)
    ridge = roof & (Y < 0.85)
    c.put_ramp(ridge, sh, np.full(X.shape, 3), mat=0)
    # chimney (stone), lit face on the left
    ch = c.rect(8.2, 0.0, 9.2, 1.6)
    c.put_ramp(ch, st, np.where(X < 8.55, 4, np.where(Y % 0.3 < 1.0 / d * 1.01, 1, 2)), mat=2)
    # wall: horizontal planks of 0.375 tile; the eave's shadow band; corner posts (left one lit)
    wall = c.rect(1.0, 5.0, 11.0, 9.3)
    py = (Y - 5.0) % 0.375
    wi = np.where(py < 1.0 / d * 1.01, 1, 2 + (vnoise(X, Y, 1.5, 20) > 0.62))
    wi = np.where(Y < 5.45, 0, wi)
    c.put_ramp(wall, tb, wi, mat=1)
    c.put_ramp(c.rect(1.0, 5.45, 1.35, 9.3), tb, np.full(X.shape, 3), mat=1)
    c.put_ramp(c.rect(10.65, 5.45, 11.0, 9.3), tb, np.full(X.shape, 1), mat=1)
    # windows: timber frame, glass (cool by day with a top-left glint; lantern-warm at night), a mullion cross
    for x0 in (2.2, 8.4):
        fr = c.rect(x0, 6.0, x0 + 1.4, 7.4)
        c.put_ramp(fr, tb, np.full(X.shape, 4), mat=1)
        gl = c.rect(x0 + 0.15, 6.15, x0 + 1.25, 7.25)
        if night:
            gi = np.where((X - x0 - 0.15) + (Y - 6.15) < 0.5, 4, 3)
            c.put_ramp(gl, ramp("lantern"), gi, mat=1)
        else:
            gi = np.where((X - x0 - 0.15) + (Y - 6.15) < 0.35, 3, 1)
            c.put_ramp(gl, ramp("water"), gi, mat=1)
        mull = gl & ((np.abs(X - (x0 + 0.7)) < 0.6 / d + 0.03) | (np.abs(Y - 6.7) < 0.6 / d + 0.03))
        c.put_ramp(mull, tb, np.full(X.shape, 1), mat=1)
    # door: vertical boards, a brass handle
    door = c.rect(5.4, 7.0, 6.6, 9.3)
    di = np.where(((X - 5.4) % 0.3) < 1.0 / d * 1.01, 0, 1 + (X < 5.7).astype(int))
    c.put_ramp(door, tb, di, mat=1)
    c.put_ramp(c.rect(6.3, 8.1, 6.42, 8.25), ramp("lantern"), np.full(X.shape, 1), mat=1)
    # foundation blocks and porch steps
    fnd = c.rect(0.9, 9.3, 11.1, 9.7)
    fi = np.where(((X + np.floor((Y - 9.3) / 0.2) * 0.25) % 0.5) < 1.0 / d * 1.01, 1, 3 - (X > 6).astype(int))
    c.put_ramp(fnd, st, fi, mat=2)
    c.put_ramp(c.rect(5.1, 9.7, 6.9, 10.0), st, np.where(Y < 9.8, 4, 2), mat=2)
    c.outline({0: sh[0], 1: tb[0], 2: st[0]}, {0: sh[1], 1: tb[1], 2: st[1]})
    return c


def ph_oak(d):
    c = Canvas(12, 12, d)
    X, Y = c.X, c.Y
    lf, bk = ramp("leaf"), ramp("bark")
    # trunk and roots: lit left third, grooves from noise
    trunk = c.rect(5.3, 6.5, 6.7, 11.0) | (c.ellipse(6.0, 11.0, 1.5, 0.45) & (Y < 11.0))
    rel = (X - 5.3) / 1.4
    ti = np.where(rel < 0.33, 3, np.where(rel < 0.7, 2, 1))
    groove = vnoise(X * 4, Y * 0.6, 3, 30) > 0.68
    ti = np.where(groove, ti - 1, ti)
    c.put_ramp(trunk, bk, ti, mat=1)
    # crown: a union of spheres; the normal of the tallest sphere at each texel, lit from the upper left,
    # then broken into leaf clusters of about 1/3 tile by noise, and darker toward the underside
    spheres = [(6, 4.2, 3.2), (3.4, 5.4, 2.4), (8.7, 5.4, 2.5), (4.6, 2.6, 2.1), (7.6, 2.5, 2.2),
               (6, 6.4, 2.4), (2.4, 6.9, 1.5), (9.8, 6.9, 1.6)]
    hmax = np.full(X.shape, -1.0)
    nx = np.zeros(X.shape)
    ny = np.zeros(X.shape)
    for cx, cy, r in spheres:
        dd = (X - cx) ** 2 + (Y - cy) ** 2
        h = np.sqrt(np.clip(r * r - dd, 0, None))
        inside = (dd < r * r) & (h > hmax)
        hmax = np.where(inside, h, hmax)
        nx = np.where(inside, (X - cx) / r, nx)
        ny = np.where(inside, (Y - cy) / r, ny)
    crown = hmax >= 0
    # scalloped edge: drop texels near the rim where leaf-cluster noise is low
    clus = vnoise(X, Y, 3.0, 31)
    crown &= ~((hmax < 0.35) & (clus < 0.45))
    nz = np.sqrt(np.clip(1 - nx ** 2 - ny ** 2, 0, None))
    lit = nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2]
    lit = lit + (clus - 0.5) * 0.55 - np.clip((Y - 6.0) / 6.0, 0, 1) * 0.35
    ci = np.floor(np.clip((lit + 0.1) / 1.1, 0, 0.999) * 6)
    c.put_ramp(crown, lf, ci, mat=0)
    c.outline({0: lf[0], 1: bk[0]}, {0: lf[1], 1: bk[1]})
    return c


def ph_bed(d):
    c = Canvas(7, 4, d)
    X, Y = c.X, c.Y
    tb = ramp("timber")
    outer = c.rect(0.15, 0.35, 6.85, 3.85)
    inner = c.rect(0.4, 0.6, 6.6, 3.6)
    edge = outer & ~inner
    ei = np.where(Y < 0.6, 3, np.where(X < 0.4, 3, 1))
    ei = np.where(((X % 1.75) < 1.0 / d * 1.01) & edge, 0, ei)
    c.put_ramp(edge, tb, ei, mat=1)
    rows = inner & (((Y - 0.6) % 0.75) < 0.18)
    c.put_ramp(rows, ramp("soil"), np.full(X.shape, 0), mat=0)
    c.outline({1: tb[0]}, {1: tb[1]})
    return c


def ph_crop(d, kind, stage):
    c = Canvas(1, 1, d)
    X, Y = c.X, c.Y
    mo = ramp("moss")
    if kind == "a":     # leafy greens: two then four leaves
        leaves = [(0.35, 0.72, 0.16, 0.1), (0.65, 0.72, 0.16, 0.1)] if stage == 1 else \
                 [(0.3, 0.62, 0.2, 0.13), (0.7, 0.62, 0.2, 0.13), (0.42, 0.45, 0.14, 0.2), (0.6, 0.45, 0.14, 0.2)]
        for cx, cy, rx, ry in leaves:
            m = c.ellipse(cx, cy, rx, ry)
            c.put_ramp(m, mo, np.where((X - cx) + (Y - cy) < 0, 4, 2), mat=0)
        c.put_ramp(c.rect(0.47, 0.6 if stage == 1 else 0.5, 0.53, 0.88), mo, np.full(X.shape, 1), mat=0)
    else:               # pumpkin: vine leaves, then a fruit
        c.put_ramp(c.ellipse(0.3, 0.6, 0.18, 0.12), mo, np.full(X.shape, 3), mat=0)
        c.put_ramp(c.ellipse(0.72, 0.55, 0.16, 0.11), mo, np.full(X.shape, 2), mat=0)
        if stage == 2:
            m = c.ellipse(0.5, 0.68, 0.32, 0.22)
            nx, ny = (X - 0.5) / 0.32, (Y - 0.68) / 0.22
            lit = nx * LIGHT[0] + ny * LIGHT[1] + np.sqrt(np.clip(1 - nx ** 2 - ny ** 2, 0, None)) * LIGHT[2]
            rib = (np.abs((X - 0.5) % 0.16) < 0.6 / d + 0.01)
            pi = np.floor(np.clip(lit, 0, 0.999) * 4) - rib
            c.put_ramp(m, ramp("pumpkin"), pi, mat=1)
            c.put_ramp(c.rect(0.47, 0.4, 0.55, 0.5), ramp("bark"), np.full(X.shape, 2), mat=0)
        else:
            c.put_ramp(c.ellipse(0.5, 0.75, 0.1, 0.08), ramp("pumpkin"), np.full(X.shape, 2), mat=1)
    c.outline({0: mo[0], 1: ramp("pumpkin")[0]})
    return c


def ph_fence(d):
    c = Canvas(1, 1.25, d)
    X, Y = c.X, c.Y
    tb = ramp("timber")
    post = c.rect(0.4, 0.2, 0.62, 1.2)
    c.put_ramp(post, tb, np.where(X < 0.47, 3, 2), mat=1)
    for y0 in (0.42, 0.78):
        rail = c.rect(0.0, y0, 1.0, y0 + 0.12) & ~post
        c.put_ramp(rail, tb, np.where(Y < y0 + 0.04, 3, 1), mat=1)
    c.outline({1: tb[0]})
    return c


def ph_farmer(d, frame):
    """1 x 2 tiles, facing right, feet on the bottom row. frame 0 = idle, 1-4 = walk."""
    c = Canvas(1, 2, d)
    X, Y = c.X, c.Y
    sk, co, ac, ink = ramp("skin"), ramp("coat"), ramp("accent"), ramp("ink")
    bob = 0.0 if frame in (0, 2, 4) else -1.0 / 16
    swing = {0: 0.0, 1: 0.1, 2: 0.0, 3: -0.1, 4: 0.0}[frame]
    # legs and boots
    for sx, ph in ((0.42, 1), (0.56, -1)):
        lx = sx + swing * ph
        leg = c.rect(lx - 0.07, 1.5 + bob, lx + 0.07, 1.9) | c.rect(lx - 0.07, 1.88, lx + 0.12, 1.98)
        c.put_ramp(leg, ink, np.full(X.shape, 1 if ph > 0 else 0), mat=2)
    # coat: lit on the left, a fold on the right
    coat = c.rect(0.25, 0.86 + bob, 0.75, 1.55 + bob) | c.ellipse(0.5, 1.5 + bob, 0.27, 0.12)
    cx = (X - 0.25) / 0.5
    c.put_ramp(coat, co, np.where(cx < 0.35, 3, np.where(cx < 0.8, 2, 1)), mat=1)
    c.put_ramp(c.rect(0.27, 0.86 + bob, 0.73, 0.97 + bob), ac, np.full(X.shape, 2), mat=3)   # scarf
    # head, a hat with a brim
    head = c.ellipse(0.55, 0.64 + bob, 0.21, 0.21)
    c.put_ramp(head, sk, np.where((X - 0.55) + (Y - 0.64 - bob) < -0.05, 3, 2), mat=4)
    c.put_ramp(c.rect(0.66, 0.6 + bob, 0.71, 0.66 + bob), ink, np.full(X.shape, 0), mat=4)  # eye
    hat = c.ellipse(0.52, 0.45 + bob, 0.33, 0.07) | c.rect(0.36, 0.25 + bob, 0.66, 0.46 + bob)
    c.put_ramp(hat, co, np.where(X < 0.45, 2, 1), mat=1)
    # arm toward the lantern
    arm = c.rect(0.62, 1.0 + bob, 0.75, 1.3 + bob)
    c.put_ramp(arm, co, np.full(X.shape, 2), mat=1)
    c.outline({1: co[0], 2: ink[0], 3: ac[0], 4: sk[0]}, {1: co[1], 4: sk[1]})
    return c


def ph_lantern(d):
    """0.375 x 0.5 tile; the handle's top centre is the pivot."""
    c = Canvas(0.375, 0.5, d)
    X, Y = c.X, c.Y
    ln, ink = ramp("lantern"), ramp("ink")
    body = c.rect(0.06, 0.16, 0.32, 0.46)
    c.put_ramp(body, ink, np.full(X.shape, 2), mat=1)
    glass = c.rect(0.1, 0.2, 0.28, 0.42)
    c.put_ramp(glass, ln, np.where(Y < 0.28, 4, 3), mat=0)
    c.put_ramp(c.rect(0.16, 0.0, 0.22, 0.16), ink, np.full(X.shape, 1), mat=1)
    return c


def ph_shadow(w, h, cx, cy, rx, ry, d):
    c = Canvas(w, h, d)
    m = c.ellipse(cx, cy, rx, ry)
    c.rgb[m] = SHADOW
    c.a[m] = SHADOW_ALPHA
    return c


def ph_probe(d):
    """A 1 x 1 tile clarity probe: a 1-texel checker (top half) and a 2-texel checker (bottom half)."""
    c = Canvas(1, 1, d)
    i = np.arange(c.W)[None, :]
    j = np.arange(c.H)[:, None]
    a, b = rgb("1a1410"), rgb("c8b89a")
    one = ((i + j) % 2 == 0)
    two = ((i // 2 + j // 2) % 2 == 0)
    top = (j < c.H // 2) & np.ones_like(one)
    c.rgb[:] = np.where((np.where(top, one, two))[..., None], a, b)
    c.a[:] = 255
    return c


def make_placeholders(g):
    for d in DENSITIES:
        out = os.path.join(PH, str(d))
        os.makedirs(out, exist_ok=True)
        ph_ground(g, d).save(os.path.join(out, "ground.png"))
        ph_house(d, False).save(os.path.join(out, "house_day.png"))
        ph_house(d, True).save(os.path.join(out, "house_night.png"))
        ph_oak(d).save(os.path.join(out, "oak.png"))
        ph_bed(d).save(os.path.join(out, "bed.png"))
        for k in ("a", "b"):
            for s in (1, 2):
                ph_crop(d, k, s).save(os.path.join(out, f"crop_{k}{s}.png"))
        ph_fence(d).save(os.path.join(out, "fence.png"))
        frames = [ph_farmer(d, f) for f in range(5)]
        strip = np.concatenate([np.dstack([f.rgb, f.a]) for f in frames], axis=1)
        Image.fromarray(strip, "RGBA").save(os.path.join(out, "farmer.png"))
        ph_lantern(d).save(os.path.join(out, "lantern.png"))
        ph_shadow(12, 10.5, 6.3, 9.9, 6.0, 0.55, d).save(os.path.join(out, "house_shadow.png"))
        ph_shadow(12, 12, 6.6, 11.0, 3.4, 0.7, d).save(os.path.join(out, "oak_shadow.png"))
        ph_shadow(1, 2, 0.55, 1.93, 0.36, 0.08, d).save(os.path.join(out, "farmer_shadow.png"))
        ph_probe(d).save(os.path.join(out, "probe.png"))
        print("placeholders", d, "->", out)


# ---------------------------------------------------------------------------------------------------------------
# Measurements written into the spec: the value contrast of key pairs by day and under the night tint.
def rel_lum(c):
    def ch(v):
        v = v / 255.0
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = c
    return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b)


def lab_L(c):
    y = rel_lum(c)
    return 116 * (y ** (1 / 3) if y > 0.008856 else 7.787 * y + 16 / 116) - 16


def tint(c, t):
    return tuple(int(round(a * b / 255.0)) for a, b in zip(c, t))


def value_table():
    pairs = [
        ("farmer coat (coat 2) on grass (moss 2)", rgb("46606a"), rgb("43552c")),
        ("farmer coat lit (coat 3) on grass (moss 2)", rgb("6a8a8a"), rgb("43552c")),
        ("farmer outline (coat 0) on path (path 2)", rgb("1e2a2c"), rgb("8a867a")),
        ("path (path 2) next to grass (moss 2)", rgb("8a867a"), rgb("43552c")),
        ("tilled soil (soil 2) next to grass (moss 2)", rgb("4f3a2e"), rgb("43552c")),
        ("timber wall (timber 2) on grass (moss 2)", rgb("7e5a36"), rgb("43552c")),
        ("pumpkin (pumpkin 2) on soil (soil 2)", rgb("d97a22"), rgb("4f3a2e")),
        ("oak crown mid (leaf 3) on grass (moss 2)", rgb("d0641c"), rgb("43552c")),
    ]
    rows = []
    for name, a, b in pairs:
        day = abs(lab_L(a) - lab_L(b))
        night = abs(lab_L(tint(a, NIGHT_TINT)) - lab_L(tint(b, NIGHT_TINT)))
        rows.append({"pair": name, "dL_day": round(day, 1), "dL_night_untinted_light": round(night, 1)})
    return rows


# ---------------------------------------------------------------------------------------------------------------
# The design sheet and the composition blueprint.
def font(size):
    try:
        return ImageFont.truetype("arial.ttf", size)
    except OSError:
        return ImageFont.load_default(size)


def design_sheet(values):
    W, H = 2000, 1400
    im = Image.new("RGB", (W, H), (24, 22, 26))
    dr = ImageDraw.Draw(im)
    f1, f2, f3 = font(30), font(18), font(14)
    dr.text((24, 18), "ART-005 E0 — common design sheet (PROPOSED, not approved)", fill=(240, 230, 210), font=f1)
    dr.text((24, 56), "One design for every density. 16 x 16 logical grid. Quality references are benchmarks, not art to copy.",
            fill=(190, 180, 165), font=f2)
    # 1. palette ramps
    y = 100
    dr.text((24, y), "1  Master palette: material ramps (dark -> light).  c = concept palette, n = proposed addition",
            fill=(240, 230, 210), font=f2)
    y += 30
    for name, cols in RAMPS.items():
        dr.text((24, y + 8), name, fill=(220, 210, 190), font=f2)
        for i, (h, src) in enumerate(cols):
            x = 130 + i * 74
            dr.rectangle([x, y, x + 70, y + 32], fill=rgb(h))
            tc = (0, 0, 0) if lab_L(rgb(h)) > 55 else (255, 255, 255)
            dr.text((x + 4, y + 2), h, fill=tc, font=f3)
            dr.text((x + 4, y + 17), src, fill=tc, font=f3)
        dr.text((130 + 6 * 74 + 6, y + 8), RAMP_USE[name], fill=(170, 160, 150), font=f3)
        y += 38
    # 2. light model
    x0, y0 = 1020, 100
    dr.text((x0, y0), "2  One light: key from the upper left; contact shadow below-right", fill=(240, 230, 210), font=f2)
    y0 += 36
    dr.line([x0 + 20, y0 + 10, x0 + 110, y0 + 100], fill=(246, 196, 90), width=5)
    dr.polygon([(x0 + 110, y0 + 100), (x0 + 92, y0 + 96), (x0 + 106, y0 + 82)], fill=(246, 196, 90))
    dr.text((x0 + 4, y0 - 6), "key", fill=(246, 196, 90), font=f3)
    sph = ph_crop(64, "b", 2)
    big = Image.fromarray(np.dstack([sph.rgb, sph.a]), "RGBA").resize((192, 192), Image.NEAREST)
    shadow = Image.new("RGBA", (192, 60), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).ellipse([30, 10, 186, 50], fill=SHADOW + (SHADOW_ALPHA,))
    im.paste(shadow, (x0 + 130, y0 + 140), shadow)
    im.paste(big, (x0 + 120, y0 - 10), big)
    dr.text((x0 + 340, y0), "- lit planes: top and left faces, +1 or +2 ramp steps\n"
            "- shade: right and under faces, -1 or -2 steps\n"
            "- contact shadow: one colour 1e2230 at alpha 96,\n  its own layer, offset ~1/16 tile right and down\n"
            "- emissive (lantern ramp) is never key-lit\n"
            "- night is a multiply (NIGHT_TINT 3a3f6e) plus\n  lights: assets are not repainted for night",
            fill=(200, 190, 175), font=f3)
    # 3. outline and clusters
    y0 = 340
    dr.text((x0, y0), "3  Outline, clusters, anti-aliasing (1 art px everywhere)", fill=(240, 230, 210), font=f2)
    for k, d in enumerate(DENSITIES):
        fm = ph_farmer(d, 1)
        img = Image.fromarray(np.dstack([fm.rgb, fm.a]), "RGBA")
        s = 128 // d     # every density shown 256 px tall, so only the pixel size differs
        img = img.resize((d * s, 2 * d * s), Image.NEAREST)
        px = x0 + k * 170
        im.paste(img, (px, y0 + 40), img)
        dr.text((px, y0 + 40 + 2 * d * s + 4), f"{d} px/tile (placeholder)", fill=(200, 190, 175), font=f3)
    dr.text((x0 + 520, y0 + 40),
            "- outer silhouette: the material's darkest tone\n  (ink only against light ground); no pure black\n"
            "- lit edge (top/left): one step lighter (selective)\n- interior lines: ramp step 1-2, never ink\n"
            "- clusters >= 2 art px; single pixels only for\n  deliberate glints and AA\n"
            "- AA: hand-placed, inside the sprite, one\n  intermediate ramp colour; alpha is 0 or 255\n"
            "- outline width is 1 art px at every density\n  (thinner on screen at 32/64: being judged)",
            fill=(200, 190, 175), font=f3)
    # 4. proportions, in tiles
    y0 = 700
    dr.text((x0, y0), "4  Proportions (logical tiles; identical at every density)", fill=(240, 230, 210), font=f2)
    T = 24
    base = y0 + 40 + 12 * T
    items = [("farmer 1x2", 1, 2, (70, 96, 106)), ("door 1.2x2.3", 1.2, 2.3, (126, 90, 54)),
             ("fence 1x1", 1, 1, (160, 122, 76)), ("crop <=1x1", 1, 1, (94, 110, 52)),
             ("oak 12x12 img\ncrown ~10, trunk 1.4", 12, 11.2, (208, 100, 28)),
             ("house 12x10", 12, 10, (70, 82, 90))]
    px = x0
    for k, (name, w, h, col) in enumerate(items):
        dr.rectangle([px, base - h * T, px + w * T, base], outline=col, width=2)
        dr.text((px + 2, base + 4 + (k % 2) * 16 if w < 3 else base + 4), name, fill=(200, 190, 175), font=f3)
        px += w * T + (40 if w < 3 else 18)
    for k in range(0, 41):
        dr.line([x0 + k * T, base + 46, x0 + k * T, base + 50], fill=(90, 90, 90))
    # 5. terrain rules
    y0 = 760
    dr.text((24, y0), "5  Terrain kit: dual grid, organic edges, contact lip, variation", fill=(240, 230, 210), font=f2)
    g = [["G"] * 12 for _ in range(6)]
    for x in range(12):
        g[3][x] = "P"
    for x in range(6, 12):
        g[4][x] = "S"
        g[5][x] = "S"
    gr = ph_ground_small(g, 32)
    img = Image.fromarray(np.dstack([gr.rgb, gr.a]), "RGBA").resize((12 * 32 * 2, 6 * 32 * 2), Image.NEAREST)
    im.paste(img, (24, y0 + 34), img)
    dr.text((24 + 12 * 64 + 16, y0 + 34),
            "- one 16-piece dual-grid set per material over grass\n- edges wander +-0.22 tile; never a straight\n"
            "  run longer than 1 tile\n- lower material gets a 1/16-tile shade lip\n  under the grass (light from upper left)\n"
            "- >= 3 fill variants per material, hashed per tile\n- decals (stones, litter, ruts) break repeats:\n"
            "  no feature repeats within 3 tiles\n- texture marks defined in tile units, so the\n"
            "  design holds at 16/32/64",
            fill=(200, 190, 175), font=f3)
    # 6. night value budget (measured from the palette)
    y0 = 1190
    dr.text((24, y0), "6  Value budget (CIELAB dL, measured from the palette; night = NIGHT_TINT multiply, no lamp)",
            fill=(240, 230, 210), font=f2)
    for i, r in enumerate(values):
        dr.text((24 + (i % 2) * 980, y0 + 30 + (i // 2) * 20),
                f"{r['pair']}: day {r['dL_day']}, night {r['dL_night_untinted_light']}", fill=(200, 190, 175), font=f3)
    im.save(os.path.join(E0, "design_sheet.png"))


def ph_ground_small(g, d):
    global MW, MH, MX, MY
    saved = (MW, MH, MX, MY)
    MW, MH, MX, MY = len(g[0]), len(g), -100, -100
    try:
        return ph_ground(g, d)
    finally:
        MW, MH, MX, MY = saved


def composition(g, objs, route, still):
    T = 32
    im = Image.new("RGB", (MW * T, MH * T + 60), (24, 22, 26))
    dr = ImageDraw.Draw(im)
    cols = {"G": (67, 85, 44), "P": (138, 134, 122), "S": (79, 58, 46)}
    for y in range(MH):
        for x in range(MW):
            dr.rectangle([x * T, y * T, x * T + T - 1, y * T + T - 1], fill=cols[g[y][x]])
    sizes = {"oak": (12, 12), "house": (12, 10), "bed": (7, 4), "fence": (1, 1.25), "crop_a1": (1, 1),
             "crop_a2": (1, 1), "crop_b1": (1, 1), "crop_b2": (1, 1)}
    f = font(14)
    for n, ax, ay in objs:
        w, h = sizes[n]
        x0, y0 = (ax + MX - w / 2) * T, (ay + MY - h) * T
        dr.rectangle([x0, y0, x0 + w * T, y0 + h * T], outline=(246, 196, 90), width=2)
        if n in ("oak", "house", "bed"):
            dr.text((x0 + 4, y0 + 4), n, fill=(246, 196, 90), font=f)
    pts = [((x + MX) * T, (y + MY) * T) for x, y in route]
    dr.line(pts, fill=(196, 64, 42), width=3)
    sx, sy = (still[0] + MX) * T, (still[1] + MY) * T
    dr.ellipse([sx - 6, sy - 6, sx + 6, sy + 6], fill=(255, 240, 192))
    dr.rectangle([MX * T, MY * T, (MX + VW) * T, (MY + VH) * T], outline=(255, 255, 255), width=3)
    dr.text((8, MH * T + 8), "ART-005 test composition: 50 x 25-tile map; white = the 30 x 17 matched vignette "
            "(the 1080p integer view); red = walk route; dot = still-shot farmer tile. Grass / path / soil.",
            fill=(220, 210, 190), font=font(16))
    im.save(os.path.join(E0, "composition.png"))


def write_palette_files():
    uniq = palette_unique()
    with open(os.path.join(E0, "palette.json"), "w", newline="\n") as f:
        json.dump({"ramps": {k: [h for h, _ in v] for k, v in RAMPS.items()},
                   "source": {k: [s for _, s in v] for k, v in RAMPS.items()},
                   "use": RAMP_USE, "shadow": {"rgb": "%02x%02x%02x" % SHADOW, "alpha": SHADOW_ALPHA},
                   "night_tint": "%02x%02x%02x" % NIGHT_TINT, "unique_colours": len(uniq)}, f, indent=1)
    with open(os.path.join(E0, "palette.gpl"), "w", newline="\n") as f:
        f.write("GIMP Palette\nName: Crow Creek Hollow ART-005 proposed master\nColumns: 8\n#\n")
        for h, src, name in uniq:
            r, g, b = rgb(h)
            f.write(f"{r:3d} {g:3d} {b:3d}\t{name} {h} {src}\n")
    sw = Image.new("RGB", (8 * 16, ((len(uniq) + 7) // 8) * 16))
    d = ImageDraw.Draw(sw)
    for i, (h, _, _) in enumerate(uniq):
        d.rectangle([(i % 8) * 16, (i // 8) * 16, (i % 8) * 16 + 15, (i // 8) * 16 + 15], fill=rgb(h))
    sw.save(os.path.join(E0, "palette.png"))
    return len(uniq)


def main():
    os.makedirs(E0, exist_ok=True)
    os.makedirs(PH, exist_ok=True)
    for folder in (ROOT,):
        # Godot never imports anything in ART-005: the harness reads PNGs with Image.load_from_file.
        open(os.path.join(folder, ".gdignore"), "w").close()
    n = write_palette_files()
    print("palette:", n, "unique colours")
    g, objs, route, still = build_layout()
    write_layout(g, objs, route, still)
    make_placeholders(g)
    values = value_table()
    with open(os.path.join(E0, "value_budget.json"), "w", newline="\n") as f:
        json.dump(values, f, indent=1)
    for r in values:
        print(r)
    design_sheet(values)
    composition(g, objs, route, still)
    print("design sheet and composition ->", E0)


if __name__ == "__main__":
    main()
