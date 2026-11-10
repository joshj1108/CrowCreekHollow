#!/bin/bash
# ART-OVERHAUL-001 Stage D finishing pass: matched BEFORE/AFTER shots. Usage: shots.sh <out dir>
GODOT="/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
OUT="$1"; mkdir -p "$OUT"
while IFS='|' read -r name args; do
	[ -z "$name" ] && continue
	"$GODOT" --path . -s tools/capture.gd -- out="$OUT/$name.png" weather=cloudy $args > /dev/null 2>&1
	echo "$name done"
done <<'LIST'
mill_day|trek=0 hour=11
mill_dest|trek=3 hour=11
mill_night|trek=3 tnight lantern=2
chapel_day|troute=chapel trek=5 tday=250 hour=11
chapel_night|troute=chapel trek=5 tday=250 tnight lantern=2
sign|trek=0 tsign tread hour=11
cairn|trek=1 tevent=cairn hour=11
hollow_night|trek=1 tdark tevent=hollow tnight lantern=2
grove_day|troute=grove trek=6 tday=400 hour=11
orchard_day|troute=orchard trek=4 tday=160 hour=11
LIST
