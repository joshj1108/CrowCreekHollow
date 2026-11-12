#!/bin/sh
# CCH-CONSOLIDATED-003 Phase E: in-game shots of the cave creatures for the review package, from the running game
# (tools/capture.gd, full size, cropped around the farmer and the three creatures standing to his right).
# BEFORE shots draw the old SpriteCook sheets through the old code (oldfoes); nothing else differs.
#   sh tools/cch003_shots_e.sh
G="C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
OUT=art/style_tests/CCH-003/E/shots
mkdir -p $OUT
CROP="crop=500,250,480,200 scale=1"
BASE="cave ctile=16,19 face=right weapon=iron_sword"
shot() { "$G" --path . -s tools/capture.gd -- out=$OUT/$1.png $2 2>&1 | grep -E "saved|ERROR"; }
# Readability by lantern tier (0 none, 1 basic, 3 upgraded), BEFORE and AFTER.
for L in 0 1 2 3; do
  shot "after_lantern$L" "$BASE lantern=$L creatures=idle $CROP"
  shot "before_lantern$L" "$BASE lantern=$L creatures=idle oldfoes $CROP"
done
# Cave light: the daylight spilling up the exit steps at noon, no lantern and the basic lantern.
for L in 0 1; do
  shot "after_exit_l$L" "cave ctile=16,20 face=right hour=12 lantern=$L creatures=idle crop=500,300,440,220 scale=1"
  shot "before_exit_l$L" "cave ctile=16,20 face=right hour=12 lantern=$L creatures=idle oldfoes crop=500,300,440,220 scale=1"
done
# Every state, AFTER, by the upgraded lantern (the mid-point of each one-shot).
for S in idle move alert attack hurt death; do
  shot "after_state_$S" "$BASE lantern=3 creatures=$S cprog=0.5 $CROP"
done
shot "after_state_death_end" "$BASE lantern=3 creatures=death cprog=1.0 $CROP"
shot "after_state_left" "$BASE lantern=3 creatures=move cface=left $CROP"
# BEFORE had only two states: still and moving (the bat always flapping), plus the hit flash.
shot "before_state_move" "$BASE lantern=3 creatures=move oldfoes $CROP"
shot "before_state_hurt" "$BASE lantern=3 creatures=hurt oldfoes $CROP"
