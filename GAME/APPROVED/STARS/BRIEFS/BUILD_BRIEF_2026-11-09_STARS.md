---
id: DOC-TFG-0303
type: PLAN
status: CURRENT
feature: STARS
purpose: Build brief, LOCK 97 - the stars of Najmara
links: [DOC-TFG-0301, DOC-TFG-0302, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE STARS OF NAJMARA — 9 Nov 2026 (LOCK 97, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 97 V1: spec DOC-TFG-0301, data `stars_data_V1.json`, masters nc01-nc10 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 103 (if the line before is not BUILT, this line stays WAITING with "waits for line 103") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/STARS/RECORD/STARS_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/stars_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters nc01-nc10, and the builds of lines 2-103. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/stars_data_V1.json` byte for byte to `SOURCE/data/stars.json`; read by the feature it describes |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/STARS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
