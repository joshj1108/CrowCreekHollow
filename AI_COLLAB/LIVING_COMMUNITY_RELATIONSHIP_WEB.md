# CCH-SOCIAL-WEB-001 — Living Community, Relationships and Indirect Consequences

**2026-11-14. Status:** design-only. Broad owner encouragement to develop narrative further, **not** authorization to edit existing scripts, finalize tentative residents, add mechanics or retcon lore.
**Foundations:** `CHARACTER_LIVES_AND_RELATIONSHIPS_DESIGN.md`, `NARRATIVE_VOICE_AND_LITERARY_STANDARDS.md`, `LOWMERE_RESIDENTS_DESIGN.md`, `CHOICE_CONSEQUENCE_SYSTEM_DESIGN.md`, `FIRST_AUTUMN_BRANCHING_DETAIL.md` through `FIRST_SEPTEMBER_BRANCHING_DETAIL.md`, `YEAR_TWO_COST_OF_STAYING_DESIGN.md`.

## Creative thesis
A community is not a row of NPCs waiting for gifts. It is a collection of people doing needed work, carrying private histories, holding imperfect views of one another, and occasionally remembering what the farmer did. The player can help, work for pay, keep to themselves, listen or disagree. Nothing is an invisible "good farmer" test.

**Five rules:**
1. NPCs have credible weekly work and modest personal goals unrelated to the player.
2. One person's choices affect another person through **plausible contact** (sale, family, shared work, neighbor conversation, delivery), never psychic reputation.
3. Relationships are not always reciprocal: warmth, trust, reliance, respect, debt and fear may differ.
4. When player ignores a problem, someone else may improvise, delay, or fail to solve it. The world isn't frozen waiting.
5. Surprising kindness, humor, embarrassment and ordinary inconvenience are as important as tragedy.

## Existing canon relational anchors (source-checked against scripts)
- **Maren ↔ Ruth:** Maren lives at last cottage down lane; her **sister Ruth** keeps mill and minute book. Maren voted down bell and remembers that night; her window lamp remains lit. Ruth has existing mentions and requests; **not yet verified as a separate in-world visiting NPC**.
- **Davy ↔ Mrs Tull and grandfather:** mother is explicitly in `StoryAct` and `FolkSystem`; grandfather worked orchard for Elias; Davy wants Pip back. He also reads old history through his grandfather. Do not invent a named mother, father, age or family tragedy.
- **Vicar ↔ parish families:** chapel services, food donations, register, hand scars and retained clapper; complicity and responsibility coexist. His existing evidence scene is fixed.
- **Postman ↔ households:** 30 years on rural route, letters for Rooks, unusually conscientious delivery and original `post_hand` twist. Never disclose twist early.
- **Maren/vicar/postman ↔ mill vote:** each remembers facts, has different personal stakes; `maren_book` and `vicar_register` remain necessary for successful re-vote.
- **Wicker Cove:** official fogbound harbor downhill; contradictory fog-history accounts, no objective onset or causal answer. Proposed named residents do not yet exist in active game.

## Relational web: 10 connected pairs, with player access and safe consequences

| Pair | Ordinary dependence / friction | One short human scene | Player involvement | Far echo |
| --- | --- | --- | --- | --- |
| Maren–Ruth | sisters, one moves through lane, one keeps the mill/records; different ways of dealing with old vote | Ruth sends food/brief note, Maren jokes about Ruth's bookkeeping | fulfill an **existing** request or listen | Maren remembers actual work; book scene unchanged |
| Davy–Mrs Tull | child's curiosity vs parent's concern | mother asks where he's been; Davy returns to his stone skipping | give information respectfully or stay out, with source-backed scene | a simple home greeting or silence; day370 rescue not altered |
| Davy–grandfather | orchard memories, grandfather's caution, Pip's absence | grandfather asks Davy to bring in apple wood or leave orchard alone | share ordinary harvest/fruit if supported | Davy uses one real detail in later talk |
| Maren–vicar | shared culpability, different ways of coping | cordial but short conversation about rain and bell cote | witness, listen, change subject | one extra line *after* canonical evidence |
| Vicar–postman | registers names, delivers names, both know the farm's long history | postman leaves service notice, vicar asks after family | deliver food or collect paper, never a second evidence key | one acknowledgment of shared ordinary work |
| Edith–Thomas (candidate) | inn needs stock on credit, store needs actual payment | a list with two price corrections | supply paid goods / side with timeline / decline | one inventory/order reflection |
| Gideon–Martha (candidate) | boat takes risk, fish market needs predictable fresh catch | argument over the hour to return, not the fog's origin | preserve/order/sell fish, optional work | price, spoilage or later trip wording |
| Edith–Martha (candidate) | inn meals need dependable fish, fishmonger needs buyers | Edith sends back one delivery spoiled by delayed cart | provide preserved alternative or quote repair | meal availability or future contract |
| Thomas–Gideon (candidate) | rope/oil/supplies, boat crew's short cash | Thomas holds ordered rope until boat can pay | bridge small work contract rather than donate automatically | later shelf state, boat readiness |
| Farm–Wicker Cove workers | farm sells inland produce/timber, harbor supplies fish/salt/tools | an empty market crate returns with a note | fulfill one actual home-dispatch order | one repeat buyer remembers seller |

**Keep relationship edges sparse in v1.0.** A single exchange between two NPCs that changes later is worth more than thirty simultaneous relationship permutations.

## Three layers of interaction — no artificial omniscience

### Level 1 — Private
A character has a concern the player does not know yet. No diary or dialogue may reveal it from a hidden flag alone. Example: Maren's own lamp reason surfaces through her existing authored scene.

### Level 2 — Local
The player witnesses a conversation, completes a delivery, or hears someone mention a named person. A second character can reference it **only if a plausible communication channel exists** (same household, buyer, post, workplace, first-hand witness). Do not let every NPC comment on a secluded forest choice.

### Level 3 — Durable world response
A repaired shop shelf remains repaired; an inn guestroom can be occupied; a farmer's supply contract affects actual stock; an independent farmer keeps their lumber. Visible state persists across seasonal changes. The world carries memory before dialogue does.

## Proposed three interlocking narrative webs

### Web A — A Lamp, a Book and a Vote (Maren/Ruth/vicar)
**Human issue:** Who is responsible for a mistake shared by people who were frightened?
- At low familiarity, Maren offers practical help and notes Ruth's habits.
- Through **existing** heart scenes, player hears Maren's lamp/hen/bell recollections, then obtains Ruth's **minute book** via `maren_book` according to existing gates.
- Separately vicar's original scenes yield `vicar_register`; his hesitation isn't overridden by friendship with Maren.
- A plausible optional scene can show disagreement over whether talking about the old meeting helps anyone. Neither character is an info terminal.
- **Consequences:** optional short dialogue variants and one personal memory; **no** extra route to win meeting, force the bell, or rewrite original 31-to-4 history.
**Sample (not implemented):** 'Ruth writes the date on everything,' Maren says. 'Even when she's cross with me. Especially then.'

### Web B — A Boy, a Dog and the Orchard (Davy/Mrs Tull/grandfather)
**Human issue:** A child hears that someone must take a turn; adults think they're protecting him by giving incomplete explanations.
- Early pond visit: tiny skipping-stone exchange grounded in already present location and Davy's real behavior.
- Mother needs help with an ordinary household need, **if** reachable; use references rather than spawning an entirely new quest-giver.
- Grandfather has memories of Elias and orchard; he cannot definitively explain the Hollow; no supernaturally authoritative exposition.
- Existing `davy_turn` scene must remain, so optional memories build around it, not duplicate the premise.
- On original **day370+ after orchard** Davy can wait at great tree from 20:00 to 01:00; found/lost outcomes remain unchanged.
- **After:** one absence or return note; don't promise Pip always comes home, and don't presume the boy is dead if he went into wood.
**Sample (not implemented):** 'He was always a bad dog at coming back,' Davy says. 'Not a bad dog at anything else.'

### Web C — The Last Crate on the Harbor Road (Edith/Thomas/Martha/Gideon)
**Human issue:** Four small businesses need one another but cannot all afford improvements.
- Thomas has two useful goods late; Edith needs flour; Martha needs salt; Gideon needs rope or oil.
- The farmer can deliver inland produce, bring **actual** workbench-prepared planks once implemented, barter through a supported merchant system, or keep their products for their farm. No romance/heroism requirement.
- A small choice determines the **order of repairs / contracts**, not a global fate-of-town toggle.
- If player helps Edith first, Thomas and Martha still work and source goods through someone else over time. If player chooses the market, Edith operates with buckets until an opportunity later.
- **Visible change:** ONE repair, ONE functioning order, ONE returning remark. Potential guestroom remains persistent if built.
- The postman can explain that a parcel arrived if actually delivered; never make him reveal the old Lowmere/Wicker Cove bell-source twist early.
**Sample (not implemented):** Thomas: 'I can put your name down for flour. I can't put flour on the shelf until the cart comes.'

## Recurring object motifs — use only when state supports them
- **Maren's lamp:** a light kept through decades, described in existing `maren_lamp`. Never turn it into a supernatural navigation beacon.
- **Davy's skipping stone:** a mundane item/line; its meaning can change with his absence or return. No collectible required.
- **Vicar's scarred hands / black book:** records vs action, without overstating redemption.
- **Postman's satchel:** carrying things is not the same as understanding or acting on them.
- **Edith's bucket:** temporary fixes and paid repairs, possible before/after view.
- **Thomas's shelf:** real goods, not arbitrary 'prosperity percent'.
- **Gideon's net:** mended over days; fishing is skilled work, not an effortless excursion.
- **Martha's salt ledger:** deterioration and preservation; contradiction in written dates needn't mean cosmic truth.
Use 1–2 details per scene, not constant self-conscious symbolic emphasis.

## Relationship consequences without new relationship meters
**Existing:** `FolkSystem` saves `bonus`, `met`, `seen`, `tastes`, `requests`, `requests_done`, `talk_day`, `gift_day`, `visit_day`, `visitor`. Walks contribute existing points; one daily talk per walker; seasonal lines; scene hearts as currently written.

**Future design:**
- Keep FolkSystem hearts for existing four. Do **not** silently attach P2 town NPCs to walker-only schedules/scene IDs; use a small compatible adapter after audit rather than parallel 0–10 hearts invented just for their sake.
- Persist only real choice facts: delivery completed, commission paid, repair complete, character physically met, witnessed testimony, optional interpretation chosen, time/day. One shared event record consumed by dialogue and diary.
- Use a **communication provenance table** for indirect knowledge: `heard_by` and `channel` candidates (witness, household, delivery, workplace). Never infer knowledge from mere hearts.
- Avoid a universal relationship graph simulation or full gossip AI in v1.0. Author specific edges and callbacks (e.g. Edith hears a Thomas delivery because the goods reach her inn).
- Disagreement can remain friendly. Thomas declining credit isn't villainy. Martha insisting on fresh catch isn't hostility toward Gideon. An unrepaired room isn't proof the farmer lacks compassion.

## A complete 4-beat microstory: 'The Cart on a Wet Morning' (future town proof)
**Prerequisites:** home-dispatch orders and a Wicker Cove store/inn exist; Thomas and Edith are approved/implemented or map to same existing merchant functionality.
1. **Ordinary request:** Thomas has a delivery of dry goods due; Edith asks for kitchen basics. Player may sell vegetables at stand, fulfill inn order, help load cart, or decline. Advertise real needs and prices.
2. **Immediate:** goods or work transferred once, paid at fair price or donated explicitly; do not double consume; missing inventory means option disabled with truthful reason.
3. **One-week callback:** if delivered to inn, Edith says who brought it; if sold to store, Thomas stocks shelf; if declined, cart arrives late from another source or item remains unavailable for a time (not permanent). No town-wide reputation.
4. **Seasonal echo:** return basket appears and owner says one specific line; diary mentions actual interaction only.
**No roll:** choosing contract, selling and giving are deterministic. An optional dangerous road repair could use one warned, bounded existing-skill roll, with alternative method.
**Test:** 3 player routes, 1 old-save/no-town route, correct delivered stock and zero duplicate payout.

## A no-town playthrough is a first-class story
If the player has never visited Wicker Cove and ignored optional social requests:
- They can still build, farm, mine, fish, cook, take original walkers, read Agnes's pages, prepare bell and reach original endings on existing conditions.
- No NPC speaks as though they helped the inn or was trusted by a merchant.
- Diary carries enough farm/wood/night specificity to be emotionally satisfying.
- When the town is accessible, basic shopping and revisiting later aren't blocked by an invisible social penalty.

## Priority task map, design only
- `CCH-SOCIAL-WEB-001` **P1 Design**: this authored relationship web, not automated infinite gossip.
- `CCH-SOCIAL-WEB-002` **P1 audit**: existing voices, interactions, checks to preserve existing heart and scene IDs, realistic NPC-to-NPC communication.
- `CCH-SOCIAL-PROVENANCE-001` **P1 design**: minimal event/observer contract for one indirect callback, reuse existing save architecture.
- `CCH-SOCIAL-MAREN-RUTH-001` **P2 gated**: one optional callback to an actual Maren/Ruth exchange (Ruth offscreen until approved).
- `CCH-SOCIAL-DAVY-001` **P2 gated**: pond/skipping-stone moment + year-two absence/return response.
- `CCH-SOCIAL-CART-001` **P2 gated**: one Thomas/Edith two-owner paid request after town+order support.
- `CCH-SOCIAL-HARBOR-001` **P2 gated**: one Gideon/Martha fish and preservation reaction after fishermen/market.
- `CCH-SOCIAL-WEB-QA-001` **P1 eventual QA**: information provenance, skip/defer, one-shot pay/XP, old saves, letter/shown/maren_book/vicar_register/davy_turn/post_hand and three ending accessibility.

**Canon caution:** Source `scripts/folk_system.gd` still uses the old Lowmere label as an over-hills origin of Agnes's letters and bell iron. Do not modify or use that old geography as a Wicker Cove fact pending `CCH-LORE-NAME-001` owner-approved reconciliation.
