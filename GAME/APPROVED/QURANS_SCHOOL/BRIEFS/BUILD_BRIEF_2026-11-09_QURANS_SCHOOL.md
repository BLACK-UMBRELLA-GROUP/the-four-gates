---
id: DOC-TFG-0086
type: PLAN
status: CURRENT
feature: QURANS_SCHOOL
purpose: Build brief, LOCK 25 - Qurans and school at the masjid, public or secret, counters
links: [DOC-TFG-0084, DOC-TFG-0085, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — QURANS AND SCHOOL — 9 Nov 2026 (LOCK 25, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 25 V1: spec DOC-TFG-0084, data `qurans_school_data_V1.json`, masters u01-u11 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 31 (if the line before is not BUILT, this line stays WAITING with "waits for line 31") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/QURANS_SCHOOL/RECORD/QURANS_SCHOOL_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/qurans_school_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters u01-u11, and the builds of lines 2-31. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/qurans_school_data_V1.json` byte for byte to `SOURCE/data/qurans_school.json`; one loader reads it |
| 3 | Button and panel | Spec §2 and §3 - the back button stays on screen |
| 4 | Paying | Spec §4 |
| T | Tests | Button 07:00-15:29 at the masjid; Quran 25 coins +1; school 30 coins +1; first child text only for the first; public +1 trust once a day and the right lines; secret only after page 1, no trust, no line; not enough coins blocks; counters. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside u01-u11 in `GAME/APPROVED/QURANS_SCHOOL/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
