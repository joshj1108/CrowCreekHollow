"""FARM-001 (one-off): join the day and night exports of tools/concept_export.gd into art/farm/concept/scenery.json.

The two runs build the same scene, so their sprites line up one for one; only tints (forest shade, the dimmer
hill at night) and a few textures (the cabin's lit windows) differ. Usage: python3 tools/concept_merge.py
"""
import json
import os

DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "art", "farm", "concept")


def main():
    day = json.load(open(os.path.join(DIR, "day.json")))
    night = json.load(open(os.path.join(DIR, "night.json")))
    assert len(day["sprites"]) == len(night["sprites"]), "day and night differ in sprite count"
    out = []
    swapped = 0
    for d, n in zip(day["sprites"], night["sprites"]):
        assert abs(d["x"] - n["x"]) < 0.5 and abs(d["y"] - n["y"]) < 0.5 and d["b"] == n["b"], (d, n)
        r = {k: d[k] for k in ("t", "x", "y", "s", "fh", "m", "z", "b", "tx", "ty", "forest")}
        r["x"], r["y"] = round(d["x"], 2), round(d["y"], 2)
        if n["m"] != d["m"]:
            r["mn"] = n["m"]
        if n["t"] != d["t"]:
            r["tn"] = n["t"]
            swapped += 1
        out.append(r)
    chunks = []
    for d, n in zip(sorted(day["chunks"], key=lambda c: c["t"]), sorted(night["chunks"], key=lambda c: c["t"])):
        assert d["x"] == n["x"] and d["y"] == n["y"]
        chunks.append({"t": d["t"], "tn": n["t"], "x": d["x"], "y": d["y"], "s": d["s"]})
    json.dump({"chunks": chunks, "sprites": out, "house_at": day["house_at"]},
              open(os.path.join(DIR, "scenery.json"), "w", newline="\n"), separators=(",", ":"))
    os.remove(os.path.join(DIR, "day.json"))
    os.remove(os.path.join(DIR, "night.json"))
    print("scenery.json: %d chunks, %d sprites (%d with a night texture, %d with a night tint)"
          % (len(chunks), len(out), swapped, sum(1 for r in out if "mn" in r)))


if __name__ == "__main__":
    main()
