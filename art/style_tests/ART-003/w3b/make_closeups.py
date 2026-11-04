# ART-003 W-3 Batch B (non-production): the farmhouse close-up and alignment sheet, and the new-art sheet.
#   python make_closeups.py  ->  review/house_closeups.png, review/assets.png
from PIL import Image, ImageDraw, ImageFont
F = ImageFont.truetype('arial.ttf', 15)
FB = ImageFont.truetype('arialbd.ttf', 20)
BG = (30, 32, 30)
GR = (70, 96, 52, 255)

def on_grass(im, k):
    bg = Image.new('RGBA', im.size, GR)
    bg.alpha_composite(im.convert('RGBA'))
    return bg.resize((im.width * k, im.height * k), Image.NEAREST)

def marks(im, k):
    # the locked landmarks: door centre x 96, windows (48, 112) and (143, 112), wall line y 149 (its last row)
    d = ImageDraw.Draw(im)
    c = (0, 255, 255)
    d.line((96 * k + k // 2, 0, 96 * k + k // 2, im.height), fill=c, width=1)
    d.line((0, 150 * k, im.width, 150 * k), fill=(255, 80, 80), width=1)
    for (x, y) in ((48, 112), (143, 112)):
        X, Y = x * k + k // 2, y * k + k // 2
        d.line((X - 14, Y, X + 14, Y), fill=c, width=1)
        d.line((X, Y - 14, X, Y + 14), fill=c, width=1)
    return im

def sheet(title, note, cells, cols, out):
    pad = 14
    cw = max(c[1].width for c in cells)
    rows = [cells[i:i + cols] for i in range(0, len(cells), cols)]
    rh = [max(c[1].height for c in r) + 26 for r in rows]
    W = pad + cols * (cw + pad)
    H = 94 + sum(h + pad for h in rh)
    s = Image.new('RGB', (W, H), BG)
    d = ImageDraw.Draw(s)
    d.text((pad, 8), title, font=FB, fill='white')
    d.text((pad, 38), note, font=F, fill=(200, 200, 190))
    y = 94
    for r, h in zip(rows, rh):
        for i, (lab, im) in enumerate(r):
            x = pad + i * (cw + pad)
            d.text((x, y), lab, font=F, fill='white')
            s.paste(im.convert('RGB'), (x, y + 22))
        y += h + pad
    s.save(out)
    print(out, s.size)

prod = Image.open('../../../farm/house_stage_3.png').convert('RGBA')
alt = Image.open('house/house_w3b.png').convert('RGBA')
concept = Image.open('house/concept_house_crop.png').convert('RGB')
k = 3
cells = [
    ('Concept 02, the house (crop, 400x310, smooth x1.44)', concept.resize((576, int(310 * 576 / 400)), Image.LANCZOS)),
    ('PRODUCTION house_stage_3, 192x160 at 3x (1:1 in game)', on_grass(prod, k)),
    ('BATCH B house_w3b, 192x160 at 3x', on_grass(alt, k)),
    ('Init: concept fitted to the locked frame (guide only)', on_grass(Image.open('house/init.png'), k)),
    ('Production with the locked landmarks', marks(on_grass(prod, k), k)),
    ('Batch B with the locked landmarks', marks(on_grass(alt, k), k)),
]
diff = Image.open('house/house_w3b_diff.png').convert('RGBA')
cells += [
    ('Hand edits after the 1 px shift (magenta): 2,229 px, 11.1%', on_grass(diff, k)),
]
gens = [('a_s250p', 'A: strength 250, concept palette'), ('b_s250', 'B: strength 250, free palette'),
        ('c_s170p', 'C (chosen): strength 170, concept palette'), ('d_s170', 'D: strength 170, free palette')]
for f, lab in gens[:2]:
    cells.append((lab, on_grass(Image.open('house/gen_%s.png' % f), k)))
sheet('ART-003 W-3 Batch B: farmhouse close-ups and alignment (non-production)',
      'Cyan: door centre x 96 and window centres (48, 112), (143, 112); red: the wall line (last wall row y 149).\n'
      'Measured on Batch B: windows 48.5/111.5 and 143.5/112.0, steps centred 96.5, '
      'walls x 10..188 (production 11..180), footing ends y 149, steps y 150..159. PixelLab: 4 pixflux img2img runs, 1 credit each, seed 701.',
      cells + [(lab, on_grass(Image.open('house/gen_%s.png' % f), k)) for f, lab in gens[2:]], 3, 'review/house_closeups.png')

# New art at 4x: the crop strip (raw and sliced) and the R2 bed beside its refit.
crops_raw = Image.open('garden/crops_gen.png').convert('RGBA')
crops = Image.open('garden/crops_w3b.png').convert('RGBA')
bed = Image.open('garden/bed_w3b.png').convert('RGBA')
oldbed = Image.open('../r2/garden_bed.png').convert('RGBA')
cells = [
    ('Crop strip as generated (128x32, pixflux, 1 credit) at 4x', on_grass(crops_raw, 4)),
    ('Sliced: corn pumpkin beans cabbage kale squash turnip sunflower (16x32 cells) at 4x', on_grass(crops, 4)),
    ('R2 bed, 96x48 (covered 6x3 of the 7x4 tiles) at 4x', on_grass(oldbed, 4)),
    ('Refitted bed, 112x64 (no resampling; red specks calmed, furrows) at 4x', on_grass(bed, 4)),
]
sheet('ART-003 W-3 Batch B: new and refitted garden art (non-production)',
      'Only the crop strip is new PixelLab art. The bed is the R2 bed widened and deepened by repeating\n'
      'its own middle columns and soil rows. The north-south fence rail is built in the tool from src/fence.png (its top rail turned on end).',
      cells, 2, 'review/assets.png')
