# CCH-CRAFT-STATIONS-001 — Workbench, Anvil, Logs and Planks

**Owner-approved design direction:** 2026-11-14.
**Status:** Owner-approved **crafting design rules**, *not* authorization to change gameplay code, recipes, art, save schema or economy without compatibility audit.

## Definitive player requirements
1. **Players must hew logs into planks at a workbench.** It should feel like actual timber working, not magically transforming raw trees directly into building materials.
2. **Every tool not made at an anvil must be made at a workbench.** Workbench is the home for non-anvil tools and hand crafting; the anvil is for forging appropriate metal tools and equipment.
3. Establish believable physical production locations; never add tedious busywork or make first-hour farming and the established story impossible.

## Existing code/documentation state checked 2026-11-14
- `DESIGN.md`: trees currently give **3 `wood`** and may yield hardwood with improved hatchet; crude/stone/copper/iron hatchets and stone/copper/iron picks plus willow/hardwood fishing rods are currently made through Craft/Tools UI. Early Lantern tiers are crafted in Craft/Other. Original first day includes making early equipment; Chapter 2 requires Tin Lantern; Chapter 3 needs a lantern for Maren's early escort.
- Current `DESIGN.md`: the existing **workshop** hosts smokehouse, furnace, a chopping log and firewood store. The chopping log converts **1 `wood` to 2 firewood**; firewood is needed for heat. Early building costs, house repairs, items and recipes currently consume `wood` throughout. **A separate explicit `log` and `plank` resource and a functional workbench/anvil are not documented as active production mechanics in this review.**
- Furnace currently smelts copper and iron ore to bars. Existing metal equipment/tools are selected through craft tabs and Smithing is a skill; additional anvil interaction must integrate, not duplicate, the furnace.
- Saves store existing inventory/resources and upgrades; old saves should not lose wood/materials. Existing balancing, chapter gating and input/controller workflows are sensitive to added station requirements.

## Resource/production chain (owner rule with proposed detailed mapping)

### Raw timber
**Tree → Logs → Workbench → Planks → Building/furniture.**
- Fell tree: produce raw logs as separate inventory resource if implementation audit approves migration. Current Forestry XP remains earned by the same logging activity; no new compulsory skill tree.
- Workbench: *Hew planks* from raw logs. Work interaction should have tactile tool action (hewing), short animation/sound and sensible batch option. No invisible auto-transformation in bag.
- Hardwood: determine separately whether it stays as hardwood and can be hewn into hardwood planks; **DO NOT** invent a second mandatory plank tier before audit.
- Non-structural use: maintain **firewood** as separate fuel from planks; route logs to firewood via existing chopping log, adapting conversion recipe carefully without breaking heat. Logs may also remain useful for posts, rough fences and other structures where plain planks aren't appropriate.
- Exact yield, animation speed, storage stack, market prices, harvested tree count, weight, blueprint materials and XP amounts **TBD after economy and UI audit**. No assumed 1:2 ratio or blanket replacement of every `wood` use.

### Tool manufacture by appropriate physical station
| Tool/recipe category | Station policy | Notes |
| --- | --- | --- |
| Crude wood/bone/fiber/stone tools | **Workbench** | Includes early hatchets/picks, rods, handles, and basic survival implements as applicable |
| Wooden or stone tool upgrades | **Workbench** | No direct inventory 'make' action |
| Metal tools (copper/iron) | **Anvil** | Forge after smelting at furnace; handles/other components can be prepared at workbench if this stays enjoyable rather than excessive |
| Metal weapons, armor, metal shields | **Anvil as appropriate** | Confirm precise exceptions/category design; shield construction may have woodwork+metalwork; avoid needless multi-step gating |
| Wooden shields, furniture, planks, hand-crafted non-metal implements | **Workbench** | As recipes evolve |
| Lanterns | **Workbench vs anvil to be resolved by actual bill of materials** | Do NOT block early Tin Lantern or day-4 Maren escort. A bench-assembled Tin Lantern is likely best for pacing. Metal later versions may use forged parts only if low friction |
| Cooking, preservation, smelting, split firewood | **Existing dedicated stations** | Hearth/cooking, smokehouse, furnace, chopping log remain authoritative and are NOT replaced by bench/anvil |

**UI concept:** Keep Craft panel as recipe catalog/preview but allow Make only at the correct station, or open a station-filtered version of same shared panel when interacting with physical station. Avoid duplicate workbench recipes in a second list and avoid blocking recipes without explaining where to craft them.

## First-hour progression / no-softlock requirement
- Bench must be usable **at the very start or with only easily gathered starting materials**. Strong candidate: a **weathered starter workbench** inside the original farmhouse or on its sheltered exterior, repairable later; **proposal, not canon**. Alternative: affordable bench build blueprint with immediate, no-tool-required materials, but must not require planks or a tool that itself requires the bench.
- Guarantee starter hoe/stone/crude hatchet options and first Tin Lantern can be made on time; preserve first-day guide and day-4 escort expectations.
- Anvil must be unlocked **after early stone tool progression** and with realistic existing copper/iron tier costs; don't require forged metal tools to obtain the first ore.
- Retain useful winter fuel without needing an expensive plank station or crafted late-game tools.
- Existing unlocked tools on old saves stay owned, never invalidated simply because their recipes move to a station.

## Major compatibility audit: how to migrate `wood`
**Do not do a global text replacement of wood->logs or wood->planks.** Audit item keys, harvest drops, building/estate costs, stew/furnace fuel, firewood splitting, lanterns, rods, fencing, crop/upkeep, trek obstacles, quest stats, old-save serializer, balance sim, icon/art and tests.

Options to decide based on code:
- **Compatible migration:** preserve `wood` as raw logs under the hood temporarily and introduce `planks` in new recipes, with player-facing display name 'Logs' and stable existing saved `wood` inventory keys. This might be easiest if the inventory layer permits labels; exact choice pending verification.
- **Versioned item conversion:** introduce `logs` key and migrate saved `wood` quantities at load, but revise every existing consumer and prevent duplication; higher risk.
Choose deliberately, not opportunistically, and compare resources in 30/90/365-day simulation.

## Crafting feel and usability
- Station in workshop/house should be a properly proportioned PixelLab sprite consistent with the game's top-down 3/4 perspective and the farmer's current scale; workshop art may need new floor layout. No floating multi-tool instant crafting.
- Bench hewing visual: log set across bench, axe/adze action, a few chips, finished boards; not a long minigame for every plank. Make a small amount per action, with batch processing unlocked or default once stable.
- Distinct sounds: rasp/scrape, wood strikes, iron on anvil; restrained and physical like current game audio.
- Display ingredient chain and where to find/perform it. Accessible via controller; if player chooses Craft away from station, explain 'Use the workbench'/'Requires anvil'.
- No 'craft in menu' bypass; no duplicate XP from hewing and collecting same product.
- Planks should be a meaningful processed good in the farm and in future **Wicker Cove** inn/store repair contracts; don't force every building plank cost to grow exponentially.

## Architecture / risks / testing
1. Audit specific code source and inventory keys for CraftSystem/ActionBar/PanelRows/FarmProjects/Estate/World resource drops/Forestry and Smithing plus construction costs. This document alone does not prove actual script implementation.
2. Write recipe/station classification matrix for **every existing tool** and first ~20 construction recipes; define explicit exceptions, if any, for dedicated cooking/smokehouse/furnace/chopping log stations.
3. Decide starter bench placement/build recipe and anvil unlock with first-hour tests. Progression test: first Day 1 guided tasks, Tin Lantern before Maren day4, first crop harvest, fuel and first repair.
4. Implement small vertical slice only after owner approval: one real bench interaction converting logs->planks, one crude tool recipe moved from generic Craft to bench, one correct failure/help explanation away from bench. Save/load and icon validation.
5. After slice: migrate construction/gear metal recipes and anvil; update controller UI and physical sprites.
6. Full tests: early unlocks, wood balance/structural costs, metal progression and ore acquisition, old save migration without resource duplication/loss, seasonal winter survivability, held equipment persisted, three endings unaffected.

## Tasks
- **CCH-CRAFT-STATIONS-001 — P1 Design/owner rule:** bench for hewing logs to planks; non-anvil tools require workbench, anvil for metal tools (recorded).
- **CCH-CRAFT-STATIONS-002 — P1 Audit:** current tool recipes, raw wood/consumers, workbench/anvil location and progression, save compatibility, UX.
- **CCH-WOOD-001 — P1 Design:** separate raw log, plank, hardwood and firewood uses; economy and migration strategy.
- **CCH-WORKBENCH-001 — P1 gated prototype candidate:** one physical workbench + logs->planks conversion, one non-anvil tool, first-hour no-softlock test.
- **CCH-ANVIL-001 — P2 gated candidate:** forge metal tools/gear at an anvil after furnace, phase by verified progression; use existing Smithing XP.
- **CCH-CRAFT-QA-001 — P1 QA:** all tool station classification, legacy save, 30-90-365 day economy, first-hour controls, day4 escort, lantern, frost fuel, 17 chapters and endings.
**No implementation authority yet.** Owner-set crafting destination rules are canon design requirements.

## 2026-11-14 — Owner requirement: logs should come from forest woodcutting

Owners report that current farm trees are difficult to locate. **Forest logging** (repeatable solo trips from farm to an intentional accessible cutting grove) should become the primary source of timber, with homestead grove trees retained as secondary/emergency sources. See [FOREST_LOGGING_EXPEDITIONS_DESIGN.md](FOREST_LOGGING_EXPEDITIONS_DESIGN.md). Integrated intended loop: **forest → harvest raw logs → carry home → hew planks at workbench → construction/Wicker Cove repair.** Early workbench and first hatchet must not depend on each other circularly. Shared CCH-WOOD-001 inventory migration, forest tree regrowth, XP/yields and farm/forest balance must be audited before code changes. **No implementation authorization.**
