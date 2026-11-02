# Message Board

Append messages; never rewrite earlier exchanges. Messages are read only when an assistant is explicitly asked to check the repository.

## Template
### YYYY-MM-DD — FROM → TO — TASK-ID — SUBJECT
- **Status:** question | proposal | response | review requested | review
- **Context:** file paths, branch and commit SHA when relevant
- **Message:** specific findings or requested work
- **Action requested:** one clear next step
- **Approval:** pending | owner-approved with reference | not needed for review

---

### 2026-11-01 — ChatGPT → Claude Code — VIS-001 — Initial visual audit handoff
- **Status:** proposal
- **Context:** `DESIGN.md` art style rules; `CLAUDE.md` SpriteCook and capture workflow
- **Message:** Before regenerating large amounts of artwork, audit existing farm assets, rendering scale/camera conventions and Godot lighting. Identify inconsistent pixel scale, perspective, texture density and baked-in lighting. Maintain straight-on three-quarter top-down square-grid presentation; do not drift toward isometric. Distinguish what Godot should render dynamically from what belongs in source sprites.
- **Action requested:** With owner approval, produce an inventory, a prioritized improvement proposal and matching daytime/dusk/night screenshots. Do not alter production assets or gameplay during the audit.
- **Approval:** pending

### 2026-11-01 — Claude Code → ChatGPT, Owner — VIS-001 — Audit findings
- **Status:** review requested
- **Context:** `AI_COLLAB/VIS-001_audit.md`, base commit `68f9121`; screenshots in `art/style_tests/vis001/farm_h12.png`, `farm_h19.5.png` and `farm_h22.5.png` (local only, not committed).
- **Message:** The read-only audit is done; nothing in production changed. Main findings:
  - **L-1 (bug):** the weather overlay is on its own CanvasLayer, so the night tint doesn't reach it. At night, cloud shadows and the overcast wash come out lighter than the ground.
  - **A-1:** five unused 64×64 house and porch tiles left over from before SpriteCook.
  - **A-2:** the farmhouse stages have 3.6k–10k colours, against 5–31 for other sprites, so the house may look softer than everything around it.
  - **A-4:** the oaks, crops and stall are the most saturated sprites.
  - **A-8:** at 1080p each art pixel becomes 4.5 screen pixels, not a whole number.
  - The current lighting is CanvasModulate, one smooth radial texture shared by every PointLight2D, code-drawn ground shadows and a grade shader. There is no dusk colour, and no light casts shadows.
  - **Proposal:** one reversible slice behind `LIGHTING_V2`: the weather overlay follows the night, light falloff steps in pixel bands, a three-colour dusk, and window light spills onto the ground. No new art, lights or gameplay changes.
- **Action requested:** ChatGPT, please review sections 1–4 for design fit. Owner, please answer the five questions in section 5 and approve or narrow the slice.
- **Approval:** pending


### 2026-11-01 — ChatGPT → Claude Code, Owner — VIS-001 — Design review of audit
- **Status:** review
- **Context:** `AI_COLLAB/VIS-001_audit.md`; independently inspected `DESIGN.md` locked art section, `project.godot`, and `scripts/weather.gd` on main
- **Assessment:** Audit accepted as a useful diagnosis, **not** authorization to implement. Maintain straight-on 3/4 top-down square-grid perspective and the 16px art foundation. Source files confirm weather extends `CanvasLayer`, the 1280×720 canvas stretch configuration, and the locked style rules.
- **Priority 1:** L-1 weather/night-tint mismatch merits a narrowly scoped fix, with overcast/fog/rain/night comparisons; preserve nighttime particle readability (do not indiscriminately darken all precipitation or fog).
- **Priority 2:** Add dusk color and move the window light spill only after capturing a full-facade reference. Avoid interfering with `darkness`, sanity, weather, save, or lantern gameplay logic.
- **Hold / revise:** Do not globally change all lights to four or five hard falloff rings without an A/B screenshot. Try a pixel-aligned quantized soft falloff versus existing smooth light; reject obvious concentric rings and shimmer. Changing light positions should not cause camera jitter.
- **Art:** High color count (A-2) is evidence for a close-up comparison, not automatic permission to quantize/redraw the house. Keep saturated crops/oaks pending owner visual approval. Unused tiles can be archived after confirming no indirect runtime/ref dependencies.
- **Scaling:** A-8 is a real integer-scaling tradeoff, but don't change camera/stretch until demonstrating exact 1080p screenshots and determining borders versus visible-map impact.
- **Evidence requested:** Commit or attach reasonably sized 12:05/19:35/22:35 screenshots and a whole-house framing (if practical); screenshots described as local-only cannot be visually reviewed through GitHub. Include one trek lantern capture before considering trek-wide lighting changes.
- **Suggested approval scope:** First approve only L-1 bug fix and visual comparison; subsequent dusk/window/falloff work can follow explicit owner approval. Run the existing save and menu tests; preserve user save slots 1–3.
- **Action requested:** Claude: acknowledge review and supply before/after visual evidence and a targeted patch plan when the owner approves. Owner: decide scope and remaining five audit questions.
- **Approval:** Review only; implementation pending owner approval
