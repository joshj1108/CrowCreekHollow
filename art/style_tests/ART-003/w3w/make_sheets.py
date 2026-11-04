# ART-003 W-3 wall comparison (non-production, no generation): farmhouse walls A (warm weathered), M (midpoint) and
# B (dark weathered) on the polish house, with the roof, windows, porch, surroundings, G1 grass and R3-1 night the same.
#   python make_sheets.py  ->  review/wall_views.png, wall_closeups.png, wall_ingame.png and the wall-pixel table
# Renders come from builds/review/ART-003/w3w (<wall>_<view>_<day|night>.png, art003_wide.gd art=w3p grass=1 wall=X).
# The concept cells are the ones on the polish package's house_views.png, so the reference is the one already reviewed.
from PIL import Image, ImageDraw, ImageFont
F = ImageFont.truetype('arial.ttf', 15)
FB = ImageFont.truetype('arialbd.ttf', 20)
BG = (30, 32, 30)
GR = (70, 96, 52, 255)
R = '../../../../builds/review/ART-003/w3w/'
H = '../w3p/house/'
WALLS = (('a', 'A warm weathered'), ('m', 'M midpoint'), ('b', 'B dark weathered'))


def sheet(title, note, rows, out):
    # rows: (label, [(tag, image), ...]); every cell in a column is the same width
    pad = 14
    n = max(len(r[1]) for r in rows)
    cw = [max(r[1][i][1].width for r in rows if len(r[1]) > i) for i in range(n)]
    W = pad + sum(c + pad for c in cw)
    Hh = 100 + sum(max(c[1].height for c in r[1]) + 48 for r in rows)
    s = Image.new('RGB', (W, Hh), BG)
    d = ImageDraw.Draw(s)
    d.text((pad, 8), title, font=FB, fill='white')
    d.multiline_text((pad, 38), note, font=F, fill=(200, 200, 190))
    y = 100
    for lab, cells in rows:
        d.text((pad, y), lab, font=FB, fill='white')
        x = pad
        for i, (tag, im) in enumerate(cells):
            d.text((x, y + 24), tag, font=F, fill=(230, 220, 170))
            s.paste(im.convert('RGB'), (x, y + 44))
            x += cw[i] + pad
        y += max(c[1].height for c in cells) + 48
    s.save(out)
    print(out, s.size)


def on_grass(im, k):
    bg = Image.new('RGBA', im.size, GR)
    bg.alpha_composite(im.convert('RGBA'))
    return bg.resize((im.width * k, im.height * k), Image.NEAREST)


# The concept cells from the polish sheet (640x360 each: V1-B day, V1-B night, V5 day, V5 night).
hv = Image.open('../w3p/review/house_views.png').convert('RGB')
concept = {k: hv.crop((14, y, 654, y + 360)) for k, y in
           (('V1_day', 111), ('V1_night', 527), ('V5_day', 943), ('V5_night', 1359))}
concept['E_day'], concept['E_night'] = concept['V5_day'], concept['V5_night']

VIEW = {'V1': 'V1-B (farmer at 38.5,10)', 'V5': 'V5 (farmer on the porch path, 45,13.5)',
        'E': 'Establishing (farmer 2 tiles north of the wall line, 45,10; hidden behind the house)'}
rows = []
for v in ('V1', 'V5', 'E'):
    for t, when in (('day', '12:00 sunny'), ('night', '21:30 sunny, R3-1 night')):
        cells = [('Concept 02 (reference)' if v != 'E' else 'Concept 02 (the V5 crop)', concept['%s_%s' % (v, t)])]
        for w, name in WALLS:
            cells.append((name, Image.open(R + '%s_%s_%s.png' % (w, v, t)).reduce(2)))
        rows.append(('%s, %s' % (VIEW[v], when), cells))
sheet('ART-003 W-3 wall comparison: concept | A warm | M midpoint | B dark (non-production, no generation)',
      'Polish house (candidate C) with only the wall boards changed: A x0.74 +6 warm, M x0.68 +5, B x0.62 +4 (the '
      'polish default). Roof, windows, porch, dressing, garden, G1 grass,\nR3-1 night, lantern energy, camera and scale '
      'are the same in every game cell. Game frames at 50%. V5 on the porch path cuts the roof and chimney; the '
      'establishing row shows the full facade.',
      rows, 'review/wall_views.png')

# Close-ups: the sprites at 3x and the house in game at 100%.
con = Image.open('../w3b/house/concept_house_crop.png').convert('RGBA')
con = con.resize((576, round(con.height * 576 / con.width)), Image.LANCZOS)   # reference only, smooth-scaled
crops = {'V1': (700, 0, 1276, 420), 'V5': (376, 0, 952, 360), 'E': (352, 0, 928, 480)}
rows = [('Sprites, day (unlit glass), 3x on flat grass', [(n, on_grass(Image.open(H + 'house_w3p_%s_day.png' % w), 3)) for w, n in WALLS]),
        ('Sprites, night (lit glass), 3x on flat grass, no night grade', [(n, on_grass(Image.open(H + 'house_w3p_%s_night.png' % w), 3)) for w, n in WALLS])]
for v, t in (('V1', 'day'), ('E', 'day'), ('E', 'night'), ('V5', 'day')):
    rows.append(('%s, %s, in game at 100%%' % (VIEW[v].split(' (')[0], t),
                 [(n, Image.open(R + '%s_%s_%s.png' % (w, v, t)).crop(crops[v])) for w, n in WALLS]))
rows.insert(0, ('Concept 02 house (reference, smooth-scaled)', [('Concept 02', con)]))
sheet('ART-003 W-3 wall comparison: sprites (non-production, no generation)',
      'Only the wall boards differ between columns. The board-to-board tone and grain, trim, roof, glass, porch deck '
      'and stone treads are the same.',
      rows[:3], 'review/wall_closeups.png')
sheet('ART-003 W-3 wall comparison: in game at 100% (non-production, no generation)',
      'The house crops from the same frames as the views sheet. Only the wall boards differ between columns.',
      rows[3:], 'review/wall_ingame.png')

# Wall pixels only: the pixels that differ between the A and B day sprites are exactly the wall boards.
def luma(c):
    return (0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]) / 255


a = Image.open(H + 'house_w3p_a_day.png').convert('RGBA')
b = Image.open(H + 'house_w3p_b_day.png').convert('RGBA')
mask = [i for i, (p, q) in enumerate(zip(a.getdata(), b.getdata())) if p != q]
b3 = Image.open('../w3b/house/house_w3b.png').convert('RGBA')
print('wall pixels', len(mask))
for name, im in (('Batch B', b3), ('A', a), ('M', Image.open(H + 'house_w3p_m_day.png')), ('B', b)):
    px = list(im.convert('RGBA').getdata())
    cs = [px[i] for i in mask]
    mean = tuple(round(sum(c[k] for c in cs) / len(cs)) for k in range(3))
    print('%-8s wall mean RGB %s luma %.3f' % (name, mean, sum(luma(c) for c in cs) / len(cs)))
