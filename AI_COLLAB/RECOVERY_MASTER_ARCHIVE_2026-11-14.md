# Crow Creek Hollow — Recovered Master Design Archive
**Recovery date:** 2026-11-14  
**Purpose:** Preserve the extensive November 2026 creative collaboration without rewriting, flattening or accidentally promoting proposals to canon.  
**Status:** Index, reconstruction and discrepancy audit — **NOT** implementation approval. This document adds no game code, assets or save changes.

## Read this first: what was recovered
The recovered work already exists in dozens of substantial Git-tracked `AI_COLLAB/*.md` files. This archive is an **entry point, not a substitute for the originals**. A reader must open the linked full document before interpreting the associated story, screenplay, balancing, art or technical details. The longest writings should not be replaced with summaries.

**Authority order:** Owner's latest explicit direction and approval; actual running game/source and saves for what is implemented; `DESIGN.md` and `CLAUDE.md` for existing rules; `AI_COLLAB/DECISIONS.md` for recorded prior approvals; specific newer owner-approved changes in dated design notes. A *design rule* may be owner-approved yet unimplemented. Unapproved proposals are not canon. Never silently overwrite older implementations or approve new work just because it appears in this index.

### Story / player identity: complete sources
| Topic | Full source (do not condense away scene choices) | State |
|---|---|---|
| Overall creative experience and end-to-end life | [CREATIVE_BLUEPRINT_START_TO_FINISH.md](CREATIVE_BLUEPRINT_START_TO_FINISH.md) | Blueprint, future features mixed with existing |
| Original mystery, chapters, systems and ending logic | [../DESIGN.md](../DESIGN.md), [../docs/GDD.md](../docs/GDD.md), `scripts/story_act.gd`, `scripts/folk_system.gd` | Existing canon/source; code must be rechecked before edits |
| Literary prose rules | [NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md](NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md) | Editorial design |
| Motifs and pacing | [LITERARY_STRUCTURE_AND_HORROR_PACING.md](LITERARY_STRUCTURE_AND_HORROR_PACING.md) | Editorial design |
| Distinction between ownership, belonging, responsibility | [PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md](PLAYER_IDENTITY_AND_HOME_STORY_BIBLE.md) | Narrative foundation |
| Seven remembered farmhouse spaces and truthful diary | [HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md](HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md) | Design only |
| Choice/revelation architecture | [MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md](MEANINGFUL_CHOICES_AND_REVELATION_ARCHITECTURE.md); [CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md](CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md) | Proposed systems; preserve canonical flags |
| Five past lives with full two-year consequences | [TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md](TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md); [PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md](PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md) | **Mandatory five-origin direction approved by owner**; episode details editorial |
| Mandatory interactive introduction | [PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md](PLAYER_ARRIVAL_INTERACTIVE_PROLOGUE_DESIGN.md) | Owner requires non-skippable; older optional text superseded |
| Authored opening / five branch departure scenes, winter follow-through | [ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md](ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md) | Full screenplay **draft**, not final dialogue |
| Authored consequential spring/summer follow-up | [ROAD_TO_CROW_CREEK_HOLLOW_SPRING_RETURN_SCREENPLAY.md](ROAD_TO_CROW_CREEK_HOLLOW_SPRING_RETURN_SCREENPLAY.md) | Full screenplay **draft**, not final dialogue |
| Back-cover synopsis and Year One choice architecture | [YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md](YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md) | Proposed copy and branching |
| Individual seasonal designs | [FIRST_AUTUMN_BRANCHING_DETAIL.md](FIRST_AUTUMN_BRANCHING_DETAIL.md), [FIRST_WINTER_BRANCHING_DETAIL.md](FIRST_WINTER_BRANCHING_DETAIL.md), [FIRST_SPRING_BRANCHING_DETAIL.md](FIRST_SPRING_BRANCHING_DETAIL.md), [FIRST_SUMMER_BRANCHING_DETAIL.md](FIRST_SUMMER_BRANCHING_DETAIL.md), [FIRST_SEPTEMBER_BRANCHING_DETAIL.md](FIRST_SEPTEMBER_BRANCHING_DETAIL.md) | Design only, date/source safety gates apply |
| Second-year climax and life afterward | [YEAR_TWO_COST_OF_STAYING_DESIGN.md](YEAR_TWO_COST_OF_STAYING_DESIGN.md) | Design proposal anchored to existing ending logic |
| NPC voices and interconnection | [CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md](CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md), [SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md](SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md), [LIVING_COMMUNITY_RELATIONSHIP_WEB.md](LIVING_COMMUNITY_RELATIONSHIP_WEB.md), [RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md](RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md) | Existing walkers protected; additional cast tentative |
| Quality / red-team literary reviews | [NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md](NARRATIVE_QUALITY_BENCHMARK_AND_RED_TEAM.md) | QA design |

### Community and surrounding world: complete sources
- [WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md](WICKER_COVE_LIVED_IN_DISTRICT_BIBLE.md): **Wicker Cove** official name, fogbound working fishing community, distinct home/work interiors, mundane daily trade and recoverable buildings.
- [LOWMERE_FIRST_DISTRICT_DESIGN.md](LOWMERE_FIRST_DISTRICT_DESIGN.md), [LOWMERE_RESIDENTS_DESIGN.md](LOWMERE_RESIDENTS_DESIGN.md), [LOWMERE_ECONOMY_HISTORY_DESIGN.md](LOWMERE_ECONOMY_HISTORY_DESIGN.md), [LOWMERE_COASTAL_WORLD_DESIGN.md](LOWMERE_COASTAL_WORLD_DESIGN.md): legacy *file names/task IDs* may say Lowmere; don't assume that is the current settlement name.
- [YEAR_ROUND_COMMUNITY_RHYTHMS.md](YEAR_ROUND_COMMUNITY_RHYTHMS.md): villagers have routines independent of player.
- [INN_ROOM_BRANCHING_STORY_PROTOTYPE.md](INN_ROOM_BRANCHING_STORY_PROTOTYPE.md): concrete example tying repair work, a guest brief, winter consequence, and a changed window to story.
- [WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md](WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md): open continuity problem in original postman geography and letters; Option A is *recommended, not approved*.
- Fog is permanent in Wicker Cove. Different residents give incompatible accounts of when/how it arrived; **never declare an objectively verified onset or cause**. Farm weather varies seasonally. Do not turn repaired Wicker Cove into sunny sanitized village.

### Survival, crafting, woodland and skills: complete sources
- [WORKBENCH_ANVIL_WOODWORKING_DESIGN.md](WORKBENCH_ANVIL_WOODWORKING_DESIGN.md): owner-approved **design rule** that logs are hewn into planks at a physical workbench, all non-anvil-made tools are crafted at workbench, and appropriate metal tools are forged at anvil. Existing cooking/furnace/smokehouse/chopping-log stations remain meaningful. Exact rates and migrations pending audit.
- [FOREST_LOGGING_EXPEDITIONS_DESIGN.md](FOREST_LOGGING_EXPEDITIONS_DESIGN.md): owner-approved accessible repeatable woodland timber trip as primary source; optional deeper hardwood; preserve escorted story treks and NW ominous terrain.
- [SKILL_MASTERY_DESIGN.md](SKILL_MASTERY_DESIGN.md), [SKILL_ROSTER_AND_MARITIME_DESIGN.md](SKILL_ROSTER_AND_MARITIME_DESIGN.md): distinguish current skills/saves from proposed consolidated roles and future maritime skills.
- [FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md](FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md): compact acceptance test joining playable first-month farming, nearwood, workbench/planks, repairs and **one** Maren choice→delayed callback→factual diary. **Awaiting specific implementation approval**.
- [LIVING_WORLD_PRODUCTION_BLUEPRINT.md](LIVING_WORLD_PRODUCTION_BLUEPRINT.md), [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md), [MASTER_ROADMAP_TO_1_0.md](MASTER_ROADMAP_TO_1_0.md): phased roadmap rather than unlimited feature push.

### Art / UI / physical world sources
- [../ART_DIRECTION.md](../ART_DIRECTION.md), [VISUAL_PIPELINE_REASSESSMENT.md](VISUAL_PIPELINE_REASSESSMENT.md), [VISUAL_REVIEW_PROTOCOL.md](VISUAL_REVIEW_PROTOCOL.md): top-down 3/4, **not isometric**; consistent pixel scale and art family; comparison and screenshot gates.
- [UI_OVERHAUL_001_SPEC.md](UI_OVERHAUL_001_SPEC.md): balanced Rustic Gothic UI kit, practical immersive menus and controller/navigation verification.
- [FARMHOUSE_INTERIOR_001_SPEC.md](FARMHOUSE_INTERIOR_001_SPEC.md): lived-in interior; working lit fireplace/candles, seasonal curtains/windows, broken stage-0 and cozy restoration, furniture interaction and save integrity.
- [FARM_001_CONCEPT_MIGRATION_PLAN.md](FARM_001_CONCEPT_MIGRATION_PLAN.md) and `ART_005_*` notes: wider homestead with road/gate, mailbox and market, ominous NW cave/hillside, smaller actual tilled fields, same house footprint over restoration stages. **Historic visual variant approvals may have been revised**: verify the latest accepted mockups and production state, particularly log walls vs later shingle/shake siding.
- Moonlit static menu artwork is selected. No further animation experiment without user request. Light should feel eerie but comfortably readable; lantern tiers increase **radius, not maximum intensity**.

## Recovered narrative contract (owner-set, not a new invented story)
**A player must know both why they came and why they stay.** `Two Lives, One Road` specifies **five serious, equal-weight reasons for coming**, each with a distinctive concrete opening, belongings/contact/keepsake choices, a winter complication, a consequential spring/summer decision, and September/year-two/postending echoes:
1. **The Cost of a Room** — affordable shelter and changed housing terms; not a mandatory impoverished or morally flawed hero.
2. **Work That Belonged to Everyone** — reclaiming time and autonomy from obligations; not automatic crafting expertise or despised coworkers.
3. **A House With One Less Person** — changed household life; **not** mandatory death, romance, relationship status or bereavement.
4. **The Place in the Photograph** — curiosity and a meaningful journey; **not** chosen-one occult destiny.
5. **A Chance Before It Closed** — acting on uncertain opportunity; **not** a throwaway route.

The mandatory, non-skippable original interactive `Road to Crow Creek Hollow` interlude uses ordinary readable prose, physically situated choices and short travel transitions. Player can pause/resume/back or decline unnecessary personal disclosure; they cannot skip the *reason for coming*. The current editorial screenplay targets ~7–10 minutes subject to playtest and trimming, **not** mandatory ten-minute passive cinema. It must hand off to October 1 gameplay without time loss or breaking save compatibility. Old life is a **parallel arc**, not supernatural evidence, and factual diary must never invent feelings.

## Canon protection: original mystery and chronology
Existing Rook/Agnes/Elias/Hollow/crow-bell story has **17 ordered chapters** and the three established endings **The Hollow Sleeps**, **Two Came Home**, and **The Line Under the Rooks**. Preserve the original Old Maren, Davy Tull, vicar and postman roles, story IDs, escort routes, evidence gates and endings. These are not replaced by five-origin biography or a D&D-like roll.

Known chronological anchors to **revalidate against runtime** before patching:
- New main game Day 1 = October 1; ~420 real seconds/day; sleep before 03:00.
- Day 4: Maren first forest-edge escort; Day 14 earliest mill after prerequisites; first harvest around Day 8.
- Day 240 = May 28: clerk E. Pell letter; Day 265 = June 22 conditional orchard beat; Day 285 = July 12 earliest knock trigger.
- Day 300 = July 27: mill meeting opportunity requiring `maren_book` + `vicar_register`; Sep 22 / Day 357 fallback.
- Year two Day 370 / Oct 5: Davy night; Day 396 / Oct 31: second All Hallows crow bell and original ending conditions.
These are protected against optional branching, hidden rolls, personal origins and new village travel.

## Recovery discrepancies / incomplete decisions: DO NOT silently resolve
1. **Farm acquired vs inherited.** Older synopsis says inherited farmhouse; later source-grounded screenplay says farm is town-held/occupied on terms and existing `EstateSystem` offers deed purchase (~12,000 coins in prior source audit). Keep latter as working **runtime constraint**; don't declare inheritance legally canon without explicit redesign/approval. Rewrite marketing copy later after owner decides.
2. **Lowmere vs Wicker Cove geography.** Wicker Cove is official future village name; original postman has letters/iron from Lowmere and 'over hills' geography. Three audit options; recommended same coastal place via ridge road **not accepted** yet.
3. **Origin detail vs canonical dialogue.** Five-origin requirement is confirmed; draft wording, contacts, calendar slots, economy, and all five complete playable arcs need editorial + source audits.
4. **Visual prototypes vs production.** Prior approvals for log exteriors and Roof A dark wood shakes are attached to dated *nonproduction* mockups. Later user preference leans weathered shake siding and simpler four-stage architecture. Reconcile with current art/screenshots before changing assets; no automatic bulk replacement.
5. **Forest/bench economics.** Exact log↔plank yield, workbench placement, tool tier prerequisites, lantern assembly, regrowth and travel duration not approved. Avoid axe→bench→plank→axe loop and regression in first 30 days.
6. **New community residents.** Edith Vale, Thomas Bellweather, Gideon Pike, Martha Fenwick are **tentative**, not owner-finalized canon. Do not give them lore that overwrites four original walkers.
7. **Statuses.** A document marked 'design complete' proves writing exists, not implemented gameplay. Verify live `scripts/*`, tests, screenshots and saves before saying any feature is playable.
8. **Opening length conflict.** Earlier optional 4–7 minute prologue text is **superseded** by mandatory, substantial five-origin interlude; final duration depends on human playtest and narrative pacing.

## Practical change-control / preservation rules
- **No novel claims of canon:** do not decide what killed or caused fog, invent a universal player tragedy, make someone secretly know origins, change bell/evidence gates, or force a morally correct farm/town choice.
- **No premature gameplay changes:** this archive grants Claude no authorization to edit source, art, scene files, flags or `DESIGN.md`.
- **Do not replace full screenplay with a synopsis.** Edit the original source documents in later owner-reviewed editorial passes with history preserved.
- **Never rewrite player memories:** events/actions in diary must be supported by saved state, with privacy controls and no obligatory emotion labels.
- **Work in reversible slices:** actual first-month test, then one confirmed choice+callback, then expand. End-to-end save/migration QA including legacy saves and original three endings.
- Continue using [README.md](README.md), [TASKS.md](TASKS.md), [DECISIONS.md](DECISIONS.md), [MESSAGE_BOARD.md](MESSAGE_BOARD.md) as asynchronous, owner-controlled collaboration, not live communication.

## Source inventory and coverage
This pass located the repository's substantial `DESIGN.md`, `docs/GDD.md`, `CLAUDE.md`, project code, and the full `AI_COLLAB` design set through GitHub. The full text of **every** linked work is already in Git history. This index was assembled from current filenames and direct reads of the major handoff, prologue, origin, screenplay, story, woodland, interior and roadmap documents; it is not a fresh line-by-line audit of every source or a Godot runtime test. Further recovery should be **targeted gap resolution**, not unnecessary wholesale re-authoring.
