# CCH-CHOICE-PATHS-001 — Player-Authored Lives, Consequence Weaving and Choice Architecture

**Creative planning date:** 2026-11-14. **Status:** DESIGN ONLY; no change to code, lore, story branches, assets or saving authorized.
**Owner-established direction:** choose-your-own-adventure feeling throughout; no objectively right/wrong playstyle; decisions matter over time; optional behind-the-scenes D&D-inspired rolls for interesting uncertainty.
**Read with:** `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `CREATIVE_BLUEPRINT_START_TO_FINISH.md`, `MASTER_ROADMAP_TO_1_0.md`, `DESIGN.md`, existing StoryAct and FolkSystem. All scene names, relationships involving proposed Wicker Cove cast, options and reward specifics below are concepts, not established in-game canon.

## First principles
1. **Identity comes from accumulated behavior, not selecting a 'class' at character creation.** The farm and neighborhood recognize what the player repeatedly does. No global morality, lawfulness or alignment meter.
2. **Choice changes context, not the absolute right to progress.** Consequences can be costly, risky, pleasant or unpleasant but must have believable recovery or alternatives. Player still owns decisions and resource tradeoffs.
3. **Players don't need to touch every system.** A farmer-only, builder, friend-focused or risk-taking explorer should each feel respected. Core Hollow story needs original established gates; optional Wicker Cove restoration, inn or maritime pursuits don't become required endings.
4. **A major choice gets a callback.** A dialogue line on selection is insufficient. Aim for immediate feedback + remembered response + one future meaningful opportunity or cost.
5. **Use hidden RNG sparingly** to vary plausible outcomes of uncertain work, not whether the player intended to help, which moral side they are on, or crucial plot canon. Record one-off roll outcomes so reloads can't fish for success.
6. **Don't manufacture punishment through silence.** The player understands broad stakes through dialogue, skill/tool readiness or clue context. Avoid invisible choices that unexpectedly kill relationships or block the chapter spine.
7. **Let the town live without the player.** A declined request may lead to someone else's imperfect repair, a delayed shipment or an unchanged service, not a frozen NPC waiting 400 days.
8. **Replay value from meaningful combinations**, not hundreds of expensive mutually exclusive main quests.

## How a playthrough is remembered (proposed state model, not approved schema)
**A. Relationships:** existing FolkSystem points/hearts, scenes and request flags are the baseline. New NPCs should use/extend it, with separate stable 'promise/choice' flags when needed. Two characters may interpret one action differently without imposing global 'reputation'.
**B. Physical/economic state:** existing farm house/stand, future town projects and practical stock/use; save each upgrade once and persist resulting services.
**C. Narrative history:** authored choice/outcome IDs and context notes in diary, plus real clues learned. Distinguish what the player **believes** from what the game proves; especially Wicker Cove's fog chronology.
**D. Hidden resolution:** seeded or persisted per-event random result and inputs to avoid save/reload manipulation; never roll on dialogue panel reopening. Developer-only logs for branch tests.
**E. Never expose universal numeric morality labels.** A brief diary recap can note 'I chose to keep the grain' without declaring the player selfish.

## Example player expressions — same world, different lives
| Player approach | Typical choices | Reliable strengths | Tradeoffs and callbacks |
|---|---|---|---|
| Self-sufficient farmer | Keeps food buffer, expands growing, sells modestly | Preparedness, steady income, winter security | Slower town restoration, respects social boundaries; people acknowledge farm reliability |
| Working craftsperson | Accepts paid carpentry jobs, invests wood/ore | Infrastructure unlocks, repairs and furniture | Material/time cost, selected building priorities shape services |
| Community neighbor | Delivers meals and helps people, builds trust | More character context and optional support | Less spare stock and coin at first; later human reciprocation |
| Cautious investigator | Collects evidence and avoids needless risks | Prepared exploration, records and grounded deductions | Some opportunities take longer; alternative safer routes exist |
| Adventurous pathfinder | Takes risks in woods/optional waters, trusts instinct | Different discoveries, materials and stories | Setbacks, Sanity/supply use and uncertain discoveries without forced tragedy |

These are *styles of play*, not menu-selectable classes or skill locks. Most players will mix them, and habits may change each season.

## Sample CYOA mini-arc: 'The Winter Shortage' (PROPOSED)
**Availability:** Optional future Wicker Cove-adjacent winter side request after farm has food surplus; first occurrence should only be introduced once towns/dispatch loop actually exists. Not a current story beat and not an addition to the fixed 17-chapter spine.
**Premise:** Inn, store and a few households need food and fuel; player's farm has finite stores.
- **Help the inn:** donate/supply part of stores. More inn cooperation, guest-catering contacts, lower home reserves; later thank-you or useful assistance, not automatic guaranteed bonus.
- **Sell to general store:** earn bounded coins via fair market contract; store distributes through ordinary channels; later access to a practical merchant opportunity, not moral condemnation.
- **Keep supplies:** home secure for severe winter; residents address their needs imperfectly or through other providers; player can help later, no permanent lock.
- **Help households directly:** effort/travel cost, individual neighbor relationship changes; an optional later social callback.
**No dice** to determine the player's allocation. If transport/repair tasks are uncertain, use one bounded check with clear risks, and a fail-forward consequence.
**Callbacks:** Same-day response; one week later letter/dialogue/stock variation; next season practical future option. Preserve optional/reversible paths.
**Economy check:** no duplicate reward for sold/donated same items, no exploit through repeat conversation, winter resources available to a reasonable player.

## Sample CYOA mini-arc: 'Whose Pier?' (PROPOSED)
**Availability:** Post-Wicker Cove, after harbor working district; no new ocean needed.
**Premise:** There are enough materials to restore one of two damaged waterfront facilities first.
- **Repair fishing gangway:** enables regular boat prep/market supply; dock workers and fishmonger respond.
- **Repair delivery landing:** reduces shipping bottleneck; store/inn supply improves and visiting merchants may be more reliable.
- **Delay work for farm improvements:** own home builds first; town continues partial functioning; re-offer repair without indefinite failure.
**Roleplay nuance:** A fisher may reasonably prefer one; a merchant another; neither is a universal objective correct choice. Other repairs remain possible later at additional cost.
**No false dramatic branch:** shared town remains fogbound and poor even with one restored pier.

## Sample CYOA mini-arc: 'What Did You See?' (PROPOSED)
**Availability:** After player hears conflicting fog histories; only if Fog-001 lore matrix passes.
**Premise:** A sailor remembers a clear headland, a local merchant has a ledger saying otherwise.
- **Trust sailor:** unlock a personal account/route story, but not objective truth.
- **Trust ledger:** invite source-comparison conversation, but not objective truth.
- **Suspend judgment:** preserve both relationships, maybe earn an observation task.
- **Challenge the premise:** ask whether different lookout positions or different years explain disagreement.
**Roll limitation:** no d20 check reveals the actual onset/cause of the fog. Checks may affect how tactfully questions are asked or whether a worn chart is deciphered; always at least one viable route to clues without a mandatory high-level skill.

## How D&D-inspired uncertainty should feel
- Player chooses **intent and approach**. Existing skills, tools, preparation, weather, helpful allies and previous decisions create plausible odds.
- A d20-like roll may vary success, success with complication or setback. **It cannot silently reverse an intentional player action**, make a protected major ending purely random, or change canon.
- UI can use grounded verbal signals: 'Your tools should hold', 'Without a dry plank this is risky', 'Gideon knows these waters'. No need to show die except optional dev debugging.
- 'Bad' outcomes may consume a small resource, require a second method, delay a contract or change dialogue. **Fail forward** on main routes; optional risky side content may be missed if stakes were clearly signposted.
- Saving: roll once for given event/attempt state, commit outcome atomically; cannot reroll by closing/reopening dialog. No infinitely farmable XP or coins.

## Five levels of narrative impact
1. **Texture:** dialogue reflects chosen wording; cheap, frequent; no permanent data needed.
2. **Relationship:** one NPC remembers and behaves differently later; meaningful but bounded.
3. **Economic:** material, cash, prices, production or business function changes; creates tradeoffs.
4. **World:** physical object/room/route or available work changes for a long time; high-value bespoke content.
5. **Story:** key historical decisions/scene access/ending variations. **Keep current StoryAct ending conditions intact until explicitly approved narrative design.**

Content budget recommendation: ~70% texture/short responses, ~20% relationship/economy callback choices, ~10% major world/story choices; these ratios are rough design heuristics, not implementation targets. Spend production effort on visible meaningful change, not branching every line.

## Existing canonical story integration and constraints
Source: `StoryAct` currently has `beats`, `meeting` won/lost determined by Maren's `maren_book` and the vicar's `vicar_register`, Davy night choices, and saved `endings`; `FolkSystem` has relationship points/hearts, scenes, requests and daily/seasonal lines. These already provide **some** consequences but not a general branching choice engine.
- A new choice's callback may acknowledge what a character did **without** moving the essential vote/ending flags behind luck.
- Wicker Cove's resident cast are proposals and must not overwrite Maren, Davy, vicar and postman schedules or authoritative story evidence.
- If an alternate meeting outcome/new endings is desired later, create a standalone story remapping plan with old-save compatibility and tests, not an incidental addition during town dialogue.
- Wicker Cove fog chronology and causation remain contradictory/unconfirmed **no matter how well the player rolls**.

## Priority tasks and design handoffs
| Task | Priority | State | First useful deliverable |
| --- | --- | --- | --- |
| **CCH-CHOICE-PATHS-001** | **P1 design** | Documented | This persistent consequence architecture, five player expressions, three connected proposed side arcs |
| **CCH-CHOICE-PATHS-002** | P1 design | Proposed | A choice consequence/callback matrix for 5-8 *existing* first-week decisions and possible alternate approaches (audit first; avoid claiming choices implemented) |
| **CCH-CHOICE-WINTER-001** | P2 | Idea | Test optional winter supply dilemma using real stock/seasonality and delayed callback after dispatch exists |
| **CCH-CHOICE-TOWN-001** | P2 | Idea | Choose harbor vs merchant restoration order; 2 local visual/function impacts and reactions |
| **CCH-CHOICE-FOG-001** | P2 | Idea | Contradictory witnesses plus diary reactions, no canonical answer |
| **CCH-CHOICE-PERSIST-001** | P1 design/QA | Proposed | Save schema, old-save migration, deterministic one-shot roll test, callbacks, duplicate reward prevention |
| **CCH-CHOICE-LIFE-001** | P2/P3 | Idea | Season-spanning reflection/diary summaries that acknowledge choices, not moral grading |

**Next approval gate:** Audit actual first-week branching and persistence; select *one tiny* playable farm decision with same-day effect and delayed callback plus one optional hidden uncertainty test. No branching story overhaul or giant choices manager authorized.

## Definition of success
A human player can replay a small set of days with genuinely different approaches and hear/see different consequences days later; neither playthrough feels objectively punished for its priorities, saved decisions don't vanish or reroll, the existing fixed story can progress, and the diary truthfully reflects actions rather than pretending they happened.
