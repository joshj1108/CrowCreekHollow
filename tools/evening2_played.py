"""CCH-EVENING-002: summarises the played runs (tools/evening_play.gd logs) for the report.
  python tools/evening2_played.py [root]   (default art/style_tests/CCH-EVENING-002)
Reads each play_<style>/log_evening.txt's EVE lines (one per evening) and prints, per style: evenings played, the
mornings' sanity (day 8 and day 15 mornings, lowest, mornings under 40 / 20), bed times, busy / waiting game hours,
rests taken (fire, quiet hour), tends, signs read, visitors faced or left alone. CCH-EVENING-001's runs, where they
exist, are printed alongside for the same style. PLAYED by injected input; a bot, not a human.
"""
import json
import os
import re
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "art/style_tests/CCH-EVENING-002"
OLD = "art/style_tests/CCH-EVENING-001"
STYLES = ["cozy", "cautious", "curious", "balanced", "minimal"]


def load(root, st):
    p = f"{root}/play_{st}/log_evening.txt"
    if not os.path.exists(p):
        return []
    out = []
    for line in open(p, encoding="utf-8"):
        m = re.search(r"\] EVE: (\{.*\})$", line.rstrip())
        if m:
            out.append(json.loads(m.group(1)))
    return out


def hm(h):
    return f"{int(h)}:{int(round((h % 1) * 60)):02d}"


def summary(ev):
    if not ev:
        return None
    ms = [e["morning_sanity"] for e in ev]
    by_day = {e["day"]: e["morning_sanity"] for e in ev}
    beds = [e["bed_at"] for e in ev if e.get("bed_at")]
    return {
        "evenings": len(ev),
        "d8": by_day.get(7, "-"),
        "last": ms[-1],
        "last_day": ev[-1]["day"] + 1,
        "lowest": min(ms),
        "u40": sum(1 for v in ms if v < 40),
        "u20": sum(1 for v in ms if v < 20),
        "bed": f"{hm(min(beds))}-{hm(max(beds))}" if beds else "-",
        "busy": round(sum(e.get("busy_h", 0) for e in ev), 1),
        "idle": round(sum(e.get("idle_h", 0) for e in ev), 1),
        "sat": sum(1 for e in ev if e.get("sat")),
        "quiet": sum(1 for e in ev if e.get("quiet")),
        "tended": sum(1 for e in ev if e.get("tended")),
        "read": sum(1 for e in ev if e.get("read")),
        "faced": sum(1 for e in ev if e.get("night_faced")),
        "alone": sum(1 for e in ev if e.get("visitor") and e.get("night_left_alone")),
    }


def main():
    print("| Style | Evenings | Morning d8 | Last morning | Lowest | <40 / <20 | Bed | Busy / waiting h | Fire / quiet / tend | Signs read | Visitors faced / left |")
    print("| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |")
    for st in STYLES:
        for tag, root in [("002", ROOT), ("001", OLD)]:
            s = summary(load(root, st))
            if not s:
                continue
            print(f"| {st} ({tag}) | {s['evenings']} | {s['d8']} | {s['last']} (day {s['last_day']}) | {s['lowest']} | "
                  f"{s['u40']} / {s['u20']} | {s['bed']} | {s['busy']} / {s['idle']} | {s['sat']} / {s['quiet']} / {s['tended']} | "
                  f"{s['read']} | {s['faced']} / {s['alone']} |")


if __name__ == "__main__":
    main()
