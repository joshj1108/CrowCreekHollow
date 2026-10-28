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

1. **The first hour.** Start a new game and play the first four or five days. Stay up past 22:00 on day 1 for the first night. From day 4, Old Maren waits at the gap in the trees north of the house (you need a Tin Lantern first; she brings the lamp oil): walk her to the wood's edge, then stay up past 22:00 that night. Was each of these scary, confusing, too long, or too easy to miss? Did the walk teach you her nerve, the lantern and the oil well enough for the longer walk to the mill from day 14? (If you go to bed early you skip the nights. That's allowed, but tell us if you did.)
2. **The first week.** Is it clear what to do next? Where did you get stuck, bored or lost? Did money, food, water or sanity feel too tight or too loose?
3. **Saving and loading.** Sleep, quit, then Continue or Load. Are you back where you were, with everything you had? Try more than one save slot.
4. **Settings.** Volume, fullscreen or windowed, window size, screen shake and message speed. Do they work, and are they still set after you restart the game?
5. **Controls.** Do keyboard and controller both work everywhere, including menus? Is anything awkward?

## Known rough edges

- There are no towns or shops to travel to. Everything comes from the farm, the cave, the catalog at the desk and the treks. Saves from older builds that went out to the towns still load: anything left in the bank comes back to your pack, and a bow or crossbow is taken apart for its materials.
- Treks into the groves (the mill from day 14, the rest later) are new and still rough. The trail works that ease them (Buildings, Trail works) are built but barely tested. Walker and destination art is placeholder.
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
