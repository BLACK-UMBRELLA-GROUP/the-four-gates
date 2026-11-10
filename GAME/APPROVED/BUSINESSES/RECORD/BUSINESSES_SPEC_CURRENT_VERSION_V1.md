---
id: DOC-TFG-0283
type: SPEC
status: CURRENT
feature: BUSINESSES
purpose: LOCK 91 - a stall and a fishing boat
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0284]
owner: THE FOUR GATES chat
---

# BUSINESSES SPEC — CURRENT VERSION V1 (LOCK 91)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `businesses_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 98 comes after line 97 |
| Masters | `../MASTERS/od01`-`od04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 83:1-3; Ibn Majah 2443 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `rent_stall` - A stall of your own (scene)

Button `button`, shown when: River Market place `spice`; 08:00-18:00; after `chapter1_done`; not after `own_stall`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Rent it · 80 coins` (needs 80 coins) → `leave` · coins -80; flag `own_stall`<br>`Not now` → `leave` · - |

## Mission `stall_week` - Your stall's week (scene)

Button `button`, shown when: River Market place `spice`; 08:00-18:00; after `own_stall`; 7 days after `own_stall`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Weigh honestly` → `leave` · coins +12<br>`Thumb on the scale` → `leave` · coins +18; trust -3; say `short`; cheats +1 |

What people say lines (`say`): `short` (bad, Nasir the inspector) - shown in River Market What people say.

## Mission `buy_boat` - A fishing boat (scene)

Button `button`, shown when: town `sahila` hub; 07:00-17:00; after `sahila_boat_done`; not after `own_boat`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Buy it · 100 coins` (needs 100 coins) → `leave` · coins -100; flag `own_boat`<br>`Not now` → `leave` · - |

## Mission `boat_week` - The week's catch (scene)

Button `button`, shown when: town `sahila` hub; 07:00-17:00; after `own_boat`; 7 days after `own_boat`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Pay him first, then take yours` → `leave` · coins +10; trust +1<br>`Take yours; pay him next week` → `leave` · coins +15; trust -2; say `late` |

What people say lines (`say`): `late` (bad, the shore) - shown in the town's What people say.

## Masters

- `od01_rent_stall__a.png`
- `od02_stall_week__a.png`
- `od03_buy_boat__a.png`
- `od04_boat_week__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `businesses_data_V1.json` (copied byte for byte to `SOURCE/data/businesses.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 91 under the Founder's blanket LOCK (9 Nov) |
