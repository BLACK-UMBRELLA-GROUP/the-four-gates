---
id: DOC-TFG-0154
type: SPEC
status: CURRENT
feature: SHIFARA
purpose: LOCK 48 - Shifara, the hospital (chapter 4): town, masjid, people; missions The fever, The doctor's secret and Knowledge carried (Idris: the hard year begins)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0155]
owner: THE FOUR GATES chat
---

# SHIFARA SPEC — CURRENT VERSION V1 (LOCK 48)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `shifara_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 55 comes after line 54 |
| Masters | `../MASTERS/sd01`-`sd23` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 5728 (plague: do not enter, do not leave) and Muslim 2699 (covering faults) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: the plague rule applied to a fever |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `shifara` | Shifara | knowledge | 10 | 2 | `Wash bandages at the hospital · 3 coins` 06:00-15:00, 60 min, +3 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `shifara` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `rahma` | Rahma | the physician | 06:00-21:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `fever_stayed` |
| `shakir` | Shakir | a talker | 08:00-20:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `secret_told` |
| `malik` | Malik | a patient's father | 08:00-19:00 | `lines` by town trust: wary < 30, friendly < 70, warm | - |

## Mission `fever` - The fever (main story)

Button `button`, shown when: town `shifara` hub; 06:00-20:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Stay and help in the wards` → `stay` · trust +10; flag `fever_stayed`, `fever_done`; say `stayed`; clock +480 min<br>`Stay at the inn and wait` → `wait` · flag `fever_done`<br>`Slip out over the wall` → `flee` · trust -10; flag `fever_done`; say `fled` |
| `stay` | End: Back; mission done |
| `wait` | End: Back; mission done |
| `flee` | End: Back; mission done |

What people say lines (`say`): `stayed` (good, Rahma the physician); `fled` (bad, the whole town) - shown in What Shifara says.

## Mission `doctor_secret` - The doctor's secret (main story)

Button `button`, shown when: town `shifara` hub; 08:00-20:00; after `fever_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Say nothing about it` → `keep` · trust +6; flag `secret_kept`, `shifara_done`; say `kept`<br>`Tell him` → `tell` · trust -10; flag `secret_told`, `shifara_done`; say `told` |
| `keep` | End: Back; mission done |
| `tell` | End: Back; mission done |

What people say lines (`say`): `kept` (good, Rahma the physician); `told` (bad, the hospital) - shown in What Shifara says.

## Mission `knowledge_home` - Knowledge carried (main story)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; after `waraka_done`, `najmara_done`, `shifara_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Stay in Ilmara` → `b` · flag `chapter4_done` |
| `b` | End: Back; mission done |

## Masters

- `sd01_shifara__town.png`
- `sd02_shifara__people.png`
- `sd03_shifara__rahma_trust_10.png`
- `sd04_shifara__rahma_trust_50.png`
- `sd05_shifara__rahma_trust_80.png`
- `sd06_shifara__shakir_trust_10.png`
- `sd07_shifara__shakir_trust_50.png`
- `sd08_shifara__shakir_trust_80.png`
- `sd09_shifara__malik_trust_10.png`
- `sd10_shifara__malik_trust_50.png`
- `sd11_shifara__malik_trust_80.png`
- `sd12_shifara__what_people_say_empty.png`
- `sd13_shifara__masjid_prayer.png`
- `sd14_shifara__masjid_first_prayer.png`
- `sd15_fever__a.png`
- `sd16_fever__stay.png`
- `sd17_fever__wait.png`
- `sd18_fever__flee.png`
- `sd19_doctor_secret__a.png`
- `sd20_doctor_secret__keep.png`
- `sd21_doctor_secret__tell.png`
- `sd22_knowledge_home__a.png`
- `sd23_knowledge_home__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `shifara_data_V1.json` (copied byte for byte to `SOURCE/data/shifara.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 48 under the Founder's blanket LOCK (9 Nov) |
