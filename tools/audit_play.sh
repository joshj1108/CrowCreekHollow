#!/usr/bin/env bash
# CCH-PLAYABLE-001: runs tools/audit_play.gd windowed in a throwaway profile (never the owner's saves).
#   bash tools/audit_play.sh <profile-name> scenario=week dev=kbm [more options]
# The profile is kept between runs with the same name, so a later scenario can load what an earlier one saved.
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
SCRATCH="${AUDIT_SCRATCH:-${TMP:-/tmp}/cch_audit_profiles}"
prof="$SCRATCH/$1"; shift
mkdir -p "$prof"
APPDATA="$(cygpath -w "$prof")" "$GODOT" --path . --fixed-fps 60 --disable-vsync -s tools/audit_play.gd -- "$@"
