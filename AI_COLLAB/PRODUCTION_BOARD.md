# Crow Creek Hollow — Production Board (CCH-RELEASE-001)

**Started:** 2026-11-15. **Kept by:** Claude Code. **Final authority:** the owner.
**This is the one release board.** It replaces the ranked queue in `MASTER_ROADMAP_TO_1_0.md` §5 and the P0–P3
labels in `DEVELOPMENT_ROADMAP.md` for scheduling. Those files keep their design history; `TASKS.md` keeps the history
of finished and in-review tasks. `DESIGN.md` stays the source of truth for rules, layout and art. Nothing here
approves a design: rows marked *owner decision* wait for the owner.

Target: Windows / Steam, $19.99, a complete single-player **Year One** (see OD-1: the code's story runs into year two).

## 0. Handoff (read this first)

- **State:** a large, mostly working farm game with 17 story chapters and 3 endings, a playable first village, and a
  19-of-20 green automated suite. **No human has played any of it end to end.** The new narrative canon (mandatory
  interlude, five origins, resident arcs) exists only as documents: **zero code**.
- **Can't ship today because:** no release build can be made (no export templates), the origin/interlude story isn't
  built, timber (logs → planks, workbench/anvil) isn't built, the story's length doesn't match "Year One" (OD-1),
  and there is no human playtest.
- **Done this session:** audit, this board, regression runner now covers all 20 suites and fails loudly; shader-cache
  workaround verified over 4 launches; trek timing investigated (real cost, threshold kept).
- **Next three tasks:** R-P0-02 export templates and a clean release build (owner installs templates) → R-P3-01
  interlude and origin choice, first playable slice → R-P1-03 logs → planks at the workbench.
- **Owner decisions waiting:** OD-1 to OD-6 (section 4), plus the pending CCH-EVENING-002 multipliers and
  CCH-WICKER-COVE-002 batch.

## 1. Evidence levels

Every status below says how it was checked. These are never mixed up:
**[code]** static reading · **[auto]** headless test suite · **[sim]** `balance_sim` / scripted runs through game
functions · **[bot]** windowed play with injected keyboard/controller input · **[human]** a person played it.
No row is **[human]** yet.

## 2. Release-readiness audit (2026-11-15)

Status: **VW** verified working (auto and/or bot) · **NV** implemented, needs verification · **PI** partially
implemented · **PL** planned, not implemented · **BB** broken or blocked.

| System | Files | Status | Evidence | Missing / risk | Acceptance for 1.0 |
| --- | --- | --- | --- | --- | --- |
| Saving, recovery, versions (v17) | `save_system.gd` | VW | auto `save_test` 66 | Every new system must add keys + migration | Old saves of each version load; crash mid-save recovers; no slot 1-3 writes in tests |
| Menus, pause, settings, input (kb, mouse, Xbox) | `title_menu.gd`, `action_bar.gd`, `game_settings.gd` | VW | auto `menu_test` 854 | No key/button remapping; human controller feel unchecked | Every panel reachable and escapable on all three devices; human pass |
| Static moonlit main menu | `title_menu.gd` | VW | approved (UI-OVERHAUL-001) | — | unchanged |
| HUD (Hunger, Thirst, Comfort; Health, Sanity) | `action_bar.gd`, `hud_icon.gd` | NV | HUD-REDESIGN-002 review requested | Owner acceptance pending | Owner accepts; no numbers |
| Farming, crops, watering, seasons | `farm_system.gd`, `weather.gd` | VW | auto, sim, bot first harvest (PLAYABLE-002) | Human pacing unknown | First harvest by ~day 6 in human play |
| Survival needs + Sanity + nights | `sanity_system.gd`, `madness_system.gd`, `night_system.gd` | NV | auto `evening_test` 166, sim | Balance unaccepted; winter is the hard season | Human fortnight + winter without despair or trivialisation |
| Evenings, shelter, Quiet Hour (CCH-EVENING-002) | `evening_system.gd` | NV | auto, sim; played evidence 1-2 evenings/style | Multipliers make a repairing sleeper nearly safe (report §F) | Owner picks multipliers; 14 played evenings per style |
| Farmhouse restoration (4 stages) | `estate_system.gd`, `farm_scenery.gd`, `interior_art.gd` | PI | auto `interior_test` 136 | Porch/second storey still live (D-015 conflict); production stage art incomplete | Four coherent stages, no storey dependency on the critical path |
| Inventory, bags, storage, cellar/cooler/smokehouse | `bag_panel.gd`, `stall_system.gd` | VW | auto, sim | — | unchanged |
| Crafting stations (workbench / anvil) | `craft_system.gd` | **PL** | code: one Craft panel, no stations | Owner rule "non-anvil tools at a workbench" not built | Workbench and anvil as places; tools split per rule |
| Timber: logs → planks, forest woodcutting | — | **PL** | code: no planks anywhere | Required by non-negotiables; inn repair waits on it | Fell → logs → hew at workbench → planks used by repairs |
| Tools, forestry, mining, smithing, shields | `mining_system.gd`, `combat_system.gd`, main.gd | NV | auto `creature_test` 74 | Upgrade ladder vs new stations | Each tier reachable in Year One |
| Lantern (radius tiers, fixed energy) | main.gd `LANTERN_TIERS` | VW | code + auto | — | matches design rule |
| Cooking, food economy | `foods.gd`, `tools/food_audit.gd` | NV | auto, data audit (CORE-LOOP-003) | 21/24 dishes restore less than raw parts (formula kept on purpose) | Cooking worth doing; human judgement |
| Stand, daily job, village notices | `stall_system.gd`, `town_system.gd` | NV | auto `orders_test` 46, bot | No human play; no partial delivery | Orders beat dumping at the stand, never required |
| Fishing, forage, animals | `fishing_system.gd`, `forage_system.gd`, `animal_system.gd` | NV | sim | Harbour fishing proposed only | unchanged unless gaps shown |
| Combat (cave foes, dogs, blocking) | `combat_system.gd`, `cave_foe_art.gd` | NV | auto | Human fairness unchecked | Fair, avoidable, readable |
| Mining cave (NW hillside) | main.gd, `cave_art.gd` | VW | auto `aoh_cave_check` | — | unchanged |
| Forest treks | `trek_system.gd`, `trek_art.gd` | NV | auto 208+209+62 pass; timing FAIL | Clearing rebuild 37-45 ms median, 59-80 max: a visible hitch when logs clear mid-trek | Rebuild under one frame budget or hidden by the fade (R-P5-04) |
| Wicker Cove (alpha + notices) | `town_*.gd` | NV | auto `town_test` 65, bot kb+Xbox; visual accepted D-019 | Residents fixed to tiles; no routines; not human-played | Human visits, trades, returns without help |
| Village rendering / shader cache | `project.godot` | VW | 4 launches, one profile, cache stays empty; farm night + village day/rain/night normal (this session) | Shaders compile each launch; controller warm launch checked earlier only | Unchanged across launches and Godot updates |
| Living Memory | `TownSystem.flags`, `.history` | PI | code | Stored; only Thomas reads the last delivery | Residents and diary react to what the player did |
| Folk on the farm (Maren, Davy, vicar, postman, Mrs Tull) | `folk_system.gd` | NV | sim | No daily routines; resident arcs designed only | Each has a routine and an arc in Year One |
| Story chapters 1-17, second-year act, 3 endings | `story_act.gd`, `mystery.gd`, `ending_screen.gd` | NV | sim (17/17, all endings) | Act opens day 240, bell from day 396: **two years** (OD-1); never human-played | A human reaches an ending |
| Agnes's diary + handwriting | `diary_book.gd`, `mystery.gd` | VW | auto `diary_test` 63; UI approved | — | unchanged |
| Opening interlude + five origins | AI_COLLAB screenplays | **PL** | docs only | Owner-mandated, non-skippable; nothing built | Interlude plays, origin saved, ≥3 later consequences per origin |
| Mid-year decisions, resident arcs, inn room | AI_COLLAB designs | **PL** | docs only | Large; must be scoped (OD-3) | Per scope decision |
| Achievements / Steam | `achievement_system.gd`, `steam_achievements.gd` | PI | code | GodotSteam not in the project | Unlocks reach Steam in a Steam build |
| Audio (SFX, ambience, music) | `music_system.gd`, `ambience_system.gd`, `tools/make_*.py` | PI | code | Generated in-house (licence clean); production quality is an owner call (`MUSIC_BRIEF.md`) | Owner accepts the mix and score |
| Accessibility | `game_settings.gd` | PI | code | Has volumes, window, message speed, page turns. No remapping, text size, brightness | Remap, text size, brightness/gamma, flashing/shake toggle |
| Release build / export | `export_presets.cfg` | **BB** | no 4.7.2 export templates on this machine; `builds/` exe is from 2026-10-27 | Cannot produce a build | `--export-release` from a clean checkout, runs on a second PC |
| Regression suite | `tools/audit_run_tests.sh` | VW | 20 suites, one command (this session) | Was missing 4 suites and never failed | Green before every commit |
| Performance | `tools/perf_f.gd` | NV | auto | No target hardware documented | Documented min spec holds 60 fps |

## 3. Known gaps investigated (directive §6)

- **Evenings:** code is done and tested; what remains is (1) the owner's multiplier choice (report recommends Boarded
  0.80 / Patched 0.65 / Restored 0.55), (2) 14 played evenings per style, (3) a human winter. Not balanced yet.
- **Village rendering:** verified this session over four launches on one profile (farm night ×2, village sunny day,
  village rain night): the cache folder stays empty and brightness is stable (12/12, 64, 28; the fault read 152).
  Sheet: `art/style_tests/CCH-RELEASE-001/work/sheet_shader.png`. Controller input was not re-checked this session.
- **Core economy:** the two recipe changes and the notices are sound in tests and sims; whether the loop *feels*
  rewarding needs a human. Cooking still mostly loses Hunger against raw food; that is a design call (OD-5).
- **Living Memory:** `flags` (five first-time events) and `history` (deliveries) are saved; only Thomas's line about
  the last delivery reads them. Everything else is stored data waiting for dialogue.
- **Trek timing:** not a flaky threshold. Over 381 clearing layouts the rebuild takes a median 37-45 ms (p90 43-57,
  max 59-80; worse with other processes running). It runs on clearing entry and whenever the clearing's tiles
  change (a log cleared), so the player can see a 2-4 frame hitch mid-trek. Threshold kept at 50 ms; fix is R-P5-04.
- **Narrative integration:** chapters 1-17, the act and three endings are code. The interlude, five origins,
  winter screenplay, midyear decisions and resident arcs are documents only. Shortest path: R-P3-01 to R-P3-04.

## 4. Owner decisions needed

| ID | Decision | Why it matters |
| --- | --- | --- |
| OD-1 | **Year One vs the coded story.** The act opens day 240 and the bell can't be hung before day 396, so every ending is in year two. Compress the act into year one, or define 1.0 as "through the second All Hallows"? | Sets the length of the whole game and every narrative task |
| OD-2 | Retire the porch and second storey (D-015 plan) or keep them as optional purchases | Restoration stages and achievements depend on it |
| OD-3 | Which designed narrative pieces are 1.0: interlude + five origins (required), midyear decisions, how many resident arcs, the inn room | Largest scope lever in the project |
| OD-4 | Evening multipliers (CCH-EVENING-002 §G) | Survival balance |
| OD-5 | Should cooked food restore more than its raw parts? | Whether cooking is worth doing |
| OD-6 | Music: keep the generated score, commission, or license | Licensing and polish schedule |
| (pending) | CCH-WICKER-COVE-002 batch and its five sub-decisions | Living Memory's first real use |

## 5. Roadmap P0–P7

Effort: **S** one session · **M** 2-4 sessions · **L** 5-10 · **XL** 10+ (Claude sessions; human time noted).
Status uses section 2's codes plus **done**. Every task's evidence goes in `art/style_tests/<ID>/` and its report in
`AI_COLLAB/`. Tests required: the full suite (`bash tools/audit_run_tests.sh`) plus the ones named.

### P0 — Stability and integration
| ID | Task | Depends | Acceptance | Tests | Effort | Status |
| --- | --- | --- | --- | --- | --- | --- |
| R-P0-01 | Regression runner covers every suite and fails loudly | — | 20 suites, summary, exit 1 on any failure | the runner itself | S | **done** (this session) |
| R-P0-02 | Reproducible release build | owner installs 4.7.2 templates | `--export-release` from a clean checkout; exe starts, saves, loads on this PC and one other | save_test, a bot run on the exe | S + owner | BB |
| R-P0-03 | Human smoke playtest, days 1-14 (owner) | R-P0-02 | owner plays from a build; notes in `TESTERS.md` format | — | owner 3-4 h | PL |
| R-P0-04 | Release-build audit: debug menu, F4, dev unlocks absent; logs on | R-P0-02 | checked in the exported exe | debug_menu_test | S | NV ([code] gated by `OS.is_debug_build`) |
| R-P0-05 | Document target hardware and first perf baseline | R-P0-02 | min spec written; perf_f on it | perf_f | S | PL |

### P1 — Core gameplay completion
| ID | Task | Depends | Acceptance | Effort | Status |
| --- | --- | --- | --- | --- | --- |
| R-P1-01 | Evening balance accepted (OD-4) and played fortnight | OD-4 | numbers set; 14 played evenings per style | M | NV |
| R-P1-02 | Workbench and anvil as stations; tool recipes split per the owner rule | — | non-anvil tools only at the workbench; saves migrate | M | PL |
| R-P1-03 | Logs → planks at the workbench; forest woodcutting as the main timber route | R-P1-02 | planks feed repairs; no grind spike in sim | M | PL |
| R-P1-04 | Food and cooking value (OD-5) | OD-5 | cooking chosen in sims and by the human tester | S | NV |
| R-P1-05 | Survival upkeep time by house stage (CCH-SURVIVAL-001) | R-P1-01 | upkeep falls with stage, measured | S | PL |
| R-P1-06 | Essential tool upgrade ladder reachable in Year One | R-P1-02, OD-1 | sim reaches each tier by its season | S | NV |

### P2 — World completion
| ID | Task | Depends | Acceptance | Effort | Status |
| --- | --- | --- | --- | --- | --- |
| R-P2-01 | Farmhouse four stages final; porch/storey per OD-2 | OD-2 | stages coherent, no storey on the critical path | M | PI |
| R-P2-02 | Wicker Cove batch 1: Edith's leak + first Living Memory reads (WC-002) | R-P1-03 (planks) or owner's material choice | repair persists; three residents/diary react | M | PL |
| R-P2-03 | Resident routines (farm folk + village) | R-P2-02 | each named resident has a day/evening place | L | PL |
| R-P2-04 | Forest exploration content per logging design | R-P1-03 | discoveries and timber worth the walk | M | PL |
| R-P2-05 | Harbour fishing | R-P2-02 | existing brackish fish only | S | PL |

### P3 — Narrative completion
| ID | Task | Depends | Acceptance | Effort | Status |
| --- | --- | --- | --- | --- | --- |
| R-P3-01 | Opening interlude, first playable slice: presentation scene + origin choice saved (`origin`) | OD-3 | non-skippable, plays before day 1, kb/controller, saved and migrated | M | PL |
| R-P3-02 | All five origins' interlude content | R-P3-01 | each branch complete per screenplay | L | PL |
| R-P3-03 | Origin consequences in Year One (diary pages, folk lines, the winter scenes) | R-P3-02, OD-1 | ≥3 visible consequences per origin | L | PL |
| R-P3-04 | Story pacing fitted to Year One (OD-1) | OD-1 | a human reaches an ending inside the 1.0 span | M | PL |
| R-P3-05 | Midyear decisions and resident arcs (scoped by OD-3) | OD-3, R-P2-03 | per scope | XL | PL |
| R-P3-06 | Narrative QA: every chapter and ending reachable on each origin | R-P3-03..05 | sim + scripted checks per origin | M | PL |

### P4 — Production art and audio (can run alongside P1-P3)
| ID | Task | Depends | Effort | Status |
| --- | --- | --- | --- | --- |
| R-P4-01 | Interlude presentation art (static scenes, PixelLab) | R-P3-01 | M | PL |
| R-P4-02 | Workbench, anvil, plank and log art | R-P1-02 | S | PL |
| R-P4-03 | Resident walk frames for routines | R-P2-03 | M | PL |
| R-P4-04 | Music and ambience to production (OD-6) | OD-6 | M + owner | PI |
| R-P4-05 | WC-VIS-01..03 village visual backlog | — | S | PL (low) |

### P5 — Beta and balancing
| ID | Task | Depends | Effort | Status |
| --- | --- | --- | --- | --- |
| R-P5-01 | Full-year sims per style and origin (labelled [sim]) | P1, P3 core | S per pass | PI |
| R-P5-02 | External playtest, 3-5 people, first 10 hours | R-P0-02, P3 core | owner-run | PL |
| R-P5-03 | Accessibility: remapping, text size, brightness, shake/flash toggles | — | M | PI |
| R-P5-04 | Trek clearing rebuild under one frame (or behind the fade) | — | S-M | NV (measured this session) |
| R-P5-05 | Bug triage to zero P0 / zero progression blockers | R-P5-02 | ongoing | — |

### P6 — Commercial readiness
| ID | Task | Depends | Effort | Status |
| --- | --- | --- | --- | --- |
| R-P6-01 | GodotSteam integration and Steam build depot | R-P0-02 | M | PI |
| R-P6-02 | Store page, capsule art, screenshots, trailer (`tools/trailer.ps1` exists) | P4 | M + owner | PL |
| R-P6-03 | Licence audit (fonts, PixelLab/SpriteCook terms, audio) and credits | — | S | PL |
| R-P6-04 | Public demo (first hour) | R-P3-01, R-P5-02 | M | PL |

### P7 — Launch and stabilisation
| ID | Task | Depends | Effort | Status |
| --- | --- | --- | --- | --- |
| R-P7-01 | Release candidate: feature freeze, full regression, fresh-install test | all gates | M | PL |
| R-P7-02 | Launch, crash/log intake (`TESTERS.md` route), hotfix branch | R-P7-01 | ongoing | PL |

## 6. Critical path

R-P0-02 build → R-P0-03 owner smoke test → **OD-1 / OD-3 decisions** → R-P3-01 → R-P3-02 → R-P3-03 → R-P3-04 →
R-P3-06 → R-P5-02 external playtest → R-P5-05 → R-P7-01.
Timber (R-P1-02 → R-P1-03 → R-P2-02) is a second chain that must land before the external playtest.
In parallel and off the critical path: P4 art and audio, R-P5-03 accessibility, R-P5-04 trek hitch, P6 store work.

## 7. Scope classes (directive §8)

- **REQUIRED FOR 1.0:** everything in section 2 marked required by the owner's non-negotiables: interlude + origins,
  timber and stations, four-stage farmhouse, Wicker Cove with memory and routines, a reachable ending, saves,
  controller, accessibility basics, Steam build.
- **DESIRABLE IF TIME PERMITS:** harbour fishing, inn guest room, village repairs beyond the first, second resident
  arc set, WC-VIS backlog, festivals.
- **POST-LAUNCH:** Year Two "Cost of Staying" design, maritime voyages, further Wicker Cove districts, decoration
  endgame.
- **NOT CURRENTLY PLANNED:** multiplayer, procedural maps, new story years, large combat trees, animated main menu.

## 8. Release quality gates

| Gate | How checked |
| --- | --- |
| No known crash or save corruption | auto (`save_test`) + human |
| No progression blocker; every mandatory chapter resolves | auto/sim per origin (R-P3-06) + human |
| Main story completable | sim + one full human playthrough |
| Inventory and progression persist | auto |
| Survival and story don't fight (no forced death in story beats) | sim + human |
| Visuals consistent and readable | owner + ChatGPT image review (human judgement) |
| Animations and audio complete | owner judgement |
| Keyboard and controller | auto (`menu_test`) + human |
| Performance on documented hardware | `perf_f` on the min-spec machine |
| Outside testers progress unaided | human only |
| Store and licence requirements | checklist (R-P6-03) |

A green suite is not a polished game: every gate above marked "human" needs a person.

## 9. Session log

| Date | Task | What happened | Commit |
| --- | --- | --- | --- |
| 2026-11-15 | CCH-RELEASE-001 | Audit, this board; R-P0-01 done; shader workaround verified; trek timing measured | see `MESSAGE_BOARD.md` |
