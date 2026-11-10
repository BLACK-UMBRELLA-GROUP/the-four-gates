---
id: DOC-TFG-0014
type: PLAN
status: CURRENT
feature: IDENTITY
purpose: Build brief, LOCK 2 part 2 - the arrival (quay, money-changers, inn, sunset), starting coins from the arrival, resting at the inn, and the cheat found out after the scales lesson
links: [DOC-TFG-0011, DOC-TFG-0012, DOC-TFG-0006, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — ARRIVAL AND THE INN — 6 Nov 2026 (LOCK 2, part 2 of 4)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 2 V3 (spec V4): spec DOC-TFG-0011, data `identity_data_V3.json` (every word and number; checked against all 30 masters), masters g02–g10, g16, g17, g18, g30 |
| Founder's words | "LOCK it (Recommended)" (6 Nov 2026); placeholder shapes only ("the visual aint importantn") |
| Build after | line 5 (if the line before is not BUILT, this line stays WAITING with "waits for line 5") |
| Build before | line 7 |
| ROADMAP | No row finished; "Tasks and money" advanced (starting money and inn cost). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/IDENTITY/RECORD/IDENTITY_SPEC_CURRENT_VERSION_V5.md` (all), `RECORD/identity_data_V3.json`, `RECORD/LOCK_RECORD.md`, the masters named above in `MASTERS/`, and the LOCK 1 pack you built in lines 2-4. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Arrival | Begin starts the arrival: the four beats from `arrival.beats` in order, with each choice's reply and effect (coins, fair, time); end screen with `end_fair` or `end_cheated`, "Coins: n" and the three buttons (g02–g10). Coins start at 0 and come only from the arrival. Apply spec §7 row `numbers.start_coins` (marked line 6) |
| 3 | Inn | "Rest until morning" at the Inn: uses a paid night if any, else takes `arrival.inn_night` coins, else the stable (`inn.broom`); wakes at 04:40 next day with the matching toast (g16–g18) |
| 4 | Cheat found | If the smiling changer was used, passing the scales lesson shows `arrival.cheat_found_after_lesson` instead of the lesson's normal line (g30) |
| T | Tests | Fair changer → 200 coins, smiling → 120; after the inn beat 198 or 118; resting with 0 coins and no paid night gives the broom line and no negative coins; cheat line only when fair = false. Add them to `res://tests/run_tests.gd`; `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0, with every LOCK 1 test still passing (update only the LOCK 1 tests whose words the renames change) |
| E | Evidence | Screenshots beside g02–g10, g16–g18, g30. Save into `GAME/APPROVED/IDENTITY/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
