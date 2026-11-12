---
id: DOC-TFG-0166
type: SPEC
status: CURRENT
feature: SIDE_BROTHERS
purpose: LOCK 52 - River Market side mission - two brothers not speaking
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0167]
owner: THE FOUR GATES chat
---

# SIDE BROTHERS SPEC — CURRENT VERSION V1 (LOCK 52)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_brothers_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 59 comes after line 58 |
| Masters | `../MASTERS/sa01`-`sa04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Muslim 2605, Bukhari 2692 (making peace) - checked 6 Nov |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: how far “saying good” may go when making peace |



## Mission `brothers` - Two brothers not speaking (side mission)

Button `button`, shown when: River Market place `spice`; 08:00-18:00; trust ≥ 30; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Tell each one the other still cares for him` → `peace` · trust +5; flag `brothers_peace`; say `peace`<br>`Tell each exactly what the other said` → `worse` · trust -2; say `worse`<br>`Stay out of it` → `out` · - |
| `peace` | End: Back; mission done |
| `worse` | End: Back; mission done |
| `out` | End: Back; mission done |

What people say lines (`say`): `peace` (good, the spice row); `worse` (bad, the spice row) - shown in River Market What people say.

## Masters

- `sa01_brothers__a.png`
- `sa02_brothers__peace.png`
- `sa03_brothers__worse.png`
- `sa04_brothers__out.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_brothers_data_V1.json` (copied byte for byte to `SOURCE/data/side_brothers.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 52 under the Founder's blanket LOCK (9 Nov) |
