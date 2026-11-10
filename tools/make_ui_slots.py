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
    # Phase 2 final: hover is a subtle lift of the iron rim (it was brass, too close to the picked gold).
    "hover":    ("251c14", "6e5e4a", "8c7a62", "3a3026", "7a5e34", "a8854a", "100c08"),
    # Picked: the iron rim of an occupied slot, a warmer fill, and a gold line set inside the rim (INSET below).
    "picked":   ("2c2016", "5a4a38", "75644e", "2e251c", "d8b050", "f4e0a0", "0e0a07"),
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
    if state == "picked":
        # The inset: a 2 px gold line one pixel inside the recessed lip, lit on its top and left.
        for i in range(SIZE):
            for j in range(SIZE):
                edge = min(i, j, n - i, n - j)
                if edge in (4, 5):
                    lit = (i == edge or j == edge) and not (i == n - edge or j == n - edge)
                    px[i, j] = rgb(("efd08a" if lit else "d8b050") if edge == 4 else "8a6428")
    if rivet:
        for (x, y) in ((4, 4), (n - 5, 4), (4, n - 5), (n - 5, n - 5)):
            px[x, y] = rgb(rivet_light)
            px[x + 1, y] = rgb(rivet)
            px[x, y + 1] = rgb(rivet)
            px[x + 1, y + 1] = rgb("0b0806")
    im.save(OUT % state)


def draw_focus():
    """The focus frame (Phase 2 final): drawn just outside a slot, so it never hides the picked inset. A pale
    lantern-ivory line between two dark lines, with heavier L-shaped brackets at the corners. Centre clear."""
    size = 20
    n = size - 1
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = im.load()
    for i in range(size):
        for j in range(size):
            edge = min(i, j, n - i, n - j)
            corner = (min(i, n - i) < 6) and (min(j, n - j) < 6)
            if edge == 0:
                px[i, j] = rgb("0b0806")
            elif edge == 1:
                px[i, j] = rgb("f1e6c8")
            elif edge == 2:
                px[i, j] = rgb("f1e6c8") if corner else rgb("0b0806")
            elif edge == 3 and corner:
                px[i, j] = rgb("0b0806")
    im.save(OUT % "focus")


for s in STATES:
    draw(s)
draw_focus()
print("wrote", ", ".join(OUT % s for s in list(STATES) + ["focus"]))
