---
id: DOC-TFG-0036
type: SPEC
status: CURRENT
feature: FEEDING
purpose: LOCK 9 - feeding the poor - paying Salma to bake bread for the hungry, in public or in secret; meals toward the 10,000 lifetime goal
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0027, DOC-TFG-0030, DOC-TFG-0037]
owner: THE FOUR GATES chat
---

# FEEDING SPEC — CURRENT VERSION V1 (LOCK 9)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `feeding_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1 teaches giving in secret: learned word `sirr`), LOCK 6 (Salma), LOCK 7 (Salma's hours). Queue line 16 comes after line 15 |
| Masters | `../MASTERS/e01`-`e08` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V44 |
| ROADMAP | No row (lifetime goals); noted for Fable |

## 1. Founder's words

"you can also pay to feed poor in game and in ramaadan pay to feed poor also same concept but of course ramadan a little different" (8 Nov 2026). Ramadan iftars are not in this LOCK.

## 2. Where (masters e01, e08)

At the Task board (the square), while Salma is not away (LOCK 7), the bar shows `place_button` before the bread-grab and talk buttons (e01). While she is away, no button (e08).

## 3. The panel (masters e02-e06)

| Rule | Number / words |
|---|---|
| Header | `panel.kicker`, `panel.title`; then `panel.intro`, or after a payment `done_public` / `done_secret` |
| Options | Each `options` row: name, line, "Pay · {n} coins" (`pay`), or `not_enough` when coins < cost (e06) |
| Pay | Coins − cost; meals + the option's `meals` |
| Secret | If the word `sirr` is learned: a tick box `secret_label`; when ticked, the line `secret_on` (e04). If not learned: the line `secret_locked` (e02) |
| Public payment | Trust + `numbers.trust_per_day` (1) at most once per game day; What people say gains `say.feeds` (from the first public payment) |
| Secret payment | No trust change, no What people say line |
| Counter | `panel.counter` with n = meals given, m = `numbers.goal_meals` (10,000, written with a thousands comma) |
| Back | `panel.back` |

## 4. What people say (master e07)

`say.feeds` is added before the LOCK 6 greeting line.

## 5. Not in this LOCK (do not build)

Ramadan iftars, feeding at the inn, the poor waiting at the inn door changing, other lifetime goals (Umrah, Hajj, Qurans, school), the masjids-visited goal.

## 6. Build rules

Words and numbers only from `feeding_data_V1.json` (copied byte for byte to `SOURCE/data/feeding.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 9. Founder 8 Nov: words in §1, then **"LOCK it (Recommended)"** after V43 |
