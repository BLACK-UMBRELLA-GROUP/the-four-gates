---
id: DOC-TFG-0282
type: PLAN
status: CURRENT
feature: LAND_AND_HOUSE
purpose: Build brief, LOCK 90 - a house, sleeping at home, and an orchard
links: [DOC-TFG-0280, DOC-TFG-0281, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — A HOUSE, SLEEPING AT HOME, AND AN ORCHARD — 9 Nov 2026 (LOCK 90, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 90 V1: spec DOC-TFG-0280, data `land_and_house_data_V1.json`, masters oc01-oc06; reissued for LOCK 103 the six gates (DOC-TFG-0323) - no change to this LOCK's data |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | lines 43, 51 (the road map and Tinara) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/LAND_AND_HOUSE/RECORD/LAND_AND_HOUSE_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/land_and_house_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters oc01-oc06, and the builds of lines 2-96. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/land_and_house_data_V1.json` byte for byte to `SOURCE/data/land_and_house.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `LAND_AND_HOUSE/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". No change to this LOCK's words or numbers. The six gates (LOCK 103) change only which line it builds after; held 16 Nov and released now. Build after lines 43, 51. Needs: none.

## Answer note — 2026-11-18 (QUESTIONS row 49)

**Entry B** (fixtures for `tinara_done` and `chapter1_done` until lines 51 and 46 land, R9; still builds after 43 and 51 as briefed if they are BUILT, otherwise fixtures). **Harvest A** (30 days after purchase, then 30 days after the last harvest). **Sleep A**: wake at the next 04:40; a night's use counts for the evening it began (a sleep after midnight uses the previous evening's allowance). **Orchard A**: "Not now" leaves the offer open. **Layout B** (R11). Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
