# CCH-CONSOLIDATED-003 Final Polish: restrained fixes to three cave-creature sheets (art/farm/cave_foes/).
# Run from the project folder: python tools/cchfp_creatures.py
# The untouched sheets are kept first in art/style_tests/CCH-003-FP/before/ (and read from there, so a rerun gives the
# same result). Frame counts, cell size and the FEET row are unchanged.
#   bat_attack: frame 0 (the blow lands on it) was a tucked pose about half the size of the frames around it, so the
#     bat seemed to shrink and grow; it becomes frame 4's wings-down strike pose, moved down to frame 0's height.
#   snake_move: the coil stood still while the head rose and fell 8 art px; the cycle now uses the frames that sway
#     the head about 5 px (0, 1, 5, 4, 5, 1), so it reads as a glide, not a bob.
#   lizard_*: its body (luma ~120) matched the cave floor (~107); the back's top edge gets a pale highlight, the row
#     under it a little light, the mid-tones go slightly darker and warmer, and the underside darker, so the back and
#     head read against the floor at the lantern's edge. No outline glow, no green.
import os
import shutil
from PIL import Image
import numpy as np

SRC = "art/farm/cave_foes"
BEFORE = "art/style_tests/CCH-003-FP/before"
CELL = 32


def keep(name):
    os.makedirs(BEFORE, exist_ok=True)
    b = os.path.join(BEFORE, name)
    if not os.path.exists(b):
        shutil.copy(os.path.join(SRC, name), b)
    return np.array(Image.open(b).convert("RGBA"))


def save(arr, name):
    Image.fromarray(arr).save(os.path.join(SRC, name))


def frame(a, i):
    return a[:, i * CELL:(i + 1) * CELL].copy()


def bat():
    a = keep("bat_attack.png")
    f4 = frame(a, 4)
    ys = np.nonzero(f4[:, :, 3].any(axis=1))[0]
    ys0 = np.nonzero(frame(a, 0)[:, :, 3].any(axis=1))[0]
    dy = int(ys0.max() - ys.max())          # bottoms level with the old frame 0
    moved = np.zeros_like(f4)
    moved[max(0, dy):CELL - max(0, -dy)] = f4[max(0, -dy):CELL - max(0, dy)]
    a[:, 0:CELL] = moved
    save(a, "bat_attack.png")


def snake():
    a = keep("snake_move.png")
    order = [0, 1, 5, 4, 5, 1]
    out = np.concatenate([frame(a, i) for i in order], axis=1)
    save(out, "snake_move.png")


def luma(c):
    return 0.299 * c[..., 0] + 0.587 * c[..., 1] + 0.114 * c[..., 2]


def lizard_frame(f):
    rgb = f[:, :, :3].astype(float)
    on = f[:, :, 3] > 0
    lum = luma(rgb)
    body = on & (lum > 40)             # the dark outline stays as it is
    out = rgb.copy()
    up = np.zeros_like(body)
    up[1:] = body[:-1]                  # a body pixel above
    down = np.zeros_like(body)
    down[:-1] = body[1:]                # a body pixel below
    top_edge = body & ~up
    second = body & up & ~np.vstack([np.zeros((2, CELL), bool), body[:-2]])
    under = body & ~down
    mid = body & ~top_edge & ~second & ~under
    out[mid] = out[mid] * 0.78 + np.array([8.0, 2.0, -6.0])
    out[second] = out[second] * 1.05 + np.array([16.0, 12.0, 2.0])
    out[top_edge] = out[top_edge] * 0.3 + np.array([206.0, 192.0, 158.0]) * 0.7
    out[under] = out[under] * 0.62
    f = f.copy()
    f[:, :, :3] = np.clip(out, 0, 255).astype(np.uint8)
    return f


def lizard():
    for st in ["idle", "move", "alert", "attack", "hurt", "death"]:
        name = "lizard_%s.png" % st
        a = keep(name)
        n = a.shape[1] // CELL
        save(np.concatenate([lizard_frame(frame(a, i)) for i in range(n)], axis=1), name)


if __name__ == "__main__":
    bat()
    snake()
    lizard()
    print("done")
