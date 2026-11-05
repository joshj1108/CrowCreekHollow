# ART-005 E2-PL (non-production): the free, deterministic cleanup of the PixelLab farmhouse section, its night
# window, its edit mask, its reconstructed pseudo-layers and the harness composites. Nothing here calls PixelLab.
#   python tools/art005_pl_cleanup.py
# Inputs (kept unedited):  art/style_tests/ART-005/pl/house/house_section_original.png   (Pro Flash create)
#                          art/style_tests/ART-005/pl/house/house_section_inpaint1.png   (Pro Flash inpaint, mask below)
# Outputs: pl/house/house_section_clean_day.png, _clean_night.png, inpaint1_mask.png, cleanup_diff.png,
#          pl/house/pseudo_layers/*.png (RECONSTRUCTED pseudo-layers, not artist-authored layers),
#          pl/32/house_day.png, house_night.png (the section pasted onto the size-correct placeholder house).
import json, os
from PIL import Image

ROOT = "art/style_tests/ART-005/"
H = ROOT + "pl/house/"
MASK = (116, 44, 44, 132)                  # x, y, w, h of inpaint 1 (the hole and the diagonal porch deck)
POST = (129, 142)                          # the inpainted porch post's columns (outline to outline), kept as drawn
WALL_ROWS = (48, 143)                      # wall rows inside the mask (below the eave beam, above the deck)
WINDOW = (48, 62, 84, 99)                  # x0, y0, x1, y1 of the window opening (frame included)
PASTE_AT = (28, 134)                       # where the section sits on the 384 x 320 placeholder house


def srgb_to_lab(c):
    def f(u):
        u /= 255.0
        return u / 12.92 if u <= 0.04045 else ((u + 0.055) / 1.055) ** 2.4
    r, g, b = (f(v) for v in c[:3])
    x = (0.4124 * r + 0.3576 * g + 0.1805 * b) / 0.95047
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    z = (0.0193 * r + 0.1192 * g + 0.9505 * b) / 1.08883
    g3 = lambda t: t ** (1 / 3) if t > 0.008856 else 7.787 * t + 16 / 116
    fx, fy, fz = g3(x), g3(y), g3(z)
    return (116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz))


def palette():
    p = json.load(open(ROOT + "e0/palette.json"))
    cols = set()
    for ramp in p["ramps"].values():
        for c in (ramp["colours"] if isinstance(ramp, dict) else ramp):
            cols.add(tuple(int(c.lstrip("#")[i:i + 2], 16) for i in (0, 2, 4)))
    return sorted(cols)


PAL = palette()
PAL_LAB = {c: srgb_to_lab(c) for c in PAL}


def nearest(c):
    lc = srgb_to_lab(c)
    return min(PAL, key=lambda p: sum((a - b) ** 2 for a, b in zip(PAL_LAB[p], lc)))


def L(c):
    return srgb_to_lab(c)[0]


def main():
    src = Image.open(H + "house_section_inpaint1.png").convert("RGBA")
    img = src.copy()
    px = img.load()
    W, Hh = img.size
    # 1. palette snap: inpainting takes no forced palette; put every opaque pixel back on the master palette
    snapped = 0
    for y in range(Hh):
        for x in range(W):
            r, g, b, a = px[x, y]
            if a and (r, g, b) not in PAL_LAB:
                px[x, y] = nearest((r, g, b)) + (255,)
                snapped += 1
    # 2. the seam: the inpainted wall came out lighter and smoother than the wall it continues. The planks run
    #    horizontally, so the wall columns just left of the mask are cloned into the strip on each side of the
    #    inpainted porch post (a hand clone, as an artist would do it); the post, deck and step stay as inpainted.
    seam_px = 0
    for y in range(*WALL_ROWS):
        for x in list(range(MASK[0], POST[0])) + list(range(POST[1] + 1, MASK[0] + MASK[2])):
            if not px[x, y][3]:
                continue
            sx = x - (POST[0] - MASK[0]) if x < POST[0] else MASK[0] - (POST[0] - MASK[0]) + (x - POST[1] - 1)
            if px[sx, y] != px[x, y]:
                px[x, y] = px[sx, y]
                seam_px += 1
    img.save(H + "house_section_clean_day.png")
    # 3. night: the window glass goes to the lantern ramp (spec 2 and 5: the one emissive exception), mullions kept
    glass = {(0x1e, 0x2a, 0x3a), (0x2c, 0x3a, 0x44), (0x3e, 0x5a, 0x64), (0x6a, 0x8a, 0x8a), (0xa8, 0xbc, 0xb4),
             (0x46, 0x52, 0x5a), (0x66, 0x70, 0x7a), (0x46, 0x60, 0x6a), (0x8a, 0x86, 0x7a), (0xb4, 0xb0, 0xa2)}
    night = img.copy()
    npx = night.load()
    gl = sorted({npx[x, y][:3] for y in range(WINDOW[1], WINDOW[3]) for x in range(WINDOW[0], WINDOW[2])
                 if npx[x, y][:3] in glass}, key=L)
    lamp = [(0xd9, 0x7a, 0x22), (0xf4, 0xb8, 0x50), (0xf6, 0xc4, 0x5a), (0xff, 0xf0, 0xc0)]
    lit = 0
    for y in range(WINDOW[1], WINDOW[3]):
        for x in range(WINDOW[0], WINDOW[2]):
            c = npx[x, y][:3]
            if c in glass:
                i = gl.index(c)
                npx[x, y] = lamp[min(len(lamp) - 1, i * len(lamp) // max(1, len(gl)))] + (255,)
                lit += 1
    night.save(H + "house_section_clean_night.png")
    # 4. the edit mask, and a diff of what the free cleanup changed (red = changed)
    m = Image.new("RGB", (W, Hh), (0, 0, 0))
    m.paste((255, 255, 255), (MASK[0], MASK[1], MASK[0] + MASK[2], MASK[1] + MASK[3]))
    m.save(H + "inpaint1_mask.png")
    d = Image.new("RGBA", (W, Hh), (0, 0, 0, 0))
    dp, sp = d.load(), src.load()
    changed = 0
    for y in range(Hh):
        for x in range(W):
            if sp[x, y] != px[x, y]:
                dp[x, y] = (255, 40, 40, 255)
                changed += 1
            elif sp[x, y][3]:
                v = int(L(sp[x, y][:3]) * 0.8)
                dp[x, y] = (v, v, v, 255)
    d.save(H + "cleanup_diff.png")
    # 5. RECONSTRUCTED pseudo-layers: split by value and edge, not recovered from any source file
    os.makedirs(H + "pseudo_layers", exist_ok=True)
    layers = {k: Image.new("RGBA", (W, Hh), (0, 0, 0, 0)) for k in ("line", "shade", "flat", "highlight", "fx_emissive")}
    lp = {k: v.load() for k, v in layers.items()}
    for y in range(Hh):
        for x in range(W):
            c = px[x, y]
            if not c[3]:
                continue
            edge = any(not (0 <= x + dx < W and 0 <= y + dy < Hh) or px[x + dx, y + dy][3] == 0
                       for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
            l = L(c[:3])
            k = "line" if (edge or l < 12) else "shade" if l < 28 else "flat" if l < 48 else "highlight"
            lp[k][x, y] = c
            if npx[x, y] != c:
                lp["fx_emissive"][x, y] = npx[x, y]
    for k, v in layers.items():
        v.save(H + "pseudo_layers/%s.png" % k)
    open(H + "pseudo_layers/README.txt", "w").write(
        "RECONSTRUCTED pseudo-layers made by tools/art005_pl_cleanup.py from the flattened cleaned PNG.\n"
        "They are a value/edge split (line = silhouette edge or L* < 12; shade < 28; flat < 48; highlight above;\n"
        "fx_emissive = the night window pixels). They are NOT original artist-authored editable layers and do not\n"
        "separate logical materials. PixelLab returned one flattened PNG per call.\n")
    # 6. the harness composites: the section on the size-correct placeholder house (32 px), day and night
    os.makedirs(ROOT + "pl/32", exist_ok=True)
    for state, sec in (("day", img), ("night", night)):
        base = Image.open(ROOT + "placeholder/32/house_%s.png" % state).convert("RGBA")
        base.alpha_composite(sec, PASTE_AT)
        base.save(ROOT + "pl/32/house_%s.png" % state)
    print("snapped %d, seam %d, night glass %d, changed vs inpaint1 %d of %d opaque" %
          (snapped, seam_px, lit, changed, sum(1 for p in src.get_flattened_data() if p[3])))


if __name__ == "__main__":
    main()
