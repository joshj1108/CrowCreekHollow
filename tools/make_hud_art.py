# UI-OVERHAUL-001 Phase 3 (HUD): draws the HUD's pixel art by hand, no generation credits.
#   art/ui/hud_icons.png  one row of 10 x 10 icons (outlined, lit from the top left), shown at 2x (20 px)
#   art/ui/hud_plate.png  the HUD's thin plate: a 16 x 16 9-slice with a 5 px corner (outline, iron rim lit on
#                         its top and left, a dark inner line, dark wood, a brass rivet in each corner), at 1:1
# Run: python tools/make_hud_art.py   (then import once with Godot --import)
# The order of ICONS must match HudIcon.ATLAS in scripts/hud_icon.gd.
from PIL import Image

CELL = 10
PAL = {
    "O": "1a120c",                                   # outline
    "R": "c0453c", "H": "e88a7a", "D": "7a2420",     # heart: red, light, dark
    "M": "d8d0b8", "S": "9a8e74",                    # moon: pale, shade
    "G": "d8b050", "L": "f2d27a", "K": "8a6428",     # coin: gold, light, dark
    "T": "b07a44", "U": "dcae6c", "V": "6e4422",     # loaf: crust, light, dark
    "B": "5f98c8", "b": "b8dcf0", "d": "34628a",     # water: blue, light, dark
    "F": "e0803a", "Y": "f2c860", "r": "a8402a",     # flame: orange, yellow, ember
    "W": "e8dcc0", "w": "a89c80",                    # wax, wax shade
    "N": "4f2e1a", "k": "7a4a2a", "P": "e8dcc0", "Q": "b8443a",   # journal: spine, leather, pages, ribbon
    "E": "f08070", "X": "c0392b", "Z": "6e1a14",     # wax seal
    "C": "c9ccd4", "c": "eceef2", "x": "858a96",     # cloud
    "A": "7fb8e0",                                   # rain
    "I": "eef4fa",                                   # snow
    "f": "9ea2aa",                                   # fog
}

ICONS = {
    "heart": [
        ".OO....OO.",
        "OHRO..ORRO",
        "OHRROORRRO",
        "ORRRRRRRRO",
        "ORRRRRRRDO",
        ".ORRRRRDO.",
        "..ORRRDO..",
        "...ORDO...",
        "....OO....",
        "..........",
    ],
    "moon": [
        "...OOOO...",
        "..OMMMMO..",
        ".OMMMMOO..",
        ".OMMMO....",
        ".OMMMO....",
        ".OMMMO....",
        ".OSMMO....",
        ".OSMMMOO..",
        "..OSSSSO..",
        "...OOOO...",
    ],
    "coin": [
        "..OOOOOO..",
        ".OLLGGGGO.",
        "OLLGGGGGKO",
        "OLGGKKGGKO",
        "OGGKGGKGKO",
        "OGGKGGKGKO",
        "OGGGKKGGKO",
        "OGGGGGGKKO",
        ".OKKKKKKO.",
        "..OOOOOO..",
    ],
    "food": [
        "..........",
        "...OOOO...",
        "..OUUUUOO.",
        ".OUTUTUUTO",
        "OUTUTUTUTO",
        "OTTTTTTTVO",
        "OTTTTTTVVO",
        ".OVVVVVVO.",
        "..OOOOOO..",
        "..........",
    ],
    "water": [
        "....OO....",
        "...OBBO...",
        "...ObBO...",
        "..ObBBBO..",
        "..ObBBBO..",
        ".ObBBBBBO.",
        ".ObBBBBdO.",
        ".OBBBBBdO.",
        "..OddddO..",
        "...OOOO...",
    ],
    "warmth": [
        "....O.....",
        "...OFO....",
        "...OFFO.O.",
        "..OFFFOOFO",
        "..OFYFFFFO",
        ".OFFYYFFO.",
        ".OFYYYYFO.",
        ".OrFYYFrO.",
        "..OrrrrO..",
        "...OOOO...",
    ],
    "nerve": [
        "....O.....",
        "...OYO....",
        "...OFO....",
        "...OOOO...",
        "...OWWO...",
        "...OWwO...",
        "...OWwO...",
        "..OOWwOO..",
        ".OwwwwwwO.",
        "..OOOOOO..",
    ],
    "book": [
        ".OOOOOOO..",
        ".ONkkkkPO.",
        ".ONkkkkPO.",
        ".ONkGGkPO.",
        ".ONkGGkPO.",
        ".ONkkkkPO.",
        ".ONkkkkPO.",
        ".ONkkkkPO.",
        ".OOOQOOOO.",
        "....Q.....",
    ],
    "seal": [
        "......OOO.",
        ".....OEXXO",
        ".....OXXXO",
        ".....OXXZO",
        "......OOO.",
        "..........",
        "..........",
        "..........",
        "..........",
        "..........",
    ],
    "sun": [
        "....YY....",
        ".Y......Y.",
        "...OOOO...",
        "..OLLGGO..",
        "Y.OLGGGO.Y",
        "Y.OGGGKO.Y",
        "..OGGKKO..",
        "...OOOO...",
        ".Y......Y.",
        "....YY....",
    ],
    "cloud": [
        "..........",
        "....OOO...",
        "...OcccO..",
        ".OOccCCCO.",
        "OccCCCCCCO",
        "OcCCCCCCxO",
        "OCCCCCCxxO",
        ".OxxxxxxO.",
        "..OOOOOO..",
        "..........",
    ],
    "rain": [
        "....OOO...",
        "...OcccO..",
        ".OOccCCCO.",
        "OccCCCCCCO",
        "OCCCCCCxxO",
        ".OOOOOOOO.",
        "..A..A..A.",
        ".A..A..A..",
        "..........",
        "..A..A....",
    ],
    "snow": [
        "....OOO...",
        "...OcccO..",
        ".OOccCCCO.",
        "OccCCCCCCO",
        "OCCCCCCxxO",
        ".OOOOOOOO.",
        "..I...I...",
        "....I...I.",
        "..I...I...",
        "....I.....",
    ],
    "fog": [
        "..........",
        ".ffffff...",
        "..........",
        "...fffffff",
        "..........",
        "ffffff....",
        "..........",
        "..fffffff.",
        "..........",
        "..........",
    ],
}


def rgb(h, a=255):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (a,)


def icons():
    im = Image.new("RGBA", (CELL * len(ICONS), CELL), (0, 0, 0, 0))
    px = im.load()
    for n, (name, rows) in enumerate(ICONS.items()):
        assert len(rows) == CELL and all(len(r) == CELL for r in rows), name
        for y, row in enumerate(rows):
            for x, ch in enumerate(row):
                if ch != ".":
                    px[n * CELL + x, y] = rgb(PAL[ch])
    im.save("art/ui/hud_icons.png")


def plate():
    size, n = 16, 15
    im = Image.new("RGBA", (size, size))
    px = im.load()
    for i in range(size):
        for j in range(size):
            edge = min(i, j, n - i, n - j)
            if edge == 0:
                c = rgb("0b0806")
            elif edge == 1:
                lit = (i == 1 or j == 1) and not (i == n - 1 or j == n - 1)
                c = rgb("8a7660" if lit else "4e4234")
            elif edge == 2:
                c = rgb("120d09")
            else:
                c = rgb("1c150f", 232)
            px[i, j] = c
    for (x, y) in ((3, 3), (n - 3, 3), (3, n - 3), (n - 3, n - 3)):
        px[x, y] = rgb("c8a058")
    im.save("art/ui/hud_plate.png")


icons()
plate()
print("wrote art/ui/hud_icons.png (%d icons) and art/ui/hud_plate.png" % len(ICONS))
