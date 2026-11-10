---
id: DOC-TFG-0113
type: PLAN
status: CURRENT
feature: SCENE_RUNNER
purpose: Build brief, LOCK 34 - the scene runner, towns and the journal
links: [DOC-TFG-0111, DOC-TFG-0112, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE SCENE RUNNER, TOWNS AND THE JOURNAL — 9 Nov 2026 (LOCK 34, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 34 V1: spec DOC-TFG-0111, data `scene_runner_data_V1.json`, masters sr01-sr02 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 40 (if the line before is not BUILT, this line stays WAITING with "waits for line 40") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/scene_runner_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters sr01-sr02, and the builds of lines 2-40. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/scene_runner_data_V1.json` byte for byte to `SOURCE/data/scene_runner.json`; one content loader reads every content file listed in `SOURCE/data/content_index.json` (create it with the content files of LOCKs 35 onward as they are built) |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Runner: a test mission file with every effect type; conditions hide and show the button; flags and after_days; done in the Journal. Towns: own trust, people by band and memory, work once a day for trust, inn wakes at 04:40, town What people say. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/SCENE_RUNNER/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
