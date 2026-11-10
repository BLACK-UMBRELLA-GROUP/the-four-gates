---
id: DOC-TFG-0050
type: PLAN
status: CURRENT
feature: JABIRS_GOATS
purpose: Build brief, LOCK 13 - Jabir's goats: buy stolen goats, walk away or tell Saeed; talk builds up
links: [DOC-TFG-0048, DOC-TFG-0049, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — JABIR'S GOATS — 8 Nov 2026 (LOCK 13, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 13 V1: spec DOC-TFG-0048, data `jabirs_goats_data_V1.json`, masters j01-j12 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 19 (if the line before is not BUILT, this line stays WAITING with "waits for line 19") |
| Build before | nothing |
| ROADMAP | No row finished (temptations - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/JABIRS_GOATS/RECORD/JABIRS_GOATS_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/jabirs_goats_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters j01-j12, and the builds of lines 2-19. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/jabirs_goats_data_V1.json` byte for byte to `SOURCE/data/jabirs_goats.json`; one loader reads it |
| 3 | Gate bar | Spec §2 (j01, j02, j05, j09) |
| 4 | Offer | Spec §3 (j03, j06) |
| 5 | Buy | Spec §4 (j04) |
| 6 | Tell Saeed | Spec §5 (j07-j09) |
| 7 | Talk | Spec §6 (j10-j12) |
| T | Tests | Button only 15:00-17:59, once a day, never after telling; buy blocked when coins < 10; a buy adds net 20 coins once a day; walk away changes nothing; telling adds 3 trust once and ends Jabir for good; trust −5 once at deal 4 and −10 once at deal 10; deals separate from dice nights and jar runs; the right What people say lines in the right order and place. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside j01-j12 in `GAME/APPROVED/JABIRS_GOATS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
