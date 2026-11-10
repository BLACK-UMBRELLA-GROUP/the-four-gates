---
id: DOC-TFG-0044
type: PLAN
status: CURRENT
feature: DICE_HOUSE
purpose: Build brief, LOCK 11 - the dice house: Mansur's invitation, fair dice, talk that builds up over nights
links: [DOC-TFG-0042, DOC-TFG-0043, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE DICE HOUSE — 8 Nov 2026 (LOCK 11, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 11 V1: spec DOC-TFG-0042, data `dice_house_data_V1.json`, masters x01-x12 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 17 (if the line before is not BUILT, this line stays WAITING with "waits for line 17") |
| Build before | nothing |
| ROADMAP | No row finished (temptations - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/DICE_HOUSE/RECORD/DICE_HOUSE_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/dice_house_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters x01-x12, and the builds of lines 2-17. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/dice_house_data_V1.json` byte for byte to `SOURCE/data/dice_house.json`; one loader reads it |
| 3 | Inn bar | Spec §2 (x01, x02, x08, x12) |
| 4 | Invitation | Spec §3 (x03) |
| 5 | Dice house | Spec §4 (x04-x07) |
| 6 | Talk | Spec §5 (x09-x11) |
| T | Tests | Button only 19:30-04:44; invite before, door after (also after "Go to bed"); "Go to bed" moves no clock; nights counted once per night, and a visit after midnight counts for the night before; bets blocked when coins < bet; forced win adds the bet, forced loss takes it; coins never below 0; no trust change from betting; trust −5 once at night 4 and −10 once at night 10, never repeated; the right single What people say line for 1, 2, 4 and 10 nights, in the right place. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside x01-x12 in `GAME/APPROVED/DICE_HOUSE/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
