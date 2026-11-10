---
id: DOC-TFG-0098
type: PLAN
status: CURRENT
feature: MENUS
purpose: Build brief, LOCK 29 - pause menu, save and continue, settings
links: [DOC-TFG-0096, DOC-TFG-0097, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — PAUSE, SAVE AND SETTINGS — 9 Nov 2026 (LOCK 29, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 29 V1: spec DOC-TFG-0096, data `menus_data_V1.json`, masters mn01-mn09 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 35 (if the line before is not BUILT, this line stays WAITING with "waits for line 35") |
| Build before | nothing |
| ROADMAP | Advances "Save, menus and polish" (save, pause menu, settings); the Mac build is not part of this line, so do not close the row - say so in the task note |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/MENUS/RECORD/MENUS_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/menus_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters mn01-mn09, and the builds of lines 2-35 (line 2's title screen is changed). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/menus_data_V1.json` byte for byte to `SOURCE/data/menus.json`; one loader reads it |
| 3 | Pause | Spec §1 - save the whole game state to one slot in the user data folder (Godot `user://`), not into the repository |
| 4 | Title | Spec §2 |
| 5 | Settings | Spec §3 - settings stored separately from the save |
| T | Tests | Esc opens and closes pause; save then load restores the same state (coins, trust, clock, every LOCK's progress); title Continue only when a save exists, with its date; settings change text size and walking speed for real and survive a restart; Esc from settings returns to where it came from. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside mn01-mn09 in `GAME/APPROVED/MENUS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
