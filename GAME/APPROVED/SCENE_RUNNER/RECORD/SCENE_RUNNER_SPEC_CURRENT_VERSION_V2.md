---
id: DOC-TFG-0111
type: SPEC
status: CURRENT
feature: SCENE_RUNNER
purpose: LOCK 34 - one data-driven scene runner for every later mission, a town model (people, work, masjid, inn, own trust and What people say) and a private Journal
links: [AD-AIOS-115, DOC-TFG-0105, DOC-TFG-0108, DOC-TFG-0112]
owner: THE FOUR GATES chat
---

# SCENE RUNNER SPEC — CURRENT VERSION V2 (LOCK 34)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `scene_runner_data_V2.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 trust, LOCK 2 prayer, LOCK 3 What people say, LOCK 6 talking, LOCK 8 All your prayers, LOCK 18 clock, LOCK 32 Jisra, LOCK 33 masjids. Queue line 41 builds after the lines named in its brief (17 Nov reissue) |
| Masters | `../MASTERS/sr01`-`sr02` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | - |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none in this LOCK |

## 2. The scene runner

A mission is data: `id`, `title`, `kicker`, `button`, where (`town` + hub, or a River Market `place`), when (`hours` [from, to] in minutes of the day, `min_trust`, `after` flags, `not` flags, `after_days` {flag: days}), `repeat` (`daily` or once), `main` / `side`, `start` scene, `scenes`, `say` lines.

| Part | Rule |
|---|---|
| Button | Shown on the place bar (River Market) or the town hub while every condition holds; `main` missions use the main button style |
| Scene | `kicker`, `title`, `text` (one or more paragraphs), `choices` - or no choices: one Back button |
| Choice | `label`, optional `need_coins` / `min_trust` / `if` / `unless` (hidden when not met), `go` (next scene; none = leave), `fx` |
| Effects (`fx`) | `coins`, `trust` (the mission's town; River Market when none), `trust_rm`, `flag`/`unflag` (a flag remembers the day it was set), `say` (adds that What people say line once, in the mission's town), `count` (meals, qurans, children or a named counter), `minutes` (clock advances), `done` |
| End | A scene with `end` marks the mission done when you leave it (Journal) |
| Flags | `toll:speak` / `toll:pay` / `toll:quiet` read LOCK 32's toll choice; `gate_opened` reads LOCK 32 |

## 3. Towns

A town is data: `name`, `gate`, `start_trust` (10), `inn` (coins a night), `kicker`, `text`, `work` {label, hours, minutes, coins, trust once a day}, `masjids`, people (by `town`).

| Part | Rule |
|---|---|
| Trust | Each town keeps its own trust (0-100), starting at `start_trust`; the meter reads `Trust · {town}` |
| People | `words.people` list; each person `hours` (away outside them) and `prays` (away at Friday prayer); talking shows `lines` by town trust - wary below `wary_below` (30), friendly below `warm_from` (70), warm - then the first `memory` line whose flag is set |
| Work | Clock + `minutes`, coins + `coins`, town trust + `trust` the first time each day |
| Inn | Pay `inn` coins (or sleep outside without coins) and wake at `wake` (04:40) |
| What {town} says | The town's `say` lines from missions and `town_says` |
| Masjid | LOCK 33 rules exactly; each masjid counts once |
| Jisra | Keeps its LOCK 32 panel; the town buttons are added after the masjid button |

## 4. The Journal (private)

`words.journal`: from the River Market bar (`journal_button`). Chapters (`chapters`: number, name, mission ids; LOCKs 3, 10 and 32 missions are read from their own state via `chapter_builtin`), each with n / m done and each mission's title once done (`…` and `not_yet` before); side missions done n / m; lifetime `goals` with their counters. No trust, no What people say.


## Masters

- `sr01_journal__empty.png`
- `sr02_journal__progress.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Walking around inside towns (a town is a hub of buttons for now); quests that span towns at once; a mission log with hints.

## Build rules

Words and numbers only from `scene_runner_data_V2.json` (copied byte for byte to `SOURCE/data/scene_runner.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## V2 change (17 Nov 2026, QUESTIONS 16)

`words.people.talk` ("Talk") is the button beside each person who is about in a town's people list (master jp02). Nothing else changes. Line 42 copies V2 over `SOURCE/data/scene_runner.json`.

## Runner and town contract (18 Nov 2026, answers QUESTIONS 18-61)

The prototype's runner is the design reference. The generic Godot runner honours every field below wherever a locked pack uses it; no pack needs its own code for them. Copy every pack byte for byte.

| # | Rule |
|---|---|
| R1 Mission conditions | `hours` [from, to] in minutes of the day, may cross midnight; null or absent = any time. `friday: true` = Fridays only. `days` = weekday numbers with Sunday 0 (Monday 1 … Saturday 6); day index 0 of the game is a Thursday, so weekday = (day index + 4) mod 7. `not_friday_prayer`. `min_count` {counter: n}. `stale` {mission (one id or a list - the latest done day of any), days, flag (used when none of the missions is done yet)} = shown only when that many days have passed. `min_trust` (the mission's town). `after` / `not` flags. `after_days` {flag: n} = n days after the day the flag was set. `repeat: "daily"` = again the next day. `repeat_days: n` = a done mission opens again n days after the day it was last done (each interval counts from the last time) |
| R2 Scenes and choices | Scene kicker and title fall back to the mission's (Q17). A scene with `end: true` marks the mission done when you leave it and applies its `fx_end` once. Choices: `need_coins`, `min_trust`, `if`, `unless`; a choice that costs coins (negative `fx.coins`) is also hidden while you have fewer coins than it costs, with or without `need_coins` |
| R3 Effects | `coins` (never below 0), `trust` (the mission's town, or `trust_town`), `trust_rm`, `flag` (remembers the day it was set), `unflag`, `say` (once per mission and key, in the mission's town or `say_town`), `count` (meals, qurans, children or any named counter), `name` (learns that Name of Allah), `minutes`, `sleep` (wake at the next 04:40), `done` |
| R4 Special flags | `girl` = the player chose the girl (saved `gender`; boy until the boy/girl screen of LOCK 2 is designed - tests cover both); `met_teacher`; `sirr` = the learned word from page 1 (LOCK 3); `toll:speak`/`toll:pay`/`toll:quiet`; `gate_opened` |
| R5 Lowest-first lists | Missions with `kind: "page_read"` offer only the lowest found unread page; `kind: "name_read"` offer only the lowest in their `group` |
| R6 Towns | Masjids may be listed by id: the runner resolves the id in the loaded masjid records (inline or separate) and counts the prayer by that id. A town masjid's return button is **Back** to the place it was opened from; "Back to the bridge" is Jisra's only (masters that show it elsewhere are a prototype slip). Hub actions in this order: open missions, Talk to people, the work button, What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn, Road map. Road map is the exit; "Back to Ilmara" shows only while no road map is loaded. A person with `hours: null` is about at any hour |
| R7 People | When two or more people are at one place, each gets its own Talk button, in their LOCK 6 order |
| R8 Journal | Rows: the chapters in the loaded data, side missions n / m, and every goal record in the loaded data. A main mission that is in no chapter list (a follow-up) has no row: check its saved completion and hidden button. Private counters (lies, cheats) stay internal |
| R9 Prerequisites from lines not yet built | When a pack needs a flag or place that another queue line produces, build it now: test it headlessly with a fixture that sets the flag or loads that pack's data file; in live play it stays closed until the producing line ships. This is not a reason to stop (charters rule 15) |
| R10 Road map | A road whose destination town is not loaded shows `not open yet`; once the town is loaded the locked gate and flag rules apply (Q22 A) |
| R11 Look (Q15) | Rules-only Godot build: keep the existing Godot layout and buttons; do not build new layouts to match masters. The masters are reference for words and order only. The look is made in Unreal |
| R12 Masters with older words | Where a master shows words that differ from the locked data (four gates, V1 lines), the data wins |

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 | Journal chapters come from the loaded data in `n` order; a later file's chapter with the same `n` replaces the earlier one. Line 41 shows Chapter 1 only (2 arrives with line 49, 3 with 52, 4 with 55, 5 with 56). A chapter mission with no data yet is not done (`…` · not yet found). sr01/sr02 picture the finished game: line 41 targets are J1 (new game: 0 / 7, side 0 / 0, goals 0) and J2 (purse, grab, sealed purse done: 3 / 7). Jisra shows only its LOCK 32 panel (toll, masjid, prayer, back) until its town data arrives (line 42); the town buttons are generic code that appear only with data. Tests may use fixtures kept under the tests folder, never in `SOURCE/data`. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 34 under the Founder's blanket LOCK (9 Nov) |
| 2026-11-17 | V2 | QUESTIONS 16: words.people.talk = "Talk", the button beside each person in a town's people list (as master jp02 and the prototype show). answers Codex's QUESTIONS 16 inside the LOCK 103 reissue |
| 2026-11-18 | V2 | Runner and town contract R1-R12 recorded from the prototype runner (answers QUESTIONS 18-61); no data change |
