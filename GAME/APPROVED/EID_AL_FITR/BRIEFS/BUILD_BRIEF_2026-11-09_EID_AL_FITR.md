---
id: DOC-TFG-0074
type: PLAN
status: CURRENT
feature: EID_AL_FITR
purpose: Build brief, LOCK 21 - the last ten nights, zakat al-fitr, Eid al-Fitr, record rows
links: [DOC-TFG-0072, DOC-TFG-0073, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE LAST TEN NIGHTS AND EID AL-FITR — 9 Nov 2026 (LOCK 21, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 21 V1: spec DOC-TFG-0072, data `eid_al_fitr_data_V1.json`, masters y01-y14 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 27 (if the line before is not BUILT, this line stays WAITING with "waits for line 27") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/EID_AL_FITR/RECORD/EID_AL_FITR_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/eid_al_fitr_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters y01-y14, and the builds of lines 2-27 (lines 25 and 26 are used). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/eid_al_fitr_data_V1.json` byte for byte to `SOURCE/data/eid_al_fitr.json`; one loader reads it |
| 3 | Last ten nights | Spec §2 |
| 4 | Zakat al-fitr | Spec §3 |
| 5 | Eid | Spec §4 |
| 6 | Record | Spec §5 |
| T | Tests | Night button only 23:00-04:44 on nights belonging to 21-30 Ramadan, once per night, 60 minutes pass; nothing says which night is special; zakat al-fitr from 28 Ramadan until 1 Shawwal 08:59, 2 coins, once a year; Eid line all of 1 Shawwal; Eid prayer 06:30-08:59 once; nothing on 2 Shawwal; record rows correct; no coins except zakat al-fitr, no trust. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside y01-y14 in `GAME/APPROVED/EID_AL_FITR/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
