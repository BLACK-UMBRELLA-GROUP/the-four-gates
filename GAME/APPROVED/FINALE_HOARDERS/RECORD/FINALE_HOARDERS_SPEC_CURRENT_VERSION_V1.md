---
id: DOC-TFG-0157
type: SPEC
status: CURRENT
feature: FINALE_HOARDERS
purpose: LOCK 49 - the finale in River Market - The hoarders (with Jalal's payout) and The bread lines
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0158]
owner: THE FOUR GATES chat
---

# FINALE HOARDERS SPEC — CURRENT VERSION V1 (LOCK 49)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `finale_hoarders_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 56 comes after line 55 |
| Masters | `../MASTERS/h101`-`h111` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Muslim 1605 (no one hoards but a sinner) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `hoarders` - The hoarders (main story)

Button `button`, shown when: River Market place `board`; 08:00-18:00; after `chapter4_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Refuse, and tell Qadi Ibrahim` → `qadi` · trust +10; flag `hoard_exposed`, `hoarders_done`; say `exposed`<br>`Refuse quietly` → `quiet` · flag `hoarders_done`<br>`Buy a share · 30 coins` (needs 30 coins) → `buy` · coins -30; flag `hoarded`, `hoarders_done` |
| `qadi` | End: Back; mission done |
| `quiet` | End: Back; mission done |
| `buy` | End: Back; mission done |

What people say lines (`say`): `exposed` (good, River Market) - shown in River Market What people say.

## Mission `hoard_profit` - Jalal pays out (main story)

Button `button`, shown when: River Market place `board`; after `hoarded`; 30 days after `hoarded`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take the sixty` → `took` · coins +60; trust -15; say `profited`<br>`Give it all to Salma's oven` → `gave` · trust +5; say `gave`; meals +300 |
| `took` | End: Back; mission done |
| `gave` | End: Back; mission done |

What people say lines (`say`): `profited` (bad, the bread line); `gave` (mixed, Salma the baker) - shown in River Market What people say.

## Mission `bread_lines` - The bread lines (main story)

Button `button`, shown when: River Market place `board`; 06:00-18:00; after `hoarders_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Buy flour for Salma's oven · 40 coins` (needs 40 coins) → `flour` · coins -40; trust +8; flag `bread_done`; say `flour`; meals +400<br>`Stand in the line and keep order` → `order` · trust +5; flag `bread_done`; say `order`; clock +180 min<br>`Push to the front for your own bread` → `self` · trust -5; flag `bread_done`; say `pushed` |
| `flour` | End: Back; mission done |
| `order` | End: Back; mission done |
| `self` | End: Back; mission done |

What people say lines (`say`): `flour` (good, Salma the baker); `order` (good, River Market); `pushed` (bad, River Market) - shown in River Market What people say.

## Masters

- `h101_hoarders__a.png`
- `h102_hoarders__qadi.png`
- `h103_hoarders__quiet.png`
- `h104_hoarders__buy.png`
- `h105_hoard_profit__a.png`
- `h106_hoard_profit__took.png`
- `h107_hoard_profit__gave.png`
- `h108_bread_lines__a.png`
- `h109_bread_lines__flour.png`
- `h110_bread_lines__order.png`
- `h111_bread_lines__self.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `finale_hoarders_data_V1.json` (copied byte for byte to `SOURCE/data/finale_hoarders.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 49 under the Founder's blanket LOCK (9 Nov) |
