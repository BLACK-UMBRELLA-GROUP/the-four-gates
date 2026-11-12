---
id: DOC-TFG-0099
type: SPEC
status: CURRENT
feature: PRAYER_REMINDER
purpose: LOCK 30 - settings, the real-life prayer reminder - off by default; city from a list (no location); Asr Standard or Hanafi; today's real times; a banner at real prayer times with Pause and pray / Later
links: [AD-AIOS-115, AD-AIOS-137, DOC-TFG-0011, DOC-TFG-0096, DOC-TFG-0100]
owner: THE FOUR GATES chat
---

# PRAYER REMINDER SPEC — CURRENT VERSION V1 (LOCK 30)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `prayer_reminder_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 V5 (the reminder chosen 6 Nov, "C · Game clock + real reminder (Recommended)", belongs in Settings), LOCK 29 (Settings screen, pause menu). Queue line 37 comes after line 36 |
| Masters | `../MASTERS/pm01`-`pm07` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V86 |
| ROADMAP | Advances "Save, menus and polish" (settings) |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Off by default | Nothing happens until the player turns it on |
| Privacy | The city is chosen from the list; the game never asks for or reads location; nothing leaves the device |
| Real worship, real times | Times must be correct for the chosen city on the real date, in that city's local time including daylight saving |
| Scholar check (open) | Which calculation methods to offer (this LOCK uses the Muslim World League method only) |

## 2. Settings rows (masters pm01-pm04)

After LOCK 29's rows: `settings.reminder` with `off` / `on` (pm01). When on, three more lines (pm02):

| Row | Detail |
|---|---|
| `settings.city` | A drop-down of `cities` (name, latitude, longitude, time zone), default London |
| `settings.asr` | `asr_standard` (shadow factor 1) / `asr_hanafi` (factor 2) (pm04) |
| `settings.today` | city, times = the five times today as "Fajr hh:mm · Dhuhr … · Isha …" (24-hour) (pm02, pm03) |
| `settings.method` | The method and privacy line |

Stored with the other settings (LOCK 29), not in the save.

## 3. The times

Standard Muslim World League calculation for the city's latitude, longitude and the real date: Dhuhr = solar noon (sun's equation of time and declination); Fajr when the sun is `fajr_angle` (18°) below the horizon before sunrise; Maghrib at sunset (`sun_angle` 0.833°); Isha at `isha_angle` (17°) after sunset; Asr when an object's shadow equals its length × factor + its noon shadow. Far-north rule: if the angle is never reached or gives a time further from sunrise/sunset than (night length × angle ÷ 60) hours, use that fraction of the night instead. Expected for London on 9 Nov 2026: Fajr 05:13 · Dhuhr 11:44 · Asr 13:56 (Hanafi 14:32) · Maghrib 16:20 · Isha 18:09; Makkah: 05:12 · 12:04 · 15:17 · 17:41 · 18:53. A tested prayer-times library giving the same results within 2 minutes may be used.

## 4. The banner (masters pm05-pm07)

While the game is open and the reminder is on, every `check_seconds` (30): if a prayer time in the chosen city has arrived within the last `late_minutes` (15) and has not been shown today, show the banner on every game screen except the title and settings: `banner.text` (prayer, city) with `banner.pray` (opens the LOCK 29 pause menu, pm06) and `banner.later` (closes it, pm07). Each prayer once a day.

## 5. Masters

| Master | Shows |
|---|---|
| pm01 | Settings with the reminder off (default) |
| pm02-pm04 | On: London with today's times; Makkah; Asr Hanafi |
| pm05 | The banner over the market map ("It is time for Asr in London.") |
| pm06, pm07 | After Pause and pray (pause menu); after Later (no banner) |

The times in pm02-pm04 are for 9 Nov 2026 (the day the masters were made); builds on other dates show that date's times - test with the fixed dates in §3.

## 6. Not in this LOCK (do not build)

Phone or system notifications when the game is closed, the adhan sound, location detection, other calculation methods, cities not in the list, Jumu'ah reminders.

## 7. Build rules

Words and numbers only from `prayer_reminder_data_V1.json` (copied byte for byte to `SOURCE/data/prayer_reminder.json`) and the earlier data files. If the engine cannot give each city's local time (time zones and daylight saving), stop and report in `QUESTIONS.md` rather than guess. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 30. Founder 6 Nov "C · Game clock + real reminder (Recommended)"; via Fable 9 Nov (AD-AIOS-137) "THERE WOULD BE A SETTING BUTTON O FOR THAT"; 9 Nov: **"LOCK it (Recommended)"** after V85 |
