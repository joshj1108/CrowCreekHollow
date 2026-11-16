# CCH-WICKER-COVE-002 — Dependency audit and the smallest playable next batch

**Status:** proposal, 2026-11-15, Claude Code. **Not approved.** No code was changed for this note.
**Context:** the owner accepted Wicker Cove alpha as the first playable village baseline (visual acceptance, provisional
82/100, `D-019`). Next focus: functional depth over polish, starting the Living Memory integration. The owner asked for a
dependency audit of four candidates and a recommendation of the smallest playable next batch, not all four at once.

Facts below are observed in the code at `62e873c` plus the owner's uncommitted tree; proposals are marked as such.

## What exists today (observed)

- `TownSystem.flags` stores the day of five first-time events (`arrived`, `traded`, `delivered`, `met_thomas`,
  `met_edith`). It is saved under `town` (save version 17) and **nothing reads it**. There is no event registry.
- There is **no written spec for the "Living Memory System"**. `DESIGN.md` names it once as the future reader of
  `flags`. The design docs set its rules: memory comes from verified outcomes only, never invented; the diary records
  facts, not a second source of truth (`BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md`, `HOUSE_MEMORY_AND_PLAYER_DIARY_ATLAS.md`);
  a callback must come through a reliable channel (mailbox or a fixed place), not a random visit
  (`FIRST_30_DAYS_LIVING_WORLD_VERTICAL_SLICE.md`).
- Residents: Thomas is fixed to his doorway tile (`"c"` in `TownLayout`), Edith to her counter (`"C"`, `"e"`).
  `TownSystem._interact` dispatches on the map character under the tile faced, not on a person's position.
- `TownSystem._line(who)` already picks lines by season, hour, `traded` and the order: the natural place to read memory.
- Fishing (`FishingSystem`) spawns spots only on `m.pond_edges` (farm tiles), draws them in the farm's `fish_layer`
  (hidden in the village, since `in_cave` is set there), and draws catches from the eight pond fish in `FISH`.
  The pier end is look-only (`TownData.LOOK["pier"]`).
- The inn's common room is the only interior. Edith mentions a leaking back room; there is no repair state, no back
  room on the map and no leak drawn.
- The diary's **Notes** section adds a page per farm moment, written in the player's hand, and saves which are new.
- Logging and the workbench (planks) are owner-approved directions, **not implemented**. Carpentry, wood, hardwood,
  stone and iron bars exist.

## The four candidates

| Candidate | Depends on | New save data | New art | Size | Risk |
| --- | --- | --- | --- | --- | --- |
| **A. Inn repair project** (persistent) | Materials decision (planks are not built), Carpentry, coins, a time cost, a visible before/after in the common room | `town.repairs` (additive, defaults empty) | none needed: a code-drawn ceiling stain, drip and bucket that go away; reuse interior art | small to medium | material choice could clash with the planned logging chain |
| **B. First memory-enabled interaction** | Something worth remembering; `flags`; `_line`; the diary's Notes | none beyond the event it reads | none | small | inventing memory if the event is thin; must stay facts-only |
| **C. Simple resident routines** | Interaction by person position, not map character; hour-based spots; collision; walking frames for Thomas and Edith (they have one pose); minimap; capture and menu tests | none (derived from the hour) | probably PixelLab walk frames, or they teleport between spots | medium | breaks today's fixed interaction tiles; readability in fog at night |
| **D. Harbour fishing** | Town-side spot list at the pier end, drawing the sparkle in the village layer, `_interact` casting on the pier, `FishingSystem` reading town spots while `TownSystem.active`, a harbour bite table | none if spots are not saved (pond spots are not) | none (reuse the sparkle) | small | economy if sturgeon gets easier; new saltwater species would mean new foods, icons, prices and recipes, so avoid them |

Notes on D: a new species list is the expensive part. The pond list already has three fish that fit a brackish
harbour (yellow perch tolerate brackish water; lamprey and white sturgeon run between sea and river), so a harbour
table can draw from those alone with the same level gates and stand prices, with no new items. The fish market
already buys them.

## Recommendation: one batch, A + B together ("Edith's leak")

B on its own has nothing worth remembering yet (`arrived` and `met_edith` are thin). A on its own is a chore with no
afterlife. Together they make the first complete memory loop on the village, using only existing systems:

1. **Look and quote.** Edith's counter gains a "The leak" entry once you have met her: the stain, drip and bucket in
   the common room, the exact cost shown against what you hold and your Carpentry, and her offer. Accept, or leave it;
   nothing fails, nothing is lost, the quote stands.
2. **Do the work.** Hand over the materials and spend a bounded block of the day at the inn (proposed: 2 hours), once,
   when you have what it needs. The stain, drip and bucket go; Edith pays once in coins. Carpentry XP as for a house step.
3. **The village remembers (Living Memory, first use).** `flags["inn_roof"]` holds the day. From then on:
   - Edith's daily word gains lines that know you fixed it (and, after a rainy day, that it held);
   - Thomas, who sold you nothing for it, has one line that he heard who did it (memory travelling between residents,
     the blueprint's "resident-to-resident" proof, in its smallest form);
   - one **Notes** page in the diary, in your hand, facts only: the day, what it took, what she paid.
4. **Nothing else changes.** No new recovery mechanic, no guest room, no friendship meter for town residents, no
   story-chapter gate, no change to the farm's 17 chapters or 3 endings, no fog lore.

Reader shape (proposal): `TownSystem` reads its own `flags`; no registry until a second consumer outside the village
needs one. An old save has no flag, so nobody remembers anything: memory is never invented.

**Why this is smallest:** zero new art, one additive save key, no movement or input changes, touches
`town_system.gd`, `town_data.gd`, the interior drawing, one diary Note, and the tests. It follows the order the
master roadmap already set (two residents, then one resident-to-resident memory).

**Next after it (separate task):** D, harbour fishing from the pier end with the perch/lamprey/sturgeon table: no new
items, self-contained, and gives a reason to stay in the village. Then C, routines, once the village has more than one
reason to move people around; it needs its own interaction rework and probably art.

## Decisions the owner needs to make before A + B is built

1. **Materials.** Planks need the logging/workbench chain, which is not built. Proposed: existing materials now
   (for example 10 wood, 4 hardwood, 2 iron bars for nails; Carpentry 2), swapped for planks when the workbench
   lands, with the saved flag unchanged. Or wait for planks.
2. **Payment.** Proposed: coins once (about 60, near a day's good stand takings), no lasting discount or bonus.
3. **Time cost.** Proposed: 2 hours of the day, done in one go at the inn.
4. **Unlock.** Proposed: open from the first word with Edith; no season gate (the design's Spring "Leak" act is a
   later dressing of the same state).
5. **Art.** Proposed: 0 generations; code-drawn stain, drip and bucket, reviewed with matching inn captures before and
   after (day and night).

## Tests that would come with it

`town_test.gd` cases for the quote, refusal without materials, the hand-over, the time spent, the payment once, the
flag saved and reloaded, an old save with no flag, the lines that read it, Thomas's line, and the diary page;
`menu_test.gd` for the new counter entry; `save_test.gd`; one `town_play.gd` run; `capture.gd` inn shots before and
after for the visual review.

## Visual backlog from the alpha review (low priority, not blockers)

Recorded as `WC-VIS-01` to `WC-VIS-03` in `TASKS.md`; not part of this batch.
