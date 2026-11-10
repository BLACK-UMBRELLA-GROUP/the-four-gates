---
id: DOC-TFG-0016
type: PLAN
status: CURRENT
feature: IDENTITY
purpose: Build brief, LOCK 2 part 4 - the first meeting with Idris at the masjid and the language system (unknown words in the town language, learned words in English)
links: [DOC-TFG-0011, DOC-TFG-0012, DOC-TFG-0006, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — IDRIS AND LEARNING THE LANGUAGE — 6 Nov 2026 (LOCK 2, part 4 of 4)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 2 V3 (spec V4): spec DOC-TFG-0011, data `identity_data_V3.json` (every word and number; checked against all 30 masters), masters g19, g25–g29 |
| Founder's words | "LOCK it (Recommended)" (6 Nov 2026); placeholder shapes only ("the visual aint importantn") |
| Build after | line 7 (if the line before is not BUILT, this line stays WAITING with "waits for line 7") |
| Build before | nothing (last line of LOCK 2) |
| ROADMAP | Row "Characters and dialogue": advanced, not finished (first character and dialogue). Do not tick. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/IDENTITY/RECORD/IDENTITY_SPEC_CURRENT_VERSION_V5.md` (all), `RECORD/identity_data_V3.json`, `RECORD/LOCK_RECORD.md`, the masters named above in `MASTERS/`, and the LOCK 1 pack you built in lines 2-4. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Language | A store of known words (from `language.words`). Text with a word marker shows the town word in a different colour until learned, then the English with the town word in brackets (g25 vs g28) |
| 3 | Meeting | Masjid action "Sit a while" before the meeting (g19) opens Idris's four beats (`teacher.beats`): choices, replies, words learned ("New word · {ar} = {en}", g26), the words-you-know counter, the end line and buttons (g29). After the meeting the action is "Look inside" |
| 4 | After | "Back to the market" returns to the Masjid point; "Meet him again" replays the beats (words stay known) |
| T | Tests | A word is unknown until its choice is picked, then known everywhere; the counter matches; the meeting can be left at any beat; "Sit a while" only before the meeting. Add them to `res://tests/run_tests.gd`; `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0, with every LOCK 1 test still passing (update only the LOCK 1 tests whose words the renames change) |
| E | Evidence | Screenshots beside g19, g25–g29. Save into `GAME/APPROVED/IDENTITY/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
