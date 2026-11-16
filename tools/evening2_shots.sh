#!/usr/bin/env bash
# CCH-EVENING-002: the review package's matched captures (tools/capture.gd, same options BEFORE and AFTER).
#   bash tools/evening2_shots.sh [before-checkout]   (no checkout: AFTER only)
# BEFORE runs capture.gd in the given checkout of CCH-EVENING-001 (954787f); options it doesn't know (rest=,
# flyms=) are skipped there, so those rows are AFTER only. Raw shots go to builds/review/CCH-EVENING-002/.
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
BEFORE_DIR="$1"
OUT=builds/review/CCH-EVENING-002
mkdir -p "$OUT/before" "$OUT/after"
PROF="${TMP:-/tmp}/cch_ev2_shots"; mkdir -p "$PROF"
shot() {   # name, both|after, options...
  local name=$1 which=$2; shift 2
  APPDATA="$(cygpath -w "$PROF")" "$GODOT" --path . -s tools/capture.gd -- out=$OUT/after/$name.png "$@" > /dev/null 2>&1
  if [ -n "$BEFORE_DIR" ] && [ "$which" = both ]; then
    mkdir -p "$BEFORE_DIR/$OUT/before"
    (cd "$BEFORE_DIR" && APPDATA="$(cygpath -w "$PROF")" "$GODOT" --path . -s tools/capture.gd -- out=$OUT/before/$name.png "$@" > /dev/null 2>&1)
    cp "$BEFORE_DIR/$OUT/before/$name.png" "$OUT/before/$name.png"
  fi
}
EVE="hour=20 weather=cloudy"
ZOOM="crop=320,180,640,360 scale=1"   # the middle quarter of the screen at full size: what the eye sees near the farmer
# Sheet 1: the signs.
shot s1_crows        both  $EVE tile=54,17 face=down sign=crows
shot s1_crows_zoom   both  $EVE tile=54,17 face=down sign=crows $ZOOM
shot s1_crows_fly    after $EVE tile=54,17 face=down sign=crows flyms=650 $ZOOM
shot s1_tracks       both  $EVE tile=39,24 face=right sign=tracks
shot s1_tracks_zoom  both  $EVE tile=39,24 face=right sign=tracks $ZOOM
shot s1_tracks_rain  both  hour=21.5 weather=rain tile=39,24 face=right sign=tracks $ZOOM
shot s1_chill        both  $EVE stage=2 tile=43,12 face=up sign=chill
shot s1_chill_zoom   both  $EVE stage=2 tile=43,12 face=up sign=chill $ZOOM
shot s1_chill_winter both  hour=20.5 weather=snow season=Winter stage=2 tile=43,12 face=up sign=chill $ZOOM
shot s1_chill_boards both  $EVE stage=0 tile=43,12 face=up sign=chill $ZOOM
# Sheet 2: the farmhouse in the evening.
IN="inside itile=13,4"
shot s2_hearth_lit   both  $IN stage=2 hour=19.5 fire=4 hearth=space
shot s2_hearth_cold  both  $IN stage=1 hour=19.5 fire=0 hearth=space
shot s2_desk_quiet   both  inside itile=1,4 stage=1 hour=19.5 tab=Desk page=2
shot s2_rest_fire    after $IN stage=2 hour=19.5 fire=4 rest=fire
shot s2_rest_quiet   after inside itile=1,4 stage=1 hour=19.5 rest=quiet
shot s2_house0_in    after inside itile=8,5 stage=0 hour=20 fire=1
shot s2_house3_in    after inside itile=8,5 stage=3 hour=20 fire=5
shot s2_house0_out   after $EVE stage=0 tile=43,14 face=up
shot s2_house3_out   after $EVE stage=3 tile=43,14 face=up
# Sheet 3: the morning after a knock left alone, slept through in the house, by stage.
for st in 0 1 2 3; do
  shot s3_morning_stage$st both inside itile=13,4 stage=$st hour=21 fire=4 morning=plain
done
shot s3_morning_prep3 both inside itile=13,4 stage=3 hour=21 fire=4 morning=prep
