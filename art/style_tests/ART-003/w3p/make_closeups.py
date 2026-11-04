# ART-003 W-3 polish (non-production): the farmhouse and garden close-up sheets, from the sprites and the renders.
#   python make_closeups.py  ->  review/house_closeups.png, review/garden_closeups.png
# Renders come from builds/review/ART-003/w3p (Batch B = pre_*, polish = post_*). In-game crops are 100%: the game
# already draws at 3x, so one screen pixel per pixel here.
from PIL import Image, ImageDraw, ImageFont
F = ImageFont.truetype('arial.ttf', 15)
FB = ImageFont.truetype('arialbd.ttf', 20)
BG = (30, 32, 30)
GR = (70, 96, 52, 255)
R = '../../../../builds/review/ART-003/w3p/'


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


H = 'house/'
b3 = Image.open('../w3b/house/house_w3b.png')
con = Image.open('../w3b/house/concept_house_crop.png').convert('RGBA')
con = con.resize((576, round(con.height * 576 / con.width)), Image.LANCZOS)   # reference only, smooth-scaled
cells = [('Concept 02 (reference, smooth-scaled)', con),
         ('Batch B (as reviewed), 3x, landmarks marked', marks(on_grass(b3, 3), 3))]
for v, name in (('b', 'b dark weathered (chosen)'), ('a', 'a warm weathered'), ('c', 'c grey weathered')):
    cells.append(('Polish %s, day (unlit glass, curtains), 3x' % name, marks(on_grass(Image.open(H + 'house_w3p_%s_day.png' % v), 3), 3)))
cells.append(('Polish b, night sprite (Batch B lit glass kept), 3x', marks(on_grass(Image.open(H + 'house_w3p_b_night.png'), 3), 3)))
crop = (376, 0, 952, 360)   # V5: the house's front at 100%
for t in ('day', 'night'):
    for tag, lab in (('pre', 'Batch B'), ('post', 'Polish b')):
        im = Image.open(R + '%s_V5_%s.png' % (tag, t)).crop(crop)
        cells.append(('%s, V5 %s, in game at 100%%' % (lab, t), im))
sheet('ART-003 W-3 polish: farmhouse close-ups (non-production, no generation)',
      'Candidate C repainted: darker weathered walls, blue-black roof (green/purple flecks removed), unlit day glass with '
      'curtains, plank porch deck, stone treads; porch dressing from existing art.\nCyan: locked door x 96 and window '
      'centres; red: wall line y 149. Silhouette, size, door, windows, footing and lights are unchanged.',
      cells, 2, 'review/house_closeups.png')

gc = []
crop = (120, 150, 760, 630)   # V2: the two west beds and the cross walk at 100%
for t in ('day', 'night'):
    for tag, lab in (('pre', 'Batch B'), ('post', 'Polish')):
        gc.append(('%s, V2 %s, 100%%' % (lab, t), Image.open(R + '%s_V2_%s.png' % (tag, t)).crop(crop)))
cr = Image.open('../w3b/garden/crops_w3b.png')
cp = Image.open('garden/crops_w3p.png')
strip = Image.new('RGBA', (cr.width, cr.height * 2 + 4), (0, 0, 0, 0))
strip.paste(cr, (0, 0))
strip.paste(cp, (0, cr.height + 4))
gc.append(('Crop cells, 4x: Batch B (top) / polish (bottom); only corn and beans change', on_grass(strip, 4)))
night = strip.copy()
px = night.load()
for y in range(night.height):   # a rough look at the night tint: multiply by R3-1's 8592b8 and darken
    for x in range(night.width):
        p = px[x, y]
        if p[3]:
            px[x, y] = (p[0] * 0x85 // 255 * 6 // 10, p[1] * 0x92 // 255 * 6 // 10, p[2] * 0xb8 // 255 * 6 // 10, p[3])
gc.append(('The same under a rough night multiply (not the game\'s grade)', on_grass(night, 4)))
sheet('ART-003 W-3 polish: garden close-ups (non-production, no generation)',
      'Rows varied: mixed rows in clumps of 2-3, one gap in most rows, three tones and small offsets per plant. Corn and '
      'pole beans recoloured (lighter leaf ramp, grey-wood pole) to hold up at night.\nSame four 7x4 beds, walkways, '
      'gates and collision.',
      gc, 2, 'review/garden_closeups.png')
