---
id: DOC-TFG-0013
type: PLAN
status: CURRENT
feature: IDENTITY
purpose: Build brief, LOCK 2 part 1 - apply the LOCK 1 renames, add the identity data, the Inn and Masjid places, the new city map (five parts, four virtue gates), the world map and the Ilmara title
links: [DOC-TFG-0011, DOC-TFG-0012, DOC-TFG-0006, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — ILMARA: NAMES, MAPS, INN AND MASJID PLACES — 6 Nov 2026, reissued 8 Nov (LOCK 2, part 1 of 4)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 2 V3 (spec V4): spec DOC-TFG-0011, data `identity_data_V3.json` (every word and number; checked against all 30 masters), masters g01, g11, g12, g13, g14, g15 |
| Founder's words | "LOCK it (Recommended)" (6 Nov 2026); placeholder shapes only ("the visual aint importantn") |
| Build after | line 4 (if the line before is not BUILT, this line stays WAITING with "waits for line 4") |
| Build before | line 6 |
| ROADMAP | No row finished; "First district" advanced (inn and masjid places). Say so in the task note. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/IDENTITY/RECORD/IDENTITY_SPEC_CURRENT_VERSION_V5.md` (all), `RECORD/identity_data_V3.json`, `RECORD/LOCK_RECORD.md`, the masters named above in `MASTERS/`, and the LOCK 1 pack you built in lines 2-4. Check them first; report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION (charters rule 10) |
| 2 | Data | Copy `RECORD/identity_data_V3.json` byte for byte to `SOURCE/data/identity.json`. Apply to `SOURCE/data/foundations.json` only the spec §7 rows marked **line 5** (the five text renames, `goal.gates` and the city map). Leave `numbers.start_coins` (line 6) and the T switch and wait buttons (line 7) exactly as LOCK 1 built them. Reissued 8 Nov - answers QUESTIONS row 2 |
| 3 | Places | Add the Inn and the Masjid from `layout_additions` to River Market (points, streets, bars, house blocks moved out of the way). Their actions come in lines 6-8; until then they show `ui.not_built` from foundations data |
| 4 | City map | Replace the old round-city map with the five-part map (g12): parts and lines from `city.parts`, gates from `city.gates`, tap a part → its line (g13), the Gate of Trust green when open (g14), "Your inn · tap" opens River Market |
| 5 | World map | g11: the city in the middle with "You land here", the 12 placeholder towns and their toast, buttons ‹ Title / City map / River Market |
| 6 | Title | g01: THE FOUR GATES, the city name, the tagline; Begin goes to the market map until line 6 adds the arrival |
| T | Tests | Renamed words appear: no "Khurasan" or "round city" in `SOURCE/data/foundations.json`, in any script or scene, or anywhere the player can see. Exempt: the `renames_in_foundations_data` list inside `SOURCE/data/identity.json`, which keeps the old names on purpose as the record of what was renamed (byte-for-byte copy of the locked data - answers QUESTIONS row 3, 8 Nov); the Inn and Masjid exist and are reachable on the streets; tapping each city part shows its line; the East gate shows open only when the LOCK 1 gate rule is met. Add them to `res://tests/run_tests.gd`; `godot --headless --path SOURCE --script res://tests/run_tests.gd` must exit 0, with every LOCK 1 test still passing (update only the LOCK 1 tests whose words the renames change) |
| E | Evidence | Screenshots beside masters g01, g11, g12, g13, g14, g15 (`<master>__master_beside_build.png`). Expected g15 differences in this line, to be named in the task note: the HUD shows LOCK 1 coins and trust with no clock box (clock is line 7, coins from the arrival line 6); the bar keeps the LOCK 1 "Wait until night/day" button; Inn and Masjid show `ui.not_built`. Save into `GAME/APPROVED/IDENTITY/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
