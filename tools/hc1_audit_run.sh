#!/usr/bin/env bash
# ART-005 HC1 Step 1 (audit only): renders every frame of the whole-farm baseline in the clean export
# builds/review/ART-005/p1_export/ (HEAD's art and code plus the C2 cabin; no VIS-002 working-tree change), as C3 was.
# Copies tools/hc1_audit.gd into the export first. Frames go to <export>/builds/review/ART-005/hc1/ (gitignored).
#   bash tools/hc1_audit_run.sh            then   python tools/hc1_audit_review.py
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
E="$ROOT/builds/review/ART-005/p1_export"
G="${GODOT:-/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
cp "$ROOT/tools/hc1_audit.gd" "$E/tools/"
O=builds/review/ART-005/hc1
BASE="mode=wide layout=b grass=1 art=f2 house=g7:c2"
mkdir -p "$E/$O"
cd "$E"
run() { local name=$1; shift; "$G" --path . -s tools/hc1_audit.gd -- $BASE "$@" out=$O/$name.png > "$O/log_$name.txt" 2>&1; grep -h "saved\|ERROR" "$O/log_$name.txt"; }

# 1. The nine views at real 720p (the game's own camera on the farmer), noon and R3-1 night (lantern tier 1).
declare -A V=( [north]=38,13.5 [fields]=51.5,24.3 [orchard]=14.5,22.5 [pond]=14,31 [cross]=33,18
               [road]=36,33.5 [gate]=56,34 [door]=45,13 )
for v in "${!V[@]}"; do
  run "${v}_day" at=${V[$v]} hour=12
  run "${v}_night" at=${V[$v]} hour=21.5
done
# 2. The overview: a 3x3 mosaic of real 720p frames, farmer hidden, no lantern (stitched by hc1_audit_review.py).
for x in 9 33 57; do for y in 5.5 20 34.5; do
  run "ov_${x}_${y}_day" at=$x,$y hour=12 nofarmer
  run "ov_${x}_${y}_night" at=$x,$y hour=21.5 nofarmer lantern=0
done; done
# 3. 1080p: the game's own stretch (1.5x, non-integer) and the harness integer framing (tile 64 px).
for f in today int; do
  run "north_day_fhd_$f" at=38,13.5 hour=12 fhd=$f
  run "north_night_fhd_$f" at=38,13.5 hour=21.5 fhd=$f
  run "door_day_fhd_$f" at=45,13 hour=12 fhd=$f
done
# 4. The pans. The farmer walks; the camera follows as in play. First: the farmer walks west along the cabin front for 5 s (real input, the game's camera), recorded at 30 fps.
rm -rf "$O/pan" && mkdir -p "$O/pan"
"$G" --path . --write-movie "$O/pan/f.png" --fixed-fps 30 -s tools/hc1_audit.gd -- $BASE at=56,14.5 hour=12 \
  hold=5 walk=left:5 camlog out=$O/pan/pan.png > "$O/log_pan.txt" 2>&1
# 5. Two more pans, since a straight walk at 30 fps steps the camera by exactly 6.0 px (no sub-pixel phase change):
#    a diagonal walk (4.24 px per frame on each axis) at 30 fps, and the straight walk at 144 fps (1.25 px per frame).
for p in "diag 30 at=56,17 hold=4 walk=left+up:4" "hz144 144 at=56,14.5 hold=2 walk=left:2"; do
  set -- $p; n=$1; fps=$2; shift 2
  rm -rf "$O/pan_$n" && mkdir -p "$O/pan_$n"
  "$G" --path . --write-movie "$O/pan_$n/f.png" --fixed-fps $fps -s tools/hc1_audit.gd -- $BASE hour=12 "$@"     camlog out=$O/pan_$n/pan.png > "$O/log_pan_$n.txt" 2>&1
  ls "$O/pan_$n" | wc -l
done
