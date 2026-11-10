---
id: DOC-TFG-0160
type: SPEC
status: CURRENT
feature: FINALE_RAIN
purpose: LOCK 50 - the finale in River Market - The rain prayer and The riot
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0161]
owner: THE FOUR GATES chat
---

# FINALE RAIN SPEC — CURRENT VERSION V1 (LOCK 50)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `finale_rain_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 57 comes after line 56 |
| Masters | `../MASTERS/h201`-`h206` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 1012 (the prayer for rain) - checked on sunnah.com; Quran 49:9 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: how the rain prayer is shown |



## Mission `rain_prayer` - The rain prayer (main story)

Button `button`, shown when: River Market place `masjid`; 05:00-10:00; after `bread_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Go out and pray with everyone` → `b` · flag `rain_prayed`; clock +120 min |
| `b` | End: Back; mission done |

## Mission `riot` - The riot (main story)

Button `button`, shown when: River Market place `board`; 10:00-20:00; after `rain_prayed`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Stand at the door and speak to them` → `speak` · trust +8; flag `riot_done`; say `calmed`<br>`Run for Qadi Ibrahim and the guard` → `qadi` · trust +4; flag `riot_done`<br>`Join the crowd` → `join` · trust -10; flag `riot_done`; say `joined` |
| `speak` | End: Back; mission done |
| `qadi` | End: Back; mission done |
| `join` | End: Back; mission done |

What people say lines (`say`): `calmed` (good, River Market); `joined` (bad, the guard) - shown in River Market What people say.

## Masters

- `h201_rain_prayer__a.png`
- `h202_rain_prayer__b.png`
- `h203_riot__a.png`
- `h204_riot__speak.png`
- `h205_riot__qadi.png`
- `h206_riot__join.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `finale_rain_data_V1.json` (copied byte for byte to `SOURCE/data/finale_rain.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 50 under the Founder's blanket LOCK (9 Nov) |
