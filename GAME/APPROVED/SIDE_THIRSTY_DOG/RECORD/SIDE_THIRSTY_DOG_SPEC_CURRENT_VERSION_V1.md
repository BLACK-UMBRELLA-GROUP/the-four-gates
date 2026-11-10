---
id: DOC-TFG-0187
type: SPEC
status: CURRENT
feature: SIDE_THIRSTY_DOG
purpose: LOCK 59 - River Market side mission - a thirsty dog
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0188]
owner: THE FOUR GATES chat
---

# SIDE THIRSTY DOG SPEC — CURRENT VERSION V1 (LOCK 59)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_thirsty_dog_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 66 comes after line 65 |
| Masters | `../MASTERS/sk01`-`sk03` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2363 (the man who watered a thirsty dog) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `thirsty_dog` - A thirsty dog (side mission)

Button `button`, shown when: River Market place `quay`; 10:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Draw water and give it a drink` → `drink` · flag `dog_watered`; clock +10 min<br>`Walk on` → `on` · - |
| `drink` | End: Back; mission done |
| `on` | End: Back; mission done |

## Masters

- `sk01_thirsty_dog__a.png`
- `sk02_thirsty_dog__drink.png`
- `sk03_thirsty_dog__on.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_thirsty_dog_data_V1.json` (copied byte for byte to `SOURCE/data/side_thirsty_dog.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 59 under the Founder's blanket LOCK (9 Nov) |
