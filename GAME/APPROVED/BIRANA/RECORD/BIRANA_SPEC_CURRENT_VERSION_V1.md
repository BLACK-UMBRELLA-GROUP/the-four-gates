---
id: DOC-TFG-0136
type: SPEC
status: CURRENT
feature: BIRANA
purpose: LOCK 42 - Birana, the wells (chapter 2): town, masjid, people; missions The dry well, The long wait, the permit, and Patience kept (Idris opens the Gate of Mercy)
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0137]
owner: THE FOUR GATES chat
---

# BIRANA SPEC — CURRENT VERSION V1 (LOCK 42)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `birana_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 49 comes after line 48 |
| Masters | `../MASTERS/bi01`-`bi28` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 2:153, 2:155-157; Abu Dawud 3580 (the briber and the bribe-taker) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `birana` | Birana | patience | 10 | 2 | `Draw water for the queue · 3 coins` 05:00-12:00, 60 min, +3 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `birana` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `thabit` | Thabit | the well digger | 05:00-18:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `well_dug` |
| `safiyya` | Safiyya | the water carrier | 05:00-15:00 | `lines` by town trust: wary < 30, friendly < 70, warm | - |
| `wahb` | Wahb | the governor's clerk | 08:00-15:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `reported_wahb`, `bribed` |

## Mission `dry_well` - The dry well (main story)

Button `button`, shown when: town `birana` hub; 05:00-15:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Dig with him` → `b` · clock +480 min<br>`Pay a labourer to dig · 20 coins` (needs 20 coins) → `pay` · coins -20; trust +3; flag `dry_well_done`<br>`Leave it to Thabit` → `leave` · flag `dry_well_done` |
| `b` | `Dig one more day` → `water` · trust +10; flag `well_dug`, `dry_well_done`; say `dug`; clock +480 min<br>`Give up` → `gave` · flag `dry_well_done` |
| `water` | End: Back; mission done |
| `gave` | End: Back; mission done |
| `pay` | End: Back; mission done |
| `leave` | End: Back; mission done |

What people say lines (`say`): `dug` (good, the women at the wells) - shown in What Birana says.

## Mission `long_wait` - The long wait (main story)

Button `button`, shown when: town `birana` hub; 08:00-15:00; after `dry_well_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Wait for the permit` → `wait` · flag `permit_waiting`<br>`Pay the ten coins` (needs 10 coins) → `bribe` · coins -10; trust -8; flag `bribed`, `birana_done`; say `bribe`<br>`Report him to the qadi` → `report` · trust +5; flag `reported_wahb`, `permit_waiting`; say `reported` |
| `wait` | End: Back; mission done |
| `bribe` | End: Back; mission done |
| `report` | End: Back; mission done |

What people say lines (`say`): `bribe` (bad, the farmers waiting for permits); `reported` (good, the farmers waiting for permits) - shown in What Birana says.

## Mission `permit_ready` - Your permit (main story)

Button `button`, shown when: town `birana` hub; 08:00-15:00; after `permit_waiting`; 5 days after `permit_waiting`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take it` → `b` · flag `birana_done` |
| `b` | End: Back; mission done |

## Mission `patience_home` - Patience kept (main story)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; after `safira_done`, `wadira_done`, `birana_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask about the road south` → `b` · flag `chapter2_done` |
| `b` | End: Back; mission done |

## Masters

- `bi01_birana__town.png`
- `bi02_birana__people.png`
- `bi03_birana__thabit_trust_10.png`
- `bi04_birana__thabit_trust_50.png`
- `bi05_birana__thabit_trust_80.png`
- `bi06_birana__safiyya_trust_10.png`
- `bi07_birana__safiyya_trust_50.png`
- `bi08_birana__safiyya_trust_80.png`
- `bi09_birana__wahb_trust_10.png`
- `bi10_birana__wahb_trust_50.png`
- `bi11_birana__wahb_trust_80.png`
- `bi12_birana__what_people_say_empty.png`
- `bi13_birana__masjid_prayer.png`
- `bi14_birana__masjid_first_prayer.png`
- `bi15_dry_well__a.png`
- `bi16_dry_well__b.png`
- `bi17_dry_well__water.png`
- `bi18_dry_well__gave.png`
- `bi19_dry_well__pay.png`
- `bi20_dry_well__leave.png`
- `bi21_long_wait__a.png`
- `bi22_long_wait__wait.png`
- `bi23_long_wait__bribe.png`
- `bi24_long_wait__report.png`
- `bi25_permit_ready__a.png`
- `bi26_permit_ready__b.png`
- `bi27_patience_home__a.png`
- `bi28_patience_home__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `birana_data_V1.json` (copied byte for byte to `SOURCE/data/birana.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 42 under the Founder's blanket LOCK (9 Nov) |
