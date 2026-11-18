---
id: DOC-TFG-0285
type: PLAN
status: CURRENT
feature: BUSINESSES
purpose: Build brief, LOCK 91 - a stall and a fishing boat
links: [DOC-TFG-0283, DOC-TFG-0284, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — A STALL AND A FISHING BOAT — 9 Nov 2026 (LOCK 91, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 91 V1: spec DOC-TFG-0283, data `businesses_data_V1.json`, masters od01-od04; reissued for LOCK 103 the six gates (DOC-TFG-0323) - no change to this LOCK's data |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | lines 43, 44 (the road map and Sahila) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/BUSINESSES/RECORD/BUSINESSES_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/businesses_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters od01-od04, and the builds of lines 2-97. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/businesses_data_V1.json` byte for byte to `SOURCE/data/businesses.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `BUSINESSES/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". No change to this LOCK's words or numbers. The six gates (LOCK 103) change only which line it builds after; held 16 Nov and released now. Build after lines 43, 44. Needs: none.
