---
id: DOC-TFG-0095
type: PLAN
status: CURRENT
feature: REGULARS_REMEMBER
purpose: Build brief, LOCK 28 - one memory line per regular in the talk panel
links: [DOC-TFG-0093, DOC-TFG-0094, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE REGULARS REMEMBER — 9 Nov 2026 (LOCK 28, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 28 V1: spec DOC-TFG-0093, data `regulars_remember_data_V1.json`, masters rm01-rm17 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 34 (if the line before is not BUILT, this line stays WAITING with "waits for line 34") |
| Build before | nothing |
| ROADMAP | No new row (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/REGULARS_REMEMBER/RECORD/REGULARS_REMEMBER_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/regulars_remember_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters rm01-rm17, and the builds of lines 2-34 (line 13's talk panel is changed; the keys read state from lines 16, 18, 19, 22, 23, 31, 32, 33). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/regulars_remember_data_V1.json` byte for byte to `SOURCE/data/regulars_remember.json`; one loader reads it |
| 3 | Memory line | Spec §2 |
| T | Tests | For each regular, every key in order: the first true key's line shows, only one line, in the right place; secret pilgrim trips give the "someone" lines; nothing when no key is true. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside rm01-rm17 in `GAME/APPROVED/REGULARS_REMEMBER/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
