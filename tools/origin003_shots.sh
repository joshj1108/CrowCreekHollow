#!/usr/bin/env bash
# CCH-ORIGIN-003: the in-engine review shots (one per thing being checked), into art/style_tests/CCH-ORIGIN-003/shots.
#   bash tools/origin003_shots.sh [name ...]     (no names: all)
G="${GODOT:-C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe}"
OUT=art/style_tests/CCH-ORIGIN-003/shots
mkdir -p "$OUT"
M="mailopen mailpanel season=Spring hour=9 scale=1"
declare -A S=(
  [a1_boxes_arrive]="past=origin:security,security_exit:stored,contact:friend pans=ship pflow=answered spring=spring,tidy $M mpick=spring:open|boxes"
  [a2_boxes_extension]="past=origin:security,security_exit:stored pflow=lapsed spring=spring,tidy $M mpick=spring:answer|more"
  [a3_deposit]="past=origin:security,security_exit:extension pflow=lapsed spring=spring,tidy $M mpick=spring:answer|query"
  [a4_boxes_followup]="past=origin:security,security_exit:stored,contact:friend pans=ship pflow=answered spring=spring,open:boxes,ans:send_on,post,go:50,read,tidy $M mpick=#2"
  [b1_offer]="past=origin:work pans=decline pflow=answered spring=spring,tidy $M mpick=spring:answer|take"
  [b2_desk_work]="past=origin:work pans=explain pflow=answered spring=spring,ans:take,post,read tab=Desk tpick=spring:answer|do season=Spring hour=14 scale=1"
  [b3_method_later]="past=origin:work pans=explain pflow=answered spring=spring,ans:method,post,go:40,read,tidy $M mpick=#2"
  [c1_key_density]="past=origin:household,household_relation:partner pans=ask pflow=answered spring=spring,tidy $M mpick=#0"
  [c2_things_choice]="past=origin:household,household_relation:partner pans=ask pflow=answered spring=spring,tidy $M mpick=spring:answer|write"
  [c3_diary_september]="past=origin:household,household_relation:partner pans=ask pflow=answered spring=spring,open:key,ans:write,post,to:340,read diary dspring season=Autumn hour=20 scale=1"
  [d1_friend_place]="past=origin:curiosity,contact:friend pfacts=crops pans=crops pflow=answered spring=spring,town,tidy $M mpick=spring:answer|place"
  [d2_photo_desk]="past=origin:curiosity,contact:none pans=keep pflow=answered spring=spring tab=Desk tpick=spring:answer|left_out season=Spring hour=20 scale=1"
  [d3_photo_diary]="past=origin:curiosity,contact:none pfacts=repair,crops pans=keep pflow=answered spring=spring,ans:compare,harvest:10 diary dspring season=Spring hour=20 scale=1"
  [e1_order_arrive]="past=origin:chance,chance_loose_end:order pans=send pflow=answered spring=spring,open:order,tidy $M mpick=spring:answer|return"
  [e2_meeting]="past=origin:chance,chance_loose_end:meeting pans=spring pflow=answered spring=spring,tidy $M mpick=spring:answer|purpose"
  [e3_storage_held]="past=origin:chance,chance_loose_end:storage pflow=lapsed spring=spring,tidy $M mpick=spring:answer|hold"
  [m1_after_winter_density]="past=origin:household,household_relation:private mailopen mailpanel scale=1 mpick=post:answer|defer"
  [m2_small_1024]="past=origin:household,household_relation:partner pans=ask pflow=answered spring=spring,tidy $M mpick=#0 size=1024x576"
)
names=("$@")
[ ${#names[@]} -eq 0 ] && names=("${!S[@]}")
for n in "${names[@]}"; do
  "$G" --path . -s tools/capture.gd -- out=$OUT/$n.png ${S[$n]} > "$OUT/$n.log" 2>&1
  echo "$n: $(grep -c 'SCRIPT ERROR' "$OUT/$n.log") script errors"
done
