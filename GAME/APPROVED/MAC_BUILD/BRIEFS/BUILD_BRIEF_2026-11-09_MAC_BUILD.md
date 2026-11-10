---
id: DOC-TFG-0315
type: PLAN
status: CURRENT
feature: MAC_BUILD
purpose: Build brief, LOCK 101 - the Mac build
links: [DOC-TFG-0313, DOC-TFG-0314, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE MAC BUILD — 9 Nov 2026 (LOCK 101, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 101 V1: spec DOC-TFG-0313, data `mac_build_data_V1.json`, masters none-none |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Build after | line 107 (if the line before is not BUILT, this line stays WAITING with "waits for line 107") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/MAC_BUILD/RECORD/MAC_BUILD_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/mac_build_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters none-none, and the builds of lines 2-107. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/mac_build_data_V1.json` byte for byte to `SOURCE/data/mac_build.json`; read by the feature it describes |
| 3 | Build | Everything in the spec, in order |
| T | Tests | The export runs headless and writes BUILDS/mac/The Four Gates.app; BUILDS/ is ignored by git; all earlier tests pass. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/MAC_BUILD/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
