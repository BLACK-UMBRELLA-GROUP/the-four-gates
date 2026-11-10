---
id: DOC-TFG-0065
type: PLAN
status: CURRENT
feature: CALENDAR
purpose: Build brief, LOCK 18 - the calendar: Hijri date on the clock, resting for days, coming dates
links: [DOC-TFG-0063, DOC-TFG-0064, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE CALENDAR — 9 Nov 2026 (LOCK 18, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 18 V1: spec DOC-TFG-0063, data `calendar_data_V1.json`, masters k01-k11 |
| Founder's words | "A · Real calendar + rest (Recommended)", "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 24 (if the line before is not BUILT, this line stays WAITING with "waits for line 24") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/CALENDAR/RECORD/CALENDAR_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/calendar_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters k01-k11, and the builds of lines 2-24 (line 7's clock and line 15's prayer record are changed). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/calendar_data_V1.json` byte for byte to `SOURCE/data/calendar.json`; one loader reads it |
| 3 | Calendar | Spec §1 |
| 4 | Clock | Spec §2 - update earlier clock tests to expect the date (the known difference) |
| 5 | Rest for days | Spec §3 |
| 6 | Coming dates | Spec §4 |
| T | Tests | Day 0 = Thursday 1 Sha'ban; day 29 = 1 Ramadan; day 59 = 1 Shawwal; day 127 = 10 Dhu al-Hijjah; day 354 = 1 Sha'ban; resting 3 days costs 6 coins and wakes on day 3 at 04:40; rested prayers never missed and not in totals; buttons blocked when coins are short; coming-date rows and "today" correct on days 0, 29, 127 and 354. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside k01-k11 in `GAME/APPROVED/CALENDAR/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference (list the clock date as the known difference), public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
