---
id: DOC-TFG-0117
type: SPEC
status: CURRENT
feature: ROAD_MAP
purpose: LOCK 36 - the road map of the four gates and twelve towns, opening one after another, and the gates of Ilmara shut at night
links: [AD-AIOS-115, DOC-TFG-0105, DOC-TFG-0111, DOC-TFG-0118]
owner: THE FOUR GATES chat
---

# ROAD MAP SPEC — CURRENT VERSION V1 (LOCK 36)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `road_map_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 world (four gates, three towns each), LOCK 32 the road east, LOCK 34 towns. Queue line 43 comes after line 42 |
| Masters | `../MASTERS/rd01`-`rd03` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | - |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |

## 2. The road map

Opened by `map_button` at the River Market Gate of Trust (once opened), in Jisra and in every town hub.

| Part | Rule |
|---|---|
| Rows | Ilmara · River Market, then each gate (`gates`: name and direction) - closed gates show `gate_closed`; open gates list their three `roads` |
| Gate opens | Trust: LOCK 32 gate opened. Patience: `chapter1_done`. Mercy: `chapter2_done`. Knowledge: `chapter3_done` |
| Town opens | Its gate is open and its `opens` flag is set (Jisra: none; Sahila: `met_jisra`, set the first time you reach Jisra; Sukara: `sahila_boat_done`; and so on) |
| Travel time | Towns behind one gate lie on one road at `minutes` from Ilmara: between them the difference; to Ilmara the town's minutes; to another gate's town through Ilmara (both added) |
| Go | `go` with the minutes; the clock advances; you arrive at the town hub (Jisra: the LOCK 32 panel); Ilmara: the Gate of Trust |

## 3. The gates at night

From `gates_close` (20:00) to `gates_open` (04:40) the gates of Ilmara are shut and nobody travels: the road map shows `night` and no Go buttons; LOCK 32's road buttons show the same line instead of travelling. Rest at an inn (LOCK 34) until morning.


## Masters

- `rd01_map__from_jisra_day.png`
- `rd02_map__patience_open.png`
- `rd03_map__night_gates_shut.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Roads with their own scenes; caravans; horses or camels making travel faster (owning things comes later).

## Build rules

Words and numbers only from `road_map_data_V1.json` (copied byte for byte to `SOURCE/data/road_map.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 36 under the Founder's blanket LOCK (9 Nov) |
