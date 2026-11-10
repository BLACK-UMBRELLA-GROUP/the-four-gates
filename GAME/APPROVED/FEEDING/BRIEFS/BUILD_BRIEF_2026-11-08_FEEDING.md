---
id: DOC-TFG-0038
type: PLAN
status: CURRENT
feature: FEEDING
purpose: Build brief, LOCK 9 - feeding the poor at Salma's oven, in public or in secret
links: [DOC-TFG-0036, DOC-TFG-0037, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — FEEDING THE POOR — 8 Nov 2026 (LOCK 9, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 9 V1: spec DOC-TFG-0036, data `feeding_data_V1.json`, masters e01-e08 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 15 (if the line before is not BUILT, this line stays WAITING with "waits for line 15") |
| Build before | nothing |
| ROADMAP | No row finished (lifetime goals - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/FEEDING/RECORD/FEEDING_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/feeding_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters e01-e08, and the builds of lines 9-15. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/feeding_data_V1.json` byte for byte to `SOURCE/data/feeding.json`; one loader reads it |
| 3 | Button | Spec §2 (e01, e08) |
| 4 | Panel | Spec §3: options, pay, secret tick box only after `sirr` is learned, trust once per day for public payments, counter (e02-e06) |
| 5 | What people say | Spec §4 (e07) |
| T | Tests | Paying lowers coins and adds meals; not enough coins blocks; public payment +1 trust only once per game day; secret payment: no trust, no line; tick box only after page 1; button hidden while Salma is away; counter with thousands comma. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside e01-e08 in `GAME/APPROVED/FEEDING/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
