"""CCH-EVENING-002: tables and charts from the comparative balance runs (tools/evening2_sims.sh, which runs
tools/balance_sim.gd with style= and json=). Pillow only (no matplotlib on this machine).
    python tools/evening2_report.py
Reads art/style_tests/CCH-EVENING-002/sims/*.json. Writes out/tables.md and review/chart_*.png.
Every number here is simulated (the game's own functions, no walking, no human); none is a judgement of enjoyment."""
import json, os, glob
from PIL import Image, ImageDraw, ImageFont

ROOT = "art/style_tests/CCH-EVENING-002"
STYLES = ["minimal", "cozy", "cautious", "curious", "balanced"]
LABEL = {"minimal": "Minimal participant", "cozy": "Cozy farmer", "cautious": "Cautious survivor",
         "curious": "Curious explorer", "balanced": "Balanced player"}
CFGS = ["A", "W", "B", "S"]
CFG_LABEL = {"A": "A baseline (EVENING-001)", "W": "C- weaker (1/.85/.70/.55)", "B": "B proposed (1/.75/.60/.45)",
             "S": "C+ stronger (1/.65/.50/.35)"}
COL = {"minimal": "#eda100", "cozy": "#2a78d6", "cautious": "#eb6834", "curious": "#1baf7a", "balanced": "#7d5bd6"}
CFG_COL = {"A": "#a9a8a3", "W": "#9dc0ea", "B": "#2a78d6", "S": "#123f78"}
INK, INK2, GRID, SURF = "#0b0b0b", "#52514e", "#e4e3df", "#fcfcfb"


def font(size):
    for f in ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf"]:
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()


def load():
    runs = {}
    for p in glob.glob(f"{ROOT}/sims/*.json"):
        runs[os.path.basename(p)[:-5]] = json.load(open(p, encoding="utf-8"))
    return runs


def window(days, lo, hi=None, season=None, stage=None):
    out = [d for d in days if d["d"] >= lo and (hi is None or d["d"] <= hi)]
    if season:
        out = [d for d in out if d["season"] == season]
    if stage is not None:
        out = [d for d in out if d["stage"] >= stage]
    return out


def stats(days, all_days):
    if not days:
        return None
    first = days[0]["d"]
    prev = [d for d in all_days if d["d"] == first - 1]
    start = prev[0]["morning"] if prev else 100.0
    morn = [d["morning"] for d in days]
    return {
        "n": len(days), "start": start, "end": morn[-1], "avg": sum(morn) / len(morn),
        "low": min(min(d["low"] for d in days), min(morn)),
        "u40": sum(1 for v in morn if v < 40), "u20": sum(1 for v in morn if v < 20),
        "loss": sum(d["night_loss"] for d in days), "sleep": sum(d["sleep"] for d in days),
        "act": sum(d["act"] for d in days), "faced": sum(d["faced"] for d in days),
        "ignored": sum(d["ignored"] for d in days), "preps": sum(d["prep"] for d in days),
        "stage": days[-1]["stage"], "comfort": sum(d.get("comfort", 0) for d in days) / len(days),
        "cold": sum(d["cold"] for d in days),
        "rest_opt": sum(1 for d in days if "fire" in d["options"] or "quiet" in d["options"]),
        "fire_opt": sum(1 for d in days if "fire" in d["options"]),
        "tend_opt": sum(1 for d in days if "tend" in d["options"]),
        "nopts": sum(len(d["options"]) for d in days) / len(days),
        "fire_rest": sum(1 for d in days if d["rest"] == "fire"),
        "quiet_rest": sum(1 for d in days if d["rest"] == "quiet"),
        "signs": sum(1 for d in days if d["sign"]),
    }


def stage_days(run):
    out = {}
    for k, v in run["milestones"].items():
        for s in ["boarded", "patched", "restored"]:
            if k == "step: " + s:
                out[s] = v
    return out


def table_windows(runs):
    lines = []
    wins = [("Days 1-7", dict(lo=1, hi=7)), ("Days 1-14", dict(lo=1, hi=14)), ("Days 1-30", dict(lo=1, hi=30)),
            ("First winter (Dec-Feb, days 62-151)", dict(lo=1, season="Winter")),
            ("Restored house (stage 3, natural progression)", dict(lo=1, stage=3)),
            ("Whole run (days 1-400)", dict(lo=1))]
    for title, w in wins:
        lines.append(f"\n### {title}\n")
        lines.append("| Style | Config | Start | End | Avg | Lowest | Mornings <40 | <20 | Night losses | Sleep + | Activities + | Faced | Left | Preps | Stage | Avg comfort 19:00 |")
        lines.append("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
        for st in STYLES:
            for c in CFGS:
                r = runs.get(f"{c}_{st}")
                if not r:
                    continue
                s = stats(window(r["days"], **w), r["days"])
                if not s:
                    lines.append(f"| {LABEL[st]} | {c} | (no days) |||||||||||||| |")
                    continue
                lines.append(f"| {LABEL[st]} | {c} | {s['start']:.0f} | {s['end']:.0f} | **{s['avg']:.1f}** | {s['low']:.0f} | {s['u40']} | {s['u20']} | {s['loss']:.0f} | {s['sleep']:.0f} | {s['act']:.0f} | {s['faced']} | {s['ignored']} | {s['preps']} | {s['stage']} | {s['comfort']:.0f} |")
    return lines


def table_activity(runs):
    lines = ["\n### Evening availability and choices (whole run, and days 1-14)\n",
             "| Style | Config | Evenings | Rest possible | Fire possible | Cold (no fire, no wood) | Tend possible | Choices at 19:00 (avg) | Rests by fire | Quiet hours | Preps | Sign evenings | Firewood: lit / tended |",
             "| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |"]
    for span, w in [("1-14", dict(lo=1, hi=14)), ("1-400", dict(lo=1))]:
        for st in STYLES:
            for c in ["A", "B"]:
                r = runs.get(f"{c}_{st}")
                if not r:
                    continue
                s = stats(window(r["days"], **w), r["days"])
                t = r["totals"]
                wood = f"{t['wood_fire']} / {t['wood_tend']}" if span == "1-400" else ""
                lines.append(f"| {LABEL[st]} | {c} ({span}) | {s['n']} | {s['rest_opt']} | {s['fire_opt']} | {s['cold']} | {s['tend_opt']} | {s['nopts']:.1f} | {s['fire_rest']} | {s['quiet_rest']} | {s['preps']} | {s['signs']} | {wood} |")
    return lines


def table_stages(runs):
    lines = ["\n### When the house reaches each stage (natural progression, first day)\n",
             "| Style | Config | Boarded | Patched | Restored |", "| --- | --- | --- | --- | --- |"]
    for st in STYLES:
        for c in ["A", "B"]:
            r = runs.get(f"{c}_{st}")
            if r:
                sd = stage_days(r)
                lines.append(f"| {LABEL[st]} | {c} | {sd.get('boarded', '-')} | {sd.get('patched', '-')} | {sd.get('restored', '-')} |")
    return lines


def table_controlled(runs):
    lines = ["\n### Controlled stage tests (CONTROLLED: the house is held at one stage from day 1; not natural progression), days 1-30\n",
             "| Style | Held stage | Avg morning | Lowest | Mornings <40 | <20 | Night losses | End |", "| --- | --- | --- | --- | --- | --- | --- | --- |"]
    for st in ["minimal", "cozy"]:
        for stg in range(4):
            r = runs.get(f"ctl_stage{stg}_{st}")
            if r:
                s = stats(window(r["days"], 1, 30), r["days"])
                lines.append(f"| {LABEL[st]} | {stg} | {s['avg']:.1f} | {s['low']:.0f} | {s['u40']} | {s['u20']} | {s['loss']:.0f} | {s['end']:.0f} |")
    return lines


# --- Charts ---

def axes(d, L, T, W, H, ymax, xmax, xstep, ystep, fs, xlabel=""):
    for v in range(0, ymax + 1, ystep):
        y = T + H - v / ymax * H
        d.line([(L, y), (L + W, y)], fill=GRID, width=1)
        d.text((L - 6, y), str(v), fill=INK2, font=fs, anchor="rm")
    for v in (range(0, xmax + 1, xstep) if xmax > 1 else []):
        x = L + v / xmax * W
        d.text((x, T + H + 10), str(v), fill=INK2, font=fs, anchor="mm")
    if xlabel:
        d.text((L + W / 2, T + H + 26), xlabel, fill=INK2, font=fs, anchor="mm")


def line(d, pts, col, width=2, dash=False):
    for i in range(len(pts) - 1):
        if dash and i % 2:
            continue
        d.line([pts[i], pts[i + 1]], fill=col, width=width)


def chart_first_month(runs, out):
    W, H = 1500, 560
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    fb, fs, f = font(20), font(12), font(14)
    d.text((24, 14), "Morning sanity, days 1-30, simulated: A baseline (grey) vs B proposed (colour)", fill=INK, font=fb)
    d.text((24, 42), "balance_sim.gd style runs, treks=3, seed 1. Dotted lines at 40 and 20 sanity. Natural progression (the house is boarded on day 1 and patched around day 13).", fill=INK2, font=fs)
    pw, ph, top = 262, 380, 110
    for i, st in enumerate(STYLES):
        L = 60 + i * (pw + 30)
        d.text((L, top - 26), LABEL[st], fill=INK, font=f)
        axes(d, L, top, pw, ph, 100, 30, 10, 20, fs, "day")
        for ref in (40, 20):
            y = top + ph - ref / 100 * ph
            for x in range(L, L + pw, 6):
                d.point((x, y), fill="#b0412e")
        for c, col, dash in [("A", "#b9b8b3", False), ("B", COL[st], False)]:
            r = runs.get(f"{c}_{st}")
            if not r:
                continue
            pts = [(L + dd["d"] / 30 * pw, top + ph - dd["morning"] / 100 * ph) for dd in r["days"] if dd["d"] <= 30]
            line(d, pts, col, 3 if c == "B" else 2, dash)
    img.save(out)


def chart_long(runs, out):
    W, H, L, T, PW, PH = 1500, 560, 70, 90, 1180, 380
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    fb, fs, f = font(20), font(12), font(14)
    d.text((24, 14), "Morning sanity over 400 days (B proposed), 14-day rolling mean, simulated", fill=INK, font=fb)
    d.text((24, 42), "Shaded: the first winter (days 62-151). Ticks under the axis: the day the cozy farmer's house reaches each stage.", fill=INK2, font=fs)
    x0 = L + 61 / 400 * PW
    x1 = L + 151 / 400 * PW
    d.rectangle([x0, T, x1, T + PH], fill="#eef2f7")
    axes(d, L, T, PW, PH, 100, 400, 50, 20, fs, "day")
    for st in STYLES:
        r = runs.get(f"B_{st}")
        if not r:
            continue
        v = [dd["morning"] for dd in r["days"]]
        pts = []
        for i in range(len(v)):
            win = v[max(0, i - 13): i + 1]
            pts.append((L + (i + 1) / 400 * PW, T + PH - sum(win) / len(win) / 100 * PH))
        line(d, pts, COL[st], 2)
    r = runs.get("B_cozy")
    if r:
        for name, day in stage_days(r).items():
            x = L + day / 400 * PW
            d.line([(x, T + PH), (x, T + PH + 6)], fill=INK, width=2)
            d.text((x + 3, T + PH + 40), name, fill=INK2, font=fs, anchor="lm")
    for j, st in enumerate(STYLES):
        y = T + 10 + j * 24
        d.line([(L + PW + 20, y), (L + PW + 44, y)], fill=COL[st], width=3)
        d.text((L + PW + 50, y), LABEL[st], fill=INK, font=fs, anchor="lm")
    img.save(out)


def chart_sensitivity(runs, out):
    W, H = 1500, 520
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    fb, fs, f = font(20), font(12), font(14)
    d.text((24, 14), "Average morning sanity by house-protection setting, simulated", fill=INK, font=fb)
    d.text((24, 42), "A = no house protection and no quiet hour (CCH-EVENING-001); C- weaker, B proposed, C+ stronger stage multipliers (all with the quiet hour).", fill=INK2, font=fs)
    spans = [("Days 1-14", 1, 14), ("Days 1-30", 1, 30), ("Days 1-400", 1, 400)]
    T, PH, gw = 100, 330, 470
    for k, (title, lo, hi) in enumerate(spans):
        L = 60 + k * (gw + 20)
        d.text((L, T - 22), title, fill=INK, font=f)
        axes(d, L, T, gw - 30, PH, 100, 1, 1, 20, fs)
        bw = (gw - 30) / len(STYLES)
        for i, st in enumerate(STYLES):
            for j, c in enumerate(CFGS):
                r = runs.get(f"{c}_{st}")
                if not r:
                    continue
                s = stats(window(r["days"], lo, hi), r["days"])
                x = L + i * bw + 6 + j * (bw - 12) / 4
                h = s["avg"] / 100 * PH
                d.rectangle([x, T + PH - h, x + (bw - 12) / 4 - 2, T + PH], fill=CFG_COL[c])
            d.text((L + i * bw + bw / 2, T + PH + 12), st, fill=INK2, font=fs, anchor="mm")
    for j, c in enumerate(CFGS):
        d.rectangle([60 + j * 300, H - 34, 72 + j * 300, H - 22], fill=CFG_COL[c])
        d.text((78 + j * 300, H - 28), CFG_LABEL[c], fill=INK, font=fs, anchor="lm")
    img.save(out)


def chart_activity(runs, out):
    W, H = 1500, 520
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    fb, fs, f = font(20), font(12), font(14)
    d.text((24, 14), "Evening options in the first 14 days: A baseline vs B proposed, simulated", fill=INK, font=fb)
    d.text((24, 42), "Bars count evenings out of 14. 'A rest possible' means the fire (A) or the fire or a quiet hour (B) could be chosen at 19:00.", fill=INK2, font=fs)
    keys = [("rest_opt", "A rest possible"), ("cold", "Cold: no fire, no wood"), ("fire_rest", "Rested by the fire"),
            ("quiet_rest", "Quiet hour taken"), ("tend_opt", "Tending possible"), ("preps", "Hearth tended")]
    T, rowh, L = 90, 66, 260
    for i, (k, lab) in enumerate(keys):
        y = T + i * rowh
        d.text((L - 12, y + 24), lab, fill=INK, font=f, anchor="rm")
        for j, st in enumerate(["cozy", "cautious", "balanced"]):
            for c_i, c in enumerate(["A", "B"]):
                r = runs.get(f"{c}_{st}")
                if not r:
                    continue
                s = stats(window(r["days"], 1, 14), r["days"])
                v = s[k]
                x = L + j * 380
                yy = y + c_i * 22
                d.rectangle([x, yy, x + v / 14 * 300, yy + 18], fill=COL[st] if c == "B" else "#c9c8c3")
                d.text((x + v / 14 * 300 + 6, yy + 9), f"{c}: {v}", fill=INK2, font=fs, anchor="lm")
    for j, st in enumerate(["cozy", "cautious", "balanced"]):
        d.text((L + j * 380, T - 18), LABEL[st] + " (grey A, colour B)", fill=INK, font=f)
    img.save(out)


def played(root, st):
    import re
    p = f"{root}/play_{st}/log_evening.txt"
    if not os.path.exists(p):
        return []
    return [json.loads(m.group(1)) for l in open(p, encoding="utf-8") for m in [re.search(r"\] EVE: (\{.*\})$", l)] if m]


def chart_played(out):
    W, H = 1500, 520
    img = Image.new("RGB", (W, H), SURF)
    d = ImageDraw.Draw(img)
    fb, fs, f = font(20), font(12), font(14)
    d.text((24, 14), "Morning sanity, PLAYED by injected input, 14 days: CCH-EVENING-001 (grey) vs CCH-EVENING-002 (colour)", fill=INK, font=fb)
    d.text((24, 42), "tools/evening_play.gd; the same days, signs and visitors in both builds (fixed by the day). Balanced is new in 002. Dotted lines at 40 and 20.", fill=INK2, font=fs)
    pw, ph, top = 262, 360, 110
    for i, st in enumerate(STYLES):
        L = 60 + i * (pw + 30)
        d.text((L, top - 26), LABEL[st], fill=INK, font=f)
        axes(d, L, top, pw, ph, 100, 15, 5, 20, fs, "morning of day")
        for ref in (40, 20):
            y = top + ph - ref / 100 * ph
            for x in range(L, L + pw, 6):
                d.point((x, y), fill="#b0412e")
        for root, col in [("art/style_tests/CCH-EVENING-001", "#b9b8b3"), (ROOT, COL[st])]:
            ev = played(root, st)
            pts = [(L + (e["day"] + 1) / 15 * pw, top + ph - e["morning_sanity"] / 100 * ph) for e in ev]
            line(d, pts, col, 3 if root == ROOT else 2)
    img.save(out)


def main():
    runs = load()
    os.makedirs(f"{ROOT}/out", exist_ok=True)
    os.makedirs(f"{ROOT}/review", exist_ok=True)
    lines = ["# CCH-EVENING-002 simulated balance tables", "",
             "All SIMULATED with tools/balance_sim.gd (style=, treks=3, seed 1, 400 days), via tools/evening2_sims.sh.",
             "Config A emulates CCH-EVENING-001 (shelter=1,1,1,1 quiet=0); B is the proposed balance; W and S are probes.",
             "Sanity values are mornings (after the night and the sleep). 'Lowest' includes the lowest point inside a day."]
    lines += table_windows(runs) + table_activity(runs) + table_stages(runs) + table_controlled(runs)
    open(f"{ROOT}/out/tables.md", "w", encoding="utf-8").write("\n".join(lines) + "\n")
    chart_first_month(runs, f"{ROOT}/review/chart_first_month.png")
    chart_long(runs, f"{ROOT}/review/chart_long.png")
    chart_sensitivity(runs, f"{ROOT}/review/chart_sensitivity.png")
    chart_activity(runs, f"{ROOT}/review/chart_activity.png")
    chart_played(f"{ROOT}/review/chart_played.png")
    print("ok", len(runs), "runs")


if __name__ == "__main__":
    main()
