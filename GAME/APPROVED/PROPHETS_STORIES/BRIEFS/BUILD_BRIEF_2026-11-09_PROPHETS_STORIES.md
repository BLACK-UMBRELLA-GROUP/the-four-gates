---
id: DOC-TFG-0252
type: PLAN
status: CURRENT
feature: PROPHETS_STORIES
purpose: Build brief, LOCK 80 - stories of the prophets after Isha
links: [DOC-TFG-0250, DOC-TFG-0251, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — STORIES OF THE PROPHETS AFTER ISHA — 9 Nov 2026 (LOCK 80, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 80 V1: spec DOC-TFG-0250, data `prophets_stories_data_V1.json`, masters dg01-dg05 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 86 (if the line before is not BUILT, this line stays WAITING with "waits for line 86") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PROPHETS_STORIES/RECORD/PROPHETS_STORIES_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/prophets_stories_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters dg01-dg05, and the builds of lines 2-86. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/prophets_stories_data_V1.json` byte for byte to `SOURCE/data/prophets_stories.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/PROPHETS_STORIES/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
