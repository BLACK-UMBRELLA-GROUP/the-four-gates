---
id: DOC-TFG-0228
type: PLAN
status: CURRENT
feature: PAGES_CH09
purpose: Build brief, LOCK 72 - the scholar's notebook, chapter 9 (knowledge and patience, pages 81-90)
links: [DOC-TFG-0226, DOC-TFG-0227, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE SCHOLAR'S NOTEBOOK, CHAPTER 9 (KNOWLEDGE AND PATIENCE, PAGES 81-90) — 9 Nov 2026 (LOCK 72, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 72 V1: spec DOC-TFG-0226, data `pages_ch09_data_V1.json`, masters pi01-pi20; reissued for LOCK 103 the six gates (DOC-TFG-0323) - no change to this LOCK's data |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only; reissued 17 Nov 2026 after LOCK 103, clickable "LOCK it (Recommended)" |
| Needs | none (charters rule 15) |
| Build after | lines 71, 53, 54, 55 (the notebook and the west towns) - set 17 Nov in the LOCK 103 reissue (charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PAGES_CH09/RECORD/PAGES_CH09_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/pages_ch09_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters pi01-pi20, and the builds of lines 2-78. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/pages_ch09_data_V1.json` byte for byte to `SOURCE/data/pages_ch09.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every page: find button only with its flags and the page before found; take sets found; the read button offers the lowest unread found page only; reading counts +1 and shows the chapter story on its last page; pages goal reaches 99 before the finale. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | `BUILD.json` and the line's checks file in `PAGES_CH09/BUILT/V1/` (under `GAME/APPROVED/`). No native Godot window or screenshots (QUESTIONS 15); the masters are reference only |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Reissue note — 17 Nov 2026 (LOCK 103, the six gates)

Founder 17 Nov: "LOCK it (Recommended)". No change to this LOCK's words or numbers. The six gates (LOCK 103) change only which line it builds after; held 16 Nov and released now. Build after lines 71, 53, 54, 55. Needs: none.
