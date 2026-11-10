---
id: DOC-TFG-0066
type: SPEC
status: CURRENT
feature: RAMADAN
purpose: LOCK 19 - worship, Ramadan - fasting Fajr to Maghrib, suhoor at the inn, iftar together and tarawih at the masjid, and a private Ramadan record
links: [AD-AIOS-115, DOC-TFG-0011, DOC-TFG-0033, DOC-TFG-0063, DOC-TFG-0067]
owner: THE FOUR GATES chat
---

# RAMADAN SPEC — CURRENT VERSION V1 (LOCK 19)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `ramadan_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 (prayer times, masjid, inn), LOCK 8 (All your prayers), LOCK 18 (calendar; Ramadan is month index 8, day 29 is 1 Ramadan; rested days). Queue line 26 comes after line 25 |
| Masters | `../MASTERS/n01`-`n11` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V64 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder's deen groups (6 Nov: "Fasting") | Ramadan is lived in the game |
| Faith is lived, not scored | No coins, no trust, nothing in What people say. The Ramadan record is private |
| Scholar check (open) | Who is excused from fasting (travellers, the sick, a girl's days). The traveller has settled in the town, so he fasts - to be confirmed with a scholar before a later LOCK uses it |

Design references (not shown in the game), checked on sunnah.com: Quran 2:183-185; Sahih al-Bukhari 1923 (suhoor); Sahih al-Bukhari 2009 (night prayer in Ramadan).

## 2. When

A day is a Ramadan day when its date (LOCK 18) is in month index `month` (8). All times are minutes of that day.

## 3. The fasting line (masters n03, n09, n11)

On a Ramadan day from `fast_from` (285 = 04:45) until before `iftar_from` (1090 = 18:10), and not a rested day, every place bar shows `fasting_line` (t = 18:10) after the other bar items and the LOCK 17 harm, before the LOCK 10 carrying line. Not on other days (n09), not after Maghrib (n11).

## 4. Suhoor (masters n01, n02, n10)

At the Inn on a Ramadan day from `suhoor_from` (210 = 03:30) until before 04:45, once a day: `suhoor_button`. Pressing it marks the day's suhoor and shows `suhoor_toast` (n02). Not before Ramadan (n10).

## 5. Iftar (masters n04, n05)

At the Masjid on a Ramadan day from 18:10 until before `iftar_until` (1170 = 19:30), once a day: `iftar_button`. It opens the `iftar` panel (kicker, title, text, `to_map`) and marks the day's iftar. Prayer buttons stay as they are.

## 6. Tarawih (masters n06, n07)

At the Masjid on a Ramadan day from `tarawih_from` (1185 = 19:45) until before `tarawih_until` (1380 = 23:00), once a day: `tarawih_button`. Pressing it marks the night, lets `tarawih_minutes` (60) pass as normal time, and shows `tarawih_toast`.

## 7. The private Ramadan record (master n08)

Once any Ramadan day has been reached, "All your prayers" (LOCK 8) shows, after its rows and before its note: `record.title`, then three rows with `record.count`:

| Row | Counts |
|---|---|
| `record.fasted` | Ramadan days whose Maghrib has passed and that were not rested |
| `record.suhoor` | Days with suhoor |
| `record.tarawih` | Nights with tarawih |

## 8. Masters

| Master | Shows |
|---|---|
| n01, n02 | Inn at 04:00 on 1 Ramadan: suhoor; after |
| n03 | Spice row at 10:00: the fasting line |
| n04, n05 | Masjid at 18:15: iftar button; the iftar panel |
| n06, n07 | Masjid at 20:00: tarawih; after (21:00) |
| n08 | All your prayers on 3 Ramadan: days fasted 3, suhoor 0, tarawih 1 |
| n09-n11 | No fasting line on 29 Sha'ban; no suhoor before Ramadan; no line after Maghrib |

Set for the pictures: trust 45, coins 198. In n08 two days were passed with no prayers, so the prayer rows above show 9 missed. Other bar items and the Isha/Maghrib call message come from earlier LOCKs.

## 9. Not in this LOCK (do not build)

Breaking a fast, who is excused, feeding people at iftar, Laylat al-Qadr, i'tikaf, Eid al-Fitr and zakat al-fitr, moon sighting, eating as a mechanic, any reward for fasting.

## 10. Build rules

Words and numbers only from `ramadan_data_V1.json` (copied byte for byte to `SOURCE/data/ramadan.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 19. Founder 6 Nov deen group "Fasting"; 9 Nov: **"LOCK it (Recommended)"** after V63 |
