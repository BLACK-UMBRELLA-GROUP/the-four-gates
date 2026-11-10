---
id: DOC-TFG-0090
type: SPEC
status: CURRENT
feature: REGULARS_AT_PRAYER
purpose: LOCK 27 - the market's day, the regulars go to prayer - Rashid, Jamal and Old Musa at the masjid for Dhuhr and Asr; their places show it; the masjid shows who is there
links: [AD-AIOS-115, DOC-TFG-0011, DOC-TFG-0027, DOC-TFG-0030, DOC-TFG-0091]
owner: THE FOUR GATES chat
---

# REGULARS AT PRAYER SPEC — CURRENT VERSION V1 (LOCK 27)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `regulars_at_prayer_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 (prayer times, iqamah), LOCK 4 (Rashid's stall), LOCK 6 (regulars and their talk buttons), LOCK 7 (opening hours, Friday closing, the away texts), LOCK 16 (loan bar hidden when Rashid is away). Queue line 34 comes after line 33 |
| Masters | `../MASTERS/ra01`-`ra08` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V80 |
| ROADMAP | No row; noted for Fable |

## 1. The rule

A regular in `goers` (Rashid, Jamal, Old Musa) is **away at prayer** when: the current prayer is in `prayers` (Dhuhr, Asr), it is not Friday Dhuhr (LOCK 7 handles Friday), and the time is from the adhan until before the iqamah + `minutes_after_iqamah` (10). Dhuhr: 12:05-12:29; Asr: 15:30-15:54. LOCK 7's night and Friday reasons come first.

Nothing is scored. Salma and Layla are not in `goers` and keep their places (ra05).

## 2. What shows (masters ra01-ra04, ra06-ra08)

| Place | While away at prayer |
|---|---|
| Spice row | The stall button is replaced by `text.stall` (prayer = Dhuhr / Asr); the LOCK 16 loan bar is hidden (ra01) |
| Any place with a goer | The talk button is replaced by `text.person` (name, prayer) (ra01-ra03, ra07) |
| Masjid | `text.masjid` with prayer and names = the goers' names joined with ", " in `goers` order, after the LOCK 26 button (ra04) |
| After the window | Everything is back (ra06) |
| Friday Dhuhr | LOCK 7 texts, unchanged (ra08) |

## 3. Masters

| Master | Shows |
|---|---|
| ra01-ra05 | 12:15 on a Thursday: spice row, quay, scales, masjid, square (Salma stays) |
| ra06 | 12:31: the stall is open again |
| ra07 | 15:40: Jamal at Asr |
| ra08 | Friday 12:10: LOCK 7's Friday text, unchanged |

Trust 45, set for the pictures. Other bar items come from earlier LOCKs.

## 4. Not in this LOCK (do not build)

Regulars walking between places (capsules move later), women's prayer places, other prayers, praying beside a named regular as a scene, anything scored.

## 5. Build rules

Words and numbers only from `regulars_at_prayer_data_V1.json` (copied byte for byte to `SOURCE/data/regulars_at_prayer.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 27 (first part of the regulars' routines). Founder 6 Nov: "Named regulars + crowd (Recommended)"; 9 Nov: **"LOCK it (Recommended)"** after V79 |
