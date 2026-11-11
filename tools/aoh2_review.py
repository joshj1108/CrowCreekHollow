"""ART-OVERHAUL-002 review sheets 4, 5 and 7 (the ones that are not BEFORE / AFTER pairs; tools/review_sheet.ps1
makes 1, 2, 3 and 6). Run from the repository root after tools/aoh2_shots.sh has filled E4/after/:
  python tools/aoh2_review.py
Sheet 4: the same farm places in each season. Sheet 5: the mill trek in each season, day and night, and two other
routes. Sheet 7: the new and changed sprites at native size and 3x, with their sizes, the season ramps, and the trek
atlas by season.
"""
import json, os
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
A = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/review/half/after/')
OUT = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/review/')
BG = (28, 26, 24)
INK = (232, 222, 200)
DIM = (170, 160, 140)
try:
    FONT = ImageFont.truetype('arial.ttf', 15)
    BIG = ImageFont.truetype('arialbd.ttf', 20)
except OSError:
    FONT = BIG = ImageFont.load_default()


def header(title, change, width):
    h = 64
    im = Image.new('RGB', (width, h), BG)
    d = ImageDraw.Draw(im)
    d.text((16, 10), title, fill=INK, font=BIG)
    d.text((16, 38), change, fill=DIM, font=FONT)
    return im


def grid(title, change, cells, cols):
    """cells: [(label, image path)], laid out cols wide, each 640x360 with a caption above."""
    w, h, cap, pad = 640, 360, 22, 12
    rows = (len(cells) + cols - 1) // cols
    W = pad + cols * (w + pad)
    hd = header(title, change, W)
    sh = Image.new('RGB', (W, hd.height + rows * (h + cap + pad) + pad), BG)
    sh.paste(hd, (0, 0))
    d = ImageDraw.Draw(sh)
    for k, (label, path) in enumerate(cells):
        x = pad + (k % cols) * (w + pad)
        y = hd.height + pad + (k // cols) * (h + cap + pad)
        d.text((x, y), label, fill=INK, font=FONT)
        sh.paste(Image.open(path).convert('RGB'), (x, y + cap))
    return sh


def sheet4():
    cells = []
    for place, name in [('season', 'Farmhouse, Great Tree and well'), ('orchard', 'Orchard')]:
        for s in ['spring', 'summer', 'autumn', 'winter']:
            cells.append(('%s, %s, 11:00, sunny (same tile, same camera)' % (name, s.capitalize()), A + '%s_%s.png' % (place, s)))
    cells.append(('Farmhouse, Winter, snowing (the snow dusting on the grass)', A + 'season_winter_snow.png'))
    return grid('ART-OVERHAUL-002 Sheet 4: the farm by season (E5)',
                'Spring and summer greens, autumn the original art, winter bare deciduous trees and dormant ground; firs, '
                'buildings and paths unchanged. Driven by the day\'s season; no gameplay change.', cells, 4)


def sheet5():
    cells = [('Mill trek, %s, 11:00' % s.capitalize(), A + 'trek_%s.png' % s) for s in ['spring', 'summer', 'autumn', 'winter']]
    cells += [('Mill trek, Summer, night, lantern 2', A + 'trek_summer_night.png'),
              ('Mill trek, Winter, night, lantern 2', A + 'trek_winter_night.png'),
              ('Orchard trek destination, Summer, 11:00', A + 'trek_orchard_summer.png'),
              ('Chapel trek destination, Winter, 11:00', A + 'trek_chapel_winter.png')]
    return grid('ART-OVERHAUL-002 Sheet 5: treks by season (E5)',
                'The trek atlas was autumn all year; now green maples and apples in spring and summer, bare in winter, '
                'and the trek grounds take the farm\'s seasonal grass. Layout, events and gloom unchanged.', cells, 4)


def tile(im, scale, label, d_label=True):
    im = im.convert('RGBA')
    big = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
    cap = 34
    c = Image.new('RGBA', (max(big.width, im.width) + im.width + 24, big.height + cap + 8), BG + (255,))
    c.alpha_composite(im, (4, cap + big.height - im.height))
    c.alpha_composite(big, (im.width + 16, cap))
    d = ImageDraw.Draw(c)
    d.text((4, 2), label, fill=INK, font=FONT)
    d.text((4, 17), '%dx%d px, shown 1x and %dx' % (im.width, im.height, scale), fill=DIM, font=FONT)
    return c


def flow(tiles, width, pad=12):
    rows, row, x = [], [], pad
    for t in tiles:
        if row and x + t.width > width:
            rows.append(row)
            row, x = [], pad
        row.append(t)
        x += t.width + pad
    rows.append(row)
    H = sum(max(t.height for t in r) + pad for r in rows) + pad
    im = Image.new('RGBA', (width, H), BG + (255,))
    y = pad
    for r in rows:
        x = pad
        for t in r:
            im.alpha_composite(t, (x, y))
            x += t.width + pad
        y += max(t.height for t in r) + pad
    return im


def sheet7():
    W = 2000
    parts = [header('ART-OVERHAUL-002 Sheet 7: pixel-art asset validation (E4, E5)',
                    'Native size and 3x (the game draws every art pixel as 3x3 screen pixels). Seasonal variants keep '
                    'their autumn sprite\'s exact canvas, so placement and Y-sorting are unchanged.', W)]
    sizes = json.load(open(os.path.join(ROOT, 'art/farm/e4/sizes.json')))
    parts.append(flow([tile(Image.open(os.path.join(ROOT, 'art/farm/e4/%s.png' % n)), 3, 'E4 ' + n) for n in sizes], W))
    rows = []
    for base, label, sc in [('gen_833b1e3652', 'Great Tree', 1), ('src_maple', 'farm maple', 2), ('w4_orchard_apple_a', 'orchard apple', 2),
                            ('w4_orchard_pear_a', 'orchard pear', 2), ('src_undergrowth', 'undergrowth', 3), ('bramble_0', 'cave bramble', 3)]:
        src = os.path.join(ROOT, 'art/farm/concept/%s.png' % base)
        if not os.path.exists(src):
            src = os.path.join(ROOT, 'art/farm/cave_ext/%s.png' % base)
        ims = [('autumn (original)', Image.open(src))] + [(s, Image.open(os.path.join(ROOT, 'art/farm/e5/%s_%s.png' % (base, s)))) for s in ['spring', 'summer', 'winter']]
        rows += [tile(im, sc, '%s, %s' % (label, s)) for s, im in ims]
    parts.append(flow(rows, W))
    # Ramps.
    src = open(os.path.join(ROOT, 'tools/aoh2_e5.py')).read().split("if __name__")[0]
    ns = {'__file__': os.path.join(ROOT, 'tools/aoh2_e5.py')}
    exec(src, ns)
    sw = Image.new('RGBA', (W, 120), BG + (255,))
    d = ImageDraw.Draw(sw)
    x = 12
    for name, ramp in ns['RAMPS'].items():
        d.text((x, 6), '%s leaf ramp' % name, fill=INK, font=FONT)
        for k, c in enumerate(ramp):
            d.rectangle((x + k * 40, 28, x + k * 40 + 36, 64), fill=ns['hexc'](c))
            d.text((x + k * 40, 70), '#' + c, fill=DIM, font=FONT)
        x += 240
    d.text((x, 6), 'Ground grass by season (h shift, sat, val, frost):', fill=INK, font=FONT)
    for k, (s, v) in enumerate(ns['SEASON_GRASS'].items()):
        d.text((x, 28 + k * 18), '%s  %+.3f  x%.2f  x%.2f  %.2f' % (s, *v), fill=DIM, font=FONT)
    parts.append(sw)
    # Trek atlas by season (top band, 2x).
    at = []
    for s, p in [('autumn (original)', 'art/farm/trek/atlas.png')] + [(s, 'art/farm/trek/e5/atlas_%s.png' % s) for s in ['spring', 'summer', 'winter']]:
        im = Image.open(os.path.join(ROOT, p)).convert('RGBA').crop((0, 90, 512, 200))
        t = Image.new('RGBA', (1024 + 24, 220 + 24), BG + (255,))
        t.alpha_composite(im.resize((1024, 220), Image.NEAREST), (12, 24))
        ImageDraw.Draw(t).text((12, 4), 'Trek atlas (512x350, rows 90-200 at 2x), ' + s, fill=INK, font=FONT)
        at.append(t)
    parts.append(flow(at, W))
    H = sum(p.height for p in parts)
    sh = Image.new('RGB', (W, H), BG)
    y = 0
    for p in parts:
        sh.paste(p.convert('RGB'), (0, y))
        y += p.height
    return sh


if __name__ == '__main__':
    sheet4().save(OUT + 'sheet4_seasons.png')
    sheet5().save(OUT + 'sheet5_seasonal_treks.png')
    sheet7().save(OUT + 'sheet7_assets.png')
    for n in ['sheet4_seasons', 'sheet5_seasonal_treks', 'sheet7_assets']:
        print(n, Image.open(OUT + n + '.png').size)
