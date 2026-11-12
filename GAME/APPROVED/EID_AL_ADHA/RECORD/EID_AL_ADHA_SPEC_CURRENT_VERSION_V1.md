---
id: DOC-TFG-0078
type: SPEC
status: CURRENT
feature: EID_AL_ADHA
purpose: LOCK 23 - worship, Dhu al-Hijjah - Saeed's sheep, the Day of Arafah fast, the Eid al-Adha prayer, the sacrifice after it, the days of Tashreeq, private record rows
links: [AD-AIOS-115, DOC-TFG-0036, DOC-TFG-0048, DOC-TFG-0063, DOC-TFG-0066, DOC-TFG-0072, DOC-TFG-0079]
owner: THE FOUR GATES chat
---

# EID AL-ADHA SPEC — CURRENT VERSION V1 (LOCK 23)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `eid_al_adha_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 9 (meals for the poor), LOCK 13 (Saeed the herder; telling him about his goats), LOCK 18 (calendar: Dhu al-Hijjah is month index 11, 1 Dhu al-Hijjah is day 118), LOCK 19 (fasting times, private record), LOCK 21 (Eid prayer pattern). Queue line 30 comes after line 29 |
| Masters | `../MASTERS/a01`-`a18` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V72 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Faith is lived, not scored | No trust, nothing in What people say. Private record only |
| Hajj is never shown (Founder 6 Nov) | The pilgrims are only mentioned in a toast |

Design references (not shown in the game), checked on sunnah.com: Sahih Muslim 1162 (fasting the Day of Arafah); Sahih al-Bukhari 5560 (the Eid prayer first, then the sacrifice).

## 2. Days

x = day of month when the date is in month `month` (11); otherwise nothing in this LOCK applies.

## 3. Saeed's sheep (masters a01-a05)

| Rule | Number / words |
|---|---|
| Button | At the Gate, x ≤ `sell_until_day` (9), from `sell_from` (420 = 07:00) until before `sell_until` (1080 = 18:00), while no sheep has been bought: `gate_button` |
| Panel | `sheep.kicker`, `sheep.title`, `sheep.text`; `sheep.remembers` only if Saeed was told about his goats (LOCK 13) (a04); then `sheep.buy` (n = `sheep_cost` 30), or `sheep.not_enough` (a05), or `sheep.bought` after buying (a03); `sheep.no` |
| Buying | Coins − 30; one sheep, owned |

## 4. The Day of Arafah (masters a06, a07)

At the Inn on x = `arafah_day` (9), from `suhoor_from` (210) until before `fast_from` (285), once: `arafah_button`; pressing it marks the fast and shows `arafah_toast`. That day from 04:45 until before `iftar_from` (1090), every bar shows `arafah_line` (t = 18:10) (a07).

## 5. Eid al-Adha and Tashreeq (masters a08-a10, a15, a18)

| Rule | Number / words |
|---|---|
| Eid line | x = `eid_day` (10): every bar shows `eid_line` |
| Eid prayer | At the Masjid on x = 10 from `eid_from` (390) until before `eid_until` (540), once: `eid_button` → panel `eid` (a10) |
| Tashreeq | x = 11 to `tashreeq_last` (13): every bar shows `tashreeq_line` (a15) |
| After | x = 14: nothing (a18) |

## 6. The sacrifice (masters a08, a11-a14, a17)

| Rule | Number / words |
|---|---|
| When | With a sheep owned: x = 10 after the Eid prayer was prayed or from 09:00 (not before, a08); x = 11 and 12 all day; x = 13 until before 18:10 (not after, a17) |
| Button | At the Gate: `sacrifice_button` (a11) |
| Panel | `sacrifice.kicker`, `.title`, `.text`, then `.thirds` and `.all` (a12); after choosing, `.out_thirds` / `.out_all` (a13, a14); `.to_map` |
| Effect | thirds: meals for the poor + `thirds_meals` (10); all: + `all_meals` (30). The sheep is used |

## 7. Private record (master a16)

All your prayers, after the zakat row, once any Dhu al-Hijjah day has been reached in the last 30 days: `record.title`, then `record.arafah` (`yes_fast` / `no`), `record.eid` (`yes_eid` / `no`), `record.sacrifice` (`yes_sac` / `no`).

## 8. Masters

| Master | Shows |
|---|---|
| a01-a05 | 1 Dhu al-Hijjah: button; offer; bought; Saeed remembers; not enough coins (20) |
| a06, a07 | Arafah: intend at the inn (04:00); fasting line at 10:00 |
| a08-a10 | Eid 06:40: no sacrifice yet; Eid prayer button; the Eid panel |
| a11-a14 | Sacrifice at 07:00 after praying; choose; thirds; all to the poor on the 11th |
| a15, a16 | Tashreeq line; the record |
| a17, a18 | 13th after Maghrib: no sacrifice; 14th: nothing |

Coins (198) and trust (45) set for the pictures. Other bar items come from earlier LOCKs.

## 9. Not in this LOCK (do not build)

Owning other animals, an animal model, the slaughter shown, cows or camels shared by seven, the first ten days' dhikr, Hajj or pilgrims shown, the Eid sermon text.

## 10. Build rules

Words and numbers only from `eid_al_adha_data_V1.json` (copied byte for byte to `SOURCE/data/eid_al_adha.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 23. Founder 6 Nov deen groups "Worship & Quran" and "Wealth"; 8 Nov ownership "sheep and goats for Eid al-Adha"; 9 Nov: **"LOCK it (Recommended)"** after V71 |
