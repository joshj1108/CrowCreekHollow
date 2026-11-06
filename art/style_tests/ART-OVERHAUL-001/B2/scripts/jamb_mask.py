"""B2 pass 2: the stone jambs either side of the opening (x 70-90 and 134-154, y 18-90), light pixels only
(luma >= 34 keeps the dark core and its outline), eroded from the silhouette by 2 px."""
import numpy as np, sys
from PIL import Image
src = np.array(Image.open(sys.argv[1]).convert('RGBA')).astype(float)
a = src[..., 3] >= 128
L = 0.3 * src[..., 0] + 0.55 * src[..., 1] + 0.15 * src[..., 2]
m = np.zeros(a.shape, bool)
m[18:90, 70:90] = True; m[18:90, 134:154] = True
m &= a & (L >= 34)
out = np.where(m[..., None], 255, 0).astype(np.uint8).repeat(3, 2)
Image.fromarray(out, 'RGB').save(sys.argv[2]); print(m.sum())
