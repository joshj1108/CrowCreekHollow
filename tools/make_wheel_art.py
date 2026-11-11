# UI-OVERHAUL-001 Phase 6 (the section wheel): draws the wheel's pixel art by hand, no generation credits.
# The wheel is a farmer's field instrument: walnut wedges with concentric grain, each set in a carved recess, split
# by brass strips, bound in an iron rim with brass rivets, round a brass-ringed walnut hub that carries the name.
# Everything is drawn at 1 native pixel and saved at 1x; the game draws it at 2x (the UI's detail density, as the
# diary and the HUD icons). Nothing is rotated or scaled at runtime, so every frame stays on the pixel grid.
#   art/ui/wheel/dial.png    the whole dial with its table shadow, every segment at rest: 232x232 native, centre 116
#   art/ui/wheel/hot.png     one frame per segment (8 across, 232x232 each): the lit wedge (lighter walnut, a brass
#                            frame), the brass notch on the rim over it and the hub's brass pointer toward it. Only
#                            those pixels; the rest is transparent and drawn over the dial.
#   art/ui/wheel/icons.png   the eight section icons, 20x20 native cells in SECTIONS order, 1 px dark outline:
#                            Skills (crossed hoe and pick), Gear (shield), Craft (hammer), Quests (scroll and seal),
#                            Diary (leather journal), House (farmhouse), Buildings (barn), Achievements (medal)
# Radii (native): rim 106.5-112.5, face 47.5-105.5, hub ring 40.5-46.5, hub 39.5. At 2x the face runs 95-211 px,
# inside SectionWheel's hit ring (INNER_R 92, OUTER_R 222).
# Run: python tools/make_wheel_art.py   (then import once with Godot --import)
import math
import os
import random

from PIL import Image, ImageDraw

OUT = os.path.join("art", "ui", "wheel")
N = 8
SEG = 2 * math.pi / N
SIZE = 232
C = 116.0
R_RIM_OUT, R_RIM_IN, R_FACE_IN, R_HUB_OUT, R_HUB = 112.5, 106.5, 47.5, 46.5, 39.5

OUTLINE = "151009"
WALNUT = ["1e120b", "24150d", "2f1c12", "3b2417", "45291a", "55361f", "6b4a32"]
IRON = ["24221f", "3a3733", "4c4944", "5f5b55", "77736c"]
BRASS = ["4a3820", "5a4424", "8a6a3a", "b0904e", "d8c08a"]
RAY = (0.6, 0.8)   # the light travels this way on screen: from the upper left


def rgba(hex_, a=255):
    return (int(hex_[0:2], 16), int(hex_[2:4], 16), int(hex_[4:6], 16), a)


def polar(x, y):
    dx, dy = x + 0.5 - C, y + 0.5 - C
    r = math.hypot(dx, dy)
    a = math.atan2(dx, -dy) % (2 * math.pi)   # zero straight up, growing clockwise
    return r, a, dx, dy


def seg_of(a):
    return int(round(a / SEG)) % N


def divider_dist(r, a):
    # Distance in px to the nearest strip between two segments, and that boundary's angle.
    k = math.floor(a / SEG - 0.5)
    best = None
    for kk in (k, k + 1):
        b = (kk + 0.5) * SEG
        d = r * math.sin(abs(a - b)) if abs(a - b) < math.pi / 2 else 99.0
        if best is None or d < best[0]:
            best = (d, b)
    return best


def lit(nx, ny):
    # How far a surface facing (nx, ny) on screen faces the light: +1 toward it, -1 away.
    return -(nx * RAY[0] + ny * RAY[1])


def face_pixel(x, y, hot, rng_grain):
    # A wedge's walnut: concentric grain (the wedge cut from one board, its own phase), set in a carved recess
    # whose walls catch the light on the lower right and fall into shadow on the upper left.
    r, a, dx, dy = polar(x, y)
    s = seg_of(a)
    ux, uy = dx / r, dy / r
    d_div, b = divider_dist(r, a)
    edges = [(R_RIM_IN - 1 - r, -ux, -uy), (r - R_FACE_IN, ux, uy)]
    # the divider's inward normal: perpendicular to the boundary ray, toward this wedge's centre
    tx, ty = math.cos(b), math.sin(b)   # the tangent across the ray at angle b (clockwise positive)
    side = 1.0 if (a - b) % (2 * math.pi) < math.pi else -1.0
    edges.append((d_div - 1.5, tx * side, ty * side))
    d, nx, ny = min(edges, key=lambda e: e[0])
    base = 5 if hot else 2
    g = math.sin(r * 0.62 + 1.6 * math.sin(a * 3.0 + s * 1.3) + s * 2.1) + 0.45 * (rng_grain[(y * SIZE + x) % len(rng_grain)] - 0.5)
    idx = base + (1 if g > 0.75 else (0 if g > -0.55 else -1))
    if d < 2.0:
        light = lit(nx, ny)
        if light > 0.25:
            idx = base + (2 if d < 1.0 else 1)
        elif light < -0.25:
            idx = base - (2 if d < 1.0 else 1)
    idx = max(0, min(len(WALNUT) - 1, idx))
    col = rgba(WALNUT[idx])
    if hot and 1.0 <= d < 2.0:
        col = rgba(BRASS[3] if lit(nx, ny) > -0.25 else BRASS[2])   # the lit wedge's brass frame
    return col


def dial():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    px = img.load()
    rng = random.Random(7)
    grain = [rng.random() for _ in range(4099)]
    hammer = random.Random(11)
    for y in range(SIZE):
        for x in range(SIZE):
            r, a, dx, dy = polar(x, y)
            ux, uy = (dx / r, dy / r) if r else (0.0, 0.0)
            # The dial's shadow on the table, offset down and right, in one hard step.
            if r > R_RIM_OUT:
                sr = math.hypot(dx - 3, dy - 4)
                if sr <= R_RIM_OUT:
                    px[x, y] = (0, 0, 0, 95)
                continue
            if r > R_RIM_OUT - 1 or (R_RIM_IN - 1 < r <= R_RIM_IN):
                px[x, y] = rgba(OUTLINE)
            elif r > R_RIM_IN:
                # The iron rim: lit on the upper left, hammered with a few dark pits.
                light = lit(ux, uy)
                i = 3 if light > 0.45 else (1 if light < -0.45 else 2)
                if r > R_RIM_OUT - 2 and light > 0.2:
                    i = 4
                if hammer.random() < 0.06:
                    i = max(0, i - 1)
                px[x, y] = rgba(IRON[i])
            elif r > R_FACE_IN:
                d_div, _ = divider_dist(r, a)
                if d_div < 1.0:
                    px[x, y] = rgba(BRASS[2] if lit(ux, uy) < 0.3 else BRASS[3])   # the brass strip
                elif d_div < 1.8:
                    px[x, y] = rgba(OUTLINE)
                else:
                    px[x, y] = face_pixel(x, y, False, grain)
            elif r > R_HUB_OUT:
                px[x, y] = rgba(OUTLINE)
            elif r > R_HUB + 1:
                light = lit(ux, uy)
                i = 3 if light > 0.45 else (1 if light < -0.5 else 2)
                px[x, y] = rgba(BRASS[i])
            elif r > R_HUB:
                px[x, y] = rgba(OUTLINE)
            else:
                # The hub: dark walnut, a carved groove near its edge, faint rings, so the name reads on it.
                i = 1 if math.sin(r * 0.7) > 0.6 else 0
                if 35.5 < r <= 36.5:
                    i = 2 if lit(ux, uy) < 0 else 0
                px[x, y] = rgba(WALNUT[i])
    # Engraved marks on the hub ring, as on a compass: a tick at the four quarters, a dot between.
    for k in range(N):
        ang = k * SEG
        for rr in ((42, 43, 44, 45) if k % 2 == 0 else (43, 44)):
            x = int(math.floor(C + math.sin(ang) * rr))
            y = int(math.floor(C - math.cos(ang) * rr))
            px[x, y] = rgba(BRASS[0])
    # Brass rivets where each strip meets the rim, and a small carved notch on the rim over each wedge.
    for k in range(N):
        ang = (k + 0.5) * SEG
        cx, cy = C + math.sin(ang) * 109.5, C - math.cos(ang) * 109.5
        rivet(px, int(cx), int(cy))
        ang = k * SEG
        for rr in (108, 109, 110):
            px[int(math.floor(C + math.sin(ang) * rr)), int(math.floor(C - math.cos(ang) * rr))] = rgba(IRON[0])
    return img


def rivet(px, cx, cy):
    shape = [".o.", "olo", ".o."]
    for j, row in enumerate(shape):
        for i, c in enumerate(row):
            if c == "o":
                px[cx - 1 + i, cy - 1 + j] = rgba(BRASS[1] if (i + j) > 2 else BRASS[3])
            elif c == "l":
                px[cx - 1 + i, cy - 1 + j] = rgba(BRASS[4])


def hot_frames():
    sheet = Image.new("RGBA", (SIZE * N, SIZE), (0, 0, 0, 0))
    rng = random.Random(7)
    grain = [rng.random() for _ in range(4099)]
    for s in range(N):
        img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
        px = img.load()
        for y in range(SIZE):
            for x in range(SIZE):
                r, a, dx, dy = polar(x, y)
                if R_FACE_IN < r <= R_RIM_IN - 1 and seg_of(a) == s and divider_dist(r, a)[0] >= 1.8:
                    px[x, y] = face_pixel(x, y, True, grain)
        mid = s * SEG
        # The hub's brass pointer: a small arrowhead on the ring, pointing out at the lit wedge.
        for rr in range(40, 56):
            half = max(0.0, (55 - rr) * 0.42)
            for w in range(-6, 7):
                if abs(w) <= half:
                    ox = math.sin(mid) * rr + math.cos(mid) * w * 0.9
                    oy = -math.cos(mid) * rr + math.sin(mid) * w * 0.9
                    x, y = int(math.floor(C + ox)), int(math.floor(C + oy))
                    edge = abs(w) > half - 1.0 or rr >= 54
                    px[x, y] = rgba(OUTLINE if edge and rr > 46 else (BRASS[4] if w <= 0 else BRASS[3]))
        # A brass notch set into the rim over the wedge.
        for rr in range(106, 113):
            for w in range(-2, 3):
                ox = math.sin(mid) * rr + math.cos(mid) * w
                oy = -math.cos(mid) * rr + math.sin(mid) * w
                x, y = int(math.floor(C + ox)), int(math.floor(C + oy))
                px[x, y] = rgba(OUTLINE if abs(w) == 2 or rr == 112 else (BRASS[4] if rr < 109 else BRASS[3]))
        sheet.paste(img, (s * SIZE, 0))
    return sheet


# --- Icons ---------------------------------------------------------------------

def outline(img):
    px = img.load()
    w, h = img.size
    edge = []
    for y in range(h):
        for x in range(w):
            if px[x, y][3] == 0:
                for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                    if 0 <= nx < w and 0 <= ny < h and px[nx, ny][3] > 0 and px[nx, ny][:3] != rgba(OUTLINE)[:3]:
                        edge.append((x, y))
                        break
    for x, y in edge:
        px[x, y] = rgba(OUTLINE)


def icon(draw_fn):
    img = Image.new("RGBA", (20, 20), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_fn(d, img.load())
    outline(img)
    return img


def line(d, p0, p1, col, w=1):
    d.line([p0, p1], fill=rgba(col), width=w)


def skills(d, px):
    # Crossed hoe and pick: ash handles, iron heads.
    line(d, (4, 16), (14, 6), "8a6a3a", 2)
    line(d, (15, 16), (5, 6), "6b5340", 2)
    line(d, (4, 15), (13, 6), "a08a62")
    d.polygon([(13, 2), (17, 2), (17, 6), (15, 8), (14, 5)], fill=rgba("77736c"))   # the hoe's blade
    d.line([(14, 3), (16, 3)], fill=rgba("a8a49c"))
    d.line([(1, 7), (3, 4), (6, 3), (9, 4)], fill=rgba("77736c"), width=2)            # the pick's head
    d.point([(2, 5), (4, 3)], fill=rgba("a8a49c"))


def gear(d, px):
    # A kite shield: an iron rim, a walnut face in two planks, a brass boss.
    d.polygon([(3, 2), (16, 2), (16, 10), (9, 18), (3, 10)], fill=rgba("77736c"))
    d.polygon([(4, 3), (15, 3), (15, 10), (9, 16), (4, 10)], fill=rgba("6b4a32"))
    d.polygon([(4, 3), (9, 3), (9, 16), (4, 10)], fill=rgba("7d5a3c"))
    d.line([(9, 3), (9, 16)], fill=rgba("45291a"))
    d.rectangle([8, 7, 10, 9], fill=rgba("b0904e"))
    d.point([(8, 7)], fill=rgba("d8c08a"))
    d.line([(4, 3), (15, 3)], fill=rgba("a8a49c"))


def craft(d, px):
    # A claw hammer: an iron head over an ash handle.
    d.rectangle([8, 8, 10, 17], fill=rgba("8a6a3a"))
    d.line([(8, 8), (8, 17)], fill=rgba("a08a62"))
    d.rectangle([5, 3, 15, 7], fill=rgba("5f5b55"))
    d.line([(5, 3), (15, 3)], fill=rgba("8a867e"))
    d.line([(6, 4), (14, 4)], fill=rgba("77736c"))
    d.polygon([(3, 2), (5, 3), (5, 7), (3, 8)], fill=rgba("4c4944"))                  # the claw
    d.rectangle([16, 3, 17, 7], fill=rgba("77736c"))                                   # the face


def quests(d, px):
    # A parchment scroll, rolled at both ends, with a few lines and a red wax seal.
    d.rectangle([4, 4, 15, 15], fill=rgba("c4ae84"))
    d.line([(4, 4), (4, 15)], fill=rgba("d6c39c"))
    d.rectangle([3, 2, 16, 4], fill=rgba("a08a62"))
    d.line([(3, 2), (16, 2)], fill=rgba("cdb88f"))
    d.rectangle([3, 15, 16, 17], fill=rgba("a08a62"))
    d.line([(3, 15), (16, 15)], fill=rgba("cdb88f"))
    for yy in (7, 9, 11):
        d.line([(6, yy), (13 if yy != 11 else 9, yy)], fill=rgba("6b5a40"))
    d.ellipse([10, 10, 14, 14], fill=rgba("8a3424"))
    d.point([(11, 11)], fill=rgba("b0503a"))


def diary(d, px):
    # A leather journal: the cover, its darker spine, the page edges, a brass clasp and a red ribbon.
    d.rectangle([4, 2, 15, 16], fill=rgba("6b4a32"))
    d.rectangle([4, 2, 6, 16], fill=rgba("45291a"))
    d.line([(7, 3), (14, 3)], fill=rgba("7d5a3c"))
    d.rectangle([15, 3, 16, 15], fill=rgba("d6c39c"))
    d.line([(16, 3), (16, 15)], fill=rgba("a08a62"))
    d.rectangle([14, 8, 16, 10], fill=rgba("b0904e"))
    d.point([(14, 8)], fill=rgba("d8c08a"))
    d.rectangle([9, 6, 12, 9], fill=rgba("55361f"))                                    # a blind-tooled panel
    d.rectangle([10, 16, 11, 18], fill=rgba("8a3424"))
    d.point([(10, 18)], fill=(0, 0, 0, 0))


def house(d, px):
    # The farmhouse: a steep shingle roof with a chimney, clapboard walls, a lit window and a door.
    d.rectangle([12, 2, 14, 7], fill=rgba("6b5340"))
    d.polygon([(1, 10), (10, 2), (18, 10)], fill=rgba("6e3a2a"))
    d.line([(2, 9), (10, 2)], fill=rgba("8a4a32"))
    d.rectangle([3, 10, 16, 17], fill=rgba("b29c74"))
    d.line([(3, 10), (16, 10)], fill=rgba("8f7a54"))
    for yy in (12, 14, 16):
        d.line([(3, yy), (16, yy)], fill=rgba("a08a62"))
    d.rectangle([5, 12, 7, 14], fill=rgba("d8c08a"))
    d.rectangle([11, 12, 13, 17], fill=rgba("45291a"))


def buildings(d, px):
    # The barn: a broad gambrel roof, weathered red boards and a cross-braced door, wider and lower than the house.
    d.polygon([(0, 10), (2, 6), (6, 3), (13, 3), (17, 6), (19, 10)], fill=rgba("5f5b55"))
    d.line([(1, 9), (2, 6), (6, 3), (13, 3)], fill=rgba("77736c"))
    d.line([(2, 6), (17, 6)], fill=rgba("4c4944"))
    d.rectangle([1, 10, 18, 17], fill=rgba("7a3226"))
    for xx in (3, 6, 13, 16):
        d.line([(xx, 11), (xx, 17)], fill=rgba("6a2a20"))
    d.rectangle([7, 11, 12, 17], fill=rgba("c4ae84"))
    d.rectangle([8, 12, 11, 17], fill=rgba("6a2a20"))
    d.line([(8, 12), (11, 17)], fill=rgba("c4ae84"))
    d.line([(11, 12), (8, 17)], fill=rgba("c4ae84"))
    d.point([(9, 5), (10, 5)], fill=rgba("2a1f16"))                                    # the loft door


def achievements(d, px):
    # A struck brass medal on a ribbon, a crow's head engraved in it.
    d.polygon([(5, 1), (8, 1), (11, 8), (8, 8)], fill=rgba("4a5a6a"))
    d.polygon([(14, 1), (11, 1), (8, 8), (11, 8)], fill=rgba("8a3424"))
    d.ellipse([4, 7, 15, 18], fill=rgba("8a6a3a"))
    d.ellipse([5, 8, 14, 17], fill=rgba("b0904e"))
    d.arc([5, 8, 14, 17], 180, 270, fill=rgba("d8c08a"))
    d.arc([5, 8, 14, 17], 0, 90, fill=rgba("8a6a3a"))
    d.point([(8, 11), (9, 11), (10, 11), (8, 12), (9, 12), (11, 12), (9, 13), (10, 13), (10, 14)], fill=rgba("5a4424"))


ICONS = [skills, gear, craft, quests, diary, house, buildings, achievements]


def icons():
    sheet = Image.new("RGBA", (20 * len(ICONS), 20), (0, 0, 0, 0))
    for i, fn in enumerate(ICONS):
        sheet.paste(icon(fn), (i * 20, 0))
    return sheet


def save(img, name):
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, name)
    img.save(path)
    print("wrote %s (%dx%d native, drawn at 2x)" % (path, img.width, img.height))


if __name__ == "__main__":
    save(dial(), "dial.png")
    save(hot_frames(), "hot.png")
    save(icons(), "icons.png")
