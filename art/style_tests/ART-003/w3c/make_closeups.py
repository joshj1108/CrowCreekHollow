# ART-003 W-3 Batch C close-up sheet: the generated sprites at 4x (raw and as used) and the new groups in game at 100%.
# Run from the repo root after the renders are copied to builds/review/ART-003/w3c/ (after_<view>_<time>.png).
from PIL import Image, ImageDraw, ImageFont
B, C = "builds/review/ART-003/w3c/", "art/style_tests/ART-003/w3c/"
BG, INK = (34, 36, 30), (235, 228, 210)
try:
    font = ImageFont.truetype("arial.ttf", 18); small = ImageFont.truetype("arial.ttf", 14)
except OSError:
    font = small = ImageFont.load_default()

def sprite(path, k=4):
    im = Image.open(C + path).convert("RGBA")
    bg = Image.new("RGBA", im.size, (70, 74, 40, 255)); bg.alpha_composite(im)
    return bg.resize((im.width * k, im.height * k), Image.NEAREST)

sprites = [("apple, as generated", "gen/apple.png"), ("apple, hand-fixed", "orchard/apple_w3c.png"),
           ("pear (unchanged)", "orchard/pear_w3c.png"), ("prop strip, as generated", "gen/props.png"),
           ("mailbox (retry)", "props/mailbox.png")]
crops = [("Orchard close, day, 100%", "after_OR_day.png", (330, 40, 950, 420)),
         ("Orchard close, R3-1 night, 100%", "after_OR_night.png", (330, 40, 950, 420)),
         ("V3 north: woodcutting corner by the well (reused SpriteCook props), day 100%", "after_V3_day.png", (420, 20, 1040, 400)),
         ("V3 south: signpost + boulder group, handcart of sacks, day 100%", "after_V3_day.png", (380, 330, 1000, 710)),
         ("Arrival: mailbox, dead tree, ruts, day 100%", "after_AR_day.png", (420, 230, 1040, 610)),
         ("Garden SW corner from V2: rain barrel + compost, day 100%", "after_V2_day.png", (0, 340, 620, 720))]
row1 = [(t, sprite(p)) for t, p in sprites]
W = max(sum(i.width for _, i in row1) + 30 * len(row1), 2 * 620 + 60)
H1 = max(i.height for _, i in row1) + 40
H2 = 3 * (380 + 34)
out = Image.new("RGB", (W + 40, 70 + H1 + H2 + 20), BG)
d = ImageDraw.Draw(out)
d.text((20, 14), "ART-003 W-3 Batch C: new sprites at 4x and the new groups in game at 100%", font=font, fill=INK)
d.text((20, 40), "4 PixelLab pixflux generations (limit 5). Apple hand-fixed (fix_apple.py); covered cart unused.", font=small, fill=INK)
x, y = 20, 70
for t, im in row1:
    d.text((x, y), t, font=small, fill=INK)
    out.paste(im, (x, y + 22 + (H1 - 40 - im.height)))
    x += im.width + 30
y = 70 + H1
for i, (t, f, box) in enumerate(crops):
    cx, cy = 20 + (i % 2) * 650, y + (i // 2) * (380 + 34)
    d.text((cx, cy), t, font=small, fill=INK)
    out.paste(Image.open(B + f).convert("RGB").crop(box), (cx, cy + 22))
out.save(C + "review/batchc_closeups.png")
print(out.size)
