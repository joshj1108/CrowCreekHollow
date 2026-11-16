#!/usr/bin/env bash
# CCH-EVENING-002: the comparative balance runs (tools/balance_sim.gd styles), each in its own throwaway profile,
# five at a time. JSON per run goes to $OUT/<config>_<style>.json, the printed table to .txt.
#   bash tools/evening2_sims.sh [days]
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
DAYS="${1:-400}"
OUT="${OUT:-art/style_tests/CCH-EVENING-002/sims}"
PROF="${TMP:-/tmp}/cch_ev2_sims"
mkdir -p "$OUT"
declare -A CFG=( [A]="shelter=1,1,1,1 quiet=0" [B]="" [W]="shelter=1,0.85,0.7,0.55" [S]="shelter=1,0.65,0.5,0.35" )
run() {   # name, options...
  local name=$1; shift
  mkdir -p "$PROF/$name"
  APPDATA="$(cygpath -w "$PROF/$name")" "$GODOT" --path . --headless -s tools/balance_sim.gd -- "$@" treks=3 every=10 \
    json="$(cygpath -w "$OUT/$name.json")" > "$OUT/$name.txt" 2>&1
  echo "done $name"
}
ONLY="${ONLY:-}"   # e.g. ONLY="S ctl" reruns only those configs
n=0
for c in A B W S; do
  if [ -n "$ONLY" ] && [[ " $ONLY " != *" $c "* ]]; then continue; fi
  for st in minimal cozy cautious curious balanced; do
    run "${c}_${st}" style=$st days=$DAYS ${CFG[$c]} &
    n=$((n+1)); if [ $((n % 5)) -eq 0 ]; then wait; fi
  done
done
# Controlled stage tests (the house held at a stage from day 1; not natural progression), 30 days.
for stg in 0 1 2 3; do
  if [ -n "$ONLY" ] && [[ " $ONLY " != *" ctl "* ]]; then break; fi
  for st in minimal cozy; do
    run "ctl_stage${stg}_${st}" style=$st days=30 stage=$stg &
    n=$((n+1)); if [ $((n % 5)) -eq 0 ]; then wait; fi
  done
done
wait
