# ART-002: 16 px vs 32 px per tile (non-production experiment)

Status: for owner and ChatGPT review. Nothing in the game, `DESIGN.md` or production art changed.

## What was tested

- The five ART-001 PixelLab assets (Douglas fir, twisted oak, mossy boulder, fallen log, forest-floor tile) were generated again at twice the pixel dimensions: the same prompts, seeds, settings and forced palette. Files and IDs: `art/style_tests/pixellab/x32/`.
- `tools/pixellab_compare.gd set=density` lays both sets on the farm under the game's own grade and day/night tint. The 32 px art is drawn at half size, so each object covers exactly the same ground as its 16 px twin. The 16 px grid, camera, movement and collisions are untouched.
- Captures were taken at 1280x720 (the game's base canvas) and in a 1924x1061 window (this monitor's maximum, about 1080p), at 12:00 and 21:30, in a clean checkout of `2d0c2e5`.
- Review sheets: `review/density_in_game.png`, `review/density_closeup.png` and `review/ART-002_master.png`.

**Caveat:** the generator draws a new design at each size. Some differences come from the model rolling different art, not from pixel density: the 32 px log lies flat and the 16 px one diagonally, the 32 px fir is bluer, and the 32 px log has a stray grey streak. Judge the detail, not the individual designs.

## Advantages of 32 px

- **More detail in the same footprint.** The oak's bark, root flare and leaf clumps, the fir's branch tiers, and the boulder's moss and cracks all read more clearly in the close-ups.
- **Smoother curves and silhouettes,** which help organic folk-horror shapes such as twisted trunks, roots and hanging moss.
- **Little code change for most art.** The farm draws its sprites with `draw_texture_rect` into tile rects (48 calls), so a 32 px texture would scale into the same rect without code changes.

## Limitations of 32 px

- **It doesn't land on whole screen pixels.** The game's 1280x720 canvas puts a 16 px tile on 48 screen pixels. A 32 px tile then gets 1.5 screen px per art pixel, so nearest-neighbour filtering draws alternating 1 and 2 px columns and rows. This is visible as shimmer and uneven outlines, especially when the camera moves (stills can't show the motion). It's clean only at 2560x1440 (3 px per art pixel) or 3840x2160 (4.5 px, uneven again). (At 1920x1080, today's 16 px art is already 4.5 px per art pixel and uneven too; 32 px makes it 2.25.)
- **Fine detail mostly disappears at actual game scale.** In the 1280x720 shots the 32 px set reads as slightly softer and busier rather than clearly better. Most of the gain shows only in enlarged close-ups.
- **No help at night.** At 21:30 both sets fade equally. Readability at night comes from outlines and values, not pixel count.
- **Ground repetition gets worse.** The 32 px tile repeats its leaf in a visible grid every tile. Larger tiles need more variants to hide repetition.
- **It contradicts the locked style.** `DESIGN.md` says "Chunky 16px pixel art" and "one art pixel is always three screen pixels". Thinner 1 art-px outlines at 32 px are half as thick on screen, which weakens the bold dark-outline look.
- **Higher cost per asset.** The pixel count is four times higher, so there is more to clean by hand, and some tools charge by size (PixelLab Pro tiers and v3 animation are priced by canvas).

## Estimated migration work if 32 px became the standard

A rough estimate, assuming the 16 px gameplay grid stays and only the art density changes.

| Area | Work |
| --- | --- |
| Display scale | Decide how 32 px art lands on whole pixels: a 2560x1440 base or an integer-scaled viewport, or accept 1.5x. A camera zoom change would alter how much of the farm is visible, which is a gameplay change. Needs its own test. |
| Farm and building art (`art/farm/`, 76 PNGs) | Regenerate every one, then review and clean up. The biggest job. |
| Player sheets (`art/player/`, 56 PNGs) | Regenerate the farmer's idles, walks and every tool action at 32x64 per frame, and re-cut the frames. Animation consistency is the hardest part. |
| UI (`art/ui/`, 40 PNGs) | Optional. The UI is drawn as 9-slices and could stay as it is. |
| Code-drawn fallbacks (`scripts/farm_art.gd`, about 920 lines) | Either redraw at 32 px or accept that fallback art looks coarser than the sprites. |
| Code | Small for rect-drawn sprites. Frame sizes for sheets, `FarmSprites` lookups, the dual-grid ground atlas (16 px frames), the minimap and capture tools need checking. |
| Docs and tooling | Rewrite the locked art-style section of `DESIGN.md`, update `CLAUDE.md`'s sprite rules and the review tools' assumptions. Owner approval required. |

## Recommendation (for review, not a decision)

Keep 16 px as the standard for now. The in-game gain at the game's real display scale is small, and it comes with uneven pixel scaling, thinner outlines and a full art redo. Mixing densities (32 px only for a few hero props) doesn't avoid the problem: at the 1280x720 canvas any 32 px art lands on 1.5 px. If more detail is still wanted, the prerequisite is a separate test of a 2560x1440 base canvas (32 px art at exactly 3x, 16 px art at 6x), since that decides whether 32 px can ever be pixel-clean.
