---
id: DOC-TFG-0142
type: SPEC
status: CURRENT
feature: TINARA
purpose: LOCK 44 - Tinara, the orchards (chapter 3): town, masjid, people; missions The widow's harvest (with repayment) and The orphan's share
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0143]
owner: THE FOUR GATES chat
---

# TINARA SPEC — CURRENT VERSION V1 (LOCK 44)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `tinara_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 51 comes after line 50 |
| Masters | `../MASTERS/ti01`-`ti24` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Ibn Majah 2443 (pay the worker before his sweat dries) - checked on sunnah.com; Quran 4:10 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `tinara` | Tinara | mercy | 10 | 2 | `Pick apricots · 5 coins` 06:00-17:00, 90 min, +5 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `tinara` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `sumayya` | Sumayya | a widow with an orchard | 06:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `widow_lent` |
| `hakam` | Hakam | a landowner | 07:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `orphan_helped` |
| `usama` | Usama | a boy selling pomegranates | 07:00-17:00 | `lines` by town trust: wary < 30, friendly < 70, warm | - |

## Mission `widow_harvest` - The widow's harvest (main story)

Button `button`, shown when: town `tinara` hub; 06:00-17:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Lend her the wages · 18 coins` (needs 18 coins) → `lend` · coins -18; trust +8; flag `widow_lent`, `widow_done`; say `lent`<br>`Pick with them so she needs fewer` → `pick` · trust +5; flag `widow_done`; say `picked`; clock +240 min<br>`Tell the pickers to wait a month` → `wait` · trust -4; flag `widow_done`; say `waited` |
| `lend` | End: Back; mission done |
| `pick` | End: Back; mission done |
| `wait` | End: Back; mission done |

What people say lines (`say`): `lent` (good, the pickers); `picked` (good, the pickers); `waited` (bad, the pickers) - shown in What Tinara says.

## Mission `widow_repay` - Sumayya repays (main story)

Button `button`, shown when: town `tinara` hub; after `widow_lent`; 30 days after `widow_lent`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take them` → `b` · coins +18 |
| `b` | End: Back; mission done |

## Mission `orphan_share` - The orphan's share (main story)

Button `button`, shown when: town `tinara` hub; 07:00-17:00; after `widow_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask Hakam to show the accounts to the qadi` → `qadi` · trust +10; flag `orphan_helped`, `tinara_done`; say `qadi`<br>`Buy all of Usama's fruit · 8 coins` (needs 8 coins) → `buy` · coins -8; trust +3; flag `tinara_done`<br>`It's a family matter` → `leave` · flag `tinara_done` |
| `qadi` | End: Back; mission done |
| `buy` | End: Back; mission done |
| `leave` | End: Back; mission done |

What people say lines (`say`): `qadi` (good, the orchard families) - shown in What Tinara says.

## Masters

- `ti01_tinara__town.png`
- `ti02_tinara__people.png`
- `ti03_tinara__sumayya_trust_10.png`
- `ti04_tinara__sumayya_trust_50.png`
- `ti05_tinara__sumayya_trust_80.png`
- `ti06_tinara__hakam_trust_10.png`
- `ti07_tinara__hakam_trust_50.png`
- `ti08_tinara__hakam_trust_80.png`
- `ti09_tinara__usama_trust_10.png`
- `ti10_tinara__usama_trust_50.png`
- `ti11_tinara__usama_trust_80.png`
- `ti12_tinara__what_people_say_empty.png`
- `ti13_tinara__masjid_prayer.png`
- `ti14_tinara__masjid_first_prayer.png`
- `ti15_widow_harvest__a.png`
- `ti16_widow_harvest__lend.png`
- `ti17_widow_harvest__pick.png`
- `ti18_widow_harvest__wait.png`
- `ti19_widow_repay__a.png`
- `ti20_widow_repay__b.png`
- `ti21_orphan_share__a.png`
- `ti22_orphan_share__qadi.png`
- `ti23_orphan_share__buy.png`
- `ti24_orphan_share__leave.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `tinara_data_V1.json` (copied byte for byte to `SOURCE/data/tinara.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 44 under the Founder's blanket LOCK (9 Nov) |
