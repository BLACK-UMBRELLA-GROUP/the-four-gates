---
id: DOC-TFG-0071
type: PLAN
status: CURRENT
feature: IFTAR_GIVING
purpose: Build brief, LOCK 20 - iftar for the fasting: Ramadan feeding at the masjid, public or secret
links: [DOC-TFG-0069, DOC-TFG-0070, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — IFTAR FOR THE FASTING — 9 Nov 2026 (LOCK 20, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 20 V1: spec DOC-TFG-0069, data `iftar_giving_data_V1.json`, masters v01-v10 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 26 (if the line before is not BUILT, this line stays WAITING with "waits for line 26") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/IFTAR_GIVING/RECORD/IFTAR_GIVING_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/iftar_giving_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters v01-v10, and the builds of lines 2-26 (line 16's feeding panel is the model). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/iftar_giving_data_V1.json` byte for byte to `SOURCE/data/iftar_giving.json`; one loader reads it |
| 3 | Button | Spec §2 |
| 4 | Panel and paying | Spec §3 and §4 |
| T | Tests | Button only in Ramadan 16:00-18:09 at the masjid; costs and meals per option; meals shared with LOCK 9's counter; public +1 trust only once a day; secret only after page 1, no trust, no line; blocked when coins short; What people say line in the right place. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside v01-v10 in `GAME/APPROVED/IFTAR_GIVING/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
