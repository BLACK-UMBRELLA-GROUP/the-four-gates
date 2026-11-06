---
id: DOC-TFG-0008
type: PLAN
status: CURRENT
feature: FOUNDATIONS
purpose: Build brief, LOCK 1 part 1 - Godot greybox of River Market (Gate street), third-person player and camera, places with the E bar, market map, city map, title, HUD, day/night switch
links: [DOC-TFG-0006, DOC-TFG-0007, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — GATE STREET GREYBOX, PLAYER AND MAPS — 6 Nov 2026 (LOCK 1, part 1 of 3)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 1 V2 (V2 answers QUESTIONS row 1: the data file now holds every label and setting): spec DOC-TFG-0006, data `foundations_data_V2.json`, masters f01, f02, f03, f04, f05, f20 |
| Founder's words | "LOCK it, lesson required (Recommended)" and the engine rule "lets build gameplay in gadot but the visual aint importantn" (6 Nov 2026) - placeholder shapes only, no art |
| Build after | nothing (first line of LOCK 1) |
| Build before | line 3 (tasks and trust) |
| ROADMAP | Roadmap row "Game design foundations": tick it (Done 2026-11-06, LOCK 1). Row "Godot project and tooling": tick it when this line is BUILT (input map, test runner, repeatable run). Row "Player and camera": tick it when this line is BUILT. Row "First district": advanced, not finished (greybox only) - do not tick. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/FOUNDATIONS/RECORD/FOUNDATIONS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/foundations_data_V2.json`, `RECORD/LOCK_RECORD.md`, and the masters named below in `MASTERS/`. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Data | Copy `RECORD/foundations_data_V2.json` byte for byte to `SOURCE/data/foundations.json`. One loader script reads it; nothing else holds words or numbers |
| 3 | World | New scene `SOURCE/game/river_market.tscn`, built from spec §4 by a script that reads the street points and the `world` section from the data (streets, square, wall with closed gatehouse, quay, canal, house blocks, one lantern per street). Boxes and flat colours only |
| 4 | Player | Spec §5, numbers from the data's `player`, `camera` and `keys` sections: capsule, walk/run, steps, third-person camera with wall pull-in, input map in `project.godot` |
| 5 | Places | One trigger per place point (2.5 m). Bottom bar per master f05 with the place's `name`, `line` and action label. In this part the actions only show their toast or open the map; the board, scales and gate panels come in lines 3 and 4 (until then: the data's `ui.not_built` line) |
| 6 | Screens | All labels from the data's `ui` section. Title (f01; Begin starts at the quay), market map M (f03/f04: top-down plan, player marker, City map, Wait until night/day), city map (f02; gate tags and messages), HUD (coins 0, trust 20/100) |
| 7 | Day and night | T or the map button switches a day setting (sun) and a night setting (dark sky, lanterns on), with the `night` / `day` toasts |
| 8 | Main scene | `project.godot` main scene → the title screen. Leave `SOURCE/look_test/` untouched (it stays in the history and README) |
| 9 | README | Update `SOURCE/README.md` and the root README: how to run the game, the keys, "placeholder shapes; gameplay first" |
| T | Tests | Data loads and every place in the data exists in the world; the player spawns at the quay; walking from the quay to the gate along the streets is possible and the gate is closed; T switches day/night and lanterns. Run headless: `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0. No test plugins: a plain GDScript runner |
| E | Evidence | Screenshots at 1920 × 1080 beside the masters: `f01`, `f02`, `f03`, `f04`, `f05` as `<master>__master_beside_build.png` (master left, build right), plus 3 in-world shots (quay looking at the gate by day; the square at night; standing at the task board with the bar). Frame rate by day and night on the Mac mini. Save into `GAME/APPROVED/FOUNDATIONS/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports, no compiled builds (core rule 8) |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A–F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read from the data file at run time.
