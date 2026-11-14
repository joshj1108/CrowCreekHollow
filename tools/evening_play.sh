#!/usr/bin/env bash
# CCH-EVENING-001: runs tools/evening_play.gd windowed in a throwaway profile (never the owner's saves).
#   bash tools/evening_play.sh <profile-name> scenario=evening style=cozy days=14 [dev=pad] [grace=0] [out=DIR]
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
SCRATCH="${AUDIT_SCRATCH:-${TMP:-/tmp}/cch_audit_profiles}"
prof="$SCRATCH/$1"; shift
rm -rf "$prof"; mkdir -p "$prof"
APPDATA="$(cygpath -w "$prof")" "$GODOT" --path . --fixed-fps 60 --disable-vsync -s tools/evening_play.gd -- "$@"
