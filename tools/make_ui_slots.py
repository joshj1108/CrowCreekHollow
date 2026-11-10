# UI-OVERHAUL-001 Phase 2: draws the inventory slot frames, one 9-slice PNG per state, at 1 art pixel per screen
# pixel like the SpriteCook UI kit (art/ui/slot.png is 1:1 too). Each is 30 x 30 with an 8 px corner:
#   outline (near black), a 2 px rim (iron, brass or gold) lit on its top and left, a recessed inner shadow,
#   a flat dark-wood fill, and a brass rivet in each corner (none on an empty slot).
# Run: python tools/make_ui_slots.py   (writes art/ui/slot_<state>.png; then import once with Godot --import)
from PIL import Image

SIZE = 30
OUT = "art/ui/slot_%s.png"
# The picked state is slot_picked, not slot_selected: art/ui/slot_selected.png is the SpriteCook kit's own lit
# slot (hotbar, bag, craft tiles) and must never be overwritten.

# state: fill, rim, rim light, rim shadow, rivet, rivet light, inner shadow
STATES = {
    "empty":    ("110d09", "2a2119", "2f251c", "1d1610", None, None, "080605"),
    "occupied": ("1e1610", "4f4234", "6a5a46", "2e251c", "7a5e34", "a8854a", "0e0a07"),
    "hover":    ("2b2016", "8a6a3a", "a8854a", "5a4426", "8a6a3a", "c09a58", "120d09"),
    "picked":   ("3a2a18", "d8b050", "efd08a", "a07c30", "d8b050", "f4e0a0", "1a130c"),
    "locked":   ("17110c", "332a20", "3d3226", "221a13", "3d3226", "4a3d2e", "0b0806"),
}


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def draw(state):
    fill, rim, light, shade, rivet, rivet_light, inner = STATES[state]
    im = Image.new("RGBA", (SIZE, SIZE), rgb(fill))
    px = im.load()
    n = SIZE - 1
    for i in range(SIZE):
        for j in range(SIZE):
            edge = min(i, j, n - i, n - j)
            if edge == 0:
                px[i, j] = rgb("0b0806")
            elif edge in (1, 2):
                # The rim: lit on the top and left, in shadow on the bottom and right, plain where they meet.
                top_left = i == edge or j == edge
                bottom_right = i == n - edge or j == n - edge
                c = rim
                if top_left and not bottom_right:
                    c = light if edge == 1 else rim
                elif bottom_right and not top_left:
                    c = shade
                px[i, j] = rgb(c)
            elif edge == 3:
                # A recessed lip: the inner shadow on the top and left, the fill elsewhere.
                if i == 3 or j == 3:
                    px[i, j] = rgb(inner)
    if rivet:
        for (x, y) in ((4, 4), (n - 5, 4), (4, n - 5), (n - 5, n - 5)):
            px[x, y] = rgb(rivet_light)
            px[x + 1, y] = rgb(rivet)
            px[x, y + 1] = rgb(rivet)
            px[x + 1, y + 1] = rgb("0b0806")
    im.save(OUT % state)


for s in STATES:
    draw(s)
print("wrote", ", ".join(OUT % s for s in STATES))
