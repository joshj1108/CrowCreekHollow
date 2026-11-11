#!/bin/bash
# ART-OVERHAUL-002 E4-E6 review shots, full size (1280x720). Usage: tools/aoh2_shots.sh <out dir> [name filter]
# Each line: name | capture options. Run once before the change and once after; the review package keeps them in
# art/style_tests/ART-OVERHAUL-002/review/full/ (before_/after_ prefixes) and half-size copies in review/half/.
GODOT="/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
OUT="$1"; FILTER="${2:-.}"
mkdir -p "$OUT"
while IFS='|' read -r name args; do
	[ -z "$name" ] && continue
	echo "$name" | grep -q -E "$FILTER" || continue
	"$GODOT" --path . -s tools/capture.gd -- out="$OUT/$name.png" scale=1 $args > /dev/null 2>&1
	echo "$name done"
done <<'LIST'
cave_ext_day|tile=11,11 hour=11 weather=sunny
cave_ext_dusk|tile=11,11 hour=19.5 weather=sunny
cave_ext_night|tile=11,11 hour=22 lantern=2 weather=sunny
cave_int_exit|cave ctile=20,19 lantern=2
cave_int_lit|cave ctile=20,19 lit
cave_int_mine|cave ctile=20,19 lantern=2 mine=0,-1
house_s0|inside stage=0 hour=11
house_s3|inside stage=3 estate hour=11
house_s3_hall|inside stage=3 estate hour=11 itile=14,15
house_s3_study|inside stage=3 estate hour=11 itile=13,6
house_s3_bed|inside stage=3 estate hour=11 itile=4,7
house_s3_night|inside stage=3 estate hour=22
season_spring|tile=38,13 hour=11 weather=sunny season=Spring
season_summer|tile=38,13 hour=11 weather=sunny season=Summer
season_autumn|tile=38,13 hour=11 weather=sunny season=Autumn
season_winter|tile=38,13 hour=11 weather=sunny season=Winter
season_winter_snow|tile=38,13 hour=11 weather=snow season=Winter
orchard_spring|tile=14,24 hour=11 weather=sunny season=Spring
orchard_summer|tile=14,24 hour=11 weather=sunny season=Summer
orchard_autumn|tile=14,24 hour=11 weather=sunny season=Autumn
orchard_winter|tile=14,24 hour=11 weather=sunny season=Winter
trek_autumn|trek=0 hour=11 tday=20
trek_winter|trek=0 hour=11 tday=75
trek_spring|trek=0 hour=11 tday=170
trek_summer|trek=0 hour=11 tday=260
trek_winter_night|trek=0 tnight lantern=2 tday=75
trek_summer_night|trek=0 tnight lantern=2 tday=260
trek_orchard_summer|troute=orchard trek=4 tday=260 hour=11
trek_chapel_winter|troute=chapel trek=5 tday=440 hour=11
world_house|tile=45,15 hour=11 weather=sunny
world_oak|tile=30,14 hour=11 weather=sunny
world_gate|tile=55,33 hour=11 weather=sunny
world_cave|tile=14,13 hour=11 weather=sunny
world_pond|tile=14,32 hour=11 weather=sunny
LIST
