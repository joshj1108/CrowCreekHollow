#!/bin/sh
# FARMHOUSE-INTERIOR-001 review captures, all from the running game through tools/capture.gd.
#   sh tools/fi001_shots.sh after                 # this tree      -> builds/review/fi001/A/
#   sh tools/fi001_shots.sh before BEFORE_TREE    # a checkout of the previous commit (with the owner's uncommitted
#                                                 # main.gd and shader, and this tools/capture.gd) -> .../B/
# Interior tiles differ between the old layout and the new, so the BEFORE shots stand on the old layout's
# matching spots (the hall, the entry mat, the bed, the hearth); everything else is the same options.
G="C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
HERE="$(pwd)"
if [ "$1" = "before" ]; then
	TREE="$2"; SUB=B
	HALL="itile=10,16"; ENTRY="itile=10,18"; BED="itile=1,6"; HEARTH="itile=16,14"
else
	TREE="$(pwd)"; SUB=A
	HALL="itile=12,5"; ENTRY="itile=12,12"; BED="itile=1,6"; HEARTH="itile=13,4"
fi
# capture.gd saves under res://, so each tree writes into its own builds/ and BEFORE is copied back at the end.
OUT="builds/review/fi001/$SUB"
mkdir -p "$TREE/$OUT" "$HERE/$OUT"
shot() { name=$1; shift; (cd "$TREE" && "$G" --path . -s tools/capture.gd -- out="$OUT/$name.png" "$@" >/dev/null 2>&1); }
# Sheet 2: layout, and the restoration comparison (same camera, every stage, furniture bought as each stage allows)
for s in 0 1 2 3; do
	F=""; [ $s -ge 2 ] && F="fire=6"
	shot r_day_s$s inside stage=$s hour=12 weather=sunny estate $HALL $F
	shot r_night_s$s inside stage=$s hour=21.5 weather=sunny estate $HALL $F
done
shot nav_entry inside stage=3 hour=12 weather=sunny estate fire=6 $ENTRY
shot nav_entry_s0 inside stage=0 hour=12 weather=sunny $ENTRY
# Sheet 3: the hearth and the lights (full size for crops)
shot f_unlit inside stage=3 hour=12 weather=sunny estate $HALL scale=1
shot f_lit inside stage=3 hour=12 weather=sunny estate fire=6 $HALL scale=1
shot f_night_candles inside stage=3 hour=21.5 weather=sunny estate $HALL
shot f_night_all inside stage=3 hour=21.5 weather=sunny estate fire=6 $HALL
shot f_night_all_full inside stage=3 hour=21.5 weather=sunny estate fire=6 $HALL scale=1
shot f_derelict_fire inside stage=0 hour=21.5 weather=sunny fire=6 $HALL scale=1
shot f_low inside stage=2 hour=21.5 weather=sunny fire=0.5 $HALL scale=1
# Sheet 4: windows (full size, cropped later)
shot w_spring inside stage=3 hour=12 weather=sunny season=Spring $HALL scale=1
shot w_summer inside stage=3 hour=12 weather=sunny season=Summer $HALL scale=1
shot w_autumn inside stage=3 hour=12 weather=sunny season=Autumn $HALL scale=1
shot w_rain inside stage=3 hour=15 weather=rain season=Summer $HALL scale=1
shot w_winter inside stage=3 hour=12 weather=snow season=Winter fire=6 $HALL scale=1
shot w_fog inside stage=3 hour=12 weather=fog season=Autumn $HALL scale=1
shot w_night inside stage=3 hour=21.5 weather=sunny season=Summer fire=6 $HALL scale=1
shot w_shutters inside stage=3 hour=21.5 weather=sunny season=Summer fire=6 shutters $HALL scale=1
shot w_s0 inside stage=0 hour=12 weather=sunny season=Summer $HALL scale=1
shot w_s1 inside stage=1 hour=12 weather=sunny season=Summer $HALL scale=1
shot w_dawn_shut inside stage=3 hour=6.9 weather=sunny season=Summer $HALL scale=1
shot w_dawn_open inside stage=3 hour=7.2 weather=sunny season=Summer $HALL scale=1
# Sheet 6: world integration
shot x_outside stage=3 hour=17 weather=sunny estate
shot x_inside inside stage=3 hour=17 weather=sunny estate fire=6 $ENTRY
shot x_bed inside stage=3 hour=21.5 weather=sunny estate fire=6 $BED
shot x_hearth inside stage=3 hour=21.5 weather=sunny estate fire=6 $HEARTH
shot x_s1_dusk inside stage=1 hour=19.5 weather=cloudy estate $HALL
[ "$TREE" != "$HERE" ] && cp "$TREE/$OUT"/*.png "$HERE/$OUT/"
echo done "$OUT"
