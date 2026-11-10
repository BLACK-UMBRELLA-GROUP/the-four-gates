---
id: DOC-TFG-0035
type: PLAN
status: CURRENT
feature: PRAYER_RECORD
purpose: Build brief, LOCK 8 - all your prayers: private totals on the title screen and under today's record
links: [DOC-TFG-0033, DOC-TFG-0034, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — ALL YOUR PRAYERS — 8 Nov 2026 (LOCK 8, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 8 V1: spec DOC-TFG-0033, data `prayer_record_data_V1.json`, masters r01-r06 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 14 (if the line before is not BUILT, this line stays WAITING with "waits for line 14") |
| Build before | nothing |
| ROADMAP | No row finished (faith in play - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PRAYER_RECORD/RECORD/PRAYER_RECORD_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/prayer_record_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters r01-r06, and line 7's prayer record. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/prayer_record_data_V1.json` byte for byte to `SOURCE/data/prayer_record.json`; one loader reads it |
| 3 | Where prayed | Spec §4: remember masjid / elsewhere for every prayer prayed on your own |
| 4 | Buttons | Spec §2: title button and the record's second button (r01, r04) |
| 5 | Panel | Spec §3: rows in order with counts, empty text, note, buttons by where it was opened from (r02, r03, r05, r06) |
| T | Tests | Each status counted in the right row; alone at the masjid vs elsewhere; Friday congregation counted in both on_time/jamaah and friday; dhuhr_fri counted in on_time (alone) and dhuhr_fri; made-up prayers not in missed; empty text before any status; buttons return to the title or the market/record; prayer still never changes coins or trust. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside r01-r06 in `GAME/APPROVED/PRAYER_RECORD/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
