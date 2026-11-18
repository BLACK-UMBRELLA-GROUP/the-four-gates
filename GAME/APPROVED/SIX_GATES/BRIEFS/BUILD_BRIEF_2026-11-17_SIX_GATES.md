---
id: DOC-TFG-0325
type: PLAN
status: CURRENT
feature: SIX_GATES
purpose: Build brief, LOCK 103 - the six gates in the built screens (words, goal list, city map)
links: [DOC-TFG-0323, DOC-TFG-0324, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE SIX GATES IN THE BUILT SCREENS — 2026-11-17 (LOCK 103, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 103 V1: spec DOC-TFG-0323, data `six_gates_data_V1.json`; reference the prototype V81 (no masters) |
| Founder's words | 17 Nov 2026 clickable "LOCK it (Recommended)" (see the LOCK record) |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner and the built LOCK 1-2 screens) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/SIX_GATES/RECORD/SIX_GATES_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/six_gates_data_V1.json`, `RECORD/LOCK_RECORD.md`, and the builds of LOCK 1-2 (lines 2-8). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/six_gates_data_V1.json` byte for byte to `SOURCE/data/six_gates.json` |
| 3 | Build | Apply `renames` to the shown words (as LOCK 2's renames do); the goal screen lists the six `goal_gates`; the city map shows six gates from `city_gates` at their directions (placeholder shapes). `gates`, `planned_lands` and `chapters_plan` are not shown |
| T | Tests | Each renamed string shows its new words; the goal screen lists six gates in order; the city map has six gate tags at their directions; no other screen changes. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and `LINE110_CHECKS.json` in `GAME/APPROVED/SIX_GATES/BUILT/V1/`. No native Godot window or screenshots (QUESTIONS 15) |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read from the data files at run time.
