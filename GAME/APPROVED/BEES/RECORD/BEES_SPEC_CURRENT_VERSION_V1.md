---
id: DOC-TFG-0277
type: SPEC
status: CURRENT
feature: BEES
purpose: LOCK 89 - a hive at Nahla
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0278]
owner: THE FOUR GATES chat
---

# BEES SPEC — CURRENT VERSION V1 (LOCK 89)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `bees_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 96 comes after line 95 |
| Masters | `../MASTERS/ob01`-`ob02` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 16:68-69 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `buy_hive` - A hive of your own (scene)

Button `button`, shown when: town `nahla` hub; 07:00-16:00; after `nahla_done`; not after `own_hive`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Buy it · 30 coins` (needs 30 coins) → `leave` · coins -30; flag `own_hive`<br>`Not now` → `leave` · - |

## Mission `honey_share` - Your honey (scene)

Button `button`, shown when: town `nahla` hub; 07:00-16:00; after `own_hive`; 7 days after `own_hive`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take 6 coins` → `leave` · coins +6 |

## Masters

- `ob01_buy_hive__a.png`
- `ob02_honey_share__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `bees_data_V1.json` (copied byte for byte to `SOURCE/data/bees.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 89 under the Founder's blanket LOCK (9 Nov) |
