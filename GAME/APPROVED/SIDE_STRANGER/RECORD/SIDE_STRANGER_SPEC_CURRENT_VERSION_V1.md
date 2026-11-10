---
id: DOC-TFG-0199
type: SPEC
status: CURRENT
feature: SIDE_STRANGER
purpose: LOCK 63 - River Market side mission - a stranger with nowhere to sleep
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0200]
owner: THE FOUR GATES chat
---

# SIDE STRANGER SPEC — CURRENT VERSION V1 (LOCK 63)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_stranger_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 70 comes after line 69 |
| Masters | `../MASTERS/so01`-`so04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 6018 (honour your guest) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `stranger` - A stranger with nowhere to sleep (side mission)

Button `button`, shown when: River Market place `inn`; 19:00-23:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Share your room with him` → `share` · trust +5; say `hosted`<br>`Pay the stable for a straw bed · 2 coins` (needs 2 coins) → `stable` · coins -2; trust +3; say `hosted`<br>`Go to bed` → `bed` · - |
| `share` | End: Back; mission done |
| `stable` | End: Back; mission done |
| `bed` | End: Back; mission done |

What people say lines (`say`): `hosted` (good, the inn) - shown in River Market What people say.

## Masters

- `so01_stranger__a.png`
- `so02_stranger__share.png`
- `so03_stranger__stable.png`
- `so04_stranger__bed.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_stranger_data_V1.json` (copied byte for byte to `SOURCE/data/side_stranger.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 63 under the Founder's blanket LOCK (9 Nov) |
