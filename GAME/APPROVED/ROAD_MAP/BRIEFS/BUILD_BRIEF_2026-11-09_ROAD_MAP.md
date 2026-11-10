---
id: DOC-TFG-0119
type: PLAN
status: CURRENT
feature: ROAD_MAP
purpose: Build brief, LOCK 36 - the road map and the gates at night
links: [DOC-TFG-0117, DOC-TFG-0118, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE ROAD MAP AND THE GATES AT NIGHT — 9 Nov 2026 (LOCK 36, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 36 V1: spec DOC-TFG-0117, data `road_map_data_V1.json`, masters rd01-rd03 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 42 (if the line before is not BUILT, this line stays WAITING with "waits for line 42") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/ROAD_MAP/RECORD/ROAD_MAP_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/road_map_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters rd01-rd03, and the builds of lines 2-42. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/road_map_data_V1.json` byte for byte to `SOURCE/data/road_map.json`; the road map reads it directly |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Gates and towns open by their flags; travel minutes for same road, to Ilmara and across gates; no travel 20:00-04:40 (road map and LOCK 32 buttons). Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/ROAD_MAP/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
