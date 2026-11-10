---
id: DOC-TFG-0059
type: PLAN
status: CURRENT
feature: RASHIDS_LOAN
purpose: Build brief, LOCK 16 - Rashid's loan: lend without increase, refused interest, time / let go / demand
links: [DOC-TFG-0057, DOC-TFG-0058, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — RASHID'S LOAN — 9 Nov 2026 (LOCK 16, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 16 V1: spec DOC-TFG-0057, data `rashids_loan_data_V1.json`, masters l01-l18 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 22 (if the line before is not BUILT, this line stays WAITING with "waits for line 22") |
| Build before | nothing |
| ROADMAP | No row finished (wealth - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/RASHIDS_LOAN/RECORD/RASHIDS_LOAN_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/rashids_loan_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters l01-l18, and the builds of lines 2-22. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/rashids_loan_data_V1.json` byte for byte to `SOURCE/data/rashids_loan.json`; one loader reads it |
| 3 | Bar | Spec §2 |
| 4 | Ask | Spec §3 |
| 5 | Due | Spec §4 and §5 |
| 6 | What people say | Spec §6 |
| T | Tests | Ask only at trust ≥ 30 in Rashid's hours; lend −30; asking 36 refused, −5 trust, no coins moved, never asked again; due only after 3 days; wait +20 coins +3 trust then +10 after 7 more days; forgive +20 +5; demand +30 −5; bar states per §2; one What people say line per choice in the right place. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside l01-l18 in `GAME/APPROVED/RASHIDS_LOAN/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
