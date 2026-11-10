---
id: DOC-TFG-0020
type: PLAN
status: CURRENT
feature: CHAPTER_1
purpose: Build brief, LOCK 3 part 2 - the bread grab, the first truth scene (see, be asked, answer) and its What people say line
links: [DOC-TFG-0017, DOC-TFG-0018, DOC-TFG-0019, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE BREAD GRAB — 7 Nov 2026 (LOCK 3, part 2 of 2)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 3 V1: spec DOC-TFG-0017, data `chapter1_data_V1.json`, masters c17-c25 |
| Founder's words | "let add lying ... get aksed and can lie or be honest" (6 Nov) and "LOCK it (Recommended)" (7 Nov 2026) |
| Build after | line 9 (if the line before is not BUILT, this line stays WAITING with "waits for line 9") |
| Build before | nothing (last line of LOCK 3) |
| ROADMAP | No row finished; "Characters and dialogue" advanced (choices that change how people treat you; the dialogue system comes in a later LOCK). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | Spec DOC-TFG-0017 (all), `RECORD/chapter1_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters c17-c25, and line 9's build. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Bread grab | Spec §4 in full: board bar button, the see panel with the Faris capsule running from the oven, the clock jump to 16:10 if earlier, the asked panel with four answers in data order, effects (trust, coins), after panel (`after.note` only for the lie), done state (c17-c24) |
| 3 | What people say | Add the answer's `say` line last (none for `quiet`) (c25) |
| T | Tests | Each answer's trust and coin effect; trust stays 0-100; coins never below 0; clock jumps to 16:10 only when earlier; note only after the lie; board button gone when done; What people say shows the right line per answer. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside c17-c25 in `GAME/APPROVED/CHAPTER_1/BUILT/V1/`; update `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
