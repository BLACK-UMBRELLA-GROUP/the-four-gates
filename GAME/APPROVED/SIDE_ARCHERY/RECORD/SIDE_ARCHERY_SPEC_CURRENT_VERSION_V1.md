---
id: DOC-TFG-0196
type: SPEC
status: CURRENT
feature: SIDE_ARCHERY
purpose: LOCK 62 - River Market side mission - a cheat at archery
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0197]
owner: THE FOUR GATES chat
---

# SIDE ARCHERY SPEC — CURRENT VERSION V1 (LOCK 62)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_archery_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 69 comes after line 68 |
| Masters | `../MASTERS/sn01`-`sn04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Abu Dawud 2574 (prizes in archery) - checked 6 Nov |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `archery` - A cheat at archery (side mission)

Button `button`, shown when: River Market place `gate`; 08:00-15:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Say what you saw` → `speak` · trust +5; say `spoke`<br>`Enter the contest yourself, fairly` → `shoot` · clock +60 min<br>`Let it go` → `out` · - |
| `speak` | End: Back; mission done |
| `shoot` | End: Back; mission done |
| `out` | End: Back; mission done |

What people say lines (`say`): `spoke` (good, the young men at the gate) - shown in River Market What people say.

## Masters

- `sn01_archery__a.png`
- `sn02_archery__speak.png`
- `sn03_archery__shoot.png`
- `sn04_archery__out.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_archery_data_V1.json` (copied byte for byte to `SOURCE/data/side_archery.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 62 under the Founder's blanket LOCK (9 Nov) |
