# Legacy house tiles (archived for VIS-001)

These five 64×64 tiles are `house_door`, `house_roof_bottom`, `house_roof_top`, `house_wall` and `porch`. They were cut from the 32 px tileset sheet on 2026-10-24, before the SpriteCook art pass.

The SpriteCook sprites `art/farm/house_stage_0..3.png` replaced them, and nothing in the game loads them. They were moved here from `art/farm/` on 2026-11-01, as owner decision D-006 (`AI_COLLAB/DECISIONS.md`) says: archive them, don't delete them.

The `.gdignore` file keeps Godot from importing or exporting this folder. To use a tile again, move it back under `art/farm/` and import it.
