"""ART-OVERHAUL-002 E3: the farm and homestead's remaining sprites.

Builds art/farm/e3/ from the PixelLab outputs kept under art/style_tests/ART-OVERHAUL-002/E3/raw/:
  house_stage_0..2.png  the P1 cabin (art/farm/concept/gen_be4b3d8247.png, 384 x 320, drawn at 1.5) edited to the
                        Decrepit, Boarded and Patched stages; alpha forced to the P1 cabin's, so the footprint, door
                        and windows stay where they are. Stage 3 (Restored) is the P1 cabin itself.
  house_stage_2_night.png  stage 2 with the P1 night sprite's lit window panes copied in (stage 0-1 windows are dark)
  ext_<id>.png          porch, second storey and cellar-room overlays: the pixels an edit of the padded P1 cabin
                        changed, cleaned up; their offsets from the cabin's top-left (cabin pixels) go in sizes.json
  <prop>.png            the decor, well, forage, happenings and night pieces: cropped to their largest shape
Binary alpha everywhere (alpha >= 128 kept). Run from the repository root:  python tools/aoh2_e3.py
"""
import json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E3/raw')
OUT = os.path.join(ROOT, 'art/farm/e3')
CABIN = os.path.join(ROOT, 'art/farm/concept/gen_be4b3d8247.png')
CABIN_NIGHT = os.path.join(ROOT, 'art/farm/concept/gen_d037a9b61e.png')
PAD = (32, 32)   # where the cabin sits in the padded canvas the extension edits were made on (448 x 400)
# Extension -> the region of the padded canvas its change is looked for in (x0, y0, x1, y1).
EXT = {'porch': (0, 150, 448, 400), 'storey': (60, 0, 400, 210), 'cellar': (0, 290, 205, 400)}
PROPS = {}   # filled in by the picks below: name -> 'key/NN'
PICKS = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E3/picks.json')


def binary(im):
    a = np.array(im.convert('RGBA'))
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    return a


def label(on):
    """8-connected components: (labels, sizes)."""
    lab = np.zeros(on.shape, int)
    sizes = [0]
    n = 0
    for y, x in zip(*np.nonzero(on)):
        if lab[y, x]:
            continue
        n += 1
        stack, size = [(y, x)], 0
        lab[y, x] = n
        while stack:
            cy, cx = stack.pop()
            size += 1
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < on.shape[0] and 0 <= nx < on.shape[1] and on[ny, nx] and not lab[ny, nx]:
                        lab[ny, nx] = n
                        stack.append((ny, nx))
        sizes.append(size)
    return lab, sizes


def crop(src):
    a = binary(Image.open(src))
    lab, sizes = label(a[..., 3] > 0)
    a[lab != int(np.argmax(sizes))] = 0
    im = Image.fromarray(a)
    return im.crop(im.getbbox())


def dilate(m, r):
    out = m.copy()
    for dy in range(-r, r + 1):
        for dx in range(-r, r + 1):
            out |= np.roll(np.roll(m, dy, 0), dx, 1)
    return out


def erode(m, r):
    return ~dilate(~m, r)


def stages(info):
    cabin = binary(Image.open(CABIN))
    night = binary(Image.open(CABIN_NIGHT))
    lit = np.abs(cabin.astype(int) - night.astype(int)).sum(-1) > 30   # the P1 cabin's lit window panes
    for s in range(3):
        a = binary(Image.open(os.path.join(RAW, 'house%d' % s, '00.png')))
        a[..., 3] = cabin[..., 3]
        a[cabin[..., 3] == 0] = 0
        Image.fromarray(a).save(os.path.join(OUT, 'house_stage_%d.png' % s))
        info['house_stage_%d' % s] = [a.shape[1], a.shape[0]]
        if s == 2:
            n = a.copy()
            n[lit] = night[lit]
            Image.fromarray(n).save(os.path.join(OUT, 'house_stage_2_night.png'))


def extensions(info):
    base = binary(Image.open(os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E3/refs/cabin_pad.png'))).astype(int)
    for ext, (x0, y0, x1, y1) in EXT.items():
        e = binary(Image.open(os.path.join(RAW, ext, '00.png'))).astype(int)
        changed = (np.abs(e - base).sum(-1) > 60) & (e[..., 3] > 0)
        box = np.zeros(changed.shape, bool)
        box[y0:y1, x0:x1] = True
        m = changed & box
        m = erode(dilate(m, 2), 2) & (e[..., 3] > 0) & box   # close the speckle into solid pieces
        lab, sizes = label(m)
        keep = np.zeros(m.shape, bool)
        for i, n in enumerate(sizes):
            if i and n >= 120:
                keep |= lab == i
        out = np.where(keep[..., None], e, 0).astype(np.uint8)
        im = Image.fromarray(out)
        bb = im.getbbox()
        im.crop(bb).save(os.path.join(OUT, 'ext_%s.png' % ext))
        info['ext_' + ext] = [bb[2] - bb[0], bb[3] - bb[1], bb[0] - PAD[0], bb[1] - PAD[1]]


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    info = {}
    stages(info)
    extensions(info)
    picks = json.load(open(PICKS)) if os.path.exists(PICKS) else {}
    for name, src in picks.items():
        im = crop(os.path.join(RAW, src + '.png'))
        im.save(os.path.join(OUT, name + '.png'))
        info[name] = list(im.size)
    json.dump(info, open(os.path.join(OUT, 'sizes.json'), 'w'), indent=1)
    print(info)
