"""CCH-CONSOLIDATED-003 Phase E review sheets (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md):
  E_old_new.png    each creature: the old SpriteCook frames and the new PixelLab idle, at native size, at the game's
                   3x and at 6x, on cave-dark ground
  E_strips.png     every new state (idle, move, alert, attack, hurt, death) of each creature, every frame at 4x, and
                   the same row at native size
  E_scenes.png     in-game BEFORE / AFTER (tools/cch003_shots_e.sh): no lantern, basic, tier 2 and upgraded lantern,
                   and the exit's daylight at noon without and with the basic lantern
  E_states.png     in-game AFTER, upgraded lantern: each state (one-shots at their mid-point), the end of the fall,
                   facing left, and BEFORE's two states
Run from the repository root after the shots:  python tools/cch003_review_e.py
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NEW = os.path.join(ROOT, 'art/farm/cave_foes')
OLD = os.path.join(ROOT, 'art/farm')
SHOTS = os.path.join(ROOT, 'art/style_tests/CCH-003/E/shots')
OUT = os.path.join(ROOT, 'art/style_tests/CCH-003/review')
BG = (34, 32, 30, 255)
FLOOR = (78, 70, 60, 255)
INK = (238, 232, 214)
DIM = (170, 162, 146)
KINDS = ['bat', 'lizard', 'snake']
STATES = ['idle', 'move', 'alert', 'attack', 'hurt', 'death']


def font(size):
    for f in ('C:/Windows/Fonts/segoeui.ttf', 'C:/Windows/Fonts/arial.ttf'):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


F_T, F_L, F_S = font(26), font(17), font(14)


def frames(path, cell):
    im = Image.open(path).convert('RGBA')
    return [im.crop((i * cell, 0, (i + 1) * cell, cell)) for i in range(im.width // cell)]


def union_box(ims):
    boxes = [i.getbbox() for i in ims if i.getbbox()]
    return (min(b[0] for b in boxes), min(b[1] for b in boxes), max(b[2] for b in boxes), max(b[3] for b in boxes))


def up(im, s):
    return im.resize((im.width * s, im.height * s), Image.NEAREST)


def header(d, w, title, note):
    d.text((16, 10), title, font=F_T, fill=INK)
    d.text((16, 46), note, font=F_S, fill=DIM)


def old_new():
    rows = []
    for k in KINDS:
        old = frames(os.path.join(OLD, 'foe_%s.png' % k), 20)
        new = frames(os.path.join(NEW, '%s_idle.png' % k), 32)[0]
        ob = union_box(old)
        nb = new.getbbox()
        rows.append((k, [o.crop(ob) for o in old], new.crop(nb)))
    W, y0 = 1500, 80
    rh = 6 * 22 + 60
    sheet = Image.new('RGBA', (W, y0 + rh * len(rows)), BG)
    d = ImageDraw.Draw(sheet)
    header(d, W, 'CCH-003 Phase E: cave creatures, old vs new',
           'Left: old SpriteCook sheet (4 frames: the only states were still and moving). Right: new PixelLab idle. '
           'Each shown at native size, at the game\'s 3x and at 6x. Same cave-floor ground.')
    for r, (k, old, new) in enumerate(rows):
        y = y0 + r * rh
        d.text((16, y + 4), k, font=F_L, fill=INK)
        x = 90
        d.text((x, y + 4), 'OLD', font=F_S, fill=DIM)
        for o in old:
            sheet.paste(FLOOR, (x, y + 26, x + o.width * 6 + 8, y + 26 + o.height * 6 + 8))
            sheet.alpha_composite(up(o, 6), (x + 4, y + 30))
            x += o.width * 6 + 16
        sheet.alpha_composite(old[0], (x, y + 30))
        sheet.alpha_composite(up(old[0], 3), (x + 30, y + 30))
        x += 30 + old[0].width * 3 + 50
        d.text((x, y + 4), 'NEW', font=F_S, fill=DIM)
        sheet.paste(FLOOR, (x, y + 26, x + new.width * 6 + 8, y + 26 + new.height * 6 + 8))
        sheet.alpha_composite(up(new, 6), (x + 4, y + 30))
        x += new.width * 6 + 24
        sheet.alpha_composite(new, (x, y + 30))
        sheet.alpha_composite(up(new, 3), (x + 30, y + 30))
        d.text((x, y + 30 + new.height * 3 + 10), '%dx%d px (old %dx%d)' % (new.width, new.height, old[0].width, old[0].height), font=F_S, fill=DIM)
    sheet.save(os.path.join(OUT, 'E_old_new.png'))


def strips():
    sc = 4
    blocks = []
    for k in KINDS:
        allf = [f for s in STATES for f in frames(os.path.join(NEW, '%s_%s.png' % (k, s)), 32)]
        box = union_box(allf)
        blocks.append((k, box, {s: [f.crop(box) for f in frames(os.path.join(NEW, '%s_%s.png' % (k, s)), 32)] for s in STATES}))
    rowh = {k: (b[3] - b[1]) * sc + 14 for k, b, _ in blocks}
    W = 140 + 6 * ((max(b[2] - b[0] for _, b, _ in blocks)) * sc + 8) + 200
    H = 80 + sum(rowh[k] * len(STATES) + 40 for k in KINDS)
    sheet = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(sheet)
    header(d, W, 'CCH-003 Phase E: every state, every frame (4x; native size at the right)',
           'Facing right; the lizard and snake mirror to face left, the bat faces the viewer. Frames keep their '
           'place in the cell, so a lunge or a fall moves. Loops: idle 5 fps, move 10 fps.')
    y = 80
    for k, box, st in blocks:
        d.text((16, y), k, font=F_T, fill=INK)
        y += 36
        for s in STATES:
            d.text((16, y + 8), s, font=F_L, fill=DIM)
            x = 140
            for f in st[s]:
                sheet.paste(FLOOR, (x - 2, y - 2, x + f.width * sc + 2, y + f.height * sc + 2))
                sheet.alpha_composite(up(f, sc), (x, y))
                x += f.width * sc + 8
            x = W - 190
            for f in st[s]:
                sheet.alpha_composite(f, (x, y + 8))
                x += f.width + 2
            y += rowh[k]
        y += 4
    sheet.save(os.path.join(OUT, 'E_strips.png'))


def grid(out, title, note, rows, cols=('BEFORE', 'AFTER')):
    """rows: [(label, [file or None per column])]"""
    ims = [[Image.open(os.path.join(SHOTS, f + '.png')).convert('RGBA') if f else None for f in fs] for _, fs in rows]
    w = max(i.width for r in ims for i in r if i)
    h = max(i.height for r in ims for i in r if i)
    W = 260 + len(cols) * (w + 12)
    H = 100 + len(rows) * (h + 12)
    sheet = Image.new('RGBA', (W, H), BG)
    d = ImageDraw.Draw(sheet)
    header(d, W, title, note)
    for c, name in enumerate(cols):
        d.text((260 + c * (w + 12), 74), name, font=F_L, fill=INK)
    for r, ((label, _), row) in enumerate(zip(rows, ims)):
        y = 100 + r * (h + 12)
        yy = y + 8
        for line in label.split('\n'):
            d.text((16, yy), line, font=F_L if yy == y + 8 else F_S, fill=INK if yy == y + 8 else DIM)
            yy += 24
        for c, im in enumerate(row):
            if im:
                sheet.alpha_composite(im, (260 + c * (w + 12), y))
    sheet.save(os.path.join(OUT, out))


def main():
    os.makedirs(OUT, exist_ok=True)
    old_new()
    strips()
    grid('E_scenes.png', 'CCH-003 Phase E: readability in the cave (in-game, full size)',
         'Bat, lizard, snake idle in a row right of the farmer (1.4 tiles apart), cave day 1. BEFORE draws the old sheets.',
         [('No lantern\npitch black, as before', ['before_lantern0', 'after_lantern0']),
          ('Basic lantern (tier 1)', ['before_lantern1', 'after_lantern1']),
          ('Lantern tier 2', ['before_lantern2', 'after_lantern2']),
          ('Upgraded lantern (tier 3)', ['before_lantern3', 'after_lantern3']),
          ('Cave light: noon at the exit\nno lantern', ['before_exit_l0', 'after_exit_l0']),
          ('Cave light: noon at the exit\nbasic lantern', ['before_exit_l1', 'after_exit_l1'])])
    grid('E_states.png', 'CCH-003 Phase E: each state in the cave (in-game, upgraded lantern)',
         'One-shots at their mid-point. Hurt keeps the old pale hit flash (the only sign of damage, per DESIGN.md).',
         [('Idle', [None, 'after_state_idle']),
          ('Move', ['before_state_move', 'after_state_move']),
          ('Alert (on noticing you)', [None, 'after_state_alert']),
          ('Attack (the contact blow)', [None, 'after_state_attack']),
          ('Hurt (hit flash)', ['before_state_hurt', 'after_state_hurt']),
          ('Death (the fall)\nBEFORE: vanished at once', [None, 'after_state_death']),
          ('Death, end of the fall', [None, 'after_state_death_end']),
          ('Facing left (move)', [None, 'after_state_left'])])
    print('ok')


if __name__ == '__main__':
    main()
