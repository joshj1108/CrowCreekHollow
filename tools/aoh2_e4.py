"""ART-OVERHAUL-002 E4: the farmhouse's bought furniture, replacing estate_system.gd's code-drawn pieces.

Builds art/farm/e4/ from the PixelLab picks under art/style_tests/ART-OVERHAUL-002/E4/raw/:
  dresser, armchair, bookshelf, painting  create_image_pro candidates (style image: the int_* house art). The 24/32 px
                                          pro candidates came back shifted half a cell, so reslice.py rejoined them
                                          into raw/<key>_fix/ first.
  clock                                   create_image_pro 32x48 candidate
  feather_bed                             int_beds.png's Restored bed (32x47) with its quilt recoloured to a plump
                                          cream eiderdown (no generation)
Each is cropped to its opaque box, alpha made binary (>= 128 kept). Run from the repository root:
  python tools/aoh2_e4.py
"""
import colorsys, json, os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RAW = os.path.join(ROOT, 'art/style_tests/ART-OVERHAUL-002/E4/raw')
OUT = os.path.join(ROOT, 'art/farm/e4')
PICKS = {'dresser': 'dresser24_fix/09', 'armchair': 'armchair24_fix/12', 'bookshelf': 'bookshelf2_fix/10',
         'painting': 'painting_fix/09', 'clock': 'clock/15'}


def binary(im):
    a = np.array(im.convert('RGBA'))
    a[..., 3] = np.where(a[..., 3] >= 128, 255, 0)
    a[a[..., 3] == 0] = 0
    return a


def crop(a):
    ys, xs = np.nonzero(a[..., 3])
    return a[ys.min():ys.max() + 1, xs.min():xs.max() + 1]


def feather_bed():
    a = binary(Image.open(os.path.join(ROOT, 'art/farm/int_beds.png')).crop((96, 0, 128, 47)))
    rgb = a[..., :3].astype(float) / 255
    out = a.copy()
    # Cream eiderdown ramp, dark to light, kept a little warm and muted.
    ramp = [(0x6e, 0x64, 0x58), (0x9a, 0x8e, 0x7c), (0xbf, 0xb3, 0x9c), (0xd8, 0xcd, 0xb4), (0xe6, 0xdd, 0xc6)]
    for y in range(a.shape[0]):
        for x in range(a.shape[1]):
            if a[y, x, 3] == 0:
                continue
            h, s, v = colorsys.rgb_to_hsv(*rgb[y, x])
            if (h < 0.04 or h > 0.92) and s > 0.35 and v > 0.2:   # the red quilt
                out[y, x, :3] = ramp[min(4, int(v * 5.2))]
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    sizes = {}
    for name, src in PICKS.items():
        a = crop(binary(Image.open(os.path.join(RAW, src + '.png'))))
        Image.fromarray(a).save(os.path.join(OUT, name + '.png'))
        sizes[name] = [int(a.shape[1]), int(a.shape[0])]
    a = feather_bed()
    Image.fromarray(a).save(os.path.join(OUT, 'feather_bed.png'))
    sizes['feather_bed'] = [int(a.shape[1]), int(a.shape[0])]
    json.dump(sizes, open(os.path.join(OUT, 'sizes.json'), 'w'), indent=1)
    print(sizes)


main()
