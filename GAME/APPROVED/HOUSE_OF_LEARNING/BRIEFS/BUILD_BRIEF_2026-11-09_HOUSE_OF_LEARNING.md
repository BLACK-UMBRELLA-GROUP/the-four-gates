---
id: DOC-TFG-0255
type: PLAN
status: CURRENT
feature: HOUSE_OF_LEARNING
purpose: Build brief, LOCK 81 - the House of Learning and copying
links: [DOC-TFG-0253, DOC-TFG-0254, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE HOUSE OF LEARNING AND COPYING — 9 Nov 2026 (LOCK 81, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 81 V1: spec DOC-TFG-0253, data `house_of_learning_data_V1.json`, masters dh01-dh02 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner, BUILT) - chain removed 17 Nov (Founder: "it should do some even if there others blockers"; charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/HOUSE_OF_LEARNING/RECORD/HOUSE_OF_LEARNING_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/house_of_learning_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters dh01-dh02, and the builds of lines 2-87. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/house_of_learning_data_V1.json` byte for byte to `SOURCE/data/house_of_learning.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/HOUSE_OF_LEARNING/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Answer note — 2026-11-18 (QUESTIONS row 40)

**B.** Build now with a fixture for `waraka_done`; the gate stays closed in live play until line 53 lands (R9). The "copies" goal may show 0 / 100 meanwhile. Layout: existing Godot layout (R11). Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
