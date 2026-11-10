---
id: DOC-TFG-0056
type: PLAN
status: CURRENT
feature: DRY_FOUNTAIN
purpose: Build brief, LOCK 15 - the dry fountain: pay in parts, name or no name, the fountain runs for good
links: [DOC-TFG-0054, DOC-TFG-0055, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE DRY FOUNTAIN — 9 Nov 2026 (LOCK 15, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 15 V1: spec DOC-TFG-0054, data `dry_fountain_data_V1.json`, masters o01-o09 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 21 (if the line before is not BUILT, this line stays WAITING with "waits for line 21") |
| Build before | nothing |
| ROADMAP | No row finished (wealth - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/DRY_FOUNTAIN/RECORD/DRY_FOUNTAIN_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/dry_fountain_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters o01-o09, and the builds of lines 2-21. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/dry_fountain_data_V1.json` byte for byte to `SOURCE/data/dry_fountain.json`; one loader reads it |
| 3 | Square bar | Spec §2 (o01, o07) |
| 4 | Panel | Spec §3 (o02-o04) |
| 5 | Runs | Spec §4 (o05, o06, o08, o09) |
| T | Tests | Name choice only on the first payment and fixed after; each payment −20 coins; blocked when coins < 20; done at 60; named +5 trust once and the What people say line in the right place; no name no trust and no line; days count from the finishing day; the button never returns. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside o01-o09 in `GAME/APPROVED/DRY_FOUNTAIN/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
