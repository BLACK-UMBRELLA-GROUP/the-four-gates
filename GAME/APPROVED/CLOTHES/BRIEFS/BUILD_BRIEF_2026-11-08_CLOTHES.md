---
id: DOC-TFG-0026
type: PLAN
status: CURRENT
feature: CLOTHES
purpose: Build brief, LOCK 5 - Layla's loom, the wardrobe, the leather bag and the carrying limit
links: [DOC-TFG-0024, DOC-TFG-0025, DOC-TFG-0023, AD-AIOS-115, AD-AIOS-131]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — CLOTHES AND A BIGGER BAG — 8 Nov 2026 (LOCK 5, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 5 V1: spec DOC-TFG-0024, data `clothes_data_V1.json` (every word and number; checked against all 15 masters), masters w01-w15 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 11 (if the line before is not BUILT, this line stays WAITING with "waits for line 11") |
| Build before | nothing |
| ROADMAP | Row "Clothes and inventory" (requested from Fable 8 Nov): tick it when this line is BUILT and close its GitHub issue against the source SHA. If the row does not exist yet, say so in the task note and tick nothing. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/CLOTHES/RECORD/CLOTHES_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/clothes_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters w01-w15, and the builds of lines 2-11. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/clothes_data_V1.json` byte for byte to `SOURCE/data/clothes.json`; one loader reads it |
| 3 | Loom | Spec §2: weaver's-lane button, Layla capsule, two-column panel, buying clothes once each, leather bag, not enough / bag full (w01-w05) |
| 4 | Wardrobe | Spec §3: replace LOCK 4's wear toggle with the wardrobe; traveller's clothes owned and worn at start; local clothes from Rashid join it; carrying count and capacity; full note; the stall and loom block buying when full (w06-w10) |
| 5 | What people say | Spec §4: the clothes lines, best clothes on Fridays only (w11-w15) |
| T | Tests | Start: traveller's clothes worn, pouch 6; buying clothes lowers coins once each; leather bag sets capacity 12 and is never blocked by a full bag; carried = bread + dates + unworn clothes; full bag blocks buying at both loom and stall; wearing changes only What people say (trust unchanged); best-clothes line only on Fridays; every LOCK 4 test that used the old wear toggle updated to the wardrobe and still passing. Add to `run_tests.gd`; the headless run must exit 0 |
| E | Evidence | Screenshots beside w01-w15 in `GAME/APPROVED/CLOTHES/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
