#!/usr/bin/env bash
# CCH-ORIGIN-005: the in-engine review shots for "The Second Year Remembers", into art/style_tests/CCH-ORIGIN-005/shots.
#   bash tools/origin005_shots.sh [name ...]     (no names: all)
#   BEFORE=1 bash tools/origin005_shots.sh b_...  runs the BEFORE shots with a HEAD worktree's capture (see GODOT_PATH)
# Full size (scale=1), so the diary's handwriting and the letters can be read. Uses tools/capture.gd's past=, spring=,
# sept= and autumn= (the second autumn: by default on to October 7, day 372, the scene's morning).
G="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
ROOT="${GODOT_PATH:-.}"
OUT=art/style_tests/CCH-ORIGIN-005/shots
mkdir -p "$OUT" "$ROOT/$OUT"
V="hour=11 scale=1"
A="past=origin:security,security_exit:forward pans=renew pflow=answered spring=spring,ans:leave,read"
B="past=origin:work pans=explain pflow=answered spring=spring,ans:take,post,read,ans:do,post,read"
C="past=origin:household,household_relation:partner,household_change:separate,keepsake:notebook pans=ask pflow=answered spring=spring,open:key,ans:time,post,read"
CP="past=origin:household,household_relation:private,household_change:private,contact:private,keepsake:postcard pans=ask pflow=answered spring=spring,open:key,ans:time,post,read"
D="past=origin:curiosity,contact:none pans=keep pflow=answered spring=spring,ans:keep"
DC="past=origin:curiosity,contact:friend pans=unsaid pflow=answered spring=spring,town,ans:place,post,read"
E="past=origin:chance,chance_loose_end:meeting pans=spring pflow=answered spring=spring,ans:autumn,post,read"
declare -A S=(
  [o1_A_letter]="$A sept=farm:worked autumn=read mailopen mailpanel mpick=^autumn:answer|sign $V"
  [o2_B_letter]="$B sept=farm:worked autumn=read mailopen mailpanel mpick=^autumn:answer|ask_first $V"
  [o3_C_letter]="$C sept=farm:worked autumn=read mailopen mailpanel mpick=^autumn:answer|send $V"
  [o4_D_desk_contact]="$DC sept=farm:worked autumn=read tab=Desk tpick=^autumn:answer|note $V"
  [o4_D_desk_write]="$DC sept=farm:worked autumn=read tab=Desk tpick=autumn:answer|write $V"
  [o5_E_letter]="$E sept=farm:worked autumn=read mailopen mailpanel mpick=^autumn:answer|tell $V"
  [v1_C_private]="$CP sept=farm:bare autumn=read mailopen mailpanel mpick=^autumn:answer|give $V"
  [v2_D_nocontact]="$D sept=farm:bare autumn=read tab=Desk tpick=^autumn:answer|note $V"
  [r1_keep]="$A sept=farm:worked,write:keep autumn=read,ans:sign,post,read diary dautumn=0 $V"
  [r1_keep_p2]="$A sept=farm:worked,write:keep autumn=read,ans:sign,post,read diary dautumn=1 $V"
  [r2_unsettled]="$A sept=farm:worked,write:unsettled autumn=read,ans:sign,post,read diary dautumn=0 $V"
  [r2_unsettled_p2]="$A sept=farm:worked,write:unsettled autumn=read,ans:sign,post,read diary dautumn=1 $V"
  [r3_unwritten]="$A sept=farm:worked autumn=read,ans:sign,post,read diary dautumn=0 $V"
  [r3_unwritten_p2]="$A sept=farm:worked autumn=read,ans:sign,post,read diary dautumn=1 $V"
  [k1_answer_letter]="$C sept=farm:worked autumn=read,ans:send,post mailopen mailpanel mpick=autumn:open $V"
  [k2_diary_parcel]="$C sept=farm:worked autumn=read,ans:send,post,read,open diary dautumn=last $V"
  [s1_after_reload]="$B sept=farm:worked,write:stay autumn=read,reload,ans:ask_first,reload,post,read,reload diary dautumn=last $V"
  [w1_world_diary]="$A sept=farm:worked,inn autumn=read diary dworld $V"
  [d1_date_morning]="$A sept=farm:worked autumn=say $V"
  [d2_desk_waiting]="$A sept=farm:worked,write:finish autumn=read tab=Desk tpick=^autumn:answer|sign $V"
  [b1_before_morning]="$A sept=farm:worked,to:372 $V"
  [b2_before_desk]="$A sept=farm:worked,write:finish,to:372 tab=Desk $V"
)
names=("$@")
[ ${#names[@]} -eq 0 ] && names=("${!S[@]}")
for n in "${names[@]}"; do
  ( cd "$ROOT" && "$G" --path . -s tools/capture.gd -- out=$OUT/$n.png ${S[$n]} > "$OUT/$n.log" 2>&1 )
  [ "$ROOT" != "." ] && cp "$ROOT/$OUT/$n.png" "$OUT/$n.png" && cp "$ROOT/$OUT/$n.log" "$OUT/$n.log"
  echo "$n: $(grep -c 'SCRIPT ERROR' "$OUT/$n.log") script errors"
done
