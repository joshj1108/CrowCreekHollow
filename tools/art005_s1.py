# ART-005 S1 (non-production): two zero-generation farmhouse mockups with a simpler roof, for the owner's
# simplification direction (board, 2026-11-05). Everything below the eave (y >= 160: walls, corner posts, foundation,
# windows, door, lamp, steps) is M0's published sprite copied pixel for pixel, so the facade, the 384 x 320 canvas,
# the window centres, the door and the footprint are identical to M0 and H1. Only the roof is replaced:
#   sa  side gable: one ridge running east-west, low (ridge cap y 48-56 instead of M0's 12-20), plain rake boards at
#       the gable ends, no hips. The roof covers the footprint's roof rows (from y 74) as before.
#   sb  sa plus one centred front gable over the door (4.5 tiles wide) with a board-and-batten face and an attic
#       window: the classic farmhouse focal point, and a place for restoration-stage detail.
# Materials are sampled from the same frozen G1 board c1 as M0 (read only). No generation, no credits.
#   python tools/art005_s1.py
# Writes art/style_tests/ART-005/pl/g4/<sa|sb>/32/house_day.png, house_night.png (harness art=g4 var=sa|sb),
# and pl/g4/<sa|sb>/labels_roof.png + blockout.png.
import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import art005_m0 as m0  # noqa: E402

W, H = m0.W, m0.H
G4 = os.path.join(m0.ROOT, "pl", "g4")
RIDGE_Y = 56        # ridge cap bottom; cap y 48-56
COURSE = 12         # slate course height (M0: 16)
EAVE_BAND = 148     # fascia 148-156, eave shadow 156-160 (as M0)
ROOF_X = (4, 380)   # gable overhang 12 px past the walls (M0 roof 1-383)
RAKE = 4            # rake (barge) board width at the gable ends
CHIM = (296, 324, 22, 66)   # x0, x1, top, bottom where it meets the roof
GAB = {"cx": 192, "half_out": 100, "half_in": 80, "apex_out": 60, "apex_in": 80, "base": 154}   # sb front gable
ATTIC = (182, 104, 202, 126)   # sb attic window x0, y0, x1, y1 (centre 192, 115)

# roof labels (separate from M0's)
R = {"empty": 0, "slate": 1, "ridge": 2, "rake": 3, "fascia": 4, "eave_shadow": 5, "chimney": 6, "chimney_cap": 7,
     "chim_shadow": 8, "g_slate_l": 9, "g_slate_r": 10, "g_barge": 11, "g_face": 12, "a_frame": 13, "a_glass": 14,
     "a_mullion": 15, "back": 16}
FLAT = {1: "5d6873", 2: "8d98a2", 3: "8a6a4c", 4: "8a6a4c", 5: "2a2420", 6: "807a70", 7: "a29c90", 8: "38404a",
        9: "6f7a85", 10: "4a535d", 11: "9a7a58", 12: "a58a66", 13: "6b4b33", 14: "4e6f7a", 15: "4a3526", 16: "434c56"}


def in_v(x, y, half, apex):
    """Inside the upward V (^) whose apex is (cx, apex) and whose feet are (cx -/+ half, GAB base)."""
    cx, base = GAB["cx"], GAB["base"]
    if y < apex or y >= base:
        return False
    return abs(x - cx) <= half * (y - apex) / (base - apex)


def roof_labels(variant):
    lab = np.zeros((H, W), np.uint8)
    x0, x1 = ROOF_X
    lab[RIDGE_Y:EAVE_BAND, x0:x1] = R["slate"]
    lab[RIDGE_Y - 12:RIDGE_Y - 6, x0 + 2:x1 - 2] = R["back"]     # the far slope, just showing past the ridge
    lab[RIDGE_Y - 6:RIDGE_Y, x0 - 1:x1 + 1] = R["ridge"]
    lab[RIDGE_Y:EAVE_BAND, x0:x0 + RAKE] = R["rake"]
    lab[RIDGE_Y:EAVE_BAND, x1 - RAKE:x1] = R["rake"]
    lab[EAVE_BAND:156, x0:x1] = R["fascia"]
    lab[156:160, x0:x1] = R["eave_shadow"]
    c0, c1, ct, cb = CHIM
    for y in range(ct + 6, cb + 4):   # cast shadow to the lower right (light from the upper left)
        for x in range(c1, c1 + 8):
            if lab[y, x] == R["slate"]:
                lab[y, x] = R["chim_shadow"]
    lab[ct + 6:cb, c0:c1] = R["chimney"]
    lab[ct:ct + 6, c0 - 3:c1 + 3] = R["chimney_cap"]
    if variant == "sb":
        cx = GAB["cx"]
        for y in range(GAB["apex_out"], GAB["base"]):
            for x in range(cx - GAB["half_out"] - 1, cx + GAB["half_out"] + 2):
                if in_v(x, y, GAB["half_out"], GAB["apex_out"]):
                    if in_v(x, y, GAB["half_in"], GAB["apex_in"]):
                        lab[y, x] = R["g_face"] if y < EAVE_BAND else lab[y, x]
                    elif in_v(x, y, GAB["half_in"] + 6, GAB["apex_in"] - 8):
                        lab[y, x] = R["g_barge"]
                    else:
                        lab[y, x] = R["g_slate_l"] if x < cx else R["g_slate_r"]
        a0, b0, a1, b1 = ATTIC
        lab[b0:b1, a0:a1] = R["a_frame"]
        lab[b0 + 3:b1 - 3, a0 + 3:a1 - 3] = R["a_glass"]
        lab[b0 + 3:b1 - 3, cx - 1:cx + 1] = R["a_mullion"]
        lab[(b0 + b1) // 2 - 1:(b0 + b1) // 2 + 1, a0 + 3:a1 - 3] = R["a_mullion"]
    return lab


def render_roof(lab, m, seed=11):
    rng = np.random.default_rng(seed)
    slate, trim, stone, tim, glass = m["slate"], m["trim"], m["stone"], m["timber"], m["glass"]
    out = np.zeros((H, W, 4), np.uint8)
    mask = np.zeros((H, W), bool)
    joints = []
    for _ in range(20):
        js, x = [], -int(rng.integers(0, 22))
        while x < W + 30:
            js.append(x)
            x += int(rng.integers(14, 27))
        joints.append(np.array(js))
    jitter = rng.uniform(-0.07, 0.07, 4000)
    # low-frequency weathering: a few large soft patches, not per-tile noise
    yy, xx = np.mgrid[0:H, 0:W]
    patch = np.zeros((H, W))
    for _ in range(5):
        px, py, r = rng.uniform(20, 360), rng.uniform(60, 140), rng.uniform(30, 70)
        patch += rng.uniform(-0.09, 0.07) * np.exp(-((xx - px) ** 2 + (yy - py) ** 2) / (2 * r * r))

    def slate_at(y, x, y0, shade):
        ci, rr = (y - y0) // COURSE, (y - y0) % COURSE
        js = joints[ci % len(joints)]
        k = int(np.searchsorted(js, x, side="right"))
        j0 = js[k - 1] if k > 0 else -40
        sid, col = k + ci * 37, x - j0
        grad = 0.06 * (1 - (y - RIDGE_Y) / (EAVE_BAND - RIDGE_Y))   # a touch lighter toward the ridge
        if rr == 0:
            return slate.tone(0.8 + shade)
        hang = (sid * 7) % 3 == 0                                  # some slates hang one px lower
        if rr == COURSE - 1 and not hang:
            return slate.tone(0.04)
        if rr == COURSE - 2 and not hang or (rr == COURSE - 1 and hang and col > 1):
            return slate.tone(0.12 + shade * 0.5)
        if col == 0:
            return slate.tone(0.2 + shade)
        t = slate.sample(rr + sid * 5, col + sid * 11)
        if m0.is_moss(t):
            return t
        return slate.tone(0.36 + 0.3 * slate.q(t) + shade + grad + jitter[sid % 4000] + patch[y, x])

    ys, xs = np.nonzero(lab)
    cx = GAB["cx"]
    for y, x in zip(ys, xs):
        n = int(lab[y, x])
        if n == R["slate"]:
            c = slate_at(y, x, RIDGE_Y, 0.0)
        elif n == R["chim_shadow"]:
            c = slate.tone(0.06 + 0.12 * slate.q(slate.sample(y, x)))
        elif n == R["ridge"]:
            rr = y - (RIDGE_Y - 6)
            c = slate.tone(0.9 if rr == 0 else (0.62 if rr <= 3 else 0.12))
        elif n == R["back"]:
            c = slate.tone(0.1 + 0.1 * slate.q(slate.sample(y, x)))
        elif n == R["rake"]:
            l = x - ROOF_X[0] if x < W // 2 else ROOF_X[1] - 1 - x
            lit = x < W // 2
            c = trim.tone((0.85 if lit else 0.4) if l <= 1 else (0.5 if lit else 0.22))
        elif n == R["fascia"]:
            rr = y - EAVE_BAND
            c = trim.tone(0.92 if rr <= 1 else (0.55 if rr <= 6 else 0.12))
        elif n == R["eave_shadow"]:
            c = m["ink"] if y >= 158 else trim.tone(0.03)
        elif n == R["chimney"]:
            q = stone.q(stone.sample(y, x)) - (0.25 if x >= CHIM[1] - 6 else 0.0)
            c = stone.tone(q)
        elif n == R["chimney_cap"]:
            rr = y - CHIM[2]
            c = stone.tone(0.95 if rr <= 1 else (0.7 if rr <= 3 else 0.15))
        elif n in (R["g_slate_l"], R["g_slate_r"]):
            c = slate_at(y, x, RIDGE_Y, 0.1 if n == R["g_slate_l"] else -0.12)
        elif n == R["g_barge"]:
            d_in = abs(x - cx) - GAB["half_in"] * (y - GAB["apex_in"]) / (GAB["base"] - GAB["apex_in"])
            lit = x < cx
            c = trim.tone((0.88 if lit else 0.5) if d_in > 4 else (0.55 if lit else 0.28) if d_in > 1 else 0.06)
        elif n == R["g_face"]:
            bx = (x - cx + 64) % 9
            if bx == 0:
                c = tim.tone(0.04)
            elif bx == 1:
                c = tim.tone(0.72)
            else:
                t = tim.sample(y, x * 3)
                c = tim.tone(0.3 + 0.42 * tim.q(t) - (0.18 if y < GAB["apex_in"] + 18 else 0.0))
        elif n == R["a_frame"]:
            a0, b0, a1, b1 = ATTIC
            l, t_, rg, b = x - a0, y - b0, a1 - 1 - x, b1 - 1 - y
            c = m["ink"] if min(l, t_, rg, b) == 0 else trim.tone(0.88 if (l <= 1 or t_ <= 1) else 0.4)
        elif n == R["a_glass"]:
            mask[y, x] = True
            c = glass.tone(0.85 if (x - ATTIC[0] + y - ATTIC[1]) in (8, 9) else 0.4)
        elif n == R["a_mullion"]:
            c = trim.tone(0.3)
        else:
            continue
        out[y, x, :3] = c
        out[y, x, 3] = 255
    return out, mask


def outline(out, ink):
    op = out[..., 3] > 0
    nb = np.zeros_like(op)
    nb[1:] |= op[:-1]
    nb[:-1] |= op[1:]
    nb[:, 1:] |= op[:, :-1]
    nb[:, :-1] |= op[:, 1:]
    edge = nb & ~op
    out[edge, :3] = ink
    out[edge, 3] = 255
    return out


def build(variant, m, lab0, ref_day, ref_night):
    # The facade (every row from the eave down, y >= 160) is M0's published sprite, copied pixel for pixel, day and
    # night, so the comparison is about the roof alone.
    fac = lab0.copy()
    fac[:160] = 0
    rlab = roof_labels(variant)
    rday, rmask = render_roof(rlab, m)
    day = np.zeros((H, W, 4), np.uint8)
    day[160:] = ref_day[160:]
    sel = rday[..., 3] > 0
    day[sel] = rday[sel]
    day = outline(day, m["ink"])
    day[160:] = ref_day[160:]                      # keep M0's own facade outline (no doubled ink)
    day[160, :ROOF_X[0] - 1] = 0                   # M0's wider eave outline stub, past this roof's overhang
    day[160, ROOF_X[1] + 1:] = 0
    if variant == "sb":   # ink between the front gable and the main roof
        g = np.isin(rlab, [R["g_slate_l"], R["g_slate_r"], R["g_barge"]])
        nb = np.zeros_like(g)
        nb[1:] |= g[:-1]
        nb[:, 1:] |= g[:, :-1]
        nb[:, :-1] |= g[:, 1:]
        edge = nb & ~g & (rlab == R["slate"])
        day[edge, :3] = m["ink"]
    night, _ = m0.night_of(day, rmask, m)          # the roof's only glass is the sb attic window
    night[160:] = ref_night[160:]
    night[160, :ROOF_X[0] - 1] = 0
    night[160, ROOF_X[1] + 1:] = 0
    flat = m0.blockout(fac)
    for k, hexc in FLAT.items():
        s_ = rlab == k
        flat[s_, :3] = [int(hexc[i:i + 2], 16) for i in (0, 2, 4)]
        flat[s_, 3] = 255
    return day, night, rlab, flat


def main():
    m = m0.load_mats(os.path.join(m0.ROOT, "pl", "anchors", "board_c1.png"))
    lab0 = m0.build_labels()
    g2 = os.path.join(m0.ROOT, "pl", "g2", "32")
    ref = np.array(Image.open(os.path.join(g2, "house_day.png")).convert("RGBA"))
    refn = np.array(Image.open(os.path.join(g2, "house_night.png")).convert("RGBA"))
    for v in ("sa", "sb"):
        d = os.path.join(G4, v, "32")
        os.makedirs(d, exist_ok=True)
        day, night, rlab, flat = build(v, m, lab0, ref, refn)
        Image.fromarray(day, "RGBA").save(os.path.join(d, "house_day.png"))
        Image.fromarray(night, "RGBA").save(os.path.join(d, "house_night.png"))
        Image.fromarray(rlab, "L").save(os.path.join(G4, v, "labels_roof.png"))
        Image.fromarray(flat, "RGBA").save(os.path.join(G4, v, "blockout.png"))
        same = (day[160:] == ref[160:]).all(axis=2).mean()
        same_n = (night[160:] == refn[160:]).all(axis=2).mean()
        print(v, "opaque px", int((day[..., 3] > 0).sum()), "M0", int((ref[..., 3] > 0).sum()),
              "facade y>=160 identical to M0: day %.4f night %.4f" % (same, same_n))


if __name__ == "__main__":
    main()
