---
id: DOC-TFG-0083
type: PLAN
status: CURRENT
feature: PILGRIMS
purpose: Build brief, LOCK 24 - pilgrims you send: Abbas, Umrah and Hajj trips, coming home, counters
links: [DOC-TFG-0081, DOC-TFG-0082, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — PILGRIMS YOU SEND — 9 Nov 2026 (LOCK 24, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 24 V2: spec DOC-TFG-0081 (`PILGRIMS_SPEC_CURRENT_VERSION_V2.md`), data `pilgrims_data_V2.json`, masters b01-b11 |
| Founder's words | "LOCK it (Recommended)", then "Show nothing (Recommended)" for V2 (9 Nov 2026); placeholder shapes only |
| Build after | line 30 (if the line before is not BUILT, this line stays WAITING with "waits for line 30") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PILGRIMS/RECORD/PILGRIMS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/pilgrims_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters b01-b11, and the builds of lines 2-30. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/pilgrims_data_V2.json` byte for byte to `SOURCE/data/pilgrims.json`; one loader reads it |
| 3 | Button and panel | Spec §2 and §3 - the back button must stay visible |
| 4 | Sending | Spec §4 |
| 5 | Coming home | Spec §5 |
| T | Tests | Button 07:00-17:59 at the gate; Umrah 40 coins home after 30 days; Hajj only 1 Shawwal-25 Dhu al-Qa'dah, 120 coins, home on 25 Dhu al-Hijjah; each person once; not enough coins blocks; home → +2 trust once (public) or none (secret); the What people say line for a public trip, none for a secret one; counters. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside b01-b11 in `GAME/APPROVED/PILGRIMS/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
