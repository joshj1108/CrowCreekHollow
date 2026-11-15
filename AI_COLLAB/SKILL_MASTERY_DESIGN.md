# CCH-SKILLS-001 — Skill Mastery and Interconnected Progression Design
**Draft:** 2026-11-14. **Status:** DESIGN, not implementation authorization.
**Basis inspected:** `DESIGN.md` (§ Skills, Farming, Fishing, Cooking, Forestry/wood, cave, house/estate, survival) and `scripts/progression_system.gd`. Reconcile all recipe/unlock data directly from source before implementing; code and current saves supersede concepts.

## Vision
Classic RuneScape-style **mastery through meaningful practice**, not level-99 imitation or aimless grinding. Homestead, survival, Wicker Cove economy and Hollow mysteries share connected uses for skills. **Preserve existing ten skills, their saved XP keys and level-cap 10 for 1.0; expand milestone utility before proposing caps or extra skills.** Wicker Cove's failing fisheries, trade and renovation are natural uses.

## Existing mechanics actually verified
- `ProgressionSystem.LEVEL_CAP=10`, `STEEP_FROM=5`, `STEEP_GROWTH=1.8`. XP thresholds 2=100, 3=300, 4=600, 5=1000, 6=1720, 7=3016, 8=5349, 9=9548, 10=17106. `_grant_xp` passes through existing Hale XP effects.
- Ten existing skills named in DESIGN: **Farming, Bushcrafting, Carpentry, Cleaning, Cooking, Fishing, Forestry, Mining, Smithing, Combat**. No verified existing Construction or Trading skill; do not add them by assumption.
- Farming: seed planting, crop harvest XP, fields at 2/5/9 plus house-stage gate; crops require seasons and levels. Fishing: level/season/hour-dependent pond species, better rods. Carpentry: house stages, repairs, wooden gear, structures. Cooking: level-based recipes, preservation, trek foods. Forestry: wood processing. Mining/Smithing: copper, iron, tools, sprinkler improvements. Bushcrafting: forage/lanterns/trek preparation. Cleaning: daily tidy and cleanse. Combat: cave/trek creatures.
- Existing `DESIGN.md` has a daily house job rotating crops, fish, wood, stone, resin, forage, cooked food, preserves, rewarding coins and job-skill XP. **New Wicker Cove orders should reuse or integrate with this, not introduce a redundant parallel XP faucet.**
- Existing nightly/survival progression and StoryAct endings must remain attainable; user wants relaxed farmer/explorer/cautious survivor to all have routes.

## Design rules
1. Every skill should have a useful unlock, technique, service, economic opportunity, or notable project around levels 2, 4, 6, 8, and 10; do not add filler unlocks every level if useless.
2. Major upgrade should grant visible change, practical function, and occasional narrative acknowledgment. Keep existing unlock levels and XP keys by default.
3. Prefer one primary skill and at most one secondary prerequisite for cross-skill activities. Optional alternate methods make builds inclusive.
4. Wicker Cove repair contracts use **Carpentry** (or existing Forestry/Smithing for materials), not a new Construction skill for v1. Town deliveries reward **relevant production-skill XP**, bounded coins and owner trust; no Trading skill by default.
5. **No mandatory XP grinding to access the three existing story endings or the first town visit.** Skills add efficiency, options and prestige rather than hard-blocking story. Don't make staying home or cooking inferior to facing every visitor.
6. Avoid XP for endlessly buying/reselling, placing/removing furniture, starting/canceling orders, or repeating no-resource crafts. Grant meaningful XP once per real production/delivery/repair action; scale and cap as appropriate.
7. High tiers should favor prestigious optional projects; do not require 10 in every skill for ending or town utility. Level 10 XP 17,106 is currently expensive and needs measured action/time checks.
8. XP rewards from **Hale** and existing chapter/jobs require explicit economy simulation; never silently alter XP threshold equations.

## Proposed mastery identity for each existing skill
| Skill | Existing foundation | Candidate mastery extension (not code) |
| --- | --- | --- |
| Farming | Seeds, seasons, field unlocks, crops | Specialty orders, efficient production, higher-tier ingredients |
| Bushcrafting | Lanterns, forage, wilderness and treks | Survival supplies, specialized woodland finds and wayfinding hints |
| Carpentry | Home restoration, maintenance, wooden gear | Inn/store repair contracts; furniture construction; visible village reconstruction |
| Cleaning | Tidy, cleanse, comfort | Faster or better household upkeep, valuable inn-room turnaround activities (avoid tedious daily cleaning chores) |
| Cooking | Recipes, stored/preserved food, trek provisions | Inn catering, travel meals, specialized customer recipes and preservation |
| Fishing | Freshwater species, rods | Coastal fishing opportunities in Wicker Cove, orders and bait/gear progression (audit mechanics before adding) |
| Forestry | Wood cutting, splitting firewood | More effective resource processing, reliable construction lumber and stock for merchants |
| Mining | Cave ore | Specialized fixtures/material tiers for construction without making mining compulsory for all house content |
| Smithing | Ore-to-bars, tools, sprinklers | Business hardware, hooks, lamp fittings, equipment and workshop efficiencies |
| Combat | Existing fighting/defense | Distinct defensive/gear options for adventurous players, not required to trade or decorate |

## Proposed progression bands (do not overwrite existing numeric unlocks)
- **1–2 Foundation:** reliable staple activities, early house/tools and first modest work orders.
- **3–4 Expansion:** varied crops/fish/recipes/tools, specialized low-risk contracts.
- **5–6 Specialist:** intermediate preservation, higher value trade and selected business repairs.
- **7–8 Expert:** efficient methods, important upgrades, multi-resource construction.
- **9–10 Master:** prestigious optional commissions, distinctive craft/decoration, community acknowledgment. NOT a prerequisite for main endings or visiting town.

## Production loops and practical prototypes
- **Farming → Cooking → Wicker Cove Orders:** turnips / seasonal crops → simple meals or preserves → small general-store or inn request. Reward coins, relevant production XP, potential relationship progress; no overlapping free XP from same goods without cost comparison.
- **Forestry → Carpentry (+ Smithing as optional supporting skill) → Inn repair:** gather wood/hardwood → repair a damaged inn room or roof → visible fix and new guest space. Keep labor/time and materials proportional; owner may contribute.
- **Fishing → Cooking → Town fish/inn demand:** fresh or preserved fish supports coastal trade and inn meals. Farm pond species and sea species distinguished, but sea fish and salt aren't assumed implemented yet.
- **Bushcrafting + Cooking → Treks:** prepare oil/rations/forage and use skills to reduce difficulty; do not obsolete walkers or story.

## Acceptance audit & simulation requirements for future Claude task (NOT YET AUTHORIZED)
- Print ten skill identities, exact training action XP, threshold, cap, current unlocks, how saved `skill_xp` is keyed.
- Compare all 10 skills across 14, 60, 180 and 400 simulated days, play styles (farmer, cautious, explorer, balanced), seasons. Show no-activity/overgrind skills and when level 2/4/6/8/10 becomes realistically achievable.
- Trace first-30-day recipes/fields/equipment and costs, market jobs, future home orders. Identify circular locks, impossible recipes, redundant requirements.
- Compare costs/time/XP from farming, cooking, contracts and construction to baseline. No infinite XP/coin loops from orders or room placement.
- Test older saves preserve XP levels and story, daytime activity and UI and level notification behavior.

## Thin implementation plan to approve LATER
**CCH-SKILLS-001A:** current XP/unlocks audit (no code changes) → owner selects 2–3 missing milestone opportunities.
**CCH-SKILLS-001B:** implement one vertical slice, likely Farming/Cooking/Wicker Cove order synergy once CCH-FOOD-001/CCH-ORDERS-001 foundations exist.
**CCH-SKILLS-001C:** Carpentry and inn repair mastery once first Wicker Cove district is viable.
**CCH-SKILLS-001D:** optional Forestry/Fishing/Smithing breadth and winter synergies after validation.
Do not approve 001B/C/D from this design alone.

## Open choices
- Exact skill unlocks are source/audit dependent; no unverified table of rewards should be treated as game data.
- Should the town offer one-time master commissions, repeatable elite contracts or both?
- Should Cooking be rewarded primarily with provisions, profit, Comfort, or evenly? Coordinate CCH-FOOD-001.
- How much of Wicker Cove renovation should be achievable by a farmer who never enters the mine? Provide viable but slower trade alternatives.


## Owner-requested roster reassessment — 2026-11-14

The earlier recommendation to preserve all ten skills is **now a safety constraint for existing saves/code pending audit, not a final design decision**. Owner wants redundant/low-value skills considered for removal or consolidation and more enjoyable skills considered for addition. Candidate Cleaning standalone retirement and Forestry merge, with distinct Cooking/Fishing/Carpentry/Bushcrafting retained. Future Seamanship is conditional on engaging NPC-fisherman voyage gameplay. See [SKILL_ROSTER_AND_MARITIME_DESIGN.md](SKILL_ROSTER_AND_MARITIME_DESIGN.md). No implementation authorized.
