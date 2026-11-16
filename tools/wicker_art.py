"""CCH-WICKER-COVE-ALPHA-001: builds art/farm/town/ from the picked PixelLab candidates. No generations.

Run from the repo root:  python tools/wicker_art.py
Raw candidates are in art/style_tests/CCH-WICKER-COVE-ALPHA-001/raw/ (fetch.sh downloads them; jobs in
pixellab-assets.json). Buildings, boats and the two residents are used at their generated size (1 art px = 1 game
art px). The prop sheets came out about twice the farm's scale, so the pieces used are halved with an
outline-keeping 2x2 reduction.
"""
from collections import Counter
from pathlib import Path
from PIL import Image

RAW = Path("art/style_tests/CCH-WICKER-COVE-ALPHA-001/raw")
OUT = Path("art/farm/town")
OUT.mkdir(parents=True, exist_ok=True)

PICKS = {
    "store": "store/01.png",
    "inn": "inn/02.png",
    "house_a": "cottage/00.png",
    "house_b": "cottage/02.png",
    "house_c": "cottage/03.png",
    "house_d": "cottage/01.png",
    "market": "market/00.png",
    "boat_a": "boat/04.png",
    "boat_b": "boat/06.png",
    "thomas": "thomas/06.png",
    "edith": "edith/00.png",
}


def trim(im):
    bb = im.getbbox()
    return im.crop(bb) if bb else im


def binary_alpha(im):
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            px[x, y] = (r, g, b, 255 if a >= 128 else 0)
    return im


def halve(im):
    """2x2 -> 1 keeping dark outlines: a block with two or more dark pixels becomes the darkest of them,
    otherwise the most common opaque colour (transparent when fewer than two opaque)."""
    W, H = im.width // 2, im.height // 2
    src = im.load()
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    dst = out.load()
    for y in range(H):
        for x in range(W):
            block = [src[x * 2 + dx, y * 2 + dy] for dy in (0, 1) for dx in (0, 1)]
            opaque = [p for p in block if p[3] >= 128]
            if len(opaque) < 2:
                continue
            dark = [p for p in opaque if (p[0] * 299 + p[1] * 587 + p[2] * 114) / 1000 < 48]
            if len(dark) >= 2:
                dst[x, y] = min(dark, key=lambda p: sum(p[:3]))[:3] + (255,)
            else:
                dst[x, y] = Counter(p[:3] for p in opaque).most_common(1)[0][0] + (255,)
    return out


for name, rel in PICKS.items():
    im = binary_alpha(trim(Image.open(RAW / rel).convert("RGBA")))
    im.save(OUT / f"{name}.png")
    print(name, im.size)

# Pieces of the prop sheets (component boxes from raw/slice.py), halved.
PIECES = {
    "net_rack": ("props/02.png", (5, 23, 123, 107)),
    "bollard": ("props/01.png", (21, 22, 68, 72)),
    "lobster_pot": ("props/01.png", (73, 41, 115, 95)),
    "rope_coil": ("props/01.png", (12, 75, 78, 114)),
    "crate_pile": ("props/00.png", (7, 15, 119, 112)),
}
for name, (rel, box) in PIECES.items():
    im = Image.open(RAW / rel).convert("RGBA").crop(box)
    im = trim(halve(binary_alpha(im)))
    im.save(OUT / f"{name}.png")
    print(name, im.size)

# The two ground tilesets (Wang, 4x4 of 16 px tiles; corner masks in TownArt.WANG).
# They came out darker than the farm's ground, so they are lifted: the cobbles and quay stone more than the
# grass, so the street reads against it (the lower terrain of each sheet is told apart by its tile 6; in the
# street sheet PixelLab swapped them, so its lower terrain is the cobbles, and in the sea sheet the quay stone).
def lift(im, gain, add):
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            px[x, y] = tuple(min(255, int(c * gain + add)) for c in (r, g, b)) + (a,)
    return im

for k, (g_low, g_up) in {"street": ((1.42, 10), (1.18, 6)), "sea": ((1.22, 6), (1.12, 4))}.items():
    im = Image.open(RAW / f"tiles_{k}.png").convert("RGBA")
    low = im.crop((32, 16, 48, 32)).getcolors(4096)
    low_set = {c for _, c in low}
    px = im.load()
    out = im.copy()
    po = out.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            gain, add = g_low if (r, g, b, a) in low_set else g_up
            po[x, y] = tuple(min(255, int(c * gain + add)) for c in (r, g, b)) + (a,)
    out.save(OUT / f"tiles_{k}.png")
print("tiles ok")
