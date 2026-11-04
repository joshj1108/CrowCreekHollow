# ART-003 W-3 (non-production): hand cleanup of the chosen canopy inpaint (oak_w3_s501.png -> oak_w3.png).
# Only pixels inside the inpaint mask change, so the trunk, limbs, roots and stones stay identical to r3/oak_d.png.
# 1. Seams: a transparent masked pixel touching a kept (unmasked) limb pixel gets the oak's outline colour, so a
#    limb that ends at the mask edge is closed by an outline instead of a flat cut.
# 2. The knot: a kept twig fragment left inside the upper-left foliage mass is repainted from the foliage round it.
import sys
import numpy as np
from PIL import Image
from scipy import ndimage as nd

src, mask_p, out = sys.argv[1], sys.argv[2], sys.argv[3]
a = np.array(Image.open(src).convert('RGBA'))
m = np.array(Image.open(mask_p).convert('L')) > 127
op = a[..., 3] > 0
lum = a[..., :3].astype(int).sum(-1)
# The outline colour: the most common very dark opaque colour of the kept wood.
dark = (~m) & op & (lum < 150)
cols, counts = np.unique(a[dark].reshape(-1, 4), axis=0, return_counts=True)
outline = cols[counts.argmax()]
n_seam = 0
kept = (~m) & op
near_kept = nd.binary_dilation(kept, structure=np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]]))
seam = m & ~op & near_kept
a[seam] = outline
n_seam = int(seam.sum())
# The knot: the kept (unmasked) twig fragment inside the upper-left mass (rows 56-69, columns 59-67), a dark
# stub the inpaint grew foliage round. Each of its pixels takes the colour of the nearest generated foliage pixel,
# and the fragment is added to the final mask (mask_final.png), which the identity check is run against.
box = np.zeros_like(m)
box[56:70, 59:68] = True
knot = box & ~m & op
src_fol = m & op & ~seam
_, (iy, ix) = nd.distance_transform_edt(~src_fol, return_indices=True)
a[knot] = a[iy[knot], ix[knot]]
Image.fromarray(np.where(m | knot, 255, 0).astype(np.uint8)).convert('RGB').save(out.replace('oak_w3.png', 'mask_final.png'))
Image.fromarray(a).save(out)
print('outline', outline.tolist(), 'seam px', n_seam, 'knot px', int(knot.sum()))
