---
id: DOC-TFG-0171
type: PLAN
status: CURRENT
feature: SIDE_NEIGHBOURS_WALL
purpose: Build brief, LOCK 53 - side mission: the neighbour's wall
links: [DOC-TFG-0169, DOC-TFG-0170, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — SIDE MISSION: THE NEIGHBOUR'S WALL — 9 Nov 2026 (LOCK 53, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 53 V1: spec DOC-TFG-0169, data `side_neighbours_wall_data_V1.json`, masters sb01-sb04 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 59 (if the line before is not BUILT, this line stays WAITING with "waits for line 59") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/SIDE_NEIGHBOURS_WALL/RECORD/SIDE_NEIGHBOURS_WALL_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/side_neighbours_wall_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters sb01-sb04, and the builds of lines 2-59. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/side_neighbours_wall_data_V1.json` byte for byte to `SOURCE/data/side_neighbours_wall.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every choice path of every mission (effects, flags, What people say lines, done in the Journal); every person line at trust 10 / 50 / 80; buttons only in their hours and conditions. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/SIDE_NEIGHBOURS_WALL/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
