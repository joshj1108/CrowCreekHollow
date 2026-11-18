#!/usr/bin/env bash
# CCH-ORIGIN-004: the in-engine review shots for "One Year on the Road", into art/style_tests/CCH-ORIGIN-004/shots.
#   bash tools/origin004_shots.sh [name ...]     (no names: all)
# Full size (scale=1), so the diary's handwriting can be read. Each uses tools/capture.gd's past=, spring= and sept=.
G="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
OUT=art/style_tests/CCH-ORIGIN-004/shots
mkdir -p "$OUT"
V="season=Autumn hour=20 scale=1"
A="past=origin:security,security_exit:stored,contact:friend pans=ship pflow=answered spring=spring,open:boxes,ans:thanks,post,read"
B="past=origin:work,work_exit:boundary pans=explain pflow=answered spring=spring,ans:method,post,go:40,read"
C="past=origin:household,household_relation:partner,household_change:separate,keepsake:notebook pans=ask pflow=answered spring=spring,open:key,ans:time,post,read"
CL="past=origin:household,household_relation:partner,household_change:separate,keepsake:postcard pans=ask pflow=answered spring=spring,open:key,ans:time,post,read"
D="past=origin:curiosity,contact:none,curiosity_interest:quiet pans=keep pflow=answered spring=spring,ans:left_out"
E="past=origin:chance,chance_loose_end:order pans=hold pflow=answered spring=spring,ans:collect,post,read"
AF="past=origin:security,security_exit:forward pans=end pflow=answered spring=spring,ans:sign,post,read"
declare -A S=(
  [o1_A_security]="$A sept=farm:worked diary dsept=0 $V"
  [o1_A_security_p2]="$A sept=farm:worked diary dsept=2 $V"
  [o2_B_work]="$B sept=farm:worked,inn diary dsept=0 $V"
  [o2_B_work_p2]="$B sept=farm:worked,inn diary dsept=2 $V"
  [o3_C_household]="$C sept=farm:worked diary dsept=0 $V"
  [o3_C_household_p2]="$C sept=farm:worked diary dsept=2 $V"
  [o4_D_nocontact]="$D sept=farm:bare diary dsept=0 $V"
  [o4_D_nocontact_p2]="$D sept=farm:bare diary dsept=2 $V"
  [o5_E_chance]="$E sept=farm:worked,cove:3 diary dsept=0 $V"
  [o5_E_chance_p2]="$E sept=farm:worked,cove:3 diary dsept=2 $V"
  [f1_farm_restored]="$AF sept=farm:restored,deed:12000 diary dsept=2 $V"
  [f2_farm_unrepaired]="$AF sept=farm:bare diary dsept=2 $V"
  [p1_past_completed]="past=origin:chance,chance_loose_end:storage pans=send pflow=answered spring=spring,open:unit,ans:give_some,post,read sept=farm:worked diary dsept=0 $V"
  [p2_past_unresolved]="past=origin:security,security_exit:stored pans=ship pflow=answered spring=spring sept=farm:worked diary dsept=0 $V"
  [v1_private]="past=origin:household,household_relation:private,contact:private pans=keep pflow=answered spring=spring,ans:close,post,read sept=farm:bare diary dsept=0 $V"
  [r1_choosing]="$C sept=farm:worked tab=Desk tpick=september:write|keep $V"
  [r2_written]="$C sept=farm:worked,write:keep tab=Desk spick $V"
  [r3_after_reload]="$C sept=farm:worked,write:keep,reload diary dsept=last $V"
  [l1_longest_p0]="$CL sept=farm:worked,inn,write:unsettled diary dsept=0 $V"
  [l2_longest_p2]="$CL sept=farm:worked,inn,write:unsettled diary dsept=2 $V"
  [l3_longest_p4]="$CL sept=farm:worked,inn,write:unsettled diary dsept=4 $V"
  [s1_small_1024]="$C sept=farm:worked tab=Desk spick $V size=1024x576"
)
names=("$@")
[ ${#names[@]} -eq 0 ] && names=("${!S[@]}")
for n in "${names[@]}"; do
  "$G" --path . -s tools/capture.gd -- out=$OUT/$n.png ${S[$n]} > "$OUT/$n.log" 2>&1
  echo "$n: $(grep -c 'SCRIPT ERROR' "$OUT/$n.log") script errors"
done
