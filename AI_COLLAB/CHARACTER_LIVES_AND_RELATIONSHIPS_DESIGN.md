# CCH-CHARACTER-LIVES-001 — Ordinary Lives, Lasting Relationships

**2026-11-14 — Design-only expansion.** Owner direction: emotionally lasting, masterful literary-quality storytelling in **plain language**, believable day-to-day lives, genuine branching and memory without a good/bad meter. **No code, original-scene, art, or NPC roster implementation authorized.**

## Important source review and a genuine canon continuity conflict

Read current `scripts/folk_system.gd`, `scripts/story_act.gd`, `AI_COLLAB/LOWMERE_RESIDENTS_DESIGN.md` and `AI_COLLAB/BRANCHING_RESIDENT_ARCS_AND_PLAYER_DIARY.md`.

**Conflict requiring separate audit before any dialogue rewrite:** Existing `scripts/folk_system.gd` postman scenes `post_round`, `post_crate`, `post_dead` still refer to **Lowmere**, with a specific setting description 'Lowmere's over the hills. Old place. Old women', weekly letters Agnes sent there, reply letters, iron for her bell arriving from Lowmere, and a bill from there. Project design has newly established **Wicker Cove** as the official name of the *fogbound coastal fishing village down the mountain road*. Blindly replacing Lowmere with Wicker Cove in those script lines would **implicitly rewrite or contradict established geographic/lore facts**, not simply rename a sign. The prior design-document rename did not edit those runtime scripts. **Preserve existing original dialogue for now; add `CCH-LORE-NAME-001` P1 audit** of all usage of Lowmere/Wicker Cove, maps, how old letter and bell parts originated, then seek owner-approved lore-preserving reconciliation. Do not silently invent a second city or a new source for the bell.

**Preserved authored canon from actual current script:**
- `FolkSystem`: four walkers, 0–10 hearts, requests, season lines, four scenes each at heart milestones. Their key dialogue and reactions already exist; **build around** rather than overwrite them.
- Maren lives at last cottage down lane, sister Ruth keeps mill, once voted bell down; `maren_lamp` nightly window lamp, `maren_hens` descendants of Agnes hens, `maren_hands` fear at answering sound, `maren_book` Ruth minute book, core meeting evidence.
- Davy Tull, his mother Mrs Tull, grandfather who worked Elias's orchard, dog Pip lost with wild dogs; stone skipping by pond, two-note whistle, ordinary child wants; `davy_turn` hook needed for one ending; time-limited second-autumn Davy event remains unchanged.
- Vicar cut bell down, kept clapper and register, carries rope burns and remorse; chapel service with no congregation, requests for food, own four authored scenes and `vicar_register` evidence.
- Postman walks round for 30 years, retains Rook letters, has conscientious boundaries about private letters, `post_hand` handwriting reveal and original `StoryAct` relevance. No new NPC should disclose this twist casually.
- Proposed Wicker Cove residents **Edith Vale, Gideon Pike, Thomas Bellweather, Martha Fenwick** and their biographies remain **candidate cast**, not owner-finalized canon; initial town slice only 1–2 residents.
- Wicker Cove fog remains dense all day/all seasons, with contradictory historical memories and no confirmed starting event/cause.

## Core character-writing rule
Every major character needs:
1. **A life when the player is away** — daily tasks, places, habits, other relationships.
2. **A simple human want** — security, dignity, company, finding Pip, keeping business open, a promise honored.
3. **An unresolved limit** — guilt, fear, pride, debt, uncertainty, or something they cannot do for another person.
The game depicts these in **small changes** over visits. Avoid giving everyone a paranormal secret, inventing grief to manipulate player emotions, NPCs announcing relationship scores, or monologues explaining symbolism.

## Existing anchor A — Old Maren, 'A lamp in the window'
**Already true:** practical older neighbor with Ruth at mill, Agnes relationship and hens, witnessed vote, kept light lit since Agnes's disappearance, holds critical book and can take a stand.
**More texture, proposed:** Maren has a dry sense of humor; notices poor weather, stack of firewood, repaired fence; may disagree about workmanship without belittling player. She is not a supernatural oracle. If player declines help she respects their limits. Ruth can influence through existing offscreen supplies/books, not mandatory new sprite.
**Three small scenes, proposed only:**
- Early: if player accepts, exchanges, or declines advice, Maren notices one actual repair or material choice; otherwise ordinary line.
- Midyear: she brings or requests ordinary kitchen goods with an observation about Ruth; reuse existing `maren_eggs`/requests and do not duplicate rewards.
- After existing `maren_book`: short non-compulsory reflection about Ruth taking care with records; do not prematurely disclose the meeting evidence.
**Voice sample:** 'That roof still leaking?' / 'Only when it rains.' / 'Well, that's a mercy. Would be worse if it leaked when it didn't.' / 'Get your boards in before Thursday.'
**Recurrence:** a window lamp, the basket she does not take back, or the stick on her knees. Don't use the lamp to 'prove' mystical truths.

## Existing anchor B — Davy Tull, 'A good skipping stone'
**Already true:** boy from farm below orchard, missing Pip, mother and grandfather, skips stones at pond, two-note whistle, learned about orchard from family, later feels compelled to take a turn.
**More texture:** warm, curious and occasionally silly; defies his mother in everyday ways; capable of being brave and also wrong. Favorite stones, dog memories and ordinary food preferences matter more than constant eerie lines.
**Three scenes, proposed only:**
- Before dangerous revelations: compare skipping stones or fish; simple joke. No quest reward required.
- After actual walks/friendship: one line recalls whether player joined orchard trek or brought relevant supply, no invented intimacy.
- Before second autumn (optional): Davy mentions he is worried about Pip without telling players his next-night fate; **never** override existing `davy_turn` scene or special day370 window.
**Voice sample:** 'Which one's better?' 'For what?' 'Skipping.' Player indicates flatter one; Davy throws the other. It skips three times. 'Knew it,' he says.
**Recurrence:** same two-note whistle heard near pond, then perhaps missed if he is absent. Nothing should claim a child is dead if only 'lost' until later grove result.

## Existing anchor C — The vicar, 'Hands that remember'
**Already true:** lowered bell, scarred hands, kept clapper, grave church register, father on farm transaction record, reads names monthly, service in near-empty chapel. He has responsibilities beyond his guilt: feeds people, keeps books, blesses farmer under conditions.
**Proposed texture:** repairs frayed hymn books, counts candles, hesitates before questions about acts of commission; kindness in small concrete acts. Never pretend redemption is a simple purchase or gift.
**Relationship memory:** player might fulfill an actual soup request, sit through a brief silence, or ask about a chapel window. His existing `vicar_register` must be unlocked through original evidence path, not generic moral reputation.
**Voice sample:** 'I set the books out every month. It's easier to put them away if they were in the proper place first.' (Proposed; not already in game.)
**Recurrence:** black register, scarred hands, empty chapel pew, kept clapper.

## Existing anchor D — The postman, 'The weight of a letter'
**Already true:** 30 years on round, never lost a letter, parcels for Rooks, original handwriting twist, care about privacy. He has a sense of practical responsibility that becomes moral tension.
**Proposed texture:** knows bad roads, rainy mornings, cost of stamps, changes of address and the time a route takes. His dry practicality keeps supernatural matter grounded.
**Relationship memory:** a farmer who completes an ordinary delivery or converses often may hear a line about the road, not a premature reveal of the secret letters.
**Voice sample:** 'Road's washed out again. Post still has to get through. It doesn't care if I'm wet.' (Proposed only.)
**Recurrence:** the satchel which he seldom sets down, envelopes, catalogues, the gate.
**Lore restraint:** Never casually explain whose handwriting appears on a letter before the actual `post_hand` scene; never rewrite the 'Lowmere over hills' references pending `CCH-LORE-NAME-001`.

## Wicker Cove candidate residents — ordinary work first
**All four names/backgrounds tentative** until explicit owner approval; do not claim game already includes them.

### Edith Vale — Innkeeper: 'The House With Empty Rooms'
- **Workday:** starts the hearth, counts deliveries, dries sheets that never quite lose the salt damp, handles a leaking upstairs room; runs the inn herself.
- **Want:** one guestroom in use without having to sell the building, and a place with enough activity to feel worth keeping open.
- **Limit:** cannot do all repairs alone; may have more pride than money.
- **Interactions:** produce/meals order, paid roof work, later persistent interior commission where player chooses actual room layout; her guests and priorities change one or two lines.
- **Sample:** 'Room upstairs has a leak. I put a bucket under it, then another. Roof doesn't care how many buckets I own.'
- **Avoid:** one dramatic tragic secret, magically restoring all village prosperity after player fixes one roof.

### Thomas Bellweather — General store: 'A Store Worth Keeping'
- **Workday:** counts stock, fixes price labels, orders essential goods by irregular shipments, checks a few neighbors' accounts.
- **Want:** a reliable shelf of basic provisions; customers who can find the goods they need when they come.
- **Limit:** won't promise stock he can't deliver; often appears stern because he tracks debt carefully.
- **Interactions:** real farm-crop order, fair price and money, one storeroom/shelf repair, later household stock availability; if farmer has no produce he still sells basics.
- **Sample:** 'Come Tuesday I'll know if the rope arrived. I can put your name down. Can't put rope on the shelf until it gets here.'
- **Avoid:** taking simple transactions as player moral identity, fixing the entire supply economy instantly.

### Gideon Pike — Working fisherman: 'A Boat That Still Goes Out'
- **Workday:** cleans nets, patches hull seams, watches tide (fog can make navigation difficult), plans crews; regular working boat rather than heroic captain.
- **Want:** a dependable boat and work for remaining crew.
- **Limit:** distrusts needless risk; can be wrong about visibility history without being a liar.
- **Interactions:** supplies, paid repair/inspection, optional short NPC-led fishing trip once maritime stretch works; minor repeated choices around safe coastal waters.
- **Sample:** 'You can mend that seam. Won't make the sea agree with you.' 
- **Avoid:** making him a mouthpiece who knows real fog cause or requiring boat play for the farm's bell ending.

### Martha Fenwick — Fishmonger: 'What the Sea Provides'
- **Workday:** buys catch, salts fish, notices quality, repairs cold store, keeps a ledger of spoilage and deliveries.
- **Want:** enough fresh fish for ordinary tables and some preserved stock for winter.
- **Limit:** has little patience for waste and grand claims; still needs Gideon and other crews.
- **Interactions:** farm produce-for-fish exchange, cold-room repair, winter preservation order; remembers useful work and missed pickups without judging player.
- **Sample:** 'If it goes bad here, it won't improve on your walk home.' 
- **Avoid:** turning every sea shortage into supernatural omen, or confirming/denying Gideon's contradictory fog accounts as objective truth.

## Web of everyday relationships, not separate quest silos
- Ruth (offscreen established sister) and Maren exchange food/records; Maren's practical comments can link mill, farm and Wicker Cove without inventing long travel scenes.
- Davy and family, including Mrs Tull, have their own time and chores; Davy's mother need not become a punitive gatekeeper or new required rescue quest.
- Vicar buys or receives food for chapel poor box; Edith's kitchen and Martha's fish could organically supply it if town economy ever exists. This must not bypass `vicar_register`.
- Postman delivers between the farm, Wicker Cove and lane *only when reconciliation of geography and existing Lowmere dialog is complete*. Do not assume he originated Agnes's old mail.
- Edith/Thomas have practical supply relationship; Gideon/Martha disagree about costs and catches without permanent hostility; Martha may supply Edith or the chapel. All exchanges use one existing coin/order/relationship network.
- Individual residents should sometimes be unavailable because they are doing work, but baseline services remain usable during business hours and critical story characters maintain exact original schedule.
- Wicker Cove forever fogbound, but each person has their own daily way of living in it. Keep visual/coastal lore ambiguous.

## Four tiny connected arcs, not dozens of forced quests
1. **Maren's basket**: player fulfills or declines an actual request → later she references Ruth in a brief line → one durable diary memory only if real.
2. **Davy's stone**: player participates in a short optional pond interaction → a later sound/line recalls it; if he goes missing the absence can be felt; if found/returned, different small response after existing Davy event, with original outcome intact.
3. **Edith's upstairs room**: player accepts paid repair, defers, or arranges joint work → room changes when truly completed → an inn guest uses it and Edith remembers, postgame still visible.
4. **Martha and Gideon's catch**: one useful preservation order → two workers disagree about storage/return timing → player can prioritize freshness or longer preservation; ensuing fish/stock result matters but not the fog truth.
All must work without the player making every character friendly; each NPC has agency to address a need elsewhere.

## Production sequencing and canon safeguards
- **P1 character writing:** audit existing `FolkSystem` scenes before adding words; maintain exact 0–10 heart levels, scene IDs, visitor date gates, post hand and ending flags.
- **P1 lore audit:** reconcile literal Lowmere from old postman runtime script vs owner-renamed official Wicker Cove and established mountain-road geography; do not paper over contradictory facts.
- **P1 prototype:** one Maren or Davy optional encounter on existing farm using current dialogue and diary memory system. Reuse `CCH-DIARY-LIFE-001B` and `CCH-AUTUMN-BRANCH-003`. Later independent callback is mandatory for testing but not added as a compulsory quest.
- **P2 town first cast:** select and approve Edith + one other practical resident; make them interesting before adding other named people. One repair and one order is sufficient for initial proof.
- **P2 more microstories:** one later callback for each successfully tested arc. No romance, full NPC schedules, new childhood backstory or maritime fleet needed.
- **P1 QA:** contrast a player who befriends all, a farmer who avoids people and a player who skips Cove; correct labels, old saves, dated scenes, user-approved plain language, story path and three endings.

## Backlog
- `CCH-CHARACTER-LIVES-001` — P1 design: this grounded cast/voice/relation matrix.
- `CCH-LORE-NAME-001` — **P1 mandatory lore audit**: old postman Lowmere runtime lines, Wicker Cove rename, over-hills geography and bell origin. Separate proposal before touching original text.
- `CCH-CHARACTER-LIVES-002` — P1 source/voice audit: choose and review 10 representative existing walker lines; identify duplicates, nonauthentic delivery and safe optional callback points.
- `CCH-MAREN-MICRO-001` — P1 gated candidate: one ordinary season response + a deterministic later memory using already available scene UI.
- `CCH-DAVY-MICRO-001` — P2 gated candidate: one short pond life moment, later subtle callback, preserve day370.
- `CCH-COVE-CAST-001` — P1 design choice/P2 eventual playable pair: owner approve which two names/cast and work patterns.
- `CCH-COVE-RELATIONS-001` — P2 idea: one connected inn/store or fishmonger/boat two-character exchange, not four independent quest trees.
- `CCH-CHARACTER-LIVES-QA-001` — P1 eventual regression: flags, hearts, older saves, town access, no-town runs, Maren book, vicar register, Davy turn, post hand and all endings.

**This document adds design directions and examples, not finalized game text. The postman lore discrepancy requires review before scripting Wicker Cove's old postal history.**

## 2026-11-14 — Expanded social web, voice anthology and eight interlocking arcs

The next level of player-authored lives is specified in [LIVING_COMMUNITY_RELATIONSHIP_WEB.md](LIVING_COMMUNITY_RELATIONSHIP_WEB.md) (10 relationship ties, realistic knowledge propagation and joint family/business stories), [SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md](SCENE_ANTHOLOGY_AND_CHARACTER_VOICE_BIBLE.md) (twelve proposed scenes in distinct plain-language voices) and [RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md](RESIDENT_ARCS_TWO_YEAR_BLUEPRINT.md) (eight compact multiseason personal/economic arcs). The implementation path is [LIVING_WORLD_PRODUCTION_BLUEPRINT.md](LIVING_WORLD_PRODUCTION_BLUEPRINT.md), **starting with one existing-farm decision, later callback and diary**, not a town-wide NPC overhaul. Postal lore conflict and possible resolution options are separately assessed in [WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md](WICKER_COVE_POSTAL_LORE_CONTINUITY_AUDIT.md); official Wicker Cove name canon but geographic/bell/letter runtime interpretation unresolved. None of these drafts finalizes proposed NPC names or grants code approval.
