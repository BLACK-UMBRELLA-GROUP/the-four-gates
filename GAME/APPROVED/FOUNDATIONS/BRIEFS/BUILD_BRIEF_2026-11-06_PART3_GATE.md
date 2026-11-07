---
id: DOC-TFG-0010
type: PLAN
status: CURRENT
feature: FOUNDATIONS
purpose: Build brief, LOCK 1 part 3 - the market scales lesson, the gate rule (100 trust and the lesson), the gate opening, and the goal screen
links: [DOC-TFG-0006, DOC-TFG-0007, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — SCALES LESSON, GATE RULE AND GOAL SCREEN — 6 Nov 2026 (LOCK 1, part 3 of 3)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 1 V2: spec DOC-TFG-0006, data `foundations_data_V2.json`, masters f12, f13, f14, f15, f16, f17, f18, f19, f20 |
| Founder's words | "LOCK it, lesson required (Recommended)" and the engine rule "lets build gameplay in gadot but the visual aint importantn" (6 Nov 2026) - placeholder shapes only, no art |
| Build after | line 3 (if line 3 is not BUILT, this line stays WAITING with "waits for line 3") |
| Build before | nothing (last line of LOCK 1) |
| ROADMAP | Row "Learning thread": advanced, not finished (the scales lesson is a first learning moment; the scholar’s errand is not designed yet) - do not tick. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/FOUNDATIONS/RECORD/FOUNDATIONS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/foundations_data_V2.json`, `RECORD/LOCK_RECORD.md`, and the masters named below in `MASTERS/`. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Lesson | "Learn the scales" at the Market scales opens the lesson (f12): three weights; trying one shows it on the scale against the checked weight - level for a true weight (f13), tipped toward the checked weight for the false one, weight 2 (f14); the answer button names the tried weight; right → +25 trust, lesson done, back in the world with the `win` toast; wrong → "Not that one. Look again." After the lesson the action is "Check the scales" with its line |
| 3 | Gate | "Ask the gatekeepers": f16 message if trust < 100; f15 message if trust = 100 but no lesson; f17 if both - the gatehouse gate swings open and stays open; the city map shows the Khurasan Gate green (f20) |
| 4 | Goal | G or the trust bar opens the goal screen (f18/f19): four gates, bars, the gate rule line with "(done)" after the lesson |
| T | Tests | The gate stays closed at 100 trust without the lesson; opens with both; all honest + lesson = exactly 100 trust; the lesson gives trust only once; a wrong answer changes nothing. Run headless: `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0. No test plugins: a plain GDScript runner |
| E | Evidence | Screenshots beside the masters `f12`–`f20`. Then a full playthrough: start → three honest tasks → lesson → gate opens, as 6 numbered screenshots. Save into `GAME/APPROVED/FOUNDATIONS/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports, no compiled builds (core rule 8) |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A–F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read from the data file at run time.
