---
id: DOC-TFG-0019
type: PLAN
status: CURRENT
feature: CHAPTER_1
purpose: Build brief, LOCK 3 part 1 - the open purse at the inn door, hadith page 1 (giving in secret) and the What people say page
links: [DOC-TFG-0017, DOC-TFG-0018, DOC-TFG-0011, DOC-TFG-0006, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE OPEN PURSE, PAGE 1, WHAT PEOPLE SAY — 7 Nov 2026 (LOCK 3, part 1 of 2)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 3 V2: spec DOC-TFG-0017, data `chapter1_data_V2.json` (every word and number), masters c01-c16 |
| Founder's words | "LOCK it (Recommended)" (7 Nov 2026); placeholder shapes only ("the visual aint importantn") |
| Build after | line 8 (if the line before is not BUILT, this line stays WAITING with "waits for line 8") |
| Build before | line 10 |
| ROADMAP | Row "Learning thread": tick it when this line is BUILT (the first scholar's page, read with the teacher, teaches through play) and close its GitHub issue against the source SHA. "First district" advanced. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/CHAPTER_1/RECORD/CHAPTER1_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/chapter1_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters c01-c16 in `MASTERS/`, and the LOCK 1 and LOCK 2 packs you built in lines 2-8. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Data | Copy `RECORD/chapter1_data_V2.json` byte for byte to `SOURCE/data/chapter1.json`; one loader reads it |
| 3 | People | Capsules with name labels per spec §2: Yusuf, Faris and Tariq at the inn door; Salma at her oven by the task board |
| 4 | Open purse | Spec §3 in full: inn bar button, door list, public and secret gifts, not enough coins, Salma, Umm Salim appearing, page 1 with the learned word, End the day (clock to next day 07:00), morning lines in order, done state (c01-c08, c10, c12, c13) |
| 5 | What people say | Spec §5: button on the market map bar, title, lines in order, tones, empty text, notes, buttons (c09, c11, c14-c16). The bread grab line comes in line 10 |
| T | Tests | Public gift: coins − cost, trust + 2, once per person; secret gift: coins − cost, trust unchanged; secret only after page 1; Umm Salim only after Salma; not enough coins blocks giving; End the day → next day 07:00; crowd n = 4 + 4 × public gifts; morning lines and What people say lines follow the spec order for every gift combination in c08-c16; inn button gone when done. Add to `res://tests/run_tests.gd`; `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside c01-c16 (master left, build right). Save into `GAME/APPROVED/CHAPTER_1/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 11 Nov 2026 (QUESTIONS row 8)

`fire` (morning) and `fooled` (What people say) apply only after a **public** gift to Tariq. A secret gift to Tariq: locked cost, no trust change, no Tariq morning line, no `fooled`, `secret_note` as for any secret gift. See the spec's Clarifications section.

## Answer note — 11 Nov 2026 (LOCK 3 V2)

Build from spec V2 and `chapter1_data_V2.json` (copy V2 byte for byte to `SOURCE/data/chapter1.json`). The bread grab no longer jumps the clock (Founder 11 Nov: "No jump: Salma asks later (Recommended)"). "End the day" still jumps to 07:00; prayers in that jump are not counted. Read the spec's Clarifications section (masters' HUD is a set-up state; What people say order DOC-TFG-0321).
