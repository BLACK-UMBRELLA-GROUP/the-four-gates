---
id: DOC-TFG-0054
type: SPEC
status: CURRENT
feature: DRY_FOUNTAIN
purpose: LOCK 15 - wealth, the dry fountain - paying 60 coins in parts to make River Market's fountain run again, with or without your name; the first fountain collectible
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0017, DOC-TFG-0055]
owner: THE FOUR GATES chat
---

# DRY FOUNTAIN SPEC — CURRENT VERSION V1 (LOCK 15)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `dry_fountain_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (trust, coins, task board), LOCK 3 (public and secret giving, What people say). Queue line 22 comes after line 21 |
| Masters | `../MASTERS/o01`-`o09` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V56 |
| ROADMAP | No row (wealth); noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder's collectible (6 Nov: "Dry fountains (sabil)") | Dry public fountains you pay to repair so people can drink. This is the first one, in River Market's square |
| Secret giving earns no visible trust (LOCK 3) | With no name, nobody knows: no trust and no What people say line |
| The game never plays God | The result is people drinking and talking, nothing else |

Design reference (not shown in the game): charity that continues (sadaqah jariyah), Sahih Muslim 1631. Hasan the mason is a new name (text only).

## 2. The square bar (masters o01, o07)

At the Task board (the square), always (any time of day): before the fountain runs, `board_button` (o01); after, the line `running` with n = days since the day it was finished (0 on that day) (o07). The button sits before the LOCK 9 feeding button.

## 3. The panel (masters o02-o04)

`panel.kicker`, `panel.title`, `panel.text`, then `panel.paid` (n = coins paid so far). Buttons:

| State | Buttons |
|---|---|
| Nothing paid yet | `give_named` and `give_secret` (n = `part`, 20) (o02) |
| Something paid | `give` (n = 20) (o03) |
| Coins < 20 | `not_enough` instead of the give buttons (o04) |
| Always | `not_now` back to the market map |

The first payment fixes the choice (name or no name) for good. Each payment: coins − 20, paid + 20.

## 4. When it runs (masters o05, o06, o08, o09)

When paid reaches `cost` (60) the fountain is done and the panel shows `done` (o05, o08): text, then `done.named` or `done.secret`, then `done.count` (n = fountains repaired, 1), and `to_rep` / `to_map`.
Named: trust + `public_trust` (5) once, and What people say gains `say.named` (good) (o06), placed after the LOCK 13 lines and before the LOCK 14 Idris line. No name: no trust and no line (o09).

## 5. Masters

| Master | Shows |
|---|---|
| o01, o07 | Square bar before; after (runs 3 days) |
| o02-o04 | First choice; after 20 paid; not enough coins |
| o05, o06 | Water again with your name; What people say |
| o08, o09 | Water again with no name; What people say (no line) |

HUD coins in o04 (15) were set for the picture. Start: 198 coins, trust 45.

## 6. Not in this LOCK (do not build)

Other fountains and the total to collect (with the other quarters and towns), the 99 Names carved on fountains, water carriers, other people giving towards it, a fountain model (a placeholder shape is allowed but not required), a waqf.

## 7. Build rules

Words and numbers only from `dry_fountain_data_V1.json` (copied byte for byte to `SOURCE/data/dry_fountain.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 15. Founder 6 Nov: collectible "Dry fountains (sabil)"; 9 Nov: **"LOCK it (Recommended)"** after V55 |
