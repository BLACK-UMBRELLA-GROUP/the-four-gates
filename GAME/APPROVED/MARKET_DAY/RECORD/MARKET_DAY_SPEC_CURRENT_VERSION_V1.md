---
id: DOC-TFG-0030
type: SPEC
status: CURRENT
feature: MARKET_DAY
purpose: LOCK 7 - River Market's day - opening hours, regulars going home at night, everything shutting for Friday prayer; closes ROADMAP "First district"
links: [AD-AIOS-115, AD-AIOS-131, DOC-TFG-0011, DOC-TFG-0021, DOC-TFG-0024, DOC-TFG-0027, DOC-TFG-0031]
owner: THE FOUR GATES chat
---

# MARKET DAY SPEC — CURRENT VERSION V1 (LOCK 7)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `market_day_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 V3 clock (prayer times, Fridays, Friday iqamah 30 min), LOCK 3 (bread grab), LOCK 4 (stall), LOCK 5 (loom), LOCK 6 (talking). Queue line 14 comes after line 13 |
| Masters | `../MASTERS/d01`-`d10` at 1920 × 1080 (content, words, states and positions - not the look) |
| Prototype | "The Four Gates Prototype" V40 |
| ROADMAP | Closes "First district" (streets, river edge, shops, day and night lighting - now with the market's daily life) |

## 1. Opening hours (masters d01-d05, d09, d10)

| Person | Open (minutes after midnight) | Close | Shuts |
|---|---|---|---|
| Salma | 270 (04:30) | 1090 (18:10, Maghrib) | Talk; the bread grab only starts while she is there |
| Jamal | 360 (06:00) | 1090 | Talk |
| Rashid | 390 (06:30) | 1090 | Talk and the stall |
| Layla | 390 (06:30) | 1090 | Talk and the loom |
| Old Musa | 390 (06:30) | 1050 (17:30) | Talk (the scales lesson itself stays open, LOCK 1) |

Away (before open or from close): the place bar shows, instead of the button, `text.closed_night` with the name for talking, `text.stall_closed_night` at spice row, `text.loom_closed_night` at weaver's lane.

## 2. Friday prayer (masters d06-d08)

On Fridays from the Friday adhan (Dhuhr start) until 5 minutes after its iqamah (`friday.closed_until_minutes_after_iqamah`; LOCK 2's Friday iqamah is 30 minutes, so 35 minutes in all) everyone in §1 is away: talking shows `text.closed_friday` with the name; stall and loom show `text.shop_closed_friday`. Afterwards everything reopens (d08).

Deen link: "when the call is made for prayer on Friday, hasten to the remembrance of Allah and leave trade" (Quran 62:9).

## 3. Change to LOCK 3

The bread grab's board button ("Something happens at the oven") shows only while Salma is not away (§1-2).

## 4. Not in this LOCK (do not build)

People walking home or to the masjid in 3D (comes with daily routines), the inn's hours, the market inspector, other days off, Ramadan hours.

## 5. Build rules

Words and numbers only from `market_day_data_V1.json` (copied byte for byte to `SOURCE/data/market_day.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 7. Founder 8 Nov: "show me all to lock. lets not offer me options for me to type continue lets just keep continueing", then **"LOCK it (Recommended)"** after V39 |
