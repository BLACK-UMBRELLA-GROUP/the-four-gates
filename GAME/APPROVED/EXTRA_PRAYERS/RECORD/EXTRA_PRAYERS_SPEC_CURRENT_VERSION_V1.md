---
id: DOC-TFG-0241
type: SPEC
status: CURRENT
feature: EXTRA_PRAYERS
purpose: LOCK 77 - the extra prayers (duha and the night prayer)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0242]
owner: THE FOUR GATES chat
---

# EXTRA PRAYERS SPEC — CURRENT VERSION V1 (LOCK 77)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `extra_prayers_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 84 comes after line 83 |
| Masters | `../MASTERS/dd01`-`dd03` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 1178, 1145 - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `extra_lesson` - The extra prayers (scene)

Button `button`, shown when: River Market place `masjid`; 08:00-20:00; after `rows_learned`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask him how` → `leave` · flag `extra_learned` |

## Mission `duha` - Duha (scene)

Button `button`, shown when: River Market place `masjid`; 08:00-11:30; after `extra_learned`; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Finish` → `leave` · extra_prayers +1; clock +10 min |

## Mission `night_prayer` - The night prayer (scene)

Button `button`, shown when: River Market place `inn`; 23:00-04:30; after `extra_learned`; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Finish` → `leave` · night_prayers +1; clock +20 min |

## Masters

- `dd01_extra_lesson__a.png`
- `dd02_duha__a.png`
- `dd03_night_prayer__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `extra_prayers_data_V1.json` (copied byte for byte to `SOURCE/data/extra_prayers.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 77 under the Founder's blanket LOCK (9 Nov) |
