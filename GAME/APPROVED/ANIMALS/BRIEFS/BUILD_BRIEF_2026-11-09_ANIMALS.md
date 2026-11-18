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
| Built from | LOCK 88 V2: spec DOC-TFG-0274, data `animals_data_V2.json`, masters oa01-oa05 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Needs | none (charters rule 15) |
| Build after | line 43 (the road map, whose result this line uses) - set 18 Nov (QUESTIONS 47) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/ANIMALS/RECORD/ANIMALS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/animals_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters oa01-oa05, and the builds of lines 2-94. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/animals_data_V2.json` byte for byte to `SOURCE/data/animals.json`; the LOCK 34 runner loads it |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/ANIMALS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Answer note — 2026-11-18 (QUESTIONS row 47)

**Road A**: line 95 now builds after line 43 (it changes every road's minutes). **Stable A**: a choice that costs coins is hidden while you have fewer (R2); paying him back and feeding resets the feeding timer - `stale.mission` is now ["feed_animal", "animal_neglected"] in `animals_data_V2.json` (R1). **Journal A**: no animal rows. Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
