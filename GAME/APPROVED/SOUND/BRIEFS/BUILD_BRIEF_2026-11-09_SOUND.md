---
id: DOC-TFG-0312
type: PLAN
status: CURRENT
feature: SOUND
purpose: Build brief, LOCK 100 - sound
links: [DOC-TFG-0310, DOC-TFG-0311, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — SOUND — 9 Nov 2026 (LOCK 100, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 100 V1: spec DOC-TFG-0310, data `sound_data_V1.json`, masters fc01-fc01 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 106 (if the line before is not BUILT, this line stays WAITING with "waits for line 106") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/SOUND/RECORD/SOUND_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/sound_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters fc01-fc01, and the builds of lines 2-106. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/sound_data_V1.json` byte for byte to `SOURCE/data/sound.json`; read by the feature it describes |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/SOUND/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
