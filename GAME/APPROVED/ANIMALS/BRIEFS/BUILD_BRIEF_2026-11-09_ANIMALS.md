---
id: DOC-TFG-0276
type: PLAN
status: CURRENT
feature: ANIMALS
purpose: Build brief, LOCK 88 - animals (donkey, camel, horse) and feeding them
links: [DOC-TFG-0274, DOC-TFG-0275, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — ANIMALS (DONKEY, CAMEL, HORSE) AND FEEDING THEM — 9 Nov 2026 (LOCK 88, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 88 V1: spec DOC-TFG-0274, data `animals_data_V1.json`, masters oa01-oa05 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 94 (if the line before is not BUILT, this line stays WAITING with "waits for line 94") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/ANIMALS/RECORD/ANIMALS_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/animals_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters oa01-oa05, and the builds of lines 2-94. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/animals_data_V1.json` byte for byte to `SOURCE/data/animals.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/ANIMALS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
