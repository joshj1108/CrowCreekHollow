"""B2: hand-drawn hanging roots over the mouth (PixelLab's two root inpaints still came out as an even curtain).
Clears the old roots under the brow (x 86-139, y 25-37) to the opening's dark, then draws eleven roots with
varied lengths, spacing, curvature and thickness in the colours the old roots used.
  python roots.py raw/cliff_r1_jamb.png raw/cliff_b2.png"""
import sys
import numpy as np
from PIL import Image
im = np.array(Image.open(sys.argv[1]).convert('RGBA'))
f = im[..., :3].astype(float)
L = 0.3 * f[..., 0] + 0.55 * f[..., 1] + 0.15 * f[..., 2]
X0, X1, Y0, Y1 = 86, 140, 25, 38
box = (slice(Y0, Y1), slice(X0, X1))
# the old roots' colours: the lit pixels in the box, darkest to lightest
lit = f[box][L[box] >= 32]
lit = lit[np.argsort(0.3 * lit[:, 0] + 0.55 * lit[:, 1] + 0.15 * lit[:, 2])]
DARK, MID, HI = (tuple(int(v) for v in lit[int(q * (len(lit) - 1))]) for q in (0.15, 0.5, 0.88))
GAP = (20, 17, 20)
sub = im[box]
sub[(L[box] >= 20) & (sub[..., 3] == 255)] = (*GAP, 255)
# (x, length, thickness, drift at the tip, kink row or -1): irregular gaps, stubs and two long ones
ROOTS = [(87, 5, 1, 0, -1), (90, 12, 2, 2, 7), (95, 3, 1, 0, -1), (99, 8, 1, -1, 4), (104, 18, 2, -2, 10),
         (110, 4, 1, 1, -1), (117, 10, 1, 2, 6), (121, 2, 1, 0, -1), (126, 15, 2, 1, 9), (131, 6, 1, -1, -1),
         (136, 9, 1, -1, 5)]
top = np.full(im.shape[1], Y0)
for x in range(X0, X1):                  # each root hangs from the brow's lowest lit pixel above the box
    y = Y0 - 1
    while y > Y0 - 6 and L[y, x] < 32:
        y -= 1
    top[x] = y + 1
for x0, n, t, drift, kink in ROOTS:
    for i in range(n):
        u = i / max(n - 1, 1)
        x = x0 + int(round(drift * u * u)) + (1 if kink >= 0 and i >= kink else 0) * np.sign(drift or 1)
        y = top[x0] + i
        thick = t == 2 and u < 0.6
        tip = i >= n - 2
        im[y, x] = (*(DARK if tip else MID), 255)
        if thick:
            im[y, x + 1] = (*DARK, 255)
            im[y, x] = (*HI, 255)
    if n >= 12:                          # a rootlet off each long root
        y = top[x0] + n // 2
        im[y, x0 - 1] = (*DARK, 255); im[y + 1, x0 - 2] = (*DARK, 255)
Image.fromarray(im).save(sys.argv[2])
print('colours', DARK, MID, HI)
