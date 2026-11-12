---
id: DOC-TFG-0259
type: SPEC
status: CURRENT
feature: VISITING_SICK
purpose: LOCK 83 - visiting the sick
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0260]
owner: THE FOUR GATES chat
---

# VISITING SICK SPEC — CURRENT VERSION V1 (LOCK 83)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `visiting_sick_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 90 comes after line 89 |
| Masters | `../MASTERS/dj01`-`dj04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Muslim 2569 - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `visit_sick` - Visiting the sick (scene)

Button `button`, shown when: River Market place `inn`; 10:00-19:00; after `chapter1_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Visit him and sit a while` → `sit` · trust +3; flag `visited_musa`; say `visited`; clock +60 min<br>`Take him soup · 3 coins` (needs 3 coins) → `soup` · coins -3; trust +3; flag `visited_musa`; say `visited`; clock +30 min<br>`Maybe later` → `later` · - |
| `sit` | End: Back; mission done |
| `soup` | End: Back; mission done |
| `later` | End: Back; mission done |

What people say lines (`say`): `visited` (good, Idris) - shown in River Market What people say.

## Masters

- `dj01_visit_sick__a.png`
- `dj02_visit_sick__sit.png`
- `dj03_visit_sick__soup.png`
- `dj04_visit_sick__later.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `visiting_sick_data_V1.json` (copied byte for byte to `SOURCE/data/visiting_sick.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 83 under the Founder's blanket LOCK (9 Nov) |
