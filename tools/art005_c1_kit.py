# ART-005 C1, optional study (non-production, zero generations): a hand-authored wood-shake roof kit. A design study
# only. It does not replace the selected S3 roof A and is not a house pipeline. Everything is drawn by rule into
# index colours taken from S3 roof A's own palette, so value steps stay intentional.
#   python tools/art005_c1_kit.py
# Writes art/style_tests/ART-005/pl/g7/c1/kit/: kit_pieces.png (the pieces, 1 px = 1 art px) and
# kit_study.png (pieces 6x, a 192 x 88 assembled field at 1:1 and 3x beside the same-size crop of S3 roof A).
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402
import art005_s2_review as r2  # noqa: E402

ROOT = m0.ROOT
OUT = os.path.join(ROOT, "pl", "g7", "c1", "kit")
S3 = os.path.join(ROOT, "pl", "g6", "shake", "32", "house_day.png")
EXPO = 9            # course exposure (S3 roof A: 10 courses over rows 58-146)
FW, FH = 192, 88    # study field = the west half of S3's roof field (x 0-191 of rows 58-145)


def ramp():
    """Seven value steps, darkest first, from S3 roof A's own most-used colours (one hue family)."""
    im = np.array(Image.open(S3).convert("RGBA"))[58:146, 20:364]
    c, n = np.unique(im[..., :3].reshape(-1, 3), axis=0, return_counts=True)
    top = c[np.argsort(-n)[:16]]
    top = top[np.argsort(top @ [0.299, 0.587, 0.114])]
    idx = np.linspace(0, len(top) - 1, 7).round().astype(int)
    return [tuple(int(v) for v in top[i]) for i in idx]


# Piece = (width, shape rule). 0 = transparent, 1 = outline/gap, 2-6 = face values (3 = base).
def piece(w, kind, rng):
    p = np.full((EXPO + 2, w), 3, np.int8)     # +2: the butt edge and its cast shadow rows
    p[:, 0] = 1                                # keyway (joint) on the left
    p[EXPO, :] = 2                             # butt edge, dark
    p[EXPO + 1, :] = 1                         # shadow cast on the course below
    p[0:2, 1:] = 2                             # under the course above: shadowed top
    p[2, 1:] = 4                               # catch-light just below the overlap
    if kind == "taper":                        # older shake: butt corner worn off
        p[EXPO - 1, -1] = 2
        p[EXPO, -1] = 1
    if kind == "split":                        # a check crack from the butt
        x = 1 + rng.integers(1, max(2, w - 2))
        p[EXPO - 3:EXPO + 1, x] = 1
        p[EXPO - 4, x] = 2
    if kind == "cup":                          # cupped: lit lip on one side
        p[3:EXPO, 1] = 4
        p[3:EXPO, -1] = 2
    for _ in range(max(1, w // 6)):            # sparse grain: short vertical dark runs, never full-length
        x = 1 + rng.integers(0, w - 1)
        y = 3 + rng.integers(0, 3)
        p[y:y + 3 + rng.integers(0, 3), x] = 2
    return p


KINDS = ["plain", "taper", "split", "cup", "plain", "taper"]
WIDTHS = [6, 8, 9, 11, 12, 14]


def assemble(rng):
    f = np.full((FH, FW), 1, np.int8)
    joints_above = []
    # laid like a real roof: eave course first, each course above it then overlaps it with its butt and shadow
    for row, y in enumerate(reversed(range(-2, FH, EXPO))):
        x = -rng.integers(0, 8)
        joints = []
        while x < FW:
            # widths in random order; take the first whose right joint is not within 2 px of a joint above
            order = rng.permutation(WIDTHS)
            w = int(next((v for v in order if not any(abs(x + v - j) <= 2 for j in joints_above)), order[0]))
            pc = piece(w, KINDS[int(rng.integers(0, len(KINDS)))], rng)
            dy = int(rng.integers(0, 2))           # butt lines step by 0-1 px per shake, not one ruled line
            for yy in range(pc.shape[0]):
                for xx in range(w):
                    if 0 <= y + dy + yy < FH and 0 <= x + xx < FW:
                        f[y + dy + yy, x + xx] = pc[yy, xx]
            joints.append(x + w)
            x += w
        joints_above = joints
    # broad, intentional shading: lighter up-slope and to the west (sun from the upper left), and two soft
    # weathered (silvered) zones; each a whole-step shift of the face values, never per-pixel noise
    yy, xx = np.mgrid[0:FH, 0:FW]
    shade = np.zeros((FH, FW))
    shade += np.where(yy < FH * 0.35, 1, 0)
    shade -= np.where(yy > FH * 0.8, 1, 0)
    for cx, cy, r in ((48, 40, 26), (150, 60, 20)):
        shade += np.where(((xx - cx) / 1.6) ** 2 + (yy - cy) ** 2 < r * r, 1, 0)
    face = f >= 2
    f = np.where(face, np.clip(f + shade.astype(np.int8), 2, 6), f)
    return f


def paint(idx, pal):
    lut = np.array([pal[0], pal[0], pal[1], pal[2], pal[3], pal[4], pal[5]], np.uint8)
    return Image.fromarray(lut[idx], "RGB").convert("RGBA")


def main():
    os.makedirs(OUT, exist_ok=True)
    gi = os.path.join(OUT, ".gdignore")
    pal = ramp()
    rng = np.random.default_rng(7)
    pieces = [piece(w, k, rng) for w, k in zip(WIDTHS, KINDS)]
    strip = np.zeros((EXPO + 2, sum(WIDTHS) + 2 * len(WIDTHS)), np.int8)
    x = 0
    for p in pieces:
        strip[:, x:x + p.shape[1]] = p
        x += p.shape[1] + 2
    ps = paint(strip, pal)
    a = np.array(ps)
    a[strip == 0, 3] = 0
    ps = Image.fromarray(a, "RGBA")
    ps.save(os.path.join(OUT, "kit_pieces.png"))
    field = paint(assemble(np.random.default_rng(11)), pal)
    s3 = Image.open(S3).convert("RGBA").crop((0, 58, FW, 58 + FH))
    up = lambda im, k: im.resize((im.width * k, im.height * k), Image.NEAREST)
    sw = Image.new("RGBA", (7 * 20, 20), r2.BG + (255,))
    d = ImageDraw.Draw(sw)
    for i, c in enumerate(pal):
        d.rectangle((i * 20, 0, i * 20 + 17, 17), fill=c)
    one = Image.new("RGBA", (FW * 2 + 16, FH), r2.BG + (255,))
    one.alpha_composite(s3, (0, 0))
    one.alpha_composite(field, (FW + 16, 0))
    title = "ART-005 C1 study: hand-authored shake-roof kit (0 generations)"
    note = ("Six pieces, 6-14 px wide, 9 px exposure (S3's course height): dark keyway joint, dark butt edge with a 1 px "
            "cast shadow, shadowed top under the course above, one catch-light row; variants plain, tapered (worn butt "
            "corner), split (check crack), cupped; sparse short grain. Assembly: random widths, a joint never within 2 px "
            "of a joint above, butt lines stepping 0-1 px per shake. Shading is broad: one value step lighter up-slope, "
            "one darker at the eave, two soft silvered zones, whole palette steps only. Colours: seven steps of S3 roof "
            "A's own palette. NOT a replacement for roof A: a direction for a possible future hand-made roof.")
    import textwrap
    blocks = [("kit pieces, 6x   |   palette (S3 roof A colours)", None),
              ("1:1   S3 roof A crop  |  kit field (192 x 88)", one), ("3x   S3 roof A crop", up(s3, 3)),
              ("3x   kit field", up(field, 3))]
    top = Image.new("RGBA", (up(ps, 6).width + 40 + up(sw, 2).width, up(ps, 6).height), r2.BG + (255,))
    top.alpha_composite(up(ps, 6), (0, 0))
    top.alpha_composite(up(sw, 2), (up(ps, 6).width + 40, 0))
    blocks[0] = (blocks[0][0], top)
    width = 16 * 2 + max(b.width for _, b in blocks)
    lines = textwrap.wrap(note, int((width - 32) / 7.2))
    h = 48 + 18 * len(lines) + 8 + sum(26 + b.height + 12 for _, b in blocks) + 16
    out = Image.new("RGBA", (width, h), r2.BG + (255,))
    d = ImageDraw.Draw(out)
    d.text((16, 12), title, font=r2.FB, fill=r2.FG)
    for i, ln in enumerate(lines):
        d.text((16, 44 + 18 * i), ln, font=r2.FS, fill=r2.DIM)
    y = 48 + 18 * len(lines) + 8
    for cap, b in blocks:
        d.text((16, y + 4), cap, font=r2.F, fill=r2.FG)
        out.alpha_composite(b, (16, y + 26))
        y += 26 + b.height + 12
    out.convert("RGB").save(os.path.join(OUT, "kit_study.png"))
    print("kit_study.png", out.size)
    if not os.path.exists(gi):
        open(gi, "w").close()


if __name__ == "__main__":
    main()
