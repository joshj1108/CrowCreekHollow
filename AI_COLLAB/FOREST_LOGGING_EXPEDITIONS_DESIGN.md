# CCH-FOREST-LOGGING-001 — Repeatable Woodland Woodcutting

**Owner-requested design requirement (2026-11-14):** Trees are currently too difficult to locate on the homestead. Players should have an intentional way to venture into the surrounding forest to cut trees and gather timber, rather than relying on scattered farm trees.
**Status:** Approved player-experience direction, **design only** — do not change code, art, saves or quest/story routes without separately approved implementation slice.
**Dependencies:** `WORKBENCH_ANVIL_WOODWORKING_DESIGN.md`, `DESIGN.md`, `MASTER_ROADMAP_TO_1_0.md`, `CCH-TREK-002` solo woodland loop ideas.

## Source-verified current system
- `scripts/farm_layout.gd`: `GROVE_SPOTS` contains 12 fixed positions around the farm perimeter. Forest `T` blocks movement; `G` denotes harvestable grove tree. Decorative woodland surrounding the farm cannot be treated as 100% cuttable without reviewing map/physics.
- `DESIGN.md`: each grove tree gives 3 `wood` and 20 Forestry XP, plus limited hardwood chance at high tool tier. Felled trees regenerate each morning. Existing trees, great oak, orchard, cave/hillside, paths and landmarks have distinct roles; do not clear all vegetation or make the NW cave a generic open field.
- `scripts/trek_system.gd`: existing routes are escorted forest journeys with fixed landmarks, story beats, threat mechanics, lantern oil and walker nerve; route `edge` first on day4 with Maren; deep treks have a day/time economy. These must remain intact. Existing forest encounter `tree` sometimes offers some wood but is not deliberate repeatable timber production.
- `WORKBENCH_ANVIL_WOODWORKING_DESIGN.md`: owner rule logs must be hewn into planks at workbench; non-anvil tools made at workbench, metal at anvil. Current `wood` item is widely used, so log migration must be deliberate.
- `MASTER_ROADMAP_TO_1_0.md` already has optional `CCH-TREK-002` for compact solo forays and `CCH-QOL-001` for reducing felling grind. This new activity should connect to those, not create a second sprawling adventure system.

## Desired experience
The player can say 'I need timber today,' head for an easy-to-find woodland exit, reach a **small designated timber-cutting grove**, chop 2–5 trees, carry logs home and hew the required planks at their physical workbench. A familiar, satisfying round trip, within an afternoon of the current ~420-second real-time day. Forest should feel dense, beautiful and slightly unsettling while the purpose remains ordinary work.

**Location recommendation:** Create a marked **forest trail / timber access** from the homestead's outer woodland edge, ideally away from the existing east gate that leads toward Wicker Cove and is used for walkers. Exact placement must be chosen after collision/map art audit. Connect to existing **Rookery Wood** without disrupting the NW cave/hillside, the great tree, fields, pond or original escort routes. A short scene transition to a dedicated area is sufficient; do not build a seamless giant overworld.

### Proposed two-band structure
- **Nearwood Cutting Grove — core release slice:** accessible after acquiring the first viable hatchet, from the beginning/early week; short solo daytime trip, approximately 6–10 *clearly harvestable* trees and stumps, little or no combat, no scripted ghost every visit; ordinary seasonal weather, memorable scenery and natural regrowth. The first logging trip may include a short clear introduction to chopping, carrying and returning. No story-critical loot. Existing original Maren day4 edge trek remains separate and possible.
- **Deep Timber Stand — later P2 extension:** reached through a more difficult fork with better hardwood opportunities, greater prep/time risk and occasional familiar woodland signs/optional findings. Harder material gated by existing tool tiers and Forestry, not by quest morality. Reuse trek art/tiles/lighting and existing threats selectively; do not conflate with escorted treks or produce a mandatory horror minigame just to obtain basic construction material.

### Basic loop / visual UX
1. Home shows a visibly signposted forest access path (a woodpile, old forester's sign or path, no giant minimap scavenger hunt).
2. Player enters compact forest cutting area, sees which trunks can be felled (readable stump base/interaction affordance). Decorative backgrounds stay dense but are not deceptive; don't make every trunk scenery look identical to a harvest target.
3. Use normal hatchet tool/animation to chop. Receive logs (and existing Forestry XP); tier influences cut speed and high-level hardwood access, after balance audit.
4. Each felled tree leaves a persistent stump / visibly changed ground during regeneration. New growth takes *several in-game days*, not instant reload or each next morning; original farm trees may remain quicker emergency supply if kept.
5. Carry acquired logs to farm (inventory caps as audited); make planks at workbench. Optional later handcart/pack improvement can increase hauling convenience; don't make slow repetitive return trips required for every house repair.
6. On returning, resume ordinary farm life; preserve time-of-day, night effects, weather, hunger/thirst/comfort, save state and season.

## Resource and pacing design
- **Primary lumber supply** moves to forest. Keep 12 homestead grove trees in an intentionally useful but secondary role (early emergency supply and decor), perhaps regroup a few within reachable farm edge if layout review shows awkward placement. Existing tree positions need actual player-path testing.
- One easy, reasonable logging trip should provide enough raw logs for one meaningful early repair or an initial batch of planks **subject to actual cost audit**. Do not set arbitrary 1:2 yields without validating the full resource economy.
- Avoid imposing cumbersome log weight until tested. Consider an early backpack capacity or small carried stack, not multiple identical trips to repair a single cabin wall.
- Forest source must be renewable across a full multi-season playthrough, with regrowth timing and hardwood odds tuned against demand and `Forestry` XP.
- Raw logs → workbench planks → buildings/furniture/Wicker Cove structural commissions; firewood split via existing chopping log. Do not globally replace the existing `wood` key before save migration plan.
- A meaningful but limited selection of tree variety: fir and common timber near access; hardwood stand deeper. Avoid expensive new species/ecology/tree-growth simulations until core loop succeeds.
- Existing cave/hillside should remain visually ominous, and dense trees should preserve cozy enclosure instead of creating a cleared industrial logging yard.

## Interaction with story/horror
- Forest logging is NOT another required walker trek. Safe nearwood area should be viable solo in daylight with existing equipment, even if the main story progresses slowly.
- Existing walkers, Maren day4, mill/orchard/chapel route gating, daily visit calendar, Grove finale, lantern oil, field shadow/trek mechanics and original 17 chapters / three endings stay unchanged until separately audited/approved.
- Decide explicitly whether a completed **solo logging expedition** affects `trek_last_day`/wood-encroachment. Default recommendation: **no**. Otherwise timber grinding would accidentally become the most efficient way to keep the Hollow away, replacing meaningful escort treks. Returning from a logging trip should not silently count as a story trek.
- A small chance of quiet atmospheric detail or optional discovery is welcome, but no guaranteed supernatural ambush or endless scripted scenes; ordinary woodcutting is necessary for construction.
- The player should be able to ignore logging indefinitely if they choose another source (farm emergency trees, potential future trade), without soft-locking main story content.

## Technical audit before implementation
- Inspect actual tree harvesting code in `main.gd`, scene/tiles/collision, world map and `farm_layout.gd`, Forestry/tool tiers, `TrekSystem` path generation, `Cave` scene reuse, `World` transitions and save data; determine cheapest non-disruptive forest destination.
- Verify workstation and early tool access: no 'need forest logs to craft axe / need axe to get logs / need crafted planks to build bench' circular dependency.
- Determine exact tree regrowth and persistence keys for nearwood/deepwood, old-save defaults, scene unload/reload duplication prevention and XP/reward anti-farming.
- Audit wood economy for 14/90/365-day progression, home restoration, tool costs, furnace/firewood and optional Wicker Cove inn repairs. The player currently starts with scarce resources; preserve first-hour and first-winter survivability.
- Reuse production art styles and PixelLab proportions; do not overwrite original forest routes/cave sprites or zoom/perspective. Same top-down 3/4 camera.
- Test controller/tool range/interaction hints, return to homestead, morning/late-night timing, lighting, season/weather, logging tree collision and stump clearing. Logging areas must feel different from a copy of an escort grove.

## Phased tasks
- **CCH-FOREST-LOGGING-001 — P1 Design, owner direction:** make forest the primary intentional renewable timber location with optional solo trips, logged in this design.
- **CCH-FOREST-LOGGING-002 — P1 Audit:** inventory harvestable farm trees, verify route/scene and tool access, exact materials, save data, human navigation blockers.
- **CCH-FOREST-LOGGING-003 — P1 gated vertical slice:** one clearly signposted nearwood access and compact 6–10 tree cutting grove; actual harvest→return→bench→plank loop; test time and no-softlock.
- **CCH-FOREST-LOGGING-004 — P2 gated extension:** deeper hardwood stand, optional risk, possible handcart/transport relief, no mandatory combat/grind.
- **CCH-FOREST-LOGGING-QA-001 — P1 QA:** 3 player navigation routes, initial tool access, day4 Maren escort, timber availability, first winter fuel, 17 chapters, save/load and no Hollow pressure exploits.
- **CCH-WOOD-001 / CCH-WORKBENCH-001 — shared dependencies:** unify logs/planks/item migration, recipe costs and early bench across the two plans. Avoid two different implementations of resource types.

**No gameplay code changes are authorized by this design document.**
