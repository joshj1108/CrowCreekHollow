# CCH-LIVING-WORLD-001 — Playable Social World: Production and Acceptance Blueprint

**Prepared 2026-11-14. Status: DESIGN + ENGINEERING PLAN ONLY.** User asks to continue developing vision; **no direct authority** to implement new code/asset changes, alter current main-story lines, or tell Claude to perform an unapproved migration.
**Use:** `MASTER_ROADMAP_TO_1_0.md`, `DEVELOPMENT_ROADMAP.md`, `LIVING_COMMUNITY_RELATIONSHIP_WEB.md`, `SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md`, source `scripts/folk_system.gd` and `scripts/story_act.gd`.

## What v1.0 should *feel* like, not simply contain
- A player can live a meaningful life entirely on their farm; they still encounter original walker story at the player's chosen pace.
- A player who regularly brings crop boxes down the road finds two workers who learn how to rely on the farmer's goods.
- A player who prefers carpentry can cut forest logs, hew planks at their bench (new approved future mechanic), and decide whether to repair their house or a small inn project.
- A player drawn to mysteries can hear two incompatible fog memories and see both as plausible accounts, while the original Rook evidence remains separately authoritative.
- Across these playthroughs, at least one NPC remembers a *specific verified event* three or more weeks later without the game labeling the farmer as virtuous, selfish, brave or cowardly.
- Ordinary mornings are worth playing even with no new cutscene; no daily mandatory relationships checklist.

## Current source realities to design around
- Four implemented walker profiles in `FolkSystem.FOLK`: `mill` Maren (farm visit from day5 and only once edge walk done), `orchard` Davy (day20), `chapel` vicar (day40), `post` postman (day6). Each has existing 0–10 heart behavior from walks/talk/gifts and four staged scenes. No guaranteed daily visits: `_pick(d)` is deterministic seeded per day but can pick nobody, and returns nobody on an eligible gate-walker day. `_visiting` is time- and location-bound.
- `_talk(id)` returns `scene`, `line`, or `again`; a general 3–4-option dialogue surface is **not established by this function**. Existing scenes take priority via `StoryAct._folk_scene` and then `_next_scene`.
- `FolkSystem` already saves `bonus/met/seen/tastes/requests/requests_done/talk_day/gift_day/visitor`. The design must reuse save semantics rather than double-pay from journal entries or add heart points every time the same reaction appears.
- Story critical: day240 letter, orchard after day265, conditional knock after day285 and 4 days after orchard, mill after day300 with `maren_book` & `vicar_register`, Davy day370 20:00–01:00 conditional, bell second All Hallows and grove/3 endings. This is existing code.
- Existing forestry has 12 scattered grove trees and generic `wood`, with accepted future solo forest logging → **logs** → workbench-hewn **planks** and non-anvil tools at workbench; **anvil** for metal tool forging. These are future design rules, not current implementation.
- Wicker Cove town and four named residents remain **planned**, not currently proven implemented. Official name and permanent fog canon; no verified hard-coded city identity in actual runtime. Historical Lowmere postman words require `CCH-LORE-NAME-001` review.

## Minimum believable-world vertical slice (six concrete outcomes)
**Target slice:** ONE existing walker; ONE optional branch; ONE reliable later callback; ONE accurate personal diary memory; ONE tangible change using *existing* game resources and UI; full original story progression intact.
1. **First meeting:** a short Maren conversation at an actual eligible source point, ideally after original day4 edge trek; 2–3 choices or equivalent practical actions (help vs trade vs independent) without disrupting the escort.
2. **Choice made:** record one immutable outcome and any real resource/time cost once.
3. **Same-day reaction:** two distinct natural language lines, one physical consequence if possible (e.g. consume wood only if chosen).
4. **Future echo:** conditional letter or morning note after 7–21 days, not solely random visit.
5. **Diary:** a personal page with one verified fact and at most one selected interpretation. Player pages in player's hand, never Agnes's.
6. **QA:** two contrasting player runs plus skip/old-save; first chapter, day4 escort, first crop, day240 story/ending compatibility.

**Not in slice:** Wicker Cove map, 4 new characters, rumor engine, 12 scenes, generic skill-check engine, global rumor AI, city simulation, shipping network or dynamic NPC pathfinding.

## Layered rollout

### Stage 0 — Lore/data and first-hour audit [P1, before gameplay migration]
- Enumerate actual `FolkSystem` scene triggers/heart levels; inventory resources and crafting; mailbox, diary, house repair and current traveler transition paths.
- Audit old Lowmere postman lines and current canon; produce owner decision with minimum necessary text changes.
- Identify one reliable callback channel from existing mail/diary/morning mechanism and document older-save behavior.
- Record a 30-day *human test* baseline, not merely balance simulation.
**Exit:** no unknown gate that would make first-choice prototype break early story.

### Stage 1 — Existing-farm choice/memory proof [P1 gated]
- One Maren side event (short, optional, no new sprite).
- Save one decision and one callback consumed-once state.
- Add one conditional player-hand diary memory (or bounded selection in existing diary).
- Support controller/mouse, skip, one save/reload and early-night event handling.
**Exit:** alternative players see different later texts 7+ days later and no duplicate rewards.

### Stage 2 — Satisfying wood production loop [P1 gated, separate approved changes]
- Accessible nearwood cutting area, with obvious tree targets and return route.
- Forest tree regrowth stored persistently; logging does not reset Hollow trek pressure by accident.
- Workbench accepts raw logs and visibly hews into planks; woodworking tools physically crafted there; metal forged at later anvil.
- Keep an early/starting hatchet and usable bench without circular requirements. Review fuel and old `wood` saves.
**Exit:** a first-week player can cut, carry, make planks and perform an appropriate repair without multiple repetitive hour-long trips.

### Stage 3 — Small economic network [P1/P2 gated]
- Two or three optional home dispatch orders with **real margins** from existing farm goods, correct inventory and one-turn-in semantics.
- One short notice/return-basket callback based on an actual fulfilled order.
- No town map needed yet; orders can be delivered by mailbox/stand mechanism.
**Exit:** merchant/supplier path is useful but not stronger in every situation than self-provision or direct stand sales.

### Stage 4 — First Wicker Cove district + two workers [P2 1.0 target gated]
- Compact downhill approach, persistent dense coastal fog, road/return, a store and inn/market/dock anchors; all basic interactions readable even when fog is dense.
- **Owner decides** between Edith + Thomas or Edith + Martha/Gideon as initial pair; never assume names are final.
- One ordinary contract and one short 2-NPC scene; the workers return to their jobs after conversation.
- One local physical repair if project system works, ideally a room or store shelf, using actually made planks when correct.
- A second village resident knows player action only if a delivery/workplace connection exists.
**Exit:** full afternoon visit, return before bedtime, useful shopping independent of narrative quest, no softlocked story, contrasting first-visit reactions.

### Stage 5 — Season-spanning relationship arc [P2 gated after 4]
- Select **one** recurring object (basket, repaired shelf, dry wood, bucket or net) and show its state in autumn/winter/spring/summer where appropriate.
- One later customer request or returning guest uses actual prior work; ordinary help and paid work both valid.
- One September 'My Days' memory and one second-autumn callback, both conditional.
**Exit:** a full-year playthrough experiences one meaningful consequence that required prior choice and persisted save state, but players who ignore it have a meaningful year too.

## NPC daily routines: light-weight scheduling *without* sprawling simulation
Early town first playable district: a **small number of discrete schedule states**, not seamless life-physics.
- **Before shops open:** Edith starts stove/prepares guest spaces; Thomas inventories stock; Martha receives early catch; Gideon checks boat. The exact local clock windows are *TBD by engineering* to fit 420-second game days and user-friendly visits.
- **Work hours:** residents anchored in useful locations; never make player miss all services because NPC wandered into inaccessible interior. A shop remains usable through consistent counter or sign if worker briefly elsewhere.
- **Afternoon:** short 1–2-step change (Edith hanging sheets, Thomas unloading delivery, Martha salting catch, Gideon mending nets) *if* animation/art capacity allows. Use ambient poses or small position changes before adding navigation AI.
- **After hours:** signs/lights change, ordinary lives suggested; no forced ghost shopkeeper or perpetual storefront NPC.
- **Bad weather:** adjust one task/line, not the entire schedule or a complicated emergent AI sim.
- **Seasonal accents:** spring windows aired at inn; summer crates/fish nets; autumn bundled wood; winter damp clothes at stove. Permanent fog at Cove remains across seasons.
- **No staged town restoration claim:** when room repaired, one window changes and the room can serve a guest; neighboring boarded houses still look lived-in/struggling.

## Save-data candidate contract (field names illustrative ONLY)
Do not implement without reviewing current save serializer:
```
social_events: {
  event_id: {
    chosen: "exchange",
    day: 10,
    completed: true,
    paid: true,
    observed_by: ["mill"],
    callback_consumed: false
  }
}
town_projects: {
  inn_roof: {stage: 1, paid_materials: true, completed_day: 190}
}
personal_memories: ["maren_exchange_10", "inn_roof_repaired_190"]
```
- Store **facts**, not inferred moral labels. The chosen action is not automatically equivalent to successful completion.
- The callback's knowledge path uses actual encounter / postal / trade provenance; no global reputation score.
- Never duplicate same reward, craft XP, relationship point or mail item when loading.
- Avoid generating a diary entry every morning; select a few authored pages.
- When feature absent or save older, leave optional memory empty rather than invent history.
- Debug view can show flags and condition tests, but not expose hidden story spoilers in public UI.
- Seeded hidden d20 only for a genuinely uncertain optional labor/investigation effort; never for canonical story gates, basic crafting or ordinary trade.

## Four 30–45 minute test playthroughs (real player time; actual full-year simulations separately)
**A. Quiet farmer:** don't visit future Cove, ignore optional requests, still farm/craft/woodcut, get original walker/quest opportunities. Diary doesn't imply new friends.
**B. Helpful neighbor:** choose Maren advice, actually fulfill 1 realistic order, sees 1 deterministic callback, doesn't get a magical best ending.
**C. Practical merchant:** take paid trade/repair; receives actual revenue and exact contract outcome, personal diary focuses on work not altruism.
**D. Curious woods walker:** prioritize woodland treks and original pages, maybe one fog testimony when town exists; no hidden roll can settle permanent fog or bypass original evidence.
For each: first-hour onboarding, gamepad, bag capacity, save/load, first winter fuel, day240 letter, day300 meeting, day370 Davy, second All Hallows, 3 endings and continued play.

## Definition of DONE for new social content
- Two paths differ beyond flavor text: money/material/service/relationship/known facts/reachable opportunity.
- NPC dialogue is under control of **real evidence and plausible provenance**.
- Resident has a daily job and no player-dependent idle existence.
- A player may decline with no judgemental text, but can miss real bounded opportunity.
- At least one later callback occurs through reliable mechanism, or the feature is explicitly only ambient.
- The original `FolkSystem` scenes, `StoryAct` milestones, inventory/forestry and controller controls remain correct.
- Tested with human play, not just code-review.
- No canonical old fog mystery answer, no new NPC asserting that Agnes caused coastal fog.

## Priority register (all gated unless design)
| ID | Priority | Scope |
| --- | --- | --- |
| CCH-LIVING-WORLD-001 | P1 design | This linked player-experience and production blueprint |
| CCH-LIVING-WORLD-AUDIT-001 | P1 | Current UI/save/scene/day schedule and conflict audit |
| CCH-LIVING-WORLD-SLICE-001 | P1 candidate | One Maren choice + later callback + diary |
| CCH-LIVING-WORLD-TIMBER-001 | P1 candidate | Forest logging + workbench planks (reuse CCH-FOREST-LOGGING-003 and WORKBENCH-001) |
| CCH-LIVING-WORLD-ORDER-001 | P1/P2 candidate | One paid supply request + plausible indirect memory |
| CCH-LIVING-WORLD-COVE-001 | P2 candidate | Two workers + one social/physical improvement in first district |
| CCH-LIVING-WORLD-YEAR-001 | P2 candidate | Year-spanning object/memory after earlier slices work |
| CCH-LIVING-WORLD-QA-001 | P1 eventual | Branch, no-town, dated events, old save, endings and pacing |

**No code has been changed by this blueprint. Implementation is a series of separate decisions, not a single giant Claude prompt.**
