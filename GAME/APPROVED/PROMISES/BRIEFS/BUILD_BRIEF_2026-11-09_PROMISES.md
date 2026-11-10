---
id: DOC-TFG-0267
type: PLAN
status: CURRENT
feature: PROMISES
purpose: Build brief, LOCK 85 - a promise to Jamal
links: [DOC-TFG-0265, DOC-TFG-0266, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — A PROMISE TO JAMAL — 9 Nov 2026 (LOCK 85, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 85 V1: spec DOC-TFG-0265, data `promises_data_V1.json`, masters dl01-dl03 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 91 (if the line before is not BUILT, this line stays WAITING with "waits for line 91") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PROMISES/RECORD/PROMISES_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/promises_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters dl01-dl03, and the builds of lines 2-91. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/promises_data_V1.json` byte for byte to `SOURCE/data/promises.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/PROMISES/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
