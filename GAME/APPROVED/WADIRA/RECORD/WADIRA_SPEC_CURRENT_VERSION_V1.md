---
id: DOC-TFG-0133
type: SPEC
status: CURRENT
feature: WADIRA
purpose: LOCK 41 - Wadira, the sandstorm valley (chapter 2): town, masjid, people; missions The sandstorm (tayammum) and Cheated in public
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0134]
owner: THE FOUR GATES chat
---

# WADIRA SPEC — CURRENT VERSION V1 (LOCK 41)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `wadira_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 48 comes after line 47 |
| Masters | `../MASTERS/wd01`-`wd21` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 5:6 and Bukhari 334 (tayammum) - checked on sunnah.com; Quran 41:34 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: tayammum when the little water left is needed for drinking |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `wadira` | Wadira | patience | 10 | 2 | `Sweep sand from the masjid yard · 3 coins` 06:00-15:00, 60 min, +3 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `wadira` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `ghazi` | Ghazi | the valley guide | 05:00-19:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `tayammum_learned` |
| `lina` | Lina | the dyer | 07:00-17:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `cheated_calm` |
| `khattab` | Khattab | the salt merchant | 08:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `enemy_helped`, `cheated_shout` |

## Mission `sandstorm` - The sandstorm (main story)

Button `button`, shown when: town `wadira` hub; 05:00-14:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Pray with tayammum, as Ghazi shows you` → `tay` · trust +5; flag `tayammum_learned`, `sandstorm_done`; say `tay`; clock +180 min<br>`Use the last water for wudu` → `water` · flag `sandstorm_done`; clock +180 min |
| `tay` | End: Back; mission done |
| `water` | End: Back; mission done |

What people say lines (`say`): `tay` (good, Ghazi the guide) - shown in What Wadira says.

## Mission `cheated_public` - Cheated in public (main story)

Button `button`, shown when: town `wadira` hub; 08:00-18:00; after `sandstorm_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Answer calmly and ask him to weigh them` → `calm` · trust +8; flag `cheated_calm`, `wadira_done`; say `calm`<br>`Shout back and call him a liar` → `shout` · trust -3; flag `cheated_shout`, `wadira_done`; say `shout`<br>`Pay him again to end it · 10 coins` (needs 10 coins) → `paid` · coins -10; trust +2; flag `wadira_done` |
| `calm` | End: Back; mission done |
| `shout` | End: Back; mission done |
| `paid` | End: Back; mission done |

What people say lines (`say`): `calm` (good, the valley market); `shout` (bad, the valley market) - shown in What Wadira says.

## Masters

- `wd01_wadira__town.png`
- `wd02_wadira__people.png`
- `wd03_wadira__ghazi_trust_10.png`
- `wd04_wadira__ghazi_trust_50.png`
- `wd05_wadira__ghazi_trust_80.png`
- `wd06_wadira__lina_trust_10.png`
- `wd07_wadira__lina_trust_50.png`
- `wd08_wadira__lina_trust_80.png`
- `wd09_wadira__khattab_trust_10.png`
- `wd10_wadira__khattab_trust_50.png`
- `wd11_wadira__khattab_trust_80.png`
- `wd12_wadira__what_people_say_empty.png`
- `wd13_wadira__masjid_prayer.png`
- `wd14_wadira__masjid_first_prayer.png`
- `wd15_sandstorm__a.png`
- `wd16_sandstorm__tay.png`
- `wd17_sandstorm__water.png`
- `wd18_cheated_public__a.png`
- `wd19_cheated_public__calm.png`
- `wd20_cheated_public__shout.png`
- `wd21_cheated_public__paid.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `wadira_data_V1.json` (copied byte for byte to `SOURCE/data/wadira.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 41 under the Founder's blanket LOCK (9 Nov) |
