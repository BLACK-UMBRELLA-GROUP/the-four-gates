---
id: DOC-TFG-0303
type: PLAN
status: CURRENT
feature: STARS
purpose: Build brief, LOCK 97 - the stars of Najmara
links: [DOC-TFG-0301, DOC-TFG-0302, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE STARS OF NAJMARA — 9 Nov 2026 (LOCK 97, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 97 V2: spec DOC-TFG-0301, data `stars_data_V2.json`, masters nc01-nc10; reissued for LOCK 103 the six gates (DOC-TFG-0323) - no change to this LOCK's data |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | lines 47, 54 (Safira and Najmara) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/STARS/RECORD/STARS_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/stars_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters nc01-nc10, and the builds of lines 2-103. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/stars_data_V2.json` byte for byte to `SOURCE/data/stars.json`; read by the feature it describes |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `STARS/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". No change to this LOCK's words or numbers. The six gates (LOCK 103) change only which line it builds after; held 16 Nov and released now. Build after lines 47, 54. Needs: none.

## Answer note — 2026-11-18 (QUESTIONS row 56)

**A.** (1) After lines 47 and 54 as briefed (fixtures if not built, R9). (2) Goal "Stars you can find your way by" n / 12, counter `stars`, now in `stars_data_V2.json`; the ten lessons plus the Safira and Najmara branch awards. (3) Lesson 1 opens after `qibla_done` (either qibla choice); each next lesson one day after the previous (`after_days` 1), at `words.hours` (the spec's `star_words.hours` means this); confirming records the star (flag and +1) and the day; leaving before confirming records nothing. Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
