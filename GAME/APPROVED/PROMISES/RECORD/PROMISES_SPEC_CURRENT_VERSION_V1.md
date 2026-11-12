---
id: DOC-TFG-0265
type: SPEC
status: CURRENT
feature: PROMISES
purpose: LOCK 85 - a promise to Jamal
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0266]
owner: THE FOUR GATES chat
---

# PROMISES SPEC — CURRENT VERSION V1 (LOCK 85)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `promises_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 92 comes after line 91 |
| Masters | `../MASTERS/dl01`-`dl03` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 33 - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `promise` - A promise (scene)

Button `button`, shown when: River Market place `quay`; 08:00-18:00; after `chapter1_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Promise to come` → `leave` · flag `promise_made`<br>`Say you can't` → `leave` · - |

## Mission `promise_kept` - A promise kept (scene)

Button `button`, shown when: River Market place `quay`; 04:40-07:00; after `promise_made`; 1 days after `promise_made`; not after `promise_kept`, `promise_broken`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Unload the timber` → `leave` · trust +5; flag `promise_kept`; say `kept`; clock +90 min |

What people say lines (`say`): `kept` (good, Jamal the boatman) - shown in River Market What people say.

## Mission `promise_broken` - A promise broken (scene)

Button `button`, shown when: River Market place `quay`; 07:00-19:00; after `promise_made`; 1 days after `promise_made`; not after `promise_kept`, `promise_broken`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Apologise` → `leave` · trust -5; flag `promise_broken`; say `broke` |

What people say lines (`say`): `broke` (bad, Jamal the boatman) - shown in River Market What people say.

## Masters

- `dl01_promise__a.png`
- `dl02_promise_kept__a.png`
- `dl03_promise_broken__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `promises_data_V1.json` (copied byte for byte to `SOURCE/data/promises.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 85 under the Founder's blanket LOCK (9 Nov) |
