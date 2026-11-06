#!/bin/bash
# ART-OVERHAUL-001 Stage D: the trek review shots. Usage: tools/aoh_trek_shots.sh <out dir> [name filter]
# Each line: name | capture options. Half-size PNGs (capture.gd's default scale).
GODOT="/c/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe"
OUT="$1"; FILTER="${2:-.}"
mkdir -p "$OUT"
while IFS='|' read -r name args; do
	[ -z "$name" ] && continue
	echo "$name" | grep -q -E "$FILTER" || continue
	"$GODOT" --path . -s tools/capture.gd -- out="$OUT/$name.png" $args > /dev/null 2>&1
	echo "$name done"
done <<'LIST'
mill_day|trek=0 hour=11
mill_night|trek=0 tnight lantern=2
mill_dest|trek=3 hour=11
edge_day|troute=edge trek=1 hour=11
edge_night|troute=edge trek=0 tnight lantern=2
orchard_day|troute=orchard trek=4 tday=160 hour=11
orchard_night|troute=orchard trek=4 tday=160 tnight lantern=2
chapel_day|troute=chapel trek=5 tday=250 hour=11
chapel_night|troute=chapel trek=5 tday=250 tnight lantern=2
post_day|troute=post trek=2 tday=340 hour=11
post_night|troute=post trek=2 tday=340 tnight lantern=2
grove_day|troute=grove trek=6 tday=400 hour=11
grove_night|troute=grove trek=6 tday=400 tnight lantern=2
flood|trek=1 tevent=flood hour=11
fog|trek=1 tdark tevent=fog hour=11
hollow_night|trek=1 tdark tevent=hollow tnight lantern=2
cairn|trek=1 tevent=cairn hour=11
sign|trek=0 tsign tread hour=11
LIST
