# ART-005 S1: farmhouse simplification and restoration redesign (design and feasibility only)

Answers the owner's direction and ChatGPT's H1 review (board, `4fc3500`). Zero generations, no credits. Nothing in the game changed: gameplay, saves, production art, collision, lighting, camera and `DESIGN.md` are untouched. M0, M1, H1, VIS-002 and every existing asset are preserved (the new files live in `art/style_tests/ART-005/pl/g4/`).

Tags: **[Measured]** = computed from pixels or code; **[Judgement]** = my visual or design opinion.

## 1. The current geometry, and what makes it heavy

M0 and H1 share one blockout (`tools/art005_m0.py`): a 384 x 320 sprite (12 x 10 tiles at 32 px), a **hipped** roof from the ridge (y 12-20, x 64-320) to the eave (y 160), hips on both ends, walls y 160-298, a footprint of 11 x 7 tiles (roof rows 5-9, walls 10-11, door at column 24, the porch row 12).

- **[Measured]** The slate covers **45%** of M0's silhouette (47,516 of 104,740 px); everything above the eave is 52%. The roof is 160 px tall over a 138 px wall (1.16 : 1).
- **[Judgement]** The roof is the largest single surface in the frame, and its three planes are a lot of tiling with nothing to look at. The hips are what failed in H1 (pale panel grids), and they are the hardest part for any generator to keep consistent across four stages.

## 2. Two simpler mockups (zero generation, non-production)

`tools/art005_s1.py` keeps **every facade pixel of M0** (y >= 160: walls, posts, foundation, windows, door, lamp, steps, copied byte for byte, day and night) and replaces only the roof. Materials come from the same frozen G1 board c1 as M0, so the comparison is about **shape, not texture**.

| | SA: side gable, low roof | SB: side gable + front gable |
|---|---|---|
| Roof | one ridge east-west, no hips; ridge cap y 50-56 (M0: 12-20) with a sliver of the far slope; thin rake boards at the gable ends | SA plus one centred front gable over the door, 6.25 tiles wide at its eaves, apex at y 60, board-and-batten face, one attic window (centre 192, 115) |
| Slate share of the silhouette [Measured] | **40%** (37,740 px, -21% vs M0) | **33%** (31,924 px, -33% vs M0) |
| Roof height : wall [Measured] | 139 : 138 (1.01), chimney included | same |
| Fits the 720p camera [Measured] | whole roof in frame | whole roof in frame (M0/H1's roof top is cut at 720p) |
| Fixed | canvas, facade, door, both window centres (`HOUSE_SPRITE_WINDOWS`), foundation, steps, footprint and collision, chimney position (moved 4 px) | same |

The roof still covers the footprint's roof rows from y 74, so nothing about the house's map tiles or collision would change.

**[Judgement]**
- **SA** is cleaner than M0 and loses the hip problem completely, but it reads as a long, flat lid: correct, plain, and still mostly roof.
- **SB** is the better house. The front gable centres the composition over the door, splits the slate into two smaller fields, adds a second material (vertical boards) above the eave, and gives a **lit attic window at night**, the only house so far with an upper light. It is the classic farmhouse silhouette and still simple: one main ridge, one gable, no hips, no dormers.
- Neither is premium art. The slate texture is M0's placeholder treatment. These sheets judge silhouette, proportion and focal balance only.

Recommendation: **SB**, with SA kept as the fallback if the front gable proves hard to keep consistent across stages.

## 3. Matched in-engine comparison

`tools/art005_density.gd` gained `art=g4 var=sa|sb` (the same loader path as g2/g3; other modes are unchanged, and the G/H frames re-captured with it are byte-identical to the H1 package). It uses the same scene, camera, lights and window-light positions for all four houses, day 12:00 and night 21:30.

- `ART-005S1_master.png`: 1080p integer framing, day and night, M0 | H1 | SA | SB (sheets at 58%).
- `ART-005S1_master_2.png`: the game's own 720p zoom (tile 48 px), day and night (74%).
- `ART-005S1_master_3.png`: the sprites at 2x and 1:1, silhouettes, and the measured roof share (62%).
- Panels and `s1_metrics.json` are in `art/style_tests/ART-005/pl/g4/review/`.
- Not captured: dusk, rain and fog, and a trek. The change is to the house only.

## 4. Restoration-stage matrix (for SB; SA is the same without the gable row)

The game already has four stages: `STAGE_NAMES` = Decrepit, Boarded, Patched, Restored (`main.gd:227`). The owner's names map to them one to one.

**Fixed at every stage:** the canvas (384 x 320), the outline silhouette (ridge, rakes, front gable, eaves, chimney), the footprint and collision, the door opening and the two window openings and their centres, the attic window opening, the foundation course, the steps' footprint, the lamp bracket position, the light direction (upper left) and the palette ramps.

| Element | 0 Dilapidated (Decrepit) | 1 Stabilized (Boarded) | 2 Repaired (Patched) | 3 Restored |
|---|---|---|---|---|
| Main roof | missing slates in 2-3 large holes showing dark battens, slipped courses, heavy moss | holes covered by tarred-plank and canvas patches, moss remains | mostly new slate, 1-2 older patches visible, little moss | complete, even weathered slate, clean ridge |
| Front gable | boards split and missing, a dark gap, bargeboard sagging at one end | gap boarded across | boards replaced, bargeboard straight | painted bargeboard, finished face |
| Attic window | broken and dark | boarded | glazed, unlit | glazed, lit at night |
| Chimney | top courses broken, no cap | same, cap stone set | repointed | sound, with a smoke wisp (animation is optional) |
| Siding | grey, split and missing boards, stains | split boards nailed back, a few new planks | most boards replaced, two tones of wood | even weathered timber; the outside paint applies here |
| Ground-floor windows | cracked panes, one gone | both boarded | reglazed, plain | shutters or flower boxes |
| Door | hanging, gap at the top | reinforced with a cross brace | rehung, plain | finished door, lamp lit (the existing `porch_light`) |
| Steps | cracked, one tread missing | a plank laid over the gap | rebuilt in stone | swept, maybe a pot at the side |
| Ground dressing (separate overlay) | weeds, rubble, a fallen board | rubble cleared, weeds remain | trimmed grass | flower bed, path edge |

Each stage changes **condition, not structure**. In production terms: four complete sprites (or one base and region overlays) on the same alpha, plus a night variant of each. The production house is currently drawn at `main.gd:2599`, one texture per `house_stage`, so swapping the art changes no code path.

One technical note for later: the outside paint (`estate._paint_tint()`) currently modulates the **whole** house sprite (`main.gd:2599`), roof and stone included. With restored art, paint should tint the siding only. That needs a separate siding mask layer, a small drawing change I'm not making now.

## 5. Audit of the porch and second-storey upgrades

Both live in `EstateSystem.EXTENSIONS` (`scripts/estate_system.gd:15-25`) with the cellar room, which is unrelated and stays.

| | Covered porch (`porch`) | Second storey (`second_storey`) |
|---|---|---|
| Unlock | house Patched (stage 2) | house Restored (stage 3), **after the porch** (`"after"`) |
| Cost | 1,200 coins, 60 wood, 40 hardwood, 40 copper bars, Carpentry 6 | 3,000 coins, 100 wood, 80 hardwood, 60 stone, 60 copper, 20 iron, 60 crow feathers, Carpentry 8 |
| Effect | stand demand x1.25 (`PORCH_DEMAND`), +2 sanity each morning (`PORCH_SANITY`) | +6 sanity per sleep (`STOREY_SLEEP`), night loss x0.9 (`STOREY_NIGHT_MULT`) |
| Drawing | a deck and copper roof on posts in the porch row (`_draw_outside`, `estate_system.gd:364-377`) | a dormer gable with two yellow windows on the roof (`estate_system.gd:350-363`) |

### Every dependency [Measured, by grep]

- **Save:**
  - `estate.built` is saved as a list of ids (`estate_system.gd:81`, `save_system.gd:106`) and loaded at `save_system.gd:212`.
  - `_from_save` **silently drops any id not in `EXTENSIONS`** (`estate_system.gd:93-95`). So deleting an entry would quietly delete the player's purchase, its effect and its property value on the next load. **This is the main hazard.**
- **Costs and progression:**
  - `_why` and `_build` (`estate_system.gd:133-160`) pay the cost and grant Carpentry XP (`XP_REPAIR * 2`).
  - The second storey requires the porch.
- **Effects:**
  - porch → `stall_system.gd:23, 63` (demand) and `estate._morning()` (`estate_system.gd:273-278`, called from `main.gd:5889`).
  - second storey → `sanity_system.gd:30` (sleep) and `night_system.gd:921` (night loss).
- **Economy:**
  - Each extension adds 15% to the property value (`desk_system.gd:233`), and the breakdown text shows the count (`desk_system.gd:244`).
  - `DESIGN.md:964` quotes "about 950 with all three".
- **Achievement:**
  - `ACH_EXTENDED` "Under a New Roof" (`achievement_system.gd:83`, `steam_achievements.csv:53`).
  - Its goal is `EstateSystem.EXTENSIONS.size()` (`achievement_system.gd:185`) and its value is `estate.built.size()` (`:261`).
  - Removing an entry changes the goal for everyone.
- **UI:**
  - the Buildings → House → Extensions tab (`panel_rows.gd:645-668`), the `ext:` action (`main.gd:3283`), and the note about property value.
  - `tools/menu_test.gd` has no case aimed at this tab; it would need one if rows are hidden (option B).
- **Drawing:** `_draw_outside`, called from the sprite path (`main.gd:2600`) and the code-drawn fallback (`main.gd:1659`); `house_roof_drawn_stage = -1` forces a redraw.
- **Collision and interaction:** **none**.
  - The extensions are drawn only. No tile, collision shape, door or interaction depends on them.
  - The porch row's boards (`Tile.PORCH`, `PORCH_RECT`) and the door lamp (`porch_light`, stage 3) belong to the base house and are independent.
- **Lighting:** none. The dormer windows are painted yellow, with no light.
- **Tools:**
  - `balance_sim.gd:705` (feathers reserved for the storey), `:710-720` and `:760` (purchase planner).
  - `save_test.gd:304-326` (round-trip with porch built, storey not).
  - `capture.gd:121` (`estate` option builds all three).
- **Docs:** `DESIGN.md` lines 55, 237, 244 (sim target: storey on day 481), 299, 581-584 and 964.

## 6. Retiring the upgrades without breaking saves

Whatever is chosen: **keep the ids `porch` and `second_storey` in `EXTENSIONS`**, so `_from_save` never drops a purchase, and keep `ACH_EXTENDED` earnable (a Steam achievement can't be cleanly removed once published, only reworded).

| Option | What changes | Existing owners | Risk |
|---|---|---|---|
| **A. Re-dress, keep the gameplay (recommended)** | Same ids, costs, effects, unlock order, property value and achievement. Only the picture and the wording change: "Covered porch" becomes porch furnishings drawn inside the fixed porch row (bench, rocker, lamp hooks; no roof, no posts past the eave). "Second storey" becomes "Attic rooms": no dormer; the SB attic window becomes the visible sign (lit at night when built). | Nothing lost; their purchase now shows as the new dressing. | Lowest: no save, balance or achievement change. `_draw_outside` and the two `about` strings change. SA has no attic window, so A works best with SB. |
| B. Withdraw from sale, keep for owners | The two rows are hidden from the Extensions tab for players who don't own them; owners keep the effects (grandfathered). The achievement goal becomes a fixed constant, and its text changes to the cellar room alone or to something new. | Keep everything. | Balance shift for new games: lose the stand x1.25, +2/+6 sanity, x0.9 night. The year-2 coin sink disappears, so `balance_sim` targets and `DESIGN.md:237-244` need a rerun. Two code paths for the same id. |
| C. Remove and refund | On load, owners get the cost back (coins and materials), the ids are cleared, and the effects end. | Refunded, but they lose sanity and stand bonuses mid-save. | Highest: property tax, sim, achievement goal and save tests all change. An earned achievement stays, but others can't get it unless reworded. Not recommended. |

If B or C is ever chosen, its gameplay value (late-game sanity, the stand bonus, a year-2 coin sink) should move somewhere else first, for example to furniture or the attic rooms.

## 7. SpriteCook, PixelLab, or both

- **PixelLab [Judgement, from E2-PL, H1]:**
  - Strong at material quality (H1's siding, windows and door were the best yet) and held the openings within 0-1 px when given a value pass.
  - It failed on a **large repeated roof surface and the hips**, and it drifted in the porch row.
  - SB removes the hips and a third of the slate. The H1 failure doesn't predict a failure here.
  - `edit_image` with a reference and an **inpaint** limited to a mask is the right tool for deriving stages from one master. The alpha stays fixed by construction.
  - A Pro edit costs about 25 generations.
- **SpriteCook [Judgement]:**
  - `pixel-engine-image-v1` produces at most 128 px, so it can't make the 384 x 320 house in one image.
  - It suits small matched kit pieces in one strip of cells:
    - boarded-window covers, roof patches, broken and new slates, a flower box, shutters, weeds and rubble.
    - These are exactly the per-stage **damage and dressing overlays**, and its earlier 16 px farm art was consistent in that role.
  - Note: the SpriteCook plugin currently needs re-authorising (`/mcp`) before it can be used.
- **Recommended combination:**
  - We own the geometry (the SB label map, fixed).
  - PixelLab makes **one** stage-3 master over SB's value pass.
  - Stages 2, 1 and 0 are derived from that master by masked edits (roof, windows, gable, siding regions only) or by hand over the master, using a small SpriteCook kit of damage and dressing pieces.
  - Every stage keeps the master's alpha. That's the consistency guarantee the owner is after.

## 8. Recommended next experiment (after the owner picks SA or SB)

1. **S2a, zero credits:** a material pass on the chosen roof (break up the slate field; 2-3 large weathering patches) and quick **stage 0 and stage 3** overlay mockups over the same alpha, to prove the matrix reads at 720p before anything is generated.
2. **S2b, one paid step, only if S2a reads well:**
   - one PixelLab Pro `edit_image` of the **stage-3** house over the SB value pass, about 25 generations.
   - The same stop rule as H1: geometry drift beyond 1 px, a repetitive roof grid, or alpha breaks → record it and stop.
   - No stage variants are generated in this step.
3. Only after that is reviewed: the SpriteCook damage kit (one strip) and the masked derivations of stages 2, 1 and 0.

## Files

- New: `tools/art005_s1.py` and `tools/art005_s1_review.py` (non-production).
- New: `art/style_tests/ART-005/pl/g4/` (`sa/`, `sb/`: `32/house_day.png`, `32/house_night.png`, `labels_roof.png`, `blockout.png`; `review/`).
- Changed: `tools/art005_density.gd` (added `art=g4 var=`; the other modes are unchanged).
- Raw harness frames are in `builds/review/ART-005/s1/` (gitignored).
