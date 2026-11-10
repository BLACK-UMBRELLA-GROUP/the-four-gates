---
id: DOC-TFG-0273
type: PLAN
status: CURRENT
feature: TRUTH
purpose: Build brief, LOCK 87 - the truth system
links: [DOC-TFG-0271, DOC-TFG-0272, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE TRUTH SYSTEM — 9 Nov 2026 (LOCK 87, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 87 V1: spec DOC-TFG-0271, data `truth_data_V1.json`, masters dn01-dn01 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 93 (if the line before is not BUILT, this line stays WAITING with "waits for line 93") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/TRUTH/RECORD/TRUTH_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/truth_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters dn01-dn01, and the builds of lines 2-93. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/truth_data_V1.json` byte for byte to `SOURCE/data/truth.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/TRUTH/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
