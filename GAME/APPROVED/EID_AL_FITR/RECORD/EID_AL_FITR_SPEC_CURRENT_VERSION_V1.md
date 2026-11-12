---
id: DOC-TFG-0072
type: SPEC
status: CURRENT
feature: EID_AL_FITR
purpose: LOCK 21 - worship, the last ten nights and Eid al-Fitr - night prayer without revealing the Night of Power, zakat al-fitr before Eid, the Eid prayer, private record rows
links: [AD-AIOS-115, DOC-TFG-0063, DOC-TFG-0066, DOC-TFG-0073]
owner: THE FOUR GATES chat
---

# EID AL-FITR SPEC — CURRENT VERSION V1 (LOCK 21)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `eid_al_fitr_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 18 (calendar; 354-day year from arrival), LOCK 19 (Ramadan, the masjid, the private Ramadan record). Queue line 28 comes after line 27 |
| Masters | `../MASTERS/y01`-`y14` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V68 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | The game never says which night is the Night of Power and gives nothing on any night |
| Faith is lived, not scored | No coins, no trust, nothing in What people say. The rows are private |
| Scholar check (open) | Zakat al-fitr paid as coins for a measure of dates |

Design references (not shown in the game), checked on sunnah.com: Quran 97; Sahih al-Bukhari 2017 (seek it in the odd nights of the last ten); Sahih al-Bukhari 1503 (zakat al-fitr, before people go out to the prayer).

## 2. The last ten nights (masters y01-y04)

| Rule | Number / words |
|---|---|
| Which nights | A night belongs to the next day (Islamic night): from `night_from` (1380 = 23:00) it belongs to tomorrow; before `night_until` (285 = 04:45) to today. It counts when that day is in Ramadan (`ramadan`, 8) on day `last_ten_from` (21) or later |
| Button | At the Masjid on such a night, once per night: `night_button` (y01). Not in the day (y03), not before the 21st (y04) |
| Pressing | The night is marked, `night_minutes` (60) pass as normal time, `night_toast` shows (y02) |

## 3. Zakat al-fitr (masters y05-y09)

| Rule | Number / words |
|---|---|
| When | From day `fitr_from_day` (28) of Ramadan, and on 1 Shawwal before `eid_until` (540 = 09:00) |
| Button | At the Masjid, until given this year: `fitr_button` (y05). Gone after giving (y08) |
| Panel | `fitr.kicker`, `fitr.title`, `fitr.text`, then `fitr.pay` (n = `fitr_cost`, 2) or `fitr.not_enough` (y09) or `fitr.given` after paying (y07), and `fitr.to_map` |
| Paying | Coins − 2, once per game year (year = day ÷ 354, rounded down) |

## 4. Eid al-Fitr (masters y10-y12, y14)

| Rule | Number / words |
|---|---|
| Eid day | 1 Shawwal (`shawwal`, 9) |
| Line | Every place bar shows `eid_line` all that day (y12), after the LOCK 19 items |
| Prayer | At the Masjid from `eid_from` (390 = 06:30) until before 09:00, once: `eid_button` (y10) opens the `eid` panel (y11) |
| Next day | Nothing (y14) |

## 5. Private record (master y13)

After the LOCK 19 Ramadan rows in All your prayers (only when those show): `record.nights` (n = nights stood), `record.fitr` (`yes_fitr` if given this year, else `no`), `record.eid` (`yes_eid` if any Eid prayer prayed, else `no`).

## 6. Masters

| Master | Shows |
|---|---|
| y01, y02 | Night of the 21st at 23:10; after standing (00:10) |
| y03, y04 | No button on 20 Ramadan afternoon; none on the night of the 11th |
| y05-y09 | Zakat al-fitr button on 28 Ramadan; panel; given; button gone; not enough coins (coins 1) |
| y10-y12 | Eid morning at the masjid; the Eid panel; Eid line at the spice row |
| y13 | Record: 2 nights stood (set), zakat al-fitr not yet, Eid prayed |
| y14 | 2 Shawwal: nothing |

Set for the pictures: trust 45, coins 198. Other bar items (iftar giving, harm, fasting line, Isha call) come from earlier LOCKs.

## 7. Not in this LOCK (do not build)

Revealing or rewarding the Night of Power, i'tikaf, Eid clothes or gifts as items, the Eid sermon, Eid al-Adha, moon sighting, zakat on wealth.

## 8. Build rules

Words and numbers only from `eid_al_fitr_data_V1.json` (copied byte for byte to `SOURCE/data/eid_al_fitr.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 21. Founder 6 Nov deen groups "Fasting" and "Worship & Quran"; 9 Nov: **"LOCK it (Recommended)"** after V67 |
