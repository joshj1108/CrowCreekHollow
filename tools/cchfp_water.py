# CCH-CONSOLIDATED-003 Final Polish: the south-facing watering frames drew the hose's stream in the jacket's tan
# (#a27d53, #ab8456) with only a blue tip, so it read as a rope. This recolours the stream to water blues: the
# pixels of those two tans that are joined (8-neighbour, through those tans and the blue) to the stream's blue tip,
# so the jacket's own tans are untouched. Run from the project folder: python tools/cchfp_water.py
# The untouched sheet is kept in art/style_tests/CCH-003-FP/before/water_south.png and read from there.
import os
import shutil
from PIL import Image
import numpy as np
from scipy import ndimage

SHEET = "art/player/d/water_south.png"
BEFORE = "art/style_tests/CCH-003-FP/before/water_south.png"
CELL = 96
TANS = {(0xab, 0x84, 0x56): (0xb4, 0xd8, 0xec), (0xa2, 0x7d, 0x53): (0x7c, 0xb0, 0xd2)}

os.makedirs(os.path.dirname(BEFORE), exist_ok=True)
if not os.path.exists(BEFORE):
    shutil.copy(SHEET, BEFORE)
a = np.array(Image.open(BEFORE).convert("RGBA"))
changed = 0
for f in range(a.shape[1] // CELL):
    fr = a[:, f * CELL:(f + 1) * CELL]
    tan = np.zeros(fr.shape[:2], bool)
    for t in TANS:
        tan |= (fr[..., 0] == t[0]) & (fr[..., 1] == t[1]) & (fr[..., 2] == t[2]) & (fr[..., 3] > 0)
    blue = (fr[..., 3] > 0) & (fr[..., 2].astype(int) > fr[..., 0].astype(int) + 30)
    lab, _ = ndimage.label(tan | blue, structure=np.ones((3, 3)))
    stream = np.zeros_like(tan)
    for l in set(lab[blue].tolist()) - {0}:
        stream |= lab == l
    stream &= tan
    for t, w in TANS.items():
        m = stream & (fr[..., 0] == t[0]) & (fr[..., 1] == t[1]) & (fr[..., 2] == t[2])
        fr[m, :3] = w
    changed += int(stream.sum())
Image.fromarray(a).save(SHEET)
print("recoloured", changed)
