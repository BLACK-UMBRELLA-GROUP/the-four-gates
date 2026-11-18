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
| Built from | LOCK 36 V2: spec DOC-TFG-0117, data `road_map_data_V2.json`, masters rd01-rd03; LOCK 103 the six gates (DOC-TFG-0323) |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner, BUILT) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/ROAD_MAP/RECORD/ROAD_MAP_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/road_map_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters rd01-rd03, and the builds of lines 2-42. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/road_map_data_V2.json` byte for byte to `SOURCE/data/road_map.json`; the road map reads it directly |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Six gates in data order; Trust by LOCK 32; the other five open exactly when the journey % reaches 20/30/40/45/50 (and stay open); journey % by `journey.rule` with a fixture of known counts; "Your journey · n%" in the Journal; open gates with no roads show `no_roads`; towns open by their flags; travel minutes for same road, to Ilmara and across gates; no travel 20:00-04:40 (road map and LOCK 32 buttons). Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `ROAD_MAP/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". V2: six gates with directions; Patience, Mercy, Knowledge, Witness and Return open at 20/30/40/45/50% of your journey; the journey % rule; "Your journey · n%" in the Journal (spec section "LOCK 103 changes"). Masters rd01-rd03 show four gates: reference for the look only, build six rows from the data. Build after line 41. Needs: none.
