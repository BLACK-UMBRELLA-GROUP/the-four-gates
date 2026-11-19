---
id: DOC-TFG-0204
type: PLAN
status: CURRENT
feature: PAGES_CH01
purpose: Build brief, LOCK 64 - the scholar's notebook, chapter 1 (intention and foundations, pages 2-10)
links: [DOC-TFG-0202, DOC-TFG-0203, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# BUILD BRIEF — THE SCHOLAR'S NOTEBOOK, CHAPTER 1 (INTENTION AND FOUNDATIONS, PAGES 2-10) — 9 Nov 2026 (LOCK 64, 1 part)

**Copy exactly. No improvements. Unclear or conflicting → stop and report** (in `GAME/APPROVED/QUESTIONS.md`, line to QUESTION).

| Field | Value |
|---|---|
| Built from | LOCK 64 V2: spec DOC-TFG-0202, data `pages_ch01_data_V2.json`, masters pa01-pa18 |
| Founder's words | Blanket LOCK, 9 Nov 2026 (see the LOCK record); placeholder shapes only |
| Needs | none (charters rule 15) |
| Build after | line 41 (the scene runner, BUILT) - chain removed 17 Nov (Founder: "it should do some even if there others blockers"; charters rule 15, AD-AIOS-154) |
| Build before | nothing |
| ROADMAP | No row finished (say so in the task note). |

| # | Step | Detail |
|---|---|---|
| 1 | Read | `GAME/APPROVED/PAGES_CH01/RECORD/PAGES_CH01_SPEC_CURRENT_VERSION_V2.md` (all), `RECORD/pages_ch01_data_V2.json`, `RECORD/LOCK_RECORD.md`, masters pa01-pa18, and the builds of lines 2-70. Report any problem in `GAME/APPROVED/QUESTIONS.md` and set this line to QUESTION |
| 2 | Data | Copy `RECORD/pages_ch01_data_V2.json` byte for byte to `SOURCE/data/pages_ch01.json`; the LOCK 34 runner loads it with the other content files - no new code unless the spec says so |
| 3 | Build | Everything in the spec, in order |
| T | Tests | Every page: find button only with its flags and the page before found; take sets found; the read button offers the lowest unread found page only; reading counts +1 and shows the chapter story on its last page; pages goal reaches 99 before the finale. Check the words. Add to `run_tests.gd`; the headless run must exit 0 with every earlier test passing |
| E | Evidence | Screenshots beside the masters in `GAME/APPROVED/PAGES_CH01/BUILT/V1/` with a `BUILD.json`. No exports or compiled builds |
| N | Task note | "Built from: <paths>", what matches, any difference, public checks A-F, the commit |
| Q | Queue | Mark this line BUILT (or FAILED) in `GAME/APPROVED/BUILD_QUEUE.md` |

Rules that always apply: text scene files only; no file over 50 MB; nothing from the keys folder; every word and number read
from the data files at run time.

## Answer note — 16 Nov 2026 (QUESTIONS row 15)

Founder: "Skip Godot pictures, rules tests only (Recommended)". Do not open the Godot window or take native screenshots for this line. Row E means: `BUILD.json` and the line's checks file in `BUILT/V1/`, with the full headless run passing. The masters stay the design reference only.

## Answer note — 2026-11-18 (QUESTIONS row 36)

**A.** Yes - one shared page adapter, exactly as the prototype: each page record makes `page_<n>` (kind page_find, at its town hub or place, title "Page n", `find_kicker`, `find_button` with {p}, `hours`, its `after`, one scene with `found` and `take` → flag `page_<n>_found`, done) and `read_<n>` (kind page_read, River Market masjid, title = chapter title, `read_kicker` {n}, `read_button`, after `page_<n>_found`, not `page_<n>_read`; text: the saying, the `idris` line, and on a chapter's last page the `story`; `read_turn` → flag `page_<n>_read`, count pages +1, done). Only the lowest found unread page is offered (R5). Page 1 is LOCK 3's `sirr` (counts as found and read). Goal "The scholar's pages" n / 100 is in `pages_ch01_data_V2.json` (page 100 is the last page, LOCK 51). Each pages line tests its own pages and the count rising by them; no line has to reach 99 live. Contract: the runner and town contract in `SCENE_RUNNER/RECORD/SCENE_RUNNER_SPEC_CURRENT_VERSION_V2.md` (R1-R12). No native pictures (Q15). Needs: none.
