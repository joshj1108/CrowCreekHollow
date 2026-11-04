# ART-003 W-3 Batch B (non-production): the raised bed refitted to the 7x4-tile beds (112x64) from the R2 bed
# (r2/garden_bed.png, 96x48, which covered only 6x3 tiles of each bed). No resampling: middle columns and soil rows
# are repeated, then tilled furrows are drawn across the soil under each crop row. -> bed_w3b.png
from PIL import Image
src = Image.open('../../r2/garden_bed.png').convert('RGBA')
W, H = src.size
cols = list(range(0, 48)) + list(range(27, 48)) + list(range(48, 96))      # +21 columns from the bed's middle
wide = Image.new('RGBA', (len(cols), H), (0, 0, 0, 0))
for i, c in enumerate(cols):
    wide.paste(src.crop((c, 0, c + 1, H)), (i, 0))
rows = list(range(0, 21)) + list(range(13, 21)) * 2 + list(range(13, 18)) + list(range(21, 48))   # +21 soil rows
tall = Image.new('RGBA', (wide.width, len(rows)), (0, 0, 0, 0))
for i, r in enumerate(rows):
    tall.paste(wide.crop((0, r, wide.width, r + 1)), (0, i))
bed = tall.crop((3, 3, 115, 67))
print('bbox', bed.getbbox(), bed.size)
px = bed.load()
# Soil: the dark interior between the frame's light rails (rows 12..50 after the stretch).
def is_soil(c):
    return c[3] > 0 and sum(c[:3]) < 300
# Calmer soil: the R2 bed's red specks pulled to a dark loam brown (the concept's beds are brown-black, not red).
for y in range(bed.height):
    for x in range(bed.width):
        c = px[x, y]
        if is_soil(c) and c[0] > c[1] * 1.45:
            l = (c[0] + c[1] + c[2]) / 3
            px[x, y] = (int(l * 1.25), int(l * 0.95), int(l * 0.7), 255)
# Furrows: one ridge per crop row, under where the crops' bases sit (every 16 px from the bed's top rows).
for base in (24, 40, 56 - 4):
    for x in range(bed.width):
        for y, f in ((base - 2, 1.3), (base - 1, 1.15), (base, 0.55), (base + 1, 0.7)):
            c = px[x, y]
            # only well inside the soil: the pixels left and right two over are soil too
            if is_soil(c) and is_soil(px[max(x - 3, 0), y]) and is_soil(px[min(x + 3, bed.width - 1), y]):
                px[x, y] = (min(int(c[0] * f), 255), min(int(c[1] * f), 255), min(int(c[2] * f), 255), 255)
bed.save('bed_w3b.png')
bed.resize((bed.width * 4, bed.height * 4), Image.NEAREST).save('../_bed4x.png')
