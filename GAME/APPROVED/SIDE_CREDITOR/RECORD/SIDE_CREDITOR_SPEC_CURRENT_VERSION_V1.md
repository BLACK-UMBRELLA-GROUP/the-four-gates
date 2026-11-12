---
id: DOC-TFG-0175
type: SPEC
status: CURRENT
feature: SIDE_CREDITOR
purpose: LOCK 55 - River Market side mission - a creditor beating a debtor
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0176]
owner: THE FOUR GATES chat
---

# SIDE CREDITOR SPEC — CURRENT VERSION V1 (LOCK 55)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_creditor_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 62 comes after line 61 |
| Masters | `../MASTERS/se01`-`se04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 2:280 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `creditor` - A creditor beating a debtor (side mission)

Button `button`, shown when: River Market place `quay`; 07:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Pull them apart and ask Zahir to give him time` → `time` · trust +5; say `stopped`<br>`Pay part of the debt · 10 coins` (needs 10 coins) → `paid` · coins -10; trust +6; say `paid`<br>`Walk past` → `past` · - |
| `time` | End: Back; mission done |
| `paid` | End: Back; mission done |
| `past` | End: Back; mission done |

What people say lines (`say`): `stopped` (good, the quay); `paid` (good, the quay) - shown in River Market What people say.

## Masters

- `se01_creditor__a.png`
- `se02_creditor__time.png`
- `se03_creditor__paid.png`
- `se04_creditor__past.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_creditor_data_V1.json` (copied byte for byte to `SOURCE/data/side_creditor.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 55 under the Founder's blanket LOCK (9 Nov) |
