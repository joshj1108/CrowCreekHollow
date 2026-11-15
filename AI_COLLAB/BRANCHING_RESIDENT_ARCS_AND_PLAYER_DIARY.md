# CCH-CHARACTER-ARCS-001 / CCH-DIARY-LIFE-001 — Branching Resident Stories and a Diary of the Life You Lived

**Date:** 2026-11-14. **Status:** Design exploration, **not implementation authorization**.
**Owner-set creative direction:** Crow Creek Hollow is an ongoing choose-your-own-adventure, no universally right/wrong choices; consequences carry through seasons, with optional hidden tabletop-style roll resolution for genuinely uncertain actions.
**Sources actually inspected:** `scripts/folk_system.gd` (existing four walker relationships/scenes/requests and their save flags), `scripts/story_act.gd` (17-chapter story, three endings and saved beats), `scripts/panel_rows.gd` (diary section/page data), `scripts/action_bar.gd` (existing book renderer/tabs), `scripts/diary_book.gd` (page presentation/handwriting). Related design: `PLAYER_PATHS_AND_CONSEQUENCE_WEAVE.md`, `LOWMERE_RESIDENTS_DESIGN.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `CREATIVE_BLUEPRINT_START_TO_FINISH.md`.

## Creative ambition

A player who spends two in-game years on the same farm should see a distinctive history of personal choices, village priorities, relationships, risks, and memories. **Their game is not different because they chose a class or aligned with a morality meter; it is different because the world remembered what they did, and because the player saw some consequences others did not.**

**Player life identity** arises from recorded behavior; never assign permanent personality labels or punish players for changing priorities later.

## Technical status / non-duplication

**Implemented:** The existing **FolkSystem** already manages friendship (0–10 hearts), gifts, requests, character dialogue and four progressive scenes per existing walker. Its `seen`, `requests_done` and `bonus` dictionaries are persisted. **StoryAct** persists narrative `beats`, meeting state and endings; critical ending hooks `maren_book`, `vicar_register`, `davy_turn`, `post_hand` are established. The journal UI already renders pages in the player's handwriting or Agnes's, with page flips, tabs, notes, pages from the woods, the second year and the Afterword. `PanelRows._diary_sections()` assembles sections, returns `sections + m.mystery._sections(is_new)`, and also has an existing 'The day' report/event history. `ActionBar` renders the pages and has a static ribbon palette.

**NOT implemented:** A general choose-your-own-adventure decision registry, authored personal-reflection sections, persistent NPC branching arcs or world/relationship callbacks based on such choices. Do not claim these exist today.

**Do not rebuild:** diaries, renderer, handwriting fonts, whole dialogue box, parallel social system or quest manager. Introduce small, stable records feeding existing `PanelRows._diary_sections()` and, later, established FolkSystem.

## How resident arcs should function

### Common three-act structure
- **Act 1 — The ordinary need:** know the person through their real profession, solve one small practical problem or decline. Player must be able to ignore them without blocking life.
- **Act 2 — A disagreement or tradeoff:** choose among 2–3 *different viable methods* to pursue a goal. Skills, resource costs, schedules, promises and personal history change consequences. Not an obvious 'help vs be cruel' binary.
- **Act 3 — Ownership of the result:** NPC makes a believable decision, with the player's earlier support influencing available paths, material outcomes and how the NPC regards them. Lasting callback in their workplace/dialogue/letter/diary.
- **Post-arc life:** ordinary schedules, occasional contract or remembered dialogue; the NPC isn't a frozen quest marker. The player can revisit or try an alternative commercial route even if a personal story diverged.
- **Hidden rolls:** for uncertain jobs (boat repair, damaged records, difficult navigation) rather than selecting moral/intimate life choices; rolls cannot decide the origin of fog, override a major promise or randomly cut off an existing ending.

### Four candidate personal arcs (names/biographies are NOT canon until owner approves)
| Candidate | Arc title | Act 1 need | Act 2 meaningful choice | Distinct long-term outcomes |
| --- | --- | --- | --- | --- |
| **Edith Vale**, innkeeper | **The House With Empty Rooms** | The inn needs food, warmth, roof/guestroom repair | Shape room service toward affordable working lodgings, small visitor hospitality, or hand-designed individual guest rooms; alternative timing via owner labor, material support or paid contract | Different guest briefs, room decoration motifs, catering orders and her acknowledgment; at least one working inn room in any route |
| **Gideon Pike**, fisherman | **The Water Beyond the Harbor** | Supply his small crew and inspect/repair aging boat | Reinvest in familiar dependable grounds, survey new waters with informed risk, or cooperate with neighboring crews to pool gear and information | Different fishing ground availability, route prep cost, crew trust and follow-up; original fishing/story never requires sailing |
| **Thomas Bellweather**, general store | **A Store Worth Keeping** | Fill empty shelves and repair the storeroom | Concentrate on local produce, broad practical household goods, or modest coastal imports | Different small stock/contract categories, customer messages and relationship texture; essential supplies remain obtainable |
| **Martha Fenwick**, fishmonger | **What the Sea Provides** | Restore cold storage and reliable fresh-fish purchasing | Prioritize local daily supply, winter preservation or higher-value specialist sales | Different storage/preservation contract emphasis, seasonal fish demand and village callbacks; no single route is richest across all conditions |

Design safeguard: each candidate must have an interesting reason to pursue the path, a real short-term tradeoff and one world response. **The resident retains agency**: the player influences priorities and helps; doesn't unilaterally decide a stranger's personal identity or entire business strategy. Business transactions must remain available even if relationships are cool. Diversification/catch-up opportunities should exist later; do not create artificial content scarcity or require all branches to reach a story ending.

## Three complete branching beat maps (illustrative)

### Edith: a first guest room
1. Farm-to-inn ingredient order establishes her practical need.
2. A leaking room needs partial carpentry repairs; player may contribute materials, negotiate a fee, or offer help later.
3. Once repaired, Edith wants to reopen it. Player can help furnish for working crews, visiting merchants or a cozy individual guest; each has a brief based on 2–3 *clear* requirements, not subjective mystery scoring.
4. First guest comments on room; fulfilled request gives bounded coins, materials/recipe or décor unlock and trust.
5. Weeks later guest type/inn supply requests reflect room's purpose; Edith thanks player in a short original scene. Remodeling remains possible so the choice doesn't become permanent punishment.
**End state:** inn has a functional room and Edith runs it; exact clientele/decor varied.

### Gideon: taking the first boat out
1. Player first helps with supplies/net repairs and sees which boat needs work.
2. Repairs include choice of quick patch vs thorough fix vs asking Gideon to inspect. **Only the uncertain physical repair may roll**. Setbacks cost time or require extra plank; no permanent sea lock.
3. If working voyage later exists: accept safe nearshore crew trip, attempt a charted fishing ground, or decline. Return with meaningful fish and a small story, not a mandatory horror encounter.
4. A later market contract or Gideon dialogue acknowledges preparedness, route choice, and safety.
5. Future route access can differ by discovery without closing the forest or story. Player can change tactics through effort.
**End state:** a working fishing crew independent of player; optional exploration frontier deepens.

### Martha: keeping winter fish usable
1. Bring fresh pond/candidate sea catch to her market and learn about storage problems.
2. Decide to help with cold storage, salt/smoking process or reliable local deliveries first. Different costs and delays; avoid duplicate production mechanics.
3. Winter market changes stock and order opportunities to reflect the chosen approach.
4. Next season she remembers how the player helped the town get through winter; an ordinary gratitude line or new fair contract, without a karma score.
**End state:** some practical market service improves; player retains other options later.

## Personalized diary — desired player experience

**The diary is not a quest log disguised as prose.** It records authored memories selected from actual saved events and player intentions. Agnes's narrative pages remain **written in Agnes's hand**, fixed and untouched. Player-authored reflections remain in the established **your hand** font, with clarity on objective event vs chosen action vs belief.

### Proposed new journal sections (small release slice)
- **'My days'** (working title) for important personal memories/events; one page per meaningful arc or concise paired moment, not a log of every button press.
- **'The people'** (optional later) for a short summary of known individuals and what they've told you, without replacing existing Folk friendship UI.
- **'Seasons'** (future stretch) for up to one authored reflection per season, if enough distinct material exists.
- **Existing 'Agnes Rook', 'The wood', 'The second year', 'Afterword' remain as designed.** Do not replace their content with random generated text or merge into character diary.

### Memory/page model (proposed, not actual save schema)
- `memory_id`: authored stable event key such as `inn_first_room`.
- `occurred_day`, optional time and season from **actual game state**.
- `who` and `location` only if relevant and verified.
- `intent_choice_id`: what user selected.
- `outcome_id`: what resolved (including complication from hidden roll).
- `belief_id` (optional): what user expressed believing; not treated as objectively true.
- `callback_state`: follow-up not yet encountered / happened.
- `page_variant_id`: index of authored text variant using events/options and conditions.
- `read` flag uses existing diary unread system where possible.
Preserve separate canonical event flags and reward ledger; journal should **render from verified event outcomes** or one shared event registry, not become a second source-of-truth controlling progression.

### Example paired diary entries (illustrative, not canonical dialogue)
**Player assisted Edith (no assertion of love/regret):**
> I had enough produce to spare for the inn. Edith was trying to keep the kitchen open, so I took it down the hill. She said the rooms might be used again before winter.

**Player stored produce for own farm:**
> The pantry was nearly as empty as it looked. I kept what I had grown. The inn's shortages were still on my mind when I passed the mailbox the next morning.

**Player used trade instead of gifting:**
> The shopkeeper offered a fair price for the vegetables. I took the contract. There is still work to do on the farm and supplies to buy.

**Fog belief vs truth:**
> Gideon remembers seeing the far headland. Martha says it was never visible. I don't know who is right.
Only write 'I believe Gideon' if player chose an answer indicating that; never declare the headland objectively existed.

### Diary usability and production limits
- Add pages to existing `PanelRows._diary_sections()`, not a second visual diary.
- Existing `ActionBar.RIBBONS` uses hard-coded known tab names; adding a new tab may require one style entry, layout/scroll check and page-turn regression. **Do not exceed readable tab limit** especially at smaller windows and controller.
- Page count bounded: v1 target **6–12 selected meaningful memory pages plus one seasonal-style recap** only after usability tests. Do not log every dialog choice or make the diary a massive unsearchable scroll.
- Explicitly preserve current 'The day' short message history, which is different from authored long-term memories. Diary page turn options and hand fonts remain.
- Memory writing must not accidentally leak unearned Agnes pages, hidden story outcomes, NPC affection, or fog cause. Original story pages remain the authoritative lore source.
- Consider optional **last season** summary before a new season, not mandatory frequent pauses or cutscenes. Player opens diary at own pace.
- Chronology and visibility across the unusual 420s day and October 1 start must be consistent.

## First implementation slice — not authorized yet
**Prototype should work without Lowmere art or new NPCs:**
1. Inspect existing farm/walker events and select one optional action with two viable methods; existing routes `maren_book`/`vicar_register` remain protected.
2. Save stable **choice/outcome** once with a small schema/migration; no repeat rewards; same decision cannot be rerolled by restarting/reopening.
3. Add **one** personalized memory page with two text variants to existing diary, plus a **later callback** from existing folk interaction, report or mail. Validate keyboard/controller, layout, page flip and two save/reload paths.
4. Automated choice matrix plus an actual player test. After this, consider extending to one Lowmere NPC (Edith) alongside `CCH-LOWMERE-PEOPLE-001B`.
5. No big branching trees or full 'journal generator' before the single-page prototype feels authentic.

## Priority and dependencies
| Task | Priority | State | Gate |
| --- | --- | --- | --- |
| **CCH-CHARACTER-ARCS-001A** | **P1 Design** | Proposed | Audit current four walkers' choices and hooks, then design compatibility matrix for new NPC arc flags |
| **CCH-DIARY-LIFE-001A** | **P1 Design** | Proposed | Diary data rendering, page count, stable memory records, save migration and privacy of unknown lore |
| **CCH-DIARY-LIFE-001B** | **P1 prototype candidate** | Not approved | One saved optional choice → two diary variants → delayed callback, using existing content |
| **CCH-CHARACTER-ARCS-001B** | **P2** | Idea | Edith arc one repair/room branch and 1–2 future callbacks; only after Lowmere/inn basic loop exists |
| **CCH-CHARACTER-ARCS-002** | **P2** | Idea | Gideon nearshore work/route choices only after first optional voyage is worthwhile |
| **CCH-CHARACTER-ARCS-003** | **P2** | Idea | Thomas and Martha economic paths using same contract/relationship infrastructure |
| **CCH-DIARY-LIFE-002** | **P2** | Idea | Player memory section, one meaningful seasonal reflection and lore-safe belief wording |
| **CCH-DIARY-LIFE-003** | **P3 stretch** | Idea | Character biographies / 'People' notes, extra journal customization, retrospective after ending |

**Testing:** A choice must create a distinct factual diary entry and a delayed spoken/world callback; old saves render the original book normally with no invented past actions; no impossible story endings, diary spoilers, excessive tabs, repeatable rewards or RNG reload exploit.

## Major design question for next owner discussion
Should the diary merely reflect decisions, or should players also be able to write a **very short optional personal interpretation** (pick an authored phrasing/attitude, not freeform keyboard text) at rare moments? Recommendation: first ship automatically accurate entries; add player-selected reflection only where it significantly changes the story perspective. This should never be necessary to unlock a route.
