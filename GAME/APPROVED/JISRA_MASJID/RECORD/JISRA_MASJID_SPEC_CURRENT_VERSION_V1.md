---
id: DOC-TFG-0108
type: SPEC
status: CURRENT
feature: JISRA_MASJID
purpose: LOCK 33 - Jisra's masjid (the boatmen's masjid, imam Uthman) and the private side mission "Masjids you have prayed in: n / 50"
links: [AD-AIOS-115, DOC-TFG-0033, DOC-TFG-0105, DOC-TFG-0109]
owner: THE FOUR GATES chat
---

# JISRA MASJID SPEC — CURRENT VERSION V1 (LOCK 33)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable answer **"OK LOCK IT BUT SHOW ME HOW MANY MORE THINGS ARE LEFT ..."** - record `LOCK_RECORD.md` beside this file |
| Founder's idea | 8 Nov: "lets add somewhere in game as again side mission masjids vistied max 50" |
| Words and numbers | `jisra_masjid_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 (prayer, congregation until 5 minutes after the iqamah), LOCK 8 (All your prayers), LOCK 32 (Jisra). Queue line 40 comes after line 39 |
| Masters | `../MASTERS/jm01`-`jm08` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V90 (draft) / V91 (locked) |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Faith is lived, not scored | The masjid count is private: no trust, no What people say line |
| Same prayer rules everywhere | Jisra's masjid uses the LOCK 2 rules exactly as River Market's masjid |

## 2. Jisra bar (master jm01)

The Jisra panel (LOCK 32 §5) gains `jisra_button` after the watch button, always shown. It opens the masjid panel.

## 3. The boatmen's masjid (masters jm02, jm03, jm05, jm06, jm07)

Panel `masjid` (kicker, title, `text`). While a prayer time is open and not yet prayed, the prayer button:

| Time | Button and record |
|---|---|
| Up to 5 minutes after the iqamah | "Pray with the congregation" (Friday Dhuhr: "Pray Friday prayer with the congregation") → recorded in congregation (jm02, jm03) |
| Later | LOCK 2 "Pray {prayer} here" → recorded on your own, at the masjid (jm05, jm06) |
| No prayer time open | no button (jm07) |

Then `back` to the Jisra panel. After the first prayer ever in this masjid, `first` replaces `text` until the next prayer there (jm03, jm06).

## 4. Masjids you have prayed in (masters jm02-jm04, jm06, jm08)

A set of masjid ids from `masjids` (`river_market`, `jisra`). A masjid is added the first time you pray there (in congregation or on your own at the masjid). Praying anywhere else (the bridge, the street) adds nothing (jm08).

`counter` (n = masjids in the set, m = `goal_masjids` 50) is shown:
- in All your prayers (LOCK 8), straight after the prayer rows, once n ≥ 1 (jm04);
- in the masjid panel under the text, once n ≥ 1.

## 5. Masters

| Master | Shows |
|---|---|
| jm01-jm04 | Masjid button on the bridge; congregation (River Market already counted, 1 / 50); Uthman's line, 2 / 50; All your prayers with 2 / 50 |
| jm05, jm06 | After the iqamah: on your own at the masjid; first masjid 1 / 50 |
| jm07, jm08 | No prayer time; prayed on the bridge - not counted, no counter row |

## 6. Not in this LOCK (do not build)

Masjids in other towns or the five parts of Ilmara; Uthman as a talking character; Jisra's people and What people say; a reward for reaching 50.

## 7. Build rules

Words and numbers only from `jisra_masjid_data_V1.json` (copied byte for byte to `SOURCE/data/jisra_masjid.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 33. Founder 8 Nov idea; 9 Nov clickable answer "OK LOCK IT ..." after V90 |
