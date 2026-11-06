"""ENV-001 (zero-generation, NON-PRODUCTION): review sheets and measurements for the whole-farm environment study.

    python tools/env001_art.py && bash tools/env001_run.sh && python tools/env001_review.py
Sheets -> art/style_tests/ENV-001/review/ (the masters are made after, with tools/review_master.ps1).
"""
import json
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
FR = os.path.join(ROOT, "builds", "review", "ART-005", "p1_export", "builds", "review", "ENV-001")
A = os.path.join(ROOT, "art", "style_tests", "ENV-001")
REV = os.path.join(A, "review")
F = ImageFont.load_default(size=18)
FS = ImageFont.load_default(size=14)
FB = ImageFont.load_default(size=24)
BG, FG, DIM, WARN = (22, 20, 24), (236, 230, 220), (170, 164, 156), (255, 196, 110)
NONPROD = ("! NON-PRODUCTION study, zero generation. Harness-only switches; nothing in the game, its art, lighting, "
           "shaders, camera, collision, layout or saves changed.")
VIEWS = {"home": "1 Cabin, golden oak, well, farmer (at 38.5,10.5)", "fields": "2 F2 fields and paths (51.5,24.3)",
         "orchard": "3 Orchard, pond, dock; lawn vs forest edge (14,27)", "gate": "4 Road, closed gate, south edge (56,34)"}
NOON = [("ctrl", "CONTROL (VS16-P1 baseline)"), ("terrain", "T  terrain only"), ("shadows", "S  shadows only"),
        ("day", "D  noon key only"), ("all", "T+S+D  combined")]
NIGHT = [("ctrl", "R3-1 night CONTROL"), ("ts", "T+S at night (D off)"), ("alld", "T+S+D forced at night")]


def frame(name):
    return Image.open(os.path.join(FR, name + ".png")).convert("RGB")


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def label(im, text, sub="", col=FG):
    out = Image.new("RGB", (im.width, im.height + (44 if sub else 26)), BG)
    d = ImageDraw.Draw(out)
    d.text((2, 3), text, font=F, fill=col)
    if sub:
        d.text((2, 24), sub, font=FS, fill=DIM)
    out.paste(im.convert("RGB"), (0, out.height - im.height))
    return out


def sheet(name, title, notes, rows, gap=14, pad=16):
    w = max(sum(c.width for c in r) + gap * (len(r) - 1) for r in rows)
    head = 44 + 18 * len(notes)
    h = head + sum(max(c.height for c in r) + gap for r in rows)
    out = Image.new("RGB", (w + 2 * pad, h + pad), BG)
    d = ImageDraw.Draw(out)
    d.text((pad, 10), title, font=FB, fill=FG)
    for i, n in enumerate(notes):
        d.text((pad, 44 + i * 18), n, font=FS, fill=WARN if n.startswith("!") else DIM)
    y = head
    for r in rows:
        x = pad
        for c in r:
            out.paste(c, (x, y))
            x += c.width + gap
        y += max(c.height for c in r) + gap
    os.makedirs(REV, exist_ok=True)
    out.save(os.path.join(REV, name + ".png"))
    print(name, out.size)
    return out


def on_bg(im, col=(40, 36, 40)):
    b = Image.new("RGBA", im.size, col + (255,))
    b.alpha_composite(im.convert("RGBA"))
    return b.convert("RGB")


def luma(im):
    a = np.asarray(im).astype(np.float32)
    return 0.299 * a[..., 0] + 0.587 * a[..., 1] + 0.114 * a[..., 2]


def value_map(im):
    L = luma(im)
    bands = np.clip((L / 256.0 * 7).astype(int), 0, 6)
    pal = np.array([12, 40, 72, 104, 140, 180, 225], np.uint8)
    return Image.fromarray(pal[bands]).convert("RGB")


def busy(im):
    # share of pixels whose luma differs from the right or lower neighbour by > 18: a texture-frequency proxy
    L = luma(im)
    dx = np.abs(np.diff(L, axis=1))[:-1, :]
    dy = np.abs(np.diff(L, axis=0))[:, :-1]
    return float(((dx > 18) | (dy > 18)).mean())


def source_sheet():
    T = os.path.join(A, "terrain")
    g = Image.open(os.path.join(T, "grass.png")).convert("RGBA")
    d = Image.open(os.path.join(T, "dirt.png")).convert("RGBA")
    w = Image.open(os.path.join(T, "path_wang.png")).convert("RGBA")
    a = Image.open(os.path.join(T, "accents.png")).convert("RGBA")
    p = Image.open(os.path.join(T, "palette.png")).convert("RGBA")
    # a sample patch laid exactly as the harness lays it: a path crossing grass with all four grass variants
    grid = ["0000000", "0011000", "0111100", "0011000", "0000000"]
    M = lambda x, y: grid[y][x] if 0 <= y < 5 and 0 <= x < 7 else "0"
    patch = Image.new("RGBA", (16 * 8, 16 * 6))
    for vy in range(6):
        for vx in range(8):
            k = M(vx - 1, vy - 1) + M(vx, vy - 1) + M(vx - 1, vy) + M(vx, vy)
            if k == "0000":
                t = g.crop((((vx * 3 + vy) % 4) * 16, 0, ((vx * 3 + vy) % 4) * 16 + 16, 16))
            elif k == "1111":
                t = d.crop((16, 0, 32, 16))
            else:
                i, v = int(k, 2), (vx + vy) % 2
                t = w.crop((i * 16, v * 16, i * 16 + 16, v * 16 + 16))
            patch.paste(t, (vx * 16, vy * 16))
    r1 = [label(on_bg(g), "Grass G0 G1 G2 G3, 1:1"), label(on_bg(d), "Dirt / worn, 1:1"),
          label(on_bg(a), "Accents, 1:1"), label(on_bg(p), "Palette (25)")]
    r2 = [label(up(on_bg(g), 3), "Grass family x3", "G0/G1 calm fills; G2 blade clumps; G3 autumn (forest edge)"),
          label(up(on_bg(d), 3), "Dirt x3", "shaded base | worn centre"),
          label(up(on_bg(a), 3), "Accents x3", "clump, dry clump, clover, pebbles, leaves, mushrooms")]
    r3 = [label(up(on_bg(w), 3), "Grass/path dual-grid set x3 (16 keys NW NE SW SE, two verge variants)",
                "turf front face + its shadow on the path where grass is N/W; lit lip where S/E; worn centre 4 px in")]
    r4 = [label(patch.convert("RGB"), "Sample patch 1:1"), label(up(patch, 3).convert("RGB"), "Sample patch x3")]
    sheet("env001_source_terrain", "ENV-001 source: hand-composed 16 px terrain family (tools/env001_art.py)",
          [NONPROD, "Every piece is placed by hand coordinates; no generator, no filter. Colours are matched to the "
           "control's grass and path, so T changes texture, not the value key."], [r1, r2, r3, r4])
    # shadow masks over their sprites
    S = os.path.join(A, "shadows")
    meta = json.load(open(os.path.join(S, "shadows.json")))
    sprites = {"cabin": ("art/style_tests/ART-005/vs16p1/cabin/house_day.png", False),
               "oak": ("art/style_tests/ART-003/w3/oak/oak_w3.png", False),
               "well": ("art/farm/prop_well.png", False), "apple_b": ("art/style_tests/ART-003/w4/orchard/apple_b.png", False),
               "logpile_flip": ("art/style_tests/ART-003/w4/props/logpile.png", True)}
    cells = []
    for n, (path, flip) in sprites.items():
        m = Image.open(os.path.join(S, n + ".png")).convert("RGBA")
        spr = Image.open(os.path.join(ROOT, path)).convert("RGBA")
        if flip:
            spr = spr.transpose(Image.FLIP_LEFT_RIGHT)
        pl, pt = meta[n]["pad"]
        base = Image.new("RGBA", m.size, (84, 92, 42, 255))
        ma = np.asarray(m)[..., 3]
        arr = np.asarray(base).copy()
        arr[ma > 200, :3] = (arr[ma > 200, :3] * np.array([0.5, 0.52, 0.62])).astype(np.uint8)
        arr[(ma > 60) & (ma <= 200), :3] = (arr[(ma > 60) & (ma <= 200), :3] * np.array([0.64, 0.67, 0.78])).astype(np.uint8)
        base = Image.fromarray(arr)
        base.alpha_composite(spr, (pl, pt))
        k = 2 if n in ("cabin", "oak") else 4
        cells.append(label(up(base.convert("RGB"), k), f"{n} x{k}", meta[n]["note"][:60]))
    sheet("env001_source_shadows", "ENV-001 source: authored contact shadows (light from the upper left)",
          [NONPROD, "Darker step = contact (kept, weaker, at night); lighter step = sun cast (day only). Applied as a "
           "cool multiply of the ground's own pixels. Fence: projected in the harness from each rail sprite."],
          [cells[:2], cells[2:]])


def view_sheet(v):
    fr = {k: frame(f"{v}_noon_{k}") for k, _ in NOON}
    c = [label(fr[k], t, "1280x720 real 3x, 12:00, same camera and farmer") for k, t in NOON]
    vm = Image.new("RGB", (1280, 720), BG)
    vm.paste(value_map(fr["ctrl"]).resize((640, 360), Image.NEAREST), (0, 0))
    vm.paste(value_map(fr["all"]).resize((640, 360), Image.NEAREST), (640, 0))
    vm.paste(fr["ctrl"].crop((480, 260, 800, 460)).resize((640, 400), Image.NEAREST).crop((0, 0, 640, 360)), (0, 360))
    vm.paste(fr["all"].crop((480, 260, 800, 460)).resize((640, 400), Image.NEAREST).crop((0, 0, 640, 360)), (640, 360))
    c.append(label(vm, "Value maps (7 luma bands, half size): control | combined",
                   "below: centre 320x200 crop x2, control | combined"))
    sheet(f"env001_{v}", f"ENV-001 view {VIEWS[v]}: control, each study alone, combined (noon)", [NONPROD],
          [c[0:2], c[2:4], c[4:6]])


def night_sheet():
    rows = []
    for v in VIEWS:
        rows.append([label(frame(f"{v}_night_{k}").crop((240, 135, 1040, 585)), f"{v}: {t}", "800x450 centre crop, 1:1")
                     for k, t in NIGHT])
    sheet("env001_night", "ENV-001 night regression: R3-1 (21:30) control vs studies, same camera",
          [NONPROD, "R3-1 grade, tint, lights and lantern are untouched. D is a daytime key; the third column forces it "
           "at night to show what an albedo key would cost if it were baked into production tiles."], rows)


def overview_sheet():
    cells = []
    for tag, t in [("noon_ctrl", "Noon CONTROL"), ("noon_all", "Noon T+S+D"), ("night_ctrl", "R3-1 night CONTROL"),
                   ("night_ts", "R3-1 night T+S")]:
        m = Image.new("RGB", (2 * 1152 + 1280, 2 * 696 + 720))
        for i, x in enumerate([9, 33, 57]):
            for j, y in enumerate([5.5, 20, 34.5]):
                m.paste(frame(f"ov_{x}_{y}_{tag}"), (i * 1152, j * 696))
        cells.append(label(m.resize((m.width // 3, m.height // 3), Image.LANCZOS), t + " - DOWNSCALED 1/3",
                           "3x3 real 720p frames stitched, farmer hidden"))
    sheet("env001_overview", "ENV-001 whole W-4 homestead, stitched overview (DOWNSCALED; judge pixels in the 720p sheets)",
          [NONPROD], [cells[:2], cells[2:]])


def measure():
    out = {}
    for v in VIEWS:
        r = {}
        for k, _ in NOON:
            im = frame(f"{v}_noon_{k}")
            r[k] = {"mean_luma": round(float(luma(im).mean()), 1), "busy": round(busy(im), 4)}
        for k, _ in NIGHT:
            im = frame(f"{v}_night_{k}")
            r["night_" + k] = {"mean_luma": round(float(luma(im).mean()), 1), "busy": round(busy(im), 4)}
        out[v] = r
    with open(os.path.join(A, "measure.json"), "w") as f:
        json.dump(out, f, indent=1)
    print(json.dumps(out, indent=1))


if __name__ == "__main__":
    source_sheet()
    for v in VIEWS:
        view_sheet(v)
    night_sheet()
    overview_sheet()
    measure()
