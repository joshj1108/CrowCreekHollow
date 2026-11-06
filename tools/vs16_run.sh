#!/usr/bin/env bash
# ART-005 VS16 (zero-generation, NON-PRODUCTION): renders the 16 px vertical-slice frames in the clean export
# builds/review/ART-005/p1_export/ (HEAD's art and code plus the C2 cabin), exactly as HC1/HC2 did. Copies the
# harness chain and the study art in first. Frames go to <export>/builds/review/ART-005/vs16/ (gitignored).
#   python tools/vs16_cabin.py && bash tools/vs16_run.sh && python tools/vs16_review.py
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
E="$ROOT/builds/review/ART-005/p1_export"
G="${GODOT:-/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
cp "$ROOT/tools/hc1_audit.gd" "$ROOT/tools/hc2_density.gd" "$ROOT/tools/vs16_scene.gd" "$E/tools/"
mkdir -p "$E/art/style_tests/ART-005/vs16"
cp -r "$ROOT/art/style_tests/ART-005/vs16/cabin" "$E/art/style_tests/ART-005/vs16/"
O=builds/review/ART-005/vs16
BASE="mode=wide layout=b grass=1 art=f2 house=g7:c2"
mkdir -p "$E/$O"
cd "$E"
declare -A VAR=( [ctrl]="" [c16]="cabin16" [c16s]="cabin16 style" )
run() { local name=$1; shift; "$G" --path . -s tools/vs16_scene.gd -- $BASE "$@" out=$O/$name.png > "$O/log_$name.txt" 2>&1; grep -h "saved\|ERROR" "$O/log_$name.txt"; }
ONLY="${1:-all}"

if [ "$ONLY" = all ] || [ "$ONLY" = stills ]; then
# home: cabin, well, golden oak and farmer in one 720p frame (HC2's framing); door: the farmer at the cabin door;
# fields: the F2 fields (the style study's ground and contact shadows away from the cabin).
for v in ctrl c16 c16s; do
  for t in "day 12" "night 21.5"; do set -- $t
    run "home_${v}_$1" ${VAR[$v]} at=38.5,10.5 hour=$2
    run "door_${v}_$1" ${VAR[$v]} at=45,13 hour=$2
  done
done
run fields_c16_day cabin16 at=51.5,24.3 hour=12
run fields_c16s_day cabin16 style at=51.5,24.3 hour=12
fi

if [ "$ONLY" = all ] || [ "$ONLY" = pans ]; then
# The HC2 diagonal pan past the cabin front at 30 fps (sub-pixel camera phase changes every frame).
pan() { local name=$1; shift
  rm -rf "$O/$name" && mkdir -p "$O/$name"
  "$G" --path . --write-movie "$O/$name/f.png" --fixed-fps 30 -s tools/vs16_scene.gd -- $BASE hour=12 "$@" \
    camlog out=$O/$name/pan.png > "$O/log_$name.txt" 2>&1
  echo "$name $(ls "$O/$name" | wc -l) files"; }
pan pan_ctrl at=56,17 hold=4 walk=left+up:4
pan pan_c16 cabin16 at=56,17 hold=4 walk=left+up:4
pan pan_c16s cabin16 style at=56,17 hold=4 walk=left+up:4
fi
