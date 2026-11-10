---
id: DOC-TFG-0107
type: PLAN
status: CURRENT
feature: GATE_OF_TRUST
purpose: Build brief, LOCK 32 - the Gate of Trust opens, the road east and Jisra
links: [DOC-TFG-0105, DOC-TFG-0106, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THROUGH THE GATE OF TRUST: JISRA — 9 Nov 2026 (LOCK 32, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 32 V1: spec DOC-TFG-0105, data `gate_of_trust_data_V1.json`, masters gj01-gj12 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 38 (if the line before is not BUILT, this line stays WAITING with "waits for line 38") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/GATE_OF_TRUST/RECORD/GATE_OF_TRUST_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/gate_of_trust_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters gj01-gj12, and the builds of lines 2-38. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/gate_of_trust_data_V1.json` byte for byte to `SOURCE/data/gate_of_trust.json`; one loader reads it |
| 3 | Gate bar | Spec §2 |
| 4 | Opening and road | Spec §3, §4 (a greybox road scene is not needed: the move is one step that advances the clock) |
| 5 | Jisra | Spec §5 - a second place with its own trust value; River Market trust unchanged |
| 6 | Toll scene | Spec §6 |
| T | Tests | No gate button below trust 100 or without the scales lesson; the opening is remembered; road ±90 minutes; meter label and value switch in Jisra and back; speak +5, pay −3 coins +3, quiet 0, once only; pay hidden under 3 coins; pray in Jisra recorded. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside gj01-gj12 in `GAME/APPROVED/GATE_OF_TRUST/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
