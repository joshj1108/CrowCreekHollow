# FARM-001 — The concept farm becomes the real game: report for review

Claude Code → ChatGPT, Owner. 2026-11-06. This report covers all of FARM-001, from the owner's request to the last decisions. Read it with the plan (`AI_COLLAB/FARM_001_CONCEPT_MIGRATION_PLAN.md`) and the FARM-001 entries in `AI_COLLAB/MESSAGE_BOARD.md`.

## What was asked

The owner liked the playable concept farm (`tools/concept_farm.gd`, commit `2d64f9b`): the W-4 layout b, the F2 fields, the VS16-P1 cabin, a mossy NW hillside with a cave mouth, and the farm stand by the mailbox at the east gate. They asked for it to replace the production farm, with everything working on it:
- the fields, orchard, well and watering;
- fishing at the pond and dock, and forage;
- the farmhouse door and porch, and the stand (Trade, 06:00-18:00);
- the cave into the real mining cave;
- the east gate as the way out to treks;
- collision, camera, the R3-1 night, and saving.

Old saves were not to be migrated; the owner wiped them. No paid generation was allowed.

## Owner decisions

| | Decision |
|---|---|
| A. Fields | One field per unlock: NW from the start (Farming 1), NE at Farming 2, SW at Farming 5, SE at Farming 9 with the house Patched. The crop yield could be raised if the economy needed it. |
| B. Orchard | The six old trees drop windfalls in autumn (apples, and a new Pear forage food). Davy's sapling reward and the apple-tree decor are unchanged. |
| C. Grove trees | Twelve forest-edge trees facing the clearing can be felled, and regrow as before. |
| D. House | The P1 cabin shows at every repair stage. Art for each stage is a later task. |
| Follow-up | The fourth field keeps the Patched condition. The homestead ladder keeps one step for it ("Open the fourth field", the old third-plot step), with no step for the third field, so it is back to 14 steps. Only the owner's BEFORE captures were skipped; the review package is AFTER only. |

## What was built (all on `main`)

| Commit | Stage |
|---|---|
| `efd4b4a` | **Layout and logic.** `tools/concept_export.gd` dumped the concept's grid and every tile a prop blocks (`tools/concept_layout.json`). `tools/concept_grid.py` translated it once into `tools/farm_grid.txt` with a new legend. `tools/hand_layout.py` was rewritten for the new anchors and writes `scripts/farm_layout.gd` (layout `VERSION` 18496244). The game reads the new map: four 7×4 fields; the well, porch, door, oak and cellar in their concept places; the cave mouth at (11,8); the stand at (54-56, 31-32). The dock is walkable and can be fished from. There are autumn windfalls in the orchard. Walkers wait on the road inside the closed east gate, and treks and falls return there. Their dialogue and quest texts say "east gate" instead of "north gate". The pedlar stands beside the stand. A new `tools/layout_test.gd` was added. |
| `ec8dc4e` | **Art.** The concept build was exported at 12:00 and 21:00 into `art/farm/concept/`: 30 ground chunks, each in a day and a night version, and 1,743 standing sprites with day and night tints, 2 MB with no new generation. The new `scripts/farm_scenery.gd` draws them in the game behind `CONCEPT_ART` in `main.gd`; switching it off falls back to the old art. Pieces sort against the farmer by their base, the ground fades to its night version as darkness falls, felled grove trees hide, and the house lights sit on the cabin. `main.gd` still draws what changes in play: the F2 fields (tilled when open, darker while fallow) with live crops, brush, rocks, stumps, buildings, decor, forage and fish spots. The R3-1 night tint and grade, which had existed only in the harness, and the concept's midday warmth now run in the game, on the farm only. The game's darkness, lamps and sanity are unchanged. |
| `97f5a3f` | **Docs.** `DESIGN.md` updates: "Farm layout" is rewritten, and "The mining cave", "Money and the farm stand", "Forage", the map, skills, well, forestry, fields, the walker spot and the code layout are revised. `spritecook-assets.json` gains a note for `art/farm/concept/`. |
| `868c836` | The review package links posted on the board. |
| `424a66c` | One homestead step for the fourth field, none for the third. |

## Checks

- **`tools/layout_test.gd`** (new, headless, slot 9): 0 failures.
  - Every place can be reached on foot from the porch: all four fields, the well, the stand's front, the cave approach, the whole dock, every walker spot, home from a trek, the pedlar, every grove and orchard tree, and every brush and rock spot. Nothing past the closed gate can be reached.
  - Walking with the move keys works from the porch to a field, the road, the stand, the dock and the cave approach.
  - Each place works: the stand opens Trade at 10:00, the well opens its panel, the cave and house go in and come back out, and planting and watering work. The fields open at Farming 2, 5 and 9 (the fourth waits for Patched). A cast from the dock, a walker at the gate, coming home from a trek, an autumn windfall and chopping all work.
- **`tools/save_test.gd`** and **`tools/menu_test.gd`**: 0 failures after each stage.
- **`tools/balance_sim.gd`** (400 days, treks=3, on the layout and logic stage):

| Run | Crop coins over 400 days |
|---|---|
| Old farm, engaged | 6,806 |
| New farm, engaged | 8,717 |
| New farm, ignore | 9,184 |
| New farm, earlybed | 9,362 |

  The fields are smaller (112 tiles against 267), but income doesn't drop, because watering capacity limits it in the sim, not field area. **No yield change was made.** One single-run difference: in the engaged run on the new farm, the orchard story beat came on day 397 and Davy's didn't come, against days 267 and 370 on the old farm. The sim walked fewer orchard treks (19 against 31). It looks like trek-choice variance, but it wasn't re-run to confirm.

## Visual review package (AFTER only)

`art/style_tests/FARM-001/review/FARM-001_master.png` (commit `ec8dc4e`) shows:
- the porch at 11:05, 19:30 dusk and 21:30 night;
- the NW cave, the stand by the gate, and the fields with crops by day;
- the fields in rain.

The owner attaches the PNG, because the GitHub connector can't decode images. No ChatGPT review is recorded yet.

**Questions for the review:**
1. Does production match the reviewed concept? Look at the hillside and cave, the stand by the gate, and the cabin and oak area.
2. Do the open fields (tilled, with the game's crop sprites) and the fallow fields (darker, grown over) read right next to the concept's F2 look?
3. Does the R3-1 night still read as approved now that it runs in the game, and does dusk blend into it cleanly?
4. Does rain over the new ground look right?

## Known gaps and open items

- The well always looks repaired, and the cabin doesn't change with repair stages (decision D). Stage art is a later task.
- The props that block (`Z`) come from the concept's collision. A few tiles of grass behind the hill's top edge can still be walked on, as in the concept.
- **Old saves:** they were moved, not deleted, at the owner's request: slots 2 and 3 with their backups, and the two pre-rename saves the game would copy back. They are in `old_saves_2026-11-06/` in the game's data folder. Slot 1 is a new-farm save and was kept.
- **Tooling note:** a stale, git-ignored `builds/wip_backup/main_head.gd` also declares `class_name MainGame`, and Godot picked it up once. A local `.gdignore` in that folder fixed it.
