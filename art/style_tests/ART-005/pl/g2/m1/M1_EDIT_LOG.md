# ART-005 M1: anchor_v2 edit log

Source: `pl/anchors/board_c1.png` (G1, frozen; read only, hash unchanged). Output: `anchor_v2.png` (new file), `anchor_v2_diff.png` (changed pixels in magenta), `m1_log.json` (all numbers). Script: `tools/art005_m1.py`, reproducible.

## What was done

Each 32 × 32 swatch was processed on its own, so no colour crosses a swatch border.

| Step | Rule | Pixels changed (board) |
| --- | --- | --- |
| 1 ramp | Merge near-duplicate colours: each swatch keeps 5–9 of its own G1 colours (weighted medoids in Lab, so no colour is invented) | 945 |
| 2 orphan | A pixel whose colour none of its 8 neighbours share takes its neighbours' majority colour | 291 |
| 3 speck | 4-connected clusters under 4 px (smaller than a 2 × 2 mark) join the colour around them. Darkest-tone lines ≥ 3 px are protected: mortar, course and plank seams, outlines | 1,345 |
| 4 manual | 4 rectangles in the window swatch copied back from c1 (below) | 63 |

Board total: **2,231 of 9,216 px changed (24%)**. A pixel can change in more than one step, so the steps add up to more than the total. Orphans **4.76% → 0.03%** (gate ≤ 3%), colours 38 → 31, 100% on the E0 palette before and after.

## Manual edits (step 4)

After one inspection at 5×: step 3 had read deliberate 1 px work in the window as noise.

| # | Swatch | Rect (swatch px) | Action | px | Reason |
| --- | --- | --- | --- | --- | --- |
| 1 | window | x 5–27, y 15–18 | copy from c1 | 26 | The horizontal mullion's lit middle row had been flattened |
| 2 | window | x 18–27, y 5–15 | copy from c1 | 15 | Top-right pane: glint diagonal and corner shading |
| 3 | window | x 5–15, y 18–27 | copy from c1 | 14 | Bottom-left pane: glint diagonal and edge shading |
| 4 | window | x 18–27, y 18–27 | copy from c1 | 8 | Bottom-right pane: glint diagonal |

## Time

- Agent working time, by the session clock: about **5 minutes**, 05:43–05:48 on 2026-11-05. That covers writing the script, two runs, one 5× inspection and choosing the four edits.
- Script run time: 0.2 s.
- An artist's time for the same result was **not measured**. These are scripted, rule-based edits plus four copy-backs, not hand-placed pixels.

## Not changed, and why

- **Mark sizes.** c1's slate courses repeat about every 8 px and its stones every 9–11 px; the spec wants 16 px courses and 10–16 px blocks. anchor_v2 keeps c1's structure, because M1 was asked to consolidate grain, not redraw marks. A 16 px-course slate swatch would have to be redrawn, by an artist or by a generation. M0 builds 16 px courses itself and only takes the face texture from the swatch.
- **Leaf litter on the soil swatch.** The small leaves merged into simpler blobs. They are still readable as accents, so nothing was restored.
- **Water dither.** Partly consolidated, and the flow lines are kept.
