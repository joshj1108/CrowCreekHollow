"""ART-005 VS16 (zero-generation, NON-PRODUCTION): builds the review sheets, GIF and measurements for the polished
16 px vertical slice from the frames tools/vs16_run.sh rendered in the clean export.

    python tools/vs16_cabin.py && bash tools/vs16_run.sh && python tools/vs16_review.py
Sheets -> art/style_tests/ART-005/vs16/review/ (the masters are made after, with tools/review_master.ps1).
"""
import glob
import json
import os
import subprocess

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
FR = os.path.join(ROOT, "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "vs16")
OUT = os.path.join(ROOT, "art", "style_tests", "ART-005", "vs16")
REV = os.path.join(OUT, "review")
F = ImageFont.load_default(size=16)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=22)
BG, FG, DIM, WARN, OK = (22, 20, 24), (236, 230, 220), (170, 164, 156), (255, 196, 110), (150, 220, 150)
# The cabin's world rect (HC2's, the same anchor): at the home still (camera centre 2520,888) it covers screen
# (697,-16)-(1273,464); pans map it through each frame's logged camera centre.
HOUSE_W = (697 + 2520 - 640, -16 + 888 - 360, 1273 + 2520 - 640, 464 + 888 - 360)
LAB = {"ctrl": ("CONTROL: C2 cabin (32 px source, 1.5 screen px per art px)", FG),
       "c16": ("VS16: proposed 16 px cabin (3 screen px per art px)", WARN),
       "c16s": ("VS16 + scene-style STUDY (warmer day grade, quieter grass, contact shadows)", OK)}
M = {"task": "ART-005 VS16", "status": "zero generation, NON-PRODUCTION prototype",
     "frames": "1280x720, the game's own camera, scale, grade and R3-1 night in the clean export; W-4 layout b, F2 fields"}


def load(name):
    return Image.open(os.path.join(FR, name)).convert("RGB")


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def label(im, text, sub="", col=FG):
    out = Image.new("RGB", (im.width, im.height + (40 if sub else 24)), BG)
    d = ImageDraw.Draw(out)
    d.text((2, 3), text, font=F, fill=col)
    if sub:
        d.text((2, 21), sub, font=FS, fill=DIM)
    out.paste(im.convert("RGB"), (0, out.height - im.height))
    return out


def sheet(name, title, notes, rows, gap=14, pad=16):
    w = max(sum(c.width for c in r) + gap * (len(r) - 1) for r in rows)
    head = 40 + 16 * len(notes)
    h = head + sum(max(c.height for c in r) + gap for r in rows)
    out = Image.new("RGB", (w + 2 * pad, h + pad), BG)
    d = ImageDraw.Draw(out)
    d.text((pad, 10), title, font=FB, fill=FG)
    for i, n in enumerate(notes):
        d.text((pad, 40 + i * 16), n, font=FS, fill=WARN if n.startswith("!") else DIM)
    y = head
    for r in rows:
        x = pad
        for c in r:
            out.paste(c, (x, y))
            x += c.width + gap
        y += max(c.height for c in r) + gap
    out.save(os.path.join(REV, name))
    print(name, out.size)


NONPROD = "! NON-PRODUCTION prototype, zero generation. Nothing in the game, its art, camera, lighting or saves was changed."


def on_bg(im, col=(74, 92, 48)):
    b = Image.new("RGBA", im.size, col + (255,))
    b.alpha_composite(im.convert("RGBA"))
    return b.convert("RGB")


def source_sheet():
    d = Image.open(os.path.join(OUT, "cabin", "house_day.png"))
    n = Image.open(os.path.join(OUT, "cabin", "house_night.png"))
    c2 = Image.open(os.path.join(ROOT, "art/style_tests/ART-005/pl/g7/c2/32/house_day.png"))
    pal = Image.open(os.path.join(OUT, "cabin", "palette.png"))
    cols = len({p for p in d.getdata() if p[3]})
    one = Image.new("RGB", (192 * 2 + 10, 160), BG)
    one.paste(on_bg(d), (0, 0))
    one.paste(on_bg(n, (24, 26, 44)), (202, 0))
    r1 = [label(one, "1:1 source, day | night (192x160, 12x10 tiles)", "%d colours by day" % cols, WARN),
          label(up(pal, 2), "draft palette ramps (x2)", "outline, logs, chink, shakes, ...")]
    r2 = [label(up(on_bg(d), 3), "VS16 16 px cabin, x3 (gameplay size, no grade)", "", WARN),
          label(up(on_bg(n, (24, 26, 44)), 3), "VS16 night variant, x3 (only the glass changes)", "", WARN),
          label(on_bg(c2).resize((576, 480), Image.NEAREST), "C2 reference (32 px) at the same world size", "x1.5, as the game shows it")]
    sheet("vs16_source.png", "ART-005 VS16 - restored 16 px farmhouse, source art",
          ["Composed for 16 px on C2's geometry: the same footprint, silhouette, chimney, 8 log courses, windows, door, lamp,",
           "footing and steps. Seven shake courses, rounded logs with chinking, real recesses, a lintel log, fieldstones.",
           "Ungraded sprite on a flat ground colour; the 720p sheets show it in the game's own camera and grade.", NONPROD],
          [r1, r2])


def pair_sheet(name, title, notes, pairs):
    rows = []
    for fa, va, fb, vb, sub in pairs:
        rows.append([label(load(fa), LAB[va][0], sub, LAB[va][1]), label(load(fb), LAB[vb][0], sub, LAB[vb][1])])
    sheet(name, title, notes, rows)


def crop_sheet():
    # The farmer beside the farmhouse, and the cabin by the golden oak and well, x2 crops of the 720p frames.
    rows = []
    for t, sub in (("day", "noon 12:00"), ("night", "21:30, R3-1 night")):
        row = []
        for v in ("ctrl", "c16"):
            im = load("door_%s_%s.png" % (v, t)).crop((400, 160, 880, 520))
            row.append(label(up(im, 2), LAB[v][0].split(":")[0] + " - farmer at the door, x2", sub, LAB[v][1]))
        rows.append(row)
    sheet("vs16_farmer_door.png", "ART-005 VS16 - the farmer beside the farmhouse, 720p crops x2",
          ["The same farmer spot (inner tile 45,13), the game's own camera. Crops of real 1280x720 frames, ENLARGED x2.",
           "Judge outline weight, value and pixel size of the farmer against each cabin.", NONPROD], rows)


def pans():
    ff = "ffmpeg"
    for p in glob.glob(os.path.join(os.environ.get("LOCALAPPDATA", ""), "Microsoft", "WinGet", "Packages", "*", "*", "bin", "ffmpeg.exe")):
        ff = p
    names = ["pan_ctrl", "pan_c16", "pan_c16s"]
    files = {n: sorted(glob.glob(os.path.join(FR, n, "f*.png"))) for n in names}
    cams = {n: [tuple(map(float, l.split()[1:])) for l in open(os.path.join(FR, n, "pan_cam.txt")) if l.strip()] for n in names}
    nfr = min(len(v) for v in files.values())
    res = {}
    keep = {}
    for n in names:
        fa, cam = files[n], cams[n]
        off = len(fa) - len(cam)
        prev, out = None, []
        for i in range(nfr):
            a = np.asarray(Image.open(fa[i]).convert("RGB"), dtype=np.int16)
            if prev is None or i - off < 0:
                prev = a
                continue
            ref = a[100:620, 140:1140]
            best, bs = None, (0, 0)
            for dx in range(-7, 8):
                for dy in range(-7, 8):
                    e = np.abs(prev[100 + dy:620 + dy, 140 + dx:1140 + dx] - ref).mean()
                    if best is None or e < best:
                        best, bs = e, (dx, dy)
            pa, prev = prev, a
            if bs == (0, 0):
                continue
            dx, dy = bs
            diff = np.abs(pa[100 + dy:620 + dy, 140 + dx:1140 + dx] - ref).sum(axis=2) > 24
            diff[200:330, 440:560] = False
            if float(diff.mean()) > 0.12:
                continue
            c = cam[i - off]
            box = (int(round(HOUSE_W[0] - c[0] + 640)), int(round(HOUSE_W[1] - c[1] + 360)),
                   int(round(HOUSE_W[2] - c[0] + 640)), int(round(HOUSE_W[3] - c[1] + 360)))
            r = [max(0, box[0] - 134), max(0, box[1] - 94), min(1000, box[2] - 146), min(520, box[3] - 106)]
            if r[2] - r[0] < 30 or r[3] - r[1] < 30:
                continue
            m = np.zeros(diff.shape, bool)
            m[r[1]:r[3], r[0]:r[2]] = True
            m[200:330, 440:560] = False
            out.append({"i": i, "shift": bs, "box": box, "sprite": float(diff[m].mean()), "rest": float(diff[~m].mean())})
        keep[n] = out
        if out:
            res[n] = {"pairs": len(out), "cabin_changed_share_mean": round(float(np.mean([o["sprite"] for o in out])), 4),
                      "rest_changed_share_mean": round(float(np.mean([o["rest"] for o in out])), 4)}
    M["pan_instability"] = {"method": "HC2's: 30 fps diagonal walk (4.24 px steps), consecutive frames aligned by the best "
                            "whole-pixel shift; share of pixels still different (sum |dRGB| > 24) inside the cabin rect vs "
                            "the rest; farmer masked", "pans": res}
    print(json.dumps(res, indent=1))
    ra = keep["pan_ctrl"]
    if not ra:
        return
    boxes = [o["box"] for o in ra]
    cx = int(np.mean([(b[0] + b[2]) / 2 for b in boxes]))
    cy = int(np.mean([(b[1] + b[3]) / 2 for b in boxes]))
    W, H = 400, 300
    x0, y0 = max(0, min(1280 - W, cx - W // 2)), max(0, min(720 - H, cy - H // 2 + 60))
    tmp = os.path.join(FR, "gif")
    os.makedirs(tmp, exist_ok=True)
    for f in glob.glob(os.path.join(tmp, "*.png")):
        os.remove(f)
    i0, i1 = ra[0]["i"], ra[-1]["i"]
    for j, i in enumerate(range(max(0, i0 - 3), min(nfr, i1 + 4))):
        fr = Image.new("RGB", (W * 3 + 24, H + 22), BG)
        d = ImageDraw.Draw(fr)
        for k, n in enumerate(names):
            d.text((k * (W + 12) + 2, 3), ("C2 control", "VS16 cabin", "VS16 + style")[k], font=FS,
                   fill=(FG, WARN, OK)[k])
            fr.paste(Image.open(files[n][i]).convert("RGB").crop((x0, y0, x0 + W, y0 + H)), (k * (W + 12), 22))
        fr.save(os.path.join(tmp, "g%04d.png" % j))
    gif = os.path.join(REV, "vs16_pan.gif")
    subprocess.run([ff, "-y", "-loglevel", "error", "-framerate", "30", "-i", os.path.join(tmp, "g%04d.png"),
                    "-vf", "split[a][b];[a]palettegen=max_colors=255:stats_mode=full[p];[b][p]paletteuse=dither=none", gif],
                   check=True)
    print("vs16_pan.gif")
    # Frame strip: four consecutive frames, a world-locked window on the door and right window, x3.
    byi = {n: {o["i"]: o for o in keep[n]} for n in names}
    mid = ra[len(ra) // 2]["i"]
    rows = []
    for k, n in enumerate(names):
        row = []
        for i in range(mid, mid + 6):
            if i not in byi["pan_ctrl"] or len(row) == 4:
                continue
            b = byi["pan_ctrl"][i]["box"]
            win = (b[0] + 230, b[1] + 290, b[0] + 470, b[1] + 470)
            row.append(label(up(Image.open(files[n][i]).convert("RGB").crop(win), 2),
                             "%s, frame %d" % (("C2 control", "VS16 cabin", "VS16 + style")[k], i), "", (FG, WARN, OK)[k]))
        rows.append(row)
    s = res
    sheet("vs16_pan_frames.png", "ART-005 VS16 - diagonal camera pan past the cabin: consecutive frames, world-locked, x2",
          ["30 fps, 4.24 px camera steps (HC2's walk). Each cell: the same world window (door and east window) in consecutive real frames, x2.",
           "Changed share after whole-pixel alignment (shimmer), cabin | rest: " + "; ".join(
               "%s %.1f%% | %.1f%%" % (k, 100 * v["cabin_changed_share_mean"], 100 * v["rest_changed_share_mean"]) for k, v in s.items()),
           NONPROD], rows)


def main():
    os.makedirs(REV, exist_ok=True)
    source_sheet()
    pair_sheet("vs16_noon.png", "ART-005 VS16 - C2 vs the 16 px cabin at real 720p, noon (1:1)",
               ["The game's own camera on the farmer: home (inner tile 38.5,10.5: cabin, golden oak, well, farmer) and door (45,13).",
                "Same frame, same farmer spot; only the cabin sprite differs. 1280x720 frames at 1:1.", NONPROD],
               [("home_ctrl_day.png", "ctrl", "home_c16_day.png", "c16", "home, noon 12:00"),
                ("door_ctrl_day.png", "ctrl", "door_c16_day.png", "c16", "door, noon 12:00")])
    pair_sheet("vs16_night.png", "ART-005 VS16 - C2 vs the 16 px cabin at real 720p, R3-1 night 21:30 (1:1)",
               ["The locked R3-1 night (lantern tier 1). Same framings as the noon sheet. Only the cabin sprite differs.", NONPROD],
               [("home_ctrl_night.png", "ctrl", "home_c16_night.png", "c16", "home, 21:30 R3-1"),
                ("door_ctrl_night.png", "ctrl", "door_c16_night.png", "c16", "door, 21:30 R3-1")])
    pair_sheet("vs16_style.png", "ART-005 VS16 - scene-style study, controlled before/after (1:1, 720p)",
               ["Both sides carry the 16 px cabin; the right adds the reversible STYLE STUDY (harness only): day grade exposure 0.84->0.90,",
                "warmth 0.02->0.045, vignette 0.55->0.42; grass 3x3 majority filter once (existing colours only); hard pixel contact shadows.",
                "Night: grade, tint and lights untouched (R3-1); only the grass and the fainter shadows differ.", NONPROD],
               [("home_c16_day.png", "c16", "home_c16s_day.png", "c16s", "home, noon"),
                ("fields_c16_day.png", "c16", "fields_c16s_day.png", "c16s", "F2 fields (51.5,24.3), noon"),
                ("home_c16_night.png", "c16", "home_c16s_night.png", "c16s", "home, 21:30 R3-1")])
    crop_sheet()
    pans()
    with open(os.path.join(OUT, "measure.json"), "w") as f:
        json.dump(M, f, indent=1)


if __name__ == "__main__":
    main()
