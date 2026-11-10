---
id: DOC-TFG-0190
type: SPEC
status: CURRENT
feature: SIDE_SPILLED_SPICE
purpose: LOCK 60 - River Market side mission - the spilled spice (witness)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0191]
owner: THE FOUR GATES chat
---

# SIDE SPILLED SPICE SPEC — CURRENT VERSION V1 (LOCK 60)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_spilled_spice_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 67 comes after line 66 |
| Masters | `../MASTERS/sl01`-`sl05` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 4:135 (stand firm for justice as witnesses) |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `spilled_spice` - The spilled spice (side mission)

Button `button`, shown when: River Market place `spice`; 08:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Remember it` → `b` · flag `saw_spice` |
| `b` | `Tell the truth: it was Sulayman, by accident` → `truth` · trust +6; say `truth`<br>`Say it was Faris` → `lie` · trust -8; say `lie`<br>`Say you didn't see` → `silent` · trust -2 |
| `truth` | End: Back; mission done |
| `lie` | End: Back; mission done |
| `silent` | End: Back; mission done |

What people say lines (`say`): `truth` (good, Faris and Rashid); `lie` (bad, the spice row) - shown in River Market What people say.

## Masters

- `sl01_spilled_spice__a.png`
- `sl02_spilled_spice__b.png`
- `sl03_spilled_spice__truth.png`
- `sl04_spilled_spice__lie.png`
- `sl05_spilled_spice__silent.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_spilled_spice_data_V1.json` (copied byte for byte to `SOURCE/data/side_spilled_spice.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 60 under the Founder's blanket LOCK (9 Nov) |
