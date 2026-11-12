---
id: DOC-TFG-0280
type: SPEC
status: CURRENT
feature: LAND_AND_HOUSE
purpose: LOCK 90 - a house, sleeping at home, and an orchard
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0281]
owner: THE FOUR GATES chat
---

# LAND AND HOUSE SPEC — CURRENT VERSION V1 (LOCK 90)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `land_and_house_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 97 comes after line 96 |
| Masters | `../MASTERS/oc01`-`oc06` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2320 - checked on sunnah.com; Quran 6:141 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |

## 2. Home

After buying the house, “Go home to sleep” is offered at the quay from 19:00 to 04:30: no coins, wake at 04:40 (LOCK 34 wake).

## Mission `buy_house` - The house by the canal (scene)

Button `button`, shown when: River Market place `quay`; 08:00-18:00; after `chapter1_done`; not after `own_house`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Buy it · 300 coins` (needs 300 coins) → `b` · coins -300; flag `own_house`<br>`Not now` → `no` · - |
| `b` | End: Back; mission done |
| `no` | End: Back; mission done |

## Mission `sleep_home` - Home (scene)

Button `button`, shown when: River Market place `quay`; 19:00-04:30; after `own_house`; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Sleep` → `leave` · - |

## Mission `buy_orchard` - An orchard (scene)

Button `button`, shown when: town `tinara` hub; 07:00-17:00; after `tinara_done`; not after `own_orchard`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Buy it · 150 coins` (needs 150 coins) → `leave` · coins -150; flag `own_orchard`<br>`Not now` → `leave` · - |

## Mission `orchard_harvest` - The harvest (scene)

Button `button`, shown when: town `tinara` hub; 07:00-17:00; after `own_orchard`; 30 days after `own_orchard`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Leave the gleanings for them` → `leave` · coins +25; meals +20<br>`Sell every last apricot` → `leave` · coins +30 |

## Masters

- `oc01_buy_house__a.png`
- `oc02_buy_house__b.png`
- `oc03_buy_house__no.png`
- `oc04_sleep_home__a.png`
- `oc05_buy_orchard__a.png`
- `oc06_orchard_harvest__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `land_and_house_data_V1.json` (copied byte for byte to `SOURCE/data/land_and_house.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 90 under the Founder's blanket LOCK (9 Nov) |
