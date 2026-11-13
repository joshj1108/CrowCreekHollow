#!/usr/bin/env bash
# CCH-PLAYABLE-001: runs tools/audit_probe.gd for each mode in parallel, each in a throwaway profile.
#   bash tools/audit_probe.sh [days] [treks]      (logs: art/style_tests/CCH-PLAYABLE-001/logs/probe_<mode>_<days>.log)
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
SCRATCH="${AUDIT_SCRATCH:-${TMP:-/tmp}/cch_audit_profiles}"
DAYS="${1:-400}"; TREKS="${2:-3}"
OUT=art/style_tests/CCH-PLAYABLE-001/logs
mkdir -p "$OUT"
for mode in engaged ignore earlybed; do
  prof="$SCRATCH/probe_${mode}_$DAYS"; mkdir -p "$prof"
  APPDATA="$(cygpath -w "$prof")" "$GODOT" --path . --headless -s tools/audit_probe.gd -- mode=$mode days=$DAYS every=20 treks=$TREKS > "$OUT/probe_${mode}_$DAYS.log" 2>&1 &
done
wait
grep -c "" "$OUT"/probe_*_$DAYS.log
