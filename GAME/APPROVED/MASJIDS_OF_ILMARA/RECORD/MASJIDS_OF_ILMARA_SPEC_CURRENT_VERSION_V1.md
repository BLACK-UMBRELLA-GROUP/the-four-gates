---
id: DOC-TFG-0316
type: SPEC
status: CURRENT
feature: MASJIDS_OF_ILMARA
purpose: LOCK 102 - the masjids of Ilmara (to reach 50)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0317]
owner: THE FOUR GATES chat
---

# MASJIDS OF ILMARA SPEC — CURRENT VERSION V1 (LOCK 102)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `masjids_of_ilmara_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 109 comes after line 108 |
| Masters | `../MASTERS/fe01`-`fe08` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | - |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |

## 2. Inside the walls

Five district hubs (`ilmara.towns`: Centre, North, West, South, East · the back lanes) appear on the road map under “Inside the walls”, a walk of `walk` minutes from River Market. Inside the walls you can walk at any hour (the night rule of LOCK 36 is for the roads outside). Districts use River Market trust and have no people, work, inn or What people say yet - only their masjids (`ilmara.masjids`, LOCK 33 rules). With these 37, the masjids in the game reach 50.


## Masters

- `fe01_map__inside_the_walls.png`
- `fe02_map__night_inside_walls_open.png`
- `fe03_district__centre.png`
- `fe04_district__north.png`
- `fe05_district__west.png`
- `fe06_district__south.png`
- `fe07_district__east_lanes.png`
- `fe08_masjid__the_great_masjid.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `masjids_of_ilmara_data_V1.json` (copied byte for byte to `SOURCE/data/masjids_of_ilmara.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 102 under the Founder's blanket LOCK (9 Nov) |
