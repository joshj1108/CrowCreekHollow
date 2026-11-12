# CCH-CONSOLIDATED-003 Final Polish: the mailbox reads apart from the farm stand.
# Run from the project folder, after tools/cch003_mailbox.py: python tools/cchfp_mailbox.py
# Reads the Phase B strip (kept in art/style_tests/CCH-003-FP/before/mailbox.png, so a rerun gives the same result)
# and rewrites art/farm/mailbox.png with the same five 19x29 frames, size, post, flag and door positions:
#   - the charcoal box (the stand's shadows are the same charcoal) becomes weathered galvanised steel: a little
#     lighter and cooler, so the metal parts from the wooden crates and post;
#   - its top edge catches a pale highlight, giving the rounded lid a clear silhouette;
#   - the door end is lifted a step from the side, with a light seam where they meet, so the door reads;
#   - the red flag is a touch brighter and warmer against the steel.
# Outlines, the post, the grass and the open door's dark inside are unchanged.
import os
import shutil
from PIL import Image
import numpy as np

OUT = "art/farm/mailbox.png"
BEFORE = "art/style_tests/CCH-003-FP/before/mailbox.png"
FW = 19

os.makedirs(os.path.dirname(BEFORE), exist_ok=True)
if not os.path.exists(BEFORE):
    shutil.copy(OUT, BEFORE)
a = np.array(Image.open(BEFORE).convert("RGBA"))
rgb = a[..., :3].astype(float)
on = a[..., 3] > 0
lum = 0.299 * rgb[..., 0] + 0.587 * rgb[..., 1] + 0.114 * rgb[..., 2]
mx = rgb.max(axis=2)
mn = rgb.min(axis=2)
sat = (mx - mn) / np.maximum(mx, 1)
H = a.shape[0]
ys, xs = np.mgrid[0:H, 0:a.shape[1]]
fx = xs % FW
box_rows = ys <= 14                                  # the box; the post and grass are below
red = on & (rgb[..., 0] > rgb[..., 1] + 25) & box_rows
metal = on & box_rows & ~red & (sat < 0.22) & (lum > 30) & (lum < 120)
door = metal & (fx <= 8) & (ys >= 4)

out = rgb.copy()
steel = np.array([0.93, 1.0, 1.08])                  # cooler
out[metal] = (rgb[metal] * 1.12 + 16.0) * steel
out[door] = out[door] + 12.0
# The seam between the door end and the side: the lighter column just right of the door.
seam = metal & (fx == 8) & (ys >= 5) & (ys <= 12)
out[seam] = out[seam] * 0.5 + np.array([170.0, 182.0, 188.0]) * 0.5
# The lid's top edge: metal with nothing (or outline) above it.
above = np.zeros_like(on)
above[1:] = metal[:-1] | red[:-1]
top = metal & ~above
out[top] = out[top] * 0.45 + np.array([176.0, 188.0, 194.0]) * 0.55
out[red] = rgb[red] * np.array([1.18, 1.0, 0.9]) + np.array([14.0, 2.0, 0.0])

a[..., :3] = np.clip(out, 0, 255).astype(np.uint8)
Image.fromarray(a).save(OUT)
print("done", int(metal.sum()), int(red.sum()))
