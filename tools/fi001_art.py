"""FARMHOUSE-INTERIOR-001: the scripted (hand-placed) pixel art for the farmhouse interior.

Writes art/farm/fi/:
  floor_0..3.png    32x32 plank floors, one per house stage (weathered, swept, oiled, finished honey boards)
  floor_dmg.png     16x16 floor decals: hole, crack, patch (new boards), stain, dust
  wall_0..3.png     128x48 wall faces (ceiling beam, plaster between timber posts, chair rail, wainscot, baseboard):
                    torn paper, lath holes and stains (0), patched plaster (1), clean (2), warm cream (3)
  win_*.png         32x30 windows: frame (closed), open (lower sash raised), boards0 (boarded, cracked panes),
                    boards1 (one board, a pane patched with oilcloth), frost (winter overlay)
  fire.png          10 frames of 22x14 flame, for the hearth (played out of order at run time)
  web.png           cobwebs: 16x16 top-left corner, 16x16 top-right corner, 24x16 sagging strand
  barricade.png     16x32 planks nailed across a doorway seen from above (a room not open yet)
  rug_bed.png       48x32 braided rag rug for the bedroom
  wall_top.png      16x16 timber cap for the tops of walls
Pure numpy and PIL, seeded, so it reproduces exactly. Run from the repository root:
  python tools/fi001_art.py
"""
import os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'art/farm/fi')
INK = '1d1611'


def rgb(h):
    h = h.lstrip('#')
    return [int(h[i:i + 2], 16) for i in (0, 2, 4)] + [255]


def canvas(w, h):
    return np.zeros((h, w, 4), np.uint8)


def put(a, x, y, c):
    if 0 <= x < a.shape[1] and 0 <= y < a.shape[0]:
        a[y, x] = rgb(c) if isinstance(c, str) else c


def rect(a, x, y, w, h, c):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            put(a, xx, yy, c)


def save(a, name):
    Image.fromarray(a).save(os.path.join(OUT, name + '.png'))


# ---------------------------------------------------------------- floors
FLOORS = [
    # boards (three tones), gap, dark grain, light grain, dust speckle
    dict(b=['55432f', '4c3b2b', '5f4a37'], gap='211611', dk='413226', lt='6c5642', dust='7a7266', dustn=26),
    dict(b=['5b4733', '524030', '654f3a'], gap='241812', dk='463528', lt='735b45', dust='7a7266', dustn=10),
    dict(b=['7a5638', '6f4e33', '83603e'], gap='2e1d13', dk='5e412a', lt='93704b', dust=None, dustn=0),
    dict(b=['8d6440', '835b3a', '976b44'], gap='3a2416', dk='6e4a2e', lt='ae8051', dust=None, dustn=0),
]


def floor(stage):
    p = FLOORS[stage]
    r = np.random.default_rng(40 + stage)
    a = canvas(32, 32)
    for row in range(8):                       # eight boards 4 px deep, running across
        y0 = row * 4
        joint = int(r.integers(4, 28))         # one butt joint per board, staggered
        for seg, (x0, x1) in enumerate([(0, joint), (joint, 32)]):
            tone = p['b'][int(r.integers(0, 3))]
            rect(a, x0, y0, x1 - x0, 3, tone)
            for _ in range(3):                 # grain dashes
                gx, gy, gl = int(r.integers(x0, x1)), y0 + int(r.integers(0, 3)), int(r.integers(2, 6))
                c = p['dk'] if r.random() < 0.6 else p['lt']
                for k in range(gl):
                    if gx + k < x1:
                        put(a, gx + k, gy, c)
        rect(a, 0, y0 + 3, 32, 1, p['gap'])     # the gap under each board
        rect(a, joint, y0, 1, 3, p['gap'])
        put(a, joint - 2, y0 + 1, p['gap'])    # nail heads by the joint
        put(a, (joint + 2) % 32, y0 + 1, p['gap'])
        if stage == 3:                          # a little sheen on the finished boards
            sx = int(r.integers(0, 28))
            rect(a, sx, y0, 4, 1, 'b58a5a')
    for _ in range(p['dustn']):
        put(a, int(r.integers(0, 32)), int(r.integers(0, 32)), p['dust'])
    return a


def floor_damage():
    """16x16 cells: 0 hole, 1 crack, 2 patch, 3 stain, 4 dust drift."""
    a = canvas(80, 16)
    r = np.random.default_rng(7)
    # 0: two boards gone, the joists and dark void under them, splintered ends
    rect(a, 1, 4, 14, 8, '0f0a08')
    for x in (4, 11):
        rect(a, x, 4, 2, 8, '3a2a1e')
        rect(a, x, 4, 1, 8, '4a3726')
    for x in range(1, 15):
        if r.random() < 0.55:
            put(a, x, 4, '8a7258')
        if r.random() < 0.55:
            put(a, x, 11, '6a5642')
    rect(a, 0, 3, 16, 1, '211611')
    rect(a, 0, 12, 16, 1, '211611')
    # 1: a split board with lifted splinters
    cx = 16
    pts = [(2, 9), (4, 8), (6, 9), (8, 8), (10, 7), (12, 8), (14, 7)]
    for x, y in pts:
        put(a, cx + x, y, '140d0a')
        put(a, cx + x + 1, y, '140d0a')
        put(a, cx + x, y - 1, '7d6650')
    # 2: two new boards nailed over a hole (lighter, unweathered)
    cx = 32
    for row, tone in ((4, 'a07a52'), (8, '966f49')):
        rect(a, cx, row, 16, 3, tone)
        rect(a, cx, row + 3, 16, 1, '3a2618')
        put(a, cx + 1, row + 1, '3a2618')
        put(a, cx + 14, row + 1, '3a2618')
        for k in range(3):
            put(a, cx + 4 + k * 4, row + 1, 'b48c60')
    # 3: a water stain: a dark ring with a paler middle
    cx = 48
    for y in range(16):
        for x in range(16):
            d = ((x - 7.5) / 7.0) ** 2 + ((y - 8) / 5.0) ** 2
            if 0.62 < d < 1.0:
                a[y, cx + x] = [24, 16, 12, 120]
            elif d <= 0.62 and (x + y) % 3 == 0:
                a[y, cx + x] = [24, 16, 12, 50]
    # 4: drifted dust and grit
    cx = 64
    for _ in range(40):
        x, y = int(r.integers(0, 16)), int(r.integers(0, 16))
        a[y, cx + x] = [138, 128, 112, int(r.integers(70, 150))]
    return a


# ---------------------------------------------------------------- walls
WALLS = [
    dict(pl=['857762', '7d6f5b', '8d7f69'], post='3f2c20', posth='56402e', rail='4e3a2b', wc=['4d3d30', '46382c', '544335'], base='2c2019', beam='33241a'),
    dict(pl=['958770', '8d7f69', '9d8f77'], post='45301f', posth='5e4430', rail='563f2d', wc=['55432f', '4e3c2b', '5c4834'], base='2f2219', beam='3a281c'),
    dict(pl=['bba985', 'b4a27f', 'c1af8b'], post='4f3522', posth='6a4a30', rail='634530', wc=['6e4d32', '674830', '765338'], base='3a2617', beam='422c1d'),
    dict(pl=['cbb791', 'c4b08b', 'd1bd97'], post='553923', posth='734f33', rail='6d4b32', wc=['7c5838', '745235', '83603d'], base='3e2818', beam='48301f'),
]


def wall(stage):
    p = WALLS[stage]
    r = np.random.default_rng(90 + stage)
    w = 128
    a = canvas(w, 48)
    # plaster, with a soft mottle
    for y in range(4, 30):
        for x in range(w):
            a[y, x] = rgb(p['pl'][int(r.integers(0, 3))] if r.random() < 0.18 else p['pl'][0])
    # ceiling beam
    rect(a, 0, 0, w, 4, p['beam'])
    rect(a, 0, 1, w, 1, p['posth'])
    rect(a, 0, 3, w, 1, '1f150f')
    for x in range(0, w, 9):
        put(a, x + int(r.integers(0, 6)), 2, '2a1d14')
    # chair rail and wainscot boards
    rect(a, 0, 30, w, 2, p['rail'])
    rect(a, 0, 30, w, 1, p['posth'])
    for x0 in range(0, w, 8):
        tone = p['wc'][(x0 // 8) % 3]
        rect(a, x0, 32, 8, 13, tone)
        rect(a, x0, 32, 1, 13, '241a13')
        put(a, x0 + 3, 34, '241a13')
        put(a, x0 + 3, 42, '241a13')
    rect(a, 0, 45, w, 3, p['base'])
    rect(a, 0, 45, w, 1, p['rail'])
    # timber posts every 64 px
    for px in (0, 64):
        rect(a, px, 4, 4, 26, p['post'])
        rect(a, px + 1, 4, 1, 26, p['posth'])
        rect(a, px + 3, 4, 1, 26, '1f150f')
        put(a, px + 2, 8, '1f150f')
        put(a, px + 2, 25, '1f150f')
    if stage == 0:
        # torn remains of an old paper, peeling in strips
        for x0, x1 in ((6, 26), (40, 58), (70, 92), (100, 122)):
            top = 5 + int(r.integers(0, 4))
            for x in range(x0, x1):
                bot = top + 8 + int(r.integers(0, 12))
                for y in range(top, min(bot, 29)):
                    a[y, x] = rgb('8c7c5c' if (x // 3) % 2 else '807052')
                put(a, x, min(bot, 29), '5e5240')
        # holes knocked through to the lath
        for hx, hy, hw, hh in ((14, 15, 9, 8), (80, 9, 7, 10), (110, 18, 8, 7)):
            rect(a, hx, hy, hw, hh, '2a1d14')
            for ly in range(hy + 1, hy + hh, 3):
                rect(a, hx, ly, hw, 1, '6e5038')
            for x in range(hx - 1, hx + hw + 1):
                put(a, x, hy - 1, '5c5040')
                put(a, x, hy + hh, '6a5e4c')
        # water stains running down from the beam
        for sx in (30, 52, 96):
            for y in range(4, 22):
                for x in range(sx, sx + 5):
                    if r.random() < 0.7 - y * 0.025:
                        c = a[y, x].astype(int)
                        a[y, x, :3] = np.clip(c[:3] - 26, 0, 255)
        # cracks
        for cx0, cy0 in ((44, 6), (88, 22), (120, 6)):
            x, y = cx0, cy0
            for _ in range(10):
                put(a, x, y, '4a3e32')
                y += 1
                x += int(r.integers(-1, 2))
        # a missing wainscot board
        rect(a, 56, 33, 6, 11, '140d0a')
        rect(a, 104, 36, 7, 8, '140d0a')
    if stage == 1:
        # patched plaster over the old holes, a few cracks left, a fainter stain
        for hx, hy, hw, hh in ((12, 13, 13, 12), (78, 7, 11, 14), (108, 16, 12, 11)):
            rect(a, hx, hy, hw, hh, 'aa9c82')
            for x in range(hx, hx + hw):
                if r.random() < 0.35:
                    put(a, x, hy, 'b8aa90')
        for cx0, cy0 in ((44, 8), (120, 8)):
            x, y = cx0, cy0
            for _ in range(6):
                put(a, x, y, '6e6250')
                y += 1
                x += int(r.integers(-1, 2))
        rect(a, 56, 33, 6, 11, '6e5438')     # the missing board replaced, still unstained
        rect(a, 56, 33, 1, 11, '241a13')
    if stage == 3:
        # a faint painted stencil band under the beam
        for x in range(2, w, 8):
            put(a, x, 6, 'a8946c')
            put(a, x + 1, 7, 'a8946c')
            put(a, x + 2, 6, 'a8946c')
    return a


def wall_top():
    a = canvas(16, 16)
    r = np.random.default_rng(5)
    for y in range(16):
        for x in range(16):
            a[y, x] = rgb(['2a1f17', '2e2219', '271c15'][int(r.integers(0, 3))])
    for y in (5, 11):
        rect(a, 0, y, 16, 1, '1a120d')
    return a


# ---------------------------------------------------------------- windows
WIN_W, WIN_H = 32, 30
PANE = (4, 4, 24, 19)   # x, y, w, h of the glass, inside the frame


def win_frame(open_=False):
    a = canvas(WIN_W, WIN_H)
    wood, hi, dk = '5a4030', '7a5a40', '2a1d14'
    rect(a, 1, 1, 30, 25, INK)                # casing
    rect(a, 2, 2, 28, 23, wood)
    rect(a, 2, 2, 28, 1, hi)
    x, y, w, h = PANE
    a[y:y + h, x:x + w] = 0                    # the glass is drawn under the frame by the game
    # muntins
    rect(a, x + w // 2 - 1, y, 2, h, wood)
    rect(a, x + w // 2 - 1, y, 1, h, hi)
    mid = y + h // 2
    rect(a, x, mid, w, 2, wood)
    rect(a, x, mid, w, 1, hi)
    if open_:
        # the lower sash pushed up behind the upper: a doubled rail at the middle and no bars below it
        rect(a, x, mid + 2, w, 2, dk)
        rect(a, x, mid - 3, w, 2, wood)
        rect(a, x, mid - 3, w, 1, hi)
        a[mid + 4:y + h, x:x + w] = 0
        rect(a, x + w // 2 - 1, mid + 4, 2, y + h - mid - 4, (0, 0, 0, 0))
    # inner shadow line on the casing
    rect(a, x - 1, y - 1, w + 2, 1, dk)
    rect(a, x - 1, y - 1, 1, h + 1, dk)
    # the sill, deeper than the frame
    rect(a, 0, 25, 32, 4, INK)
    rect(a, 1, 25, 30, 3, '6e4f37')
    rect(a, 1, 25, 30, 1, '8e6b4a')
    rect(a, 1, 29, 30, 1, (0, 0, 0, 90))
    # latch
    put(a, x + w // 2, mid + 1, 'b08a4a')
    return a


def win_boards(stage):
    a = canvas(WIN_W, WIN_H)
    x, y, w, h = PANE
    r = np.random.default_rng(300 + stage)
    if stage == 0:
        # cracked and broken panes: a dark gap where glass is gone, cracks across the rest
        rect(a, x, y, 10, 7, '120d0a')
        for k in range(6):
            put(a, x + 10 - k, y + 7 - k // 2, (220, 220, 210, 160))
        for cx, cy in ((x + 16, y + 3), (x + 4, y + 14)):
            px, py = cx, cy
            for _ in range(7):
                put(a, px, py, (230, 230, 220, 150))
                px += int(r.integers(-1, 2))
                py += 1
        boards = [(y + 2, -1), (y + 9, 1), (y + 15, 0)]
    else:
        # one board across the lower half, and a pane patched with oiled cloth
        rect(a, x + 13, y + 1, 10, 7, 'b3a283')
        for k in range(0, 10, 3):
            put(a, x + 13 + k, y + 3, '9a8a6c')
        boards = [(y + 12, 0)]
    for by, slope in boards:
        for bx in range(-1, WIN_W + 1):
            yy = by + (bx * slope) // 10
            for t in range(4):
                c = ['6a5038', '5e4630', '54402c', INK][t] if t < 3 else INK
                put(a, bx, yy + t, c)
            if bx % 7 == 0:
                put(a, bx, yy + 1, '2a1d14')
        put(a, 2, by + 1, 'a0a0a0')           # nail heads
        put(a, WIN_W - 3, by + 1 + (WIN_W * slope) // 10, 'a0a0a0')
    return a


def win_frost():
    """Winter: frost feathering in from the panes' edges and corners (white, partly clear)."""
    a = canvas(WIN_W, WIN_H)
    x, y, w, h = PANE
    r = np.random.default_rng(77)
    for py in range(y, y + h):
        for px in range(x, x + w):
            # distance to the nearest pane edge (the four panes each frost from their own frame)
            lx = (px - x) % (w // 2)
            ly = (py - y) % (h // 2)
            d = min(lx, w // 2 - 1 - lx, ly, h // 2 - 1 - ly)
            corner = min(lx, w // 2 - 1 - lx) + min(ly, h // 2 - 1 - ly)
            p = 0.9 if d == 0 else (0.55 if d == 1 else (0.25 if d == 2 and corner < 5 else 0.0))
            if r.random() < p:
                a[py, px] = [232, 240, 248, int(r.integers(150, 225))]
    # a few fern strokes
    for sx, sy in ((x + 1, y + 1), (x + w - 2, y + h - 2), (x + 13, y + 10)):
        px, py = sx, sy
        for _ in range(4):
            put(a, px, py, (240, 246, 252, 200))
            px += 1 if sx < x + 10 else -1
            py += 1 if sy < y + 10 else -1
    return a


# ---------------------------------------------------------------- fire
def fire():
    """10 frames of 22x14 flame over a log bed, drawn from a seeded flame field: a few tongues that rise
    and lean differently each frame, a hot white-yellow core, orange body and a dark red fringe."""
    fw, fh, n = 22, 14, 10
    a = canvas(fw * n, fh)
    r = np.random.default_rng(11)
    pal = ['7a2a16', 'b4441c', 'e07a2a', 'f2b04a', 'fbe6a0']
    for f in range(n):
        heat = np.zeros((fh, fw))
        tongues = [(5 + r.normal(0, 1), 7 + r.normal(0, 1.5)), (11 + r.normal(0, 1), 11 + r.normal(0, 1.5)),
                   (16 + r.normal(0, 1), 8 + r.normal(0, 1.5))]
        lean = r.normal(0, 0.18)
        for cx, height in tongues:
            for yy in range(fh):
                up = fh - 1 - yy
                if up > height:
                    continue
                half = max(0.6, 3.6 * (1 - up / max(height, 1)) ** 0.8)
                ccx = cx + lean * up
                for xx in range(fw):
                    d = abs(xx - ccx) / half
                    if d < 1:
                        heat[yy, xx] = max(heat[yy, xx], (1 - d) * (1 - 0.65 * up / max(height, 1)))
        heat += r.normal(0, 0.025, heat.shape)
        # drop lone flecks: a pixel needs two lit neighbours to stay
        lit = heat > 0.12
        nb = sum(np.roll(np.roll(lit, dy, 0), dx, 1) for dy in (-1, 0, 1) for dx in (-1, 0, 1)) - lit
        heat[(nb < 2)] = 0
        for yy in range(fh):
            for xx in range(fw):
                v = heat[yy, xx]
                if v > 0.12:
                    k = 0 if v < 0.2 else 1 if v < 0.38 else 2 if v < 0.58 else 3 if v < 0.78 else 4
                    a[yy, f * fw + xx] = rgb(pal[k])
        # glowing log bed along the bottom
        for xx in range(2, fw - 2):
            a[fh - 1, f * fw + xx] = rgb('3a1a10' if (xx + f) % 4 else 'c0502a')
            a[fh - 2, f * fw + xx] = rgb('6a2414') if a[fh - 2, f * fw + xx, 3] == 0 else a[fh - 2, f * fw + xx]
    return a


# ---------------------------------------------------------------- cobwebs, barricade, rug
def webs():
    a = canvas(56, 16)
    c = (210, 210, 200, 150)
    c2 = (210, 210, 200, 90)
    # top-left corner web: radial strands from the corner, three sagging rings
    for k in range(5):
        ang = k * (np.pi / 2) / 4
        for t in range(15):
            x, y = int(round(np.cos(ang) * t)), int(round(np.sin(ang) * t))
            put(a, x, y, c)
    for rad in (5, 9, 13):
        for k in range(rad * 3):
            ang = k / (rad * 3) * (np.pi / 2)
            x = int(round(np.cos(ang) * rad))
            y = int(round(np.sin(ang) * rad + np.sin(ang * 2) * 1.2))
            put(a, x, y, c2)
    a[:, 16:32] = a[:, 0:16][:, ::-1]          # top-right is its mirror
    # a sagging strand 24 wide
    for x in range(24):
        y = int(round(1 + 6 * np.sin(np.pi * x / 23)))
        put(a, 32 + x, y, c)
        if x % 5 == 2:
            put(a, 32 + x, y + 1, c2)
    return a


def barricade():
    a = canvas(16, 32)
    # the doorway's floor in shadow, then planks nailed across, seen from above
    rect(a, 0, 0, 16, 32, '1a130e')
    for y0, tone in ((3, '5e4630'), (12, '54402c'), (21, '5a432e')):
        rect(a, 0, y0, 16, 5, INK)
        rect(a, 0, y0 + 1, 16, 3, tone)
        rect(a, 0, y0 + 1, 16, 1, '74583e')
        put(a, 2, y0 + 2, 'a0a0a0')
        put(a, 13, y0 + 2, 'a0a0a0')
    return a


def rug_bed():
    w, h = 48, 32
    a = canvas(w, h)
    rings = ['5a3a2e', '7a5a3c', '4e5a6a', '8a6a48', '6a3a34', '9a845e', '5a6a54']
    for y in range(h):
        for x in range(w):
            d = ((x - 23.5) / 23.5) ** 2 + ((y - 15.5) / 15.5) ** 2
            if d <= 1:
                ring = int(np.sqrt(d) * 9)
                c = rings[ring % len(rings)] if ring < 8 else INK
                a[y, x] = rgb(c)
                if (x + y * 2) % 5 == 0 and ring < 8:   # the braid
                    a[y, x, :3] = np.clip(a[y, x, :3].astype(int) - 18, 0, 255)
    return a


def main():
    os.makedirs(OUT, exist_ok=True)
    for s in range(4):
        save(floor(s), 'floor_%d' % s)
        save(wall(s), 'wall_%d' % s)
    save(floor_damage(), 'floor_dmg')
    save(wall_top(), 'wall_top')
    save(win_frame(), 'win_frame')
    save(win_frame(True), 'win_open')
    save(win_boards(0), 'win_boards0')
    save(win_boards(1), 'win_boards1')
    save(win_frost(), 'win_frost')
    save(fire(), 'fire')
    save(webs(), 'web')
    save(barricade(), 'barricade')
    save(rug_bed(), 'rug_bed')
    print('wrote', sorted(os.listdir(OUT)))


if __name__ == '__main__':
    main()
