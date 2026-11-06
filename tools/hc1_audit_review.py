# ART-005 HC1 Step 1 (audit only): builds the review panels and measurements from the frames that
# tools/hc1_audit_run.sh rendered in the clean export (builds/review/ART-005/p1_export/builds/review/ART-005/hc1/).
# Writes art/style_tests/ART-005/hc1/review/ (panels, the stitched overviews, the pan GIF) and
# art/style_tests/ART-005/hc1/measure.json. Nothing in the game or its art is read for writing or changed.
#   python tools/hc1_audit_review.py
import glob
import json
import os
import subprocess

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
FR = os.path.join(ROOT, "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "hc1")
OUT = os.path.join(ROOT, "art", "style_tests", "ART-005", "hc1")
REV = os.path.join(OUT, "review")
FRAMES = os.path.join(REV, "frames")
BLUE = os.path.join(ROOT, "art", "style_tests", "ART-003", "wide", "blueprint_wide_v1b_w3b.txt")
BG, FG, DIM, ACC = (28, 30, 34), (232, 232, 228), (170, 172, 176), (255, 200, 60)
F = ImageFont.load_default(size=16)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=22)
PX = 48                       # one logical tile at 720p (16 art px x 3)
VIEWS = {"north": (38, 13.5), "cross": (33, 18), "fields": (51.5, 24.3), "door": (45, 13),
         "orchard": (14.5, 22.5), "pond": (14, 31), "road": (36, 33.5), "gate": (56, 34)}
NAMES = {"north": "2. farmhouse, golden oak, well", "cross": "6. main paths and crossroads",
         "fields": "3. four compact F2 fields", "door": "9. farmer beside the farmhouse door",
         "orchard": "4. orchard and fruit trees", "pond": "5. pond and dock",
         "road": "7. road approaching the property", "gate": "8. closed entrance gate"}
OV_X, OV_Y = (9, 33, 57), (5.5, 20, 34.5)
HOUSE = (1896, 129, 2472, 609)          # the C2 sprite's world rect (inner px), from art003_wide.gd's g6 placement
ROOF = (1896, 129, 2472, 369)           # its roof part (to the top log)
DAY = "noon 12:00"
NIGHT = "night 21:30, R3-1 (locked ART-003 prototype night), lantern tier 1"
M = {}


def load(name):
    return Image.open(os.path.join(FR, name)).convert("RGB")


def luma(im):
    a = np.asarray(im.convert("RGB"), dtype=np.float32) / 255.0
    lin = np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
    y = lin @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
    return np.where(y <= 0.0031308, y * 12.92, 1.055 * y ** (1 / 2.4) - 0.055) * 255.0   # sRGB-encoded luma, 0-255


def grid(name, title, note, cells, cols, cap=26):
    w = max(im.width for _, im in cells)
    h = max(im.height for _, im in cells)
    gap, pad, head = 12, 16, 74
    rows = (len(cells) + cols - 1) // cols
    out = Image.new("RGB", (pad * 2 + cols * w + (cols - 1) * gap, head + rows * (cap + h + gap) + pad), BG)
    d = ImageDraw.Draw(out)
    d.text((pad, 12), title, font=FB, fill=FG)
    for i, line in enumerate(note.split("\n")[:2]):
        d.text((pad, 42 + i * 15), line, font=FS, fill=DIM)
    for i, (c, im) in enumerate(cells):
        x = pad + (i % cols) * (w + gap)
        y = head + (i // cols) * (cap + h + gap)
        for j, line in enumerate(c.split("\n")):
            d.text((x, y + 4 + j * 15), line, font=F if j == 0 else FS, fill=FG if j == 0 else DIM)
        out.paste(im.convert("RGB"), (x, y + cap))
    out.save(os.path.join(REV, name))
    print(name, out.size)
    return out


def ccrop(im, w, h, cx=None, cy=None):
    cx = im.width // 2 if cx is None else cx
    cy = im.height // 2 if cy is None else cy
    return im.crop((cx - w // 2, cy - h // 2, cx - w // 2 + w, cy - h // 2 + h))


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


# --- 1. the stitched overview -------------------------------------------------------------------------------------

def mosaic(hr):
    x0, y0 = OV_X[0] * PX - 640, OV_Y[0] * PX - 360
    W, H = int(OV_X[-1] * PX + 640 - x0), int(OV_Y[-1] * PX + 360 - y0)
    out = Image.new("RGB", (W, H))
    for x in OV_X:
        for y in OV_Y:
            im = load("ov_%s_%s_%s.png" % (x, y if y != int(y) else int(y), hr))
            out.paste(im, (int(x * PX - 640 - x0), int(y * PX - 360 - y0)))
    return out, (x0, y0)


def overview():
    res = {}
    for hr in ("day", "night"):
        im, org = mosaic(hr)
        im.save(os.path.join(REV, "hc1_overview_%s_fullres.png" % hr))
        res[hr] = (im, org)
    org = res["day"][1]
    cells = []
    for hr, lab in (("day", DAY), ("night", "night 21:30, R3-1, no lantern (farmer hidden)")):
        im = res[hr][0].copy()
        d = ImageDraw.Draw(im)
        for k, (vx, vy) in VIEWS.items():
            r = (vx * PX - 640 - org[0], vy * PX - 360 - org[1])
            d.rectangle((r[0], r[1], r[0] + 1279, r[1] + 719), outline=ACC, width=4)
            d.text((r[0] + 10, r[1] + 8), NAMES[k].split(".")[0], font=ImageFont.load_default(size=40), fill=ACC)
        cells.append(("1. full homestead overview - " + lab,
                      im.resize((im.width // 2, im.height // 2), Image.LANCZOS)))
    grid("hc1_overview.png", "HC1 Step 1 - 1. whole homestead (W-4 + F2 + C2), stitched from nine real 720p frames",
         "Each tile is a real 1280x720 gameplay frame (game camera, tile = 48 px), farmer hidden, stitched edge to edge and "
         "shown here at 50% (DOWNSCALED, not gameplay scale; full-res file beside it).\nYellow boxes = the eight 720p "
         "location views. Night: no lantern. Faint darker bands at frame joins are each frame's own grade vignette, not art.",
         cells, 1)
    return res


# --- 2. locations, day | night, 1:1 -------------------------------------------------------------------------------

def locations():
    for sheet, keys in (("hc1_locations_a.png", ("north", "cross", "fields", "door")),
                        ("hc1_locations_b.png", ("orchard", "pond", "road", "gate"))):
        cells = []
        for k in keys:
            for hr, lab in (("day", DAY), ("night", "night 21:30 R3-1, lantern")):
                cells.append((NAMES[k] + " - " + lab, ccrop(load("%s_%s.png" % (k, hr)), 800, 450)))
        grid(sheet, "HC1 Step 1 - locations at ACTUAL 720p gameplay scale (1:1 pixels), noon | R3-1 night",
             "Centre 800x450 crop of each real 1280x720 frame (the full frames are in review/frames/). Game camera on the "
             "farmer; tile = 48 px; one 16 px art px = 3 screen px, the C2 cabin's = 1.5.\ntools/hc1_audit.gd mode=wide "
             "layout=b grass=1 art=f2 house=g7:c2, clean export of HEAD (no VIS-002 change).", cells, 2)


def fhd():
    cells = []
    for k, hr, lab in (("north", "day", "noon"), ("north", "night", "night R3-1"), ("door", "day", "noon")):
        for f, fl in (("today", "game's own stretch: 1.5x, art px = 4.5 screen px (NON-integer)"),
                      ("int", "harness integer framing: art px = 4 px, cabin px = 2 px")):
            im = load("%s_%s_fhd_%s.png" % (k, hr, f))
            cells.append(("%s, 1080p, %s\n%s" % (NAMES[k], lab, fl), ccrop(im, 900, 520)))
    grid("hc1_1080p.png", "HC1 Step 1 - 1080p views (1:1 crops of 1920x1080 frames)",
         "Left: what a 1080p player sees today (canvas_items stretch of the 1280x720 view, so pixels are 4 or 5 px wide). "
         "Right: an integer 4/3 harness framing (tile 64 px)\nfor comparison only - NOT a camera proposal. Same scene, hour "
         "and lights.", cells, 2, cap=40)


# --- 3. values ------------------------------------------------------------------------------------------------------

def blueprint():
    return [l.rstrip("\n") for l in open(BLUE) if l.strip()]


def region_stats(im, org):
    """Mean and spread of luma, and texture energy, per blueprint code, on a stitched overview (inner px coords)."""
    y = luma(im)
    lap = np.abs(4 * y[1:-1, 1:-1] - y[:-2, 1:-1] - y[2:, 1:-1] - y[1:-1, :-2] - y[1:-1, 2:])
    lap = np.pad(lap, 1)
    g = blueprint()
    groups = {"grass": ".", "path/road": "P", "water": "~", "fields": "S", "forest": "T", "fence": "X"}
    out = {}
    for name, codes in groups.items():
        vals, tex = [], []
        for ty, row in enumerate(g):
            for tx, c in enumerate(row):
                if c in codes:
                    sx, sy = int(tx * PX - org[0]), int(ty * PX - org[1])
                    if 0 <= sx and sx + PX <= im.width and 0 <= sy and sy + PX <= im.height:
                        vals.append(y[sy:sy + PX, sx:sx + PX].ravel())
                        tex.append(lap[sy:sy + PX, sx:sx + PX].mean())
        if vals:
            v = np.concatenate(vals)
            out[name] = {"mean": round(float(v.mean()), 1), "p10": round(float(np.percentile(v, 10)), 1),
                         "p90": round(float(np.percentile(v, 90)), 1), "texture": round(float(np.mean(tex)), 1),
                         "tiles": len(vals)}
    for name, r in (("cabin roof", ROOF), ("cabin (whole sprite rect)", HOUSE)):
        sl = (slice(int(r[1] - org[1]), int(r[3] - org[1])), slice(int(r[0] - org[0]), int(r[2] - org[0])))
        v = y[sl]
        out[name] = {"mean": round(float(v.mean()), 1), "p10": round(float(np.percentile(v, 10)), 1),
                     "p90": round(float(np.percentile(v, 90)), 1), "texture": round(float(lap[sl].mean()), 1)}
    return out


def oak_rect():
    g = blueprint()
    xs = [x for y, r in enumerate(g) for x, c in enumerate(r) if c == "B"]
    ys = [y for y, r in enumerate(g) for x, c in enumerate(r) if c == "B"]
    cx, by = (min(xs) + max(xs) + 1) / 2.0, max(ys) + 1
    return (int((cx - 6) * PX), int((by - 11) * PX), int((cx + 6) * PX), int((by + 0.5) * PX))   # 576 px oak sprite


def values(ov):
    y_cells, stats = [], {}
    bands = [0, 40, 70, 100, 135, 175, 256]
    pal = [(10, 10, 40), (60, 40, 110), (60, 110, 160), (90, 170, 120), (220, 200, 80), (255, 245, 230)]
    for hr in ("day", "night"):
        im, org = ov[hr]
        y = luma(im)
        stats[hr] = region_stats(im, org)
        r = oak_rect()
        sl = (slice(r[1] - int(org[1]), r[3] - int(org[1])), slice(r[0] - int(org[0]), r[2] - int(org[0])))
        stats[hr]["golden oak (sprite rect)"] = {"mean": round(float(y[sl].mean()), 1),
                                                 "p90": round(float(np.percentile(y[sl], 90)), 1)}
        g = Image.fromarray(np.clip(y, 0, 255).astype(np.uint8)).convert("RGB")
        idx = np.digitize(y, bands[1:-1])
        post = Image.fromarray(np.array(pal, dtype=np.uint8)[idx])
        half = lambda i: i.resize((i.width * 2 // 5, i.height * 2 // 5), Image.LANCZOS)
        y_cells.append(("grey value - %s" % ("noon" if hr == "day" else "R3-1 night, no lantern"), half(g)))
        y_cells.append(("6-band value key - %s" % ("noon" if hr == "day" else "R3-1 night"), half(post)))
        # Where the eye goes: a coarse map of local contrast (texture noise) and luma extremes.
        if hr == "day":
            lap = np.abs(4 * y[1:-1, 1:-1] - y[:-2, 1:-1] - y[2:, 1:-1] - y[1:-1, :-2] - y[1:-1, 2:])
            lap = np.pad(lap, 1)
            k = 24
            hh, ww = lap.shape[0] // k, lap.shape[1] // k
            blk = lap[:hh * k, :ww * k].reshape(hh, k, ww, k).mean(axis=(1, 3))
            blk = np.clip(blk / np.percentile(blk, 98) * 255, 0, 255).astype(np.uint8)
            heat = Image.fromarray(blk).resize((ww * k, hh * k), Image.NEAREST)
            y_cells.append(("texture-noise map - noon (block mean |Laplacian|, bright = busy)",
                            half(Image.merge("RGB", (heat, heat.point(lambda v: v * 0.6), Image.new("L", heat.size, 30))))))
    legend = Image.new("RGB", y_cells[0][1].size, BG)
    d = ImageDraw.Draw(legend)
    d.text((20, 20), "6-band value key (sRGB luma, 0-255):", font=FB, fill=FG)
    for i, c in enumerate(pal):
        d.rectangle((20, 60 + i * 44, 80, 96 + i * 44), fill=c)
        d.text((95, 68 + i * 44), "%d-%d" % (bands[i], bands[i + 1] - 1), font=FB, fill=FG)
    d.text((20, 340), "Region means are in measure.json", font=F, fill=DIM)
    d.text((20, 362), "(per blueprint code, roof and oak rects).", font=F, fill=DIM)
    y_cells.append(("legend", legend))
    grid("hc1_values.png", "HC1 Step 1 - 4. scene value maps of the stitched overview (DOWNSCALED to 40%)",
         "Grey = Rec.709 luma of the real rendered frames, no art or lighting change. The 6-band key shows the value "
         "masses; the noise map shows where high-frequency texture sits.\nRegion numbers: measure.json -> values.", y_cells, 2)
    M["values"] = stats


# --- 5. pixel density ------------------------------------------------------------------------------------------------

def runs(img, rect):
    # A run ends where the next pixel differs by more than the colour grade's film grain (sum |dRGB| > 15; the
    # grain moves flat colours by about 3-5 per channel), so a run is one art pixel, or several alike ones in a row.
    a = np.asarray(img.convert("RGB"), dtype=np.int32)[rect[1]:rect[3], rect[0]:rect[2]]
    step = np.abs(np.diff(a, axis=1)).sum(axis=2) > 15
    hist = {}
    for srow in step:
        edges = np.flatnonzero(srow) + 1
        lens = np.diff(np.concatenate(([0], edges, [len(srow) + 1])))[1:-1]   # drop the cut-off runs at both ends
        for L in lens:
            hist[int(L)] = hist.get(int(L), 0) + 1
    return hist


def density():
    im = load("door_day.png")
    # screen rects in the door frame (camera on 45,13): cabin wall logs, oak canopy, grass east of the cabin, farmer
    cam = (45 * PX - 640, 13 * PX - 360)
    house = (HOUSE[0] - cam[0] + 20, 110, HOUSE[2] - cam[0] - 20, 280)
    rects = {"C2 cabin walls (32 px art at 0.5x)": house, "golden oak canopy (16 px art)": (0, 0, 260, 200),
             "grass east of the cabin (16 px)": (960, 330, 1270, 560), "farmer (16 px)": (612, 280, 668, 380)}
    hists = {k: runs(im, r) for k, r in rects.items()}
    fhd_im = load("north_day_fhd_today.png")
    M["pixel_runs_1080p_today"] = {}
    for k, r in (("C2 cabin walls", (1100, 200, 1900, 400)), ("golden oak canopy", (100, 20, 600, 250))):
        h = runs(fhd_im, r)
        tot = sum(h.values())
        M["pixel_runs_1080p_today"][k] = {"runs": tot, "top": sorted(h.items(), key=lambda kv: -kv[1])[:6]}
    summ = {}
    for k, h in hists.items():
        tot = sum(h.values())
        m3 = sum(v for L, v in h.items() if L % 3 == 0)
        short = sum(v for L, v in h.items() if L <= 2)
        summ[k] = {"runs": tot, "multiple_of_3": round(m3 / tot, 3), "length_1_or_2": round(short / tot, 3),
                   "top": sorted(h.items(), key=lambda kv: -kv[1])[:6]}
    M["pixel_runs_720p"] = summ
    # Panel: enlarged crops (4x) of matching areas, and the run-length bars.
    crops = [("C2 cabin: window + logs, 720p x4 (ENLARGED)", im.crop((470, 160, 570, 235))),
             ("C2 cabin: corner + foundation, x4", im.crop((380, 220, 480, 295))),
             ("golden oak: canopy edge, x4", im.crop((150, 100, 250, 175))),
             ("well + tub, x4", im.crop((255, 410, 355, 485))),
             ("farmer at the door step, x4", im.crop((590, 270, 690, 345))),
             ("cabin step | farmer | grass, x4", im.crop((640, 290, 740, 365)))]
    cells = [(c, up(x, 4)) for c, x in crops]
    bars = Image.new("RGB", (400, 300), BG)
    for i, (k, s) in enumerate(summ.items()):
        pass
    # bar chart: share of runs of length 1..6 per region
    chart = Image.new("RGB", (1224, 300), BG)
    d = ImageDraw.Draw(chart)
    cols = [(220, 120, 80), (240, 190, 70), (110, 170, 110), (120, 150, 220)]
    d.text((10, 6), "Horizontal same-colour run lengths at 720p (share of runs). 16 px art at 3x -> runs of 3, 6, 9...;",
           font=F, fill=FG)
    d.text((10, 26), "cabin (32 px art at 1.5 px) -> runs of 1, 2, 3: half-size pixels. Bar height = share of runs (full = 100%).",
           font=F, fill=FG)
    for j, (k, h) in enumerate(hists.items()):
        tot = sum(h.values())
        for L in range(1, 10):
            v = h.get(L, 0) / tot
            x = 40 + (L - 1) * 130 + j * 28
            d.rectangle((x, 270 - int(v * 190), x + 24, 270), fill=cols[j])
        d.rectangle((40 + j * 300, 56, 54 + j * 300, 70), fill=cols[j])
        d.text((60 + j * 300, 55), k, font=FS, fill=FG)
    for L in range(1, 10):
        d.text((40 + (L - 1) * 130 + 40, 276), "run %d" % L, font=FS, fill=DIM)
    cells_w = max(c[1].width for c in cells)
    grid("hc1_density.png", "HC1 Step 1 - 2. pixel-density consistency at 720p (crops ENLARGED 4x, nearest)",
         "From the real 720p noon frame at the door. Every crop is 100x75 screen px -> 400x300. The cabin's art pixels "
         "(and its 1-px outline) are 1.5 screen px - drawn as alternating 1- and 2-px columns -\nagainst 3-px pixels on "
         "the oak, well, grass and farmer. Measured run lengths: measure.json -> pixel_runs_720p.", cells, 3)
    ch = Image.open(os.path.join(REV, "hc1_density.png"))
    out = Image.new("RGB", (max(ch.width, chart.width + 32), ch.height + chart.height + 16), BG)
    out.paste(ch, (0, 0))
    out.paste(chart, (16, ch.height))
    out.save(os.path.join(REV, "hc1_density.png"))


def outlines():
    """Edge colour of each sprite's silhouette (opaque pixels touching transparency), from the source files."""
    S = {"C2 cabin (32 px)": "art/style_tests/ART-005/pl/g7/c2/32/house_day.png",
         "golden oak (16 px)": "art/style_tests/ART-003/w3/oak/oak_w3.png",
         "well (16 px)": "art/farm/prop_well.png",
         "apple tree (16 px)": "art/style_tests/ART-003/w4/orchard/apple_a.png",
         "gatepost (16 px)": "art/style_tests/ART-003/w4/gate/gatepost.png",
         "log pile (16 px)": "art/style_tests/ART-003/w4/props/logpile.png",
         "farmer idle (16 px)": "art/player/farmer_idle.png"}
    res = {}
    for k, p in S.items():
        fp = os.path.join(ROOT, p)
        if not os.path.exists(fp):
            continue
        a = np.asarray(Image.open(fp).convert("RGBA"), dtype=np.int32)
        op = a[..., 3] > 128
        pad = np.pad(op, 1)
        edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
        c = a[edge][:, :3]
        lum = c @ np.array([0.2126, 0.7152, 0.0722])
        res[k] = {"size": [int(a.shape[1]), int(a.shape[0])], "edge_px": int(edge.sum()),
                  "edge_mean_rgb": [int(v) for v in c.mean(axis=0)], "edge_median_luma": round(float(np.median(lum)), 1),
                  "edge_share_luma_below_40": round(float((lum < 40).mean()), 3),
                  "colours": int(len(np.unique((a[op][:, 0] << 16) | (a[op][:, 1] << 8) | a[op][:, 2])))}
    M["outlines_source"] = res


# --- pans: shimmer ------------------------------------------------------------------------------------------------

PANS = {"pan": "straight west, 30 fps (camera steps exactly 6.0 px)",
        "pan_diag": "diagonal north-west, 30 fps (4.24 px steps)",
        "pan_hz144": "straight west, 144 fps (1.25 px steps)"}
HOUSE_W = (HOUSE[0] + 14 * PX, HOUSE[1] + 8 * PX, HOUSE[2] + 14 * PX, HOUSE[3] + 8 * PX)   # map px (with the border)


def pan_one(name):
    files = sorted(glob.glob(os.path.join(FR, name, "f*.png")))
    cam = [tuple(map(float, l.split()[1:])) for l in open(os.path.join(FR, name, "pan_cam.txt")) if l.strip()]
    off = len(files) - len(cam)            # the movie has a few frames before the first logged process frame
    frames = [np.asarray(Image.open(p).convert("RGB"), dtype=np.int16) for p in files]
    res = []
    for i in range(max(1, off + 1), len(frames)):
        a, b = frames[i - 1], frames[i]
        ref = b[100:620, 140:1140]
        best, bs = None, (0, 0)
        j = i - off
        pdx = int(round(cam[j][0] - cam[j - 1][0])) if j >= 1 else 0
        pdy = int(round(cam[j][1] - cam[j - 1][1])) if j >= 1 else 0
        for dx in range(pdx - 1, pdx + 2):
            for dy in range(pdy - 1, pdy + 2):
                e = np.abs(a[100 + dy:620 + dy, 140 + dx:1140 + dx] - ref).mean()
                if best is None or e < best:
                    best, bs = e, (dx, dy)
        if bs == (0, 0):
            continue
        dx, dy = bs
        diff = np.abs(a[100 + dy:620 + dy, 140 + dx:1140 + dx] - ref).sum(axis=2) > 24
        diff[200:330, 440:560] = False         # the walking farmer at the screen centre (region coords)
        cx, cy = cam[i - off]
        r = [int(HOUSE_W[0] - (cx - 640)) - 140 + 12, int(HOUSE_W[1] - (cy - 360)) - 100 + 12,
             int(HOUSE_W[2] - (cx - 640)) - 140 - 12, int(HOUSE_W[3] - (cy - 360)) - 100 - 12]
        r = [max(0, r[0]), max(0, r[1]), min(1000, r[2]), min(520, r[3])]
        if r[2] - r[0] < 80 or r[3] - r[1] < 80:
            continue
        m = np.zeros(diff.shape, bool)
        m[r[1]:r[3], r[0]:r[2]] = True
        m[200:330, 440:560] = False
        if float(diff[~m].mean()) > 0.12:   # the alignment failed (the farmer stopped or turned): not a pan pair
            continue
        res.append({"i": i, "cam": (cx, cy), "shift": bs, "cam_frac": [round(cx % 1, 3), round(cy % 1, 3)],
                    "cabin": float(diff[m].mean()), "rest": float(diff[~m].mean()), "rect": r, "diff": diff})
    return files, res


def pans():
    summary = {}
    keep = {}
    for name, lab in PANS.items():
        files, res = pan_one(name)
        if not res:
            continue
        summary[name] = {"what": lab, "pairs": len(res),
                         "cabin_changed_share_mean": round(float(np.mean([r["cabin"] for r in res])), 4),
                         "rest_changed_share_mean": round(float(np.mean([r["rest"] for r in res])), 4),
                         "cabin_changed_share_max": round(float(np.max([r["cabin"] for r in res])), 4),
                         "camera_fractions_seen": sorted({tuple(r["cam_frac"]) for r in res})[:8]}
        keep[name] = (files, res)
    M["pan_instability"] = {"method": "consecutive frames aligned by the best whole-pixel shift over a 1000x520 centre "
                            "region; share of pixels that still differ (sum |dRGB| > 24); farmer masked; cabin = the C2 "
                            "sprite rect inset 12 px, rest = everything else (includes drifting leaf particles and "
                            "water animation)", "pans": summary}
    print(json.dumps(summary, indent=1))
    # Strip and difference map from the diagonal pan: the aligned pair with the most cabin change; each cell crops
    # the same WORLD window (the cabin's west window and the logs above it) from that frame, via the logged camera.
    files, res = keep["pan_diag"]
    w = max(res, key=lambda r: r["cabin"])
    i0 = w["i"]
    byi = {r["i"]: r for r in res}
    cells = []
    anchor = (HOUSE_W[0] + 110, HOUSE_W[1] + 250)
    for k in range(i0 - 2, i0 + 4):
        if k not in byi:
            continue
        cx, cy = byi[k]["cam"]
        x0 = int(np.floor(anchor[0] - (cx - 640)))
        y0 = int(np.floor(anchor[1] - (cy - 360)))
        im = Image.open(files[k]).convert("RGB")
        cells.append(("frame %d, camera frac (%.2f, %.2f)" % (k, cx % 1, cy % 1), up(im.crop((x0, y0, x0 + 120, y0 + 80)), 4)))
    dm = Image.fromarray((w["diff"] * 255).astype(np.uint8)).convert("RGB")
    ImageDraw.Draw(dm).rectangle(tuple(w["rect"]), outline=ACC, width=3)
    s = M["pan_instability"]["pans"]
    note = ("Diagonal pan (30 fps). Each cell: the same 120x80 px WORLD window on the cabin (west window + logs), ENLARGED 4x. "
            "Changed share per aligned frame pair, cabin | rest of frame:\n" + "; ".join("%s %.1f%% | %.1f%%" % (k.replace("pan_", "") if k != "pan" else "west 30fps",
            100 * v["cabin_changed_share_mean"], 100 * v["rest_changed_share_mean"]) for k, v in s.items()))
    top = grid("hc1_pan_frames.png", "HC1 Step 1 - 2. camera-pan diagnosis: does the 1.5-px cabin shimmer?", note, cells, 3)
    out = Image.new("RGB", (top.width, top.height + dm.height + 40), BG)
    out.paste(top, (0, 0))
    ImageDraw.Draw(out).text((16, top.height + 8), "pixels still different after whole-pixel alignment, frames %d->%d "
                             "(white; yellow box = cabin; farmer masked)" % (i0 - 1, i0), font=F, fill=FG)
    out.paste(dm, (16, top.height + 32))
    out.save(os.path.join(REV, "hc1_pan_frames.png"))
    # GIF: the diagonal pan, 480x270 round the farmer, 1:1 (gameplay scale), 30 fps.
    ff = "ffmpeg"
    for p in glob.glob(os.path.join(os.environ.get("LOCALAPPDATA", ""), "Microsoft", "WinGet", "Packages", "*", "*", "bin", "ffmpeg.exe")):
        ff = p
    tmp = os.path.join(FR, "pan_gif")
    if os.path.isdir(tmp):
        for f in glob.glob(os.path.join(tmp, "*.png")):
            os.remove(f)
    os.makedirs(tmp, exist_ok=True)
    for j, k in enumerate(range(5, min(len(files), 70))):   # the moving part of the diagonal walk
        Image.open(files[k]).convert("RGB").crop((400, 150, 880, 420)).save(os.path.join(tmp, "g%04d.png" % j))
    subprocess.run([ff, "-y", "-loglevel", "error", "-framerate", "30", "-i", os.path.join(tmp, "g%04d.png"),
                    "-vf", "split[a][b];[a]palettegen=max_colors=255:stats_mode=full[p];[b][p]paletteuse=dither=none",
                    os.path.join(REV, "hc1_pan_diag.gif")], check=True)
    print("hc1_pan_diag.gif")


def copy_frames():
    os.makedirs(FRAMES, exist_ok=True)
    for k in VIEWS:
        for hr in ("day", "night"):
            load("%s_%s.png" % (k, hr)).save(os.path.join(FRAMES, "%s_%s_720p.png" % (k, hr)))
    for k, hr in (("north", "day"), ("north", "night"), ("door", "day")):
        for f in ("today", "int"):
            load("%s_%s_fhd_%s.png" % (k, hr, f)).save(os.path.join(FRAMES, "%s_%s_1080p_%s.png" % (k, hr, f)))


def main():
    os.makedirs(REV, exist_ok=True)
    import sys
    if "density" in sys.argv:
        density()
        M.update({k: v for k, v in json.load(open(os.path.join(OUT, "measure.json"))).items() if k not in M})
        with open(os.path.join(OUT, "measure.json"), "w") as f:
            json.dump(M, f, indent=1)
        print(json.dumps(M["pixel_runs_720p"]), json.dumps(M["pixel_runs_1080p_today"]))
        return
    copy_frames()
    ov = overview()
    locations()
    fhd()
    values(ov)
    density()
    outlines()
    pans()
    summary()
    with open(os.path.join(OUT, "measure.json"), "w") as f:
        json.dump(M, f, indent=1)
    print(json.dumps({k: v for k, v in M.items() if k != "pan_shifts"}, indent=1)[:6000])



# --- summary panel (text) for the master ----------------------------------------------------------------------------

SUMMARY = [
    ("HC1 Step 1 - provisional rubric self-score (Claude Code; ChatGPT scores independently)", None),
    ("Concept fidelity 6.0 | Richness 5.5 | Lighting 5.5 | Asset consistency 4.0 | Readability 7.0 | Technical 5.5"
     "  =  55.5 / 100 (below 65)", FG),
    ("", None),
    ("Measured (measure.json)", None),
    ("- 720p run lengths: 16 px art 76-85% multiples of 3 px; C2 cabin 31% (42% are 1-2 px). Cabin pixels = half size.", FG),
    ("- Pan, changed pixels after whole-pixel alignment, cabin | rest: diagonal 30 fps 9.3% | 2.2% (shimmer); "
     "west 30 fps 0.5% | 0.7%; west 144 fps 4.0% | 4.3%.", FG),
    ("- 1080p today (1.5x stretch): 16 px art pixels are 4-5 px wide for EVERY asset - non-integer, independent of the cabin.", FG),
    ("- Sprite edge luma: farmer/well 0-1 (black), cabin/oak 21, log pile 30, apple tree 44, gatepost 45 = four outline families.", FG),
    ("- Noon mean luma: grass 49, path 58, fields 50, roof 33, forest 30, oak rect 64. Grass texture 20.5 = fields 20.0.", FG),
    ("", None),
    ("Ranked problems (impact x frequency x 720p visibility, then feasibility / effort / risk)", None),
    ("1 No single art standard: two densities, four outline families, mixed generator families", FG),
    ("2 Scene value/colour key: narrow, low noon key; roof at forest value; brightest small things are litter", FG),
    ("3 Ground noise and uniform scatter; no quiet zones; grass as busy as the crops", FG),
    ("4 No grounding / light model: no contact shadows, no readable light direction", FG),
    ("5 Motion: cabin shimmer on diagonal moves; 1080p non-integer stretch for all art (scaling = locked, high risk)", FG),
    ("6 Paths: blobby edges, ~9 luma from grass; crossroads reads as a clearing", FG),
    ("7 Soft non-pixel overlays: wet-soil blobs, wheel ruts, well ring, fog wisps", FG),
    ("8 Hero props: gate reads as a pole; orchard crowns unlike oak; cool stone-like dock; black void past the gate at night", FG),
    ("9 Composition gaps: empty NW quarter and oak-to-orchard stretch", FG),
    ("10 Farmer: clean and readable, but black outline and detail level set it apart", FG),
    ("", None),
    ("Recommended next three (proposals only): 1 decide ONE art standard (density + outline + shading) with matched evidence "
     "(= Step 2);", ACC),
    ("2 scene value/colour key + grounding rule (paint-over study); 3 ground calm-down: scatter, path edges, pixel-art "
     "overlays (harness only).", ACC),
    ("Density verdict: the mismatch is real and major, but NOT the only cause; it does not by itself pick 16 vs 32 px.", ACC),
]


def summary():
    out = Image.new("RGB", (1640, 40 + 27 * len(SUMMARY)), BG)
    d = ImageDraw.Draw(out)
    y = 16
    for text, col in SUMMARY:
        d.text((20, y), text, font=FB if col is None else F, fill=(255, 255, 255) if col is None else col)
        y += 27
    out.save(os.path.join(REV, "hc1_summary.png"))
    print("hc1_summary.png", out.size)


if __name__ == "__main__":
    main()
