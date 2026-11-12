---
id: DOC-TFG-0304
type: SPEC
status: CURRENT
feature: REGULARS_ROUTES
purpose: LOCK 98 - the regulars walk their routes
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0305]
owner: THE FOUR GATES chat
---

# REGULARS ROUTES SPEC — CURRENT VERSION V1 (LOCK 98)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `regulars_routes_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 105 comes after line 104 |
| Masters | `../MASTERS/fa01`-`fa04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | - |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |

## 2. Routes

The five regulars of LOCK 6 move between places by time (`routes.people`: [from, to, place] in minutes of the day); outside those windows they are at their LOCK 6 place. LOCK 7 hours, LOCK 27 prayer times and Friday still decide when they are away. In the 3D game they walk between the places by the shortest street path, starting 10 minutes before the window.


## Masters

- `fa01_routes__rashid_at_the_quay_0730.png`
- `fa02_routes__rashid_at_his_stall_1000.png`
- `fa03_routes__salma_at_the_quay_1430.png`
- `fa04_routes__salma_buying_flour_1430.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `regulars_routes_data_V1.json` (copied byte for byte to `SOURCE/data/regulars_routes.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 98 under the Founder's blanket LOCK (9 Nov) |
