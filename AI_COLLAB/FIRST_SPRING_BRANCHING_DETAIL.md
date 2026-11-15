# CCH-SPRING-BRANCH-001 — First Spring: The Neighbor

**Planning date:** 2026-11-14. **Status:** Narrative and world design **only**. No approval to implement code, new town, dialogue, sprites, branches or change canon.
**Parent references:** `YEAR_ONE_BRANCHING_NARRATIVE_DESIGN.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `FIRST_AUTUMN_BRANCHING_DETAIL.md`, `FIRST_WINTER_BRANCHING_DETAIL.md`, `LOWMERE_FIRST_DISTRICT_DESIGN.md`, `LOWMERE_RESIDENTS_DESIGN.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`.

## Creative promise

Autumn: 'What kind of life will you build?' Winter: 'When life gets difficult, what matters most?' Spring: **'What kind of neighbor will you become?'**

The village of **Wicker Cove** should become a real inhabited place, not a supernatural attraction or quest vending machine. The player may visit because they need supplies, have products to sell, enjoy building things, or want to know more about the people who knew the Rooks. The place is useful regardless of which curiosity they pursue.

**Owner-mandated editorial voice:** literary depth in plain language; concise, rooted in ordinary details, meaningful subtext, no overwritten supernatural explanation or prescribed player emotions. A character is a worker and neighbor before they are a lore dispenser.

## Source-grounded timeline and build limits
- Day1 = October1. First spring is **March1–May31**. Existing March1 **Spring Thaw** lasts 2 days and gives watered crops an extra growth stage. Existing April20 **Planting Fair** gives 5 turnip seeds; it does **not** imply a playable town festival already exists. Keep exact game effects.
- Existing orchard route threshold from day152 / March1; preserve its actual walker, trek, status and story conditions. Do not redirect existing route destinations to the proposed village.
- Day240 (~May28), existing parish clerk E. Pell's letter arrives by the farm mailbox, addressed to the tenant at Rook's farm; this happens even when player never visits Wicker Cove. It is **late spring** on actual calendar. Its fixed text, the 31-to-4 historic vote and existing response scenes cannot be retconned by this side arc.
- Current game day ~420 real seconds. 'Nearly an hour walking down the road' from literary voice sample **is not a committed game travel duration**. First visit and return should still leave an evening; menus pause time as designed. Implement in a short connected scene transition, not a one-hour real-time trek.
- Wicker Cove is **not yet implemented** in the reviewed game code. This is a design proposal dependent on `CCH-LOWMERE-001` compact playable district, `CCH-ORDERS-001` tested home dispatch, economic audit, and one or two original NPC interactions; no immediate coding authorization.
- Wicker Cove is fogbound **24/7, all seasons**, regardless of inland weather. Memory and documentation of fog's historical start contradict and **remain unresolved**; do not let hidden d20, evidence collection, special weather or ending 'solve' or remove it.
- Candidate names Edith Vale (inn), Thomas Bellweather (store), Martha Fenwick (fish market), Gideon Pike (boat) are tentative and should not all be introduced as feature-complete NPCs in first slice. At most **two new speaking residents** initially.
- Main `StoryAct` and `FolkSystem` scenes remain source of truth for Maren/Davy/vicar/postman, 17 chapters and the three endings. No core chapter is gated by town reputation, first-visit approach, a side choice or a random skill check.

## Five spring beats

### S0 — March1 onward: 'The Thaw' (shared)
**Existing mechanic:** the 2-day Spring Thaw growth bonus is unchanged. Farm shows brighter leaves, garden soil and different produce availability.
**Player-specific response:** recall actual winter work or supplies if state was recorded. A player who stocked the pantry may have more planting freedom; someone who spent reserves needs to rebuild. Neither is judged.
**Gameplay:** spring planting, recipes, optional visits with existing walkers, prior year preparations, orchard treks. Opening spring activity remains worthwhile even if Wicker Cove's map is not ready.

### S1 — March, 'A Reason to Go Downhill' (first village invitation)
**Proposed hooks**, any one sufficient, with never a forced 'role' selection:
- **Supplier:** player accepts a reasonable food/produce order at existing farm stand/mailbox; delivery may be completed at home or, later, in Wicker Cove. Town has practical supply/payoff.
- **Craftsperson:** an available small repair notice mentions old inn boards or harbor shop shelves; player may seek a quote, not instantly commit.
- **Curious stranger:** an old receipt or resident name from known farm pages prompts an optional visit; travel **not** locked to story evidence.
- **Ordinary visitor:** player simply wants salt, rope, specialty supplies or a look at the harbor, with basic trading available to all.
**Access rule:** One real route to Wicker Cove, unlocked by simple geographical access/verified implementation milestones rather than friendship points, moral route, quest-gated mystery or large farm upgrade. Optional arrival introductions vary only if provenance is actually saved.

### S2 — First arrival, 'The Third Step'
**Proposed scene (short, interruptible; not canonical dialogue):**
> The road bent downhill. You heard gulls before you saw the water.
>
> The first houses stood close together. Beyond them, the harbor disappeared into fog.
>
> A man was working a net outside a shed. He watched you pass.
>
> 'You from up the hill?'
>
> 'The Rook place.'
>
> He paused.
>
> 'Ah.'
>
> He went back to the net.
>
> 'Mind the steps by the fish market. Third one's rotten.'

**Editorial nuance:** The workman's pause implies recognition without declaring hostility, knowledge, supernatural conspiracy or universal town consensus. The player should not be required to select a canned spoken response; short dialogue can describe introduction and then return control.
**Town first-visit proof:** one useful general store interaction, one reachable order or sale, one working resident exchange, visible inn/market/dock anchors, clear route home. Avoid 15-minute cutscene and never close town immediately because player won't discuss the Hollow.
**Proposed reaction variants:** if player arrives holding contract, shopkeeper comments on actual delivery; if seeking repairs, innkeeper points out a damaged beam; if asking about records, one resident directs to public ledgers/another worker. Background street stays identical. No made-up inference about why player came.

### S3 — April20, 'The Work of Spring'
**Existing event:** Planting Fair provides **five turnip seeds**. If an eventual town gathering is designed, it must be optional, light and not be required to earn original event reward; 'Planting Fair' does not currently establish a rendered Wicker Cove fair.
**Proposed cross-system choice:** limited time/materials: invest in more farm production, accept first village order/repair quote, or pursue an optional personal errand. All choices cost actual game resources/time and offer different future advantages. Free time and resources are not unlimited; no universal max-reputation route.
**Social response:** resident sees player as reliable seller, capable worker or someone willing to listen; no class label or universal reputation number.
**Diary:** only if real transactions/approaches were made; no automatic 'the villagers trust me' claim.

### S4 — Early May, 'Two Accounts' (optional quiet fog mystery)
**Premise:** one resident recalls that you could once see a headland from the harbor steps. A ledger or another person indicates that the fog was always thick enough to hide it. No fixed true version.
**Options:** hear more from the witness, look at a dated document, ask a second resident, or move on without choosing a side. These are available with ordinary civil conversation, not hidden high-Charisma gates. None conclusively resolve the fog.
**Optional uncertainty roll** may allow reading a damaged date on a chart/receipt; success only produces better *legible text*, never a guaranteed truthful answer. Failure can yield an uncertain date or another source to consult, not lock all clues.
**Diary:** 'The old fisherman says he saw the headland. The shop ledger says otherwise. I have both stories, and no reason yet to call either true.' Never refer to objectively impossible history, author-graded belief, or an origin revealed by a nat20.
**Callback:** a resident notices player read the ledger or references a chart later, then returns to work. Humanizing details prioritized over escalating dramatic stings.

### S5 — May28 day240, 'The Town Writes' (fixed story spine)
**Canon:** E. Pell's letter and the player's existing chapter/progression still arrive in the farm mailbox whether the village was visited or not. Current story already connects the Rook farm to town governance and bell vote.
**Optional perspective, not new plot rule:** If player has visited Cove, they may recognize the clerk's name or have heard ordinary residents discuss old meetings; if not, letter remains comprehensible. Dialogue callbacks happen *after* the fixed letter and only conditionally.
**Next season:** the player enters summer with unique opportunities based on actual supplies, relationships and discoveries, while `maren_book`, `vicar_register` and later events remain required as already authored.

## Three playthrough trajectories (same town, different meaning)
| Path texture | First meaningful exchange | Later April/May callback | Economic/story safeguard |
| --- | --- | --- | --- |
| **Supplier** | Deliver produce; merchant asks where it was grown | order offer reflects prior delivery; existing prices/payments apply | No town travel required for all deliveries, no infinite premium |
| **Craftsperson** | Get honest quote for inn floor/market shelf | owner acknowledges returned materials/work; future first repair when implemented | Player can still buy/sell regardless of repair choice |
| **Curious stranger** | Speak about Rooks, listen to two conflicting accounts | one later line about a ledger or witness; diary reflects actual questions | No required fog explanation, no blocked original chapter |
| **Ordinary visitor** | Buy goods, observe harbor, go home | town remains accessible, mild recognition if talked | Does not lose content or get labeled antisocial |

These are **player approaches**, never a locked role; all paths can be mixed on subsequent trips.

## Sample dialogue with distinct practical voices (not approved names/canon)
**Innkeeper (if player inquires about repairs):**
> 'Room upstairs has a leak. I put a bucket under it, then another. The roof doesn't care how many buckets I own.'
**Player options:** 'I could look at it.' / 'What would you pay for the work?' / 'Not today.' All reasonable.
**Shopkeeper (if player brings produce):**
> 'Fresh greens. That's been a while. You grow these yourself?'
**Player options:** 'Up at Rook's farm.' / 'I can bring more next week.' / 'Just here to sell what I have.' Do not gate sale on choosing warmth.
**Dockside resident, fog testimony:**
> 'My father swore he could see the far point from here. Martha says her father said the same and he was a liar. What am I supposed to do with that?'
**Response:** 'What did your father see?' / 'Is there anything written down?' / 'I don't know.' None tagged correct.

## One seasonal decision with three distant echoes (vertical storytelling)
**First arrival — what the player actually chooses to do:** deliver / inquire repair / learn account / ordinary trade. No forced dialogue option picker.
- **Immediate:** useful interaction and simple recognition.
- **Within spring:** one remembered line or small work offer tied to real prior activity.
- **Summer:** if relevant feature later exists, connected merchant/inn commission; otherwise ordinary resident line with no fake unlock.
- **Second-year town-letter reaction:** when applicable, one conditional side line distinguishes 'I've met these people' from 'I know the town only through letters' without altering the fixed E. Pell letter, votes or endings.
- **Diary:** a single factual note plus optional follow-up when earned. Not a generated sweeping personality profile.

## What not to build
- No reputation 'Good Farmer / Bad Farmer' meter.
- No full festival in April just because Planting Fair exists as a dated buff.
- No mandatory completion of a Wicker Cove quest before accessible trade.
- No four-NPC simultaneous launch, vast indoor town, multi-day trip, ocean map or ship system for the first encounter.
- No reinterpretation that village fog was caused by Agnes, the bell or the Hollow.
- No forgotten original Maren/Davy/vicar/postman roles or altered original vote chronology.
- No player emotions assigned by the narrator or long dialogue that prevents meaningful daily choices.

## Implementation/design dependency and priorities (not approval)
- **CCH-SPRING-BRANCH-001 — P1 DESIGN (this file):** season beat structure and first-town player approaches, fixed story/calendar safeguards.
- **CCH-SPRING-BRANCH-002 — P1 DESIGN AUDIT:** verify travel scene transitions, story letter/diary integration, prices and actual NPC/dialogue choices against current code; choose one tiny first-visit hook (supplier OR ordinary visitor) with one later callback.
- **CCH-SPRING-BRANCH-003 — P2 candidate:** one functional town visit supporting both a trade and one optional dialogue response using `CCH-LOWMERE-001`, not a duplicate town story implementation.
- **CCH-SPRING-FOG-001 — P2 IDEA:** two conflicting testimonies + one optional ledger note that preserve uncertain fog chronology.
- **CCH-SPRING-LETTER-001 — P2 IDEA:** one noninvasive, optional side reaction to May28 town letter, never replacing original event flags.
- **CCH-SPRING-DIARY-001 — P2 IDEA:** at most one or two truthfully player-specific spring memories and summer callback.
- **CCH-SPRING-BRANCH-QA-001 — P1 eventual QA:** ordinary visitor, trader, craftsperson, investigator, no-town-visit save; March1 crop bonus, April20 seeds, May28 letter, existing ending-path eligibility, game-day travel, controller/UI, return home, save/load, fog permanent and legible.

**Success test:** Four players can reach the same harbor street and leave with four different reasons to return; each one experiences a useful town, real human interaction and a later truthful acknowledgment. Player can skip the village and still reach the existing Rook story. No code has been changed by this planning file.
