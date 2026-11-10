---
id: DOC-TFG-0286
type: SPEC
status: CURRENT
feature: WAQF
purpose: LOCK 92 - four endowments (waqf)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0287]
owner: THE FOUR GATES chat
---

# WAQF SPEC — CURRENT VERSION V1 (LOCK 92)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `waqf_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 99 comes after line 98 |
| Masters | `../MASTERS/oe01`-`oe16` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2737 - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: naming an endowment publicly or in secret |



## Mission `waqf_library` - A shelf for the House of Learning (scene)

Button `button`, shown when: River Market place `centre`; 08:00-18:00; after `library_met`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Endow it in your name · 200 coins` (needs 200 coins) → `named` · coins -200; trust +5; say `named`; waqf +1<br>`Endow it with no name · 200 coins` (needs 200 coins) → `secret` · coins -200; waqf +1<br>`Not now` → `no` · - |
| `named` | End: Back; mission done |
| `secret` | End: Back; mission done |
| `no` | End: Back; mission done |

What people say lines (`say`): `named` (good, the scholars) - shown in River Market What people say.

## Mission `waqf_guesthouse` - A room for travellers (scene)

Button `button`, shown when: River Market place `inn`; 08:00-18:00; after `chapter2_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Endow it in your name · 250 coins` (needs 250 coins) → `named` · coins -250; trust +5; say `named`; waqf +1<br>`Endow it with no name · 250 coins` (needs 250 coins) → `secret` · coins -250; waqf +1<br>`Not now` → `no` · - |
| `named` | End: Back; mission done |
| `secret` | End: Back; mission done |
| `no` | End: Back; mission done |

What people say lines (`say`): `named` (good, the inn) - shown in River Market What people say.

## Mission `waqf_hospital` - A bed in the hospital (scene)

Button `button`, shown when: town `shifara` hub; 08:00-18:00; after `shifara_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Endow it in your name · 150 coins` (needs 150 coins) → `named` · coins -150; trust +5; say `named`; waqf +1<br>`Endow it with no name · 150 coins` (needs 150 coins) → `secret` · coins -150; waqf +1<br>`Not now` → `no` · - |
| `named` | End: Back; mission done |
| `secret` | End: Back; mission done |
| `no` | End: Back; mission done |

What people say lines (`say`): `named` (good, Rahma the physician) - shown in the town's What people say.

## Mission `waqf_well` - A well for Birana (scene)

Button `button`, shown when: town `birana` hub; 05:00-15:00; after `birana_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Endow it in your name · 120 coins` (needs 120 coins) → `named` · coins -120; trust +5; say `named`; waqf +1<br>`Endow it with no name · 120 coins` (needs 120 coins) → `secret` · coins -120; waqf +1<br>`Not now` → `no` · - |
| `named` | End: Back; mission done |
| `secret` | End: Back; mission done |
| `no` | End: Back; mission done |

What people say lines (`say`): `named` (good, the women at the wells) - shown in the town's What people say.

## Masters

- `oe01_waqf_library__a.png`
- `oe02_waqf_library__named.png`
- `oe03_waqf_library__secret.png`
- `oe04_waqf_library__no.png`
- `oe05_waqf_guesthouse__a.png`
- `oe06_waqf_guesthouse__named.png`
- `oe07_waqf_guesthouse__secret.png`
- `oe08_waqf_guesthouse__no.png`
- `oe09_waqf_hospital__a.png`
- `oe10_waqf_hospital__named.png`
- `oe11_waqf_hospital__secret.png`
- `oe12_waqf_hospital__no.png`
- `oe13_waqf_well__a.png`
- `oe14_waqf_well__named.png`
- `oe15_waqf_well__secret.png`
- `oe16_waqf_well__no.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `waqf_data_V1.json` (copied byte for byte to `SOURCE/data/waqf.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 92 under the Founder's blanket LOCK (9 Nov) |
