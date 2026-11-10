---
id: DOC-TFG-0047
type: PLAN
status: CURRENT
feature: QASIMS_JARS
purpose: Build brief, LOCK 12 - Qasim's jars: the wine run from the quay, one a night, talk that builds up
links: [DOC-TFG-0045, DOC-TFG-0046, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — QASIM'S JARS — 8 Nov 2026 (LOCK 12, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 12 V1: spec DOC-TFG-0045, data `qasims_jars_data_V1.json`, masters q01-q09 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 18 (if the line before is not BUILT, this line stays WAITING with "waits for line 18") |
| Build before | nothing |
| ROADMAP | No row finished (temptations - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/QASIMS_JARS/RECORD/QASIMS_JARS_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/qasims_jars_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters q01-q09, and the builds of lines 2-18 (line 18's night rule is reused). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/qasims_jars_data_V1.json` byte for byte to `SOURCE/data/qasims_jars.json`; one loader reads it |
| 3 | Quay bar | Spec §2 (q01, q02, q05, q06) |
| 4 | Offer and run | Spec §3 (q03, q04) |
| 5 | Talk | Spec §4 (q07-q09) |
| T | Tests | Button only 19:30-04:44 and only before this night's run; walking away keeps it; a run adds 20 coins once per night (after midnight counts for the night before); no clock change; trust −5 once at run 4 and −10 once at run 10, never repeated; dice nights do not count as runs; the right single What people say line for 1, 2, 4 and 10 runs, right after the dice line. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside q01-q09 in `GAME/APPROVED/QASIMS_JARS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
