"""CCH-CONSOLIDATED-003 Phase F: the final package's contact sheets (AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md).
Each sheet is a column of rows, one scene per row, BEFORE (the commit before Phase A, b1e8235) beside AFTER (the
final build), with a caption naming the scene and its capture options. Rows with only an AFTER image (things BEFORE
didn't have, e.g. the debug panel's overrides) show it alone. Frame grids from tools/review_motion.ps1 are added
as single images.
Run from the repository root after tools/cch003_shots_f.sh has filled both shot folders:
  python tools/cch003_review_f.py <before shots dir> <after shots dir>
Writes art/style_tests/CCH-003/review/F_sheet_<name>.png.
"""
import os
import sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'art/style_tests/CCH-003/review')
BG = (40, 37, 34)
INK = (238, 232, 214)
DIM = (170, 162, 146)
TAG_B = (150, 110, 90)
TAG_A = (110, 150, 100)


def font(size):
    for f in ('C:/Windows/Fonts/segoeui.ttf', 'C:/Windows/Fonts/arial.ttf'):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


F_T, F_L, F_S = font(26), font(18), font(14)

# sheet name -> (title, note, [(shot, caption, before?)])
SHEETS = {
    'hud': ('1  HUD: survival bars without numbers', 'Full size, the HUD strip along the top (x 0-1040). BEFORE b1e8235, AFTER final build.', [
        ('hud_day', 'Farm, 12:00, sunny: every need full', True),
        ('hud_low', 'Low health, hunger, thirst and warmth (hp=3 food=12 water=10 warmth=20): warnings, no numbers', True),
        ('hud_trek', 'Rookery Wood trek, clearing 1: the Nerve bar', True),
    ]),
    'mailbox': ('2  The outdoor mailbox and the farmhouse entrance', 'Half size; mailbox crops full size.', [
        ('entrance_day', 'Entrance, 12:00, sunny (a new game starts at the door)', True),
        ('entrance_dusk', 'Entrance, 19:30, basic lantern', True),
        ('entrance_night', 'Entrance, 21:30, cloudy, lantern tier 2', True),
        ('mailbox_day', 'Mailbox by the east gate, one unread letter (flag up), 12:00 (BEFORE: no mailbox)', True),
        ('mailbox_open', 'Checking it: the door open, the Mailbox panel', False),
        ('mailbox_snow', 'Winter snow, flag up', False),
    ]),
    'furniture': ('3  Furniture family (restored house, everything bought)', 'Full-size crops; BEFORE has the old furniture.', [
        ('int_bed', 'Bedroom: bed against the north wall, bedside cabinet, chest, reading stand (12:00)', True),
        ('int_desk', 'Study corner and desk at 21:30: no red light on the desk', True),
        ('int_s3_estate', 'Whole house, 12:00, every piece bought, the clock', True),
    ]),
    'stages': ('4  Layout and restoration: the four house stages', 'Half size, 12:00 sunny; fire lit from stage 2.', [
        ('int_s0', 'Stage 0 decrepit', True),
        ('int_s1', 'Stage 1 boarded', True),
        ('int_s2', 'Stage 2 patched, fire lit', True),
        ('int_s3', 'Stage 3 restored, fire lit', True),
        ('int_s3_night', 'Restored at 21:30: all candles, the fire, everything bought', True),
        ('int_s0_night', 'Decrepit at 21:30, basic lantern', True),
    ]),
    'farmer': ('6  The farmer, everywhere he goes', 'Full-size crops around the farmer.', [
        ('farmer_day', 'Farm, 12:00, facing down', True),
        ('farmer_night', 'Farm, 21:30, lantern tier 2 in hand', True),
        ('farmer_inside', 'Restored house at night, lantern in hand', True),
        ('farmer_cave', 'Cave, upgraded lantern', True),
    ]),
    'combat': ('8  Combat and 9 cave creatures in the game', 'Full-size crops; the farmer holds the iron sword. BEFORE: the old farmer and creatures.', [
        ('combat_cave', 'Bat, lizard, snake striking (attack, mid-point), upgraded lantern', True),
        ('combat_hurt', 'Hurt flinch inside the hit flash', True),
        ('creatures_l1', 'Idle by the basic lantern', True),
        ('creatures_exit', 'Idle in the exit\'s noon daylight, basic lantern', True),
    ]),
    'debug': ('10  Developer world-state panel (debug builds only)', 'Half size. BEFORE had no panel.', [
        ('debug_panel', 'Panel open, 12:00 sunny: time, date, season, weather, temperature, pause', False),
        ('debug_snow', 'Forced snow and 20 F: badge "DEBUG OVERRIDES", the world follows', False),
    ]),
    'consistency': ('11  Final consistency', 'Half size. BEFORE b1e8235, AFTER final build.', [
        ('farm_day', 'Farm, 12:00, sunny', True),
        ('farm_night', 'Farm, 21:30, cloudy, lantern tier 2', True),
        ('cave_explore', 'Cave exploration, upgraded lantern', True),
        ('window_winter', 'Restored house, winter snow at the windows', True),
        ('window_autumn', 'Restored house, autumn rain, 17:00', True),
    ]),
    'seasons': ('11  Final consistency: the four seasons', 'Half size, the farm at 12:00. BEFORE b1e8235, AFTER final build.', [
        ('season_spring', 'Spring, 12:00', True),
        ('season_summer', 'Summer, 12:00', True),
        ('season_autumn', 'Autumn, 12:00, rain', True),
        ('season_winter', 'Winter, 12:00, snow', True),
    ]),
}


def load(d, name):
    p = os.path.join(d, name + '.png')
    return Image.open(p).convert('RGB') if os.path.exists(p) else None


CROPS = {'hud': (0, 0, 1040, 104)}


def build(key, before_dir, after_dir):
    title, note, rows = SHEETS[key]
    box = CROPS.get(key)
    pad, cap_h = 16, 30
    imgs = []
    for shot, cap, with_before in rows:
        a = load(after_dir, shot)
        b = load(before_dir, shot) if with_before else None
        if box and a is not None:
            a = a.crop(box)
            b = b.crop(box) if b is not None else None
        if a is None:
            print('missing AFTER', shot)
            continue
        imgs.append((cap, b, a))
    w_img = max(a.width for _, _, a in imgs)
    two = any(b is not None for _, b, _ in imgs)
    w = pad * 3 + w_img * 2 if two else pad * 2 + w_img
    h = 80 + sum(cap_h + max(a.height, b.height if b else 0) + pad for _, b, a in imgs)
    sheet = Image.new('RGB', (w, h), BG)
    d = ImageDraw.Draw(sheet)
    d.text((pad, 10), 'CCH-CONSOLIDATED-003 Phase F  ' + title, font=F_T, fill=INK)
    d.text((pad, 46), note, font=F_S, fill=DIM)
    y = 80
    for cap, b, a in imgs:
        d.text((pad, y + 4), cap, font=F_L, fill=INK)
        y += cap_h
        if b is not None:
            sheet.paste(b, (pad, y))
            d.rectangle((pad, y, pad + 74, y + 20), fill=TAG_B)
            d.text((pad + 6, y + 1), 'BEFORE', font=F_S, fill=INK)
        xa = pad * 2 + w_img if two else pad
        sheet.paste(a, (xa, y))
        d.rectangle((xa, y, xa + 62, y + 20), fill=TAG_A)
        d.text((xa + 6, y + 1), 'AFTER', font=F_S, fill=INK)
        y += max(a.height, b.height if b else 0) + pad
    path = os.path.join(OUT, 'F_sheet_%s.png' % key)
    sheet.save(path)
    print('wrote', path, sheet.size)


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for k in (sys.argv[3:] or SHEETS):
        build(k, sys.argv[1], sys.argv[2])
