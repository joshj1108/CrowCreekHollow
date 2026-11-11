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


# --- Phase 3 final (HUD polish): the HUD's instrument frame, recessed meter tracks, the hotbar's empty slot ---
FRAME = 32          # hud_frame.png: a 9-slice with a 10 px corner, edges and centre tiled
CORNER = 10


def _px(c):
    return rgb(c) if isinstance(c, str) else c


def frame():
    """A compact handcrafted frame at 1:1, in the kit panel's language: an outline, a 3 px walnut rail lit on
    its top and left with a little grain, a thin muted-brass line, a dark recess, then dark walnut planks
    (alpha 232 as before). An iron L-bracket with a brass rivet caps each corner."""
    n = FRAME - 1
    im = Image.new("RGBA", (FRAME, FRAME))
    px = im.load()
    for i in range(FRAME):
        for j in range(FRAME):
            edge = min(i, j, n - i, n - j)
            top_left = (j == edge or i == edge) and not (j == n - edge or i == n - edge)
            bottom_right = (j == n - edge or i == n - edge) and not (j == edge or i == edge)
            t = i if (j == edge or j == n - edge) else j          # position along the edge, for the grain
            if edge == 0:
                c = "0b0806"
            elif edge in (1, 2, 3):
                base = {1: ("7d6047", "5a4330", "3e2c1e"), 2: ("5e4532", "54402f", "3a291c"),
                        3: ("3a2a1d", "33251a", "241910")}[edge]
                c = base[0] if top_left else (base[2] if bottom_right else base[1])
                if edge == 2 and (t * 5 + 3) % 9 == 0:
                    c = "3a2a1d"                                   # a grain mark
                if edge == 1 and (t * 7 + 1) % 13 == 0 and not bottom_right:
                    c = "6a5039"
            elif edge == 4:
                c = "8a6c40" if top_left else ("5a4326" if bottom_right else "725832")
            elif edge == 5:
                c = "070504"
            else:
                c = ("17110c", 232) if j % 12 == 11 else (("221a12", 232) if (i * 3 + j * 7) % 23 == 0 else ("1c150f", 232))
                c = rgb(*c)
            px[i, j] = _px(c)
    # The iron brackets: arms 3 px wide over the rail, 9 px long, with a rivet in the corner and a stud at each end.
    for (sx, sy) in ((0, 0), (1, 0), (0, 1), (1, 1)):
        for a in range(CORNER):
            for b in range(CORNER):
                x = n - a if sx else a
                y = n - b if sy else b
                arm = (1 <= a <= 3 and 1 <= b <= 8) or (1 <= b <= 3 and 1 <= a <= 8) or (a <= 4 and b <= 4 and a >= 1 and b >= 1)
                if not arm:
                    continue
                # Lit on the side facing up or left, in shadow facing down or right, whatever corner it is in.
                outer_v = (a == 1)                   # the arm's outer column
                outer_h = (b == 1)
                inner_v = (a == 3 and b > 4) or (a == 4 and b <= 4)
                inner_h = (b == 3 and a > 4) or (b == 4 and a <= 4)
                c = "54483a"
                if (outer_h and not sy) or (outer_v and not sx) or (inner_h and sy) or (inner_v and sx):
                    c = "7e6e58"
                elif (outer_h and sy) or (outer_v and sx) or (inner_h and not sy) or (inner_v and not sx):
                    c = "2a221a"
                if (a == 8 and b <= 3) or (b == 8 and a <= 3):
                    c = "1a140e"                       # the arm's cut end
                px[x, y] = rgb(c)
        # The rivet (2 x 2, lit top-left) and a small stud near each arm's end.
        rx = n - 3 if sx else 2
        ry = n - 3 if sy else 2
        for (dx, dy, c) in ((0, 0, "e8c878"), (1, 0, "b08a48"), (0, 1, "b08a48"), (1, 1, "5e4628")):
            px[rx + dx, ry + dy] = rgb(c)
        for (a, b) in ((6, 2), (2, 6)):
            x = n - a if sx else a
            y = n - b if sy else b
            px[x, y] = rgb("8a7a62")
    im.save("art/ui/hud_frame.png")


def track(name, rim_lit, rim, rim_dark):
    """A meter's recessed channel (12 x 10, 3 px slice): the carved edge in shadow on its top and left and
    catching light on its bottom lip, a near-black floor with a darker line under the top edge."""
    w, h = 12, 10
    im = Image.new("RGBA", (w, h))
    px = im.load()
    for x in range(w):
        for y in range(h):
            if y == 0 or x == 0 or x == w - 1:
                c = rim_dark if (y == 0 or x == 0) else rim
            elif y == h - 1:
                c = rim_lit
            elif y == 1 or x == 1:
                c = "050403"
            else:
                c = "0f0b08"
            px[x, y] = rgb(c)
    for (x, y) in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
        px[x, y] = (0, 0, 0, 0)          # rounded by one pixel, like a cut groove
    im.save("art/ui/%s.png" % name)


def hotbar_empty():
    """The hotbar's free slot (30 x 30, 8 px corner like the Inventory slots): the empty slot made easier to
    see at night: a lit iron rim where the Inventory's empty slot has a faint one, still no rivets."""
    size, n = 30, 29
    im = Image.new("RGBA", (size, size), rgb("130e0a"))
    px = im.load()
    for i in range(size):
        for j in range(size):
            edge = min(i, j, n - i, n - j)
            top_left = (i == edge or j == edge) and not (i == n - edge or j == n - edge)
            bottom_right = (i == n - edge or j == n - edge) and not (i == edge or j == edge)
            if edge == 0:
                px[i, j] = rgb("0b0806")
            elif edge == 1:
                px[i, j] = rgb("5e5040" if top_left else ("2e251c" if bottom_right else "45392c"))
            elif edge == 2:
                px[i, j] = rgb("3a3026" if not bottom_right else "251d16")
            elif edge == 3 and (i == 3 or j == 3):
                px[i, j] = rgb("080605")
    im.save("art/ui/hotbar_empty.png")


icons()
plate()
frame()
track("hud_track", "4e4234", "3a3026", "17110c")
track("hud_track_warn", "c8553f", "8a3a2a", "4a1e14")
hotbar_empty()
print("wrote art/ui/hud_icons.png (%d icons), hud_plate.png, hud_frame.png, hud_track(_warn).png, hotbar_empty.png" % len(ICONS))
