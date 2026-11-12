# CCH-CONSOLIDATED-003 — Farmhouse, HUD, Player, Combat, Cave Creatures, Mail & Debug Tools

The owner's brief, 2026-11-11, recorded here so each phase's session can read it. The owner authorized implementation, pixel-art creation (PixelLab, within the existing subscription; no new paid charges), animation, scene integration and supporting code. The owner asked that the phases run one after another in fresh sessions **without stopping for approval between phases**; visual acceptance comes at the end. `DESIGN.md`, `CLAUDE.md` and the art style lock still come first. Rustic Gothic — Balanced UI; existing approved pixel-art style.

**Goal:** one coherent, playable update, not disconnected art upgrades.

## Working rules for every phase

- Start with a short audit of the phase's area (assets being replaced, systems referencing them, sprite scales/frames/perspective, save risks). Then implement; don't stop at a proposal.
- Order: A HUD + debug menu → B mail to the outdoor mailbox → C farmhouse furniture, clipping and layout → D farmer and all player animations → E cave creatures → F integration, performance, final review package.
- One commit per phase (plus a "Board: … package links" commit), **always pushed** to `origin main`. Leave the owner's unrelated uncommitted work out (e.g. the sunset experiment in `scripts/main.gd` / `shaders/grade.gdshader`, `.import`/`.uid`/`project.godot`/`scenes/main.tscn` noise): stage only your own hunks (build the file from HEAD plus your edits and `git update-index --cacheinfo` it if needed).
- A phase is complete only when assets are integrated, states work, gameplay still works, automated checks pass, in-engine screenshots confirm it, known limits are recorded and it's committed. Record blockers honestly; never claim blocked work is done. Don't declare new art final: the owner accepts it.
- Preserve mechanics, balance, progression, prices, unlock conditions, hitboxes, timings and saves. Existing saves must load; migrate rather than discard. Never test in save slots 1-3.
- Track every generated asset and credit in the existing records (`pixellab-assets.json` / `spritecook-assets.json`). Reuse references; reject wrong perspective or anatomy before animating.
- Per phase update `AI_COLLAB/MESSAGE_BOARD.md`, `AI_COLLAB/TASKS.md` (row CCH-CONSOLIDATED-003), `DESIGN.md`. Follow `AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md` (BEFORE/AFTER captures via `tools/capture.gd`, sheets, GIFs via `tools/review_motion.ps1`, a `<TASK>_master.png` ≤2048 px), saved under `art/style_tests/CCH-003/`.
- Don't restart main-menu animation work or redesign approved systems outside this scope. Don't change the approved outdoor Balanced Night Lighting.

## Phase A — HUD and developer tools (DONE, `d1a8b57`)

No numbers beside any survival bar (Health, Sanity top-left; Hunger, Thirst, Comfort top-right; no headings); developer-only debug panel for time, date, temperature, weather, pause, revert, with overrides not saved. See `DESIGN.md` → Test builds and `scripts/debug_menu.gd`.

## Phase B — Mail to the outdoor mailbox

- Remove the red desk notification light entirely: the light, its blinking, emission, indicator and obsolete code. No replacement light in the house. The desk stays as a desk if it has another purpose.
- Audit every reference to the mail interaction, then move all normal mail handling to the mailbox near the farm entrance and market stand: receiving, reading, unread state, attachments/rewards, quest/progression letters. Preserve exactly; don't reset read/unread or lose pending rewards (old saves must keep them).
- Mailbox is a recognizable interactable with the existing interaction control and a contextual prompt like other farm interactions; reading reuses the existing UI architecture.
- New mail indicator: prefer a physical raised flag (or envelope in the slot), subtle, no glowing alert; returns to rest when everything is read/collected.
- New mailbox sprite (PixelLab): handcrafted, rustic, weathered dark metal body, sturdy wooden post, small brass/iron details, muted-rust flag, hinged door; distinct silhouette, slightly more prominent than before but same scale and perspective as other props; not oversized. Keep it near the gate and stall (small position tweaks OK): interactable from a clear adjacent tile, not hidden by the stall, not blocking the path, correct Y-sort and collision, readable by season and at night.
- Brief animations where useful: flag up/down, lid opening, short interaction.
- Tests: mail migration and unread state, desk no longer handles mail, flag state. Review: old vs new mailbox, beside the stall, flag up/down, closed, prompt, day and night.

## Phase C — Farmhouse furniture, clipping audit and layout

- Replace **all** legacy furniture art still in the farmhouse (beds, desks, tables, chairs, washstands, cabinets, dressers, armchairs, bookshelves, clocks, storage, cooler props, others; audit the real inventory). Generate as one coordinated family (PixelLab) matching the FARMHOUSE-INTERIOR-001 art: same perspective, pixel density, palette, light direction, wood rendering, shadows, outline weight, proportions. Keep each object's purpose and purchase/upgrade conditions; update placement, interaction and collision for new sizes.
- Mandatory clipping audit in every restoration stage and reachable camera position: cut-off sprites, bad atlas regions, wrong origins/offsets, transparency bounds, clipping parents, Y-sort, rendering behind/through walls, overlaps, display size, tile alignment. Fix causes, not with bigger sprites or arbitrary offsets. Nothing accidentally cut off.
- Layout: the bed is wrongly placed with a gap behind the headboard; put its headboard against the wall, clear access, correct interaction and sleep. Review every piece: logical, reachable, supported, facing usefully, believable walkways; seating grouped around the hearth and rug; bed, bedside, storage, window, curtains as one bedroom; practical areas make sense.
- Keep the four stages (Decrepit, Boarded, Patched, Restored); make Restored feel like a lived-in home with restrained detail (pottery, books, folded fabric, cushions, firewood, mantel pieces, wall ornaments, containers, textiles). Never grant unpurchased furniture; built-in decor may follow the stage. Prices and requirements unchanged.
- Fireplace stays the heart: masonry integrated, firebox framed, flames inside, logs and embers, firelight reaching furniture, dark when unlit. Every lit candle has a visible flame matching its light. Check night corners. Preserve windows' seasonal/weather/curtain/frost/fog/shutter/boarded behaviour.
- Tests: furniture collision and reachability, sprite frame validity; run `tools/interior_test.gd`. Review masters: every new furniture asset (native, enlarged, old vs new), all four stages, bed, hearth, sleeping, practical area, collision/paths, clipping before/after with a list of issues found and fixed.

## Phase D — Farmer redesign and all player animations

- New rustic-modern farmer: weathered baseball cap (preferred), practical work jacket or flannel, earth-tone jeans/pants, work boots, leather belt, modest utility details. Capable, grounded, a little weathered. Avoid cowboy hats, medieval armour, ornate clothes, anime proportions, big heads, urban or loud colours. Inspect current player size, tile size, collision, enemies, furniture and tools first; keep the world scale (don't enlarge to add detail).
- Canonical reference sheet first, then every animation from it. Replace every existing state in every supported direction: idle, walk, run (if any), tool use, farming, gathering, mining, chopping, digging, watering, harvesting, interacting, hurt, attack, block, death (if any), others. Clean silhouettes, stable heads, believable feet and hands, correct tool alignment, no popping, consistent timing, no missing frames. No old frames mixed in.
- Lantern: when active and not using a tool/weapon, carried in one hand, swinging slightly, light from its position, facing-correct, not clipping. During tool use and attack/block it moves to the hip/belt; light stays on and follows. Quick hand↔belt transition where practical, never delaying actions. The actual light source follows the visible lantern. Don't change lantern upgrades, radius or lighting balance. No lantern shown when inactive/daytime per current rules.
- Combat: audit every weapon type and attack; rebuild attacks (grip, wind-up, strike, recovery, directions) and a distinct directional block set. Preserve damage, timings, hitboxes, block effectiveness, stamina, i-frames; animation synced to real hit/block windows.
- Tests: animation state transitions, lantern hand/belt attachment, weapon blocking; verify all directions, transitions, interruptions, no stuck states or floating weapons. Review: old vs new farmer, directions, walking, scale beside house/furniture/cave; lantern hand/belt, tools, night, upgrades; attacks, blocking, recovery, hits, with gameplay GIFs.

## Phase E — Cave creatures

- Audit every existing cave creature and its animation needs; don't invent new enemies. Make them believable cave inhabitants: natural anatomy, rough hides, fungal/mineral staining, plausible limbs, cave-adapted muted colours, silhouettes readable by lantern. Avoid purple crystals, glowing eyes, neon, cartoon monsters, big heads. Keep each one's role and scale; hostile vs harmless stays clear.
- Per creature: idle, move, alert, attack, hurt, death, other existing states, in supported directions. Match hitboxes, collision, speed, telegraphs, attack windows, aggro, pathing, drops, spawns, save state. No difficulty or AI changes.
- Check readability in cave darkness, with basic and upgraded lantern, attack effects and cave light. Tests: creature attack-state behaviour. Review: old vs new, native size, each state, in the cave.

## Phase F — Integration, performance, final package

- Cross-check HUD/world state, mail and quests (old mail survives load, desk light gone), every interior stage and furniture item, player outdoors/indoors/cave/combat/lantern, every creature.
- Benchmark (capture `perf`): farm day, farm night, restored house with all candles and fire, seasonal weather, cave combat with lantern, several enemies; report frame times vs before.
- Run every test tool in `tools/` (menu, layout, save, diary, wheel, interior, debug_menu, plus new ones).
- Final masters 1-11 per the brief: HUD; mailbox and entrance; furniture; layout and restoration; clipping audit; farmer design; lantern and tools; combat; cave creatures; debug menu; final consistency (farm day/night, entrance, restored and decrepit interior, cave exploration and combat, seasons). GIFs: walking with lantern, hand→belt, tool use, attacks, blocking, creature attack and death, mailbox and flag, fireplace and candles, seasonal window, debug weather/time change. All from the running game.
- Then stop for the owner's visual acceptance.

## Non-negotiables (all true before calling the update complete)

No numbers beside survival bars; working debug menu; mail at the outdoor mailbox; red desk light gone; distinct new mailbox art; legacy furniture replaced; clipping audited and fixed; sensible placement with the bed against the wall; cozy restored house; consistent new farmer; all player animations replaced; lantern in hand while moving, on the belt for tools and combat, light following it; complete attack and synced block animations; cohesive new cave creatures; progression, collisions and saves intact; game playable and coherent.
