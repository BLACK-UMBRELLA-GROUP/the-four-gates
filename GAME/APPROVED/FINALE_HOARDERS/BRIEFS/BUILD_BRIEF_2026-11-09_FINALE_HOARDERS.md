---
id: DOC-TFG-0159
type: PLAN
status: CURRENT
feature: FINALE_HOARDERS
purpose: Build brief, LOCK 49 - the hard year: the hoarders and the bread lines
links: [DOC-TFG-0157, DOC-TFG-0158, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE HARD YEAR: THE HOARDERS AND THE BREAD LINES — 9 Nov 2026 (LOCK 49, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 49 V2: spec DOC-TFG-0157, data `finale_hoarders_data_V2.json`, masters h101-h111; LOCK 103 the six gates (DOC-TFG-0323) |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner and LOCK 9, BUILT) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/FINALE_HOARDERS/RECORD/FINALE_HOARDERS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/finale_hoarders_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters h101-h111, and the builds of lines 2-55. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/finale_hoarders_data_V2.json` byte for byte to `SOURCE/data/finale_hoarders.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every choice path of every mission (effects, flags, What people say lines, done in the Journal); every person line at trust 10 / 50 / 80; buttons only in their hours and conditions. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `FINALE_HOARDERS/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". V2: the hard year starts after `chapter6_done` and is Journal chapter 7. Tests set the flag (chapters 5-6 come in later LOCKs). Build after line 41. Needs: none.
