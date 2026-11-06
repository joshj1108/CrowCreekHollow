#!/usr/bin/env bash
# ART-005 VS16-P1 (zero-generation, NON-PRODUCTION): renders matched VS16 and VS16-P1 frames in the clean export
# builds/review/ART-005/p1_export/, as VS16 did (same camera spots, farmer spot, hours and switches; only the cabin
# art differs). Frames go to <export>/builds/review/ART-005/vs16p1/ (gitignored).
#   python tools/vs16p1_cabin.py && bash tools/vs16p1_run.sh && python tools/vs16p1_review.py
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
E="$ROOT/builds/review/ART-005/p1_export"
G="${GODOT:-/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
cp "$ROOT/tools/hc1_audit.gd" "$ROOT/tools/hc2_density.gd" "$ROOT/tools/vs16_scene.gd" "$ROOT/tools/vs16p1_scene.gd" "$E/tools/"
mkdir -p "$E/art/style_tests/ART-005/vs16" "$E/art/style_tests/ART-005/vs16p1"
cp -r "$ROOT/art/style_tests/ART-005/vs16/cabin" "$E/art/style_tests/ART-005/vs16/"
cp -r "$ROOT/art/style_tests/ART-005/vs16p1/cabin" "$E/art/style_tests/ART-005/vs16p1/"
O=builds/review/ART-005/vs16p1
BASE="mode=wide layout=b grass=1 art=f2 house=g7:c2 cabin16"
mkdir -p "$E/$O"
cd "$E"
run() { local name=$1; shift; "$G" --path . -s tools/vs16p1_scene.gd -- $BASE "$@" out=$O/$name.png > "$O/log_$name.txt" 2>&1; grep -h "saved\|ERROR" "$O/log_$name.txt"; }
# home: cabin, golden oak, well and farmer (VS16's framing); door: the farmer beside the cabin door.
for v in vs16 p1; do
  X=""; [ "$v" = p1 ] && X=p1
  for t in "day 12" "night 21.5"; do set -- $t
    run "home_${v}_$1" $X at=38.5,10.5 hour=$2
    run "door_${v}_$1" $X at=45,13 hour=$2
  done
done
