---
id: DOC-TFG-0101
type: PLAN
status: CURRENT
feature: PRAYER_REMINDER
purpose: Build brief, LOCK 30 - the real-life prayer reminder in Settings
links: [DOC-TFG-0099, DOC-TFG-0100, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE REAL-LIFE PRAYER REMINDER — 9 Nov 2026 (LOCK 30, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 30 V1: spec DOC-TFG-0099, data `prayer_reminder_data_V1.json`, masters pm01-pm07 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 36 (if the line before is not BUILT, this line stays WAITING with "waits for line 36") |
| Build before | nothing |
| ROADMAP | Advances "Save, menus and polish" (settings); does not close it - say so in the task note |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PRAYER_REMINDER/RECORD/PRAYER_REMINDER_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/prayer_reminder_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters pm01-pm07, and the builds of lines 2-36 (line 36's settings and pause menu are used). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/prayer_reminder_data_V1.json` byte for byte to `SOURCE/data/prayer_reminder.json`; one loader reads it |
| 3 | Settings rows | Spec §2 |
| 4 | Times | Spec §3 - match the expected London and Makkah times for 9 Nov 2026 within 2 minutes; no location access of any kind |
| 5 | Banner | Spec §4 |
| T | Tests | Off by default; rows only when on; times for London and Makkah on 9 Nov 2026 within 2 minutes of §3 (and Hanafi Asr); Glasgow on 21 Jun 2026 gives a Fajr and an Isha (far-north rule); banner once per prayer within 15 minutes, not on title or settings; Pause and pray opens the pause menu; Later closes it; settings survive a restart. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside pm01-pm07 in `GAME/APPROVED/PRAYER_REMINDER/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
