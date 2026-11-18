---
id: DOC-TFG-0128
type: PLAN
status: CURRENT
feature: CHAPTER_1_END
purpose: Build brief, LOCK 39 - chapter 1 ends - trust kept
links: [DOC-TFG-0126, DOC-TFG-0127, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — CHAPTER 1 ENDS - TRUST KEPT — 9 Nov 2026 (LOCK 39, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 39 V2: spec DOC-TFG-0126, data `chapter1_end_data_V2.json`, masters ce01-ce02; LOCK 103 the six gates (DOC-TFG-0323) |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/CHAPTER_1_END/RECORD/CHAPTER_1_END_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/chapter1_end_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters ce01-ce02, and the builds of lines 2-45. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/chapter1_end_data_V2.json` byte for byte to `SOURCE/data/chapter1_end.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every choice path of every mission (effects, flags, What people say lines, done in the Journal); every person line at trust 10 / 50 / 80; buttons only in their hours and conditions. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `CHAPTER_1_END/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". V2: Idris now names the north-west gate and says Safira waits for when it opens. Nothing else changes. Build after line 41. Needs: none.

## Answer note — 2026-11-18 (QUESTIONS row 25)

**A.** Scene B becomes "The road north-west waits for the Gate of Patience." (fixed in `chapter1_end_data_V2.json`, not yet built; the masters' V1 lines are superseded, R12). The spec's dependency line now defers to the brief: line 41. Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
