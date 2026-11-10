---
id: DOC-TFG-0068
type: PLAN
status: CURRENT
feature: RAMADAN
purpose: Build brief, LOCK 19 - Ramadan: fasting line, suhoor, iftar, tarawih, private record
links: [DOC-TFG-0066, DOC-TFG-0067, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — RAMADAN — 9 Nov 2026 (LOCK 19, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 19 V1: spec DOC-TFG-0066, data `ramadan_data_V1.json`, masters n01-n11 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 25 (if the line before is not BUILT, this line stays WAITING with "waits for line 25") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/RAMADAN/RECORD/RAMADAN_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/ramadan_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters n01-n11, and the builds of lines 2-25 (line 15's panel and line 25's calendar are used). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/ramadan_data_V1.json` byte for byte to `SOURCE/data/ramadan.json`; one loader reads it |
| 3 | Fasting line | Spec §2 and §3 |
| 4 | Suhoor, iftar, tarawih | Spec §4-§6 |
| 5 | Record | Spec §7 |
| T | Tests | Fasting line only 04:45-18:09 on Ramadan days and not on rested days; suhoor 03:30-04:44 at the inn once a day; iftar 18:10-19:29 at the masjid once a day; tarawih 19:45-22:59 at the masjid once a day and 60 minutes pass; nothing outside Ramadan; record counts days fasted (Maghrib passed, not rested), suhoor and tarawih; no coins, no trust, no What people say line. Check the words, not only the buttons. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside n01-n11 in `GAME/APPROVED/RAMADAN/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
