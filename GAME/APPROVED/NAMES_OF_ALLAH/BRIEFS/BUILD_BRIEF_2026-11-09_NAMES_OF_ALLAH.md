---
id: DOC-TFG-0089
type: PLAN
status: CURRENT
feature: NAMES_OF_ALLAH
purpose: Build brief, LOCK 26 - the Names of Allah at three River Market places, private count
links: [DOC-TFG-0087, DOC-TFG-0088, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE NAMES OF ALLAH — 9 Nov 2026 (LOCK 26, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 26 V1: spec DOC-TFG-0087, data `names_of_allah_data_V1.json`, masters m01-m08 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 32 (if the line before is not BUILT, this line stays WAITING with "waits for line 32") |
| Build before | nothing |
| ROADMAP | No new row (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/NAMES_OF_ALLAH/RECORD/NAMES_OF_ALLAH_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/names_of_allah_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters m01-m08, and the builds of lines 2-32. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/names_of_allah_data_V1.json` byte for byte to `SOURCE/data/names_of_allah.json`; one loader reads it |
| 3 | Button | Spec §2 |
| 4 | Panel | Spec §3 - the Arabic shows with its marks, right to left |
| T | Tests | Button only after meeting Idris, only at the three places, once each; panel words per Name; count 1, 2, 3 of 99; no coins, no trust. Check the words (including the Arabic string). Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside m01-m08 in `GAME/APPROVED/NAMES_OF_ALLAH/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
