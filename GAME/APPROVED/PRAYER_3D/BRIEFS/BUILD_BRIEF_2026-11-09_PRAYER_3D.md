---
id: DOC-TFG-0309
type: PLAN
status: CURRENT
feature: PRAYER_3D
purpose: Build brief, LOCK 99 - the prayer in 3D
links: [DOC-TFG-0307, DOC-TFG-0308, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE PRAYER IN 3D — 9 Nov 2026 (LOCK 99, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 99 V1: spec DOC-TFG-0307, data `prayer_3d_data_V1.json`, masters fb01-fb01 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner, BUILT) - chain removed 17 Nov (Founder: "it should do some even if there others blockers"; charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PRAYER_3D/RECORD/PRAYER_3D_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/prayer_3d_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters fb01-fb01, and the builds of lines 2-105. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/prayer_3d_data_V1.json` byte for byte to `SOURCE/data/prayer_3d.json`; read by the feature it describes |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every condition and choice in the data; counters and goals in the Journal; nothing changes trust unless the data says so. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/PRAYER_3D/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Answer note — 2026-11-18 (QUESTIONS row 58)

**Placement A**: the masters' highlight is illustrative. Rows of 9, front row first, each row filling from the middle out, right before left at equal distance; the player takes the next free slot after the regulars present. **Panel**: the card is the design reference, not a screen; no card ships. **Prayer**: only an on-time congregational prayer at a masjid plays the sequence; make-up, Tarawih, night prayer and Eid keep their current hooks. The prayer record and feedback appear as now (immediately); the sequence then plays, any key skips, and it returns to where you prayed. T checks the existing record and masjid updates only. Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.

## Answer note — 2026-11-18 (QUESTIONS row 62)

**A.** Only attendance that already exists counts: at the River Market masjid, LOCK 27's goers (Rashid, Jamal, Old Musa) for Dhuhr and Asr, and at Friday prayer everyone LOCK 7 sends to the masjid; at every other masjid and prayer no regulars are defined, so zero precede the player, who takes the first slot (front row, middle). The full crowd is a look for Unreal (runner contract R11). Line 106 back to WAITING. Needs: none.
