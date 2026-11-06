---
id: DOC-TFG-0009
type: PLAN
status: CURRENT
feature: FOUNDATIONS
purpose: Build brief, LOCK 1 part 2 - task board, the three tasks with honest and quick choices, results, trust and coins, put-it-right tasks and the daily boat job
links: [DOC-TFG-0006, DOC-TFG-0007, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — TASKS, TRUST, COINS, AMENDS AND THE DAILY JOB — 6 Nov 2026 (LOCK 1, part 2 of 3)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 1 V2: spec DOC-TFG-0006, data `foundations_data_V2.json`, masters f06, f07, f08, f09, f10, f11 |
| Founder's words | "LOCK it, lesson required (Recommended)" and the engine rule "lets build gameplay in gadot but the visual aint importantn" (6 Nov 2026) - placeholder shapes only, no art |
| Build after | line 2 (if line 2 is not BUILT, this line stays WAITING with "waits for line 2") |
| Build before | line 4 (lesson and gate) |
| ROADMAP | Row "Tasks and money": advanced, not finished (no shop yet - not decided) - do not tick; say so in the task note. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/FOUNDATIONS/RECORD/FOUNDATIONS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/foundations_data_V2.json`, `RECORD/LOCK_RECORD.md`, and the masters named below in `MASTERS/`. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Board | "Read the board" at the Task board opens the board panel (f06): the three tasks from the data, then the daily job. Done tasks show "done honestly" / "done the quick way" |
| 3 | Task and result | f07 and f08/f09: story, honest choice first, quick second, "‹ Not now"; the result applies coins and trust (trust 0–100) and shows the label, line and changes |
| 4 | Put it right | After a quick choice its "Put it right" row appears (f10): cost; trust given back = trust actually lost + honest trust (spec §7); "need n coins" when the player cannot pay; "put right" when done |
| 5 | Daily job | Once a day (f11); resets when T turns night into day |
| 6 | HUD | Coins and trust update live; the trust bar opens the goal screen placeholder ("Not built yet." until line 4) |
| T | Tests | All honest = 75 trust and 12 coins; all quick = 0 trust and 31 coins; all quick then all three amends = 75 trust and 0 coins; trust never below 0 or above 100; daily job only once per day and back after night→day; "need n coins" when short. Run headless: `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0. No test plugins: a plain GDScript runner |
| E | Evidence | Screenshots beside the masters `f06`–`f11` (`<master>__master_beside_build.png`). Save into `GAME/APPROVED/FOUNDATIONS/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports, no compiled builds (core rule 8) |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A–F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read from the data file at run time.
