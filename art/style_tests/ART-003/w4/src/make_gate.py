# ART-003 W-4: the closed east gate, hand-drawn with the colours of the prototype fence (src/fence.png) and its iron.
# The gate runs north-south across the east-west road, so in the game's straight-on 3/4 view it is seen end-on, like
# the garden's north-south fence: two stout capped posts and two plank leaves, each leaf a tile long and 14 px tall.
#   gatepost.png  10x34, its base on the bottom row
#   gate_spur.png  6x30: the fence running on into the trees north and south (drawing only)
#   gate_leaf_n.png / gate_leaf_s.png  8x24 (lower than the posts, so the gate reads post-leaf-leaf-post): one tile of footprint (bottom 16 rows) plus the leaf's height; the
#   north leaf carries the latch at its south end, the south leaf a hinge strap at its north end.
import os
from PIL import Image
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "gate")
P = {"O": (59, 42, 30), "L": (160, 122, 76), "l": (154, 109, 66), "b": (126, 90, 54), "B": (92, 65, 40),
     "i": (58, 58, 58), "I": (94, 92, 86), "m": (94, 110, 52), "M": (46, 63, 36)}
def save(rows, name):
    im = Image.new("RGBA", (len(rows[0]), len(rows)), (0, 0, 0, 0))
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c in P:
                im.putpixel((x, y), P[c] + (255,))
    im.save(os.path.join(out, name))
post = ["..OOOOOO..",
        ".OLLLLLLO.",
        "OLLlllllbO",
        "OlbbbbbbBO",
        ".OOOOOOOO."]
for y in range(5, 31):
    post.append("..OIIiiO.." if y in (11, 22) else ("..OLlbBO.." if y % 7 else "..OlbbBO.."))
post += ["..OmLbBO..", ".OMmlbBMO.", ".OOOOOOOO."]
save(post, "gatepost.png")
def leaf(latch):
    # two boards side by side (the leaf's top edge, seen from above), with joints and a light top face
    rows = ["OOOOOOOO"]
    for y in range(1, 23):
        rows.append("OBBBBBBO" if y % 6 == 0 else "OLlbOLbO")
    rows.append("OOOOOOOO")
    if latch == "n":   # an iron latch bar near the leaf's south end, where the leaves meet
        rows[18], rows[19] = "iIIiiIIO", "OiiiiiiO"
    else:              # a hinge strap near the north end
        rows[4], rows[5] = "OIIiiIBO", "OiiiiiBO"
    return rows
# A fence spur either side of the gate, running into the trees: a plain post with its rail turned on end.
spur = []
for y in range(30):
    spur.append("OLbBO." if y < 2 or y > 26 else (".ObO.." if y % 9 else "OLbBO."))
spur[0] = ".OOO.."
spur[-1] = "OOOOO."
save(spur, "gate_spur.png")
save(leaf("n"), "gate_leaf_n.png")
save(leaf("s"), "gate_leaf_s.png")
print("saved")
