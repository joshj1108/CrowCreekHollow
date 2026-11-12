"""CCH-CONSOLIDATED-003 Phase D review sheets (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md), from the game's own sheets:
  D_farmer_old_new.png   the old SpriteCook farmer and the new PixelLab farmer standing in all four facings, at 6x
  D_strips_move.png      idle, walk, idle and walk with the lantern, per facing (west mirrors east)
  D_strips_tools.png     chop, mine, hoe, water, plant, cast (fishing holds the last frame), gather
  D_strips_combat.png    each weapon's attack and guard, and the flinch
  D_strips_old.png       every old SpriteCook sheet (BEFORE)
Frames are cropped to the part of the cell any frame of the group uses, and drawn at whole multiples.
Run from the repository root:  python tools/cch003_review_d.py
"""
import glob, os
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
D = os.path.join(ROOT, 'art/player/d')
OLD = os.path.join(ROOT, 'art/player')
OUT = os.path.join(ROOT, 'art/style_tests/CCH-003/review')
BG = (92, 104, 86, 255)
INK = (238, 232, 214)
CELL = 96


def font(size):
    for f in ('C:/Windows/Fonts/segoeui.ttf', 'C:/Windows/Fonts/arial.ttf'):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


F_T, F_L = font(26), font(16)


def wrap(d, xy, text, f, fill, width):
    """Draws text wrapped to width; returns the y under it."""
    x, y = xy
    line = ''
    for w in text.split(' '):
        t = (line + ' ' + w).strip()
        if d.textlength(t, font=f) > width and line:
            d.text((x, y), line, font=f, fill=fill)
            y += f.size + 4
            line = w
        else:
            line = t
    d.text((x, y), line, font=f, fill=fill)
    return y + f.size + 4


def frames(path, cell):
    im = Image.open(path).convert('RGBA')
    return [im.crop((i * cell, 0, (i + 1) * cell, cell)) for i in range(im.width // cell)]


def union_box(ims):
    box = None
    for im in ims:
        b = im.getbbox()
        if b:
            box = b if box is None else (min(box[0], b[0]), min(box[1], b[1]), max(box[2], b[2]), max(box[3], b[3]))
    return box


def strips(rows, title, note, out, sc=2, cell=CELL):
    """rows: [(label, path)]. One labelled row of frames per sheet, every frame cropped to the group's box."""
    allf = {lab: frames(p, cell) for lab, p in rows}
    box = union_box([f for fs in allf.values() for f in fs])
    bw, bh = (box[2] - box[0]) * sc, (box[3] - box[1]) * sc
    n = max(len(f) for f in allf.values())
    lw, gap = 210, 6
    W = max(lw + n * (bw + gap) + 10, 760)
    probe = ImageDraw.Draw(Image.new('RGBA', (8, 8)))
    top = wrap(probe, (10, wrap(probe, (10, 8), title, F_T, INK, W - 20) + 2), note, F_L, INK, W - 20) + 10
    o = Image.new('RGBA', (W, top + len(rows) * (bh + gap) + 10), BG)
    d = ImageDraw.Draw(o)
    y = wrap(d, (10, 8), title, F_T, INK, W - 20)
    wrap(d, (10, y + 2), note, F_L, (200, 196, 180), W - 20)
    for r, (lab, _) in enumerate(rows):
        y = top + r * (bh + gap)
        d.text((10, y + bh // 2 - 10), lab, font=F_L, fill=INK)
        for i, f in enumerate(allf[lab]):
            x = lw + i * (bw + gap)
            d.rectangle((x, y, x + bw - 1, y + bh - 1), fill=(84, 96, 78, 255))
            o.alpha_composite(f.crop(box).resize((bw, bh), Image.NEAREST), (x, y))
            d.text((x + 3, y + 1), str(i), font=font(11), fill=(170, 176, 160))
    o.save(os.path.join(OUT, out))
    print(out, o.size)


def old_new():
    sc = 6
    old = [Image.open(os.path.join(OLD, 'farmer_%s.png' % k)).convert('RGBA').crop((0, 0, 36, 36)) for k in ('idle', 'idle_right', 'idle_up')]
    old.append(old[1].transpose(Image.FLIP_LEFT_RIGHT))
    new = [Image.open(os.path.join(D, 'idle_%s.png' % k)).convert('RGBA').crop((0, 0, CELL, CELL)) for k in ('south', 'east', 'north')]
    new.append(new[1].transpose(Image.FLIP_LEFT_RIGHT))
    # Both drawn with their boots on one line: the old sheets' feet are on their bottom row, the new ones' on row 65.
    ob = union_box(old)
    nb = union_box(new)
    nb = (nb[0], nb[1], nb[2], 66)
    ow, oh = (ob[2] - ob[0]) * sc, (ob[3] - ob[1]) * sc
    nw, nh = (nb[2] - nb[0]) * sc, (nb[3] - nb[1]) * sc
    h = max(oh, nh)
    cw = max(ow, nw) + 24
    o = Image.new('RGBA', (240 + 4 * cw, 110 + 2 * (h + 40)), BG)
    d = ImageDraw.Draw(o)
    d.text((10, 8), 'CCH-003 Phase D: the farmer, old and new (6x)', font=F_T, fill=INK)
    wrap(d, (10, 42), 'Same scale, 16 x 32 art px. Facing down, right, up, left (left mirrors right). BEFORE: SpriteCook straw hat and overalls. AFTER: PixelLab cap, canvas jacket over flannel, belt, work jeans and boots.', F_L, (200, 196, 180), o.width - 20)
    for r, (lab, ims, b) in enumerate([('BEFORE (old)', old, ob), ('AFTER (new)', new, nb)]):
        y = 90 + r * (h + 40)
        d.text((10, y + h // 2 - 10), lab, font=F_T, fill=INK)
        for i, im in enumerate(ims):
            c = im.crop(b)
            c = c.resize((c.width * sc, c.height * sc), Image.NEAREST)
            o.alpha_composite(c, (240 + i * cw, y + h - c.height))
        d.line((240, y + h, o.width - 10, y + h), fill=(170, 80, 70), width=1)
    o.save(os.path.join(OUT, 'D_farmer_old_new.png'))
    print('D_farmer_old_new.png', o.size)


def main():
    os.makedirs(OUT, exist_ok=True)
    old_new()
    dirs = ['south', 'east', 'north']
    p = lambda k: os.path.join(D, k + '.png')
    strips([('%s %s' % (a, d), p('%s_%s' % (a, d))) for a in ('idle', 'walk', 'idle_lantern', 'walk_lantern') for d in dirs],
           'CCH-003 Phase D: idle and walk, with and without the lantern (2x)',
           'Every frame of each sheet, left to right. The lantern is in the left hand; its flame is where the light comes from.',
           'D_strips_move.png')
    strips([('%s %s' % (a, d), p('%s_%s' % (a, d))) for a in ('chop', 'mine', 'hoe', 'water', 'plant', 'cast', 'gather') for d in dirs],
           'CCH-003 Phase D: tool actions (2x)',
           'Frame 0 is the tool held ready. Chop and mine loop; fishing holds the cast\'s last frame and the game draws the line.',
           'D_strips_tools.png')
    strips([('attack %s %s' % (w, d), p('attack_%s_%s' % (w, d))) for w in ('sword', 'copper', 'knife', 'stick') for d in dirs],
           'CCH-003 Phase D: attacks (2x)',
           'The damage lands on the press and the foe flashes for 0.2 s, so the grip and wind-up play in the first third of the 0.3 s swing and the strike frame (3-6 by sheet) shows by 0.1 s; then follow-through and recovery. Copper is the iron sword recoloured.',
           'D_strips_attack.png')
    strips([('block %s %s' % (w, d), p('block_%s_%s' % (w, d))) for w in ('sword', 'copper', 'knife', 'stick') for d in dirs] +
           [('hurt %s' % d, p('hurt_%s' % d)) for d in dirs],
           'CCH-003 Phase D: guards and the flinch (2x)',
           'The guard rises in 0.1 s and holds its last frame while LT / right click is held; a blow it turns aside jolts it. The flinch plays over 0.35 s of the 0.9 s safety.',
           'D_strips_block.png')
    old = sorted(glob.glob(os.path.join(OLD, 'farmer_*_*.png'))) + [os.path.join(OLD, 'farmer_idle.png')]
    strips([(os.path.basename(f)[7:-4], f) for f in old], 'CCH-003 Phase D BEFORE: the old SpriteCook sheets (2x)',
           'Retired: no longer loaded by the game. A raised guard had no sheet and was drawn in code; there was no lantern, flinch or gather.',
           'D_strips_old.png', sc=2, cell=36)


if __name__ == '__main__':
    main()
