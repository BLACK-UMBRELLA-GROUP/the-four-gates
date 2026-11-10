---
id: DOC-TFG-0041
type: PLAN
status: CURRENT
feature: SEALED_PURSE
purpose: Build brief, LOCK 10 - the sealed purse: Karim's job, the coin, delivery to Abbas at the gate
links: [DOC-TFG-0039, DOC-TFG-0040, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE SEALED PURSE — 8 Nov 2026 (LOCK 10, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 10 V1: spec DOC-TFG-0039, data `sealed_purse_data_V1.json`, masters h01-h10 |
| Founder's words | "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 16 (if the line before is not BUILT, this line stays WAITING with "waits for line 16") |
| Build before | nothing |
| ROADMAP | No row finished (chapter missions - say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/SEALED_PURSE/RECORD/SEALED_PURSE_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/sealed_purse_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters h01-h10, and the builds of lines 2-16. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/sealed_purse_data_V1.json` byte for byte to `SOURCE/data/sealed_purse.json`; one loader reads it |
| 3 | Offer | Spec §1 (h01, h02, h10); Karim capsule at the quay |
| 4 | Coin | Spec §2 (h03, h04) |
| 5 | Delivery | Spec §3 (h05, h06, h08); Abbas capsule at the gate |
| 6 | What people say | Spec §4 (h07, h09) |
| T | Tests | Offer only at trust ≥ 40, in Karim's hours, not at Friday prayer, until accepted; refuse keeps the offer; keep adds 1 coin; whole delivery +5 trust and +4 coins; short delivery −8 trust and no fee; the carrying line until delivery; job done once; What people say line per outcome. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside h01-h10 in `GAME/APPROVED/SEALED_PURSE/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
