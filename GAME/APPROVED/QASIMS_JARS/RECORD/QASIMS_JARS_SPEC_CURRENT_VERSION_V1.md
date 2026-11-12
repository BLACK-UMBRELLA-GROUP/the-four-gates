---
id: DOC-TFG-0045
type: SPEC
status: CURRENT
feature: QASIMS_JARS
purpose: LOCK 12 - temptations, Qasim's jars - carrying wine from the quay for good money, with talk that builds up over the nights you do it
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0017, DOC-TFG-0042, DOC-TFG-0046]
owner: THE FOUR GATES chat
---

# QASIM'S JARS SPEC — CURRENT VERSION V1 (LOCK 12)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `qasims_jars_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (trust), LOCK 2 (clock, quay), LOCK 3 (What people say), LOCK 11 (night hours, the night rule, the build-up rule). Queue line 19 comes after line 18 |
| Masters | `../MASTERS/q01`-`q09` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V50 |
| ROADMAP | No row (temptations); noted for Fable |

## 1. Rules over everything (Founder, 6 Nov 2026)

| Rule | Meaning in this LOCK |
|---|---|
| Your choice, good money | "u get offerd to bring in illegal alcohol and thers good money involved u decided to do it or not". Qasim says plainly that it is wine; you are never tricked into it |
| The game never plays God | No accident, no bad luck. Every result comes from people talking |
| It builds up | The same build-up rule as the dice house (LOCK 11), counted on its own for this temptation |

Deen reference for the design (not shown in the game): the one who carries wine is among the ten cursed (Tirmidhi 1295); Quran 5:90.

## 2. Hours and the quay bar (masters q01, q02, q05, q06)

| Rule | Number / words |
|---|---|
| Open | From `open_from` (1170 = 19:30) until before `open_until` (285 = 04:45), every night. Nothing in the day (q01) |
| Night | The night is the day of the evening; a time before 04:45 belongs to the night before (as LOCK 11) |
| Button | At the Quay, `quay_button` while open and no run has been made this night (q02). Gone after a run that night (q05). Still there after walking away (q06) |

## 3. The offer and the run (masters q03, q04)

Panel `offer` (q03): `offer.carry` makes the run; `offer.no` returns to the market map at the Quay with nothing changed.
A run: coins + `pay` (20), the night is marked, runs + 1, then the panel `done` with `done.runs` (n = runs so far) and `done.to_map` (q04). No clock change.

## 4. Talk that builds up (masters q07-q09)

| Runs | What people say line (`say`) | Trust |
|---|---|---|
| 1 | none | none |
| `talk_from_runs` (2) to 3 | `say.talk` (mixed) (q07) | none |
| `seen_from_runs` (4) to 9 | `say.seen` (bad) (q08) | `seen_trust` (−5), once, on the 4th run |
| `smuggler_from_runs` (10) or more | `say.smuggler` (bad) (q09) | `smuggler_trust` (−10) more, once, on the 10th run |

One jars line at a time (the highest reached). Its place in What people say: straight after the LOCK 11 dice line, before the LOCK 10 sealed-purse line. Trust stays 0-100. Dice nights and jar runs never add together.

## 5. Masters

| Master | Shows |
|---|---|
| q01 | Quay in the day: no boatman |
| q02 | Quay after Isha: `quay_button` |
| q03, q04 | Qasim's offer; after the run (coins 198 → 218) |
| q05, q06 | Quay the same night after a run (no button); after walking away (button) |
| q07-q09 | What people say after 2, 4 and 10 runs |

Runs in q07-q09 were set directly for the picture (start trust 45). In q02 the Isha call message was showing when the picture was taken and is not part of this LOCK.

## 6. Not in this LOCK (do not build)

The night watch catching a run, Idris growing cooler, the judge, drinking wine, selling wine yourself, a Qasim capsule or boat model walking routes (named in text only), the back-lanes house as a place.

## 7. Build rules

Words and numbers only from `qasims_jars_data_V1.json` (copied byte for byte to `SOURCE/data/qasims_jars.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 12. Founder 6 Nov: "u get offerd to bring in illegal alcohol and thers good money involved u decided to do it or not"; 8 Nov: **"LOCK it (Recommended)"** after V49 |
