# Crow Creek Hollow — Recovered Decisions, Open Questions and Claude Handoff
**2026-11-14 | Status:** Preservation and review brief. **No game modification authorized.**

## A. Decisions directly affirmed by the owner
- Prioritize a **finished, playable, coherent indie game**, not endless premium-art iteration, while keeping exceptional literary ambitions.
- The reason for arriving is as important as the reason for staying. Make the beginning a **mandatory, interactive and non-skippable** personal narrative, with pause/resume and meaningful origin consequences across years.
- **Five distinct origin arcs** as in `TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md`; no one default tragedy, fixed career, gender, romance, identity class or morality meter.
- Plain, human, literary writing; show the ordinary lived consequence of actions, not explanatory speeches about themes. No arbitrary 'right' choice.
- Physical workbench required to hew logs into planks. Non-anvil tools built at workbench; appropriate metal tools at anvil; cooking/smelting/smoking/firewood still use appropriate specialist facilities.
- Readable, repeatable **forest timber-gathering trips** as ordinary material sourcing; not frustrating searches for a handful of homestead trees.
- **Wicker Cove** as name for rundown downhill coastal fishing village with **permanent fog and contradictory histories**; no objective explanation settled.
- Keep homestead road and gate, market stand near mailbox, real NW cave/hillside terrain with cozy dread, tilled ground fields replacing raised boxes.
- Farmhouse is one recognizable base building across deterioration/recovery stages, with no new second-floor/porch structural upgrade design; interiors grow genuinely lived-in. Later exterior materials should be reconciled against most recent owner/art review before production.
- **Balanced darkness** and lantern upgrades extending radius, not brightness; static moonlit main menu, don't revisit menu animation unless asked.
- Rustic Gothic balanced UI: separated health/sanity vs Hunger/Thirst/Comfort, labels with no adjacent numbers, diary pages turning and distinguish Agnes's writing from player notes; mailbox—not red desk lamp—for mail.
- Lantern in hand by default at night, at hip when tool held; farmer rustic modern and full relevant animation including blocking, credible cave creatures.
- Preservation of original 17 chapters, four original walkers, three story endings, existing save/progression/camera behavior unless specifically approved.

## B. Authored but not owner-finalized
- First full opening screenplay and all five departure choices, five winter scenes, substantial spring replies; the actual prose, exact mail timing and character responses remain editorial drafts.
- Town residents Edith/Thomas/Gideon/Martha and their arcs; which are the first approved characters, physical appearances, inn/store interior choices.
- Inn room work and village repair economics; ships, coastal journeys and expanded maritime skills beyond the first satisfying village and homestead loop.
- Exact origin keepsakes, resources/fees, NPC trust effects, dynamic journal lines, story presentation details.
- Specific woodland entrance, first workbench position, plank conversion, forest tree yields/regrowth and all balancing.
- Real code rollout of any design documented November 14; no source commits from this recovery.

## C. Conflicts to resolve in future owner review (not immediate blockers to archive)
1. **Estate title:** inherited in early marketing pitch vs town-held occupation and optional deed purchase in current mechanics. No change to actual game until explicitly requested.
2. **Wicker Cove/Lowmere:** original postman correspondence, bell iron and ridge wording vs new permanent coastal fog; `WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md` Option A recommended but open.
3. **Exterior house:** older nonproduction log walls/wood shake roof approval vs later shake-siding preference; assess current screenshots and accepted stages before art patch.
4. **Narrative prologue:** earlier short/optional draft superseded by mandatory five-origin interlude. Length is provisional, all five arcs must have gameplay-relevant follow-ups.
5. **Existing vs proposed world:** designs for Wicker Cove, expanded relationships and nearwood aren't automatically implemented and must not be marketed as complete.

## D. Claude collaboration instruction for subsequent authorized implementation (not a task to execute now)
1. Fetch latest `main` (or the proposed docs PR after merge). Read `AI_COLLAB/RECOVERY_MASTER_ARCHIVE_2026-11-14.md` and linked full files, `DESIGN.md`, `CLAUDE.md`, `AI_COLLAB/DECISIONS.md`, `TASKS.md`, and task-specific live scripts. Never implement directly from a summary.
2. Report what already works in code separately from what is documented only. Verify actual scripts and tests; don't call a spec 'shipped.'
3. Propose small source-safe implementation slices with dependency order. Preferred candidate **after approval**: first 30-day use case (tool workbench and nearwood timber access without recipe deadlock); one Maren choice→saved later consequence→truthful diary. Preserve Chapter 2 lantern and Day 4 trek.
4. For mandatory prologue, first audit new-game, game clock, readable interaction, save/load/legacy slots, mail/diary/dialogue hooks, then offer staged implementation. Player should not lose first-day time to the interlude. No Skip, but support accessibility and pause/resume.
5. Never modify original narrative chapter progression, `maren_book`/`vicar_register`, `post_hand`, Davy night or three endings from a design-only brief.
6. Before visual review, provide before/after screenshots per `VISUAL_REVIEW_PROTOCOL.md`. Before production migrations test old saves and actual controller/keyboard flows; do not touch user slots 1–3.
7. Communicate implementation evidence, changed files, screenshots and blockers on `AI_COLLAB/MESSAGE_BOARD.md` only when a specific owner-authorized task requests it. Owner gives final approval.

## E. Next preservation action after this archive
- Review and reconcile the existing [LIVING_WORLD_DESIGN_HANDOFF_INDEX.md](LIVING_WORLD_DESIGN_HANDOFF_INDEX.md), which already exhaustively catalogs November's writing.
- Keep the two full screenplay files intact; later line edit chapter by chapter rather than replacing from recollection.
- Establish a versioned literary acceptance matrix for all five origins, autumn/winter/spring/September/year two; pair choices with verified save flags, playable outcomes and possible dialogue without inventing player feelings.
- Maintain a living distinction between **owner-approved target**, **fully written editorial draft**, **source-verified current behavior**, **proposed future expansion**, and **implemented/tested**.
