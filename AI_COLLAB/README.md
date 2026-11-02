# AI Collaboration — Crow Creek Hollow

This folder is a version-controlled handoff system, not a live chat or autonomous agent channel. ChatGPT and Claude Code only see changes after fetching/pulling the repository. The project owner is final decision-maker.

## Source of truth and ownership
- `DESIGN.md` remains authoritative for game rules, layout and locked art. Existing `CLAUDE.md` technical instructions remain in force.
- **ChatGPT (design lead/reviewer):** design proposals, art direction, visual acceptance criteria, gameplay evaluation, and reviewing Claude implementations. May author collaboration notes and specs.
- **Claude Code (implementation lead):** Godot code, SpriteCook generation, shader/lighting integration, tests, commits and technical feasibility feedback. May challenge design proposals and request decisions.
- **Owner (final approval):** changes to locked art, camera, gameplay mechanics, scope and acceptance of major deliverables. Neither assistant can silently approve the other's work.

## Operating procedure
1. At session start, read `TASKS.md`, `DECISIONS.md` and the latest relevant entries in `MESSAGE_BOARD.md`.
2. Claim a task with explicit owner, reviewer, state, acceptance criteria, and files/commit links.
3. Work on approved scope only. For substantial code/art changes, stop at the review gate.
4. Append timestamped messages to `MESSAGE_BOARD.md` with a task ID and an explicit request or outcome.
5. Request independent review; mark it *review requested*, not *approved*. Owner accepts or changes priorities.
6. Commit and push notes when requested. Other assistant must pull/fetch before reading. Avoid concurrent edits of the same file; preserve earlier messages.

## Task states
`proposed` → `approved` → `in progress` → `review requested` → `changes requested` or `accepted`; `blocked` as needed.

## Rules
- Do not imply live communication, continuous monitoring, or automatic approval.
- No writes to user save slots 1–3. Respect test commands, asset constraints and code boundaries in root `CLAUDE.md`.
- Identify facts observed in code versus proposals. Link commits and screenshots where available.
- No gameplay changes or mass sprite replacement without owner approval.
- The GitHub branch/commit workflow for a specific session must be authorized by the owner; avoid silently pushing to `main`.
