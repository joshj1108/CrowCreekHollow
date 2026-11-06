"""B2: mask for re-inpainting the cliff face as irregular rock. White = regenerate: opaque rock eroded 2 px
(keeps the silhouette), minus the mouth and its brow (x 72-152, y 14-96)."""
import numpy as np, sys
from PIL import Image
src = np.array(Image.open(sys.argv[1]).convert('RGBA'))
a = src[..., 3] >= 128
m = a.copy()
for _ in range(2):
    e = m.copy(); e[1:] &= m[:-1]; e[:-1] &= m[1:]; e[:, 1:] &= m[:, :-1]; e[:, :-1] &= m[:, 1:]; m = e
m[14:, 72:152] = False
m[90:] = False                        # keep the soil foot as it is
out = np.where(m[..., None], 255, 0).astype(np.uint8).repeat(3, 2)
Image.fromarray(out, 'RGB').save(sys.argv[2])
print(m.sum(), 'px white')
