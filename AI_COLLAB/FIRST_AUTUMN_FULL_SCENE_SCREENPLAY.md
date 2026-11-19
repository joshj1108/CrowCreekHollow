# CCH-SCRIPT-AUTUMN-002 — First Autumn: A House That Needs Work
## Scene-ready literary screenplay, conditional branches, October 1–November 30

**Created:** 2026-11-14. **State:** ORIGINAL EDITORIAL DRAFT, NOT IMPLEMENTED OR FINAL APPROVED DIALOGUE. The existing first-day tutorial, Chapters 1–4, Old Maren's authored day-4 edge escort, scripted first-night scare, first All Hallows and all evidence/endings are protected. These proposed scenes are **additional** and must be inserted only after a source audit and an owner-approved small slice. No character may reveal the core Rook mystery early.

**Primary companions:** `FIRST_AUTUMN_BRANCHING_DETAIL.md`, `ROAD_TO_CROW_CREEK_HOLLOW_BRANCHING_SCREENPLAY_DRAFT.md`, `TWO_LIVES_INTERWOVEN_ORIGIN_ARCS.md`, `CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md`, `INTEGRATED_NARRATIVE_BIBLE_VOL_1.md`. Any assumed object, tool, material, animation or GUI action in brackets is an *art/implementation dependency*, not a claim it already exists.

### Editorial rule: always earn the line
A scene may mention repaired boards only if a repair exists. A scene may describe planks only **after** the workbench system is implemented. A character may describe an origin only after it was shared through a plausible conversation or actual correspondence. Player emotional interpretation is always player-authored or omitted. If an intended scene has no justified facts, choose the simple no-branch baseline. The game remains playable without entering the scene.

---

# MOVEMENT I — THE LANDING (October 1–3)

## Scene A-00, "The Latch" — after Act Zero, before first actionable tutorial
**[STAGING]** The interlude ended with the farmhouse gate. Camera returns to the real farm. No in-game minutes are consumed by this text; no second mandatory lengthy scene. The farmhouse is Stage 0; narration references only visibly true details.

**NARRATION**

> The door had swollen in its frame.
>
> You pushed with your shoulder. It opened far enough to let you through.
>
> There was a bed, a table, and more work than you could finish before dark.
>
> You set down what you had brought.
>
> Outside, a crow called twice. Then there was only the sound of wind through the fence.

**[SHORT PLAYER INTENTION, OPTIONAL, NEVER A MORALITY TAG]**
- "See what the house needs first." → highlights *existing* repair affordance, if implemented.
- "Get something growing." → resumes existing planting tutorial.
- "Find water and a meal." → resumes existing needs instruction.

All options converge instantly on existing first-day controls. Do not add a stat, hidden origin-class modifier, gift or lost time. The player has already chosen *why* they came; no second questionnaire.

**[IF INTERIOR ART DOES NOT DISPLAY BED OR TABLE AT THAT MOMENT]** Change description to "The house had been left standing. You went inside to see what was useful." Do not create false environmental specificity.

## Scene A-01, "The First Night"
**[TRIGGER]** Existing Chapter 1 sleep/first-night scare occurs. This is a *non-invasive optional diary aftermath*, not additional scare logic.

**NARRATION (morning after; only if player actually slept inside)**

> Rain had found its way through one corner of the roof.
>
> You moved what you could away from the damp place.
>
> The house was still standing.
>
> You had another day.

**[VARIANT if no rain / leak effect is actually implemented]**

> The boards made different sounds in daylight.
>
> You looked at the door once more, then went outside.
>
> There was work to do.

This passage does not claim the player was frightened, relieved or reassured. The original scare must not be reenacted or downgraded.

## Scene A-02, "What Fits on the Table"
**[TRIGGER]** Player first voluntarily examines an origin-associated *verified* item or origin journal entry, in a quiet window after the tutorial. Never automatically require an interior visit to finish day 1.

**A — SECURITY:**
> You put the folded notice where it would stay dry.
>
> The amount on the old sheet had not changed. Neither had the date.
>
> The table had room for both a bill and a packet of seed.

**B — WORK:**
> The small notebook opened to a list written for another place.
>
> There was nothing on the next page.
>
> You turned it over and wrote down what the roof needed.
>
> [Only show writing action if actual user interaction and notebook state support it.]

**C — HOUSEHOLD:**
> The ordinary thing you had packed sat beside the stove.
>
> You could leave it there or put it away. No one was coming to tell you which.

**D — PHOTOGRAPH:**
> You laid the picture near the window.
>
> From here the fence was hard to see in the trees.
>
> The photograph showed the same turn in the road, but not the broken gate.

**E — CHANCE:**
> There was still an old date written on the back of the letter.
>
> Whatever else happened here, that day would come whether you remembered it or not.

**[Interaction choices]** Display / file / keep packed (and "do nothing" accessible). Only if actual inventory/prop support is implemented. Otherwise store diary text behind a player-opened entry and avoid declaring new furniture positions.

---

# MOVEMENT II — A HAND OR A TRADE (October 4–14)

## Scene A-03, "Bad Timber, Good Advice" — Maren's first practical branch

**[TRIGGER]** Only **after** the protected Maren Day 4 wood's-edge event has actually completed and its original rewards/flags safely saved. Can occur at a normal later visit, not during the mandatory trek, and cannot interrupt a danger/time-gated scene.

**[STAGING]** Maren notices a genuinely broken portion of the house, fence or wood supply. If a specific roof weakness can't be queried, use the general weathered property. Her dry humor is intentional. Do not borrow or change the original `maren_book` dialogue.

**MAREN**
> "You found the weak end yet?"

**PLAYER OPTIONS**
1. "There are several." 
2. "Show me where you'd start."
3. "I've got a way of doing it."

**MAREN** [shared]
> "There usually are."  
> [She looks at a warped board.]  
> "The trouble with a house is it can wait longer than a person can."

**[CHOICE AFTER SITUATION IS CLEAR]**
- **ACCEPT ADVICE:** "Tell me which job matters before the rain."  
  **MAREN:** "The place where water gets in. Pretty trim won't keep a blanket dry."  
  *Result:* one clear actionable hint to a currently available repair and its obtainable materials. No free paid repair, no automatic resource transfer. `autumn_maren_approach=advice` is a **proposed editorial record, not an existing save flag**.
- **PROPOSE FAIR EXCHANGE:** "I can give you something for the material."  
  **MAREN:** "Then we'll count it properly. I'd rather have a trade than a debt neither of us remembers."  
  *Result:* initiate fair, explicitly priced/quantity-limited existing trade **only if actual UI and resource mechanics support it**; never imply exchange completed when merely offered. Store `traded` only on successful transaction. If trade isn't technically possible, replace this choice with "I'll see what I can trade for" and record a *plan*, not a purchase.
- **WORK INDEPENDENTLY:** "I'd rather figure it out on my own."  
  **MAREN:** "Suit yourself. Keep the dry boards out of the mud."  
  *Result:* no negative friendship or secret difficulty; player retains agency and Maren remains available through original interactions.

**[NEXT VISIT CALLBACK, ONLY AFTER REAL ACTION]**
- Advice + repair completed:  
  **MAREN:** "The patch held."  
  **PLAYER:** "For now."  
  **MAREN:** "For now is how most houses get kept."
- Advice + no repair:  
  **MAREN:** "That corner's still open to the weather."  
  **MAREN:** "Rain doesn't mind being asked to wait."
- Trade completed + repair completed:  
  **MAREN:** "You used the boards well."  
  **PLAYER:** "You charged me fairly."  
  **MAREN:** "I try to."
- Independent + repair completed:  
  **MAREN:** "Looks like you found your way around the problem."  
  **PLAYER:** "I did."  
  **MAREN:** "Good."
- Independent + no repair:  
  **MAREN:** "You'll get to it."  
  **MAREN:** "Just don't wait for a proper storm."

**[WHY THIS MATTERS]** The branch is not about whether accepting help is virtuous. It reveals Maren's character and persists through the **repair and later specific acknowledgment**. Trade has a real economy effect, independence preserves resources and asks time from the player, and advice improves knowledge. It must never block the original mystery evidence.

## Scene A-04, "The First Surplus" — first crop and the practical meaning of plenty

**[TRIGGER]** After actual first harvest; preserve the existing Chapter 4 `Food Takes Time` and rewards. This is a short optional observation at harvest, market stand or kitchen.

**NARRATION**
> The first crop came out of the ground without much ceremony.
>
> Dirt clung to the roots.
>
> There were enough to choose what happened to them next.

**[CHOICES ARE ACTUAL PLAYER ACTIONS, NOT A MODAL QUIZ]**
- Cook or keep some, if real recipe/pantry supports it.
- Place some on the farm stand for sale, if actual stand supports it.
- Fulfill a genuine eligible request from an existing resident, if open.
- Replant or hold reserve based on actual availability.

**DIARY EXAMPLES** (not mutually exclusive moral labels)
> "I kept the first harvest for meals."
> "I sold part of the crop at the stand."
> "I gave Maren the eggs she asked for." **Only** if original request and actual delivery completed.

No imaginary social callback when only a normal stand sale happened.

## Scene A-05, "The Path Out" — forest timber as ordinary necessity

**[TRIGGER]** Only after the owner-approved future **nearwood logging** system actually exists, and only on an optional first solo trip. The day-4 escorted trek remains a separate system and its tension is not replaced.

**[STAGING]** Narrow, readable woodland trail with harvestable trees distinguished from decoration. No mandatory ambush.

**NARRATION**
> The path was narrow enough to make you turn sideways where the branches bent over it.
>
> A tree had fallen years ago and left a gap in the canopy.
>
> There was room to work there.
>
> You chose the first trunk and set down what you were carrying.

**[AFTER ACTUAL CHOP]**
> The cut opened pale wood under the bark.
>
> You turned the log and made another.
>
> By the time you had enough to carry, the light had moved.

**[RETURN, ONLY AFTER REAL WORKBENCH PROCESS]**
> The first plank took longer than you expected.
>
> The next came straighter.

This deliberately refuses the trope where every forest visit is a supernatural vision. The trees matter first because the house needs timber. **No prose about logs/planks in current production until resources actually exist.**

---

# MOVEMENT III — PEOPLE WHO HAVE WORK TO DO (October 15–31)

## Scene A-06, "Three Skips" — Davy, ordinary childhood before danger

**[TRIGGER]** Only if Davy's source eligibility/day20 and location permit contact. Never relocate Davy or assume friendship/knowledge of Pip beyond original `FolkSystem` state.

**DAVY**
> "How many do you think it'll do?"

**PLAYER OPTIONS**
- "Three."
- "Only one."
- "Throw it and see."

**[STAGING]** Davy throws a flat stone into water, if the existing pond animation supports it; otherwise describe only a small splash without claiming exact engine animation.

**DAVY**
> "Two. It was nearly three."

**PLAYER**
> "You counted the last little one?"

**DAVY**
> "It counts if you can see it."

**[IF PLAYER STAYS AND HELPS LOOK FOR A STONE]**
> He picked up one you passed him, weighed it in his hand, and put it in his pocket instead of throwing it.
>
> "This one's good," he said. "I'll keep it."

**[IF PLAYER LEAVES]** Davy keeps practicing on his own. Later scene must not claim they skipped stones together. No heart penalty for leaving.

**[Purpose]** Davy is a child with habits and wit, not a device to announce a tragic prophecy. His later possible absence only has emotional weight if the player knows a life that was already happening.

## Scene A-07, "The Register Is for Names" — an ordinary chapel encounter

**[TRIGGER]** Eligible vicar dialogue only; canonical `vicar_register` scene and evidence are **not** reproduced or unlocked early. This is a separate small exchange during allowed visit.

**VICAR**
> "You'll have to forgive the dust."

**PLAYER**
> "Does anyone use the place?"

**VICAR**
> "I do. That makes one."  
> [He closes an ordinary service ledger, *not* the canonical old register.]  
> "Some mornings that's enough to keep it swept."

**PLAYER OPTIONS**
- "I could bring supplies when I have extra."
- "I hope the roof holds."
- "I should get back."

The offer creates no completed contribution until an actual item exchange occurs. He continues his routine with or without the farmer. Do not assert the original bell/clapper truth in this optional scene.

## Scene A-08, "All Hallows" — a different sort of dark

**[TRIGGER]** First All Hallows existing calendar experience where supported. No new obligation, crowd scene, imported lore or second All Hallows/crow bell reveal.

**NARRATION**
> The road had fewer lights than usual.
>
> Somewhere beyond the gate, a shutter knocked in the wind.
>
> You checked your lantern before going out.

**[IF PLAYER STAYS HOME]**
> You put another piece of wood on the fire.
>
> There were still beans to sort and a roof that needed attention.

**[IF PLAYER WALKS SAFELY IN THE WORLD]**
> Behind the farmhouse the hills were darker than the fields.
>
> When you came back, the gate looked smaller than it had in daylight.

No forced apparition for ordinary seasonal play. The original mystery scenes own their special appearances.

---

# MOVEMENT IV — WHAT THE FIRST FROST FINDS (November)

## Scene A-09, "What I Saved" — November 10 first frost

**[TRIGGER]** Use existing season/weather progression; avoid claiming actual frost VFX if none. Inventory-conditioned text only.

**[WHEN PLAYER HAS STORED FOOD/FUEL]**
> You counted the jars and the wood that would fit beside the hearth.
>
> It was not enough for the whole winter.
>
> It was something to begin with.

**[WHEN PLAYER HAS VERY LITTLE]**
> You checked what you had kept.
>
> There was less than you wanted.
>
> The road to the fields was still clear enough to work.

**[WHEN PLAYER HAS BEEN TRADING]**
> The stand had earned enough to buy what the fields hadn't given.
>
> The accounts were written in a hand that was beginning to look familiar.

**[POTENTIAL CHOICE]** Prepare the house, finish a contract, or carry supplies to someone *if the offer exists*. The calendar does not morally rank buying, keeping or giving.

## Scene A-10, "The Last Dry Board" — delayed Maren callback

**[TRIGGER]** A player-visible completed repair after A-03, or unresolved approach if no repair. No exact board count unless actual inventory state can confirm.

**MAREN**
> "It'll turn colder again."
>
> [She looks at the work you did, or the work still waiting.]
>
> "You needn't finish a house all at once."

**PLAYER**
> "I know."

**MAREN**
> "I only learned it after trying."

**[IF PLAYER COMPLETED THE REPAIR AND ACCEPTED ADVICE]**
> "You were right about the water."
>
> "I usually am about water," she said. "It's people I get wrong."

**[IF PLAYER MADE A FAIR EXCHANGE]**
> "Those were good boards."
>
> "Good enough," she said. "You paid for good enough."

**[IF PLAYER WORKED INDEPENDENTLY]**
> "I found the weak part."
>
> "There you are," Maren said. "Now you'll find the next one."

The same person is recognizable across approaches, but she sees the actual result.

## Scene A-11, "The House in November" — end of autumn, optional private interlude

**[TRIGGER]** A quiet evening entered voluntarily, no timer trap. At least one saved fact (a crop actually harvested, repair actually finished, meaningful original trek completed). If none, use a neutral environmental line.

**BASELINE**
> The house made its usual noises as the weather changed.
>
> The table held the day's unfinished work.
>
> Outside, the fields lay dark.

**[TRUE MODIFIERS — choose max two, with actual source record]**
- First crop: "There was still dirt under one fingernail from the last harvest."
- Actual structural repair: "The repaired part of the wall no longer let the rain through." **Only if weatherproofing is actually represented/true**; else "The newer boards showed plainly beside the old ones."
- Confirmed market sale: "The morning's sale had bought another bag of seed."
- Completed solo nearwood/hewing: "The offcuts from the bench were stacked for kindling." **Only if bench and offcuts exist.**
- Given or answered origin letter: "The answer was in the post." **Only if actually sent.**
- Existing Maren trek: "Beyond the fence, the path Maren had shown you was hidden in the trees."

**PLAYER-SELECTED FINAL LINE (optional private journal; don't force emotion)**
- "There is still a great deal to do."
- "I can manage some of it."
- "I don't know what I'll do next."
- "Leave this page unfinished."

The page is a record of actions and chosen words, not an algorithm telling players who they have become.

---

# Production appendix — factual trigger table

| Scene | Earliest window | Required real fact | Unsafe assumptions to exclude | QA |
|---|---|---|---|---|
| A-00 Latch | Oct1 after prior-life interlude | Stage 0 house physically matches | Free inheritance deed; hidden origin lore | Day clock unchanged |
| A-01 First Night | Next morning | Actual sleep; seasonal/weather state if described | Additional first scare | Chapter 1 intact |
| A-02 Table | After tutorial | Verified origin object/page | Player fixed feelings; spawned unsupported asset | No-contact/no keepsake route |
| A-03 Maren | After original day4 escorted trek | Source trek complete; normal available visit | Replacing original scene/heart flags | Chapter 3, Maren book |
| A-04 Harvest | After first crop harvested | Recorded inventory/market/request action | Unmade meal/sale/gift | Chapter 4 rewards |
| A-05 Nearwood | After forestry/bench production exists | Tree chop, inventory, bench action | Automatic phantom logs/planks | Save migration, viable tree supply |
| A-06 Davy | Source day20+ eligibility | Eligible location/character scene | Timed Y2 fate foreknowledge | No duplicate original scene |
| A-07 Vicar | Original NPC availability | Separate ordinary chapel moment | Early register and bell clues | Evidence unchanged |
| A-08 All Hallows | Calendar-supported Oct31 | Seasonal conditions | Spoiling Y2 bell | No forced lore |
| A-09 First Frost | Nov10 weather/inventory eligibility | Relevant resources if stated | Invisible jar/wood assertions | Low resources valid |
| A-10 Board | Nov and after A-03 | Repair state and successful exchange flag | Pretending repairs done | All three responses |
| A-11 House | Quiet end-autumn evening | At least one true event or neutral variant | Generated psychological diagnosis | diary facts, old saves |

**Authoring gate:** Before implementing, inspect `scripts/folk_system.gd`, `scripts/story_act.gd`, `scripts/diary_book.gd`, `scripts/estate_system.gd`, weather, inventory, social request UI and the day-count calculations. Integrate A-03 first, perhaps A-11 second, only after owner approval. Preserve gamepad flow, 420-second day, pause/skip semantics of non-prologue popups and user save slots 1–3. Never implement from this screenplay without the user approving a slice.
