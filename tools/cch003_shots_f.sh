#!/bin/sh
# CCH-CONSOLIDATED-003 Phase F: the final package's stills, from the running game (tools/capture.gd, half size).
# Run once in a worktree of the commit before Phase A (BEFORE) and once in the final build (AFTER), with the same
# options, so each pair matches:
#   sh tools/cch003_shots_f.sh <project dir> <out dir, relative to that project, e.g. builds/review/F_shots>
# Options the old build doesn't know (mail=, weapon=, creatures=, debug) are ignored there: the BEFORE frame shows
# the same place and time without them.
G="C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
P=$1
OUT=$2
mkdir -p "$P/$OUT"
shot() { "$G" --path "$P" -s tools/capture.gd -- out="$OUT/$1.png" $2 2>&1 | grep -E "saved|SCRIPT ERROR" | head -3; }
while IFS='|' read -r name opts; do
  case "$name" in ''|'#'*) continue ;; esac
  [ -n "$ONLY" ] && case " $ONLY " in *" $name "*) ;; *) continue ;; esac
  shot "$name" "$opts"
done <<'LIST'
# 1 HUD
hud_day|hour=12 weather=sunny scale=1
hud_low|hour=12 weather=sunny hp=3 food=12 water=10 warmth=20 scale=1
hud_trek|trek=1 hour=12 weather=cloudy scale=1
# 2 mailbox and entrance
entrance_day|hour=12 weather=sunny
entrance_dusk|hour=19.5 weather=sunny lantern=1
entrance_night|hour=21.5 weather=cloudy lantern=2
mailbox_day|tile=53,33 face=up hour=12 weather=sunny mail=1 scale=1 crop=440,160,400,300
mailbox_open|tile=53,33 face=up hour=12 weather=sunny mail=1 mailopen scale=1 crop=440,160,400,300
mailbox_snow|tile=53,33 face=up hour=12 season=Winter weather=snow mail=1 scale=1 crop=440,160,400,300
# 3/4/5 furniture, layout and restoration, clipping
int_s0|inside stage=0 hour=12 weather=sunny
int_s1|inside stage=1 hour=12 weather=sunny
int_s2|inside stage=2 hour=12 weather=sunny fire=6
int_s3|inside stage=3 hour=12 weather=sunny fire=6
int_s3_estate|inside stage=3 hour=12 weather=sunny fire=6 estate clock
int_s3_night|inside stage=3 hour=21.5 weather=cloudy fire=6 estate clock
int_s0_night|inside stage=0 hour=21.5 weather=cloudy lantern=1
int_bed|inside stage=3 itile=6,5 face=left hour=12 weather=sunny fire=6 estate scale=1 crop=240,120,800,480
int_desk|inside stage=3 itile=2,5 face=up hour=21.5 weather=cloudy fire=6 estate scale=1 crop=240,120,800,480
# 6 farmer, 7 lantern and tools
farmer_day|tile=50,30 face=down hour=12 weather=sunny scale=1 crop=520,240,240,240
farmer_night|tile=50,30 face=down hour=21.5 weather=cloudy lantern=2 scale=1 crop=520,240,240,240
farmer_inside|inside stage=3 itile=8,6 face=down hour=21.5 weather=cloudy fire=6 lantern=2 scale=1 crop=520,240,240,240
farmer_cave|cave ctile=16,19 face=down lantern=3 scale=1 crop=520,240,240,240
# 8 combat, 9 creatures
combat_cave|cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=attack cprog=0.5 scale=1 crop=500,250,480,200
combat_hurt|cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=hurt cprog=0.5 scale=1 crop=500,250,480,200
creatures_l1|cave ctile=16,19 face=right weapon=iron_sword lantern=1 creatures=idle scale=1 crop=500,250,480,200
creatures_exit|cave ctile=16,20 face=right hour=12 lantern=1 creatures=idle scale=1 crop=500,300,440,220
# 10 debug menu
debug_panel|debug hour=12 weather=sunny
debug_snow|debug dweather=snow dtemp=20 hour=12
# 11 consistency
farm_day|hour=12 weather=sunny tile=40,26
farm_night|hour=21.5 weather=cloudy lantern=2 tile=40,26
cave_explore|cave ctile=16,19 face=up lantern=3
season_spring|season=Spring hour=12 weather=sunny tile=40,26
season_summer|season=Summer hour=12 weather=sunny tile=40,26
season_autumn|season=Autumn hour=12 weather=rain tile=40,26
season_winter|season=Winter hour=12 weather=snow tile=40,26
window_winter|inside stage=3 season=Winter weather=snow hour=12 fire=6
window_autumn|inside stage=3 season=Autumn weather=rain hour=17 fire=6
LIST
