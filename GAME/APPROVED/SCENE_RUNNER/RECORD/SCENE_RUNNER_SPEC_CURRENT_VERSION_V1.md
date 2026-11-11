---
id: DOC-TFG-0111
type: SPEC
status: CURRENT
feature: SCENE_RUNNER
purpose: LOCK 34 - one data-driven scene runner for every later mission, a town model (people, work, masjid, inn, own trust and What people say) and a private Journal
links: [AD-AIOS-115, DOC-TFG-0105, DOC-TFG-0108, DOC-TFG-0112]
owner: THE FOUR GATES chat
---

# SCENE RUNNER SPEC — CURRENT VERSION V1 (LOCK 34)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `scene_runner_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 trust, LOCK 2 prayer, LOCK 3 What people say, LOCK 6 talking, LOCK 8 All your prayers, LOCK 18 clock, LOCK 32 Jisra, LOCK 33 masjids. Queue line 41 comes after line 40 |
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

Words and numbers only from `scene_runner_data_V1.json` (copied byte for byte to `SOURCE/data/scene_runner.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 | Journal chapters come from the loaded data in `n` order; a later file's chapter with the same `n` replaces the earlier one. Line 41 shows Chapter 1 only (2 arrives with line 49, 3 with 52, 4 with 55, 5 with 56). A chapter mission with no data yet is not done (`…` · not yet found). sr01/sr02 picture the finished game: line 41 targets are J1 (new game: 0 / 7, side 0 / 0, goals 0) and J2 (purse, grab, sealed purse done: 3 / 7). Jisra shows only its LOCK 32 panel (toll, masjid, prayer, back) until its town data arrives (line 42); the town buttons are generic code that appear only with data. Tests may use fixtures kept under the tests folder, never in `SOURCE/data`. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 34 under the Founder's blanket LOCK (9 Nov) |
