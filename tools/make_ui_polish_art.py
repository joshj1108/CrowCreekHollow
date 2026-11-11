"""UI-FINAL-001: the gear icons' material variants, a few new gear icons, and the skill medallion.

    python tools/make_ui_polish_art.py            # writes art/ui/icons_gear.png and art/ui/skill_medallion_(rim|disc).png
    python tools/make_ui_polish_art.py preview    # also a 5x preview sheet in art/style_tests/UI-FINAL-001/review/

No generation: everything here is made from the existing SpriteCook item icons (art/ui/icons.png) or drawn by
hand on a 16 px grid below, in the icons' own outline colour and top-left light.

- Material variants: the same piece in copper or iron (or bark and amber for the wood-and-resin pieces), so the
  Craft grid's helm, cuirass, greaves and boots of each tier no longer share one picture. A variant keeps the
  original's outline and shading and only remaps each pixel's lightness onto the material's 5-step ramp.
- New pieces, drawn by hand: a kettle helm and a cuirass (the metal head and chest pieces were a felt hat and a
  cloth coat), a hunting knife and a sharpened stick (both were the iron sword).
- The skill medallion (20 x 20, shown at 3x behind a skill's icon): an iron rim and a disc the skill's tint
  colours (the disc is drawn in light greys and multiplied by the tint), so a skill reads as an emblem, not an item.

icons_gear.png is a 4-wide atlas of 16 px cells in GEAR_ICONS order (UiSkin.GEAR_ICONS mirrors it).
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UI = os.path.join(ROOT, "art", "ui")
SRC_ORDER = [
    "axe", "pick", "hoe", "trowel", "hose", "rod", "hammer", "broom", "sword", "shield", "bow", "arrow",
    "lantern", "glove", "pack", "anvil", "hat", "shirt", "pants", "boots", "pendant", "bracer", "bandage", "bowl",
]
OUTLINE = (29, 22, 17, 255)

RAMPS = {
    "copper": ["3a1d10", "63351c", "8e4e28", "b06e3e", "cc9464"],
    "iron": ["1e2226", "3c424a", "5d656f", "828b95", "a8b0b8"],
    "bark": ["2e1d12", "4f3220", "6f4a2e", "8f6a44", "b08c62"],
    "amber": ["3a1e08", "6e3a10", "9e5a1c", "c47e2c", "dca456"],
}

# Hand-drawn pieces: 0 is the outline, 1-4 the material's ramp from dark to light (light from the top left).
HELM = [
    "................",
    "................",
    "................",
    ".....000000.....",
    "....04443320....",
    "...0444333210...",
    "...0443332210...",
    "..043433222110..",
    "..043332222110..",
    ".00111311131100.",
    ".04333333332210.",
    "..000000000000..",
    "......0220......",
    "......0110......",
    ".......00.......",
    "................",
]
CUIRASS = [
    "................",
    "...000....000...",
    "..04320000321O..",
    ".0444433333221O.",
    ".0444433332211O.",
    ".0444333322211O.",
    "..043433322210..",
    "..044333222110..",
    "..043333222110..",
    "..011111111110..",
    "..043332222110..",
    "...0333222210...",
    "....00000000....",
    "................",
    "................",
    "................",
]
# The knife and the stick, laid along the diagonal from the bottom left, three px thick: (x, y, shade). The
# outline is added round them.
def _diag(parts: list) -> list:
    """parts: (steps, upper shade, lower shade) runs from the handle end; each step is one px up and right."""
    cells, i = [], 0
    for steps, top, low in parts:
        for _ in range(steps):
            cells.append((3 + i, 12 - i, top))
            cells.append((3 + i, 13 - i, low))
            cells.append((4 + i, 13 - i, low))
            i += 1
    return cells


KNIFE = _diag([(4, "w3", "w2"), (1, "m1", "m1"), (5, "m4", "m3")]) + [(6, 8, "m2"), (9, 11, "m2"), (13, 2, "m4")]
STICK = _diag([(7, "w3", "w2"), (2, "p4", "p3")]) + [(12, 3, "p4")]
STROKE = {"w1": "4f3220", "w2": "6f4a2e", "w3": "8f6a44", "m1": "3c424a", "m2": "5d656f", "m3": "828b95",
          "m4": "a8b0b8", "p2": "b08c62", "p3": "c8aa80", "p4": "dcc49c"}

# The variants and new pieces, in atlas order: name -> how it is made.
GEAR_ICONS = [
    ("hat_bark", ("recolor", "hat", "bark")),
    ("helm_copper", ("draw", HELM, "copper")),
    ("helm_iron", ("draw", HELM, "iron")),
    ("shirt_bark", ("recolor", "shirt", "bark")),
    ("cuirass_copper", ("draw", CUIRASS, "copper")),
    ("cuirass_iron", ("draw", CUIRASS, "iron")),
    ("pants_bark", ("recolor", "pants", "bark")),
    ("pants_copper", ("recolor", "pants", "copper")),
    ("pants_iron", ("recolor", "pants", "iron")),
    ("boots_copper", ("recolor", "boots", "copper")),
    ("boots_iron", ("recolor", "boots", "iron")),
    ("pendant_amber", ("recolor", "pendant", "amber")),
    ("pendant_copper", ("recolor", "pendant", "copper")),
    ("pendant_iron", ("recolor", "pendant", "iron")),
    ("bracer_copper", ("recolor", "bracer", "copper")),
    ("glove_iron", ("recolor", "glove", "iron")),
    ("shield_copper", ("recolor", "shield", "copper")),
    ("shield_iron", ("recolor", "shield", "iron")),
    ("sword_copper", ("recolor", "sword", "copper")),
    ("knife", ("strokes", KNIFE)),
    ("stake", ("strokes", STICK)),
]


def _hex(h: str) -> tuple:
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def _src(name: str) -> Image.Image:
    atlas = Image.open(os.path.join(UI, "icons.png")).convert("RGBA")
    i = SRC_ORDER.index(name)
    return atlas.crop(((i % 4) * 16, (i // 4) * 16, (i % 4) * 16 + 16, (i // 4) * 16 + 16))


def recolor(name: str, ramp: str) -> Image.Image:
    """The icon with each inked pixel's lightness put on the ramp; the near-black outline stays as it is."""
    src = _src(name)
    px = [src.getpixel((x, y)) for y in range(16) for x in range(16)]
    lums = [0.299 * r + 0.587 * g + 0.114 * b for r, g, b, a in px if a > 0]
    lo, hi = min(lums), max(lums)
    out = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    steps = [_hex(h) for h in RAMPS[ramp]]
    for i, (r, g, b, a) in enumerate(px):
        if a == 0:
            continue
        lum = 0.299 * r + 0.587 * g + 0.114 * b
        if lum < 40:            # the outline
            out.putpixel((i % 16, i // 16), (r, g, b, a))
            continue
        t = (lum - lo) / max(1.0, hi - lo)
        k = min(4, max(1, int(round(t * 4))))
        out.putpixel((i % 16, i // 16), steps[k][:3] + (a,))
    return out


def draw(rows: list, ramp: str) -> Image.Image:
    out = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    steps = [_hex(h) for h in RAMPS[ramp]]
    for y, row in enumerate(rows):
        for x, c in enumerate(row):
            if c in "0O":
                out.putpixel((x, y), OUTLINE)
            elif c in "1234":
                out.putpixel((x, y), steps[int(c)])
    return out


def strokes(cells: list) -> Image.Image:
    out = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
    for x, y, shade in cells:
        out.putpixel((x, y), _hex(STROKE[shade]))
    _outline(out)
    return out


def _outline(img: Image.Image) -> None:
    filled = {(x, y) for y in range(16) for x in range(16) if img.getpixel((x, y))[3] > 0}
    for x, y in list(filled):
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            p = (x + dx, y + dy)
            if 0 <= p[0] < 16 and 0 <= p[1] < 16 and p not in filled:
                img.putpixel(p, OUTLINE)


def gear_atlas() -> Image.Image:
    rows = (len(GEAR_ICONS) + 3) // 4
    atlas = Image.new("RGBA", (64, rows * 16), (0, 0, 0, 0))
    for i, (name, how) in enumerate(GEAR_ICONS):
        if how[0] == "recolor":
            cell = recolor(how[1], how[2])
        elif how[0] == "draw":
            cell = draw(how[1], how[2])
        else:
            cell = strokes(how[1])
        atlas.alpha_composite(cell, ((i % 4) * 16, (i // 4) * 16))
    return atlas


def medallion() -> tuple:
    """The rim (fixed iron colours) and the disc (light greys, multiplied by the skill's tint in the game)."""
    rim = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
    disc = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
    iron = [_hex(h) for h in RAMPS["iron"]]
    c = 9.5
    for y in range(20):
        for x in range(20):
            dx, dy = x - c, y - c
            d = (dx * dx + dy * dy) ** 0.5
            lit = (-dx - dy) / 13.5          # light from the top left
            if d <= 9.6 and d > 8.6:
                rim.putpixel((x, y), OUTLINE)
            elif 7.2 < d <= 8.6:
                rim.putpixel((x, y), iron[3] if lit > 0.35 else (iron[2] if lit > -0.35 else iron[1]))
            elif 6.4 < d <= 7.2:
                rim.putpixel((x, y), OUTLINE[:3] + (200,))
            elif d <= 6.4:
                g = 235 if lit > 0.3 else (205 if lit > -0.25 else 175)
                disc.putpixel((x, y), (g, g, g, 255))
    # Four rivets on the rim.
    for x, y in ((9, 1), (17, 9), (9, 17), (1, 9)):
        rim.putpixel((x, y), iron[4])
    return rim, disc


def preview(atlas: Image.Image, rim: Image.Image, disc: Image.Image) -> None:
    out = os.path.join(ROOT, "art", "style_tests", "UI-FINAL-001", "review")
    os.makedirs(out, exist_ok=True)
    bg = (40, 32, 26, 255)
    src = Image.open(os.path.join(UI, "icons.png")).convert("RGBA").crop((0, 0, 64, 96))
    sheet = Image.new("RGBA", (64 + 8 + 64 + 8 + 24 * 3, max(96, atlas.height) + 8), bg)
    sheet.alpha_composite(src, (4, 4))
    sheet.alpha_composite(atlas, (76, 4))
    tints = ["4f6b3a", "6b4a3a", "8a6a3a"]
    for i, t in enumerate(tints):
        tinted = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
        col = _hex(t)
        for y in range(20):
            for x in range(20):
                p = disc.getpixel((x, y))
                if p[3]:
                    tinted.putpixel((x, y), tuple(p[k] * col[k] // 255 for k in range(3)) + (255,))
        tinted.alpha_composite(rim)
        sheet.alpha_composite(tinted, (148 + i * 24, 4))
    sheet = sheet.resize((sheet.width * 5, sheet.height * 5), Image.NEAREST)
    sheet.save(os.path.join(out, "gear_icons_preview.png"))
    print("preview:", os.path.join(out, "gear_icons_preview.png"))


if __name__ == "__main__":
    atlas = gear_atlas()
    atlas.save(os.path.join(UI, "icons_gear.png"))
    rim, disc = medallion()
    rim.save(os.path.join(UI, "skill_medallion_rim.png"))
    disc.save(os.path.join(UI, "skill_medallion_disc.png"))
    print("wrote art/ui/icons_gear.png (%d icons), skill_medallion_rim.png, skill_medallion_disc.png" % len(GEAR_ICONS))
    if "preview" in sys.argv:
        preview(atlas, rim, disc)
