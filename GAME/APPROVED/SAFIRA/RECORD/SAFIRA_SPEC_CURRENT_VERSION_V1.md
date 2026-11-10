---
id: DOC-TFG-0130
type: SPEC
status: CURRENT
feature: SAFIRA
purpose: LOCK 40 - Safira, the caravanserai (chapter 2): town, masjid, people; missions The slow pilgrim and Lost at night
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0131]
owner: THE FOUR GATES chat
---

# SAFIRA SPEC — CURRENT VERSION V1 (LOCK 40)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `safira_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 47 comes after line 46 |
| Masters | `../MASTERS/sf01`-`sf23` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 2:153 (Allah is with the patient); Quran 16:16 (by the stars they are guided) |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `safira` | Safira | patience | 10 | 2 | `Water the camels · 4 coins` 06:00-18:00, 60 min, +4 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `safira` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `harun` | Harun | the caravan master | 05:00-20:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `slow_pilgrim_walked` |
| `amina` | Amina | the keeper of the caravanserai | 05:00-21:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `night_found` |
| `shuayb` | Shuayb | an old pilgrim going home | always | `lines` by town trust: wary < 30, friendly < 70, warm | - |

## Mission `slow_pilgrim` - The slow pilgrim (main story)

Button `button`, shown when: town `safira` hub; 05:00-12:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Walk with Shuayb behind the caravan` → `walk` · trust +8; flag `slow_pilgrim_walked`, `slow_pilgrim_done`; say `walked`; clock +240 min<br>`Pay for a camel for him · 15 coins` (needs 15 coins) → `camel` · coins -15; trust +5; flag `slow_pilgrim_done`; say `camel`<br>`It's not your business` → `left` · flag `slow_pilgrim_done` |
| `walk` | End: Back; mission done |
| `camel` | End: Back; mission done |
| `left` | End: Back; mission done |

What people say lines (`say`): `walked` (good, Harun the caravan master); `camel` (good, the camel drivers) - shown in What Safira says.

## Mission `lost_night` - Lost at night (main story)

Button `button`, shown when: town `safira` hub; 18:00-22:00; after `slow_pilgrim_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Go now with a lantern` → `b` · -<br>`Leave it to Harun's men` → `wait` · flag `safira_done` |
| `b` | `Follow the still star` → `found` · trust +10; flag `night_found`, `safira_done`; say `found`; stars +1<br>`Keep searching the hollows` → `lost` · trust +3; flag `safira_done`; clock +180 min |
| `found` | End: Back; mission done |
| `lost` | End: Back; mission done |
| `wait` | End: Back; mission done |

What people say lines (`say`): `found` (good, Amina of the caravanserai) - shown in What Safira says.

## Masters

- `sf01_safira__town.png`
- `sf02_safira__people.png`
- `sf03_safira__harun_trust_10.png`
- `sf04_safira__harun_trust_50.png`
- `sf05_safira__harun_trust_80.png`
- `sf06_safira__amina_trust_10.png`
- `sf07_safira__amina_trust_50.png`
- `sf08_safira__amina_trust_80.png`
- `sf09_safira__shuayb_trust_10.png`
- `sf10_safira__shuayb_trust_50.png`
- `sf11_safira__shuayb_trust_80.png`
- `sf12_safira__what_people_say_empty.png`
- `sf13_safira__masjid_prayer.png`
- `sf14_safira__masjid_first_prayer.png`
- `sf15_slow_pilgrim__a.png`
- `sf16_slow_pilgrim__walk.png`
- `sf17_slow_pilgrim__camel.png`
- `sf18_slow_pilgrim__left.png`
- `sf19_lost_night__a.png`
- `sf20_lost_night__b.png`
- `sf21_lost_night__found.png`
- `sf22_lost_night__lost.png`
- `sf23_lost_night__wait.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `safira_data_V1.json` (copied byte for byte to `SOURCE/data/safira.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 40 under the Founder's blanket LOCK (9 Nov) |
