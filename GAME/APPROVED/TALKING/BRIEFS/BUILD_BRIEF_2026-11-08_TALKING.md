---
id: DOC-TFG-0029
type: PLAN
status: CURRENT
feature: TALKING
purpose: Build brief, LOCK 6 - talking to five River Market regulars, lines by trust and memory, greeting with salam
links: [DOC-TFG-0027, DOC-TFG-0028, AD-AIOS-115, AD-AIOS-131]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — TALKING TO PEOPLE — 8 Nov 2026 (LOCK 6, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 6 V1: spec DOC-TFG-0027, data `talking_data_V1.json` (every word and number; checked against all 15 masters), masters t01-t15 |
| Founder's words | "lock 6" and "LOCK it (Recommended)" (8 Nov 2026); placeholder shapes only |
| Build after | line 12 (if the line before is not BUILT, this line stays WAITING with "waits for line 12") |
| Build before | nothing |
| ROADMAP | Row "Characters and dialogue": tick it when this line is BUILT and close its GitHub issue against the source SHA. |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/TALKING/RECORD/TALKING_SPEC_CURRENT_VERSION_V1.md` (all), `RECORD/talking_data_V1.json`, `RECORD/LOCK_RECORD.md`, masters t01-t15, and the builds of lines 2-12. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/talking_data_V1.json` byte for byte to `SOURCE/data/talking.json`; one loader reads it |
| 3 | People | Spec §2: capsules with name labels for Salma, Rashid, Layla, Jamal, Old Musa at their places (reuse any capsule already placed by lines 9-12); "Talk to {name}" on each place bar (t01) |
| 4 | Talk panel | Spec §3: header, tier line, memory line, reply or tip, greet once per person, ask, goodbye; +1 trust on the third different greeting (t02-t14) |
| 5 | What people say | Spec §4: "Greets everyone" after 3 different greetings (t15) |
| T | Tests | Tier by trust at 39/40/79/80; each memory line appears only in its state and none otherwise; greeting each person once only; +1 trust only on the third different person and never again; tips per person; goodbye returns to the market map; What people say line after 3 greetings. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside t01-t15 in `GAME/APPROVED/TALKING/BUILT/V1/` with a `BUILD.json` (commit SHA, Godot version, timestamp). No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.
