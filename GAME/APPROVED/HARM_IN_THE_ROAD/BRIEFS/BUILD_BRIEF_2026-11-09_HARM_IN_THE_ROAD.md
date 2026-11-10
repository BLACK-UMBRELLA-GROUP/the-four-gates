---
id: DOC-TFG-0062
type: PLAN
status: CURRENT
feature: HARM_IN_THE_ROAD
purpose: Build brief, LOCK 17 - harm in the road: daily harm, unseen moving, private count
links: [DOC-TFG-0060, DOC-TFG-0061, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — HARM IN THE ROAD — 9 Nov 2026 (LOCK 17, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 17 V1: spec DOC-TFG-0060, data `harm_in_the_road_data_V1.json`, masters p01-p09 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 23 (if the line before is not BUILT, this line stays WAITING with "waits for line 23") |
| Build before | nothing |
| ROADMAP | No row finished (character and community - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/HARM_IN_THE_ROAD/RECORD/HARM_IN_THE_ROAD_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/harm_in_the_road_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters p01-p09, and the builds of lines 2-23. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/harm_in_the_road_data_V1.json` byte for byte to `SOURCE/data/harm_in_the_road.json`; one loader reads it |
| 3 | Today's harm and bar | Spec §2 and §3 |
| 4 | Moving it | Spec §4 |
| T | Tests | Place and harm follow the day number; shown only 06:30-19:29 and only at that place; once a day; moving adds 5 minutes and 1 to the private count; no coins, no trust, no What people say line; the bar shows the harm's words (check the words, not just the button). Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside p01-p09 in `GAME/APPROVED/HARM_IN_THE_ROAD/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
