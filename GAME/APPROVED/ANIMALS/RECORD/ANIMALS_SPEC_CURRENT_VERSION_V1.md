---
id: DOC-TFG-0274
type: SPEC
status: CURRENT
feature: ANIMALS
purpose: LOCK 88 - animals (donkey, camel, horse) and feeding them
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0275]
owner: THE FOUR GATES chat
---

# ANIMALS SPEC — CURRENT VERSION V1 (LOCK 88)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `animals_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 95 comes after line 94 |
| Masters | `../MASTERS/oa01`-`oa05` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Abu Dawud 2548 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |

## 2. Animals

Owning an animal shortens every road: the best animal you own multiplies LOCK 36 road minutes by `numbers` (donkey 0.75, camel 0.6, horse 0.5), rounded. The animal must be fed at the inn stable (1 coin a day). If it hasn't been fed for `unfed_days` (3) days, the stable boy's scene runs (-3 trust and a What people say line).

## Mission `buy_animal` - Saeed's animals (scene)

Button `button`, shown when: River Market place `gate`; 07:00-18:00; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `The donkey · 40 coins` (needs 40 coins) → `b` · coins -40; flag `own_donkey`, `own_any`<br>`The camel · 120 coins` (needs 120 coins) → `b` · coins -120; flag `own_camel`, `own_any`<br>`The mare · 200 coins` (needs 200 coins) → `b` · coins -200; flag `own_horse`, `own_any`<br>`Not today` → `no` · - |
| `b` | End: Back; mission done |
| `no` | End: Back; mission done |

## Mission `feed_animal` - Feeding your animal (scene)

Button `button`, shown when: River Market place `inn`; 05:00-20:00; after `own_any`; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Done` → `leave` · coins -1; clock +10 min |

## Mission `animal_neglected` - The stable boy (scene)

Button `button`, shown when: River Market place `inn`; 05:00-20:00; after `own_any`; once a day.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Pay him back and feed it · 3 coins` → `leave` · coins -3; trust -3; say `neglect` |

What people say lines (`say`): `neglect` (bad, the stable boy at the inn) - shown in River Market What people say.

## Masters

- `oa01_buy_animal__a.png`
- `oa02_buy_animal__b.png`
- `oa03_buy_animal__no.png`
- `oa04_feed_animal__a.png`
- `oa05_animal_neglected__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `animals_data_V1.json` (copied byte for byte to `SOURCE/data/animals.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 88 under the Founder's blanket LOCK (9 Nov) |
