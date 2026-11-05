# ART-003 W-3 Batch C: orchard, crossroads, arrival and paths

Status: for the owner's and ChatGPT's review. **Non-production.** Approved by the owner on 2026-11-03 (D-011), after ChatGPT's wall image review (`cad881d`); house wall A (D-010).

- **Not changed:** production art, `main.gd`, gameplay, saves, the live farm layout, the prototype blueprint, collision rules for existing tiles, camera, scale, lights, `DESIGN.md`. No P-1, no house stages 0–2.
- **PixelLab:** **4 generations of the 5-generation limit** (3 expected). Balance 4,964 → 4,960. All `create_image_pixflux` with the concept palette; no Pro Flash, inpainting or USD credit. IDs in `pixellab-assets.json`.
- **Renders:** BEFORE is a `git archive` export of `4e864e7` (`art=w3p grass=1 wall=a`); AFTER is the same export plus the edited `tools/art003_wide.gd` and `w3c/` (`art=w3c grass=1`). Neither has the VIS-002 work. 1280×720, 12:00 and 21:30 (R3-1), sunny, autumn, sanity 100.

## What was made
**Generated (4):**
| Asset | Result | Use |
| --- | --- | --- |
| Apple tree 48×64 | Good crown, but no visible fruit, an orange trunk and a ground disc: it read as another maple | **Hand-fixed, no retry spent** (`orchard/fix_apple.py`): disc removed, trunk browned, 11 apples set in with a dark rim and a highlight, palette colours only |
| Pear tree 48×64 | Reads as a fruit tree; small pears in a yellow-green crown | As generated |
| Prop strip 128×48 | Signpost, handcart of sacks, compost bin, barrel of apples, and an unasked covered cart. **No mailbox** | Sliced into `props/`; the covered cart is unused |
| Mailbox 32×32 | The strip's one retry, for the mailbox only | `props/mailbox.png` |

**Reused (0 generations):** `chopping_log`, `woodstore`, `prop_stump` and `tree_dead_0` (production SpriteCook), the R3 boulders and ground cover, the W-3 shore strip, the R3 barrel.

## Placement (`art=w3c`, on top of `art=w3p`)
- **Orchard:** apple and pear in a checkerboard on the six orchard tiles, in place of the maples; a barrel of apples beside one tree.
- **V3 crossroads, three groups with open grass between:**
  - a woodcutting corner between the well and the oak (chopping block, woodstore, stump);
  - a signpost and three boulders between the fork's south-west and south branches;
  - a handcart of sacks where the well path meets the south branch.
- **Arrival (the road's east end):** a mailbox and a dead tree north of the road, and boulders at its south verge. Wheel ruts run along the road's long east–west stretch: two faint lines, darkened in place.
- **Paths:** grass tufts creep a few pixels onto about a third of the path tiles that border grass, so the edges stop reading as even bands.
- **Garden → pond:** a rain barrel and the compost at the garden's south-west corner; rushes and cattails on the strip between the pond's east bank and the dock path.
- **Collision:** every new prop blocks its tile(s) through `c_block` (`_blocked`); the fruit trees stay on the existing blocking orchard tiles. Reeds and rushes are walkable, like the existing shore props. No tile code or blueprint changed.

## Walk
- Porch (V5) → well → oak → garden west gate and cross walk → south gate → road → dock, day and night: **"route legs skipped: []" both times**, 759 frames at 30 fps (the same length as the polish walk).
- A first attempt started from V1 instead of the porch (my error, not the earlier setup). It skipped legs, starting with the porch, which the house dressing blocks. It was re-run from V5 as before.

## Performance (median frame ms / draw calls / objects; lights on: 0 by day, 6 at night, unchanged)
| View | Day before | Day after | Night before | Night after |
| --- | --- | --- | --- | --- |
| V3 | 2.72 / 722 / 1455 | 2.95 / 730 / 1463 | 3.28 / 726 / 1455 | 3.11 / 734 / 1463 |
| V4 | 2.70 / 704 / 1495 | 3.48 / 713 / 1501 | 3.00 / 706 / 1497 | 3.36 / 715 / 1503 |
| Orchard close | 2.69 / 742 / 1481 | 2.79 / 746 / 1482 | 2.72 / 746 / 1483 | 3.05 / 748 / 1484 |
| Arrival | 3.08 / 739 / 1391 | 2.80 / 744 / 1396 | 2.96 / 746 / 1393 | 2.92 / 751 / 1398 |
| V1-B (spot check) | 4.28 / 732 / 1514 | 3.03 / 738 / 1529 | 3.38 / 734 / 1505 | 2.89 / 743 / 1526 |
| V2 (spot check) | 3.04 / 829 / 1509 | 3.13 / 829 / 1498 | 3.18 / 844 / 1501 | 2.96 / 849 / 1505 |

- **Draw calls:** +0 to +9 per view, within the +30 budget.
- **Frame times:** they move both ways by run-to-run noise. Every view stays under 3.5 ms median.
- **Spot check (V1-B, V2):** whole-frame luma moves by 0.002 at most. The tufts and ruts are the only change there.

## Reading (Claude's, not a review)
- **The orchard now reads as fruit trees,** not forest. The apples read at 100%, less so at 50%. The fruit trees are smaller and more open than the maples were, so the orchard looks thinner and more cultivated than before. Whether that's better is a judgement for the review.
- **V3 has three focal points instead of one,** and the open grass is kept between them. The handcart and signpost are small at 50%.
- **The woodstore** is the production SpriteCook sprite, and beside the PixelLab props it reads like a tall cabinet. It's the weakest reuse; the porch firewood art would be a zero-cost swap.
- **The arrival:** the mailbox and dead tree give the road's end a threshold. The road still runs into the east forest with no visible way out; making one would mean thinning forest tiles, which is a layout change and wasn't done.
- **Night:** the new props sit under the unchanged R3-1 night. The apple tree under the farmer's lantern lights up warmly, as any sprite there does.
- **The ruts are faint** by design. They show at 100% and almost vanish at 50%.

## Review package (`review/`)
- `ART-003WC_master.png` (72%): `batchc_views_a.png` (V3, V4) and `batchc_views_b.png` (orchard close, arrival), BEFORE | AFTER, day and R3-1 night, at 50%.
- `ART-003WC_master_2.png` (72%): `batchc_closeups.png` (sprites at 4×, raw and fixed; the new groups in game at 100%) and `batchc_spotcheck.png` (V1-B, V2).
- `ART-003WC_master_3.png` (63%): `walk_day_frames.png`, `walk_night_frames.png` (12 frames each). `walk_day.gif` and `walk_night.gif` are 60% centre crops at half size, 6 fps.
- `make_closeups.py` builds the close-up sheet; the BEFORE/AFTER sheets come from `tools/review_sheet.ps1`.

## Checks
- **VIS-002:** the working-tree diff, leaving out `tools/art003_wide.gd`, `art/style_tests/ART-003` and `AI_COLLAB`, still hashes `f52e5ae0…`. `stash@{0}` is present.
- **Saves:** slots 1–3 in the game's save folder (`app_userdata/Crow Creek Hollow`) match `builds/wip_backup/saves_after_wb.txt`. Only test slot 8 was written.

## Open for the owner
- **Batch C as a prototype direction:** the fruit trees, the V3 groups, the arrival and the path dressing.
- **The woodstore:** swap it for the porch firewood, or keep it.
- **One unspent generation:** it stays unspent unless the owner asks for it.
- **Production:** nothing here goes to production without the C-12 pipeline decision. The fruit trees would also need seasonal states.
