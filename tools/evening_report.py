"""CCH-EVENING-001: tables and charts from the evening play logs (tools/evening_play.gd's EVE lines) and the
first-week balance sims. Pillow only (no matplotlib on this machine).
    python tools/evening_report.py
Reads art/style_tests/CCH-EVENING-001/play_*/log_evening.txt and work/sim_*_grace*.txt.
Writes out/tables.md, review/chart_sanity.png and review/chart_activity.png.
Every number here comes from the bot's logs; none is a judgement of enjoyment."""
import json, os, re, glob
from PIL import Image, ImageDraw, ImageFont

ROOT = "art/style_tests/CCH-EVENING-001"
STYLES = ["cozy", "cautious", "curious", "minimal"]
LABEL = {"cozy": "Cozy farmer (pad)", "cautious": "Cautious survivor", "curious": "Curious explorer",
         "minimal": "Minimal participant", "control_nograce": "Minimal, no grace (control)"}
# The validated default categorical palette (dataviz references/palette.md), slots 1-4 in fixed order.
COL = {"cozy": "#2a78d6", "cautious": "#eb6834", "curious": "#1baf7a", "minimal": "#eda100"}
INK, INK2, GRID, SURF, REF = "#0b0b0b", "#52514e", "#e4e3df", "#fcfcfb", "#8a8984"
# CCH-PLAYABLE-002's keyboard replay, morning sanity on days 1-9 (the previous build, same bot, bed at 19:00).
PREV = [100, 91, 93, 65, 75, 61, 38, 34, 34]


def evenings(name):
    path = f"{ROOT}/play_{name}/log_evening.txt"
    if not os.path.exists(path):
        return [], []
    eves, lines = [], open(path, encoding="utf-8").read().splitlines()
    for ln in lines:
        m = re.search(r"\] EVE: (\{.*\})$", ln)
        if m:
            eves.append(json.loads(m.group(1)))
    return eves, lines


def font(size):
    for f in ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf"]:
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def sanity_chart(series, out):
    W, H, L, R, T, B = 1160, 520, 70, 300, 60, 60
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    f, fs, fb = font(15), font(13), font(19)
    d.text((L, 16), "Morning sanity by day, played by injected input (14 days)", fill=INK, font=fb)
    maxd = 15
    x = lambda day: L + (day - 1) / (maxd - 1) * (W - L - R)
    y = lambda v: T + (100 - v) / 100 * (H - T - B)
    for v in range(0, 101, 20):
        d.line([(L, y(v)), (W - R, y(v))], fill=GRID, width=1)
        d.text((L - 10, y(v)), str(v), fill=INK2, font=fs, anchor="rm")
    for day in range(1, maxd + 1):
        d.text((x(day), H - B + 14), str(day), fill=INK2, font=fs, anchor="mm")
    d.text(((L + W - R) / 2, H - 18), "morning of day", fill=INK2, font=fs, anchor="mm")
    # The previous build's replay, as a dashed neutral reference.
    pts = [(x(i + 1), y(v)) for i, v in enumerate(PREV)]
    for i in range(len(pts) - 1):
        a, b = pts[i], pts[i + 1]
        for k in range(0, 10, 2):
            t0, t1 = k / 10, (k + 1) / 10
            d.line([(a[0] + (b[0] - a[0]) * t0, a[1] + (b[1] - a[1]) * t0), (a[0] + (b[0] - a[0]) * t1, a[1] + (b[1] - a[1]) * t1)], fill=REF, width=2)
    labels = [(pts[-1][1], "Previous build (CCH-PLAYABLE-002)", REF, pts[-1][0])]
    for name, vals in series.items():
        if not vals:
            continue
        c = COL.get(name, REF)
        p = [(x(dd), y(v)) for dd, v in vals]
        if name == "control_nograce":
            for pt in p:
                d.rectangle([pt[0] - 4, pt[1] - 4, pt[0] + 4, pt[1] + 4], outline=INK2, width=2)
            labels.append((p[-1][1], LABEL[name], INK2, p[-1][0]))
            continue
        d.line(p, fill=c, width=2)
        for pt in p:
            d.ellipse([pt[0] - 4, pt[1] - 4, pt[0] + 4, pt[1] + 4], fill=c, outline=SURF, width=2)
        labels.append((p[-1][1], LABEL[name], c, p[-1][0]))
    # Direct labels at each line's end, nudged apart so they never overlap.
    labels.sort()
    placed = []
    for ly, text, c, lx in labels:
        while any(abs(ly - q) < 18 for q in placed):
            ly += 18
        placed.append(ly)
        d.line([(lx + 6, ly), (W - R + 12, ly)], fill=GRID, width=1)
        d.ellipse([W - R + 14, ly - 4, W - R + 22, ly + 4], fill=c)
        d.text((W - R + 28, ly), text, fill=INK, font=fs, anchor="lm")
    img.save(out)


def activity_chart(rows, out):
    keys = [("signs", "Signs seen (out at 19:00)"), ("read", "Signs read"), ("tended", "Hearth tended"), ("sat", "Evenings by the fire"),
            ("faced", "Visitors faced"), ("slept", "Nights slept through")]
    W, H, L, T, B = 1100, 470, 230, 60, 40
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    fs, fb = font(13), font(19)
    d.text((24, 16), "What each style did across 14 evenings (played; every run had signs on days 2, 7, 9 and 11)", fill=INK, font=fb)
    mx = max(1, max(r.get(k, 0) for r in rows.values() for k, _ in keys))
    band = (H - T - B) / len(keys)
    bh = (band - 14) / max(1, len(rows))
    for i, (k, lab) in enumerate(keys):
        y0 = T + i * band
        d.text((L - 12, y0 + band / 2 - 4), lab, fill=INK, font=fs, anchor="rm")
        for j, (name, r) in enumerate(rows.items()):
            v = r.get(k, 0)
            yy = y0 + 4 + j * bh
            w = (W - L - 160) * v / mx
            if v > 0:
                d.rounded_rectangle([L, yy, L + max(w, 4), yy + bh - 2], radius=3, fill=COL[name])
            d.text((L + w + 6, yy + bh / 2 - 1), str(v), fill=INK2, font=fs, anchor="lm")
    lx = W - 150
    for j, name in enumerate(rows):
        d.rectangle([lx, T + j * 20, lx + 10, T + j * 20 + 10], fill=COL[name])
        d.text((lx + 16, T + j * 20 + 5), LABEL[name], fill=INK, font=fs, anchor="lm")
    img.save(out)


def main():
    os.makedirs(f"{ROOT}/out", exist_ok=True)
    os.makedirs(f"{ROOT}/review", exist_ok=True)
    md, series, counts = [], {}, {}
    md.append("# CCH-EVENING-001 play tables (generated by tools/evening_report.py)\n")
    md.append("Played by injected input (tools/evening_play.gd). Not a human; nothing here measures enjoyment.\n")
    for name in STYLES + ["control_nograce"]:
        eves, lines = evenings(name)
        if not eves:
            continue
        problems = [ln for ln in lines if " PROBLEM: " in ln]
        series[name] = [(e["day"] + 1, e["morning_sanity"]) for e in eves]
        series[name] = [(1, 100)] + series[name]
        c = {"evenings": len(eves),
             "signs": sum(1 for e in eves if e.get("sign")),
             "read": sum(1 for e in eves if e.get("read")),
             "tended": sum(1 for e in eves if e.get("tended")),
             "sat": sum(1 for e in eves if e.get("sat")),
             "faced": sum(1 for e in eves if e.get("night_faced")),
             "slept": sum(1 for e in eves if not e.get("stayed_up")),
             "left": sum(1 for e in eves if e.get("night_left_alone")),
             "fed": sum(int(e.get("fed", 0)) for e in eves),
             "busy": round(sum(e.get("busy_h", 0) for e in eves), 2),
             "idle": round(sum(e.get("idle_h", 0) for e in eves), 2),
             "problems": len(problems)}
        counts[name] = c
        md.append(f"\n## {LABEL[name]}\n")
        md.append(f"Evenings {c['evenings']}; sign evenings seen {c['signs']}; signs read {c['read']}; hearth tended {c['tended']}; "
                  f"evenings by the fire {c['sat']}; visitors faced {c['faced']}; nights slept through (in bed before 22:00) {c['slept']}; "
                  f"nights left alone with a cost {c['left']}; firewood fed {c['fed']}; evening game hours active {c['busy']}, waiting {c['idle']}; "
                  f"bot PROBLEM lines {c['problems']}.\n")
        md.append("| Day | Sign | Read | Tended | By the fire | Fed | Visitor | Faced | Sanity 19:00 | at bed | next morning | Comfort 19:00 | at bed | Firewood 19:00 | at bed | Bed at | Active h | Waiting h | Why not |")
        md.append("| " + " | ".join(["---"] * 19) + " |")
        for e in eves:
            why = "; ".join(x for x in [e.get("tend_blocked", ""), e.get("sit_blocked", "")] if x)
            md.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (
                e["day"], e.get("sign") or "-", "yes" if e.get("read") else "-", "yes" if e.get("tended") else "-",
                "yes" if e.get("sat") else "-", e.get("fed", 0), e.get("night", "-"), "yes" if e.get("night_faced") else "-",
                e.get("sanity_19", "-"), e.get("sanity_bed", "-"), e.get("morning_sanity", "-"), e.get("warmth_19", "-"),
                e.get("warmth_bed", "-"), e.get("firewood_19", "-"), e.get("firewood_bed", "-"), e.get("bed_at", "-"),
                e.get("busy_h", 0), e.get("idle_h", 0), why or "-"))
        if problems:
            md.append("\nBot problems: " + " / ".join(p.split("PROBLEM: ")[1][:120] for p in problems[:8]))
    md.append("\n## First-week sanity, balance sim (simulated, not played)\n")
    md.append("| Mode | Grace | " + " | ".join(f"D{i}" for i in range(1, 15)) + " |")
    md.append("| --- | --- | " + " | ".join(["---"] * 14) + " |")
    for f in sorted(glob.glob(f"{ROOT}/work/sim_*_grace*.txt")):
        mode, g = re.search(r"sim_(\w+)_grace(\d)", f).groups()
        vals = [re.split(r"\s+", ln.strip())[4].split("/")[0] for ln in open(f, encoding="utf-8") if re.match(r"^\s+\d+ Oct", ln)]
        md.append(f"| {mode} | {'on' if g == '1' else 'off'} | " + " | ".join(vals) + " |")
    open(f"{ROOT}/out/tables.md", "w", encoding="utf-8", newline="\n").write("\n".join(md) + "\n")
    sanity_chart(series, f"{ROOT}/review/chart_sanity.png")
    activity_chart({k: v for k, v in counts.items() if k in STYLES}, f"{ROOT}/review/chart_activity.png")
    print(json.dumps(counts, indent=1))


if __name__ == "__main__":
    main()
