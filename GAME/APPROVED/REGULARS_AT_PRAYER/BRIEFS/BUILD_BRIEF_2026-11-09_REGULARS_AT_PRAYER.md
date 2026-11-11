---
id: DOC-TFG-0092
type: PLAN
status: CURRENT
feature: REGULARS_AT_PRAYER
purpose: Build brief, LOCK 27 - the regulars go to prayer at Dhuhr and Asr
links: [DOC-TFG-0090, DOC-TFG-0091, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE REGULARS GO TO PRAYER — 9 Nov 2026 (LOCK 27, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 27 V1: spec DOC-TFG-0090, data `regulars_at_prayer_data_V1.json`, masters ra01-ra08 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 33 (if the line before is not BUILT, this line stays WAITING with "waits for line 33") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/REGULARS_AT_PRAYER/RECORD/REGULARS_AT_PRAYER_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/regulars_at_prayer_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters ra01-ra08, and the builds of lines 2-33 (lines 11, 13, 14 and 23 are changed). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/regulars_at_prayer_data_V1.json` byte for byte to `SOURCE/data/regulars_at_prayer.json`; one loader reads it |
| 3 | Rule | Spec §1 - add "away at prayer" after LOCK 7's night and Friday checks |
| 4 | What shows | Spec §2 |
| T | Tests | Goers away 12:05-12:29 (Dhuhr, not on Fridays) and 15:30-15:54 (Asr, every day, Friday included); texts per place with the right prayer name; masjid line names in order; stall and loan hidden while away; Salma and Layla never away at prayer; Friday Dhuhr unchanged (LOCK 7, ra08); Friday 15:40 goers away for Asr; nothing scored. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside ra01-ra08 in `GAME/APPROVED/REGULARS_AT_PRAYER/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 11 Nov 2026 (QUESTIONS row 12)

Row T corrected to match spec §1 and the locked data: only Friday Dhuhr is left to LOCK 7. On Fridays the Asr window (15:30-15:54) applies like any day - goers away, stall shut for Asr, loan bar hidden, Masjid line shown. Add a Friday 15:40 test. See spec Clarifications row 12.
