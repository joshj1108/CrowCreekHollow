# ART-003 W-3 (non-production): the crown mask for oak_d's canopy inpaint. White = regenerate, black = keep.
# Kept: everything from row CUT down (trunk, roots, stones), and the major limbs above it: brown (non-leaf) pixels
# that survive an erosion of radius 2, grown back by 3 so their outlines come through too. Thin twigs and the leaf
# clumps are regenerated, as is the empty canvas above and beside the crown, so the canopy can fill out.
import sys
import numpy as np
from PIL import Image
from scipy import ndimage as nd

src, out, preview = sys.argv[1], sys.argv[2], sys.argv[3]
CUT = int(sys.argv[4]) if len(sys.argv) > 4 else 128
a = np.array(Image.open(src).convert('RGBA')).astype(int)
r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
opaque = al > 0
leaf = opaque & (r > 150) & (r - b > 90) & (g > 70)
wood = opaque & ~leaf
core = nd.binary_erosion(wood, structure=np.ones((5, 5)))
limbs = nd.binary_dilation(core, structure=np.ones((7, 7))) & opaque
# Drop small kept fragments cut off from the trunk (a knot inside the crown).
lab, n = nd.label(limbs | (np.arange(limbs.shape[0])[:, None] >= CUT))
sizes = nd.sum(np.ones_like(lab), lab, range(1, n + 1))
big = np.isin(lab, [i + 1 for i, s in enumerate(sizes) if s >= 60])
keep = limbs & big
keep[CUT:, :] = True
mask = ~keep
Image.fromarray(np.where(mask, 255, 0).astype(np.uint8)).convert('RGB').save(out)
# Preview: the oak over grey, masked area tinted red.
pv = np.full(a.shape, (120, 140, 150, 255))
pv = np.where(opaque[..., None], a, pv)
pv[mask] = (pv[mask] * 0.5 + np.array([255, 0, 0, 255]) * 0.5).astype(int)
Image.fromarray(pv.astype(np.uint8)).resize((768, 768), Image.NEAREST).save(preview)
print('masked px', int(mask.sum()), 'kept limb px above cut', int((limbs[:CUT]).sum()))
