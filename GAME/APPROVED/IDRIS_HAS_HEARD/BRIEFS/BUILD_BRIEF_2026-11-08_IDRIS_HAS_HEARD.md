---
id: DOC-TFG-0053
type: PLAN
status: CURRENT
feature: IDRIS_HAS_HEARD
purpose: Build brief, LOCK 14 - Idris has heard: cooling after temptation hits, page held back, never prayer, warming after good
links: [DOC-TFG-0051, DOC-TFG-0052, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — IDRIS HAS HEARD — 8 Nov 2026 (LOCK 14, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 14 V1: spec DOC-TFG-0051, data `idris_has_heard_data_V1.json`, masters i01-i08 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 20 (if the line before is not BUILT, this line stays WAITING with "waits for line 20") |
| Build before | nothing |
| ROADMAP | No row finished (temptations - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/IDRIS_HAS_HEARD/RECORD/IDRIS_HAS_HEARD_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/idris_has_heard_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters i01-i08, and the builds of lines 2-20 (lines 9, 18, 19 and 20 are changed by this LOCK). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/idris_has_heard_data_V1.json` byte for byte to `SOURCE/data/idris_has_heard.json`; one loader reads it |
| 3 | Cooling | Spec §2 |
| 4 | While cool | Spec §3 (i02-i05, i08) - the page-1 step of line 9 checks Idris first |
| 5 | Way back | Spec §4 (i06, i07) |
| T | Tests | Each of the six hits cools Idris once; cool point = trust after the hit; masjid line only while cool; every prayer still possible while cool; page 1 refused while cool (no page, no word, no secret giving) and readable after warming; warming at cool point + 10; a temptation act while cool moves the cool point; a new hit after warming cools again; the single right Idris line, last in What people say. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside i01-i08 in `GAME/APPROVED/IDRIS_HAS_HEARD/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 11 Nov 2026 (QUESTIONS row 10)

Warming uses Idris's private uncapped trust tally (spec Clarifications, row 10): gains cut off by the 100 cap still count toward cool point + 10. Add tests for 100 → 95 → +5 → +5 (warms) and for a temptation at the cap while cool (needs 10 fresh points).
