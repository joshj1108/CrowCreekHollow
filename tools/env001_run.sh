#!/usr/bin/env bash
# ENV-001 (zero-generation, NON-PRODUCTION): renders the review matrix in the clean export
# builds/review/ART-005/p1_export/ with tools/env001_scene.gd. Same camera, farmer spot, hour and 3x scale per row;
# only the switches differ. Frames go to <export>/builds/review/ENV-001/ (gitignored). Four Godot runs at a time.
#   python tools/env001_art.py && bash tools/env001_run.sh && python tools/env001_review.py
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
E="$ROOT/builds/review/ART-005/p1_export"
export G="${GODOT:-/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
cp "$ROOT/tools/hc1_audit.gd" "$ROOT/tools/hc2_density.gd" "$ROOT/tools/vs16_scene.gd" "$ROOT/tools/vs16p1_scene.gd" \
   "$ROOT/tools/env001_scene.gd" "$E/tools/"
mkdir -p "$E/art/style_tests/ART-005/vs16p1" "$E/art/style_tests/ENV-001"
cp -r "$ROOT/art/style_tests/ART-005/vs16p1/cabin" "$E/art/style_tests/ART-005/vs16p1/"
rm -rf "$E/art/style_tests/ENV-001/terrain" "$E/art/style_tests/ENV-001/shadows"
cp -r "$ROOT/art/style_tests/ENV-001/terrain" "$ROOT/art/style_tests/ENV-001/shadows" "$E/art/style_tests/ENV-001/"
export O=builds/review/ENV-001
export BASE="mode=wide layout=b grass=1 art=f2 house=g7:c2 cabin16 p1"
mkdir -p "$E/$O"
cd "$E"
jobs=()
# Views: 1 home (cabin, oak, well, farmer); 2 fields; 3 orchard, pond and dock with lawn and forest edge;
# 4 road, closed gate and the southern boundary.
declare -A V=( [home]=38.5,10.5 [fields]=51.5,24.3 [orchard]=14,27 [gate]=56,34 )
for v in "${!V[@]}"; do
  for t in "ctrl:" "terrain:terrain" "shadows:shadows" "day:day" "all:all"; do
    jobs+=("${v}_noon_${t%%:*}|at=${V[$v]} hour=12 ${t#*:}")
  done
  for t in "ctrl:" "ts:terrain shadows" "alld:all daynight"; do
    jobs+=("${v}_night_${t%%:*}|at=${V[$v]} hour=21.5 ${t#*:}")
  done
done
# The stitched overview: 3x3 real 720p frames, farmer hidden (no lantern at night).
for x in 9 33 57; do for y in 5.5 20 34.5; do
  jobs+=("ov_${x}_${y}_noon_ctrl|at=$x,$y hour=12 nofarmer")
  jobs+=("ov_${x}_${y}_noon_all|at=$x,$y hour=12 nofarmer all")
  jobs+=("ov_${x}_${y}_night_ctrl|at=$x,$y hour=21.5 nofarmer lantern=0")
  jobs+=("ov_${x}_${y}_night_ts|at=$x,$y hour=21.5 nofarmer lantern=0 terrain shadows")
done; done
printf '%s\n' "${jobs[@]}" | xargs -P 4 -I{} bash -c '
  j="{}"; n="${j%%|*}"; a="${j#*|}"
  "$G" --path . -s tools/env001_scene.gd -- $BASE $a out=$O/$n.png > "$O/log_$n.txt" 2>&1
  grep -h "saved\|ERROR" "$O/log_$n.txt"'
