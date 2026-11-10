---
id: DOC-TFG-0023
type: PLAN
status: CURRENT
feature: MARKET_STALL
purpose: Build brief, LOCK 4 - the market stall at the spice row, your bag, the extra change and bread for Faris
links: [DOC-TFG-0021, DOC-TFG-0022, AD-AIOS-115, AD-AIOS-131]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE MARKET STALL — 8 Nov 2026 (LOCK 4, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 4 V1: spec DOC-TFG-0021, data `market_stall_data_V1.json` (every word and number; checked against all 15 masters), masters s01-s15 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 10 (if the line before is not BUILT, this line stays WAITING with "waits for line 10") |
| Build before | nothing |
| ROADMAP | Row "Tasks and money": tick it when this line is BUILT (task board, wallet and now the shop) and close its GitHub issue against the source SHA. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/MARKET_STALL/RECORD/MARKET_STALL_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/market_stall_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters s01-s15, and the builds of lines 2-10. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/market_stall_data_V1.json` byte for byte to `SOURCE/data/market_stall.json`; one loader reads it |
| 3 | Stall | Spec §2: spice-row button, Rashid capsule, stall panel, buying, once-only clothes, not enough coins, the extra change on the first purchase, found out on a later day (s01-s08) |
| 4 | Bag | Spec §3: coins box opens the bag; rows; wear / take off (s09-s11) |
| 5 | Faris | Spec §4: quay button while holding bread, toast, +1 trust first time only, Faris capsule at the quay (s12-s13) |
| 6 | What people say | Spec §5: the four new lines in order (s14-s15) |
| T | Tests | Buying lowers coins by the price and adds to the bag; clothes once only; not enough coins blocks buying; first purchase only gives the extra 5 coins; give back: coins −5, trust +2; keep: no change that day, −3 trust once on the first stall visit of a later day; bread give: bread −1, +1 trust only the first time; quay button only while holding bread; What people say lines per state. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside s01-s15 in `GAME/APPROVED/MARKET_STALL/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
