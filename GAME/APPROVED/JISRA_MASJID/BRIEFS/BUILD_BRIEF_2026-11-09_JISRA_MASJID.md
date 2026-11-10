---
id: DOC-TFG-0110
type: PLAN
status: CURRENT
feature: JISRA_MASJID
purpose: Build brief, LOCK 33 - Jisra's masjid and the masjids-prayed-in count
links: [DOC-TFG-0108, DOC-TFG-0109, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — JISRA'S MASJID AND MASJIDS PRAYED IN — 9 Nov 2026 (LOCK 33, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 33 V1: spec DOC-TFG-0108, data `jisra_masjid_data_V1.json`, masters jm01-jm08 |
| Founder's words | "OK LOCK IT ..." (9 Nov 2026); placeholder shapes only |
| Build after | line 39 (if the line before is not BUILT, this line stays WAITING with "waits for line 39") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/JISRA_MASJID/RECORD/JISRA_MASJID_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/jisra_masjid_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters jm01-jm08, and the builds of lines 2-39. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/jisra_masjid_data_V1.json` byte for byte to `SOURCE/data/jisra_masjid.json`; one loader reads it |
| 3 | Jisra bar | Spec §2 |
| 4 | Masjid | Spec §3 - reuse the LOCK 2 prayer code; do not copy it |
| 5 | Count | Spec §4 - saved with the game (LOCK 29 save slot) |
| T | Tests | Congregation until iqamah + 5, on your own at the masjid after; Uthman's line after the first prayer only; count adds each masjid once; bridge prayer not counted; counter rows appear at n ≥ 1; no trust change. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside jm01-jm08 in `GAME/APPROVED/JISRA_MASJID/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
