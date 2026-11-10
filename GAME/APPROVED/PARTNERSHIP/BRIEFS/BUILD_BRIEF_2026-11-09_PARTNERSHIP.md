---
id: DOC-TFG-0104
type: PLAN
status: CURRENT
feature: PARTNERSHIP
purpose: Build brief, LOCK 31 - a partnership with Layla
links: [DOC-TFG-0102, DOC-TFG-0103, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — A PARTNERSHIP WITH LAYLA — 9 Nov 2026 (LOCK 31, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 31 V1: spec DOC-TFG-0102, data `partnership_data_V1.json`, masters ps01-ps12 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 37 (if the line before is not BUILT, this line stays WAITING with "waits for line 37") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PARTNERSHIP/RECORD/PARTNERSHIP_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/partnership_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters ps01-ps12, and the builds of lines 2-37. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/partnership_data_V1.json` byte for byte to `SOURCE/data/partnership.json`; one loader reads it |
| 3 | Bar | Spec §2 |
| 4 | Offer | Spec §3 |
| 5 | Weekly share | Spec §4 |
| 6 | What people say | Spec §5 |
| T | Tests | Button only at trust ≥ 40 in Layla's hours; partner −60 coins; fixed refused −3 trust, never offered again; shares due every 7 days; weeks give +5, +3, 0 (bad-week text), +6, then repeat; What people say line per choice in the right place. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside ps01-ps12 in `GAME/APPROVED/PARTNERSHIP/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
