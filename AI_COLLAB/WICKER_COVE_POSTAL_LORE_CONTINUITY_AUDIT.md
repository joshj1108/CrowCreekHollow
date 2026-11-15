# CCH-LORE-NAME-001 — Wicker Cove / Old Lowmere Runtime Postal-Lore Audit

**2026-11-14. Status:** PARTIAL SOURCE AUDIT + OWNER-DECISION BRIEF, **not** an approved retcon or code edit.
**Reason:** The official in-world fishing-village name is **Wicker Cove**, down the mountain road from Crow Creek Hollow, under permanent fog. Most design prose was renamed on November 14; existing runtime `scripts/folk_system.gd` still has at least three explicit old Lowmere mentions that carry narrative facts.

## What actual runtime source says (directly verified)
Existing `FolkSystem.SCENES.post` includes:
1. `post_round` — postman describes Agnes receiving letters from **Lowmere**, calls it *'over the hills'* and *'Old place. Old women.'* Agnes wrote there weekly during her last winter and received replies; postman claims he never read them.
2. `post_crate` — bell iron arrived on his round in a heavy crate **from Lowmere**, broke cart axle; card indicated the bell wants ringing by someone who stays.
3. `post_dead` — postman retains a **bill from Lowmere**, plus Rook catalogs; reports unstamped mysterious letters appearing in sack.
4. `post_hand` — postman recognizes a letter to Agnes as in **player's handwriting**, via previous tax slips; **preserve exact reveal order and text/flag**.
Original scenes `maren_book`, `vicar_register`, `davy_turn`, `post_hand` remain locked ending requirements. The work here must not overwrite scene IDs, heart/day requirements, evidence or dialogue order.

**Important:** GitHub indexed `search` returned **no matches** for even these verified script words, so it is not reliable for exhaustive ref enumeration. This audit only verifies directly fetched `scripts/folk_system.gd` and named design sources. A *complete runtime-text audit* later must programmatically scan the checked-out repository, localization files, content data, NPC lines, generated documentation and project resources, preserving historical commit logs.

## Confirmed owner world direction
- Wicker Cove is the only official village in this role; older Lowmere **design names/IDs/filenames do not imply a second town**.
- Wicker Cove is a modest, deteriorating **coastal fishing village downhill along winding mountain road**; dense fog all day/year; testimony and records about fog onset contradict. Unknown real cause or onset.
- The farm is the last inhabited homestead before wilderness paths; named postman delivers to farm; the mill is original Rook vote location.
- Existing postal source/history **must be preserved unless owner deliberately chooses a retcon**; the bell's iron source, letters from old women and other mysteries are not disposable set dressing.

## Three lore-safe reconciliation options (none approved yet)

### Option A — Recommended: the old mail source is Wicker Cove, reached by a road that goes over a ridge then descends
Interpret old 'over the hills' as conversational description of travel rather than a firm statement that village lies inland/high above farm. Wicker Cove was Agnes's letter correspondent, source of bell iron and bill. Edit only old proper-name tokens and **the explicit geographical phrase** in narrative when code update is separately approved, e.g.:
- Old place reference: 'Wicker Cove's down past the ridge. Old place. Old women.'
- Agnes letters still went there weekly and replies returned in unusual script.
- Heavy iron still arrived **from Wicker Cove**. Broken axle unchanged; card unchanged.
- Old bill still came from Wicker Cove.
**Strength:** one town, preserves all existing mysterious postal facts and owner geography, minimal art/system changes.
**Risk:** Why a declining fishing village supplied bell iron, and what 'old women' mean, remains **deliberately open**. Neither is proof of fog cause or local supernatural society. An old trading connection or re-shipping harbor is *one plausible interpretation* but **do not canonize** it without owner instruction.

### Option B — Maintain 'over the hills' but draw road crossing high saddle before descent
Wicker Cove can be both downhill overall and beyond hills. A mountain ridge intervenes, so original wording stays except official name. However, first-visit road staging and map geography must make ridge/road plausible, which adds mild world layout constraints.
**Strength:** fewer dialogue edits, same letters/bell source.
**Risk:** players might picture an inland town rather than the coast unless scripts elsewhere clarify.

### Option C — Historical 'Lowmere' as deprecated postal district/place-name, now Wicker Cove
Old crate/bills used former name but current village renamed. This would be a **new in-world historical fact** and risks making the user-approved clean town rename into new lore. Could work as an archival nickname, but conflicts with previous instruction not to treat old design name as a separate town; needs explicit owner approval and more support in diaries/ledgers.
**Recommendation:** avoid unless user specifically wants a historical double name.

**Do not choose** a fourth option that silently invents a second town, deletes the correspondence, makes the fog origin explicit, or changes the ending requirements.

## Minimal future change set (only after owner's choice)
1. Preserve `post_round/post_crate/post_dead/post_hand` IDs, scene order, emotional beats, gift hooks and flags.
2. Replace only the old proper names and any one conflicting geographical phrase; don't rewrite the content of letter or bell-card mystery.
3. Inspect exact adjacent dialogue `maren_hens`, `maren_hands`, `maren_book`, `vicar_register`, `StoryAct.LETTER` and `StoryAct.SHOWN` for any implication altered by new geography.
4. Run repository-wide raw-text search before edit because remote indexed search proved empty even on confirmed matches.
5. Confirm maps/route sign wording Wicker Cove, official name in HUD/quest/diary, road direction and lake/ocean continuity.
6. Keep old `CCH-LOWMERE-*` task IDs and `LOWMERE_*` design files stable unless deliberate future migration; don't break cross-doc links.
7. Regression: old saves with `seen.post_round` etc, replay of unlocked scenes, no double rewards, original three endings, first-town entry, fog remains ambiguous.

## Human narrative recommendation
The old letters from the village and the bell iron are powerful **shared social history**. Rather than explain who the old women were immediately, let Edith/Thomas (if approved later) treat postal archives as mundane working records. A shop receipt might mention weight/date; a resident may disagree about whether that delivery was ordinary. A rare optional contradiction can deepen uncertainty **without confirming the origin of the fog or the bell**. Existing postman's handwriting twist still belongs to his original final scene and must not be spoiled.

## Pending owner approval
**Suggested reconciliation: Option A**, using Wicker Cove as the same place while preserving all events, letters, crate and bill, and clarifying the downhill ridge road in the postman's one geographical line. This is **a recommendation, not canon**. An implementation proposal can be prepared later; no script changed now.

## Tasks
- `CCH-LORE-NAME-001` — P1 source audit/owner geography choice (partially audited).
- `CCH-LORE-NAME-002` — P1 runtime scan + selective patch after owner's explicit choice.
- `CCH-LORE-NAME-QA-001` — P1 old saves/story scenes/3 endings + first Wicker Cove visit/ledger check.
