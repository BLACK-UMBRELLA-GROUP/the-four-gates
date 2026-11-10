---
id: DOC-TFG-0192
type: PLAN
status: CURRENT
feature: SIDE_SPILLED_SPICE
purpose: Build brief, LOCK 60 - side mission: the spilled spice (witness)
links: [DOC-TFG-0190, DOC-TFG-0191, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — SIDE MISSION: THE SPILLED SPICE (WITNESS) — 9 Nov 2026 (LOCK 60, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 60 V1: spec DOC-TFG-0190, data `side_spilled_spice_data_V1.json`, masters sl01-sl05 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 66 (if the line before is not BUILT, this line stays WAITING with "waits for line 66") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/SIDE_SPILLED_SPICE/RECORD/SIDE_SPILLED_SPICE_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/side_spilled_spice_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters sl01-sl05, and the builds of lines 2-66. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/side_spilled_spice_data_V1.json` byte for byte to `SOURCE/data/side_spilled_spice.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every choice path of every mission (effects, flags, What people say lines, done in the Journal); every person line at trust 10 / 50 / 80; buttons only in their hours and conditions. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/SIDE_SPILLED_SPICE/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
