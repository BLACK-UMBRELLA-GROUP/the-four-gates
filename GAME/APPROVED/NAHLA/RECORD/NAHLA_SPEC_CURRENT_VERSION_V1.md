---
id: DOC-TFG-0139
type: SPEC
status: CURRENT
feature: NAHLA
purpose: LOCK 43 - Nahla, the beekeepers (chapter 3): town, masjid, people; missions The sick child and The overloaded donkey
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0140]
owner: THE FOUR GATES chat
---

# NAHLA SPEC — CURRENT VERSION V1 (LOCK 43)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `nahla_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 50 comes after line 49 |
| Masters | `../MASTERS/nh01`-`nh22` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 16:69 (honey, a healing); Abu Dawud 2548 (fear Allah regarding animals) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `nahla` | Nahla | mercy | 10 | 2 | `Carry honey jars down the hill · 4 coins` 07:00-16:00, 60 min, +4 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `nahla` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `dawud` | Dawud | the beekeeper | 05:00-18:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `sick_sat` |
| `umm_yahya` | Umm Yahya | a mother | 06:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `sick_sat` |
| `ayyub` | Ayyub | the carter | 07:00-17:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `donkey_helped` |

## Mission `sick_child` - The sick child (main story)

Button `button`, shown when: town `nahla` hub; 06:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Sit with the boy through the night` → `sit` · trust +8; flag `sick_sat`, `sick_child_done`; say `sat`; clock +600 min<br>`Buy honey and herbs for her · 12 coins` (needs 12 coins) → `buy` · coins -12; trust +5; flag `sick_child_done`; say `bought`<br>`Wish her well and go` → `go` · flag `sick_child_done` |
| `sit` | End: Back; mission done |
| `buy` | End: Back; mission done |
| `go` | End: Back; mission done |

What people say lines (`say`): `sat` (good, Umm Yahya); `bought` (good, Dawud the beekeeper) - shown in What Nahla says.

## Mission `overloaded_donkey` - The overloaded donkey (main story)

Button `button`, shown when: town `nahla` hub; 07:00-17:00; after `sick_child_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Stop him and help unload half` → `help` · trust +6; flag `donkey_helped`, `nahla_done`; say `helped`; clock +60 min<br>`Pay for a second donkey · 6 coins` (needs 6 coins) → `hire` · coins -6; trust +4; flag `donkey_helped`, `nahla_done`<br>`Walk on` → `walk` · flag `nahla_done` |
| `help` | End: Back; mission done |
| `hire` | End: Back; mission done |
| `walk` | End: Back; mission done |

What people say lines (`say`): `helped` (good, the hill road) - shown in What Nahla says.

## Masters

- `nh01_nahla__town.png`
- `nh02_nahla__people.png`
- `nh03_nahla__dawud_trust_10.png`
- `nh04_nahla__dawud_trust_50.png`
- `nh05_nahla__dawud_trust_80.png`
- `nh06_nahla__umm_yahya_trust_10.png`
- `nh07_nahla__umm_yahya_trust_50.png`
- `nh08_nahla__umm_yahya_trust_80.png`
- `nh09_nahla__ayyub_trust_10.png`
- `nh10_nahla__ayyub_trust_50.png`
- `nh11_nahla__ayyub_trust_80.png`
- `nh12_nahla__what_people_say_empty.png`
- `nh13_nahla__masjid_prayer.png`
- `nh14_nahla__masjid_first_prayer.png`
- `nh15_sick_child__a.png`
- `nh16_sick_child__sit.png`
- `nh17_sick_child__buy.png`
- `nh18_sick_child__go.png`
- `nh19_overloaded_donkey__a.png`
- `nh20_overloaded_donkey__help.png`
- `nh21_overloaded_donkey__hire.png`
- `nh22_overloaded_donkey__walk.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `nahla_data_V1.json` (copied byte for byte to `SOURCE/data/nahla.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 43 under the Founder's blanket LOCK (9 Nov) |
