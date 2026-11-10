---
id: DOC-TFG-0032
type: PLAN
status: CURRENT
feature: MARKET_DAY
purpose: Build brief, LOCK 7 - opening hours, regulars away at night, Friday prayer closing
links: [DOC-TFG-0030, DOC-TFG-0031, AD-AIOS-115, AD-AIOS-131]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — RIVER MARKET'S DAY — 8 Nov 2026 (LOCK 7, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 7 V1: spec DOC-TFG-0030, data `market_day_data_V1.json`, masters d01-d10 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 13 (if the line before is not BUILT, this line stays WAITING with "waits for line 13") |
| Build before | nothing |
| ROADMAP | Row "First district": tick it when this line is BUILT and close its GitHub issue against the source SHA. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/MARKET_DAY/RECORD/MARKET_DAY_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/market_day_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters d01-d10, and the builds of lines 2-13. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/market_day_data_V1.json` byte for byte to `SOURCE/data/market_day.json`; one loader reads it |
| 3 | Hours | Spec §1: each person away before `open` and from `close`; the place bar shows the away text instead of talk, stall and loom buttons (d01-d05, d09, d10) |
| 4 | Friday | Spec §2: on Fridays from the adhan to iqamah + 5 everyone is away with the Friday texts; reopen after (d06-d08) |
| 5 | Bread grab | Spec §3: the board's bread-grab button only while Salma is not away |
| T | Tests | Each person's open/close boundaries (one minute before and at each time); Friday window start and end (not on other days); stall and loom refuse to open while away; talk refuses while away; bread grab hidden while Salma is away. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside d01-d10 in `GAME/APPROVED/MARKET_DAY/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
