# Crow Creek Hollow

Godot 4.7 top-down farming and horror game (called Hallowvale until October 2026; the repo, save files and some paths still use that name). `DESIGN.md` is the source of truth for rules, layout and art; read only the section you need (`grep -n "^## " DESIGN.md`).

## Working with this repo

- `scripts/main.gd` is about 6,500 lines. Never read it whole: `grep -n` for the function or constant, then read that range.
- The repo stores LF line endings; Git warns about CRLF on commit, which is harmless.
- Commit only when asked, on `main`. Leave the unrelated `.import`, `.uid`, `project.godot` and `scenes/main.tscn` changes out unless asked.

## Checking changes in the game

Godot: `C:/Program Files (x86)/Steam/steamapps/common/Godot Engine/godot.windows.opt.tools.64.exe`

- After adding images, import them once: `godot --path . --headless --import`.
- Screenshot a scene with `tools/capture.gd` (not headless; it needs a renderer). It starts a new game and saves a half-size PNG:
  `godot --path . -s tools/capture.gd -- out=art/style_tests/x.png inside stage=3 weather=rain season=Winter hour=21`
  See the top of the file for every option. Take one shot per thing being checked, and look at it only once.
- Check balance with `tools/balance_sim.gd` (headless): it plays a new game for N days through the real game functions and prints coins, sanity, skills, homestead steps and milestones. Options at the top of the file:
  `godot --path . --headless -s tools/balance_sim.gd -- mode=engaged days=400 every=40 treks=3` (modes: engaged, ignore, earlybed; treks=N models the planned treks). A year takes a few minutes, so run the modes in parallel.
- Check menus with `tools/menu_test.gd` (headless, slot 9; puts `settings.cfg` back): `godot --path . --headless -s tools/menu_test.gd`. It opens every menu by its own key or button and drives it with injected keys, Xbox buttons and sticks, and mouse clicks and wheel steps, printing PASS or FAIL per case (focus on open, every entry reachable, wrapping, nothing disabled in the focus path, B/Esc back one level, tabs, footer prompts per device, the clock paused, and no press leaking to the farm on close). Run it after adding a panel, tab or button.
- Check saving with `tools/save_test.gd` (headless, slot 9): `godot --path . --headless -s tools/save_test.gd`. It prints PASS or FAIL for each case. Never test in slots 1-3: those are the user's real saves.
- Compare SpriteCook variations on one preview image:
  `& .\tools\sheet.ps1 -Out art/style_tests/x/sheet.png -Scale 4 -Files a.png, b.png` (PowerShell tool).

## Sprites (SpriteCook)

The style rules are locked in `DESIGN.md` under "Art style (locked)". In short: 16 px tiles shown at 3x, straight-on 3/4 top-down view, muted palette, dark outlines.

- Use `pixel-engine-image-v1` for sprites at an exact size (128 px max, no references). For several related pieces, generate one strip of 16 px cells so they match.
- Download to `art/style_tests/<section>/`, pick from one sheet, then copy the chosen art into `art/farm/` (or `art/ui/`).
- Draw sprites behind `FARM_SPRITES` in `main.gd` with `FarmSprites.tex(name)`, keeping the code-drawn version as the fallback.
- Record every asset ID in `spritecook-assets.json` and add a short note to `DESIGN.md`.
- Work one section at a time and stop for review after each.

## Shared AI collaboration (when applicable)

When collaborating with ChatGPT on an owner-approved task, read `AI_COLLAB/README.md`, `AI_COLLAB/TASKS.md`, `AI_COLLAB/DECISIONS.md`, and task-relevant messages in `AI_COLLAB/MESSAGE_BOARD.md`. This is an asynchronous Git-based handoff, not an active chat. Preserve the owner's final authority, distinguish proposals from approved work, and write task outcomes and review requests back to the message board when asked. `DESIGN.md` and all existing instructions above take precedence over collaboration suggestions. This note does not authorize commits, branch changes, or implementation on its own.
