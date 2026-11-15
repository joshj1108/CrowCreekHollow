# CCH-RESIDENT-ARCS-002 — Interlocking Two-Year Personal Stories

**2026-11-14. Status: broad narrative design only.** Original walkers are already coded; new Wicker Cove resident names, backgrounds, housing and town events remain **candidate** until owner approval and playable district. No script or story-ending changes authorized.
**Purpose:** Make choices matter in human lives, not just mission state. Eight compact authored arcs show choice → real cost → delayed acknowledgement → modest second-year echo, without a huge combinatorial branch tree.

## Design contract applying to all arcs
- One practical problem and one human relationship at its center. Lead with what character does, not a tragic history.
- At least three viable approaches: direct help, fair trade/another method, defer or decline. The game should not scold independence, sell-first behavior or caution.
- The NPC remains a person: makes their own decisions if ignored, may reject an unreasonable offer, maintains work, and does not exist only to thank the farmer.
- Immediate consequence uses actual materials/items/time/money or a legitimate scene witnessed. **A choice is not completed until its task is done.**
- One callback within 7–30 days and one later seasonal or post-ending trace *only if earned*. Avoid 15 follow-up letters from one favor.
- Optional hidden d20 only for an uncertain technical action (repair/navigation/reading damaged record), not morality, love, relationship consent or original mandatory story.
- Reuse current diaries, one stable saved fact id and existing 0–10 hearts for four walkers. No personality alignment score or city-wide reputation meter.
- **No modification of authored Maren book, vicar register, Davy turn, postman's handwriting reveal, meeting prerequisites, existing 17 chapters or three endings**. Fog remains unresolved.

## Arc A — Maren and Ruth: 'The Lamp in the Window'
**Status:** Existing Maren and offscreen sister Ruth, entirely grounded in currently implemented `FolkSystem` words/requests and original book scene.
**Human issue:** Two sisters preserve evidence differently. Ruth writes things down. Maren keeps a lamp burning and does necessary work.
**Beat 1 / First autumn:** Maren gives practical timber/firewood advice at legitimate eligibility; player accepts, arranges an exchange or works independently. No negative heart penalty for independent repair.
**Beat 2 / Winter:** Ruth's cooking/hen request reaches player via Maren as existing system allows; player fills it for ordinary reward or ignores it. Maren mentions Ruth's habit of remembering exactly who brought what. No magical transmission of a private choice.
**Beat 3 / Spring:** Existing `maren_hands`, `maren_book` sequence continues as authored. Optional conversation after `maren_book` can show how Ruth and Maren differ on bringing old records to the mill, without preventing it.
**Year-two echo:** Maren remembers a real repaired object or actual bargain, *not* generic 'you saved me'. Meeting outcome still exclusively uses `maren_book`+`vicar_register`.
**Distinct endings:** If meeting won, small afterword/farm conversation reflects people taking turns. If lost, a line can acknowledge Maren wished she could convince others; **only** if consistent with existing meeting text.
**Narrative sample:** 'Ruth keeps everything,' Maren said. 'The receipts, the letters, the names of people who still owe her a spoon.' She folded the cloth over the eggs. 'I keep the things she would throw away.'
**Status rule:** Sample is noncanon; never reveal new factual relic or hidden note early.
**QA:** no doubled eggs/request payout, no scene skipping at 2/4/6/8 hearts, Ruth not spawned into world without approved sprite.

## Arc B — Davy, Pip and the Tull family: 'The Best Stone'
**Status:** Davy/Mrs Tull/grandfather/Pip are existing story people; Mrs Tull and grandfather presently mostly referenced, not necessarily playable new NPCs.
**Human issue:** When people are missing, ordinary habits become ways to keep them present. A boy takes adult talk literally.
**Beat 1 / First autumn:** Player meets Davy legitimately after day20 and can share a short pond-side play moment or simply leave him to his day. Three skips/fish subject, no reward.
**Beat 2 / Winter–spring:** Davy asks after Pip or brings an actual pond/forage request using existing request framework. Player fulfills, gives an honest answer, or waits. Do not tell him invented information about Pip or give player a made-up 'guardian role'.
**Beat 3 / Summer:** His original `davy_turn` scene is independent and protected. Optional human exchange may reference a prior completed orchard walk, not disclose a hidden story answer.
**Year-two echo:** During or after **existing** day370 night, prior small memory can color one *separate* line but **can't** change Davy found/lost window (20:00–01:00) or auto-rescue him.
**After outcome:** If found, Davy returns home under existing story rules; if lost, one unoccupied place or quiet note; if he later returns from grove, original story describes him changed. Do not assert he's dead while missing.
**Narrative sample:** 'Pip never liked the deep water,' Davy said. 'He liked it when I went in. But he wouldn't follow.' He found another stone. 'That's different, you know.'
**Player agency:** Even players who never spoke to Davy must have the authored opportunity and ability to find him when original conditions permit.

## Arc C — The vicar and the postman: 'The Names and the Letters'
**Status:** Both existing walkers with independent story revelations; must maintain secrecy.
**Human issue:** Two people keep records. One thinks recording names can answer for inaction; the other delivers the old letters rather than asking about them.
**Beat 1 / First winter:** A routine chapel supply/food request and a routine parcel route intersect. Player may donate requested food, perform a paid delivery or decline; optional dialogue only if actual transaction.
**Beat 2 / Spring:** An unsent card or parish notice can pass between chapel and postman (not the secret Agnes envelopes). They disagree mildly about what should be written down. Do not invent extra witness names or alter the 31-to-4 vote.
**Beat 3 / Summer:** **Existing** `vicar_register` and `post_hand` scenes come through established heart/day flags. New dialogue cannot spill either secret early.
**Second year:** If player met both and actual supply/delivery occurred, one comment on the difficulty of carrying names/letters. Without it, source scenes stand alone.
**Narrative sample:** 'You carry the letters,' the vicar said. 'I carry the names.' The postman tightened the strap on his sack. 'Mine are heavier in the rain.'
**Moral nuance:** They can be conscientious in one part of life and wrong in another. Neither is redeemed by one gift or turned into a cartoon villain.

## Arc D — Edith and Thomas: 'A Room Above the Street'
**Status:** candidate future Wicker Cove pair; work requires approved district and economics.
**Human issue:** Inn must pay for dry rooms and food; store must conserve cash and keep shelves stocked. People can respect each other and still disagree.
**Beat 1 / Spring first visit:** Edith has an upstairs leak; Thomas can source a small quantity of boards and basic supplies at a fair price. Player buys, offers work, asks for paid quote or passes.
**Beat 2 / Summer:** Player chooses priority: use *workbench-hewn planks* on farm, repair one part of inn for pay, or trade materials for useful goods. Edith may source boards later if player skips. Don't demand impossible planks until actual woodworking is implemented.
**Beat 3 / Autumn/winter:** If a room was repaired, Edith asks for one guest brief with **2–3 explicit preferences** (comfortable bed / curtains / lamp / storage), fulfilled through supported furniture placement; otherwise room stays used for storage, with a believable alternate effort from owner.
**Year-two echo:** Thomas notes one actual invoice settled or Edith welcomes a specific guest; visible repaired room persists across save/load. Player can redesign at some cost and keep the room useful.
**Branches:** labor-focused/paid contract; trade-focused/supply and goods; home-focused/decline. All viable.
**Sample:** 'I said I'd get it fixed,' Edith told Thomas. 'I didn't say I'd have the money by Monday.' Thomas looked at the entry. 'Monday was the day you wrote down.'
**Non-negotiable:** no full-town restoration score. Guestroom work doesn't substitute for Rook story evidence. Owners still have lives if player chooses to ignore the inn.

## Arc E — Gideon and Martha: 'The Last Safe Tide'
**Status:** candidate after fish market works; boat journeys later optional stretch.
**Human issue:** A boat working too late risks crew and catch; a market waiting too long cannot sell it fresh. Neither person controls the sea.
**Beat 1 / Spring:** Player observes normal net repair and fish delivery. One useful salt/food/rope contract if stock and inputs actually exist.
**Beat 2 / Summer:** A fishing trip or repair decision: inspect patch / fix quickly / wait for safe weather. A prepared optional technical roll may affect repair time and materials; never a moral check or guaranteed supernatural truth.
**Beat 3 / Autumn:** Martha chooses to sell some catch fresh and preserve some for winter. Player may supply materials, buy affordable fish or fulfill an order.
**Year-two echo:** In winter, fish-market stock and village kitchen needs reflect **real storage upgrade / returned boat**. If nothing improved, Gideon and Martha continue making imperfect decisions; no 'everyone starved because player didn't help' punishment.
**Fog restraint:** Gideon and Martha can remember headland differently without either being objective source of fog onset.
**Sample:** 'You think I'm afraid of a poor catch,' Gideon said. 'I'm afraid of bringing them home in the dark.' Martha closed the ledger. 'Then bring them home sooner. I'll buy smaller fish.'
**Do not** make crew voyage a requirement for farm endings or launch an entire ocean map before the first market works.

## Arc F — Thomas and the valley households: 'On the Cuff'
**Status:** candidate first-town commerce episode, not a banking simulator.
**Human issue:** shopkeeper sometimes extends informal credit, but must keep the shop stocked.
**Beat 1:** Farm supplier asked for modest order. Player sells produce for prompt pay, accepts later payment if explicitly warned, or keeps goods for home.
**Beat 2:** If delayed payment happened, actual ledger entry can become due. Thomas may settle slowly or offer materials at fair exchange. Avoid predatory surprise debt or fake inflation.
**Beat 3:** Neighbor who benefited thanks **Thomas** for buying the goods; only if proper communication path supports it may farmer learn who used them.
**Later:** one shelf shows a type of produce where earlier it was empty. If no contract, trader restocks differently, with less variety.
**Sample:** 'They're not free just because I haven't charged them yet,' Thomas said. 'They still have to come from somewhere.'
**QA:** no infinite coin loop, double paid backorders, involuntary debt or punitive reputation.

## Arc G — Edith and Martha: 'A Meal for Someone Passing Through'
**Status:** candidate town guestroom plus fish-preservation system.
**Human issue:** A guest's meal requires cooperation between market and kitchen; the visitor's own preferences should be respected.
**Beat 1:** Edith needs food suited to a **specific guest**, not generic 'premium decor' points. The player may supply vegetable/fish, suggest a cheaper seasonal alternative, or decline.
**Beat 2:** Martha has fresh/older fish; she can propose preserving what won't sell tonight. Cooking/availability based on actual item kind and season.
**Beat 3:** Guest stays in repaired room; room feedback based on **visible** furniture requirements, not implied quality metric. Edith and Martha can disagree about prices without villains.
**Later:** guest may return or send ordinary note if the room actually served them. Avoid guest automatically appearing if player hasn't built room.
**Sample:** Edith: 'They asked for soup without fish.' Martha: 'Then I suppose you'll need vegetables.' Edith: 'I know a place uphill.'
**Test:** affordable alternate path for player who can't cook advanced recipe, guest content entirely optional.

## Arc H — The farmer and Wicker Cove: 'Nothing Fixed at Once'
**Status:** macro-arc constructed from optional real economic relationships, not a story quest or global town repair score.
**Human issue:** Player cannot single-handedly restore a failing community; people still work and help each other. A small improvement matters because it changes one ordinary life.
**Beat 1:** First optional trade and town visit; a resident recognizes the Rook farm, with no universal hostility.
**Beat 2:** Player prioritizes ONE project: inn, store, fish market or farm. Material choice is real (planks, preserved food, coins/time).
**Beat 3:** An owner returns work with practical benefit: shelf stock, room lodging, stored fish, a repaired trail handrail. All other sites continue in their prior condition or move a little through owner work.
**Year-two echo:** one village resident remembers work and another resident can know through a **verified** delivery or conversation; no world-wide moral scoring.
**Sample:** The inn's upstairs window was lit for the first time since spring. Edith was still sweeping the front steps. There was nothing dramatic about it. A person had somewhere dry to sleep.
**Fog:** remains permanent before and after any ending, economic repair or personal investigation.

## Cross-character consequences: small authored matrix

| Prior fact | Listener who might know | Exact way they learn | Later callback |
| --- | --- | --- | --- |
| Player repaired own roof | Maren only if she directly sees finished condition | farm visit during actual availability | workmanship remark |
| Player fulfilled Ruth's egg request | Maren | she personally accepts delivery | Ruth's reaction in later line |
| Player provided inn vegetables via store | Edith and Thomas | delivery receipt/physical goods | different line at inn/store |
| Player repaired inn window | Edith, guest, Thomas if contracted | witnessed repair/paid invoice | room occupancy + invoice |
| Player helped with boat materials | Gideon, Martha if boat returns with catch | personal supply + delivered fish | market stock/crew response |
| Player kept food for winter | no villager automatically | private household state | farm comfort/diary only |
| Player read two conflicting fog accounts | only witnesses consulted | direct conversation | optional testimony reaction, not world proof |
| Player found Davy at tree | Davy, Mrs Tull from original scene, player | original special night | canonical diary + tiny later response |
| Player never visited town | nobody in town recognizes player | none | ordinary initial meeting, not accusation |

## Production priorities and risk
**First** implement/prove one existing-farm branch with callback. **Second** build satisfying log→plank and basic town orders. **Third** select first two Wicker Cove residents (Edith+one practical store/market worker) and make one interlocked arc work. **Fourth** add second short seasonal echo. **Fifth** extend to Gideon/Martha only if fishing contracts work. A six-year simulated NPC society is not required.

**Candidate task IDs:**
- `CCH-RESIDENT-ARCS-002` P1 Design: this multi-year arc anthology.
- `CCH-RESIDENT-ARCS-AUDIT-002` P1: map each to real existing scenes and calendar gates.
- `CCH-RESIDENT-ARCS-SLICE-002` P1 gated: one choice, one callback, one diary.
- `CCH-COVE-INN-REL-002` P2 gated: Edith+Thomas order/repair/guestroom.
- `CCH-COVE-HARBOR-REL-002` P2 gated: Gideon+Martha supply/timing/preservation.
- `CCH-RESIDENT-ARCS-QA-002` P1 eventual: varied choices, skipping, resource economy, narrator truth, old saves, no-town and all canonical endings.

**No new resident is confirmed as canonical by inclusion here.**
