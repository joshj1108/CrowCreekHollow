# Visual review protocol

This sets out how Claude Code hands finished graphics work to ChatGPT as real images of the game. It extends `AI_COLLAB/README.md` and replaces none of it. `DESIGN.md`, the root `CLAUDE.md` and the owner's approval gates still come first.

## When it applies

Use it whenever a task finishes work on any of these:

- artwork or sprites
- lighting, shaders or the colour grade
- atmosphere, weather or particles
- UI
- the Rookery Wood trek's visuals

It also applies to a fix that changes how any of these look. It doesn't apply to work that can't change the picture, such as balance, saves or menu logic with no visual change.

## What a review package contains

1. **Matching BEFORE and AFTER screenshots**, taken with `tools/capture.gd` using the same options: scene, tile, time, weather, season, house stage, lantern and size.
   - **BEFORE** is the game without the change: the previous commit, or the change's flag switched off (for example `LIGHTING_V2 = false`).
   - Say which one you used.
2. **A labelled contact sheet** made with `tools/review_sheet.ps1`. It shows both versions side by side, tagged BEFORE and AFTER. Its header names the task, the change being judged and the commit, and each row is captioned with the scene, time of day and relevant settings.
3. **Only the scenarios the change can affect**, chosen from:
   - daylight (about 12:00)
   - dusk (about 19:30)
   - night (21:30; on day 1, later than 22:00 brings the scripted first-night event)
   - rain or fog at night
   - a Rookery Wood trek scene (`trek=N`)

   Leave out scenarios the change doesn't touch, and say why.
4. **Motion evidence** for anything that moves: animation, a moving lantern, flickering lights, weather in motion, camera movement.
   - Record it with `tools/review_motion.ps1`. It makes a looping GIF and a strip of evenly spaced frames from a short recording.
   - Where a clip isn't practical, use a short sequence of separate captures.
   - Say plainly when still images can't show an effect, and what a reviewer should look for in play.
   - Movie Maker records at exactly 30 fps of game time, but anything timed by the wall clock (`Time.get_ticks_msec()`) runs at the machine's real speed. So a flicker or sway can play at a different pace in the clip than in play. Note that whenever it applies.
5. **Measurements where they help**, such as a brightness profile or how much of the lit ground changes from frame to frame, stated as measurements and not as visual judgements.

## Where the images go

- The package goes under `art/style_tests/<TASK-ID>/review/`, for example `art/style_tests/VIS-001/review/`.
  - Both tools put a `.gdignore` in that folder, so Godot never imports, ships or exports review images.
  - Raw captures and recordings stay in `builds/review/`, which is gitignored. Only the finished sheets, GIFs and frame strips go in the review folder.
- Review images are kept separate from production assets: never put them in `art/farm/`, `art/ui/` or `art/player/`.
- Don't change gameplay, art or lighting just to make a screenshot look better. Captures show the game as it actually plays. A capture-only setup through `capture.gd` options (tile, hour, weather, stage) is fine, and should be listed in the caption.

## Committing and posting

1. Commit and push the package **only when the owner has authorized it for that task**, on `main` unless the owner says otherwise. Leave out the unrelated `.import`, `.uid`, `project.godot` and `scenes/main.tscn` changes.
2. After pushing, add an entry to `AI_COLLAB/MESSAGE_BOARD.md` (template below) with:
   - the commit SHA that contains the images;
   - one or two sentences on what changed and what to judge;
   - for each image, a GitHub page link and a raw image link, both pinned to that SHA:
     - Page: `https://github.com/joshj1108/CrowCreekHollow/blob/<SHA>/art/style_tests/<TASK-ID>/review/<file>`
     - Raw: `https://raw.githubusercontent.com/joshj1108/CrowCreekHollow/<SHA>/art/style_tests/<TASK-ID>/review/<file>`

   The repository is public, so both links open without signing in. Pin them to the SHA, not to `main`, so they always show the images that were reviewed.
3. The links have to point at a pushed commit, so post them in a follow-up commit, or in the same commit only if the SHA is already known (it isn't, for the commit that adds the images).

### Message board entry template

```
### YYYY-MM-DD — Claude Code → ChatGPT, Owner — TASK-ID — Visual review package: <subject>
- **Status:** review requested
- **Commit:** `<SHA>` (images); BEFORE = <previous commit or flag off>; AFTER = <commit or flag on>
- **What changed:** <one or two sentences>
- **What to judge:** <specific questions>
- **Images:**
  - <sheet name>: [page](https://github.com/joshj1108/CrowCreekHollow/blob/<SHA>/<path>) · [raw](https://raw.githubusercontent.com/joshj1108/CrowCreekHollow/<SHA>/<path>)
- **Motion:** <GIF and frame-strip links, or "still images can't show <effect>; check <what> in play">
- **Scenarios left out:** <which, and why>
- **Approval:** pending ChatGPT review and owner decision
```

## Reviews and approval

- **Pushing a package doesn't start a ChatGPT review.** ChatGPT sees it only when the owner asks it to read the repository.
- Never write or suggest that ChatGPT has reviewed, seen or approved an image until its review is recorded on the message board in its own entry, and quote that entry when referring to it.
- If ChatGPT reports it couldn't open or render an image, record that, and don't count text-only review as a visual review.
- ChatGPT's review is advice. The owner gives final visual acceptance, as in `AI_COLLAB/README.md` and `DECISIONS.md`. A task stays `review requested` until the owner accepts it.

## Keeping this protocol current

Changes to this protocol go through the normal AI_COLLAB process: propose them on the message board, and the owner approves them. Record accepted changes in `DECISIONS.md`.
