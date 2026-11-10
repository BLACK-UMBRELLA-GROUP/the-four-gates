---
id: DOC-TFG-0063
type: SPEC
status: CURRENT
feature: CALENDAR
purpose: LOCK 18 - the game year - real Hijri months from 1 Sha'ban, the date on the clock, resting for days at the inn, and the coming dates (Ramadan, Eids, Arafah, end of the zakat year)
links: [AD-AIOS-115, DOC-TFG-0011, DOC-TFG-0033, DOC-TFG-0064]
owner: THE FOUR GATES chat
---

# CALENDAR SPEC — CURRENT VERSION V1 (LOCK 18)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Founder's choice | 9 Nov: "Decide it now", then **"A · Real calendar + rest (Recommended)"** (real Hijri months starting in Sha'ban; rest for days at the inn; zakat one lunar year after arriving) |
| Words and numbers | `calendar_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 (clock: 48 real minutes a day, weekdays with day 0 a Thursday, the inn at 2 coins a night, prayer times), LOCK 8 (prayer record). Queue line 25 comes after line 24 |
| Masters | `../MASTERS/k01`-`k11` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V62 |
| ROADMAP | No row; noted for Fable |

## 1. The calendar

| Rule | Number / words |
|---|---|
| Months | `months` in order, each [name, days] - the fixed 30/29 pattern, 354 days a year |
| Start | Day 0 (arrival, a Thursday) = day `start_day` (1) of month index `start_month` (7, Sha'ban) |
| Date of day d | Count forward (or back) from the start through the months, wrapping after Dhu al-Hijjah to Muharram |
| No year number | The year is never shown |
| Moon sighting | Not in this LOCK - the fixed pattern decides |

## 2. The clock (every screen)

The clock's first line becomes `hud_date` + " · " + time, e.g. "Thursday 1 Sha'ban · 10:00" (w = weekday, d = day of month, m = month name). The second line is unchanged.

**Known difference:** every earlier master (LOCKs 1-17) shows the clock without the date. Those masters stay as they are; builds after this line show the date. Earlier tests that check the clock's first line must expect the date from this line on.

## 3. Rest for days (masters k01-k04, k10, k11)

| Rule | Number / words |
|---|---|
| Button | At the Inn, always, `inn_button` after the other inn buttons (LOCK 11 dice) and before the LOCK 3 purse button (k01) |
| Panel | `panel.kicker`, `panel.title`, `panel.today`, `panel.coming`, a table of the coming dates (§4), `panel.note`, then one button per `rest_days` (3, 7): `panel.rest` (n days, c = n × 2 coins), or `panel.not_enough` when coins < c (k10), then `panel.not_now` |
| Resting n days | Coins − n × 2. The clock jumps to day + n at `wake_minute` (280 = 04:40). Every prayer whose time ends after the moment you started resting and at or before waking is **not counted**: never "missed", not in the totals (k11). Back at the Inn, with the toast `rested_toast` (k03) |
| Prayer record | A not-counted prayer shows `rested_status` in Today's prayers if it is on screen |

## 4. Coming dates (masters k02, k04, k06, k08, k09)

Rows in this order: each of `panel.events` ([name, month index, day]) then `panel.zakat`. Each row shows the date of its next occurrence from today as `panel.in_days` (d, m, n = days from today), or `panel.today_tag` when it is today.
The zakat row counts to the end of each lunar year since arrival: day 354, 708 ... (today on those days, k09; 354 days on arrival day, k02).

## 5. Masters

| Master | Shows |
|---|---|
| k01, k05, k07 | Inn bar with the date on the clock: 1 Sha'ban, 29 Sha'ban, 1 Shawwal |
| k02, k04 | Coming dates on day 0 and after resting 3 days |
| k03 | Woke on Sunday 4 Sha'ban at 04:40 (coins 198 → 192) |
| k06, k08, k09 | Ramadan, Eid al-Adha and the zakat year end "today" |
| k10 | Not enough coins for 7 days |
| k11 | All your prayers after resting 7 days: nothing counted |

Start: 198 coins (10 in k10), trust 45, set for the picture.

## 6. Not in this LOCK (do not build)

Fasting and Ramadan rules, zakat itself, the Eid prayers and celebrations, moon sighting, seasons, the year number, resting anywhere but the inn, other rest lengths.

## 7. Build rules

Words and numbers only from `calendar_data_V1.json` (copied byte for byte to `SOURCE/data/calendar.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 18. Founder 9 Nov: "Decide it now", "A · Real calendar + rest (Recommended)", **"LOCK it (Recommended)"** after V61. Settles the game year left PENDING on 6 Nov ("we will decide fully later") |
