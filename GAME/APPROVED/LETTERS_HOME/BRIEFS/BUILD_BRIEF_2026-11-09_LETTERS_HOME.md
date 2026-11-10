---
id: DOC-TFG-0270
type: PLAN
status: CURRENT
feature: LETTERS_HOME
purpose: Build brief, LOCK 86 - letters home
links: [DOC-TFG-0268, DOC-TFG-0269, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — LETTERS HOME — 9 Nov 2026 (LOCK 86, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 86 V1: spec DOC-TFG-0268, data `letters_home_data_V1.json`, masters dm01-dm01 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 92 (if the line before is not BUILT, this line stays WAITING with "waits for line 92") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/LETTERS_HOME/RECORD/LETTERS_HOME_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/letters_home_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters dm01-dm01, and the builds of lines 2-92. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/letters_home_data_V1.json` byte for byte to `SOURCE/data/letters_home.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/LETTERS_HOME/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
