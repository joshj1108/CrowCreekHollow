# ART-003 WH: the east road exit, current vs proposed, as text and as a tile image. Non-production; writes only
# into this folder. Inner-farm tile coordinates (0,0 = top-left walkable tile); x >= 64 is the tree border
# (the live game draws 14 border tiles each side, BORDER_X; the prototype draws 6, MARGIN).
#   python art/style_tests/ART-003/wh/exit_blueprint.py
from PIL import Image, ImageDraw, ImageFont
import os
HERE = os.path.dirname(os.path.abspath(__file__))
BP = os.path.join(HERE, "..", "wide", "blueprint_wide_v1b_w3b.txt")
X0, X1, Y0, Y1 = 46, 78, 27, 43          # region shown, inclusive-exclusive
rows = open(BP).read().split("\n")
def base(x, y):
    if 0 <= y < 40 and 0 <= x < 64:
        return rows[y][x]
    return "T"                               # border: forest
# Batch C props (they block their tiles): m mailbox, D dead tree, k boulders
PROPS = {(53, 32): "m", (56, 32): "D", (57, 32): "D", (54, 36): "k", (55, 36): "k"}
def current(x, y):
    return PROPS.get((x, y), base(x, y))
def proposed(x, y):
    c = current(x, y)
    # 1. A farm gate on the homestead line, x = 59: posts in the fence code, two closed gate leaves (block).
    if x == 59 and y in (33, 36): return "X"
    if x == 59 and y in (34, 35): return "G"
    # 2. Beyond the gate the road runs on as a cut avenue: road rows 34-35, a grass verge either side,
    #    forest kept on rows 32 and 37 so the trees frame it.
    if 60 <= x <= 69:
        if y in (34, 35): return "P"
        if y in (33, 36): return "v"
    # 3. In the border it bends north-east, out of the camera's reach, so it turns away into the wood
    #    instead of ending in a wall: x 70-73 on rows 33-34, x 74-77 on rows 32-33.
    if 70 <= x <= 73:
        if y in (33, 34): return "P"
        if y in (32, 35): return "v"
    if 74 <= x <= 77:
        if y in (32, 33): return "P"
        if y in (31, 34): return "v"
    return c
def text(f):
    out = ["      " + "".join(str(x // 10 % 10) for x in range(X0, X1)),
           "      " + "".join(str(x % 10) for x in range(X0, X1))]
    for y in range(Y0, Y1):
        out.append("y=%2d  %s" % (y, "".join(f(x, y) for x in range(X0, X1))))
    return "\n".join(out)
COL = {"T": (34, 52, 36), ".": (92, 112, 60), "P": (128, 98, 66), "X": (70, 50, 34), "G": (196, 120, 40),
       "v": (120, 136, 76), "S": (88, 66, 44), "w": (110, 90, 64), "m": (70, 110, 170), "D": (150, 150, 150),
       "k": (110, 110, 120), "g": (196, 160, 80)}
def draw(f, title, cam=None):
    s = 22
    W, H = (X1 - X0) * s, (Y1 - Y0) * s
    im = Image.new("RGB", (W + 40, H + 60), (24, 26, 22))
    d = ImageDraw.Draw(im)
    d.text((40, 6), title, fill=(230, 230, 220))
    for y in range(Y0, Y1):
        d.text((4, 40 + (y - Y0) * s + 5), str(y), fill=(170, 170, 160))
        for x in range(X0, X1):
            c = f(x, y)
            px, py = 40 + (x - X0) * s, 40 + (y - Y0) * s
            d.rectangle([px, py, px + s - 1, py + s - 1], fill=COL.get(c, (90, 90, 90)), outline=(20, 20, 18))
            if c not in "T.P":
                d.text((px + 7, py + 5), c, fill=(255, 255, 255))
    for x in range(X0, X1, 2):
        d.text((40 + (x - X0) * s + 3, 26), str(x), fill=(170, 170, 160))
    bx = 40 + (64 - X0) * s                    # inner farm / border line
    d.line([bx, 40, bx, 40 + H], fill=(230, 60, 60), width=2)
    py = 40 + (40 - Y0) * s
    d.line([40, py, 40 + W, py], fill=(230, 60, 60), width=2)
    mx = 40 + (70 - X0) * s                    # end of the prototype's 6-tile margin
    for yy in range(40, 40 + H, 8):
        d.line([mx, yy, mx, yy + 4], fill=(240, 200, 60), width=2)
    if cam:                                    # 26.67 x 15 tile camera round the farmer
        cx, cy = cam
        l, t = 40 + (cx - 13.33 - X0) * s, 40 + (cy - 7.5 - Y0) * s
        d.rectangle([l, t, l + 26.67 * s, t + 15 * s], outline=(255, 255, 255), width=2)
        fx, fy = 40 + (cx - X0) * s, 40 + (cy - Y0) * s
        d.ellipse([fx - 5, fy - 5, fx + 5, fy + 5], fill=(255, 255, 255))
    return im
if __name__ == "__main__":
    open(os.path.join(HERE, "exit_blueprint.txt"), "w").write(
        "CURRENT (art=w3c)\n" + text(current) + "\n\nPROPOSED (not built)\n" + text(proposed) + "\n")
    a = draw(current, "CURRENT: road ends at x=58 against forest. White box = camera with the farmer at the road end (58.4,34.5)", (58.4, 34.5))
    b = draw(proposed, "PROPOSED: gate at x=59 (G blocks, X posts); avenue x60-69; bends NE in the border. Red = farm edge; yellow dashes = prototype margin end", (58.4, 34.5))
    im = Image.new("RGB", (a.width, a.height * 2 + 10), (24, 26, 22))
    im.paste(a, (0, 0)); im.paste(b, (0, a.height + 10))
    os.makedirs(os.path.join(HERE, "review"), exist_ok=True)
    im.save(os.path.join(HERE, "review", "wh_exit_blueprint.png"))
    print(open(os.path.join(HERE, "exit_blueprint.txt")).read())
