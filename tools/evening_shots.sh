#!/usr/bin/env bash
# CCH-EVENING-001: the review package's matched captures (tools/capture.gd, same options BEFORE and AFTER).
#   bash tools/evening_shots.sh [before-checkout]   (no checkout: AFTER only)
# BEFORE runs capture.gd in the given checkout of the previous commit (its evening options are guarded, so the
# same script works there); AFTER runs in this checkout. Raw shots go to builds/review/CCH-EVENING-001/.
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
BEFORE_DIR="$1"
OUT=builds/review/CCH-EVENING-001
mkdir -p "$OUT/before" "$OUT/after"
PROF="${TMP:-/tmp}/cch_ev_shots"; mkdir -p "$PROF"
shot() {   # name, options...
  local name=$1; shift
  APPDATA="$(cygpath -w "$PROF")" "$GODOT" --path . -s tools/capture.gd -- out=$OUT/after/$name.png "$@" > /dev/null 2>&1
  if [ -n "$BEFORE_DIR" ]; then
    mkdir -p "$BEFORE_DIR/$OUT/before"
    (cd "$BEFORE_DIR" && APPDATA="$(cygpath -w "$PROF")" "$GODOT" --path . -s tools/capture.gd -- out=$OUT/before/$name.png "$@" > /dev/null 2>&1)
    cp "$BEFORE_DIR/$OUT/before/$name.png" "$OUT/before/$name.png"
  fi
}
EVE="hour=20 weather=cloudy"
# Sheet 1: the evening outdoors, and the signs.
shot s1_ordinary   $EVE tile=47,16 face=down
shot s1_crows      $EVE tile=54,17 face=down sign=crows
shot s1_crows_read $EVE tile=54,17 face=down sign=crows signsay
shot s1_tracks     $EVE tile=39,24 face=right sign=tracks
shot s1_tracks_rain hour=20 weather=rain tile=39,24 face=right sign=tracks signsay
shot s1_chill      $EVE stage=2 tile=43,12 face=up sign=chill
shot s1_chill_winter hour=20 weather=snow season=Winter stage=2 tile=43,12 face=up sign=chill signsay
# Sheet 2: the hearth.
IN="inside itile=13,4 stage=2"
shot s2_day_space  $IN hour=15 fire=1 hearth=space
shot s2_eve_space  $IN hour=19.5 fire=4 hearth=space
shot s2_tend       $IN hour=19.5 fire=4 hearth=tend
shot s2_sit        $IN hour=19.5 fire=4 hearth=sit
# Sheet 3: the morning after a knock left alone.
shot s3_morning_plain $IN hour=21 fire=4 morning=plain
shot s3_morning_prep  $IN hour=21 fire=4 morning=prep
shot s3_morning_grace $IN hour=21 fire=4 morning=grace
