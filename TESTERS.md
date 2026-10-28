# Testing Crow Creek Hollow

Thank you for playing. This is an early test build of a top-down farming and horror game: you keep a run-down farm at the edge of a wood, and the nights are not safe. Please play the way you naturally would, then tell us what happened.

## Running it

- You get one file, `CrowCreekHollow.exe` (Windows 10 or 11, 64-bit). Put it anywhere and double-click it. Nothing needs installing.
- Windows may show "Windows protected your PC" because the file isn't signed. Click **More info**, then **Run anyway**.
- The build version is shown in the bottom-right corner of the start screen (for example `v0.1.0`). Please include it in your feedback.

## Controls in brief

| | Keyboard and mouse | Xbox controller |
|---|---|---|
| Move | WASD or arrow keys | Left stick or D-pad |
| Talk, sleep, open, gather, drink | Space | A |
| Use the tool or weapon in hand | Left click | RT |
| Change the seed to plant (trowel) | Z and X | |
| Bag and inventory | Tab | Y |
| Section wheel (skills, gear, crafting, quests...) | Hold Shift, then use the mouse | Click the left stick, then the left stick and A |
| Close a panel, the wheel or the bag | B or Esc | B |
| **Pause menu** (resume, settings, controls, "Unstick me" if you're trapped, quit) | **Esc** | **Start** |

The full list is under **Controls** in the Pause menu and in Settings on the start screen.

**The game only saves when you go to sleep** (or when you collapse at 03:00). Quitting halfway through a day loses that day.

## What to focus on

1. **The first night.** Start a new game and stay up past 22:00 on day 1. Was it scary, confusing, too long, or too easy to miss? (If you go to bed early you skip it. That's allowed, but tell us if you did.)
2. **The first week.** Is it clear what to do next? Where did you get stuck, bored or lost? Did money, food, water or sanity feel too tight or too loose?
3. **Saving and loading.** Sleep, quit, then Continue or Load. Are you back where you were, with everything you had? Try more than one save slot.
4. **Settings.** Volume, fullscreen or windowed, window size, screen shake and message speed. Do they work, and are they still set after you restart the game?
5. **Controls.** Do keyboard and controller both work everywhere, including menus? Is anything awkward?

## Known rough edges

- The road and towns are switched off in this build, so there are no shops yet. Everything comes from the farm and the cave.
- Treks into the groves (from the first winter) are new and still rough. The trail works that ease them (Buildings, Trail works) are built but barely tested. Walker and destination art is placeholder.
- The pacing after the first few weeks isn't finished. Skills and farm projects may run out early.
- Some art is placeholder, and the game has no icon yet.
- There's no in-game bug report button. Please use the steps below.

## What to send back

For each problem, or for your overall impressions, please send:

1. **The build version** from the corner of the start screen.
2. **What happened**: what you did, what you expected, and what you saw instead. Include the in-game day and time if you remember them. A screenshot helps (Win+Shift+S).
3. **Your save file and the log**, especially after a crash or anything strange. The game keeps them in this folder (paste the line into the File Explorer address bar):

   ```
   %APPDATA%\Godot\app_userdata\Crow Creek Hollow
   ```

   - `hallowvale_save_1.json`, `_2` and `_3`: your save slots (the `.bak.json` files hold the save before that one). Send the slot you were playing.
   - `settings.cfg`: your settings.
   - `logs\godot.log`: the log from the last run. Older runs are in the same folder with the date in the name. **Copy the log before you start the game again**, because each launch begins a new one.

Zipping the whole folder and sending that works too.
