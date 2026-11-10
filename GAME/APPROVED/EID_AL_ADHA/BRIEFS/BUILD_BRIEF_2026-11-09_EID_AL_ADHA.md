---
id: DOC-TFG-0080
type: PLAN
status: CURRENT
feature: EID_AL_ADHA
purpose: Build brief, LOCK 23 - Eid al-Adha: sheep, Arafah fast, Eid prayer, sacrifice, Tashreeq, record
links: [DOC-TFG-0078, DOC-TFG-0079, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — EID AL-ADHA — 9 Nov 2026 (LOCK 23, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 23 V1: spec DOC-TFG-0078, data `eid_al_adha_data_V1.json`, masters a01-a18 |
| Founder's words | "LOCK it (Recommended)" (9 Nov 2026); placeholder shapes only |
| Build after | line 29 (if the line before is not BUILT, this line stays WAITING with "waits for line 29") |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/EID_AL_ADHA/RECORD/EID_AL_ADHA_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/eid_al_adha_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters a01-a18, and the builds of lines 2-29 (lines 16, 20, 25, 26 and 28 are used). Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/eid_al_adha_data_V1.json` byte for byte to `SOURCE/data/eid_al_adha.json`; one loader reads it |
| 3 | Sheep | Spec §3 |
| 4 | Arafah | Spec §4 |
| 5 | Eid and Tashreeq | Spec §5 |
| 6 | Sacrifice | Spec §6 |
| 7 | Record | Spec §7 |
| T | Tests | Sheep only 1-9 Dhu al-Hijjah 07:00-17:59, one sheep, 30 coins, Saeed's extra line only after telling him; Arafah intention 03:30-04:44 on the 9th and its line until 18:09; Eid line on the 10th; Eid prayer 06:30-08:59 once; sacrifice never before the prayer (or 09:00), allowed to the 13th before 18:10, meals +10 or +30, once; Tashreeq line 11-13; nothing on the 14th; record rows; no trust. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside a01-a18 in `GAME/APPROVED/EID_AL_ADHA/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
