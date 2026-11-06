#!/usr/bin/env bash
# ART-005 HC1 Step 2 (zero-generation, non-production): renders the density-study frames in the clean export
# builds/review/ART-005/p1_export/ (HEAD's art and code plus the C2 cabin), exactly as HC1 Step 1 did.
# Copies tools/hc1_audit.gd, tools/hc2_density.gd and the study art (art/style_tests/ART-005/hc2/house16, well32) in
# first. Frames go to <export>/builds/review/ART-005/hc2/ (gitignored).
#   python tools/hc2_house16.py && python tools/hc2_well32.py && bash tools/hc2_density_run.sh && python tools/hc2_density_review.py
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
E="$ROOT/builds/review/ART-005/p1_export"
G="${GODOT:-/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
cp "$ROOT/tools/hc1_audit.gd" "$ROOT/tools/hc2_density.gd" "$E/tools/"
mkdir -p "$E/art/style_tests/ART-005/hc2"
cp -r "$ROOT/art/style_tests/ART-005/hc2/house16" "$ROOT/art/style_tests/ART-005/hc2/well32" "$E/art/style_tests/ART-005/hc2/"
O=builds/review/ART-005/hc2
BASE="mode=wide layout=b grass=1 art=f2 house=g7:c2"
mkdir -p "$E/$O"
cd "$E"
declare -A VAR=( [ctrl]="" [h16]="house16" [w32]="well32" )
run() { local name=$1; shift; "$G" --path . -s tools/hc2_density.gd -- $BASE "$@" out=$O/$name.png > "$O/log_$name.txt" 2>&1; grep -h "saved\|ERROR" "$O/log_$name.txt"; }

# 1. One framing that holds the whole cabin, the well, the oak and the farmer: the game's own camera on the farmer at
#    inner tile 38.5,10.5, real 720p, noon and the R3-1 night (lantern tier 1). Same farmer spot for every variant.
for v in ctrl h16 w32; do
  run "home_${v}_day" ${VAR[$v]} at=38.5,10.5 hour=12
  run "home_${v}_night" ${VAR[$v]} at=38.5,10.5 hour=21.5
done
# The farmer at the cabin door (HC1's door view): character against the cabin at both densities.
for v in ctrl h16; do
  run "door_${v}_day" ${VAR[$v]} at=45,13 hour=12
  run "door_${v}_night" ${VAR[$v]} at=45,13 hour=21.5
done
# 2. Diagonal pans at 30 fps (4.24 px camera steps: the sub-pixel phase changes every frame).
#    pan_house: HC1's diagonal walk past the cabin front (ctrl vs h16); pan_well: north-east past the well (ctrl vs w32).
pan() { local name=$1 v=$2; shift 2
  rm -rf "$O/$name" && mkdir -p "$O/$name"
  "$G" --path . --write-movie "$O/$name/f.png" --fixed-fps 30 -s tools/hc2_density.gd -- $BASE $v hour=12 "$@" \
    camlog out=$O/$name/pan.png > "$O/log_$name.txt" 2>&1
  echo "$name $(ls "$O/$name" | wc -l) files"; }
pan pan_house_ctrl "" at=56,17 hold=4 walk=left+up:4
pan pan_house_h16 house16 at=56,17 hold=4 walk=left+up:4
pan pan_well_ctrl "" at=35,20 hold=3 walk=right+up:3
pan pan_well_w32 well32 at=35,20 hold=3 walk=right+up:3
