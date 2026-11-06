"""ART-OVERHAUL-001 Stage C corrections (C2): game files derived from the kept Stage C art.

1. art/farm/cave_int/floor_var.png: a strip of six 16 px floor variants built from floor.png. Every variant keeps
   the tile's outer two pixels exactly, so any mix still tiles seamlessly. The one bright crescent that made the
   floor read as a grid is lifted out (patched from a plain band of the same tile) and put back only on some
   variants, mirrored or moved, or left out.
2. art/farm/cave_int/atlas.png: the iron pieces' rust streaks are lifted a step, so iron reads as ore and not as
   dark rock at the edge of the lantern's ring. Only pixels already rust-coloured change; the outline is untouched.
   Re-running is safe: the iron cuts are rebuilt from art/style_tests/ART-OVERHAUL-001/C/raw/iron via the stored
   originals in C2/iron_orig.png on the first run.

Run from the repo root: python tools/aoh_cave_c2.py
"""
import json
import os
from PIL import Image

DIR = "art/farm/cave_int/"
WORK = "art/style_tests/ART-OVERHAUL-001/C2/"


def lum(c):
    return 0.3 * c[0] + 0.59 * c[1] + 0.11 * c[2]


def floor_variants():
    t = Image.open(DIR + "floor.png").convert("RGBA")
    src = t.load()
    # The crescent sits in rows 5-8, columns 4-13; rows 9-12 of the same columns are plain grain.
    clean = t.copy()
    cp = clean.load()
    for y in range(5, 9):
        for x in range(4, 14):
            cp[x, y] = src[x, y + 4]
    # The mark as a stamp: its bright pixels and its one dark under-pixel, relative to (5, 6); rows 6-7, columns 5-12.
    stamp = []
    for y in range(6, 8):
        for x in range(5, 13):
            c = src[x, y]
            if lum(c) > 115 or (lum(c) < 80 and y == 7):
                stamp.append((x - 5, y - 6, c))

    def stamped(ox, oy, flip):
        im = clean.copy()
        p = im.load()
        w = max(dx for dx, _, _ in stamp)
        for dx, dy, c in stamp:
            x = ox + (w - dx if flip else dx)
            y = oy + dy
            assert 2 <= x <= 13 and 2 <= y <= 13, (x, y)
            p[x, y] = c
        return im

    # The specks at rows 12-13 (columns 4-6) are also lifted from the plain variant, so it has no mark at all.
    plain = clean.copy()
    pp = plain.load()
    for y in (12, 13):
        for x in range(3, 8):
            pp[x, y] = src[x, y - 3]
    variants = [t, clean, plain, stamped(4, 6, True), stamped(3, 10, False), stamped(5, 4, True)]
    for v in variants:  # every variant keeps the original edge ring
        vp = v.load()
        for i in range(16):
            for j in (0, 1, 14, 15):
                assert vp[i, j] == src[i, j] and vp[j, i] == src[j, i]
    strip = Image.new("RGBA", (16 * len(variants), 16))
    for i, v in enumerate(variants):
        strip.paste(v, (16 * i, 0))
    strip.save(DIR + "floor_var.png")
    return len(variants)


def iron_lift():
    data = json.load(open(DIR + "cave_int.json"))
    atlas = Image.open(DIR + "atlas.png").convert("RGBA")
    os.makedirs(WORK, exist_ok=True)
    orig_path = WORK + "atlas_orig.png"
    if not os.path.exists(orig_path):
        atlas.save(orig_path)
    orig = Image.open(orig_path).convert("RGBA")
    o = orig.load()
    a = atlas.load()
    changed = 0
    for pc in data["pieces"]:
        if pc["kind"] != "iron":
            continue
        for y in range(pc["y"], pc["y"] + pc["h"]):
            for x in range(pc["x"], pc["x"] + pc["w"]):
                r, g, b, al = o[x, y]
                if al == 0:
                    continue
                # Rust: red clearly above blue and not an outline. Lift it a step toward a warm ochre.
                if r > b + 18 and r > 60:
                    a[x, y] = (min(255, int(r * 1.5 + 30)), min(255, int(g * 1.32 + 14)), int(b * 0.95), al)
                    changed += 1
                else:
                    a[x, y] = (r, g, b, al)
    atlas.save(DIR + "atlas.png")
    return changed


if __name__ == "__main__":
    print("floor variants:", floor_variants())
    print("iron pixels lifted:", iron_lift())
