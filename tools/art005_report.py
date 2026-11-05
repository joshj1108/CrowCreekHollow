# ART-005 E1 review package builder (non-production). Reads the captures that tools/art005_run.sh wrote to
# builds/review/ART-005/ and writes the sheets, GIFs, frame strips and measurements to
# art/style_tests/ART-005/review/. Measurements are printed and saved as e1_metrics.json.
#   python tools/art005_report.py
import csv
import glob
import json
import os
import shutil
import subprocess

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.path.join(HERE, "..", "builds", "review", "ART-005")
R = os.path.join(HERE, "..", "art", "style_tests", "ART-005", "review")
os.makedirs(R, exist_ok=True)
open(os.path.join(R, ".gdignore"), "w").close()

COLS = [("A16", "A  existing 16 px (W-3/W-4 art)"), ("A+", "A+  directed 16 px (RESERVED: no art yet)"),
        ("P32", "B  32 px PLACEHOLDER"), ("P64", "C  64 px PLACEHOLDER")]
CAM = (25.0, 12.5)     # the still camera centre in map tiles (vignette 15, 8.5 + offset 10, 4)
BG = (24, 22, 26)
FG = (236, 226, 206)
DIM = (170, 160, 150)
metrics = {}


def font(n):
    try:
        return ImageFont.truetype("arial.ttf", n)
    except OSError:
        return ImageFont.load_default(n)


F = {n: font(n) for n in (14, 16, 18, 22, 28)}


def load(p):
    return Image.open(p).convert("RGB")


def scale_of(tag, res_h):
    """Screen px per logical unit for a capture tag like P32_day_int (1 tile = 16 units)."""
    d = int(tag[1:3])
    if "_today" in tag:
        return 3.0 * res_h / 720.0
    n0 = round(16.875 * d)
    k = max(1, min((res_h * 16 // 9) // (30 * d), res_h // n0))
    if "_fill" in tag:
        k = max(1, round(res_h / n0))
    return d / 16.0 * k


def crop_world(img, tag, res_h, x0, y0, w, h):
    """A 1:1 crop of a still, for a box in vignette tiles."""
    s = scale_of(tag, res_h)
    cx, cy = img.width / 2, img.height / 2
    X0 = cx + ((x0 + 10) - CAM[0]) * 16 * s
    Y0 = cy + ((y0 + 4) - CAM[1]) * 16 * s
    return img.crop((int(round(X0)), int(round(Y0)), int(round(X0 + w * 16 * s)), int(round(Y0 + h * 16 * s))))


def header(draw, w, title, sub):
    draw.text((16, 12), title, fill=FG, font=F[28])
    draw.text((16, 50), sub, fill=DIM, font=F[16])


def reserved(w, h, text="A+  reserved for professionally directed 16 px art (E2). No art yet."):
    im = Image.new("RGB", (w, h), (40, 36, 44))
    d = ImageDraw.Draw(im)
    for i in range(-h, w, 40):
        d.line([i, 0, i + h, h], fill=(52, 48, 58), width=6)
    d.text((24, h // 2 - 12), text, fill=FG, font=F[22])
    return im


# ---------------------------------------------------------------------------------------------------------------
def sheet_density(hour):
    """Four columns at 1080p integer framing, shown at 50% (pixel detail is in the 1:1 crops sheet)."""
    tiles = []
    for key, label in COLS:
        if key == "A+":
            tiles.append((reserved(960, 540), label))
            continue
        im = load(f"{B}/stills/{key}_{hour}_int_1080p.png").resize((960, 540), Image.BOX)
        tiles.append((im, label))
    W, H = 2 * 960 + 48, 2 * (540 + 34) + 110
    out = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(out)
    header(d, W, f"ART-005 E1 — same scene, four columns, 1080p integer framing, {'12:00 day' if hour == 'day' else '21:30 night'}",
           "Tile = 64 screen px (A 480x270 x4, B 960x540 x2, C 1920x1080 x1). Shown at 50% here; see the 1:1 crops. "
           "B and C are size-correct engineering PLACEHOLDERS: judge framing, scale and light, not art quality.")
    for i, (im, label) in enumerate(tiles):
        x = 16 + (i % 2) * (960 + 16)
        y = 96 + (i // 2) * (540 + 34)
        d.text((x, y), label, fill=FG, font=F[18])
        out.paste(im, (x, y + 26))
    p = f"{R}/e1_density_{hour}_1080p.png"
    out.save(p)
    return p


REGIONS = [("house corner", 11.0, 3.5, 4, 5), ("oak crown edge", 6.0, 1.0, 4, 5),
           ("grass / path / soil", 4.0, 11.0, 4, 5), ("farmer + porch", 13.5, 9.0, 3, 5),
           ("garden bed", 22.0, 5.5, 4, 5)]


def sheet_crops(hour, res_h=1080):
    cols = []
    for key in ("A16", "P32", "P64"):
        for fr in ("int", "today"):
            cols.append((key, fr))
    cells = []
    for name, x0, y0, w, h in REGIONS:
        row = []
        for key, fr in cols:
            tag = f"{key}_{hour}_{fr}"
            im = load(f"{B}/stills/{tag}_{res_h}p.png")
            row.append(crop_world(im, tag, res_h, x0, y0, w, h))
        cells.append((name, row))
    colw = [max(r[1][i].width for r in cells) for i in range(len(cols))]
    rowh = [max(c.height for c in r[1]) for r in cells]
    W = 140 + sum(colw) + 12 * len(cols) + 16
    H = 130 + sum(rowh) + 14 * len(cells)
    out = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(out)
    header(d, W, f"ART-005 E1 — 1:1 screen-pixel crops at {res_h}p, {hour}: integer framing vs today's framing",
           "int: native render, integer scale (4x / 2x / 1x). today: drawn straight at the output, tile 72 px "
           "(16 px art at 4.5x, 32 at 2.25x, 64 at 1.125x: uneven pixel columns). B/C are PLACEHOLDERS.")
    x = 140
    for i, (key, fr) in enumerate(cols):
        lab = {"A16": "A 16", "P32": "B 32 ph", "P64": "C 64 ph"}[key] + ("  int" if fr == "int" else "  today")
        d.text((x, 92), lab, fill=FG, font=F[18])
        x += colw[i] + 12
    y = 122
    for (name, row), rh in zip(cells, rowh):
        d.text((12, y + 8), name, fill=DIM, font=F[16])
        x = 140
        for i, c in enumerate(row):
            out.paste(c, (x, y))
            x += colw[i] + 12
        y += rh + 14
    p = f"{R}/e1_crops_1to1_{hour}_{res_h}p.png"
    out.save(p)
    return p


def sheet_scaling():
    """The farmer and porch, 1:1, at every output size and framing, per density."""
    order = [(720, "int"), (720, "fill"), (720, "today"), (1080, "int"), (1080, "today"), (1440, "int"),
             (1440, "fill"), (1440, "today"), (2160, "int"), (2160, "today")]
    rows = []
    for key in ("A16", "P32", "P64"):
        row = []
        for rh, fr in order:
            tag = f"{key}_day_{fr}"
            im = load(f"{B}/stills/{tag}_{rh}p.png")
            row.append(crop_world(im, tag, rh, 14.0, 10.6, 2.0, 2.4))
        rows.append((key, row))
    colw = [max(r[1][i].width for r in rows) for i in range(len(order))]
    rowh = [max(c.height for c in r[1]) for r in rows]
    W = 110 + sum(colw) + 10 * len(order) + 10
    H = 160 + sum(rowh) + 12 * len(rows)
    out = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(out)
    header(d, W, "ART-005 E1 — scaling at 720p, 1080p, 1440p and 4K (1:1 screen px, the farmer on the porch path)",
           "Each cell is 2 x 2.4 tiles of the same world. Labels: art px -> screen px per art px. "
           "int = integer scale with borders; fill = integer scale chosen to fill (shows more or less world); today = baseline.")
    x = 110
    for i, (rh, fr) in enumerate(order):
        d.text((x, 92), f"{rh}p {fr}", fill=FG, font=F[16])
        x += colw[i] + 10
    y = 150
    for (key, row), rh_ in zip(rows, rowh):
        d.text((10, y + 6), {"A16": "A 16", "P32": "B 32 ph", "P64": "C 64 ph"}[key], fill=FG, font=F[18])
        x = 110
        for i, c in enumerate(row):
            out.paste(c, (x, y))
            rh, fr = order[i]
            s = scale_of(f"{key}_day_{fr}", rh) * 16 / int(key[1:3])
            d.text((x, y + c.height + 1), f"x{s:.3g}", fill=(246, 196, 90) if abs(s - round(s)) > 1e-6 else DIM,
                   font=F[14])
            x += colw[i] + 10
        y += rh_ + 12 + 14
    p = f"{R}/e1_scaling_matrix.png"
    out.save(p)
    return p


# ---------------------------------------------------------------------------------------------------------------
def runs_of(row_dark):
    runs, cur, n = [], row_dark[0], 0
    for v in row_dark:
        if v == cur:
            n += 1
        else:
            runs.append(n)
            cur, n = v, 1
    runs.append(n)
    return runs[1:-1]     # drop partial runs at the ends


def probe_metrics():
    """Run widths of the 1-texel checker (top half of the probe tile), per framing, size and density, over eight
    camera sub-pixel offsets. Integer scale: every run is k px and the pattern never changes shape."""
    out = {}
    for d in (16, 32, 64):
        for res in (720, 1080, 1440, 2160):
            for fr, cm in (("int", "smooth"), ("today", "smooth")):
                files = sorted(glob.glob(f"{B}/probe/P{d}_day_{fr}_{res}p_{cm}_probe_*.png"))
                if d == 64 and res == 720 and fr == "int":
                    # 64 px at 720p cannot scale down by a whole number: the native 1920x1080 is cropped to the
                    # middle 20 x 11.25 tiles, and the probe tile lies outside it
                    out[f"P{d}_{fr}_{res}p"] = {"note": "n/a: probe off screen (only 20 x 11.25 tiles visible)"}
                    continue
                if not files:
                    continue
                allw, shapes = [], set()
                for f in files:
                    a = np.asarray(load(f)).astype(float).mean(-1)
                    h = a.shape[0]
                    # rows in the upper-middle of the 1-texel checker half
                    rows = [a[int(h * q)] for q in (0.18, 0.25, 0.32)]
                    ws = []
                    for r in rows:
                        thr = (r.max() + r.min()) / 2
                        ws += runs_of(list(r[4:-4] < thr))
                    allw += ws
                    shapes.add(tuple(sorted(set(ws))))
                if not allw:
                    continue
                vals, cnt = np.unique(allw, return_counts=True)
                mode = vals[cnt.argmax()]
                out[f"P{d}_{fr}_{res}p"] = {"widths": {int(v): int(c) for v, c in zip(vals, cnt)},
                                           "uniform_share": round(float(cnt.max() / cnt.sum()), 3),
                                           "mode_px": int(mode), "distinct_width_sets_over_offsets": len(shapes)}
    metrics["probe"] = out
    return out


def sheet_probe():
    tiles = []
    for d in (16, 32, 64):
        for fr in ("int", "today"):
            for step in (0, 2, 4):
                f = f"{B}/probe/P{d}_day_{fr}_1080p_smooth_probe_{step}.png"
                if os.path.exists(f):
                    im = load(f)
                    tiles.append((f"{d} px {fr} cam+{step/8:.2f}u", im.resize((im.width * 2, im.height * 2), Image.NEAREST)))
    cw = max(t[1].width for t in tiles)
    chh = max(t[1].height for t in tiles)
    per = 6
    W = per * (cw + 12) + 24
    H = 110 + ((len(tiles) + per - 1) // per) * (chh + 36)
    out = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(out)
    header(d, W, "ART-005 E1 — pixel-clarity probe, 1080p, shown at 200%",
           "A 1-texel checker (top) and 2-texel checker (bottom), one tile, at three camera sub-pixel offsets. "
           "Integer framing keeps every texel the same size; today's framing changes texel widths as the camera moves.")
    for i, (lab, im) in enumerate(tiles):
        x = 12 + (i % per) * (cw + 12)
        y = 96 + (i // per) * (chh + 36)
        d.text((x, y), lab, fill=FG, font=F[14])
        out.paste(im, (x, y + 20))
    p = f"{R}/e1_probe_1080p.png"
    out.save(p)
    return p


# ---------------------------------------------------------------------------------------------------------------
def walk_metrics():
    out = {}
    for f in sorted(glob.glob(f"{B}/walk*/*.csv")):
        tag = os.path.basename(f)[:-4]
        if "_free_" in tag:
            continue      # free mode's screen positions are only computed from floats, not measured: left out
        rows = list(csv.DictReader(open(f)))
        if len(rows) < 3:
            continue
        wx = np.array([float(r["world_screen_x"]) for r in rows])
        px = np.array([float(r["player_screen_x"]) for r in rows])
        cam = np.array([float(r["cam_float_x"]) for r in rows])
        moving = np.abs(np.diff(cam)) > 1e-6
        step = -np.diff(wx)[moving]
        if step.size == 0:
            continue
        ideal = float(np.mean(step))
        dev = np.abs(step - ideal)
        out[tag] = {"frames": int(step.size), "mean_step_px": round(ideal, 3), "std_step_px": round(float(step.std()), 3),
                    "min_step_px": round(float(step.min()), 2), "max_step_px": round(float(step.max()), 2),
                    "frames_off_by_ge_1px": round(float((dev >= 0.999).mean()), 3),
                    "stall_frames": int((np.abs(step) < 1e-6).sum()),
                    "player_screen_jitter_px": round(float(px.max() - px.min()), 2)}
    metrics["walk"] = out
    return out


def compose_motion(tags, labels, name, n=100, title=""):
    """Side-by-side frames of several walk/swing captures -> a GIF (50 fps) and a 6-frame strip."""
    dirs = [f"{B}/{t}" for t in tags]
    if not all(os.path.isdir(x) for x in dirs):
        print("missing", [x for x in dirs if not os.path.isdir(x)])
        return None, None
    tmp = os.path.join(B, "_gif_" + name)
    shutil.rmtree(tmp, ignore_errors=True)
    os.makedirs(tmp)
    frames = []
    for i in range(n):
        ims = []
        for x in dirs:
            p = f"{x}/f_{i:04d}.png"
            if not os.path.exists(p):
                break
            ims.append(load(p))
        if len(ims) < len(dirs):
            break
        w, h = ims[0].size
        im = Image.new("RGB", (len(ims) * (w + 6) - 6, h + 24), BG)
        d = ImageDraw.Draw(im)
        for j, (a, lab) in enumerate(zip(ims, labels)):
            im.paste(a, (j * (w + 6), 24))
            d.text((j * (w + 6) + 4, 3), lab, fill=FG, font=F[16])
        im.save(f"{tmp}/{i:04d}.png")
        frames.append(im)
    gif = f"{R}/{name}.gif"
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-framerate", "50", "-i", f"{tmp}/%04d.png", "-vf",
                    "split[a][b];[a]palettegen=max_colors=64:stats_mode=full[p];[b][p]paletteuse=dither=none",
                    gif], check=True)
    pick = [0, 3, 6, 9, 12, 15]
    strip_imgs = [frames[i] for i in pick if i < len(frames)]
    W = strip_imgs[0].width
    H = sum(x.height + 8 for x in strip_imgs) + 70
    st = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(st)
    d.text((8, 8), title, fill=FG, font=F[18])
    d.text((8, 34), "Frames 0, 3, 6, 9, 12, 15 of the 50 fps clip (60 ms apart), 1:1 screen px.", fill=DIM, font=F[14])
    y = 60
    for x in strip_imgs:
        st.paste(x, (0, y))
        y += x.height + 8
    strip = f"{R}/{name}_frames.png"
    st.save(strip)
    shutil.rmtree(tmp, ignore_errors=True)
    return gif, strip


def swing_metrics():
    out = {}
    for x in sorted(glob.glob(f"{B}/swing/*")):
        if not os.path.isdir(x):
            continue
        fs = sorted(glob.glob(f"{x}/f_*.png"))
        prev, ch = None, []
        for f in fs:
            a = np.asarray(load(f)).astype(int)
            if prev is not None:
                ch.append(float((np.abs(a - prev).sum(-1) > 6).mean()))
            prev = a
        out[os.path.basename(x)] = {"mean_changed_px_share": round(float(np.mean(ch)), 4),
                                    "max_changed_px_share": round(float(np.max(ch)), 4)}
    metrics["swing"] = out
    return out


def step_chart(path):
    """World screen-x step per frame, A 16 px at 50 fps: snap vs smooth vs today, and at 144 Hz."""
    series = [("walk/A16_day_int_1080p_snap_walk50", "A16 int snap, 50 fps"),
              ("walk/A16_day_int_1080p_smooth_walk50", "A16 int smooth, 50 fps"),
              ("walk/A16_day_today_1080p_smooth_walk50", "A16 today (free), 50 fps"),
              ("walk144/P16_day_int_1080p_snap_walk144", "P16 int snap, 144 Hz"),
              ("walk144/P16_day_int_1080p_smooth_walk144", "P16 int smooth, 144 Hz")]
    W, H = 1400, 170 * len(series) + 90
    im = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(im)
    header(d, W, "ART-005 E1 — camera motion: on-screen step of the world per frame (px), 1080p",
           "A steady walk should give a flat line. Steps that alternate (e.g. 4, 8, 4, 8 or 0, 4, 0) read as judder.")
    for i, (key, lab) in enumerate(series):
        f = f"{B}/{key}.csv"
        if not os.path.exists(f):
            continue
        rows = list(csv.DictReader(open(f)))[:90]
        wx = np.array([float(r["world_screen_x"]) for r in rows])
        st = -np.diff(wx)
        y0 = 90 + i * 170
        d.text((10, y0), lab, fill=FG, font=F[16])
        top, bot = y0 + 26, y0 + 150
        mx = max(10.0, float(np.ceil(st.max())) if st.size else 10)
        for v in range(0, int(mx) + 1, 2):
            yy = bot - (v / mx) * (bot - top)
            d.line([60, yy, W - 20, yy], fill=(48, 46, 52))
            d.text((20, yy - 8), str(v), fill=DIM, font=F[14])
        pts = [(60 + j * (W - 90) / max(1, len(st) - 1), bot - (s / mx) * (bot - top)) for j, s in enumerate(st)]
        for a, b in zip(pts, pts[1:]):
            d.line([a, b], fill=(240, 160, 48), width=2)
        for p in pts:
            d.ellipse([p[0] - 2, p[1] - 2, p[0] + 2, p[1] + 2], fill=(246, 196, 90))
    im.save(path)
    return path


# ---------------------------------------------------------------------------------------------------------------
def perf_table():
    rows = []
    for f in sorted(glob.glob(f"{B}/perf/*_perf.json")):
        rows.append(json.load(open(f)))
    metrics["perf"] = rows
    return rows


def sheet_ui():
    """The HUD: on its own output-resolution canvas vs inside the native world render. 1:1 crops."""
    cases = [("A16_night_int_1080p_uiscreen", 1080, "A 16, HUD on screen canvas, 1080p"),
             ("A16_night_int_1080p_uiworld", 1080, "A 16, HUD inside the 480x270 world render"),
             ("P64_night_int_1080p_uiworld", 1080, "C 64 ph, HUD inside the 1920x1080 world render"),
             ("P32_night_int_2160p_uiscreen", 2160, "B 32 ph, HUD on screen canvas, 4K")]
    tiles = []
    for tag, rh, lab in cases:
        f = f"{B}/ui/{tag}.png"
        if not os.path.exists(f):
            continue
        im = load(f)
        w = im.width
        top = im.crop((0, 0, int(w * 0.42), int(rh * 0.09)))
        bar = im.crop((int(w * 0.28), int(rh * 0.86), int(w * 0.72), rh))
        if rh == 2160:
            top = top.crop((0, 0, top.width // 2, top.height))
            bar = bar.crop((0, 0, bar.width // 2, bar.height))
        tiles.append((lab, top, bar))
    W = max(1560, max(max(t[1].width, t[2].width) for t in tiles) + 32)
    H = 100 + sum(t[1].height + t[2].height + 50 for t in tiles)
    out = Image.new("RGB", (W, H), BG)
    d = ImageDraw.Draw(out)
    header(d, W, "ART-005 E1 — UI rendered apart from the pixel-art world (1:1 crops)",
           "Text and the production slot art on the output-resolution canvas stay crisp at any density; drawn inside the "
           "native world render they inherit its pixel size (blocky at 16 px) and the world's colour grade. 4K: left half only.")
    y = 96
    for lab, top, bar in tiles:
        d.text((16, y), lab, fill=FG, font=F[18])
        out.paste(top, (16, y + 24))
        out.paste(bar, (16, y + 30 + top.height))
        y += top.height + bar.height + 50
    p = f"{R}/e1_ui_separation.png"
    out.save(p)
    return p


def main():
    made = [sheet_ui()]
    for hour in ("day", "night"):
        made.append(sheet_density(hour))
        made.append(sheet_crops(hour))
    made.append(sheet_scaling())
    probe_metrics()
    made.append(sheet_probe())
    walk_metrics()
    swing_metrics()
    made.append(step_chart(f"{R}/e1_camera_steps.png"))
    motion = [
        (["walk/A16_day_int_1080p_smooth_walk50", "walk/P32_day_int_1080p_smooth_walk50", "walk/P64_day_int_1080p_smooth_walk50"],
         ["A 16 int smooth", "B 32 ph int smooth", "C 64 ph int smooth"], "e1_walk_day_int",
         "Day walk, 1080p integer framing, smooth camera (art-px snap + screen-px remainder)"),
        (["walk/A16_day_today_1080p_smooth_walk50", "walk/P32_day_today_1080p_smooth_walk50", "walk/P64_day_today_1080p_smooth_walk50"],
         ["A 16 today", "B 32 ph today", "C 64 ph today"], "e1_walk_day_today",
         "Day walk, 1080p, today's framing (baseline: non-integer scale, free camera)"),
        (["walk/A16_day_int_1080p_snap_walk50", "walk/A16_day_int_1080p_smooth_walk50", "walk/A16_day_today_1080p_smooth_walk50"],
         ["A 16 int snap", "A 16 int smooth", "A 16 today"], "e1_walk_camera_modes",
         "Camera modes on the existing 16 px art, 1080p: snap (4 px steps) vs smooth vs today"),
        (["walk/A16_night_int_1080p_smooth_walk50", "walk/P32_night_int_1080p_smooth_walk50", "walk/P64_night_int_1080p_smooth_walk50"],
         ["A 16 night", "B 32 ph night", "C 64 ph night"], "e1_walk_night_lantern",
         "Night walk with the lantern (smooth falloff, as LANTERN_SMOOTH), 1080p integer framing"),
        (["walk/A16_night_int_1080p_smooth_walk50", "walk/A16_night_int_1080p_smooth_walk50_stepped"],
         ["A 16 lantern smooth", "A 16 lantern stepped"], "e1_lantern_smooth_vs_stepped",
         "Lantern falloff while walking, A 16 px: smooth gradient vs LIGHTING_V2 stepped bands"),
        (["swing/A16_night_int_1080p_smooth_swing", "swing/P32_night_int_1080p_smooth_swing", "swing/P64_night_int_1080p_smooth_swing",
          "swing/A16_night_int_1080p_smooth_swing_stepped", "swing/P64_night_int_1080p_smooth_swing_stepped"],
         ["A16 smooth", "B32 smooth", "C64 smooth", "A16 stepped", "C64 stepped"], "e1_lantern_swing",
         "Standing still, lantern swinging, 1080p: the light pool per density, smooth vs stepped"),
    ]
    gifs = []
    for tags, labels, name, title in motion:
        g, s = compose_motion(tags, labels, name, title=title, n=80 if "swing" in name else 75)
        if g:
            gifs.append(g)
            made.append(s)
    perf_table()
    with open(f"{R}/e1_metrics.json", "w", newline="\n") as f:
        json.dump(metrics, f, indent=1)
    print("\n".join(os.path.relpath(m) for m in made + gifs))
    for k, v in metrics.get("walk", {}).items():
        print("walk", k, v)
    for k, v in metrics.get("probe", {}).items():
        print("probe", k, v)
    for k, v in metrics.get("swing", {}).items():
        print("swing", k, v)
    for r in metrics.get("perf", []):
        print("perf", r)


if __name__ == "__main__":
    main()
