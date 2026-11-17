# CCH-ORIGIN-001 — The Road to Crow Creek Hollow (implementation report)

**Status:** implemented, all five origins; **stopped for owner and ChatGPT review.** Automated and input-driven
tests only; **no human has played it.** Winter correspondence and later callbacks are not built (out of scope).

## What a new game does now

New Game → slot → name → **the road** (mandatory, no Skip) → the farm fades in on October 1, Day 1, 06:00, exactly as
before. Continue/Load of any existing farm save is unchanged and never shows the road.

| Step | Screenplay | Notes |
| --- | --- | --- |
| The notice | SCENE 00, C00 | the listing quoted on a paper slip; five reasons |
| The reason for leaving | 1A / 1B / 1C / 1D / 1E | one origin's scene only; C1A, C1B, C1C-1 + C1C-2, C1D, C1E |
| Someone who knows you | SCENE 20, C20, C21 | origin-tuned exchange; "no one" is its own scene |
| What comes along | SCENE 30, C30 | keepsake or nothing, a fact only |
| The road | SCENES 40-42, C41, C42 | origin echo at the fuel stop; sign; the gate's three origin statements |
| The door | END NARRATION + confirm | "Go in" locks the record; Back is available until then |

All 17,220 possible roads end at the door with every choice made (`interlude_test`).

**Length.** The longest road per origin is 456-494 words of narration plus its choices: about **4-5 minutes** at an
ordinary pace, under the 7-10 minute goal. Nothing was padded (the brief says not to); if the owner wants more, it
should come from the screenplay, not from filler.

## Editorial adaptations (screenplay → screen)

The words are the screenplay's. Where it gave a stage direction rather than prose, or two lines conflicted, this is
what was done; each is small and open to the owner's edit in `scripts/road_script.gd`.
1. **C20 asked before SCENE 20.** The screenplay narrates "Someone came by…" and then offers "No one is here". To keep
   both true, the choice comes first ("Before you left, did anyone come by?"), after one added context line ("By the
   last afternoon, only a few boxes were still open."). "No one" plays the screenplay's solitude scene and its
   single reply ("I'll make the arrangements myself."); the "You shut the last box" coda is skipped there, since the
   solitude scene already shuts the room.
2. **"Someone from a changed relationship"** is offered only on the household road, as written; elsewhere it isn't shown.
3. **C1A / C1B outcomes** (stage directions) became short prose: e.g. "You wrote a short note asking for more time…
   'Until the end of the month. No longer.'"; "Your supervisor accepted your notice, then asked who would take over."
4. **1C variant.** "If an identified person and continued contact were selected" can't be known yet at 1C (contact
   is chosen later), so the knock plays when neither household answer was "private"; otherwise the closed-box line.
5. **Work echo at the fuel stop.** "The last page of instructions…" plays only if instructions were written; the other
   two exits get "The folded farm notice was still in your coat pocket." (from 1B), so nothing claims a page that
   wasn't written.
6. **Keepsakes** got one short line each from the screenplay's descriptions; the notebook's ("It held names,
   measurements and a few things worth remembering") is the most composed. Per the production note, "You had more
   than you could carry… You carried it anyway" was cut to "You closed the case and lifted it from the floor."
7. Tense made consistent (past) in a few stage-direction lines.

No farmhouse inheritance, deed, Rook kinship, occupation, gender, romance or death is stated. The notice says
"Available for occupation and work. Terms through the town office." (screenplay wording, legal text still pending
owner approval per CCH-ROAD-LEGAL-001).

## Controls and accessibility

- Pages show whole at once (a 0.18 s fade any input overrides); no timers; no daylight lost.
- Continue: A / Space / Enter / click. Back: B / Backspace / the Back button, to the first page. Pause: Esc / Start
  (Resume, Quit to title, Quit game); B or Esc resumes. Focus always lands on Continue, the earlier answer, or the
  first option; the theme's gold focus ring shows it; earlier answers are gold with a bullet and a note.
- Footer prompts switch between keyboard and Xbox names with the last device.

## Saving

- `SAVE_VERSION` 17 → **18**. A farm save carries `origin`. Older saves migrate to `{"status": "legacy"}`: they load
  normally, never see the road, and get no invented past.
- While on the road, every page writes a small **interlude record** to the slot (`interlude: true`, `day: 1`, empty
  `inventory`, `save_name`, `origin` with `pos`), through the usual safe `write_save` (temp file, backup). Continue
  and Load resume it on the same page with the same answers. After the door the record is `complete`; until the
  farm's first save, loading that slot starts Day 1 fresh with the record. `_load_game` refuses to treat the record
  as a farm.
- **Behaviour change to note:** New Game in a used slot now replaces the old save when the road starts (the two-press
  overwrite already confirmed it); before, the old save survived until the first night's save. The old save
  becomes the slot's backup on the first write, and is gone after the second.
- Tools that call `MainGame._on_title_start("new", …)` directly (34 test/capture scripts) still start a farm without
  the road; such a farm's origin is `"none"`. Players can only reach the farm through `_on_title_choice`, which plays
  the road for every New Game.

## Origin-state keys (for future mail and diary)

Record (`origin` in the save, `OriginState.data`): `v` (1), `status` (`in_progress` | `complete` | `legacy` |
`none`), `choices` (key → option id, only the road taken), `order` (keys in the order chosen), `pos` (resume step,
in progress only), `day` (1, complete only). `OriginState.sanitize` replays the choices through the script and drops
anything off the road, so a damaged or hand-edited record can't hold a contradiction.

| Key | Options | Where |
| --- | --- | --- |
| `origin` | security, work, household, curiosity, chance | C00 (A-E) |
| `security_exit` | extension, forward, stored | C1A |
| `work_exit` | finish, instructions, boundary | C1B |
| `household_relation` | partner, friend, family, private | C1C-1 |
| `household_change` | separate, moved, ended, private | C1C-2 |
| `curiosity_interest` | growing, quiet, making, exploring | C1D |
| `chance_loose_end` | work_offer, storage, order, meeting | C1E |
| `contact` | friend, family, colleague_or_neighbor, former_household (household only), private, none | C20 |
| `contact_intent` | promise, uncertain, invite, boundaries; none (no contact) | C21 |
| `keepsake` | photo, tool, postcard, notebook, none | C30 |
| `road_pause` | look, drive | C41 |
| `arrival_intention` | security: fit_to_live, land_provide, one_day · work: own_terms, one_repair, not_today · household: new_routine, keep_some, see_how · curiosity: find_out, learn_land, no_idea · chance: work_next, worth_doing, what_i_have | C42 |

Read-only queries on `MainGame.origin` (all answer `""`/false for legacy or unfinished records): `known()`,
`status()`, `origin()`, `choice(key)`, `contact()`, `has_contact()`, `contact_intent()`, `keepsake()`,
`arrival_intention()`, `household_sender()` (relation, or `""` if private), and `thread()`, the winter thread each
origin opens: `forwarded_belongings` (A: W-A forwarded box, from `security_exit`), `old_workplace` (B: W-B),
`former_household` (C: W-C second key), `the_place` (D: W-D, needs `has_contact()`), `open_arrangement`
(E: W-E, from `chance_loose_end`). Rules for consumers: honour `contact_intent == "boundaries"`; never let a
resident of the Hollow speak of the player's past without an in-world source; write no diary entry the player
didn't earn.

## Tests

| Kind | What | Result |
| --- | --- | --- |
| Automated + input-driven | `tools/interlude_test.gd` (new, slot 9): script coverage (17,220 roads), record sanitizing, each origin walked end to end through the title entry point by keys (A, D), Xbox buttons (B, E) and mouse clicks (C); its own scene and no other; Back/re-choose; pause by Esc and Start; quit and Continue resume; arrival vs. a farm started the old way (pack, purse, meters, skills, tools, place, guide, first night, act, town); clock held; walking after; save/load of the record; v17 legacy save | **101 PASS, 0 FAIL** |
| Regression suite | `tools/audit_run_tests.sh` (22 suites + interlude_test) | **22 of 23 pass.** `aoh_trek_check` fails its 50 ms build-timing check (116 ms under parallel load); this is the pre-existing R-P5-04 failure, untouched by this change. `menu_test` 883 PASS, `save_test` 66 PASS. |
| Simulated progression | none run: no gameplay system changed, and a farm after the road is checked equal to a new game's | — |
| Human playtest | none | **not done** |

Untested: real controller hardware (input is injected), screen readers, other resolutions than 1280x720, the
window-close save path (`NOTIFICATION_WM_CLOSE_REQUEST`; each page already saves, so at worst the last page is lost).

## Files

New: `scripts/origin_state.gd`, `scripts/road_script.gd`, `scripts/road_interlude.gd`, `tools/interlude_test.gd`,
this report, `art/style_tests/CCH-ORIGIN-001/` (shots, review sheets, master).
Changed: `scripts/main.gd` (title router, interlude hand-off, `origin`), `scripts/save_system.gd` (v18, `origin`,
interlude record), `scripts/title_menu.gd` (slot line), `tools/capture.gd` (`road=`, `roadc=`, `roadpad`,
`roadpause`, `roadarrive`), `tools/audit_run_tests.sh` (adds interlude_test), `DESIGN.md`.

## Awaiting integration (not built)

Winter letters W-A…W-E, spring/summer decisions (SPRING_RETURN screenplay), the September diary passage, year-two
echoes, a diary page for the road, illustrated scenes (R-P4-01), the town notice's final legal wording, and a human
read for pacing and voice (CCH-ROAD-EDIT-001).
