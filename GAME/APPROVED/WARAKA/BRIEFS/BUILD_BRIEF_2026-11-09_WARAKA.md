---
id: DOC-TFG-0150
type: PLAN
status: CURRENT
feature: WARAKA
purpose: Build brief, LOCK 46 - Waraka, the copyist and the fake hadith seller
links: [DOC-TFG-0148, DOC-TFG-0149, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — WARAKA, THE COPYIST AND THE FAKE HADITH SELLER — 9 Nov 2026 (LOCK 46, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 46 V1: spec DOC-TFG-0148, data `waraka_data_V1.json`, masters wk01-wk21 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 52 (if the line before is not BUILT, this line stays WAITING with "waits for line 52") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/WARAKA/RECORD/WARAKA_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/waraka_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters wk01-wk21, and the builds of lines 2-52. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/waraka_data_V1.json` byte for byte to `SOURCE/data/waraka.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every choice path of every mission (effects, flags, What people say lines, done in the Journal); every person line at trust 10 / 50 / 80; buttons only in their hours and conditions. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/WARAKA/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
