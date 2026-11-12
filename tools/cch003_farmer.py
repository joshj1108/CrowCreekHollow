"""CCH-CONSOLIDATED-003 Phase D: the farmer's sprite sheets, cleaned for the game from the PixelLab character.

Reads art/style_tests/CCH-003/D/raw/group/ (the PixelLab character group 345e6050..., downloaded by raw/pull.py: one
state per held thing, each with its animations; ids and prompts in pixellab-assets.json) and writes:
  art/player/d/<anim>_<south|east|north>.png   one strip per animation and facing, CELL x CELL frames, the feet's
                                               bottom row on row FEET of every cell, the body centred on column CELL/2.
                                               West mirrors east in the game.
  art/player/d/lantern.png                     the lantern on its own, cut from the Lantern state, hung on the belt.
  scripts/farmer_frames.gd                     frame counts, the lantern's centre in every carrying frame, how far the
                                               belt drops in every action frame, and the rod's tip at the end of a cast.
Cleanup: alpha to 0/255; the teal patch the side views put on the jacket's pocket is painted jacket tan; the white
motion-smear arcs some swings drew are taken out; specks of a few pixels away from the figure are dropped.
The copper sword is the iron sword's frames with the blade's greys mapped onto a copper ramp.
Run from the repository root:  python tools/cch003_farmer.py
"""
import json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/CCH-003/D/raw/group')
OUT = os.path.join(ROOT, 'art/player/d')
GD = os.path.join(ROOT, 'scripts/farmer_frames.gd')
CELL = 96
FEET = 65          # the row the base figure's lowest boot pixel sits on, in every cell
DIRS = ['south', 'east', 'north']

# Animation -> per facing (state folder, animation folder[, frames to keep]). A missing facing falls back to the
# first source listed. "smear": take out white motion-smear arcs (and the cast's drawn line, which the game draws);
# "spray": the hose's white water becomes water blue; "spark": hit sparks are taken out. picks.json overrides a facing's source and frames.
ANIMS = {
    'idle': {'*': ('Idle', 'idle')},
    'walk': {'*': ('Idle', 'walk')},
    'idle_lantern': {'*': ('Lantern', 'idle_lantern')},
    'walk_lantern': {'*': ('Lantern', 'walk_lantern_v3')},
    'chop': {'*': ('Axe', 'chop')},
    'mine': {'*': ('Pickaxe', 'mine'), 'smear': True},
    'hoe': {'*': ('Hoe', 'hoe')},
    'water': {'*': ('Hose', 'water'), 'spray': True},
    'plant': {'*': ('Trowel', 'plant')},
    'cast': {'*': ('Rod', 'cast'), 'smear': True},
    'hurt': {'*': ('Idle', 'hurt2'), 'smear': True, 'spark': True},
    'gather': {'*': ('Idle', 'gather2')},
    'attack_sword': {'*': ('Iron_sword', 'attack'), 'spark': True},
    'attack_knife': {'*': ('Knife', 'attack'), 'spark': True},
    'attack_stick': {'*': ('Stick', 'attack'), 'smear': True, 'spark': True},
    'block_sword': {'*': ('Iron_sword', 'block')},
    'block_knife': {'*': ('Knife', 'block')},
    'block_stick': {'*': ('Stick', 'block')},
}
OVERRIDES = os.path.join(ROOT, 'art/style_tests/CCH-003/D/picks.json')   # per anim/facing source and frame picks
COPPER_FROM = {'attack_copper': 'attack_sword', 'block_copper': 'block_sword'}


def load(p):
    a = np.array(Image.open(p).convert('RGBA')).astype(np.int32)
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    return a


def components(mask):
    h, w = mask.shape
    lab = np.zeros((h, w), np.int32)
    comps = []
    for y in range(h):
        for x in range(w):
            if mask[y, x] and not lab[y, x]:
                n = len(comps) + 1
                stack, comp = [(y, x)], []
                lab[y, x] = n
                while stack:
                    cy, cx = stack.pop()
                    comp.append((cy, cx))
                    for dy in (-1, 0, 1):
                        for dx in (-1, 0, 1):
                            ny, nx = cy + dy, cx + dx
                            if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not lab[ny, nx]:
                                lab[ny, nx] = n
                                stack.append((ny, nx))
                comps.append(comp)
    return comps


def clean(a, smear=False, spray=False, spark=False):
    a = a.copy()
    if spark:
        # Hit sparks some strikes drew: bright yellow-orange (no weapon or clothing is that colour).
        r, g, b = a[..., 0], a[..., 1], a[..., 2]
        a[(a[..., 3] > 0) & (r > 200) & (g > 130) & (b < 90)] = 0
        # and cyan-white impact flashes
        a[(a[..., 3] > 0) & (b > 200) & (g > 180) & (r < 190)] = 0
    r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3] > 0
    # The pocket patch: teal, and the off-white pixel beside it.
    teal = al & (g > r + 15) & (b > r + 15) & (g + b > 220)
    if teal.any():
        ys, xs = np.nonzero(teal)
        for y, x in zip(ys, xs):
            a[y, x, :3] = (162, 125, 83)
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < a.shape[0] and 0 <= xx < a.shape[1] and a[yy, xx, 3] and a[yy, xx, :3].min() > 190:
                        a[yy, xx, :3] = (171, 132, 86)
    if smear:
        white = (a[..., 3] > 0) & (a[..., :3].min(axis=2) > 240)
        a[white] = 0
    if spray:
        # The hose's water, drawn white: a pale water blue.
        white = (a[..., 3] > 0) & (a[..., :3].min(axis=2) > 240)
        a[white, :3] = (150, 200, 228)
    # Specks away from the figure (dust, broken smear ends): components under 4 pixels.
    comps = components(a[..., 3] > 0)
    if comps:
        big = max(len(c) for c in comps)
        for c in comps:
            if len(c) < 4 and len(c) < big:
                for y, x in c:
                    a[y, x] = 0
    return a


def place(a, off):
    """Put a source canvas into a CELL x CELL cell at offset (x, y)."""
    out = np.zeros((CELL, CELL, 4), np.int32)
    h, w = a.shape[:2]
    for y in range(h):
        ty = y + off[1]
        if 0 <= ty < CELL:
            xs0, xs1 = max(0, -off[0]), min(w, CELL - off[0])
            if xs1 > xs0:
                out[ty, xs0 + off[0]:xs1 + off[0]] = a[y, xs0:xs1]
    return out


def base_shift():
    """Per facing, the vertical shift that puts the base figure's boots on FEET."""
    s = {}
    for d in DIRS:
        a = load(os.path.join(RAW, 'Idle/rotations/%s.png' % d))
        bottom = np.nonzero(a[..., 3])[0].max() + (CELL - a.shape[0]) // 2
        s[d] = FEET - bottom
    return s


def frame_offset(state, d, frame0, shift, frames=None):
    """Where a source canvas goes in the cell. The canvas is centred on the state's canvas; when frame 0 is the
    state's rotation, its exact position is found by matching."""
    rot = load(os.path.join(RAW, '%s/rotations/%s.png' % (state, d)))
    rot_off = ((CELL - rot.shape[1]) // 2, (CELL - rot.shape[0]) // 2 + shift)
    w, h = frame0.shape[1], frame0.shape[0]
    guess = ((CELL - w) // 2, (CELL - h) // 2 + shift)
    target = place(rot, rot_off)
    best, best_err = guess, None
    for dy in range(-6, 7):
        for dx in range(-6, 7):
            off = (guess[0] + dx, guess[1] + dy)
            err = np.abs(place(frame0, off)[..., 3] - target[..., 3]).sum()
            if best_err is None or err < best_err:
                best, best_err = off, err
    total = target[..., 3].sum()
    if best_err is not None and best_err < total * 0.08:
        return best
    # Not the rotation itself (a template clip, or a clip without its first frame): put the boots where the rotation's
    # are (the median over the frames, so a stride doesn't lift the figure), and centre the legs on its legs.
    def legs(img, off):
        c = place(img, off)
        ys, xs = np.nonzero(c[..., 3])
        bottom = ys.max()
        low = ys >= bottom - 6
        return bottom, xs[low].mean()
    tb, tx = legs(rot, rot_off)
    found = [legs(f, guess) for f in (frames or [frame0])]
    fb = int(np.median([f[0] for f in found]))
    fx = float(np.median([f[1] for f in found]))
    return (guess[0] + int(round(tx - fx)), guess[1] + int(tb - fb))


def is_cap(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (a[..., 3] > 0) & (np.abs(r - g) < 14) & (g - b > 16) & (g > 50) & (g < 140)


def head_top(a):
    ys = np.nonzero(is_cap(a))[0]
    return int(ys.min()) if len(ys) else None


def lantern_centre(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    y = (a[..., 3] > 0) & (r > 190) & (g > 150) & (b < 130) & (g - b > 60)
    comps = components(y)
    if not comps:
        return None
    c = max(comps, key=len)
    if len(c) < 2:
        return None
    ys, xs = zip(*c)
    return [round(float(np.mean(xs)) + 0.5, 1), round(float(np.mean(ys)) + 0.5, 1)]


def copper(a):
    a = a.copy()
    rgb = a[..., :3]
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    lum = rgb.mean(axis=2)
    grey = (a[..., 3] > 0) & (sat < 24) & (lum > 95)
    ramp = np.array([(110, 54, 30), (172, 94, 52), (218, 134, 78), (246, 192, 138)], float)
    for c in components(grey):
        if len(c) < 5:
            continue
        for y, x in c:
            t = np.clip((lum[y, x] - 95) / 140.0, 0, 1) * 3
            i = min(int(t), 2)
            col = ramp[i] + (ramp[i + 1] - ramp[i]) * (t - i)
            a[y, x, :3] = col.astype(np.int32)
    return a


def frames_of(state, anim, d):
    folder = os.path.join(RAW, state, 'animations', anim, d)
    if not os.path.isdir(folder):
        return None
    return [os.path.join(folder, f) for f in sorted(os.listdir(folder)) if f.endswith('.png')]


def main():
    os.makedirs(OUT, exist_ok=True)
    picks = json.load(open(OVERRIDES, encoding='utf-8')) if os.path.exists(OVERRIDES) else {}
    shift = base_shift()
    counts, lanterns, belt, ref_head = {}, {}, {}, {}
    sheets = {}
    for d in DIRS:
        base = load(os.path.join(RAW, 'Idle/rotations/%s.png' % d))
        ref_head[d] = head_top(place(base, ((CELL - base.shape[1]) // 2, (CELL - base.shape[0]) // 2 + shift[d])))
    for key, spec in ANIMS.items():
        for d in DIRS:
            src = picks.get('%s_%s' % (key, d)) or spec.get(d) or spec['*']
            state, anim = src[0], src[1]
            files = frames_of(state, anim, d)
            if not files:
                print('missing', key, d, state, anim)
                continue
            keep = src[2] if len(src) > 2 and src[2] is not None else list(range(len(files)))
            raw = [load(files[i]) for i in keep]
            off = frame_offset(state, d, load(files[0]), shift[d], raw)
            if len(src) > 3:
                off = (off[0], off[1] + int(src[3]))   # a picks.json nudge, in art pixels
            cells = [place(clean(f, spec.get('smear', False), spec.get('spray', False), spec.get('spark', False)), off) for f in raw]
            sheets['%s_%s' % (key, d)] = cells
    for key, src in COPPER_FROM.items():
        for d in DIRS:
            k = '%s_%s' % (src, d)
            if k in sheets:
                sheets['%s_%s' % (key, d)] = [copper(c) for c in sheets[k]]
    for k, cells in sheets.items():
        strip = np.concatenate(cells, axis=1).astype(np.uint8)
        Image.fromarray(strip, 'RGBA').save(os.path.join(OUT, k + '.png'))
        counts[k] = len(cells)
        d = k.rsplit('_', 1)[1]
        if 'lantern' in k:
            pts, last = [], None
            for c in cells:
                p = lantern_centre(c) or last
                pts.append(p)
                last = p
            first = next((p for p in pts if p), [CELL / 2, FEET - 6])
            lanterns[k] = [p or first for p in pts]
        drops = []
        for c in cells:
            t = head_top(c)
            drops.append(0 if t is None or ref_head[d] is None else max(0, round((t - ref_head[d]) * 0.6)))
        belt[k] = drops
    # The lantern on its own: the lit cluster in the Lantern state's south rotation and the frame round it.
    rot = load(os.path.join(RAW, 'Lantern/rotations/south.png'))
    rot = place(rot, ((CELL - rot.shape[1]) // 2, (CELL - rot.shape[0]) // 2 + shift['south']))
    cx, cy = lantern_centre(rot)
    x0, y0 = int(cx) - 3, int(cy) - 6
    box = rot[y0:y0 + 9, x0:x0 + 7].copy()
    keep = np.zeros(box.shape[:2], bool)
    for comp in components(box[..., 3] > 0):
        if any(abs(x - (cx - x0)) <= 3 and abs(y - (cy - y0)) <= 3 for y, x in comp):
            for y, x in comp:
                keep[y, x] = True
    box[~keep] = 0
    Image.fromarray(box.astype(np.uint8), 'RGBA').save(os.path.join(OUT, 'lantern.png'))
    lamp_centre = [round(cx - x0, 1), round(cy - y0, 1)]
    # The rod's tip at the end of the cast: the opaque pixel farthest from the shoulders, per facing.
    rod = {}
    for d in DIRS:
        k = 'cast_%s' % d
        if k in sheets:
            c = sheets[k][-1]
            ys, xs = np.nonzero(c[..., 3])
            dist = (xs - CELL / 2) ** 2 + (ys - (FEET - 20)) ** 2
            i = int(np.argmax(dist))
            rod[d] = [int(xs[i]) + 0.5, int(ys[i]) + 0.5]
    write_gd(counts, lanterns, belt, rod, lamp_centre, box.shape)
    print('wrote', len(sheets), 'sheets')


def vec(p):
    return 'Vector2(%s, %s)' % (p[0], p[1])


def write_gd(counts, lanterns, belt, rod, lamp_centre, lamp_shape):
    L = ['class_name FarmerFrames',
         '',
         '## Made by tools/cch003_farmer.py (CCH-CONSOLIDATED-003 Phase D); do not edit by hand.',
         '## The farmer\'s sheets in art/player/d/: CELL x CELL frames in a row, the boots\' lowest row on FEET.',
         '## Positions are art pixels from a cell\'s top-left corner.',
         '',
         'const CELL := %d' % CELL,
         'const FEET := %d' % FEET,
         '',
         '# Frames in each sheet.',
         'const FRAMES := {']
    for k in sorted(counts):
        L.append('\t"%s": %d,' % (k, counts[k]))
    L += ['}', '', '# The lantern\'s flame in every frame of the carrying sheets (it swings with the walk).', 'const LANTERN := {']
    for k in sorted(lanterns):
        L.append('\t"%s": [%s],' % (k, ', '.join(vec(p) for p in lanterns[k])))
    L += ['}', '', '# How far the belt drops below the standing belt in each frame (a crouch or a lean), in art pixels.', 'const BELT_DROP := {']
    for k in sorted(belt):
        L.append('\t"%s": [%s],' % (k, ', '.join(str(v) for v in belt[k])))
    L += ['}', '', '# The rod\'s tip in the last frame of the cast, where the line starts while waiting for a bite.', 'const ROD_TIP := {']
    for d in sorted(rod):
        L.append('\t"%s": %s,' % (d, vec(rod[d])))
    L += ['}', '', '# lantern.png: its size and the flame\'s centre in it.',
          'const LAMP_SIZE := Vector2(%d, %d)' % (lamp_shape[1], lamp_shape[0]),
          'const LAMP_FLAME := %s' % vec(lamp_centre), '']
    with open(GD, 'w', encoding='utf-8', newline='') as f:
        f.write('\n'.join(L))


if __name__ == '__main__':
    main()
