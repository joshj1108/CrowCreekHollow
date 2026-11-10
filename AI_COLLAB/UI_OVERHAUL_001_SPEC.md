# UI-OVERHAUL-001 — UI/UX Overhaul Design Specification v1.0

**Status:** registered 2026-11-09 by the owner. Phase 1 is approved to start in a fresh session once the uncommitted ART-OVERHAUL-002 E2/E3 work (and W-4) is committed. Each later phase needs the owner's go-ahead after the previous phase's review. No credit limit set yet; new art generation needs one.

**Notes for whoever starts Phase 1 (Claude Code, 2026-11-09):**
- The palette below already matches the current UI kit (`DESIGN.md` → "Text colours" and "UI skin").
- `scripts/ui_skin.gd` already draws the SpriteCook wood-and-iron kit as 9-slices (panel, buttons in four states, slot, selected slot, meters, close button) from `art/ui/`. Phase 1 builds on it: move the styling into a central Godot `Theme` resource and add the missing components (tabs, tooltip, scrollbar, notification badge, confirmation dialog, parchment description panel, a focus state distinct from hover), then show the whole set on one prototype menu.
- Run `tools/menu_test.gd` after every panel, tab or button change, and follow `AI_COLLAB/VISUAL_REVIEW_PROTOCOL.md` at the end of each phase.
- The spec names Pixelorama for asset editing; the repo's generators are PixelLab (connected) and SpriteCook (needs `/mcp` sign-in). Record asset IDs as usual.
- One phase per session; stop for review after each.

---

# CROW CREEK HOLLOW
## Official UI/UX Overhaul — Design Specification v1.0

**Project:** Crow Creek Hollow
**Engine:** Godot 4.7
**Target viewport:** 1280 × 720 baseline, adaptable to other resolutions
**Visual identity:** Rustic Gothic Homestead
**Development goal:** Replace placeholder-feeling interfaces with a unified, polished, immersive UI while preserving all existing game systems.

---

## 1. Design Vision

Crow Creek Hollow is a cozy farming game with an underlying sense of unease. Its interface should reinforce that identity rather than resemble a generic fantasy RPG.

Every interface should suggest that the player is handling something tangible from their homestead: a worn journal, a collection of tools, an old ledger, or a weathered wooden case.

The overall feeling should be:

- **Cozy:** Soft warmth, aged paper, natural wood, inviting details.
- **Rustic:** Imperfect handcrafted materials, visible wear, functional simplicity.
- **Eerie:** Deep shadows, subtle mystery, restrained gothic influences.
- **Grounded:** Believable materials, practical equipment, and rural character.
- **Readable:** Clear information hierarchy and responsive controls.

The interface should feel atmospheric without making routine gameplay slower or harder.

### Core design principle

**Every visual element must improve either immersion, clarity, or interaction.** Decoration alone is not enough.

---

## 2. Official Art Direction

### Artistic style

All interface graphics must follow the visual characteristics of the actual Crow Creek Hollow environment artwork.

Requirements:

- Carefully arranged pixel clusters
- Defined silhouettes and dark outlines
- Muted, natural colors
- Consistent directional lighting
- Restrained highlights
- Weathered textures
- Minimal smooth gradients
- No glossy mobile-game appearance
- No mismatched high-resolution illustrations
- No unrelated fantasy ornamentation

Interface artwork should be authored at deliberate native resolutions and displayed with integer scaling where practical.

### Color palette

| Purpose | Color | Hex |
|---|---|---|
| Deep shadow | Near-black brown | `#151009` |
| Panel interior | Charred wood | `#231A12` |
| Weathered leather | Dark chestnut | `#3B2417` |
| Primary wood | Walnut brown | `#6B5340` |
| Warm trim | Muted brass | `#8A6A3A` |
| Parchment | Aged cream | `#C4AE84` |
| Paper edging | Old linen | `#8F7A54` |
| Primary text | Warm ivory | `#E8DCC0` |
| Secondary text | Muted beige | `#9A8A6A` |
| Positive status | Moss green | `#8FB069` |
| Warning | Rust red | `#D0705A` |
| Highlight | Lantern gold | `#D8B050` |

These colors are grounded in the existing `action_bar.gd` definitions. They are a foundation, not a restriction against additional shades needed for sprites.

Avoid creating artificial nighttime darkness inside UI assets. World lighting should not make essential interface text unreadable.

### Typography

Use a maximum of three functional roles:

1. **Display font:** Rustic serif or subtly handwritten lettering for major headings, journal chapters, and decorative labels.
2. **Body font:** Highly readable, pixel-compatible text for descriptions, item details, and diary entries.
3. **Numerical font:** Clear digits for currency, time, quantities, and stats.

Decorative handwriting must never be required to understand important gameplay information.

---

## 3. Heads-Up Display (HUD)

### Design objective

Create an attractive but compact interface that keeps the player's attention on the world.

### Proposed layout

**Top-left: Survival information**

- Health
- Sanity
- Food
- Water
- Warmth
- Diary notification

Health and sanity should be the most visually recognizable elements. Secondary needs should be compact enough not to dominate the screen.

**Top-center: Clock and calendar**

- Current time
- Day and date
- Season
- Weather icon
- Active seasonal event, when appropriate

Use a small weathered-wood or brass-trimmed clock plate.

**Currency**

Display a small coin icon and current balance without requiring an oversized panel.

**Bottom-center: Action bar**

- Equipped tool
- Active item slots
- Selection highlight
- Keyboard or controller prompts where useful
- Remaining quantities or charges

### Visual treatment

The HUD should use thin, carved wooden frames with occasional brass details.

Icon backgrounds should remain subdued. Colors should communicate information, not overwhelm the player.

Health can use restrained red, sanity desaturated blue-violet, warmth soft amber, and other survival needs muted natural colors.

### Interaction behavior

- Important changes should trigger subtle visual feedback.
- Critical needs may pulse gently; avoid aggressive flashing.
- The diary's unread indicator must remain visible.
- HUD elements must not interfere with clicking world objects.
- HUD updates must reflect the same underlying values currently used by the game.

### Success criteria

The player can identify health, sanity, time, and equipped tool at a glance without needing to read small labels.

---

## 4. Shared Menu System

### Design objective

Make every major menu look like part of the same handcrafted interface system.

### Standard layout

All major menus should share:

**Header**

- Section-specific illustrated icon
- Title
- Short descriptive subtitle
- Consistent close/back controls

**Navigation**

- Clearly selected category or tab
- Keyboard and controller navigation
- Mouse hover and selection states
- Consistent tab sizing

**Content region**

- Main inventory or information list
- Supporting detail panel where necessary
- Clear action buttons
- Consistent spacing and typography

**Footer**

- Contextual control instructions
- Action confirmation
- Back or close prompt

### Panel treatments

Use dark wood or leather for structural frames, with lighter parchment-like surfaces for information-heavy content.

Avoid giving every menu a completely different background material.

### Common component library

Create reusable UI elements for:

- Primary button
- Secondary button
- Disabled button
- Active tab
- Inactive tab
- Selected item slot
- Inventory slot
- Progress bar
- Status label
- Tooltip
- Notification badge
- Scrollbar
- Divider
- Confirmation dialog
- Menu panel frame
- Description panel

All components must have consistent normal, hover, pressed, focused, and disabled states as appropriate.

---

## 5. Inventory, Gear, and Crafting

### Inventory

The inventory should resemble a tidy collection of belongings stored in a practical field bag or wooden organizer.

Requirements:

- Clearly defined slots
- Consistent item icon proportions
- Readable stack counts
- Obvious selection state
- Item details displayed without obscuring other slots
- Distinct usable and nonusable item states

### Gear

Equipment slots should follow a restrained silhouette of the character or a practical equipment arrangement.

Avoid overly decorative fantasy armor interfaces.

Show equipment stats, applicable bonuses, and requirements clearly.

### Crafting

Crafting should resemble working from a handwritten workshop ledger.

Recipes should display:

- Resulting item
- Required materials
- Available quantities
- Missing quantities
- Skill requirements
- Crafting action

Missing resources should be immediately recognizable, while remaining readable without color alone.

---

## 6. Diary — Signature Interface

### Design objective

Transform the diary into a believable, interactive field journal that feels important to the story.

This should be one of the game's most memorable interface features.

### Physical appearance

- Worn, dark-brown leather cover
- Aged parchment pages
- Visible center binding
- Small irregularities in paper edges
- Subtle page shadows
- Handwritten-style chapter headings
- Dark, readable body text
- Colored ribbon bookmarks
- Occasional illustrations when narratively appropriate

The book should not be so ornate that it feels magical or disconnected from the homestead.

### Layout

Maintain a two-page spread with clear left and right pages.

Preserve existing first-day instructions, quest chapters, notes, new-page indicators, torn-out pages, and section bookmarks.

### Page-turn animation

Implement a physical page-turn transition:

1. Outer paper edge lifts.
2. Page bends inward.
3. Curl passes across the center binding.
4. Moving shadow follows the curve.
5. Page settles on the opposite side.
6. New content becomes fully visible.

**Initial timing target:** 550–650 milliseconds.

Support forward and reverse page turning.

### Animation implementation

Use the current diary content controls and render the moving page as a temporary visual layer.

A 2D shader or mesh-based page curl is preferred over a large collection of manually generated animation frames.

Keep the underlying diary data independent of the animation.

### Interaction requirements

- Keyboard left/right
- Gamepad navigation
- Mouse page arrows
- Mouse wheel
- Section bookmarks
- Repeated input handling
- Optional immediate completion of an ongoing page turn

Prevent conflicting turns from corrupting the current page index.

### Sound

Use restrained paper rustling, with slightly different sounds for page movement and settling.

Volume should be consistent with the rest of the game's sound effects.

---

## 7. Section Wheel

### Design objective

Make the section wheel an attractive, intuitive access point for major systems.

### Appearance

A compact, weathered circular selector inspired by a handcrafted wooden compass or field tool.

Use:

- Dark wooden central hub
- Individual illustrated section icons
- Brass or aged-metal selection accents
- Clear highlighted segment
- Legible section name

Do not overcrowd the wheel with unnecessary ornamentation.

### Behavior

Preserve all existing menu access and input bindings.

The selected segment should respond immediately to input.

Opening and closing should feel responsive and should not interrupt the player's understanding of current controls.

---

## 8. Quests, Skills, and Achievements

### Quests

Present narrative content like a collection of handwritten assignments or journal records.

Show clear distinctions between active, completed, and unavailable objectives.

### Skills

Use consistent icons for every skill, with readable experience progress and level information.

Skill progression must remain easy to inspect.

### Achievements

Use modest commemorative elements, such as small carved emblems or stamped marks.

Avoid flashy reward screens that clash with the game's atmosphere.

---

## 9. Homestead Management Menus

Apply the shared UI system to:

- House repairs
- Buildings
- Well and water systems
- Coop
- Barn
- Workshop and production
- Desk and catalog
- Property and tax information

These should feel like practical homestead records and project ledgers.

Required information must include costs, ownership, requirements, progress, and available actions.

Never sacrifice clarity to make the menus resemble physical documents.

---

## 10. Transitions and Audio

### Interaction timing

| Interaction | Initial target |
|---|---|
| Standard button response | Immediate |
| Small hover transition | 80–120 ms |
| Menu opening | 150–220 ms |
| Menu closing | 120–180 ms |
| Tab switching | 100–160 ms |
| Diary page turning | 550–650 ms |
| Subtle notification | 200–350 ms |

These are design targets, not established engine measurements.

### Motion rules

Animation should add character without making frequent interactions cumbersome.

Use restrained movement, limited glow, and gentle easing.

Do not add unnecessary movement to every menu element.

Respect reduced-motion preferences if implemented.

### Sound rules

Create a consistent family of quiet tactile sounds:

- Wooden click
- Leather movement
- Paper rustling
- Brass or metal selection tick
- Soft confirmation
- Muted error or unavailable action

Avoid loud UI effects and exaggerated fantasy sounds.

---

## 11. Asset Production Standards

### Native artwork

All assets should be created for Pixelorama editing and Godot integration.

Requirements:

- PNG format
- Transparent backgrounds where appropriate
- Consistent pixel density
- Exact verified export dimensions
- No accidental background glow
- No unrelated decorative particles
- No baked-in scene lighting
- No unintended scaling distortion

### Nine-slice assets

Use Godot nine-patch or StyleBoxTexture techniques for scalable frames, where practical.

This allows frames and buttons to expand without stretching corner ornamentation.

### Recommended asset organization

```text
art/
  ui/
    theme/
    frames/
    buttons/
    icons/
    hud/
    diary/
    wheel/
    inventory/
    effects/
    cursors/
```

Establish an asset manifest recording dimensions, intended display scale, material type, and usage for every approved asset.

### Quality checks

Before accepting any artwork:

1. Compare it against existing Crow Creek Hollow art.
2. Check color consistency.
3. Confirm native pixel dimensions.
4. Confirm transparency.
5. Test its appearance at actual game scale.
6. Inspect readability against gameplay backgrounds.
7. Verify that it works at the baseline viewport.

No asset is approved solely because it looks attractive in isolation.

---

## 12. Technical Architecture

### Preserve existing systems

The overhaul must not change:

- Inventory quantities
- Crafting requirements
- Skill progression
- Quest completion
- Diary content and unread tracking
- Save/load behavior
- Building construction
- Survival calculations
- Input bindings
- Gamepad functionality
- Day/night behavior

### Implementation approach

The current project already uses reusable interface code, particularly:

- `scripts/action_bar.gd`
- `scripts/panel_rows.gd`
- `scripts/main.gd`
- `scripts/section_wheel.gd`
- `scripts/hud_icon.gd`

Retain their gameplay-facing contracts wherever possible.

Introduce shared visual styling through centralized themes, textures, reusable components, and narrowly scoped rendering changes.

Separate presentation logic from gameplay data rather than rewriting the systems together.

### Responsive design

The 1280 × 720 viewport is the baseline.

Test smaller windows and larger displays for clipped text, inaccessible controls, and inconsistent scaling.

Prefer native pixel scaling for artwork, but allow responsive layout and font sizing where required for accessibility.

---

## 13. Implementation Roadmap

### Phase 1 — Establish the UI foundation

- Finalize colors and typography.
- Define icon dimensions and art rules.
- Build common frame and button components.
- Establish Godot theme resources.
- Create one representative menu prototype.

**Acceptance:** A representative screen demonstrates the complete visual language, including focused and disabled states.

### Phase 2 — HUD overhaul

- Rework survival indicators.
- Improve date, time, and weather display.
- Redesign currency and diary notifications.
- Refine action bar styling.
- Verify HUD readability during day and night.

**Acceptance:** All gameplay values remain accurate and immediately readable.

### Phase 3 — Shared menu overhaul

- Apply consistent layouts to inventory, gear, crafting, skills, quests, and other panels.
- Standardize navigation, buttons, tabs, and tooltips.
- Test mouse, keyboard, and gamepad operation.

**Acceptance:** All existing menu actions function without regression.

### Phase 4 — Diary overhaul

- Replace the existing diary frame graphics.
- Refine parchment and text layout.
- Add physical page-turn animation.
- Add page sounds.
- Preserve all chapters, sections, torn pages, and notifications.

**Acceptance:** The diary feels like a physical journal and all original content remains accessible.

### Phase 5 — Section wheel overhaul

- Introduce consistent illustrated icons.
- Replace placeholder visual treatments.
- Refine selection behavior and transitions.
- Validate all existing menu destinations.

**Acceptance:** The wheel remains fast, intuitive, and fully controller-compatible.

### Phase 6 — Final polish and validation

- Refine hover and transition timings.
- Balance interface audio.
- Test different screen sizes.
- Perform complete functionality regression testing.
- Review every screen for artistic consistency.

**Acceptance:** The complete interface looks cohesive and no gameplay functionality has been lost.

---

## 14. Project Rules

1. Never replace working gameplay behavior solely to improve the visuals.
2. Never introduce UI assets that conflict with the established art direction.
3. Never stretch pixel-art assets non-proportionally.
4. Never assume a generated image has the correct dimensions without verifying it.
5. Never sacrifice readability for atmosphere.
6. Never implement all screens simultaneously without first validating shared components.
7. Always preserve keyboard, mouse, and gamepad compatibility.
8. Always review a change inside the actual running game.
9. Keep the approved moonlit main menu static; do not resume its animation experiments.
10. Work incrementally, with each completed phase remaining playable.

---

## 15. Definition of Done

The UI overhaul is complete when:

- All major screens follow one recognizable visual identity.
- HUD elements are clear, attractive, and unobtrusive.
- Common interface components look and behave consistently.
- The diary has convincing physical page-turn transitions.
- The section wheel feels integrated with the game's art.
- All production graphics use verified dimensions and consistent pixel scaling.
- All existing controls and gameplay systems continue working.
- The interface remains readable across day, dusk, and night.
- The game can be played without reliance on placeholder-feeling UI.

**Final creative goal:** Crow Creek Hollow should feel like a living, weathered homestead whose menus and journals belong naturally to the world—not a game world covered by unrelated interface windows.
