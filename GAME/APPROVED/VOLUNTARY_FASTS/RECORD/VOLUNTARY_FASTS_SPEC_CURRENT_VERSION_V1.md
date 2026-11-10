---
id: DOC-TFG-0256
type: SPEC
status: CURRENT
feature: VOLUNTARY_FASTS
purpose: LOCK 82 - Monday and Thursday fasts
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0257]
owner: THE FOUR GATES chat
---

# VOLUNTARY FASTS SPEC — CURRENT VERSION V1 (LOCK 82)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `voluntary_fasts_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 89 comes after line 88 |
| Masters | `../MASTERS/di01`-`di01` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Muslim 1162 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `voluntary_fast` - Monday and Thursday (scene)

Button `button`, shown when: River Market place `inn`; 04:00-04:45; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Eat and make the intention to fast` → `leave` · voluntary_fasts +1; clock +15 min |

## Masters

- `di01_voluntary_fast__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `voluntary_fasts_data_V1.json` (copied byte for byte to `SOURCE/data/voluntary_fasts.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 82 under the Founder's blanket LOCK (9 Nov) |
