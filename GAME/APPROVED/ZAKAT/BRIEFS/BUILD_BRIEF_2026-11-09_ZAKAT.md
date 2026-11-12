---
id: DOC-TFG-0077
type: PLAN
status: CURRENT
feature: ZAKAT
purpose: Build brief, LOCK 22 - zakat: yearly due, masjid panel, recipients, private record
links: [DOC-TFG-0075, DOC-TFG-0076, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — ZAKAT — 9 Nov 2026 (LOCK 22, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 22 V1: spec DOC-TFG-0075, data `zakat_data_V1.json`, masters z01-z13 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 28 (if the line before is not BUILT, this line stays WAITING with "waits for line 28") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/ZAKAT/RECORD/ZAKAT_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/zakat_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters z01-z13, and the builds of lines 2-28 (lines 15, 25 and 28 are used). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/zakat_data_V1.json` byte for byte to `SOURCE/data/zakat.json`; one loader reads it |
| 3 | Zakat year | Spec §2 |
| 4 | Button and panel | Spec §3 and §4 |
| 5 | Record | Spec §5 |
| T | Tests | Nothing before day 354; due = ceil(coins/40) at ≥ 100 coins, else 0, recorded once per year; button rules per §3; paying takes the due once; not enough coins blocks paying; each recipient's text; record paid / due / not due; no trust, no What people say line. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside z01-z13 in `GAME/APPROVED/ZAKAT/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 11 Nov 2026 (QUESTIONS row 11)

Overlapping years follow spec Clarifications row 11: one year at a time, oldest unpaid first; receipt until exit; latest assessment when nothing is unpaid; record row shows the total still due. Add two test states on day index 708: (a) year 1 owes 8, year 2 owes 3 — pay 8 → button stays, record `due · 3 coins`; pay 3 → button gone, record `paid · 3 coins`; (b) year 1 owes 8, year 2 zero-due (60 held) — the panel serves the 8 first; after payment the zero-due notice stays until that day ends and the record reads `not due this year`. Prototype V73 menu: "LOCK 22 · Two years unpaid" and "LOCK 22 · Old debt, new year not due".
