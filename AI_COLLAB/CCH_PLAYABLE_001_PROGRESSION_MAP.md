# CCH-PLAYABLE-001 — Gameplay progression map

Companion to `CCH_PLAYABLE_001_FINDINGS.md` (2026-11-13). Each milestone: what it needs, how it unlocks, whether the
needs can be got, whether it was reached **in blind play** (real input, first week and follow-ups) and **in
simulation** (first day in the engaged / ignore / early-bed 400-day probes), whether it is blocked, and the findings
that touch it. "Sim" days are not played days. "—" = not reached; "n/t" = not tried.

## The shape of the game

```
START (day 1, 06:00, Oct 1; hoe, trowel, bucket, 5 turnip seeds, 4 firewood, 0 coins)
  |
  |-- find the diary at the desk  ->  guided first day (8 steps)  ->  chapters, tips, homestead steps
  |
  +-- SURVIVAL LOOP (every day) ---------------------------------------------------------------
  |     hunger: forage -> crops -> cooking (hearth) -> eggs, milk, fish
  |     thirst: pond -> well (repaired) ; comfort: fire (firewood) and the house's stage
  |     sanity: nights faced (lantern) / tidying, pastimes, blessing / the house's stage
  |     health: refills each morning; bandage; 0 = wake at the gate, -10 sanity
  |
  +-- FARM LOOP -------------------------------------------------------------------------------
  |     seeds (5 to start; the CATALOG at the desk; chapter rewards; seed back from harvests)
  |       -> plant (trowel) -> water daily (bucket -> pump + hose -> nozzle -> sprinklers) or rain
  |       -> ripen (turnip about 7 days) -> harvest (hoe) -> eat / cook / store (cellar) / SELL (stand)
  |     Farming level opens fields 2-4 and crops; seasons gate each crop
  |
  +-- MATERIALS -------------------------------------------------------------------------------
  |     brush -> sticks, fiber, resin        trees (hatchet) -> wood, hardwood (better hatchet)
  |     farm rocks (pick) -> stone           cave ore (pick; Mining 2 copper, pick 2 + Mining 5 iron)
  |     furnace: ore + wood -> bars          crows, mends, treks -> feathers
  |     treks -> flour, apple saplings, flax, storm oak, rope
  |
  +-- HOMESTEAD (14 steps, 20 coins each) ------------------------------------------------------
  |     boarded -> second field -> coop -> patched -> smokehouse, firewood store, furnace
  |       -> yard light -> fourth field -> barn -> Hollow Lantern -> flower beds
  |       -> restored (Carpentry 8, SUMMER only) -> crow bell (4 parts; hung only on All Hallows, year 2)
  |     coins: stand, daily job, steps, treks  ->  catalog, furniture, extensions, paint, tax, deed
  |
  +-- EXPLORATION ------------------------------------------------------------------------------
  |     cave (any day; a lantern to see, a pick to mine, a weapon to fight)
  |     treks: lantern + lamp oil;  edge (day 4) -> mill (14) -> orchard -> chapel -> post -> grove (397)
  |     walkers' hearts -> scenes -> the second year's meeting and endings
  |
  +-- STORY ------------------------------------------------------------------------------------
        17 chapters, strictly in order   |   Agnes's 10 pages + 5 from the wood
        second year: letter (240) -> shown -> orchard (265+) -> his knock -> meeting (300-357) -> Davy (370)
        ENDINGS: The Line Under the Rooks (leave the Hollow at the door 3 times, from day 240)
                 The Hollow Sleeps (bell on day 396 + the grove)   |   Two Came Home (the grove by night, all won)
```

## Dead ends and dependency loops found

| Where | What | Finding |
| --- | --- | --- |
| Chapter 9 -> chapters 10-17 | Cleansing needs a lost sanity limit; a careful player has none. The chapter list waits (engaged sim: day 21 to day 398). | PLAY-04 |
| Chapter 15 -> 16, 17, Story Complete | Davy's beat is never closed if the bell comes first. **Permanent on that save.** | PLAY-05 |
| Early bed -> low sanity -> walker's nerve -> failed trek -> lower sanity | A loop a new player can fall into in week one; each turn makes the next trek harder. | PLAY-02, PLAY-09 |
| Fishing pole "(locked)" <- Willow rod <- Fishing 2 <- fishing | Looks circular; is not (the bare pole casts). | PLAY-12 |
| Frozen walker <- trail ration <- eggs <- coop | No remedy on the first trek. | PLAY-09 |
| Coins -> seeds | The link (the desk's catalog) is never shown. | PLAY-08 |
| Chapter 10 <- Restored <- Summer | Earliest about day 245 by design. | PLAY-14 |

No circular **requirement** was found: nothing needs itself. No material, recipe ingredient or tool is unobtainable.

## Milestones

### Start and the first session

| Milestone | Needs | Unlocked by | Needs obtainable | Blind play | Sim (eng / ign / early) | Blocked | Findings |
| --- | --- | --- | --- | --- | --- | --- | --- |
| New game started | — | Title menu | yes | **yes**, both devices | — | no | — |
| Diary found | Walk indoors, hand action at the desk | A hint 6 s in, every 90 s | yes | **yes** (06:38 day 1) | — | no | PLAY-07 |
| Guided first day done | Seeds, brush, a tree, the pond | Diary steps | yes | **yes** (about 09:25 day 1) | — | no | PLAY-06, PLAY-10 |
| First night survived | — | 22:00, scripted | yes | **yes** (watched indoors) | 1 / 1 / 2 | no | — |
| Ch. 1 Sleep Under Your Own Roof | Bed, 18:00-03:00 | Diary "Sleeping" | yes | **yes** (day 2) | 2 / 2 / 2 | no | — |
| Ch. 2 Light the Way (Tin Lantern) | 4 wood, 3 fiber, Bushcrafting 2 | Craft, Other | yes | **yes** (day 2 or day 4, as fiber allowed) | 2 / 2 / 2 | no | PLAY-21 |
| House Boarded | 3 wood, 2 fiber | House section | yes | **yes** (day 2) | 1 / 1 / 1 | no | — |

### Survival

| Milestone | Needs | Unlocked by | Obtainable | Blind play | Sim | Blocked | Findings |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Eating (forage) | Forage on the farm daily | Diary "Hunger, thirst, and comfort" (12:00 day 1) | yes | **yes** | yes | no | — |
| Drinking | The pond | Guide step 8 | yes | **yes** | yes | no | PLAY-10 |
| Fire and comfort | Firewood (4 to start; then the firewood store) | Hearth | yes | **yes** (ran out day 5-6) | woodshed 26 / 23 / 23 | no | — |
| Keeping sanity | Facing nights, tidying, pastimes, blessing | Never explained early | yes | **no**: 2 of 100 by day 7 | under 40 on 2 / 51 / 58 of 400 days | no | PLAY-02, PLAY-03 |
| Death and recovery | — | Health 0 | — | **yes** (cave, both devices) | — | indoors only | PLAY-01 |
| 03:00 collapse | — | The clock | — | n/t (probe: ok) | — | no | PLAY-13 |

### Farm and trade

| Milestone | Needs | Unlocked by | Obtainable | Blind play | Sim | Blocked | Findings |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Plant and water | Seeds, bucket | Guide | yes | **yes** | yes | no | — |
| Ch. 4 first harvest | A ripe crop (about 7 watered nights) | Time | yes | **no** (week ended day 8; ch. 3 also in front of it) | 10 / 10 / 11 | no | PLAY-09 (ordering) |
| Ch. 5 Farming 2, second field | Farming XP | Level | yes | no | 6 / 6 / 6 (level), ch. 10-11 | no | — |
| Ch. 6 ten harvests | Seeds | — | yes | no | 11 / 15 / 13 | no | PLAY-08 |
| First sale at the stand | Anything to sell | The stand | yes | **yes** (forage, day 3) | yes | no | — |
| Ch. 7 five sales | — | — | yes | sold 5+, chapter waits behind 3-6 | 11 / 15 / 13 | no | — |
| Buying seeds | Coins, the desk's Catalog | Never introduced | yes | **yes, only when sent there** (day 8) | yes | no | PLAY-08 |
| Ch. 8 a pumpkin | Farming 3, pumpkin seeds (reward of ch. 5) | — | yes | no | 21 / 22 / 22 | no | — |
| Well repaired, hose | Materials, Carpentry 2 | Well panel | yes | no | 5 / 5 / 5 | no | — |
| Coop, hens, eggs | Step 3; hens from the catalog | Buildings | yes | no | coop 7; hens 16-18 | no | — |
| Root cellar | Coins, materials | House, Storage | yes | no | 20 / 20 / 18 | no | — |
| Smokehouse, firewood store | Workshop placed | Buildings | yes | no | 26 / 23 / 23 | no | — |
| Furnace, bars | Copper ore, wood | Buildings | yes | no | 36 / 35 / 35; copper bar 42 / 35 / 42; iron bar 50 / 57 / 57 | no | — |
| Barn, goats, milk | Step 10 | Buildings | yes | no | 79-80 | no | — |
| All crops | Seeds from the catalog, seasons | Farming levels | yes | no | 9 of 11 grown (leek, strawberry not tried by the sim) | no | — |
| All 31 recipes | Crops, forage, named fish, eggs, milk, flour | Cooking | yes (every ingredient has a source) | no | 9 cooked; 15 never makeable by the sim's diet | no | — |
| First tax bill paid | Coins, the desk's Tax tab | Day 93, a letter | yes | no | 93 / 93 / 93 | no | PLAY-16 |

### House and homestead

| Milestone | Needs | Unlocked by | Obtainable | Blind play | Sim | Blocked | Findings |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Stage 1 Boarded | 3 wood, 2 fiber | — | yes | **yes** | 1 | no | — |
| Stage 2 Patched | 5 wood, 4 fiber, Carpentry 3 | Mending gives Carpentry | yes | no (Carpentry 3 not reached in a week) | 13 / 13 / 13 | no | — |
| Stage 3 Restored (ch. 10) | 8 wood, 6 fiber, Carpentry 8, **Summer** | — | yes | no | 245 / 245 / 245 | by season only | PLAY-14 |
| Ch. 9 Clear the Stain | Cleaning 3, 2 crops, **a lost sanity limit** | House, Home | only after a collapse or a lost night | no | **398** / 96 / 93 | **yes, for a careful player** | **PLAY-04** |
| Furniture (6) | Coins, hardwood, bars, feathers; house stage | Buildings, Furnishing | yes | no | 28-249, all six in every mode | no | — |
| Cellar room | 700 coins, 60 stone, 20 hardwood, 20 copper bars | Stage 2 | yes | no | 141 / 185 / 181 | no | — |
| Covered porch | 1200 coins, 60 wood, 40 hardwood, 40 copper bars | Stage 2 | yes, slowly | no | **— in 400 days** | no (cost) | — |
| Second storey | Porch first; 3000 coins and more | Stage 3 | yes, slowly | no | **—** | no (cost) | — |
| Land deed | 12,000 coins in 500s | The clerk's letter (day 14) | yes, slowly | no | 10,000 of 12,000 by day 400 (engaged) | no (cost) | — |
| All 14 homestead steps | See the chart | — | yes | 1 of 14 | 14 of 14 (bell on 396) | no | — |

### Light, tools and gear

| Milestone | Needs | Obtainable | Blind play | Sim | Blocked | Findings |
| --- | --- | --- | --- | --- | --- | --- |
| Lantern tier 1 Tin | 4 wood, 3 fiber, Bushcrafting 2 | yes | **yes** | 1 | no | — |
| Lantern tier 2 Brass | 4 wood, 4 fiber, 2 resin, Bushcrafting 4 | yes | no | 7 | no | — |
| Lantern tier 3 Hollow | 6 wood, 6 fiber, 4 resin, Bushcrafting 6 | yes | no | 19 / 19 / 16 | no | — |
| Crude hatchet | 2 sticks, 2 fiber | yes | **yes** (day 1) | 1 | no | — |
| Stone, copper, iron hatchet | Stone; bars, Smithing 2 / 5 | yes | no | 1 / 36 / 52-59 | no | — |
| Stone pick | 2 wood, 3 stone, Mining 1 | yes | no (never told one is needed) | 1 | no | PLAY-17 |
| Copper, iron pick | Bars, Smithing 2 / 5 | yes | no | 36 / 52-59 | no | — |
| Willow rod | 2 sticks, 2 fiber, **Fishing 2** | yes (the bare pole fishes) | no | never made by the sim | no | PLAY-12 |
| Copper nozzle, spray head | Bars, Smithing 3 / 6 | yes | no | 43 / 106-113 | no | — |
| First weapon (sharpened stick) | 2 wood, 1 fiber, Bushcrafting 2 | yes | **yes** (day 8, when sent to Craft) | n/t by the sim | no | PLAY-17 |
| Knife, copper and iron swords, armour, shields | Resin; bars and Smithing 2-6; hardwood | yes (materials and levels all reached) | no | materials reached; the sim crafts no gear | no | — |
| Bags (Satchel, Haversack, Backpack) | 40 / 120 / 300 coins and fiber, wood | yes | no | never bought by the sim | no | — |

### Exploration and combat

| Milestone | Needs | Obtainable | Blind play | Sim | Blocked | Findings |
| --- | --- | --- | --- | --- | --- | --- |
| Cave entered | Walk to the west edge (tip on day 4) | yes | **yes** (day 5) | — | no | — |
| Agnes's page 8 (the cave) | First cave visit | yes | **yes** | never (the sim does not walk in) | no | — |
| First creature killed | A weapon | yes | **yes** (day 8: a lizard and a bat, then died) | n/t | no | PLAY-17 |
| Ore mined | A pick; Mining 2 for copper | yes | no | copper 15, iron 37 | no | — |
| Ch. 3 To the Wood's Edge (first trek) | Lantern, day 4, before 15:00 | yes | **yes, on the 6th attempt** (day 4, sanity 67); 5 failures, the last at sanity 4 | 4-5 | no; fragile at low sanity | PLAY-09, PLAY-02 |
| Mill, orchard, chapel, post routes | Day 14+, Bushcrafting, oil, rations | yes | no | 23-28 / 161-198 / 245-252 / 336 | no | — |
| Trail works (9) | Coins, materials | yes | no | 8 of 9 (post lamps never) | no | — |
| Pages from the wood (5) | Hollow trees on routes | yes | no | 43-254, all five | no | — |
| The grove | Bell hung; day 397 | yes | no | 399 / — / 399 | no | — |

### Story

| Milestone | Needs | Blind play | Sim (eng / ign / early) | Blocked | Findings |
| --- | --- | --- | --- | --- | --- |
| Agnes's pages 1-10 | Things the player does anyway | 4 of 10 in the first week, a fifth on day 9 | 9 / 8 / 8 of 10 (p3 needs a figure faced; p8 the cave) | no | — |
| Night visitors, all kinds | Nights lived | first, knock, field, crows, pond (slept through) | all met; footsteps only when awake | no | PLAY-02 |
| Friendship, hearts to 10, scenes | Walks, words, gifts, requests | none | all four walkers to 10 by day 78-394 | no | — |
| Ch. 11 the letter shown | Day 240; talk to a walker | no | 240 / 244 | no | — |
| Ch. 12 the water rises | An orchard trek from day 265 | no | **closed by the bell (397)** / 275 / 386 | no | — |
| Ch. 13 his knock | 4 nights after ch. 12, from day 285 | no | closed by the bell in all three | no | — |
| Ch. 14 the meeting | Day 300-357 | no | 358 / 358 / 302 | no | — |
| Ch. 15 Davy's night | Ch. 12's beat, day 370 | no | **never** / 371 / 388 | **yes, if the bell comes first** | **PLAY-05** |
| Ch. 16 the bell | Four parts; All Hallows of year 2 (day 396) | no | bell hung 396 in all; chapter **never** / 397 / 397 | behind ch. 15 | PLAY-05 |
| Ch. 17 the grove | The grove trek | no | **never** / — / 400 | behind ch. 15 | PLAY-05 |
| Ending: The Line Under the Rooks | The Hollow left at the door 3 times from day 240 | no | — / 285 / 288 | no | — |
| Ending: The Hollow Sleeps | Bell + grove | no | — / 408 (420-day run) / 399 | no | — |
| Ending: Two Came Home | Grove by night, meeting won, last scenes, five wood pages | no | 399 / — / — | no | — |

## Reading the map

- **Connected:** the systems do join into one game. Materials feed tools, tools feed the homestead, the homestead feeds
  coins and the story's bell, the walkers feed the second year, and every ending is reachable (in simulation).
- **Weakest joins, in order:** the first week's sanity and first trek (PLAY-02, PLAY-09); coins to seeds (PLAY-08);
  chapters 9 and 15 (PLAY-04, PLAY-05).
- **Proved by play:** the first eight days' worth: start, first session, survival basics, the farm loop up to ripening,
  repair to Boarded, trade, the first trek, the cave, combat and death. Everything after day 8 is simulation or existing tests.
