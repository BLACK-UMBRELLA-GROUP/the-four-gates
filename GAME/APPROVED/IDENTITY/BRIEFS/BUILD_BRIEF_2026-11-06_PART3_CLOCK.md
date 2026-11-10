---
id: DOC-TFG-0015
type: PLAN
status: CURRENT
feature: IDENTITY
purpose: Build brief, LOCK 2 part 3 - the game clock (48-minute day), five prayer times, adhan, praying in congregation at the masjid or alone, missed and made up, Friday prayer, the private prayer record, and Wait until next prayer replacing the day/night switch
links: [DOC-TFG-0011, DOC-TFG-0012, DOC-TFG-0006, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — DAY AND PRAYER CLOCK — 6 Nov 2026 (LOCK 2, part 3 of 4)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 2 V3 (spec V4): spec DOC-TFG-0011, data `identity_data_V3.json` (every word and number; checked against all 30 masters), masters g15, g19–g24 |
| Founder's words | "LOCK it (Recommended)" (6 Nov 2026); placeholder shapes only ("the visual aint importantn") |
| Build after | line 6 (if the line before is not BUILT, this line stays WAITING with "waits for line 6") |
| Build before | line 8 |
| ROADMAP | No row finished; note "faith in play - prayer clock" for Fable (not a ROADMAP row yet). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/IDENTITY/RECORD/IDENTITY_SPEC_CURRENT_VERSION_V5.md` (all), `RECORD/identity_data_V3.json`, `RECORD/LOCK_RECORD.md`, the masters named above in `MASTERS/`, and the LOCK 1 pack you built in lines 2-4. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Clock | `clock` section: day length, start time, weekdays, the five prayers (begins, ends, iqamah), night hours. HUD centre box (g15): weekday · time and the next / now / done line, formats exactly as in the data. Day and night lighting follow the clock (replaces LOCK 1's T switch; T and the button are now "Wait until next prayer"). Apply spec §7 rows `keys.wait_day_night` and `ui.buttons.wait_night / wait_day` (marked line 7) |
| 3 | Prayer | Adhan toast when a prayer begins (g20). At the Masjid from the adhan until iqamah + 5 min: "Pray with the congregation" (Friday: "Pray Friday prayer with the congregation", g24); otherwise "Pray {prayer} here" (P, g21) - on a Friday away from the masjid it is always Dhuhr (`clock.friday.away_rule`, `pray_here_friday`, status `dhuhr_fri`). Praying takes 10 game minutes |
| 4 | Missed / made up | A prayer not prayed before its time ends is missed (not counted if it ended before the game started); "Make up {prayer}" appears (g23) |
| 5 | Record | Tap the clock → "Your prayers" (g22) with each prayer's time and status and the privacy note. No coins or trust change from prayer, ever |
| T | Tests | Times match the table; congregation only inside the window at the masjid; Friday replaces Dhuhr on Fridays only in congregation at the masjid (away: Dhuhr, man's status dhuhr_fri); a skipped window becomes missed; make-up turns it to made up; prayer never changes coins or trust; Wait jumps to the next prayer start. Add them to `res://tests/run_tests.gd`; `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0, with every LOCK 1 test still passing (update only the LOCK 1 tests whose words the renames change) |
| E | Evidence | Screenshots beside g15, g19–g24, and the HUD at day and at night. Save into `GAME/APPROVED/IDENTITY/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
