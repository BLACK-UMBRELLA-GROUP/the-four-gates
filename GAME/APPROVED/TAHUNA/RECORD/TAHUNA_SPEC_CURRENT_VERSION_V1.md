---
id: DOC-TFG-0145
type: SPEC
status: CURRENT
feature: TAHUNA
purpose: LOCK 45 - Tahuna, the mill (chapter 3): town, masjid, people; missions The miller's debt, The enemy's son and Mercy shown (Idris opens the Gate of Knowledge)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0146]
owner: THE FOUR GATES chat
---

# TAHUNA SPEC — CURRENT VERSION V1 (LOCK 45)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `tahuna_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 52 comes after line 51 |
| Masters | `../MASTERS/th01`-`th24` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2078 (the man who forgave debtors) - checked on sunnah.com; Quran 2:280, 41:34, 21:107 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `tahuna` | Tahuna | mercy | 10 | 2 | `Carry sacks at the mill · 5 coins` 06:00-18:00, 90 min, +5 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `tahuna` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `man` | Ma'n | the miller | 05:00-19:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `debt_paid`, `debt_seized` |
| `hafsa` | Hafsa | the miller's wife | 06:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | - |
| `rami` | Rami | Khattab's son | 07:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `enemy_helped` |

## Mission `millers_debt` - The miller's debt (main story)

Button `button`, shown when: town `tahuna` hub; 06:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Pay his debt to Karim yourself · 30 coins` (needs 30 coins) → `paid` · coins -30; trust +10; flag `debt_paid`, `tahuna_debt`; say `paid`<br>`Write to Karim asking him to wait` → `time` · trust +5; flag `debt_time`, `tahuna_debt`; say `time`<br>`Take his flour sacks for Karim` → `seized` · coins +5; trust -10; flag `debt_seized`, `tahuna_debt`; say `seized` |
| `paid` | End: Back; mission done |
| `time` | End: Back; mission done |
| `seized` | End: Back; mission done |

What people say lines (`say`): `paid` (good, the farmers on the bank); `time` (good, the farmers on the bank); `seized` (bad, the farmers on the bank) - shown in What Tahuna says.

## Mission `enemy_son` - The enemy's son (main story)

Button `button`, shown when: town `tahuna` hub; 06:00-18:00; after `tahuna_debt`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Carry him and pay the carter · 8 coins` (needs 8 coins) → `help` · coins -8; trust +10; flag `enemy_helped`, `tahuna_done`; say `helped`<br>`Carry him; let someone else pay` → `carry` · trust +6; flag `enemy_helped`, `tahuna_done`<br>`Leave him to the millers` → `leave` · flag `tahuna_done` |
| `help` | End: Back; mission done |
| `carry` | End: Back; mission done |
| `leave` | End: Back; mission done |

What people say lines (`say`): `helped` (good, the millers) - shown in What Tahuna says.

## Mission `mercy_home` - Mercy shown (main story)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; after `nahla_done`, `tinara_done`, `tahuna_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask about the road west` → `b` · flag `chapter3_done` |
| `b` | End: Back; mission done |

## Masters

- `th01_tahuna__town.png`
- `th02_tahuna__people.png`
- `th03_tahuna__man_trust_10.png`
- `th04_tahuna__man_trust_50.png`
- `th05_tahuna__man_trust_80.png`
- `th06_tahuna__hafsa_trust_10.png`
- `th07_tahuna__hafsa_trust_50.png`
- `th08_tahuna__hafsa_trust_80.png`
- `th09_tahuna__rami_trust_10.png`
- `th10_tahuna__rami_trust_50.png`
- `th11_tahuna__rami_trust_80.png`
- `th12_tahuna__what_people_say_empty.png`
- `th13_tahuna__masjid_prayer.png`
- `th14_tahuna__masjid_first_prayer.png`
- `th15_millers_debt__a.png`
- `th16_millers_debt__paid.png`
- `th17_millers_debt__time.png`
- `th18_millers_debt__seized.png`
- `th19_enemy_son__a.png`
- `th20_enemy_son__help.png`
- `th21_enemy_son__carry.png`
- `th22_enemy_son__leave.png`
- `th23_mercy_home__a.png`
- `th24_mercy_home__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `tahuna_data_V1.json` (copied byte for byte to `SOURCE/data/tahuna.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 45 under the Founder's blanket LOCK (9 Nov) |
