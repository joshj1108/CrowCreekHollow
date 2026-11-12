"""CCH-CONSOLIDATED-003 Phase E: the cave creatures' sprite sheets, cleaned for the game from PixelLab animations.

Reads art/style_tests/CCH-003/E/raw/anim/<name>/NN.png (animate_image jobs listed in raw/anim_jobs.json, downloaded
by raw/fetch_anims.py; 00 is the input frame, the base sprite placed at refs/base_<kind>.png) and writes
  art/farm/cave_foes/<kind>_<state>.png   one strip of 32x32 frames facing right (the bat faces the viewer).
The base sprite stands with its lowest pixel on row 30 (CaveFoeArt.FEET); frames keep PixelLab's registration, so
a lunge or a fall moves within the cell.
Cleanup per frame: alpha to 0/255; only the creature's own body is kept (the largest piece and anything touching
it), which drops the white sparkles, splashes and "!" marks some animations drew (clusters of 4+ pale pixels go
first); single bright glints become the body's dark outline tone and saturated reds (eyes, open mouths, tongues) a
dull dark red-brown, so no eye glows; body tones are lifted by LIFT so each creature reads by lantern.
Run from the repository root:  python tools/cch003_creatures.py
"""
import os
import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/CCH-003/E/raw/anim')
OUT = os.path.join(ROOT, 'art/farm/cave_foes')
CELL = 32

# state -> source animation (frames 1..n, the generated ones, unless listed)
PICKS = {
    'bat': {'idle': 'bat_idle', 'move': 'bat_move', 'alert': 'bat_alert', 'attack': 'bat_attack',
            'hurt': 'bat_hurt', 'death': 'bat_death'},
    'lizard': {'idle': 'lizard_idle', 'move': 'lizard_move', 'alert': 'lizard_alert2',
               'attack': 'lizard_attack2', 'hurt': 'lizard_hurt2', 'death': 'lizard_death'},
    'snake': {'idle': 'snake_idle', 'move': 'snake_move2', 'alert': 'snake_alert', 'attack': 'snake_attack',
              'hurt': 'snake_hurt', 'death': 'snake_death'},
}
MOUTH = (78, 44, 38)
# Value lift of the body tones (not the outline), so each reads by lantern at the ring's edge: the lizard came out
# nearly as dark as the cave floor. Hues are kept, so the colours stay muted.
LIFT = {'bat': 1.15, 'lizard': 1.4, 'snake': 1.1}


def clean(a, lift=1.0):
    a = a.copy()
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    # Effects first: clusters of 4+ bright pale pixels (sparkles, splashes, "!" marks) go entirely.
    rgb0 = a[..., :3].astype(np.int32)
    pale = (a[..., 3] > 0) & (rgb0.sum(-1) / 3 > 170) & ((rgb0.max(-1) - rgb0.min(-1)) < 90)
    plab, pn = ndimage.label(pale, structure=np.ones((3, 3)))
    for j in range(1, pn + 1):
        if (plab == j).sum() >= 4:
            a[plab == j] = 0
    m = a[..., 3] > 0
    lab, n = ndimage.label(m, structure=np.ones((3, 3)))
    if n > 1:
        sizes = ndimage.sum(m, lab, range(1, n + 1))
        k = 1 + int(np.argmax(sizes))
        keep = lab == k
        near = ndimage.binary_dilation(keep, iterations=1)
        for j in range(1, n + 1):
            if j != k and sizes[j - 1] <= 3 and (near & (lab == j)).any():
                keep |= lab == j
        m = keep
    a[~m] = 0
    rgb = a[..., :3].astype(np.int32)
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    lum = (r + g + b) / 3
    sat = rgb.max(-1) - rgb.min(-1)
    # the darkest body tone (the outline) for white glints
    body = rgb[m]
    dark = body[np.argsort(body.sum(-1))[len(body) // 20]] if len(body) else np.array([30, 26, 24])
    white = m & (lum > 160)
    a[white, :3] = dark
    red = m & (r > g + 50) & (r > b + 50)
    a[red, :3] = MOUTH
    # teal/green/blue effect pixels that touch the body (the alert icon's ring)
    cool = m & ((b > r + 40) | (g > r + 45))
    a[cool, :3] = dark
    if lift != 1.0:
        rgb = a[..., :3].astype(np.float32)
        body = m & (rgb.sum(-1) / 3 > 35)
        rgb[body] = np.clip(rgb[body] * lift, 0, 255)
        a[..., :3] = rgb.astype(np.uint8)
    return a


def main():
    os.makedirs(OUT, exist_ok=True)
    for kind, states in PICKS.items():
        for state, src in states.items():
            d = os.path.join(RAW, src)
            files = sorted(f for f in os.listdir(d) if f.endswith('.png'))[1:]
            strip = np.zeros((CELL, CELL * len(files), 4), np.uint8)
            for i, f in enumerate(files):
                a = np.array(Image.open(os.path.join(d, f)).convert('RGBA'))
                strip[:, i * CELL:(i + 1) * CELL] = clean(a, LIFT[kind])
            Image.fromarray(strip).save(os.path.join(OUT, '%s_%s.png' % (kind, state)))
            print('%s_%s %d frames' % (kind, state, len(files)))


if __name__ == '__main__':
    main()
