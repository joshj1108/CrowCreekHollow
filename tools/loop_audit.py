"""CCH-LOOP-001: turns tools/loop_audit.gd's LOOP lines into the audit's tables and charts.

    python tools/loop_audit.py art/style_tests/CCH-LOOP-001/logs art/style_tests/CCH-LOOP-001/out

Reads loop_<style>.log for each play style. Writes tables.md (markdown tables pasted into the report) and SVG charts
(rasterised to PNG by tools/svg_to_png.gd). SIMULATED evidence: the sim does each block's work through the game's own
functions with no walking; time is ESTIMATED from counts x unit times measured in the input-driven play logs
(UNIT_MIN below, with where each was measured). Nothing here is a measured human engagement score.
"""
import json, os, sys, collections

LOG_DIR, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
STYLES = ["relaxed", "explorer", "progression", "balanced", "earlybed"]
STYLE_NAME = {"relaxed": "A. Relaxed farmer", "explorer": "B. Explorer", "progression": "C. Progression-focused",
              "balanced": "D. Balanced", "earlybed": "E. Tutorial early-bed"}

# Game minutes per action, measured from the CCH-PLAYABLE-002 input-driven week logs (see the report's method
# section). Walking between places is in TRAVEL_PER_BLOCK, one round of the farm per outdoor block that did work.
UNIT_MIN = {
    # median game minutes between the bot's messages for each action in the CCH-PLAYABLE-001 input-driven weeks,
    # which include the walk to the thing (planting and watering a row are quick after the first).
    "planted": 4, "watered": 5, "harvested": 4,               # farming
    "gathered": 18, "felled": 20, "mined": 10, "foraged": 25,  # gathering (walks across the farm)
    "eaten": 2, "drank": 30,                                   # survival (the walk to the pond)
    "sold": 1, "cooked": 6, "crafted": 5,                      # trading, crafting
    "tidied": 10, "mended": 10, "cleansed": 10,                # house (building)
    "caught": 20, "fished": 0, "faced": 30, "jobs": 10,
}
BRISK = 0.6            # a practised player: 60% of the bot's pace (an assumption, reported as a band)
STAND_VISIT = 20       # walking to the stand and the panel, once per block with sales
TRAVEL_PER_BLOCK = 15  # leaving the house and coming back, per outdoor block that did any work
TREK_HOURS = 2.5       # one walk through the Rookery Wood, gate to gate (sim estimate 0.5 + 0.75 per clearing)
FOLK_MIN = 15          # a word, a scene or a request with a walker on the farm
CATEGORY = {
    "planted": "Farming", "watered": "Farming", "harvested": "Farming",
    "gathered": "Gathering", "felled": "Gathering", "mined": "Gathering", "foraged": "Gathering",
    "eaten": "Survival", "drank": "Survival", "caught": "Survival",
    "sold": "Trading", "cooked": "Crafting", "crafted": "Crafting",
    "tidied": "Building", "mended": "Building", "cleansed": "Building", "jobs": "Building",
    "faced": "Combat/night",
}
CATS = ["Farming", "Gathering", "Survival", "Crafting", "Trading", "Building", "Exploration", "Narrative", "Travel"]
COLORS = {"Farming": "#2a78d6", "Gathering": "#eb6834", "Survival": "#1baf7a", "Crafting": "#eda100",
          "Trading": "#e87ba4", "Building": "#008300", "Exploration": "#6250d6", "Narrative": "#e34948",
          "Travel": "#9a9890", "Unfilled": "#e4e2dc"}
WORTH_KEYS = ["water", "harvest", "plant", "forage", "brush", "fell", "rocks", "cave", "sell", "catalog", "craft",
              "cook", "tidy", "mend", "repair", "cleanse", "animals", "folk", "trek", "happening", "night"]
NON_CHORE = ["cave", "craft", "cook", "repair", "folk", "trek", "happening", "catalog", "rocks", "fell"]


def load(style):
    days = []
    path = os.path.join(LOG_DIR, "loop_%s.log" % style)
    if not os.path.exists(path):
        return days
    for line in open(path, encoding="utf-8", errors="replace"):
        if line.startswith("LOOP "):
            days.append(json.loads(line[5:]))
    return days


def day_minutes(d):
    mins = collections.Counter()
    for bname, b in d["blocks"].items():
        if not isinstance(b, dict):
            continue
        work = False
        for k, n in b.items():
            if k in UNIT_MIN and k in CATEGORY and n > 0:
                mins[CATEGORY[k]] += UNIT_MIN[k] * n
                if k not in ("eaten", "faced"):
                    work = True
        if b.get("sold", 0) > 0:
            mins["Trading"] += STAND_VISIT
        if work and bname in ("morning_out", "afternoon", "evening"):
            mins["Travel"] += TRAVEL_PER_BLOCK
    treks = d["blocks"].get("trek", 0)
    if treks:
        mins["Exploration"] += treks * TREK_HOURS * 60
    for cp in d["checkpoints"]:
        if cp["at"].startswith("13") and cp["acts"].get("folk") == "worth":
            mins["Narrative"] += FOLK_MIN
        if cp["at"].startswith("07") and cp["acts"].get("happening") == "worth":
            mins["Narrative"] += 10
    night = mins.pop("Combat/night", 0)
    return mins, night


def waking(style):
    # 06:00 to the hour the style stops: the night's visitor at 22:00 (engaged and ignore) or bed at 21:00.
    return (21 - 6) * 60 if style == "earlybed" else (22 - 6) * 60


def worth_count(acts, keys=WORTH_KEYS):
    return sum(1 for k in keys if acts.get(k) == "worth")


# Fresh = something new worth doing. The night is counted apart. The cave is a daily loop with a new layout, counted
# as repeatable. After the sim's morning work (13:00, 19:00) open soil with seed in hand is soil it chose to leave
# (sprinkler spots, a crop that would not ripen in time), so planting is not counted then.
FRESH = [k for k in WORTH_KEYS if k not in ("night", "cave")]
FRESH_LATER = [k for k in FRESH if k != "plant"]


def fresh_count(acts, later=False):
    return worth_count(acts, FRESH_LATER if later else FRESH)


def nothing_at_all(acts):
    return fresh_count(acts, True) == 0 and not any(v in ("repeat", "leisure") for v in acts.values())


def progress_events(prev, d):
    ev = []
    if prev is None:
        return ev
    if d["chapter"] != prev["chapter"]:
        ev.append("chapter")
    if d["step"] != prev["step"]:
        ev.append("homestead step")
    if d["house"] != prev["house"]:
        ev.append("house stage")
    if d["lantern"] != prev["lantern"]:
        ev.append("lantern")
    if d["blocks"].get("trek", 0):
        ev.append("trek")
    made = sum(b.get("crafted", 0) for b in d["blocks"].values() if isinstance(b, dict))
    if made > 0:
        ev.append("made %d" % made)
    return ev


def kinds_done(d):
    s = set()
    for b in d["blocks"].values():
        if isinstance(b, dict):
            for k, n in b.items():
                if k in CATEGORY and n > 0:
                    s.add(k)
    if d["blocks"].get("trek", 0):
        s.add("trek")
    return s


STYLE_DATA = {s: load(s) for s in STYLES}
md = []


def table(head, rows):
    md.append("| " + " | ".join(head) + " |")
    md.append("| " + " | ".join("---" for _ in head) + " |")
    for r in rows:
        md.append("| " + " | ".join(str(c) for c in r) + " |")
    md.append("")


def summarize(style, days):
    W = waking(style)
    out = []
    prev = None
    prev_kinds = set()
    for d in days:
        mins, night = day_minutes(d)
        active = min(W, sum(mins.values()))
        cps = {cp["at"][:5]: cp["acts"] for cp in d["checkpoints"]}
        avail = {k: fresh_count(v, k in ("13:00", "19:00")) for k, v in cps.items()}
        after = cps.get("13:00", {})
        dusk = cps.get("19:00", {})
        # Unfilled time is split by what was on offer once the sim's work was done (13:00 and 19:00 checkpoints):
        # no worthwhile thing left but chores -> forced; only repeatable or leisure things left -> optional.
        idle = W - active
        # Unfilled time is split by what was still on offer at 13:00 and 19:00, half each: nothing at all ->
        # forced; only repeatable work or leisure (felling, fishing, the cave again, cooking, a pastime) -> low
        # choice; at least one fresh worthwhile thing -> free with choices.
        forced_share = (0.5 if nothing_at_all(after) else 0) + (0.5 if nothing_at_all(dusk) else 0)
        low_share = (0.5 if fresh_count(after, True) == 0 and not nothing_at_all(after) else 0) +                     (0.5 if fresh_count(dusk, True) == 0 and not nothing_at_all(dusk) else 0)
        kinds = kinds_done(d)
        rep = len(kinds & prev_kinds) / len(kinds) if kinds else 1.0
        ev = progress_events(prev, d)
        out.append({"day": d["day"], "season": d["season"], "weather": d["weather"], "sanity": d["sanity"],
                    "mins": mins, "active": active, "idle": idle, "forced": idle * forced_share,
                    "optional": idle * (1 - forced_share - low_share), "low": idle * low_share, "avail": avail, "after": after, "dusk": dusk,
                    "cats": sum(1 for c in CATS if mins.get(c, 0) > 0), "rep": rep, "events": ev,
                    "chapter": d["chapter"], "step": d["step"], "night": d["night"], "W": W, "nightmin": night})
        prev = d
        prev_kinds = kinds
    # Days until the next progress event, from each day.
    for i, r in enumerate(out):
        nxt = next((j for j in range(i + 1, len(out)) if out[j]["events"] and any(not e.startswith("made") or True for e in out[j]["events"])), None)
        r["to_next"] = (out[nxt]["day"] - r["day"]) if nxt is not None else None
    return out


S = {s: summarize(s, STYLE_DATA[s]) for s in STYLES if STYLE_DATA[s]}


def hm(m):
    return "%d:%02d" % (int(m) // 60, int(m) % 60)


# --- First 14 days, balanced style ---------------------------------------------------------------------------
md.append("### First 14 days, D. Balanced (simulated, estimated minutes; waking window 06:00-22:00 = 16:00)\n")
rows = []
for r in S.get("balanced", [])[:14]:
    rows.append([r["day"], r["weather"], r["sanity"], hm(r["mins"].get("Farming", 0)), hm(r["mins"].get("Gathering", 0)),
                 hm(r["mins"].get("Survival", 0)), hm(r["mins"].get("Crafting", 0) + r["mins"].get("Trading", 0)),
                 hm(r["mins"].get("Building", 0)), hm(r["mins"].get("Exploration", 0)), hm(r["mins"].get("Travel", 0)),
                 hm(r["active"]), "%d%%" % round(100 * r["active"] / r["W"]),
                 "%s / %s / %s" % (r["avail"].get("07:00", 0), r["avail"].get("13:00", 0), r["avail"].get("19:00", 0)),
                 ", ".join(r["events"]) or "-"])
table(["Day", "Weather", "Sanity", "Farm", "Gather", "Survive", "Craft+trade", "House", "Trek", "Travel", "Active", "Active %",
       "Worth doing 07/13/19", "Progress"], rows)

# --- Style comparison ---------------------------------------------------------------------------------------
def avg(xs):
    xs = list(xs)
    return sum(xs) / len(xs) if xs else 0


md.append("### Play styles over 400 simulated days\n")
rows = []
for s, rs in S.items():
    rows.append([STYLE_NAME[s], "%d%% (%d%%)" % (round(100 * avg(r["active"] / r["W"] for r in rs)), round(100 * BRISK * avg(r["active"] / r["W"] for r in rs))),
                 "%d%%" % round(100 * avg(r["forced"] / r["W"] for r in rs)),
                 "%d%%" % round(100 * avg(r["low"] / r["W"] for r in rs)),
                 "%d%%" % round(100 * avg(r["optional"] / r["W"] for r in rs)),
                 "%.1f" % avg(r["cats"] for r in rs),
                 "%.1f / %.1f / %.1f" % (avg(r["avail"].get("07:00", 0) for r in rs), avg(r["avail"].get("13:00", 0) for r in rs), avg(r["avail"].get("19:00", 0) for r in rs)),
                 "%d%%" % round(100 * avg(1 if r["events"] else 0 for r in rs)),
                 "%.0f%%" % (100 * avg(r["rep"] for r in rs)),
                 "%.1f" % avg(r["to_next"] for r in rs if r["to_next"] is not None)])
table(["Style", "Active, bot pace (brisk)", "Forced idle", "Low-choice free", "Free with fresh choices", "Categories/day", "Worth doing 07/13/19", "Days with progress",
       "Repetition", "Days to next progress"], rows)

# --- Seasons, balanced -----------------------------------------------------------------------------------------
md.append("### Seasons, D. Balanced (first year; days averaged per season)\n")
rows = []
seasons = collections.OrderedDict()
for r in S.get("balanced", []):
    key = ("Y1 " if r["day"] <= 334 else "Y2 ") + r["season"]
    seasons.setdefault(key, []).append(r)
for k, rs in seasons.items():
    m = collections.Counter()
    for r in rs:
        m.update(r["mins"])
    n = len(rs)
    rows.append([k, "%d-%d" % (rs[0]["day"], rs[-1]["day"]), hm(m["Farming"] / n), hm(m["Gathering"] / n), hm(m["Exploration"] / n),
                 hm((m["Crafting"] + m["Trading"] + m["Building"]) / n), "%d%%" % round(100 * avg(r["active"] / r["W"] for r in rs)),
                 "%d%%" % round(100 * avg(r["low"] / r["W"] for r in rs)),
                 "%.1f" % avg(r["avail"].get("13:00", 0) for r in rs), "%.1f" % avg(r["avail"].get("19:00", 0) for r in rs),
                 "%d%%" % round(100 * avg(1 if r["events"] else 0 for r in rs))])
table(["Season", "Days", "Farm", "Gather", "Trek", "Craft/trade/house", "Active", "Low-choice free", "Worth doing 13:00", "Worth doing 19:00",
       "Days with progress"], rows)

# --- Activity availability at each checkpoint (balanced) -------------------------------------------------------
md.append("### What was on offer, by checkpoint (D. Balanced, share of days each status, 400 days)\n")
rows = []
bal = STYLE_DATA.get("balanced", [])
for key in WORTH_KEYS + ["fish", "pastime"]:
    row = [key]
    for at in ["06:00", "07:00", "13:00", "19:00", "22:00"]:
        cnt = collections.Counter()
        for d in bal:
            for cp in d["checkpoints"]:
                if cp["at"].startswith(at):
                    cnt[cp["acts"].get(key, "-")] += 1
        tot = sum(cnt.values()) or 1
        top = ", ".join("%s %d%%" % (k, round(100 * v / tot)) for k, v in cnt.most_common(2))
        row.append(top)
    rows.append(row)
table(["Activity", "06:00", "07:00", "13:00", "19:00", "22:00"], rows)

# --- Stage contrast ------------------------------------------------------------------------------------------
md.append("### Early, mid and late game (D. Balanced)\n")
rows = []
for name, lo, hi in [("Days 1-14", 1, 14), ("Days 15-60", 15, 60), ("Days 61-180", 61, 180), ("Days 181-300", 181, 300), ("Days 301-400", 301, 400)]:
    rs = [r for r in S.get("balanced", []) if lo <= r["day"] <= hi]
    if not rs:
        continue
    rows.append([name, "%d%%" % round(100 * avg(r["active"] / r["W"] for r in rs)), "%d%%" % round(100 * avg(r["low"] / r["W"] for r in rs)),
                 "%.1f" % avg(r["avail"].get("13:00", 0) for r in rs), "%.1f" % avg(r["avail"].get("19:00", 0) for r in rs),
                 "%d%%" % round(100 * avg(1 if r["events"] else 0 for r in rs)), "%.0f%%" % (100 * avg(r["rep"] for r in rs)),
                 "%.1f" % avg(r["to_next"] for r in rs if r["to_next"] is not None)])
table(["Stage", "Active", "Low-choice free", "Worth doing 13:00", "Worth doing 19:00", "Days with progress", "Repetition", "Days to next progress"], rows)

# --- Longest stretches with no progress event -------------------------------------------------------------------
md.append("### Longest stretches with no progress event (no chapter, homestead step, house, lantern, trek or new thing made)\n")
rows = []
for s, rs in S.items():
    best = []
    run_start = None
    for r in rs:
        if r["events"]:
            if run_start is not None:
                best.append((r["day"] - run_start, run_start, r["day"] - 1))
            run_start = None
        elif run_start is None:
            run_start = r["day"]
    best.sort(reverse=True)
    rows.append([STYLE_NAME[s], "; ".join("%d days (%d-%d)" % b for b in best[:3]) or "-"])
table(["Style", "Three longest gaps"], rows)

open(os.path.join(OUT, "tables.md"), "w", encoding="utf-8").write("\n".join(md))


# --- Charts (SVG; light surface, fixed category order, legend, values in ink) ------------------------------------
def svg_stacked(path, title, subtitle, labels, series, total, ylab):
    W, H, L, R, T, B = 1100, 520, 70, 200, 70, 50
    pw, ph = W - L - R, H - T - B
    n = len(labels)
    bw = pw / n
    o = ['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" font-family="Segoe UI, Arial" font-size="13">' % (W, H),
         '<rect width="100%" height="100%" fill="#fcfcfb"/>',
         '<text x="%d" y="30" font-size="18" fill="#0b0b0b" font-weight="600">%s</text>' % (L, title),
         '<text x="%d" y="52" fill="#52514e">%s</text>' % (L, subtitle)]
    for g in range(0, total + 1, total // 4):
        y = T + ph - ph * g / total
        o.append('<line x1="%d" x2="%d" y1="%.1f" y2="%.1f" stroke="#e4e2dc"/>' % (L, L + pw, y, y))
        o.append('<text x="%d" y="%.1f" text-anchor="end" fill="#52514e">%s</text>' % (L - 6, y + 4, ylab(g)))
    for i, lab in enumerate(labels):
        y0 = T + ph
        x = L + i * bw + 2
        for name, vals in series:
            v = vals[i]
            if v <= 0:
                continue
            h = ph * v / total
            o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>' % (x, y0 - h + 1, max(1, bw - 4), max(0, h - 2), COLORS.get(name, "#999")))
            y0 -= h
        if n <= 40 or i % 5 == 0:
            o.append('<text x="%.1f" y="%d" text-anchor="middle" fill="#52514e" font-size="11">%s</text>' % (x + bw / 2 - 2, T + ph + 16, lab))
    for j, (name, _) in enumerate(series):
        y = T + 10 + j * 22
        o.append('<rect x="%d" y="%d" width="14" height="14" rx="3" fill="%s"/>' % (L + pw + 20, y, COLORS.get(name, "#999")))
        o.append('<text x="%d" y="%d" fill="#0b0b0b">%s</text>' % (L + pw + 40, y + 12, name))
    o.append("</svg>")
    open(path, "w", encoding="utf-8").write("\n".join(o))


bal = S.get("balanced", [])
if bal:
    first = bal[:14]
    series = [(c, [r["mins"].get(c, 0) for r in first]) for c in CATS] + [("Unfilled", [max(0, r["W"] - r["active"]) for r in first])]
    svg_stacked(os.path.join(OUT, "first14_minutes.svg"), "First 14 days: estimated game minutes by activity (D. Balanced, simulated)",
                "Waking window 06:00-22:00. 'Unfilled' = time the sim's day leaves free; see the report for forced vs optional.",
                ["D%d" % r["day"] for r in first], series, 960, lambda g: "%02d:00" % (g // 60))
    weeks = []
    for i in range(0, len(bal), 7):
        wk = bal[i:i + 7]
        weeks.append(wk)
    series = [(c, [avg(r["mins"].get(c, 0) for r in wk) for wk in weeks]) for c in CATS] + \
             [("Unfilled", [avg(max(0, r["W"] - r["active"]) for r in wk) for wk in weeks])]
    svg_stacked(os.path.join(OUT, "year_minutes.svg"), "400 days, week by week: estimated minutes a day by activity (D. Balanced, simulated)",
                "Average per day in each week. Waking window 06:00-22:00.", ["W%d" % (i + 1) for i in range(len(weeks))], series, 960,
                lambda g: "%02d:00" % (g // 60))
    # Worth-doing counts by checkpoint for each style, early vs late.
    labels, s1, s2, s3 = [], [], [], []
    for s, rs in S.items():
        for nm, lo, hi in [("1-14", 1, 14), ("61-180", 61, 180), ("301-400", 301, 400)]:
            sub = [r for r in rs if lo <= r["day"] <= hi]
            labels.append("%s %s" % (s[:5], nm))
            s1.append(avg(r["avail"].get("07:00", 0) for r in sub))
            s2.append(avg(r["avail"].get("13:00", 0) for r in sub))
            s3.append(avg(r["avail"].get("19:00", 0) for r in sub))
    o = ['<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="580" font-family="Segoe UI, Arial" font-size="13">',
         '<rect width="100%" height="100%" fill="#fcfcfb"/>',
         '<text x="70" y="30" font-size="18" fill="#0b0b0b" font-weight="600">Worthwhile things on offer at 07:00, 13:00 and 19:00 (simulated)</text>',
         '<text x="70" y="52" fill="#52514e">Average count per day, by style and stage. After the sim has done its work for the block.</text>']
    L, T, pw, ph = 70, 70, 830, 400  # labels below, in a 580 px tall chart
    top = max(s1 + s2 + s3 + [1])
    top = int(top) + 1
    for g in range(0, top + 1):
        y = T + ph - ph * g / top
        o.append('<line x1="%d" x2="%d" y1="%.1f" y2="%.1f" stroke="#e4e2dc"/>' % (L, L + pw, y, y))
        o.append('<text x="%d" y="%.1f" text-anchor="end" fill="#52514e">%d</text>' % (L - 6, y + 4, g))
    gw = pw / len(labels)
    for i, lab in enumerate(labels):
        for j, (vals, col) in enumerate([(s1, "#2a78d6"), (s2, "#eb6834"), (s3, "#1baf7a")]):
            h = ph * vals[i] / top
            x = L + i * gw + 4 + j * (gw - 8) / 3
            o.append('<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="2" fill="%s"/>' % (x, T + ph - h, (gw - 8) / 3 - 2, h, col))
        o.append('<text x="%.1f" y="%d" text-anchor="end" fill="#52514e" font-size="11" transform="rotate(-40 %.1f %d)">%s</text>' % (L + i * gw + gw / 2, T + ph + 14, L + i * gw + gw / 2, T + ph + 14, lab))
    for j, (nm, col) in enumerate([("07:00", "#2a78d6"), ("13:00", "#eb6834"), ("19:00", "#1baf7a")]):
        o.append('<rect x="920" y="%d" width="14" height="14" rx="3" fill="%s"/><text x="940" y="%d" fill="#0b0b0b">%s</text>' % (80 + j * 22, col, 92 + j * 22, nm))
    o.append("</svg>")
    open(os.path.join(OUT, "availability.svg"), "w", encoding="utf-8").write("\n".join(o))
print("wrote", OUT)
