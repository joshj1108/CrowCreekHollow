#!/usr/bin/env bash
# CCH-PLAYABLE-001: reruns every headless regression test, each in its own throwaway profile (APPDATA is pointed
# at a scratch folder, so the owner's saves and settings are never opened), up to 5 at a time.
#   bash tools/audit_run_tests.sh [scratch_dir]
# Logs go to art/style_tests/CCH-PLAYABLE-001/logs/test_<name>.log; a summary line per test is printed.
GODOT="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
SCRATCH="${1:-${TMP:-/tmp}/cch_audit_profiles}"
OUT="${OUT:-art/style_tests/CCH-PLAYABLE-001/logs}"
mkdir -p "$OUT"
TESTS="save_test menu_test interior_test mail_test debug_menu_test diary_test wheel_test layout_test farmer_test creature_test aoh2_e2_check aoh2_e3_check aoh2_e5_check aoh_cave_check aoh_trek_check diary_fit"
run() {
  local t=$1 prof="$SCRATCH/$1"
  mkdir -p "$prof"
  local t0=$SECONDS
  APPDATA="$(cygpath -w "$prof")" "$GODOT" --path . --headless -s tools/$t.gd > "$OUT/test_$t.log" 2>&1
  local code=$?
  local pass fail err
  pass=$(grep -c "PASS\|^ok\|  ok" "$OUT/test_$t.log"); fail=$(grep -c "FAIL" "$OUT/test_$t.log")
  err=$(grep -c "SCRIPT ERROR\|^ERROR" "$OUT/test_$t.log")
  echo "$t exit=$code pass_lines=$pass fail_lines=$fail engine_errors=$err secs=$((SECONDS-t0))"
}
n=0
for t in $TESTS; do
  run $t &
  n=$((n+1)); if [ $((n % 5)) -eq 0 ]; then wait; fi
done
wait
