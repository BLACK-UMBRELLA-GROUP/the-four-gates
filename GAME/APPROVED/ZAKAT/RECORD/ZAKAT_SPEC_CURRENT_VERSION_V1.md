---
id: DOC-TFG-0075
type: SPEC
status: CURRENT
feature: ZAKAT
purpose: LOCK 22 - wealth, zakat - one fortieth of coins at or above the threshold each lunar year from arrival, given through Idris or to a person in need, private, due until paid
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0033, DOC-TFG-0063, DOC-TFG-0076]
owner: THE FOUR GATES chat
---

# ZAKAT SPEC — CURRENT VERSION V1 (LOCK 22)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `zakat_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (Umm Salim, Faris, Yusuf and his son Ali), LOCK 8 (All your prayers), LOCK 18 (354-day year from arrival; the inn's "Your zakat year ends" row). Queue line 29 comes after line 28 |
| Masters | `../MASTERS/z01`-`z13` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V70 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| A duty, not a show | No trust, no What people say line, no reward. Private record only |
| The game never plays God | Not paying is never punished; it simply stays due |
| Scholar check (open) | The `threshold` (100 coins) stands in for nisab; only the coins held on the day are counted (no year-long check, no other wealth) |

Design references (not shown in the game), checked on sunnah.com: Quran 9:60 (who may receive zakat); Sahih al-Bukhari 1395 (taken from the rich, given to the poor).

## 2. The zakat year

Zakat year k (k = 1, 2, ...) ends on day k × 354 (LOCK 18). The first time the game is on or after that day, it records for year k: the coins held then, and the due = coins ÷ `share` (40) rounded up if coins ≥ `threshold` (100), else 0.

## 3. The masjid button (masters z01, z02, z08, z11, z13)

At the Masjid, after the other bar items: `masjid_button` - while year k's due > 0 and not paid (z02, z13: still there days later), or, when nothing is due, only on the day it was recorded (z11: gone next day). Nothing before the first year ends (z01) and nothing after paying (z08).

## 4. The panel (masters z03-z07, z10, z12)

`panel.kicker`, `panel.title`, then `panel.due` (c = coins recorded, t = 100, n = due) or `panel.none` (z10). When due and unpaid: one button per `options` entry, in order (z03) - or `panel.not_enough` (n = due) if coins now < due (z12). After paying: the chosen option's `out` text (z04-z07). Always `panel.to_map`.

Paying: coins − due; marked paid with the chosen option.

## 5. Private record (master z09)

All your prayers, after the LOCK 21 rows (or after the prayer rows when those do not show), once a zakat year has ended: `record.title` with `record.paid` / `record.due` (n = due) / `record.none`.

## 6. Masters

| Master | Shows |
|---|---|
| z01, z02 | Day 353 (30 Rajab): nothing; day 354 (1 Sha'ban): the button |
| z03-z07 | 238 coins: 6 due; paid through Idris, to Umm Salim, Faris, Yusuf |
| z08, z09 | Button gone; record "paid · 6 coins" |
| z10, z11 | 60 coins: not due; gone next day |
| z12, z13 | 300 coins recorded, 3 coins now: due 8, not enough; still due 6 days later |

Coins and trust (45) set for the pictures.

## 7. Not in this LOCK (do not build)

Zakat on goods, animals, crops or property; counting wealth over the whole year; zakat collectors; Idris tracking who paid; any reward.

## 8. Build rules

Words and numbers only from `zakat_data_V1.json` (copied byte for byte to `SOURCE/data/zakat.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 22. Founder 6 Nov deen group "Wealth" (zakat); 9 Nov: game year A (zakat one lunar year after arriving) and **"LOCK it (Recommended)"** after V69 |
