---
id: DOC-TFG-0258
type: PLAN
status: CURRENT
feature: VOLUNTARY_FASTS
purpose: Build brief, LOCK 82 - Monday and Thursday fasts
links: [DOC-TFG-0256, DOC-TFG-0257, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — MONDAY AND THURSDAY FASTS — 9 Nov 2026 (LOCK 82, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 82 V1: spec DOC-TFG-0256, data `voluntary_fasts_data_V1.json`, masters di01-di01 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner, BUILT) - chain removed 17 Nov (Founder: "it should do some even if there others blockers"; charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/VOLUNTARY_FASTS/RECORD/VOLUNTARY_FASTS_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/voluntary_fasts_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters di01-di01, and the builds of lines 2-88. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/voluntary_fasts_data_V1.json` byte for byte to `SOURCE/data/voluntary_fasts.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/VOLUNTARY_FASTS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Answer note — 2026-11-18 (QUESTIONS row 41)

**Weekday A**: Sunday 0, Monday 1, Thursday 4, weekday = (day index + 4) mod 7 (R1); JSON unchanged. **Presentation B**: existing River Market layout (R11). Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
