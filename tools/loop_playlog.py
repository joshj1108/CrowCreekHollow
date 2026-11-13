"""CCH-LOOP-001: daily timelines from the input-driven play logs (tools/audit_play.gd, log_week.txt).

    python tools/loop_playlog.py art/style_tests/CCH-PLAYABLE-002/play_kbm/log_week.txt [more logs] > timeline.md

PLAYED evidence (injected input in the real game), kept apart from the simulation. Every game-clock minute from 06:00
to the moment the bot went to bed is given to the activity of the next thing the game said or the bot did (the walk
to a thing counts towards it), using the keyword table below. A gap of more than GAP minutes with no message and no
action is "Waiting". The bot follows the tutorial (to bed at about 19:15), so its evenings show what that advice does,
not what an evening could hold.
"""
import re, sys, collections

GAP = 45
RULES = [  # (category, substrings in the MSG/ACT text), first match wins
    ("Exploration", ["Rookery Wood", "into the trees", "clearing", "Maren", "the trail", "trek", "the wood's edge", "stile", "walker"]),
    ("Combat", ["strikes you", "You hit", "You miss", "You kill", "defeated", "guard", "swing"]),
    ("Narrative", ["diary", "Chapter", "Next:", "Done:", "page", "letter", "mailbox", "Achievement", "vicar", "pedlar", "Agnes"]),
    ("Farming", ["Planted", "Planting", "Watered", "water", "harvest", "Harvest", "seed", "crop", "trowel", "hose", "bucket"]),
    ("Gathering", ["Gathered", "brush", "fell the tree", "chopping", "Chip", "pick", "You break", "ore", "forage"]),
    ("Survival", ["drink", "eat", "You eat", "thirst", "hunger", "fire", "hearth", "warm", "chilled"]),
    ("Crafting", ["You make", "craft", "Craft", "hatchet", "lantern", "Lantern", "cook"]),
    ("Trading", ["sell", "You sell", "coins", "order", "catalog", "Catalog"]),
    ("Building", ["repair", "Repair", "mend", "tidy", "Boarded", "House"]),
    ("Travel", ["step inside", "step back out", "cave", "You step"]),
]


def cat(text):
    for c, keys in RULES:
        for k in keys:
            if k in text:
                return c
    return "Other"


def parse(path):
    """Days in file order: a day runs from 06:00 until its "You sleep through the night" (or collapse) line, whose
    day label is already the next day's."""
    days = collections.OrderedDict()
    day = None
    ev = []
    for line in open(path, encoding="utf-8", errors="replace"):
        m = re.match(r"\[D(\d+) (\d\d):(\d\d)\] (MSG|ACT|OBS|PROBLEM): (.*)", line)
        if not m:
            continue
        d, h, mi, kind, text = int(m.group(1)), int(m.group(2)), int(m.group(3)), m.group(4), m.group(5)
        t = (h if h >= 6 else h + 24) * 60 + mi
        if day is None:
            day = d
        ending = kind == "MSG" and (text.startswith("You sleep through the night") or text.startswith("You collapse before reaching"))
        if ending:
            days[day] = _close(ev, t)
            day = None
            ev = []
            continue
        if kind in ("MSG", "ACT"):
            ev.append((t, text))
    if ev:
        days[day] = _close(ev, ev[-1][0])
    return days


def _close(ev, end):
    mins = collections.Counter()
    cur = 6 * 60
    blocks = []
    for t, text in ev:
        if t > end or t < cur - 600:
            continue
        gap = t - cur
        c = cat(text)
        if gap > GAP:
            mins["Waiting"] += gap
            blocks.append((cur, t, "Waiting"))
        elif gap > 0:
            mins[c] += gap
            blocks.append((cur, t, c))
        cur = max(cur, t)
    return {"mins": mins, "end": end, "blocks": blocks}


def hm(m):
    return "%02d:%02d" % ((m // 60) % 24, m % 60)


CATS = ["Farming", "Gathering", "Survival", "Crafting", "Trading", "Building", "Exploration", "Combat", "Narrative", "Travel", "Other", "Waiting"]
for path in sys.argv[1:]:
    days = parse(path)
    print("#### %s\n" % path)
    print("| Day | To bed | " + " | ".join(CATS) + " | Played window |")
    print("| --- | --- | " + " | ".join("---" for _ in CATS) + " | --- |")
    for d, r in days.items():
        tot = r["end"] - 360
        print("| %d | %s | " % (d, hm(r["end"])) + " | ".join(str(r["mins"].get(c, 0)) for c in CATS) + " | %d min |" % tot)
    print()
    # Merged hour-by-hour timeline per day: each block of 60 game minutes gets its main activity.
    print("Hour by hour (main activity in each game hour; '.' = in bed):\n")
    print("| Day | " + " | ".join("%02d" % (h % 24) for h in range(6, 24)) + " |")
    print("| --- | " + " | ".join("---" for _ in range(6, 24)) + " |")
    for d, r in days.items():
        row = []
        for h in range(6, 24):
            lo, hi = h * 60, h * 60 + 60
            share = collections.Counter()
            for a, b, c in r["blocks"]:
                ov = max(0, min(b, hi) - max(a, lo))
                if ov:
                    share[c] += ov
            row.append(share.most_common(1)[0][0][:5] if share else ".")
        print("| %d | " % d + " | ".join(row) + " |")
    print()
