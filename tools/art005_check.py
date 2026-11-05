# ART-005 E0 proposed asset validator (non-production). Measures, does not judge: palette conformance against
# the proposed master palette, colour count, partial alpha, orphan pixels, resampling (mixel risk), outline
# darkness and size on the half-tile grid. Prints one Markdown table row per image.
#   python tools/art005_check.py --density 16 art/farm/house_stage_3.png art/farm/fence.png
#   python tools/art005_check.py --density 32 art/style_tests/ART-005/placeholder/32/*.png
# Thresholds in the ART-005 style specification (section 10) are proposals; this tool only reports.
import argparse
import glob
import json
import os

import numpy as np
from PIL import Image

PAL = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "art", "style_tests", "ART-005", "e0",
                   "palette.json")


def to_lab(rgb):
    c = rgb.astype(np.float64) / 255.0
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    m = np.array([[0.4124, 0.3576, 0.1805], [0.2126, 0.7152, 0.0722], [0.0193, 0.1192, 0.9505]])
    xyz = c @ m.T / np.array([0.95047, 1.0, 1.08883])
    f = np.where(xyz > 0.008856, np.cbrt(xyz), 7.787 * xyz + 16 / 116)
    return np.stack([116 * f[..., 1] - 16, 500 * (f[..., 0] - f[..., 1]), 200 * (f[..., 1] - f[..., 2])], -1)


def load_palette():
    with open(PAL) as f:
        p = json.load(f)
    hexes = sorted({h for v in p["ramps"].values() for h in v})
    return np.array([[int(h[i:i + 2], 16) for i in (0, 2, 4)] for h in hexes], np.uint8)


def resample_factor(rgba):
    """The largest n in 2..8 for which the image is made of n x n blocks of one colour (an upscaled image)."""
    h, w = rgba.shape[:2]
    for n in (8, 6, 4, 3, 2):
        if h % n or w % n:
            continue
        blk = rgba[::n, ::n].repeat(n, 0).repeat(n, 1)
        if np.array_equal(blk, rgba):
            return n
    return 1


def check(path, density, pal, pal_lab, frames=1):
    rgba = np.array(Image.open(path).convert("RGBA"))
    h, w = rgba.shape[:2]
    a = rgba[..., 3]
    op = a > 0
    n_op = int(op.sum())
    if n_op == 0:
        return None
    rgb = rgba[..., :3]
    cols = rgb[op]
    uniq = np.unique(cols, axis=0)
    # palette conformance: exact, and within dE76 <= 3 of a palette colour
    lab = to_lab(cols)
    d = np.sqrt(((lab[:, None, :] - pal_lab[None, :, :]) ** 2).sum(-1)).min(1)
    exact = float((d < 0.5).mean())
    near = float((d <= 3.0).mean())
    partial = float(((a > 0) & (a < 255)).sum()) / n_op
    # orphans: an opaque pixel whose colour matches none of its opaque 8 neighbours (and has at least 3 of them)
    key = (rgb[..., 0].astype(np.int32) << 16) | (rgb[..., 1].astype(np.int32) << 8) | rgb[..., 2]
    key = np.where(op, key, -1)
    pk = np.pad(key, 1, constant_values=-1)
    same = np.zeros(key.shape, np.int32)
    nb = np.zeros(key.shape, np.int32)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dx == 0 and dy == 0:
                continue
            s = pk[1 + dy:1 + dy + h, 1 + dx:1 + dx + w]
            same += (s == key) & op
            nb += s >= 0
    orphan = float(((same == 0) & (nb >= 3) & op).sum()) / n_op
    # outline: share of silhouette texels (an opaque texel with a transparent 4-neighbour) with L* <= 35
    po = np.pad(op, 1)
    edge = op & (~po[:-2, 1:-1] | ~po[2:, 1:-1] | ~po[1:-1, :-2] | ~po[1:-1, 2:])
    full_lab = to_lab(rgb)
    dark_edge = float((full_lab[..., 0][edge] <= 35).mean()) if edge.any() else 0.0
    grid = (w // frames) % (density // 2) == 0 and h % (density // 2) == 0
    return {"file": os.path.relpath(path).replace("\\", "/"), "size": f"{w}x{h}", "colours": len(uniq),
            "pal_exact": exact, "pal_dE3": near, "partial_alpha": partial, "orphans": orphan,
            "resampled": resample_factor(rgba), "dark_outline": dark_edge, "half_tile_grid": grid}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--density", type=int, default=16)
    ap.add_argument("--frames", type=int, default=1, help="frames across, for strips")
    ap.add_argument("files", nargs="+")
    args = ap.parse_args()
    pal = load_palette()
    pal_lab = to_lab(pal)
    print("| file | size | colours | in palette (exact / dE<=3) | partial alpha | orphan px | resampled | dark outline | half-tile grid |")
    print("| --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for pattern in args.files:
        for p in sorted(glob.glob(pattern)) or [pattern]:
            r = check(p, args.density, pal, pal_lab, args.frames)
            if r is None:
                continue
            print(f"| {r['file']} | {r['size']} | {r['colours']} | {r['pal_exact']:.0%} / {r['pal_dE3']:.0%} | "
                  f"{r['partial_alpha']:.1%} | {r['orphans']:.2%} | {'no' if r['resampled'] == 1 else str(r['resampled']) + 'x'} | "
                  f"{r['dark_outline']:.0%} | {'yes' if r['half_tile_grid'] else 'no'} |")


if __name__ == "__main__":
    main()
