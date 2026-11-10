---
id: DOC-TFG-0268
type: SPEC
status: CURRENT
feature: LETTERS_HOME
purpose: LOCK 86 - letters home
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0269]
owner: THE FOUR GATES chat
---

# LETTERS HOME SPEC — CURRENT VERSION V1 (LOCK 86)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `letters_home_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 93 comes after line 92 |
| Masters | `../MASTERS/dm01`-`dm01` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 5971 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `letter_home` - A letter home (scene)

Button `button`, shown when: River Market place `inn`; 19:00-22:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Give it to a caravan going your way` → `leave` · letters +1; clock +30 min |

## Masters

- `dm01_letter_home__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `letters_home_data_V1.json` (copied byte for byte to `SOURCE/data/letters_home.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 86 under the Founder's blanket LOCK (9 Nov) |
