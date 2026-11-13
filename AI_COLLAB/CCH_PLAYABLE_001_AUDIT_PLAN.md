# CCH-PLAYABLE-001 — Full Playable-Build Audit: plan

**Status:** APPROVED by the owner 2026-11-12; audit begun. Prepared by Claude Code, 2026-11-12, at the close of CCH-CONSOLIDATED-003
Final Polish. The owner approves the plan before the audit begins; ChatGPT reviews the findings.

**Question the audit answers:** can a new player start Crow Creek Hollow and progress through every existing gameplay
system without developer intervention (no debug panel, no F4, no capture options, no edited saves)?

**Out of scope while auditing:** new features, new content, art changes, balance changes, refactors. Every finding is
recorded, not fixed; fixes are proposed afterwards as separate, owner-approved tasks. The only code written during the
audit is test and probe tooling under `tools/` (never in slots 1–3; slot 9 or a dedicated audit slot).

## 1. Method

Three passes, each feeding the next:

1. **Blind play (the real game, windowed, a fresh profile).** A new game from the title menu, played as a new player
   would: keyboard and mouse for one run, an Xbox controller for another. No debug build shortcuts. Each session is
   recorded (Movie Maker or OBS) with a timestamped log of what was tried, what the game said, and where the player
   was unsure or stuck. Target: the first in-game week in full, then key milestones (below) reached by playing on.
2. **Scripted progression (headless).** `tools/balance_sim.gd` already plays N days through the real game functions
   (modes engaged, ignore, earlybed; treks=N). Extend it read-only into an audit probe that records, per day, which
   progression flags, unlocks, quests and milestones became reachable and which never did in 400 days, so content
   that cannot be reached is found by measurement, not by memory.
3. **Targeted checks.** For each system in section 2, the existing headless tests (save, menu, interior, mail,
   debug_menu, diary, wheel, layout, farmer, creature, aoh2_e2/e3/e5, aoh_cave, aoh_trek) are rerun, and the gaps
   they don't cover are listed; anything that can only be seen in motion gets a short clip.

## 2. Coverage

### First-session experience
- Launch, title menu (`scripts/title_menu.gd`), settings, slot choice, new game, load, delete, quit.
- Intro and first objectives: is there a first goal on screen, and does the player find the diary, the desk and the
  mailbox without being told where they are? Day 1 to day 4 (the walk to the wood's edge, the first trek).
- Tutorials and controls: every action has a visible prompt on both devices (footer prompts, hotbar, Section Wheel).
- Diary introduction (`scripts/diary_book.gd`): found, opened, first page, notes unread markers.
- Survival basics: hunger, thirst, comfort, health and sanity without numbers — can a new player tell what is
  falling and what fixes it? The first night (scripted visitor at 22:00).

### Farm progression
- Planting, watering (bucket, then the hose), harvesting, crop growth and death, seasons' crops.
- Crafting (`craft_system.gd`), cooking, building upgrades and the homestead projects (`farm_projects.gd`).
- Furniture purchases (`estate_system.gd`) and their stage gates; farmhouse restoration stages 0–3.
- Trading: the farm stand (`stall_system.gd`), the pedlar, coins.
- Mail: letters, the flag, the Mailbox panel, mail-delivered quests and rewards.
- Animals (`animal_system.gd`), the cellar, cooler, smokehouse, firewood.

### Exploration and combat
- Treks (`trek_system.gd`): the routes, the marked and dark trails, events, the walker, returning home, ending early.
- The mining cave: entry, ore, lantern tiers and their unlock path, creatures.
- Attacking and blocking (now synchronised to the contact frame), weapon and armour progression.
- Death and recovery: collapsing on the farm, in the cave and on a trek; what is lost; that the player is never
  left in a stuck state.
- Quest rewards and the folk's friendship scenes (`folk_system.gd`), the night visitors and raids.

### Long-term systems
- Seasonal transitions and weather (`weather.gd`), the calendar, festivals or events tied to days.
- Save/load (`save_system.gd`): every system's state survives a save and load at any point of a day, inside, in the
  cave and on a trek; backup and temp-file behaviour; old saves.
- Inventory persistence, progression flags, skills (`progression_system.gd`), achievements
  (`achievement_system.gd`, Steam mirror), the mystery pages and the endings (`story_act.gd`, `ending_screen.gd`).

### Technical stability
- Missing assets (every `FarmSprites.tex` and `load` resolves; the import log is clean), scene transitions (door,
  cave, trek, sleep, ending), collision (the layout flood fill, the interior reachability, trek paths), stuck player
  states (a panel or animation that never ends, input left disabled), animation errors, save corruption (killed
  mid-save), runtime errors (Godot's output during every pass, treated as a finding), and performance at
  1280x720 and the lowest supported resolution.

## 3. Milestones to reach by play

Day 1 morning · first harvest sold · first night survived · first letter read · first trek completed · cave entered
and first creature killed · lantern tier 2 · farmhouse Boarded, Patched, Restored · first furniture bought · first
season change · first friendship scene · a night raid handled · an ending reached (by play if feasible in the audit's
time; otherwise by the scripted probe, and said so).

## 4. Findings format and severity

Each finding: ID, system, steps to reproduce (from a new game), expected, actual, evidence (clip, screenshot, log
line), severity, and a proposed fix size (S/M/L) without implementing it.

- **Critical blocker:** a new player cannot continue (crash, soft lock, unreachable required step, save loss).
- **Major usability problem:** the player can continue but is unlikely to find out how (no prompt, misleading
  feedback, an essential system never introduced).
- **Missing content preventing progression:** a planned step with no content behind it (a quest without a reward,
  an unlock that never triggers).
- **Minor polish issue:** works, but rough (text, timing, a visual glitch).
- **Already playable:** confirmed working end to end, listed so it is not re-audited.

## 5. Deliverables

1. `AI_COLLAB/CCH_PLAYABLE_001_FINDINGS.md`: the findings table, sorted by severity, and the "already playable" list.
2. A progression map: each milestone, the day the engaged/ignore/earlybed probes reach it (or never), and the
   blind-play day.
3. Clips of every critical and major finding, under `art/style_tests/CCH-PLAYABLE-001/` (never production art).
4. A proposed, ordered fix list for owner approval, grouped into small tasks.
5. A board post with the commit SHA and links.

## 6. Order and effort

Blind play first (it is the only pass that sees the game as a new player does), then the probe, then targeted
checks. Estimated three working sessions, one per pass, each ending with a board update. No commit changes game code.
