# ART-003 W-4 review sheets that review_sheet.ps1 can't make: sprite close-ups with in-game 100% crops, the gate's
# tile-level diagram with the collision result, the forest-margin evidence, the walk frame strips, and the Task B
# layout sheet. Run from the repo root after the captures are in w4/shots/ and the movie frames in <scratch>/after/mv/.
#   python art/style_tests/ART-003/w4/src/make_review.py <scratch dir>
import os
import sys
from PIL import Image, ImageDraw, ImageFont

A = "art/style_tests/ART-003/"
W4 = A + "w4/"
SH = W4 + "shots/"
RV = W4 + "review/"
SCR = sys.argv[1] if len(sys.argv) > 1 else ""
BG, INK, DIM = (30, 32, 28), (236, 230, 214), (170, 166, 150)
try:
    F = ImageFont.truetype("arial.ttf", 20)
    FB = ImageFont.truetype("arialbd.ttf", 24)
    FS = ImageFont.truetype("arial.ttf", 15)
    FM = ImageFont.truetype("consola.ttf", 15)
except OSError:
    F = FB = FS = FM = ImageFont.load_default()


def spr(path, k):
    im = Image.open(path).convert("RGBA")
    bg = Image.new("RGBA", im.size, (92, 104, 60, 255))
    bg.alpha_composite(im)
    return bg.resize((im.width * k, im.height * k), Image.NEAREST).convert("RGB")


def shot(name, box=None):
    im = Image.open(SH + name).convert("RGB")
    return im.crop(box) if box else im


class Sheet:
    def __init__(self, w, title, sub):
        self.w, self.items, self.y = w, [], 0
        self.title, self.sub = title, sub

    def row(self, label, ims, caps=None, gap=12):
        self.items.append((label, ims, caps or [""] * len(ims), gap))

    def save(self, path):
        h = 80
        for label, ims, caps, gap in self.items:
            h += 34 + max(i.height for i in ims) + (24 if any(caps) else 0) + 16
        img = Image.new("RGB", (self.w, h), BG)
        d = ImageDraw.Draw(img)
        d.text((16, 12), self.title, font=FB, fill=INK)
        d.text((16, 46), self.sub, font=FS, fill=DIM)
        y = 80
        for label, ims, caps, gap in self.items:
            d.text((16, y), label, font=F, fill=INK)
            y += 34
            x = 16
            for im, cap in zip(ims, caps):
                img.paste(im, (x, y))
                if cap:
                    d.text((x, y + max(i.height for i in ims) + 4), cap, font=FS, fill=DIM)
                x += max(im.width, int(d.textlength(cap, font=FS)) + 6) + gap
            y += max(i.height for i in ims) + (24 if any(caps) else 0) + 16
        img.save(path)
        print("saved", path, img.size)


# --- close-ups ---------------------------------------------------------------------------------------------------
c = Sheet(1340, "ART-003 W-4: log pile, orchard and gate, close up",
          "Sprites at 6x / 4x on a flat grass colour; in-game crops at 100% (1280x720 captures, 3x scale). BEFORE = Batch C (art=w3c), AFTER = W-4 (art=w4).")
c.row("Log pile: the SpriteCook woodstore it replaces, and the hand-built pile (19x16, r3/log.png colours only), 6x",
      [spr("art/farm/woodstore.png", 6), spr(W4 + "props/logpile.png", 6), spr(A + "r3/log.png", 3)],
      ["woodstore.png (BEFORE)", "logpile.png (AFTER)", "source: r3/log.png, 3x"])
V3 = (600, 30, 1000, 300)   # the V3 woodcutting corner (33-35, 14) from V3 (31, 19)
WING = (250, 100, 1030, 330)  # both house wings (39, 10) and (51, 10) from V5-B (45, 13.5)
c.row("V3 woodcutting corner, 100%: before day, after day, after R3-1 night",
      [shot("before_v3_day.png", V3), shot("after_v3_day.png", V3), shot("after_v3_night.png", V3).point(lambda v: min(255, v * 2))],
      ["BEFORE day", "AFTER day", "AFTER night (brightened 2x for this sheet only)"])
c.row("House wings from V5-B (porch), 100%: before day, after day",
      [shot("before_v5_day.png", WING), shot("after_v5_day.png", WING)], ["BEFORE day", "AFTER day"])
c.row("Orchard sprites, 4x: Batch C apple and pear, then W-4 apple A/B and pear A/B, windfalls and basket",
      [spr(A + "w3c/orchard/apple_w3c.png", 4), spr(A + "w3c/orchard/pear_w3c.png", 4), spr(W4 + "orchard/apple_a.png", 4),
       spr(W4 + "orchard/apple_b.png", 4), spr(W4 + "orchard/pear_a.png", 4), spr(W4 + "orchard/pear_b.png", 4),
       spr(W4 + "orchard/windfall_apple.png", 4), spr(W4 + "orchard/windfall_pear.png", 4), spr(W4 + "orchard/basket.png", 4)],
      ["apple (B)", "pear (B)", "apple A", "apple B", "pear A", "pear B", "", "", "basket"], gap=8)
OR = (240, 60, 900, 420)   # the orchard from (13, 22)
c.row("Orchard, 100%: before and after, day", [shot("before_or_day.png", OR), shot("after_or_day.png", OR)], ["BEFORE day", "AFTER day"])
c.row("Orchard, 100%: before and after, R3-1 night", [shot("before_or_night.png", OR), shot("after_or_night.png", OR)], ["BEFORE night", "AFTER night"])
c.row("Gate sprites, 6x: post (10x34), north leaf with latch, south leaf with hinge (8x24), fence spur (6x30)",
      [spr(W4 + "gate/gatepost.png", 6), spr(W4 + "gate/gate_leaf_n.png", 6), spr(W4 + "gate/gate_leaf_s.png", 6), spr(W4 + "gate/gate_spur.png", 6)],
      ["gatepost", "leaf, north", "leaf, south", "spur"])
GATE = (470, 120, 1000, 560)
c.row("East gate, 100%: before day, after day, after night",
      [shot("before_end_day.png", GATE), shot("after_end_day.png", GATE), shot("after_end_night.png", GATE)],
      ["BEFORE day (forest)", "AFTER day", "AFTER night"], gap=8)
c.save(RV + "w4_closeups.png")

# --- the gate, tile by tile ---------------------------------------------------------------------------------------
lines = open(A + "wh/exit_blueprint.txt").read().split("\n")
cur, pro, sec = {}, {}, ""
for ln in lines:
    if ln.startswith("CURRENT"):
        sec = "c"
    elif ln.startswith("PROPOSED"):
        sec = "p"
    elif ln.startswith("y="):
        y = int(ln[2:4])
        for i, ch in enumerate(ln[6:]):
            (cur if sec == "c" else pro)[(46 + i, y)] = ch
reach_b = set(tuple(map(int, l.split(","))) for l in open(SH + "reach_before_w3c.txt").read().split())
reach_a = set(tuple(map(int, l.split(","))) for l in open(SH + "reach_after_w4.txt").read().split())
COLS = {"T": (40, 64, 42), ".": (104, 150, 72), "P": (196, 160, 104), "X": (150, 110, 70), "G": (230, 230, 230), "v": (130, 168, 88),
        "m": (200, 60, 60), "D": (110, 90, 80), "k": (140, 140, 140), "S": (120, 80, 52), "w": (176, 146, 100), "g": (196, 160, 104)}
S = 22
gw, gh = 32 * S, 16 * S
img = Image.new("RGB", (gw * 2 + 3 * 24, gh + 300), BG)
d = ImageDraw.Draw(img)
d.text((16, 10), "ART-003 W-4: the east gate, tile level (x 46-77, y 27-42)", font=FB, fill=INK)
d.text((16, 42), "Left: Batch C (BEFORE). Right: W-4 as built (AFTER) = the WH blueprint's PROPOSED grid. A dot marks a tile the farmer can reach (flood fill over the game's collision check).",
       font=FS, fill=DIM)
for k, (grid, reach, title) in enumerate([(cur, reach_b, "BEFORE (art=w3c)"), (pro, reach_a, "AFTER (art=w4)")]):
    ox, oy = 24 + k * (gw + 24), 100
    d.text((ox, oy - 26), title, font=F, fill=INK)
    for (x, y), ch in grid.items():
        r = [ox + (x - 46) * S, oy + (y - 27) * S, ox + (x - 45) * S - 1, oy + (y - 26) * S - 1]
        d.rectangle(r, fill=COLS.get(ch, (255, 0, 255)))
        if ch in "XGm":
            d.text((r[0] + 6, r[1] + 3), ch, font=FM, fill=(0, 0, 0))
        if (x, y) in reach:
            d.ellipse([r[0] + 8, r[1] + 8, r[0] + 13, r[1] + 13], fill=(255, 230, 80))
    d.line([ox + 18 * S, oy, ox + 18 * S, oy + gh], fill=(255, 255, 255), width=2)   # x = 64, the inner farm's east edge
    d.text((ox + 18 * S + 4, oy + gh + 4), "x=64: border", font=FS, fill=DIM)
    d.line([ox + 13 * S, oy + gh, ox + 13 * S, oy + gh + 14], fill=(255, 255, 255), width=2)
    d.text((ox + 13 * S - 26, oy + gh + 18), "x=59", font=FS, fill=DIM)
same = reach_a == reach_b
notes = [
    "Key: T forest  . grass  P road  X gate post  G closed gate leaf  v verge  m mailbox  D dead tree  k boulders  (S w g garden)",
    f"Reachable tiles: BEFORE {len(reach_b)}, AFTER {len(reach_a)}; the two sets are {'IDENTICAL' if same else 'DIFFERENT'}. Gate tiles (59, 33..36): blocked in both.",
    "The gate and avenue are drawn only: collision reads the base layout, where every one of these tiles is forest, so it blocks exactly as before.",
    "Walk test: pushing east along rows 33.4, 34.5, 35.5 and 36.5 stops at x 58.66 (day and night); all four legs stall at the gate.",
    "x 60-63 are inner tiles drawn as avenue; x 64-77 are the border. The gate is the 'X G G X' column at x 59.",
]
for i, t in enumerate(notes):
    d.text((24, 100 + gh + 50 + i * 26), t, font=FS, fill=INK if i in (1, 3) else DIM)
img.save(RV + "w4_gate_diagram.png")
print("saved", RV + "w4_gate_diagram.png", img.size)

# --- forest margin --------------------------------------------------------------------------------------------
half = lambda n: shot(n).resize((640, 360), Image.LANCZOS)
m = Sheet(1340, "ART-003 W-4: forest margin 6 -> 14 tiles (the live border's width)",
          "Each pair: BEFORE (Batch C, 6-tile margin) and AFTER (W-4, 14). Half size. The camera is the game's own; it stops at the live border.")
m.row("Road end, farmer at the gate (58.4, 34.5), day: the grey-green strip at the right edge is gone",
      [half("before_end_day.png"), half("after_end_day.png")], ["BEFORE", "AFTER"])
m.row("South-east corner (62.5, 38.5), day: the camera's furthest reach east and south",
      [half("before_se_day.png"), half("after_se_day.png")], ["BEFORE", "AFTER"])
m.row("North-west corner (0.5, 0.5), day: the furthest reach west and north",
      [half("before_nw_day.png"), half("after_nw_day.png")], ["BEFORE", "AFTER"])
m.save(RV + "w4_margin.png")

# --- walk frames -----------------------------------------------------------------------------------------------
if SCR:
    def strip(folder, n, title, crop=(320, 180, 960, 540), cols=4):
        files = sorted(os.listdir(folder))
        files = [f for f in files if f.endswith(".png")]
        idx = [int(i * (len(files) - 1) / (n - 1)) for i in range(n)]
        ims = [Image.open(os.path.join(folder, files[i])).convert("RGB").crop(crop) for i in idx]
        tw, th = ims[0].size
        out = Image.new("RGB", (cols * tw + (cols + 1) * 8, ((n + cols - 1) // cols) * (th + 30) + 50), BG)
        dd = ImageDraw.Draw(out)
        dd.text((8, 10), title + f"  ({len(files)} frames at 30 fps; {n} evenly spaced, centre crop 640x360 at 100%)", font=FS, fill=INK)
        for k, im in enumerate(ims):
            x, y = 8 + (k % cols) * (tw + 8), 40 + (k // cols) * (th + 30)
            out.paste(im, (x, y))
            dd.text((x, y + th + 4), f"frame {idx[k] + 1}", font=FS, fill=DIM)
        return out
    for key, n, title in [("rd", 12, "Route walk, day: porch, well, oak, garden, road, dock. Legs skipped: none"),
                          ("rn", 12, "Route walk, R3-1 night: the same route. Legs skipped: none"),
                          ("gd", 8, "Gate push, day: east along rows 34.5, 35.5, 33.4, 36.5; all four stop at x 58.66"),
                          ("gn", 8, "Gate push, R3-1 night: the same; all four stop at x 58.66")]:
        strip(os.path.join(SCR, "after", "mv", key), n, "ART-003 W-4 " + title).save(RV + f"w4_walk_{key}.png")
        print("saved", RV + f"w4_walk_{key}.png")

# --- Task B: live, prototype and the parity blueprint ----------------------------------------------------------
P = A + "parity/"
ims = [Image.open(P + n).convert("RGB") for n in ["live_layout.png", "prototype_layout.png", "parity_blueprint.png"]]
out = Image.new("RGB", (ims[0].width + ims[1].width + 48, ims[0].height + ims[2].height + 120), BG)
dd = ImageDraw.Draw(out)
dd.text((16, 12), "ART-003 W-4 Task B: layout parity (documentation only; nothing built or migrated)", font=FB, fill=INK)
dd.text((16, 46), "Top: the live farm today and the ART-003 prototype at the same 64x40 inner-tile scale. Bottom: the proposed parity layout, every live feature placed.",
        font=FS, fill=DIM)
out.paste(ims[0], (16, 80))
out.paste(ims[1], (32 + ims[0].width, 80))
out.paste(ims[2], (16, 100 + ims[0].height))
out.save(RV + "w4b_layouts.png")
print("saved", RV + "w4b_layouts.png", out.size)
