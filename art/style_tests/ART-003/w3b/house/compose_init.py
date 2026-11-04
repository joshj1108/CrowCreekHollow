# ART-003 W-3 Batch B (non-production): the init image for the Restored-house img2img.
# The concept house (concept_house_crop.png, from concept 02) is fitted to the locked sprite frame: 192x160, walls
# x 12..181 ending at y 149, door centred at x 96, front windows centred at (48, 112) and (143, 112), steps under the
# door to the bottom edge. The concept's roof, cross-gable and chimney come from the crop; the wall band is repainted
# by hand at the locked positions in the concept's colours. It is a guide for PixelLab only, never a sprite.
#   python compose_init.py   ->  init.png, init_3x.png
from PIL import Image, ImageDraw

W, H = 192, 160
crop = Image.open('concept_house_crop.png').convert('RGB')
# The concept house from its chimney top (y 18) to its porch floor (y 250), between the wings' outer posts (x 30..372).
src = crop.crop((30, 14, 372, 252))
body = src.resize((W - 8, 150), Image.LANCZOS)       # 184 x 150: walls end at 149
img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
img.paste(body, (-1, 0))   # the concept's door (crop x 211) lands on x 96
# Cut away the forest behind the roof: keep pixels inside a roof/house silhouette drawn by hand.
mask = Image.new('L', (W, H), 0)
d = ImageDraw.Draw(mask)
d.polygon([(4, 150), (4, 74), (10, 64), (34, 64), (36, 30), (84, 30), (96, 8), (108, 28), (122, 28), (123, 0),
           (143, 0), (145, 30), (151, 32), (152, 74), (188, 98), (188, 150)], fill=255)
img.putalpha(mask)
d = ImageDraw.Draw(img)

WALL = (150, 112, 74, 255)        # warm timber
WALL_D = (96, 66, 44, 255)
BEAM = (58, 40, 30, 255)
GLOW = (246, 196, 104, 255)
GLOW_D = (196, 128, 58, 255)
STONE = (92, 88, 84, 255)
STONE_L = (128, 122, 112, 255)
DOOR = (104, 62, 40, 255)
OUT = (28, 22, 20, 255)
# Wall band under the eaves: planks with posts, then a stone footing.
d.rectangle((12, 96, 181, 149), fill=WALL)
for y in range(100, 143, 5):
    d.line((12, y, 181, y), fill=WALL_D)
for x in (12, 66, 126, 181):
    d.rectangle((x - 2, 92, x + 2, 149), fill=BEAM)
d.rectangle((12, 142, 181, 149), fill=STONE)
for x in range(14, 181, 9):
    d.rectangle((x, 143, x + 5, 146), fill=STONE_L)
# Porch roof between the posts, under the gable: a shingled shed roof.
d.polygon([(60, 88), (132, 88), (136, 98), (56, 98)], fill=(54, 62, 78, 255), outline=OUT)
# Door at x 86..106, lamps either side.
d.rectangle((85, 102, 107, 147), fill=OUT)
d.rectangle((87, 104, 105, 147), fill=DOOR)
d.line((96, 104, 96, 147), fill=BEAM)
for lx in (78, 114):
    d.rectangle((lx - 2, 108, lx + 2, 114), fill=GLOW)
# Front windows centred at (48, 112) and (143, 112): frame, warm glass, mullions, a flower box.
for cx in (48, 143):
    d.rectangle((cx - 12, 98, cx + 12, 126), fill=BEAM)
    d.rectangle((cx - 10, 100, cx + 10, 124), fill=GLOW)
    d.line((cx, 100, cx, 124), fill=GLOW_D)
    d.line((cx - 10, 112, cx + 10, 112), fill=GLOW_D)
    d.rectangle((cx - 13, 127, cx + 13, 132), fill=(90, 52, 34, 255))
    for k in range(cx - 12, cx + 13, 3):
        d.point((k, 126), fill=(200, 70, 50, 255) if k % 2 else (226, 180, 70, 255))
# Steps from the porch to the sprite's bottom edge, under the door.
for i, y in enumerate((150, 154, 157)):
    d.rectangle((80 + i * 0, y, 112 - i * 0, y + 2 + (1 if i == 2 else 0)), fill=STONE_L if i % 2 == 0 else STONE)
img.save('init.png')
img.resize((W * 3, H * 3), Image.NEAREST).save('init_3x.png')
print('init.png', img.size)
