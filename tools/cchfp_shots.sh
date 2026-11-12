#!/bin/sh
# CCH-CONSOLIDATED-003 Final Polish: the review package's stills, from the running game (tools/capture.gd).
# Run once in a clean worktree of the commit before this pass (BEFORE) and once in this build (AFTER), with the same
# options, so each pair matches:
#   sh tools/cchfp_shots.sh <project dir> <out dir, relative to that project>
# ONLY="a b" limits it to those shots.
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
# Sheet 2: creatures at the lantern's edge (tier 1), and at full light
creatures_l1|cave ctile=16,19 face=right weapon=iron_sword lantern=1 creatures=idle scale=1 crop=500,250,480,200
creatures_l3|cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=idle scale=1 crop=500,250,480,200
bat_attack0|cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=attack cprog=0.0 ckinds=bat scale=1 crop=500,250,480,200
cave_explore|cave ctile=16,19 face=up lantern=3
# Sheet 3: mailbox beside the stand (normal zoom), unread and read, day, dusk, night, winter; the farmhouse
mailbox_day|tile=53,34 face=up hour=12 weather=sunny mail=1 scale=1 crop=400,120,480,360
mailbox_read|tile=53,34 face=up hour=12 weather=sunny mail=0 scale=1 crop=400,120,480,360
mailbox_dusk|tile=53,34 face=up hour=19.5 weather=sunny mail=1 lantern=1 scale=1 crop=400,120,480,360
mailbox_night|tile=53,34 face=up hour=21.5 weather=cloudy mail=1 lantern=2 scale=1 crop=400,120,480,360
mailbox_winter|tile=53,34 face=up hour=12 season=Winter weather=snow mail=1 scale=1 crop=400,120,480,360
int_desk|inside stage=3 itile=2,5 face=up hour=12 weather=sunny fire=6 estate clock scale=1 crop=0,60,760,420
int_dining|inside stage=3 itile=9,10 face=up hour=12 weather=sunny fire=6 estate clock scale=1 crop=300,60,760,420
int_night|inside stage=3 itile=12,8 face=down hour=21.5 weather=cloudy fire=6 estate clock
int_door|inside stage=3 itile=12,12 face=down hour=21.5 weather=cloudy fire=6 estate clock
# Sheet 4: integration
farm_day|hour=12 weather=sunny tile=40,26
farm_night|hour=21.5 weather=cloudy lantern=2 tile=40,26
int_day|inside stage=3 itile=12,8 face=down hour=12 weather=sunny fire=6 estate clock
combat_cave|cave ctile=16,19 face=right weapon=iron_sword lantern=3 creatures=attack cprog=0.5
ui_mailbox|tile=53,34 face=up hour=12 weather=sunny mail=1 mailpanel
LIST
