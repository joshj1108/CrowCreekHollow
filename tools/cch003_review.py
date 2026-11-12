"""CCH-CONSOLIDATED-003 Phase C review images (art/style_tests/CCH-003/review/C_*.png, plus the half-size captures
in art/style_tests/CCH-003/C/before|after/). Run from the repository root after the captures:
  python tools/cch003_review.py <full-size before dir> <full-size after dir> <before dump.json> <after dump.json>
The captures come from tools/capture.gd at scale=1 (1280x720); the dumps from tools/interior_test.gd dump=PATH.
Writes:
  C_furniture.png   every replaced piece: the old sprite and the new one, each at native size and at 4x
  C_detail.png      native-pixel crops (2x) of the same places before and after: the bed corner, the hearth and
                    fireside, the dining and pantry corner, the wash room and the study
  C_collision.png   each stage's tiles with everything bought, before and after: solid pieces, interactions,
                    walls, and the floor reachable from the door
  C_clipping.png    the clipping audit: what it found and how each was fixed
"""
import json, os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
REV = os.path.join(ROOT, 'art/style_tests/CCH-003/review')
FARM = os.path.join(ROOT, 'art/farm')
BG = (58, 54, 50, 255)
INK = (236, 228, 212, 255)
DIM = (170, 160, 146, 255)


def font(size):
    for f in ('C:/Windows/Fonts/segoeui.ttf', 'C:/Windows/Fonts/arial.ttf'):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


F_T, F_H, F_S = font(26), font(17), font(14)


def art(path, box=None):
    im = Image.open(os.path.join(FARM, path)).convert('RGBA')
    return im.crop(box) if box else im


# --- C_furniture -------------------------------------------------------------------------------------------

OLD_NEW = [
    ('Bed, Decrepit', art('int_beds.png', (0, 0, 32, 47)), 'fc/bed_0.png'),
    ('Bed, Boarded', art('int_beds.png', (32, 0, 64, 47)), 'fc/bed_1.png'),
    ('Bed, Patched', art('int_beds.png', (64, 0, 96, 47)), 'fc/bed_2.png'),
    ('Bed, Restored', art('int_beds.png', (96, 0, 128, 47)), 'fc/bed_3.png'),
    ('Feather bed (bought)', art('e4/feather_bed.png'), 'fc/bed_feather.png'),
    ('Desk', art('int_furniture.png', (0, 0, 27, 29)), 'fc/desk.png'),
    ('Washstand', art('int_furniture.png', (30, 0, 48, 29)), 'fc/wash.png'),
    ('Washstand, Restored', art('int_furniture.png', (52, 0, 70, 29)), 'fc/wash_fine.png'),
    ('Cooler (built)', art('int_furniture.png', (73, 0, 95, 29)), 'fc/cooler.png'),
    ('Dining table', art('int_table.png'), 'fc/table.png'),
    ('Chair, facing', art('int_chairs.png', (0, 0, 16, 24)), 'fc/chair_front.png'),
    ('Chair, from behind', art('int_chairs.png', (16, 0, 32, 24)), 'fc/chair_back.png'),
    ('Dresser (bought)', art('e4/dresser.png'), 'fc/dresser.png'),
    ('Armchair (bought)', art('e4/armchair.png'), 'fc/armchair.png'),
    ('Long-case clock (bought)', art('fi/clock_case.png'), 'fc/clock_case.png'),
    ('Painting (bought)', art('e4/painting.png'), 'fc/painting.png'),
    ('Bookshelf (bought)', art('e4/bookshelf.png'), 'fc/bookshelf.png'),
    ('Bedside table', art('fi/bedside.png'), 'fc/bedside.png'),
    ('Side table / candle stand', art('fi/sidetable.png'), 'fc/sidetable.png'),
    ('Hearth rug', art('int_rug.png'), 'fc/rug.png'),
]
NEW_ONLY = ['firewood', 'crock', 'jug', 'books', 'cushion', 'plate', 'sampler', 'wreath']


def furniture():
    S = 4
    rows = []
    for label, old, new in OLD_NEW:
        rows.append((label, old, art(new)))
    colw = [230, 0, 0, 0, 0]
    colw[1] = max(r[1].width for r in rows) + 16
    colw[2] = max(r[1].width for r in rows) * S + 16
    colw[3] = max(r[2].width for r in rows) + 16
    colw[4] = max(r[2].width for r in rows) * S + 16
    # two columns of entries, so the sheet is not too tall
    half = (len(rows) + 1) // 2
    entry_w = sum(colw)
    heights = [max(r[1].height, r[2].height) * S + 14 for r in rows]
    col_h = [sum(heights[:half]), sum(heights[half:])]
    W = entry_w * 2 + 60
    extra = 280
    H = 120 + max(col_h) + 40 + extra
    o = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(o)
    d.text((20, 14), 'CCH-003 Phase C: the farmhouse furniture family (PixelLab), old and new', font=F_T, fill=INK)
    d.text((20, 50), 'Each row: OLD at native size and 4x, then NEW at native size and 4x (nearest-neighbour, on the house\'s '
           'mid-brown). Old: SpriteCook int_*.png, ART-OVERHAUL-002 E4 and FARMHOUSE-INTERIOR-001 fi/. New: art/farm/fc/.',
           font=F_S, fill=DIM)
    for c in range(2):
        x0 = 20 + c * (entry_w + 20)
        hx = x0
        for i, h in enumerate(['', 'OLD 1x', 'OLD 4x', 'NEW 1x', 'NEW 4x']):
            d.text((hx, 84), h, font=F_H, fill=INK)
            hx += colw[i]
        y = 110
        for k, (label, old, new) in enumerate(rows[c * half:(c + 1) * half]):
            h = heights[c * half + k]
            d.rectangle([x0 - 4, y - 2, x0 + entry_w - 8, y + h - 6], fill=(74, 62, 50, 255) if k % 2 == 0 else (68, 58, 48, 255))
            d.text((x0, y + 4), label, font=F_S, fill=INK)
            d.text((x0, y + 22), '%dx%d -> %dx%d' % (old.width, old.height, new.width, new.height), font=F_S, fill=DIM)
            y += h
    # the images, over the row bands
    for c in range(2):
        x0 = 20 + c * (entry_w + 20)
        y = 110
        for k, (label, old, new) in enumerate(rows[c * half:(c + 1) * half]):
            h = heights[c * half + k]
            x = x0 + colw[0]
            for im, s, cw in ((old, 1, colw[1]), (old, S, colw[2]), (new, 1, colw[3]), (new, S, colw[4])):
                big = im.resize((im.width * s, im.height * s), Image.NEAREST)
                o.alpha_composite(big, (x, y + 4))
                x += cw
            y += h
    y = 120 + max(col_h) + 20
    d.text((20, y), 'New lived-in detail (no old piece; Restored only, never bought furniture): native and 4x', font=F_H, fill=INK)
    x = 20
    y += 30
    for n in NEW_ONLY:
        im = art('fc/%s.png' % n)
        d.text((x, y), n, font=F_S, fill=DIM)
        o.alpha_composite(im, (x, y + 22))
        big = im.resize((im.width * S, im.height * S), Image.NEAREST)
        o.alpha_composite(big, (x + im.width + 8, y + 22))
        x += im.width * (S + 1) + 40
    o.save(os.path.join(REV, 'C_furniture.png'))


# --- C_detail -----------------------------------------------------------------------------------------------

def detail(bdir, adir):
    # (label, capture, crop box at full size 1280x720)
    spots = [
        ('Bedroom, Restored, day (s3)', 's3', (100, 90, 420, 400)),
        ('Hearth and fireside, Restored, 21:30, fire lit (n3)', 'n3', (430, 60, 960, 450)),
        ('Dining and pantry, Restored, 21:30, farmer north of the table (dining)', 'dining', (380, 280, 760, 640)),
        ('Wash room and study, Restored, day (east)', 'east', (900, 100, 1240, 600)),
        ('Bed and wake spot, Restored, 21:30 (bed)', 'bed', (60, 200, 420, 520)),
    ]
    tiles = []
    for label, cap, box in spots:
        b = Image.open(os.path.join(bdir, cap + '.png')).convert('RGBA').crop(box)
        a = Image.open(os.path.join(adir, cap + '.png')).convert('RGBA').crop(box)
        tiles.append((label, b, a))
    S = 1
    W = max(t[1].width for t in tiles) * 2 + 60
    H = 70 + sum(t[1].height + 40 for t in tiles)
    o = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(o)
    d.text((20, 14), 'CCH-003 Phase C: places in the house at native game pixels (1280x720 capture crops)', font=F_T, fill=INK)
    y = 60
    for label, b, a in tiles:
        d.text((20, y), label + '    BEFORE | AFTER', font=F_H, fill=INK)
        o.alpha_composite(b, (20, y + 26))
        o.alpha_composite(a, (40 + b.width, y + 26))
        y += b.height + 40
    o.save(os.path.join(REV, 'C_detail.png'))


# --- C_collision -------------------------------------------------------------------------------------------

def collision(bjson, ajson):
    def grid(path):
        data = json.load(open(path))
        return data['kinds'], data['stages']
    S = 14
    out = []
    for tag, path in (('BEFORE', bjson), ('AFTER', ajson)):
        kinds, stages = grid(path)
        out.append((tag, kinds, stages))
    W = 20 + 4 * (24 * S + 20)
    H = 70 + 2 * (14 * S + 50) + 60
    o = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(o)
    d.text((20, 14), 'CCH-003 Phase C: collision and paths, every stage with every piece of furniture bought', font=F_T, fill=INK)
    col = {'WALL': (24, 20, 18), 'TABLE': (150, 96, 58), 'BED': (176, 72, 72), 'DESK': (196, 150, 70),
           'FIREPLACE': (220, 110, 40), 'COOLER': (90, 150, 190), 'STATION': (120, 190, 160), 'EXIT': (240, 240, 240)}
    names = ['Decrepit', 'Boarded', 'Patched', 'Restored']
    y = 56
    for tag, kinds, stages in out:
        for s, rows in enumerate(stages):
            x0 = 20 + s * (24 * S + 20)
            d.text((x0, y), '%s  %s' % (tag, names[s]), font=F_H, fill=INK)
            for ty, row in enumerate(rows):
                for tx, (k, reach) in enumerate(row):
                    name = kinds[k]
                    c = col.get(name)
                    if c is None:
                        c = (96, 132, 86) if reach else (60, 56, 52)
                    r = [x0 + tx * S, y + 24 + ty * S, x0 + tx * S + S - 2, y + 24 + ty * S + S - 2]
                    d.rectangle(r, fill=c + (255,))
        y += 14 * S + 50
    lx = 20
    for name, c in [('reachable floor', (96, 132, 86)), ('floor not reachable (shut room)', (60, 56, 52)),
                    ('solid piece (TABLE)', col['TABLE']), ('bed', col['BED']), ('desk', col['DESK']),
                    ('hearth', col['FIREPLACE']), ('cooler', col['COOLER']), ('washstand', col['STATION']),
                    ('exit', col['EXIT'])]:
        d.rectangle([lx, y, lx + 14, y + 14], fill=c + (255,))
        d.text((lx + 20, y - 2), name, font=F_S, fill=INK)
        lx += 40 + int(d.textlength(name, font=F_S))
    o.save(os.path.join(REV, 'C_collision.png'))


# --- C_clipping --------------------------------------------------------------------------------------------

ISSUES = [
    ('Bed: a 3 art-px strip of floor between the headboard and the wall (the old bed began at the floor line).',
     'The bed is drawn from its foot row and its sprite\'s top 8 rows are the headboard, which now stands on the wall\'s '
     'face; the test checks the headboard\'s foot is within 2 px of the floor line, every stage, both beds.'),
    ('The cooler showed a debug outline and the word "Cooler" in the sprite build.',
     'Removed: the cooler is a sprite like every piece.'),
    ('The washtub (fi, 20 px) in the wash room\'s last column drew 2 px through the east wall.',
     'Moved to (21,5), inside the room.'),
    ('The barrel and sack (22 px) in the hall\'s first column drew 3 px through the bedroom partition (new pantry spot).',
     'The pantry corner starts at (9,12).'),
    ('The dresser (bought, last bedroom column) drew 1 px through the partition (the old E4 dresser too).',
     'The new dresser is 16 px wide (one plain middle column removed).'),
    ('The cooler (20 px) and the log basket (16 px) overlapped by 2 px side by side under the hall window.',
     'The log basket stands by the hearth at (15,3); the cooler has the window spot to itself.'),
    ('The armchair (21 px) overlapped the log basket and the side table beside the hearth.',
     'The armchair is 17 px (four plain middle columns removed); no overlap on the row.'),
    ('The fine washstand (19 px) overlapped the linen press by 1 px.',
     'One middle column removed (18 px).'),
    ('The firewood stack beside the hearth either overlapped its neighbours or left an unreachable pocket tile.',
     'The firewood is stacked in the pantry corner by the door, where it comes in (Restored).'),
    ('The new cooler (31 px) would have reached the hall window\'s sill.',
     'Two plain rows of its door removed (29 px, the old height).'),
    ('Oversized first candidates (36 px chairs, a 26 px side table, 28 px decor) against the 20-24 px house props.',
     'Rejected; chairs, dresser and clock trimmed in repeated parts, candle stand and decor regenerated at 16-28 px.'),
    ('The old SpriteCook side tables read as spindly dark figures; the old desk light and hall rug tiles are gone.',
     'Replaced by the round candle stand and a single rug sprite centred in RUG_RECT (it never runs under a wall).'),
]


def clipping():
    W = 1900
    lines = []
    for i, (found, fixed) in enumerate(ISSUES):
        lines.append(('%d. FOUND: %s' % (i + 1, found), INK))
        lines.append(('     FIXED: %s' % fixed, (190, 214, 160, 255)))
    d0 = ImageDraw.Draw(Image.new('RGBA', (10, 10)))
    wrapped = []
    for text, c in lines:
        words, cur = text.split(' '), ''
        for w in words:
            t = (cur + ' ' + w).strip() if cur else w
            if d0.textlength(t, font=F_H) > W - 60:
                wrapped.append((cur, c))
                cur = '        ' + w
            else:
                cur = t if cur else w
        wrapped.append((cur, c))
    H = 140 + len(wrapped) * 24 + 40
    o = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(o)
    d.text((20, 14), 'CCH-003 Phase C: clipping audit, issues found and fixed', font=F_T, fill=INK)
    d.text((20, 52), 'Audited in all four stages, with nothing bought and with everything bought, and from the camera at the door, '
           'the bed, the hearth, the dining table, the bedroom\'s west side and the study (C_cameras). tools/interior_test.gd now '
           'checks it every run: no two pieces on a row overlap, nothing draws through a side wall or partition or above its '
           'wall\'s face, every piece is solid where it stands, every candle stands on its piece, the frames are measured and '
           'pixel-clean.', font=F_S, fill=DIM)
    y = 120
    for text, c in wrapped:
        d.text((20, y), text, font=F_H, fill=c)
        y += 24
    o.save(os.path.join(REV, 'C_clipping.png'))


def halves(bdir, adir):
    for src, dst in ((bdir, 'before'), (adir, 'after')):
        out = os.path.join(ROOT, 'art/style_tests/CCH-003/C', dst)
        os.makedirs(out, exist_ok=True)
        for f in sorted(os.listdir(src)):
            if f.endswith('.png'):
                Image.open(os.path.join(src, f)).convert('RGB').resize((640, 360), Image.LANCZOS).save(os.path.join(out, f))


if __name__ == '__main__':
    bdir, adir, bjson, ajson = sys.argv[1:5]
    os.makedirs(REV, exist_ok=True)
    furniture()
    detail(bdir, adir)
    collision(bjson, ajson)
    clipping()
    halves(bdir, adir)
