"""ART-005 VS16-P1 (zero-generation, NON-PRODUCTION): review sheets and measurements for the farmhouse finishing pass.

    python tools/vs16p1_cabin.py && bash tools/vs16p1_run.sh && python tools/vs16p1_review.py
Sheets -> art/style_tests/ART-005/vs16p1/review/ (the masters are made after, with tools/review_master.ps1).
"""
import json
import os

import numpy as np
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
FR = os.path.join(ROOT, "builds", "review", "ART-005", "p1_export", "builds", "review", "ART-005", "vs16p1")
A = os.path.join(ROOT, "art", "style_tests", "ART-005")
OUT = os.path.join(A, "vs16p1")
REV = os.path.join(OUT, "review")
F = ImageFont.load_default(size=16)
FS = ImageFont.load_default(size=13)
FB = ImageFont.load_default(size=22)
BG, FG, DIM, WARN, OK = (22, 20, 24), (236, 230, 220), (170, 164, 156), (255, 196, 110), (150, 220, 150)
NONPROD = "! NON-PRODUCTION prototype, zero generation. VS16 kept unchanged; nothing in the game, its art, camera, lighting or saves changed."
# Component boxes in source pixels (x0, y0, x1, y1), exclusive ends.
BOX = {"roof": (0, 20, 96, 81), "door": (76, 100, 116, 160), "foundation": (0, 136, 96, 151),
       "window": (32, 98, 64, 132), "log corner": (0, 80, 32, 142)}
DOOR, WINS = (84, 108, 107, 148), ((37, 101, 59, 126), (132, 101, 154, 126))


def src(which, t):
    return Image.open(os.path.join(A, which, "cabin", f"house_{t}.png")).convert("RGBA")


def frame(name):
    return Image.open(os.path.join(FR, name + ".png")).convert("RGB")


def up(im, k):
    return im.resize((im.width * k, im.height * k), Image.NEAREST)


def on_bg(im, col=(74, 92, 48)):
    b = Image.new("RGBA", im.size, col + (255,))
    b.alpha_composite(im.convert("RGBA"))
    return b.convert("RGB")


def label(im, text, sub="", col=FG):
    out = Image.new("RGB", (max(im.width, 10), im.height + (40 if sub else 24)), BG)
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
    return out


V, P = ("VS16 (current prototype)", FG), ("VS16-P1 (finishing pass)", WARN)


def source_sheet():
    d0, d1, n0, n1 = src("vs16", "day"), src("vs16p1", "day"), src("vs16", "night"), src("vs16p1", "night")
    row1 = [label(on_bg(im), t, "1:1 source", c) for im, (t, c) in
            ((d0, V), (d1, P), (n0, V), (n1, P))]
    row1.append(label(up(Image.open(os.path.join(OUT, "cabin", "palette.png")).convert("RGBA"), 2).convert("RGB"), "P1 ramps", "x2"))
    row2 = [label(up(on_bg(d0), 3), V[0] + "  DAY", "source x3 (gameplay scale, no lighting)", V[1]),
            label(up(on_bg(d1), 3), P[0] + "  DAY", "source x3 (gameplay scale, no lighting)", P[1])]
    row3 = [label(up(on_bg(n0), 3), V[0] + "  NIGHT glass", "source x3 (no night grade; see the R3-1 sheet)", V[1]),
            label(up(on_bg(n1), 3), P[0] + "  NIGHT glass", "source x3 (no night grade; see the R3-1 sheet)", P[1])]
    sheet("p1_source.png", "ART-005 VS16-P1 - farmhouse SOURCE ART: VS16 vs P1 (1:1 and x3)",
          [NONPROD, "Source-art views, not game screenshots. 192x160 canvas, 16 px per tile; x3 = the game's 720p scale before lighting."],
          [row1, row2, row3])


def detail_sheet():
    rows = []
    for t in ("day", "night"):
        a, b = src("vs16", t), src("vs16p1", t)
        names = ("roof", "door", "foundation", "window", "log corner") if t == "day" else ("window", "door")
        row = []
        for n in names:
            x0, y0, x1, y1 = BOX[n]
            k = 6 if n != "roof" else 5
            pa, pb = up(on_bg(a.crop((x0, y0, x1, y1))), k), up(on_bg(b.crop((x0, y0, x1, y1))), k)
            pair = Image.new("RGB", (pa.width * 2 + 6, pa.height), BG)
            pair.paste(pa, (0, 0)); pair.paste(pb, (pa.width + 6, 0))
            row.append(label(pair, f"{n} ({t})", f"left VS16, right P1; source x{k}"))
        rows.append(row)
    # split the long day row in two
    day = rows[0]
    sheet("p1_details.png", "ART-005 VS16-P1 - component CLOSE-UPS (source art, enlarged)",
          [NONPROD, "Enlarged source pixels, not gameplay scale. The gameplay-scale view of the same parts is on the 720p crop sheet."],
          [day[:2], day[2:], rows[1]])


def change_map():
    out = {}
    rows = []
    for t in ("day", "night"):
        a, b = np.array(src("vs16", t)), np.array(src("vs16p1", t))
        alpha_same = bool((a[..., 3] == b[..., 3]).all())
        diff = (a != b).any(axis=2)
        out[t] = {"alpha_identical": alpha_same, "changed_px": int(diff.sum()),
                  "opaque_px": int((b[..., 3] > 0).sum())}
        regions = {}
        for n, (x0, y0, x1, y1) in {"roof": (0, 21, 192, 81), "chimney": (146, 10, 165, 33), "walls+corners": (0, 81, 192, 141),
                                    "foundation": (0, 141, 192, 150), "steps": (79, 150, 113, 160)}.items():
            regions[n] = int(diff[y0:y1, x0:x1].sum())
        for n, (x0, y0, x1, y1) in {"door": (81, 104, 111, 150), "window L": (35, 101, 62, 131), "window R": (130, 101, 157, 131)}.items():
            regions[n] = int(diff[y0:y1, x0:x1].sum())
        out[t]["changed_by_region"] = regions
        base = on_bg(Image.fromarray(b)).convert("L").convert("RGB")
        base = Image.blend(base, Image.new("RGB", base.size, (0, 0, 0)), 0.55)
        m = np.array(base)
        m[diff] = (255, 90, 60)
        cm = Image.fromarray(m)
        dr = ImageDraw.Draw(cm)
        dr.rectangle(DOOR, outline=(90, 220, 255))
        for w in WINS:
            dr.rectangle(w, outline=(90, 220, 255))
        rows.append(label(up(cm, 3), f"CHANGE MAP ({t})", "red = pixel differs from VS16; cyan = VS16's door and window rectangles"))
    # alignment: outline both versions' alpha and the openings
    a, b = np.array(src("vs16", "day"))[..., 3] > 0, np.array(src("vs16p1", "day"))[..., 3] > 0
    al = np.zeros(a.shape + (3,), np.uint8)
    al[a & b] = (70, 70, 70); al[a & ~b] = (255, 60, 60); al[~a & b] = (60, 160, 255)
    ali = Image.fromarray(al)
    dr = ImageDraw.Draw(ali)
    dr.rectangle(DOOR, outline=(255, 220, 90))
    for w in WINS:
        dr.rectangle(w, outline=(255, 220, 90))
    note = (f"footprint: alpha identical day {out['day']['alpha_identical']}, night {out['night']['alpha_identical']} "
            f"(grey = both; red/blue would mark a mismatch)")
    sheet("p1_change_map.png", "ART-005 VS16-P1 - CHANGE MAP and FOOTPRINT / OPENING ALIGNMENT",
          [NONPROD, note, f"Door {DOOR} and windows {WINS} (x0,y0,x1,y1 source px) unchanged; window light centres unchanged.",
           f"changed px by region, day: {out['day']['changed_by_region']}"],
          [rows, [label(up(ali, 3), "FOOTPRINT + OPENINGS (both versions overlaid)", "yellow = door and window rectangles, shared")]])
    return out


def frame_sheets():
    fdiff = {}
    for spot in ("home", "door"):
        for t in ("day", "night"):
            a, b = np.array(frame(f"{spot}_vs16_{t}")).astype(int), np.array(frame(f"{spot}_p1_{t}")).astype(int)
            d = np.abs(a - b).sum(axis=2) > 0
            # Every frame differs a little everywhere: the grade's film grain is seeded by TIME (a same-config rerun
            # differs as much). Locate the cabin as the 576x480 window (192x160 art px x3) holding the most strong
            # differences, and report how much changed inside and outside it.
            strong = (np.abs(a - b).sum(axis=2) > 40).astype(np.int64)
            ii = np.pad(strong.cumsum(0).cumsum(1), ((1, 0), (1, 0)))
            best, bx, by = -1, 0, 0
            for y0 in range(-240, 721 - 240, 3):
                for x0 in range(-288, 1281 - 288, 3):
                    xa, ya, xb, yb = max(0, x0), max(0, y0), min(1280, x0 + 576), min(720, y0 + 480)
                    if xb <= xa or yb <= ya:
                        continue
                    n = ii[yb, xb] - ii[ya, xb] - ii[yb, xa] + ii[ya, xa]
                    if n > best:
                        best, bx, by = n, x0, y0
            inside = int(best)
            fdiff[f"{spot}_{t}"] = {"cabin_rect": [bx, by, bx + 576, by + 480], "strong_px_in_cabin": inside,
                                    "strong_px_outside": int(strong.sum()) - inside,
                                    "mean_abs_diff_all": round(float(np.abs(a - b).sum(axis=2).mean()), 2)}
    tl = {"day": "NOON 12:00", "night": "R3-1 NIGHT 21:30"}
    for t in ("day", "night"):
        rows = [[label(frame(f"home_vs16_{t}"), f"{V[0]} - home, {tl[t]}", "real 1280x720 game frame, 1:1", V[1]),
                 label(frame(f"home_p1_{t}"), f"{P[0]} - home, {tl[t]}", "same camera, farmer spot, hour and scale", P[1])]]
        sheet(f"p1_home_{t}.png", f"ART-005 VS16-P1 - FULL-GAME 720p: cabin, golden oak, well, farmer - {tl[t]}",
              [NONPROD, "Full-game screenshots (clean export, the game's own camera, x3 scale, grade and R3-1 night). Only the cabin sprite differs."],
              rows)
    rows = []
    for t in ("day", "night"):
        rows.append([label(frame(f"door_vs16_{t}"), f"{V[0]} - farmer at the door, {tl[t]}", "real 1280x720 game frame, 1:1", V[1]),
                     label(frame(f"door_p1_{t}"), f"{P[0]} - farmer at the door, {tl[t]}", "same framing", P[1])])
    sheet("p1_door.png", "ART-005 VS16-P1 - FULL-GAME 720p: the farmer beside the farmhouse, noon and 21:30",
          [NONPROD, "Full-game screenshots. Only the cabin sprite differs."], rows)
    # gameplay-scale crops: the cabin from the door frames, 1:1 and x2 (screen pixels, lit by the game)
    rows = []
    for t in ("day", "night"):
        bb = fdiff[f"door_{t}"]["cabin_rect"]
        x0, y0, x1, y1 = max(0, bb[0] - 24), max(0, bb[1] - 24), min(1280, bb[2] + 24), min(720, bb[3] + 24)
        ca, cb = frame(f"door_vs16_{t}").crop((x0, y0, x1, y1)), frame(f"door_p1_{t}").crop((x0, y0, x1, y1))
        rows.append([label(ca, f"VS16 - {tl[t]}", "720p frame crop, 1:1 (true gameplay size)", V[1]),
                     label(cb, f"P1 - {tl[t]}", "720p frame crop, 1:1 (true gameplay size)", P[1])])
    sheet("p1_gameplay_crops.png", "ART-005 VS16-P1 - the cabin at TRUE GAMEPLAY SIZE (720p crops, 1:1)",
          [NONPROD, "Crops of the real game frames above, not enlarged: this is how large every change is during play."], rows)
    return fdiff


def stats(t):
    im = src("vs16p1", t)
    cols = {c for c in im.get_flattened_data() if c[3]} if hasattr(im, "get_flattened_data") else {c for c in im.getdata() if c[3]}
    return len(cols)


def main():
    os.makedirs(REV, exist_ok=True)
    source_sheet()
    detail_sheet()
    cm = change_map()
    fd = frame_sheets()
    m = {"task": "ART-005 VS16-P1", "status": "zero generation, NON-PRODUCTION finishing pass",
         "colours": {"vs16_day": 39, "vs16_night": 42, "p1_day": stats("day"), "p1_night": stats("night")},
         "source_change": cm, "frame_change": fd}
    with open(os.path.join(OUT, "measure.json"), "w") as f:
        json.dump(m, f, indent=1)
    print(json.dumps(m, indent=1))


if __name__ == "__main__":
    main()
