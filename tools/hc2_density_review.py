# ART-005 HC1 Step 2 (zero-generation, non-production): builds the density-study panels, GIFs and measurements from
# the frames tools/hc2_density_run.sh rendered in the clean export
# (builds/review/ART-005/p1_export/builds/review/ART-005/hc2/). Writes art/style_tests/ART-005/hc2/review/ and
# art/style_tests/ART-005/hc2/measure.json. Nothing in the game or its art is changed.
#   python tools/hc2_density_review.py
import glob
import json
import os
import subprocess

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
FR = os.path.join(ROOT, "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "hc2")
OUT = os.path.join(ROOT, "art", "style_tests", "ART-005", "hc2")
REV = os.path.join(OUT, "review")
FRAMES = os.path.join(REV, "frames")
BG, FG, DIM, ACC, WARN = (28, 30, 34), (232, 232, 228), (170, 172, 176), (255, 200, 60), (255, 120, 90)
F = ImageFont.load_default(size=16)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=22)
SRC = {"C2 cabin (32 px, control)": "art/style_tests/ART-005/pl/g7/c2/32/house_day.png",
       "16 px cabin (EXPERIMENTAL MOCKUP)": "art/style_tests/ART-005/hc2/house16/house_day.png",
       "well (16 px, production)": "art/farm/prop_well.png",
       "well (32 px STUDY)": "art/style_tests/ART-005/hc2/well32/prop_well_32.png",
       "golden oak (16 px)": "art/style_tests/ART-003/w3/oak/oak_w3.png",
       "farmer idle (16 px)": "art/player/farmer_idle.png",
       "apple tree (16 px)": "art/style_tests/ART-003/w4/orchard/apple_a.png",
       "log pile (16 px)": "art/style_tests/ART-003/w4/props/logpile.png"}
VAR = {"ctrl": "CONTROL: C2 cabin 32 px + well 16 px (HC1 baseline)",
       "h16": "A: 16 px cabin MOCKUP + well 16 px (all 16 px)",
       "w32": "B: C2 cabin 32 px + well 32 px STUDY"}
DAY = "noon 12:00"
NIGHT = "21:30, R3-1 night, lantern tier 1"
# Sprite rects in world units, from the home still: its logged camera centre is (2520, 888) and there the cabin sprite
# covers screen (697,-16)-(1273,464) (576x480 = 12x10 tiles at 48 px) and the well (570,526)-(666,672). Pans map them
# to the screen through each frame's logged camera centre (pan_cam.txt).
HOME_CAM = (2520.0, 888.0)
HOUSE_W = (697 + 2520 - 640, -16 + 888 - 360, 1273 + 2520 - 640, 464 + 888 - 360)
WELL_W = (570 + 2520 - 640, 526 + 888 - 360, 666 + 2520 - 640, 672 + 888 - 360)


def to_screen(rw, cam):
    return (int(round(rw[0] - cam[0] + 640)), int(round(rw[1] - cam[1] + 360)),
            int(round(rw[2] - cam[0] + 640)), int(round(rw[3] - cam[1] + 360)))


M = {"what": "ART-005 HC1 Step 2 density study, zero generation, non-production. Frames: 1280x720, the game's own "
             "camera on the farmer at inner tile 38.5,10.5 (home) or 45,13 (door), W-4 layout b, F2 fields."}


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
    """rows: list of lists of images (already labelled)."""
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
    return out


def diff_box(a, b, frac=0.08):
    """Screen bbox of where two frames of the same scene differ (the swapped sprite): rows/columns where at least
    `frac` of pixels differ, so sparse drifting leaves are ignored."""
    # The colour grade's film grain and drifting leaves differ between runs too: close small gaps, open away specks,
    # and keep the largest connected region (the swapped sprite).
    from scipy import ndimage
    d = np.abs(np.asarray(a, np.int16) - np.asarray(b, np.int16)).sum(axis=2) > 40
    d = ndimage.binary_closing(d, structure=np.ones((5, 5)))
    d = ndimage.binary_opening(d, structure=np.ones((6, 6)))
    lab, n = ndimage.label(d)
    if n == 0:
        return None
    sizes = ndimage.sum(d, lab, range(1, n + 1))
    k = int(np.argmax(sizes)) + 1
    if sizes[k - 1] < 400:
        return None
    ys, xs = np.nonzero(lab == k)
    return (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)


def runs(img, rect):
    """Horizontal same-colour run lengths at 720p (HC1's method: a run ends where |dRGB| summed > 15)."""
    a = np.asarray(img.convert("RGB"), dtype=np.int32)[rect[1]:rect[3], rect[0]:rect[2]]
    step = np.abs(np.diff(a, axis=1)).sum(axis=2) > 15
    hist = {}
    for srow in step:
        edges = np.flatnonzero(srow) + 1
        lens = np.diff(np.concatenate(([0], edges, [len(srow) + 1])))[1:-1]
        for L in lens:
            hist[int(L)] = hist.get(int(L), 0) + 1
    tot = sum(hist.values()) or 1
    return {"runs": tot, "multiple_of_3": round(sum(v for L, v in hist.items() if L % 3 == 0) / tot, 3),
            "length_1_or_2": round(sum(v for L, v in hist.items() if L <= 2) / tot, 3),
            "top": sorted(hist.items(), key=lambda kv: -kv[1])[:6]}


def source_stats():
    res = {}
    for k, p in SRC.items():
        fp = os.path.join(ROOT, p)
        if not os.path.exists(fp):
            continue
        a = np.asarray(Image.open(fp).convert("RGBA"), dtype=np.int32)
        op = a[..., 3] > 128
        pad = np.pad(op, 1)
        edge = op & ~(pad[:-2, 1:-1] & pad[2:, 1:-1] & pad[1:-1, :-2] & pad[1:-1, 2:])
        c = a[edge][:, :3]
        lum = c @ np.array([0.2126, 0.7152, 0.0722])
        rgb = a[op][:, :3]
        key = (rgb[:, 0] << 16) | (rgb[:, 1] << 8) | rgb[:, 2]
        # clusters: 4-connected same-colour regions; mean size and share of 1-px clusters (noise)
        flat = np.full(op.shape, -1, np.int64)
        flat[op] = key
        seen = np.zeros(op.shape, bool)
        sizes = []
        H, W = op.shape
        for y in range(H):
            for x in range(W):
                if not op[y, x] or seen[y, x]:
                    continue
                st = [(y, x)]
                seen[y, x] = True
                n = 0
                while st:
                    yy, xx = st.pop()
                    n += 1
                    for ny, nx in ((yy + 1, xx), (yy - 1, xx), (yy, xx + 1), (yy, xx - 1)):
                        if 0 <= ny < H and 0 <= nx < W and not seen[ny, nx] and flat[ny, nx] == flat[yy, xx]:
                            seen[ny, nx] = True
                            st.append((ny, nx))
                sizes.append(n)
        sizes = np.array(sizes)
        tile = 32 if ("32" in k) else 16
        res[k] = {"size_px": [int(W), int(H)], "art_px_per_tile": tile, "screen_px_per_art_px_720p": 3 * 16 / tile,
                  "colours": int(len(np.unique(key))), "clusters": int(len(sizes)),
                  "cluster_mean_px": round(float(sizes.mean()), 2),
                  "cluster_median_px": float(np.median(sizes)),
                  "single_px_cluster_share": round(float((sizes == 1).mean()), 3),
                  "cluster_mean_screen_px2_720p": round(float(sizes.mean()) * (3 * 16 / tile) ** 2, 1),
                  "edge_median_luma": round(float(np.median(lum)), 1),
                  "edge_share_luma_below_40": round(float((lum < 40).mean()), 3),
                  "outline_width_screen_px_720p": 3 * 16 / tile}
    M["source"] = res


def source_panel():
    """Both comparisons at the source, at the SAME world size: C2 2x / 16 px 4x (so each is 768 px wide), well 32 px
    4x / 16 px 8x."""
    def src(p, k):
        im = Image.open(os.path.join(ROOT, p)).convert("RGBA")
        bg = Image.new("RGBA", im.size, (52, 56, 46, 255))
        bg.alpha_composite(im)
        return up(bg.convert("RGB"), k)
    c2 = src(SRC["C2 cabin (32 px, control)"], 2)
    h16 = src(SRC["16 px cabin (EXPERIMENTAL MOCKUP)"], 4)
    h16n = src("art/style_tests/ART-005/hc2/house16/house_night.png", 4)
    c2n = src("art/style_tests/ART-005/pl/g7/c2/32/house_night.png", 2)
    sheet("hc2_house_source.png", "HC1 Step 2 - farmhouse density at the source (same world size: 12 x 10 tiles)",
          ["Left: C2 at 32 art px per tile (control, unchanged), x2. Right: 16 px approximation, x4. Same footprint, "
           "door, windows, lamp, chimney, steps and silhouette.",
           "! The 16 px cabin is an EXPERIMENTAL MOCKUP redrawn by script on C2's halved coordinates in 30 of C2's colours. "
           "It is not finished, artist-authored 16 px art.",
           "Night: only the window glass lights, as C2's does."],
          [[label(c2, "C2 cabin, 32 px (control), day"), label(h16, "16 px cabin MOCKUP, day", col=WARN)],
           [label(c2n, "C2 cabin, 32 px, night variant"), label(h16n, "16 px cabin MOCKUP, night variant", col=WARN)]])
    w16 = src(SRC["well (16 px, production)"], 8)
    w32 = src(SRC["well (32 px STUDY)"], 4)
    sheet("hc2_well_source.png", "HC1 Step 2 - well density at the source (same world size: 2 x 3 tiles)",
          ["Left: production well, 16 px per tile, x8. Right: the 32 px STUDY, x4: the same shapes on the doubled grid, "
           "outlines and mortar thinned to 1 px, every stone/shingle/post re-shaded, 25 colours (16 px: 17).",
           "! The 32 px well is a constructed STUDY, not finished artist-authored art; one 32 px prop cannot show what "
           "a rebuilt 32 px world would look like."],
          [[label(w16, "well, 16 px (production)"), label(w32, "well, 32 px STUDY", col=WARN)]])


def context():
    ctx = {}
    for hr, lab in (("day", DAY), ("night", NIGHT)):
        rows = [[label(load("home_%s_%s.png" % (v, hr)), VAR[v], "1280x720 actual 720p, 1:1, " + lab,
                       WARN if v != "ctrl" else FG)] for v in ("ctrl", "h16", "w32")]
        sheet("hc2_context_%s.png" % hr, "HC1 Step 2 - in context, actual 720p gameplay zoom, %s" % lab,
              ["Same farmer spot (inner 38.5,10.5), the game's own camera and scale, same surrounding art. Only the "
               "cabin sprite (A) or the well sprite (B) is swapped; nothing else differs.",
               "! A = experimental 16 px mockup; B = 32 px study. Neither is finished art."], rows)
    # crops 1:1 and x3 of cabin and well from the same frames
    for hr in ("day", "night"):
        c, a, b = (load("home_%s_%s.png" % (v, hr)) for v in ("ctrl", "h16", "w32"))
        ctx[hr] = {"house_screen_rect": to_screen(HOUSE_W, HOME_CAM), "well_screen_rect": to_screen(WELL_W, HOME_CAM)}
    M["context_rects"] = ctx
    return ctx


def crops(ctx):
    cells_h, cells_w = [], []
    for hr in ("day", "night"):
        c, a, b = (load("home_%s_%s.png" % (v, hr)) for v in ("ctrl", "h16", "w32"))
        x0, y0, x1, y1 = ctx[hr]["house_screen_rect"]
        win = (x0, y0 + 280, x0 + 160, y0 + 380)            # west log ends, logs and the west window (art y 101-124)
        door = ((x0 + x1) // 2 - 50, y0 + 330, (x0 + x1) // 2 + 110, y0 + 430)   # door, lamp, foundation
        cells_h.append([label(up(c.crop(win), 4), "C2 32 px: window + corner, %s, x4" % hr),
                        label(up(a.crop(win), 4), "16 px MOCKUP: same window, %s, x4" % hr, col=WARN)])
        cells_h.append([label(up(c.crop(door), 4), "C2 32 px: door + footing, %s, x4" % hr),
                        label(up(a.crop(door), 4), "16 px MOCKUP: door + footing, %s, x4" % hr, col=WARN)])
        wx0, wy0, wx1, wy1 = ctx[hr]["well_screen_rect"]
        cx, cy = (wx0 + wx1) // 2, (wy0 + wy1) // 2
        wwin = (cx - 80, cy - 80, cx + 80, cy + 80)           # the well with grass, path, stump and rocks round it
        cells_w.append([label(up(c.crop(wwin), 3), "well 16 px (production) in context, %s, x3" % hr),
                        label(up(b.crop(wwin), 3), "well 32 px STUDY in context, %s, x3" % hr, col=WARN)])
    sheet("hc2_house_crops.png", "HC1 Step 2 - farmhouse at 720p, crops ENLARGED x4 (nearest) from the in-context frames",
          ["Each crop is 160x100 screen px of the real 720p frame -> 640x400. C2's art px are 1.5 screen px (columns "
           "alternate 1 and 2 px); the mockup's are 3 px, like the oak, grass, well and farmer.",
           "! 16 px cabin = experimental mockup, not finished art."], cells_h)
    sheet("hc2_well_crops.png", "HC1 Step 2 - well at 720p in its surroundings, crops ENLARGED x3 (nearest)",
          ["Each crop is 160x160 screen px of the real 720p frame -> 480x480: the well beside the 16 px stump, rocks, grass "
           "and path. The study's pixels are 1.5 screen px against 3 px everywhere around it.",
           "! 32 px well = constructed study, not finished art."], cells_w)
    # door view: the farmer at the door at both densities
    rows = []
    for hr in ("day", "night"):
        c, a = load("door_ctrl_%s.png" % hr), load("door_h16_%s.png" % hr)
        w = (640 - 120, 360 - 130, 640 + 120, 360 + 30)
        rows.append([label(up(c.crop(w), 3), "farmer at the door, C2 32 px, %s, x3" % hr),
                     label(up(a.crop(w), 3), "farmer at the door, 16 px MOCKUP, %s, x3" % hr, col=WARN)])
    sheet("hc2_door_farmer.png", "HC1 Step 2 - character against the cabin: the 16 px farmer at the door (HC1's door view)",
          ["240x160 screen px of the real 720p frame (camera on the farmer at inner 45,13) -> x3. The farmer is 16 px art "
           "(3 screen px per art px) in both.", "! 16 px cabin = experimental mockup."], rows)
    # run lengths in the swapped sprites' screen rects
    rl = {}
    for hr in ("day", "night"):
        c, a, b = (load("home_%s_%s.png" % (v, hr)) for v in ("ctrl", "h16", "w32"))
        hb = ctx[hr]["house_screen_rect"]
        hbi = (hb[0] + 16, hb[1] + 16, hb[2] - 16, hb[3] - 16)
        wb = ctx[hr]["well_screen_rect"]
        wbi = (wb[0] + 6, wb[1] + 6, wb[2] - 6, wb[3] - 6)
        rl[hr] = {"cabin C2 32 px": runs(c, hbi), "cabin 16 px mockup": runs(a, hbi),
                  "well 16 px": runs(c, wbi), "well 32 px study": runs(b, wbi),
                  "golden oak canopy 16 px": runs(c, (40, 30, 300, 200))}
    M["pixel_runs_720p"] = rl


def pan_metrics(name, other):
    """Per consecutive frame pair: align by the best whole-pixel shift, count pixels still different (shimmer).
    The swapped sprite's rect per frame = where this pan's frame differs from the matching frame of `other` (same walk,
    same camera). Returns (files, per-pair results)."""
    fa = sorted(glob.glob(os.path.join(FR, name, "f*.png")))
    fb = sorted(glob.glob(os.path.join(FR, other, "f*.png")))
    cam = [tuple(map(float, l.split()[1:])) for l in open(os.path.join(FR, name, "pan_cam.txt")) if l.strip()]
    off = len(fa) - len(cam)   # the movie has a few frames before the first logged process frame
    rw = HOUSE_W if "house" in name else WELL_W
    n = min(len(fa), len(fb))
    res = []
    prev = None
    for i in range(n):
        a = np.asarray(Image.open(fa[i]).convert("RGB"), dtype=np.int16)
        if prev is None:
            prev = a
            continue
        ref = a[100:620, 140:1140]
        best, bs = None, (0, 0)
        for dx in range(-7, 8):
            for dy in range(-7, 8):
                e = np.abs(prev[100 + dy:620 + dy, 140 + dx:1140 + dx] - ref).mean()
                if best is None or e < best:
                    best, bs = e, (dx, dy)
        pa = prev
        prev = a
        if bs == (0, 0):
            continue
        dx, dy = bs
        diff = np.abs(pa[100 + dy:620 + dy, 140 + dx:1140 + dx] - ref).sum(axis=2) > 24
        diff[200:330, 440:560] = False   # the walking farmer at the screen centre
        if float(diff.mean()) > 0.12:
            continue
        if i - off < 0:
            continue
        box = to_screen(rw, cam[i - off])
        r = [box[0] - 140 + 6, box[1] - 100 + 6, box[2] - 140 - 6, box[3] - 100 - 6]
        r = [max(0, r[0]), max(0, r[1]), min(1000, r[2]), min(520, r[3])]
        if r[2] - r[0] < 30 or r[3] - r[1] < 30:
            continue
        m = np.zeros(diff.shape, bool)
        m[r[1]:r[3], r[0]:r[2]] = True
        m[200:330, 440:560] = False
        res.append({"i": i, "shift": bs, "box": box, "sprite": float(diff[m].mean()), "rest": float(diff[~m].mean())})
    return fa, res


def pans():
    out = {}
    keep = {}
    for comp, (a, b) in (("house", ("pan_house_ctrl", "pan_house_h16")), ("well", ("pan_well_ctrl", "pan_well_w32"))):
        for me, other in ((a, b), (b, a)):
            files, res = pan_metrics(me, other)
            keep[me] = (files, res)
            if res:
                out[me] = {"pairs": len(res), "sprite_changed_share_mean": round(float(np.mean([r["sprite"] for r in res])), 4),
                           "rest_changed_share_mean": round(float(np.mean([r["rest"] for r in res])), 4),
                           "sprite_changed_share_max": round(float(np.max([r["sprite"] for r in res])), 4)}
    M["pan_instability"] = {"method": "30 fps diagonal walks (4.24 px camera steps), consecutive frames aligned by the best "
                            "whole-pixel shift over a 1000x520 centre region; share of pixels still different (sum |dRGB| "
                            "> 24) inside the swapped sprite's rect (inset 8 px) vs the rest of the frame; farmer masked. "
                            "The rect per frame is the sprite's world rect through that frame's logged camera.",
                            "pans": out}
    print(json.dumps(out, indent=1))
    ff = "ffmpeg"
    for p in glob.glob(os.path.join(os.environ.get("LOCALAPPDATA", ""), "Microsoft", "WinGet", "Packages", "*", "*", "bin", "ffmpeg.exe")):
        ff = p
    for comp, a, b, la, lb in (("house", "pan_house_ctrl", "pan_house_h16", "C2 32 px (control)", "16 px MOCKUP"),
                               ("well", "pan_well_ctrl", "pan_well_w32", "well 16 px (production)", "well 32 px STUDY")):
        fa, ra = keep[a]
        fb, rb = keep[b]
        if not ra:
            continue
        boxes = [r["box"] for r in ra]
        cx = int(np.mean([(bx[0] + bx[2]) / 2 for bx in boxes]))
        cy = int(np.mean([(bx[1] + bx[3]) / 2 for bx in boxes]))
        W, H = (560, 320) if comp == "house" else (320, 240)
        x0 = max(0, min(1280 - W, cx - W // 2))
        y0 = max(0, min(720 - H, cy - H // 2))
        i0, i1 = ra[0]["i"], ra[-1]["i"]
        tmp = os.path.join(FR, "gif_" + comp)
        os.makedirs(tmp, exist_ok=True)
        for f in glob.glob(os.path.join(tmp, "*.png")):
            os.remove(f)
        k = 2 if comp == "well" else 1
        for j, i in enumerate(range(max(0, i0 - 3), min(len(fa), len(fb), i1 + 4))):
            A = Image.open(fa[i]).convert("RGB").crop((x0, y0, x0 + W, y0 + H))
            B = Image.open(fb[i]).convert("RGB").crop((x0, y0, x0 + W, y0 + H))
            A, B = up(A, k), up(B, k)
            fr = Image.new("RGB", (A.width * 2 + 12, A.height + 22), BG)
            d = ImageDraw.Draw(fr)
            d.text((2, 3), la, font=FS, fill=FG)
            d.text((A.width + 14, 3), lb, font=FS, fill=WARN)
            fr.paste(A, (0, 22))
            fr.paste(B, (A.width + 12, 22))
            fr.save(os.path.join(tmp, "g%04d.png" % j))
        gif = os.path.join(REV, "hc2_pan_%s.gif" % comp)
        subprocess.run([ff, "-y", "-loglevel", "error", "-framerate", "30", "-i", os.path.join(tmp, "g%04d.png"),
                        "-vf", "split[a][b];[a]palettegen=max_colors=255:stats_mode=full[p];[b][p]paletteuse=dither=none",
                        gif], check=True)
        print(os.path.basename(gif), "1:1" if k == 1 else "x2")
        # strip: six consecutive frames, a world-locked window on the sprite (window follows the sprite's box), x4
        byi_a = {r["i"]: r for r in ra}
        mid = ra[len(ra) // 2]["i"]
        rows = []
        for lab, files, col in ((la, fa, FG), (lb, fb, WARN)):
            row = []
            for i in range(mid, mid + 6):
                if i not in byi_a:
                    continue
                bx = byi_a[i]["box"]
                if comp == "house":
                    win = (bx[0] + 90, bx[1] + 290, bx[0] + 210, bx[1] + 370)
                else:
                    win = (bx[0], bx[1] + 30, bx[0] + 100, bx[1] + 110)
                im = Image.open(files[i]).convert("RGB").crop(win)
                row.append(label(up(im, 4), "%s, frame %d" % (lab, i), "shift %s" % (byi_a[i]["shift"],), col))
            rows.append(row[:3])
            rows.append(row[3:6])
        s = M["pan_instability"]["pans"]
        sheet("hc2_pan_%s_frames.png" % comp, "HC1 Step 2 - diagonal camera pan, %s: consecutive frames, world-locked, x4" % comp,
              ["30 fps, 4.24 px camera steps. Each cell: the same world window on the %s, cut from consecutive real frames, "
               "ENLARGED x4." % comp,
               "Changed share after whole-pixel alignment (shimmer), sprite | rest: " + "; ".join(
                   "%s %.1f%% | %.1f%%" % (k, 100 * v["sprite_changed_share_mean"], 100 * v["rest_changed_share_mean"])
                   for k, v in s.items() if comp in k),
               "! Mockup / study art, not finished art."], rows)


def copy_frames():
    os.makedirs(FRAMES, exist_ok=True)
    for f in sorted(glob.glob(os.path.join(FR, "home_*.png")) + glob.glob(os.path.join(FR, "door_*.png"))):
        Image.open(f).convert("RGB").save(os.path.join(FRAMES, os.path.basename(f).replace(".png", "_720p.png")))


def main():
    os.makedirs(REV, exist_ok=True)
    source_stats()
    source_panel()
    ctx = context()
    crops(ctx)
    pans()
    copy_frames()
    with open(os.path.join(OUT, "measure.json"), "w", newline="\n") as f:
        json.dump(M, f, indent=1)
    print("measure.json")


if __name__ == "__main__":
    main()
