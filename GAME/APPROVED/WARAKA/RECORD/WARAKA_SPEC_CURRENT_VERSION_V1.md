---
id: DOC-TFG-0148
type: SPEC
status: CURRENT
feature: WARAKA
purpose: LOCK 46 - Waraka, the paper mills (chapter 4): town, masjid, people; missions The copyist and The fake hadith seller
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0149]
owner: THE FOUR GATES chat
---

# WARAKA SPEC — CURRENT VERSION V1 (LOCK 46)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `waraka_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 53 comes after line 52 |
| Masters | `../MASTERS/wk01`-`wk21` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 2:282; Bukhari 110 (whoever lies about the Prophet deliberately) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `waraka` | Waraka | knowledge | 10 | 2 | `Turn the pulp vats · 4 coins` 06:00-17:00, 60 min, +4 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `waraka` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `yaqub` | Yaqub | the copyist | 07:00-18:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `copy_fixed` |
| `fuad` | Fuad | a seller of charms | 08:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `fake_exposed` |
| `zaynab` | Zaynab | the paper maker | 06:00-17:00 | `lines` by town trust: wary < 30, friendly < 70, warm | - |

## Mission `copyist` - The copyist (main story)

Button `button`, shown when: town `waraka` hub; 07:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Insist he copies the page again` → `fix` · trust +8; flag `copy_fixed`, `copyist_done`; say `fixed`; clock +120 min<br>`Let it go` → `let` · flag `copyist_done` |
| `fix` | End: Back; mission done |
| `let` | End: Back; mission done |

What people say lines (`say`): `fixed` (good, the copyists) - shown in What Waraka says.

## Mission `fake_hadith` - The fake hadith seller (main story)

Button `button`, shown when: town `waraka` hub; 08:00-18:00; after `copyist_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take Fuad to the scholars of the paper market` → `scholars` · trust +10; flag `fake_exposed`, `waraka_done`; say `exposed`<br>`Quietly warn the buyers` → `warn` · trust +6; flag `waraka_done`; say `warned`<br>`Not your business` → `leave` · flag `waraka_done` |
| `scholars` | End: Back; mission done |
| `warn` | End: Back; mission done |
| `leave` | End: Back; mission done |

What people say lines (`say`): `exposed` (good, the scholars of Waraka); `warned` (good, the paper market) - shown in What Waraka says.

## Masters

- `wk01_waraka__town.png`
- `wk02_waraka__people.png`
- `wk03_waraka__yaqub_trust_10.png`
- `wk04_waraka__yaqub_trust_50.png`
- `wk05_waraka__yaqub_trust_80.png`
- `wk06_waraka__fuad_trust_10.png`
- `wk07_waraka__fuad_trust_50.png`
- `wk08_waraka__fuad_trust_80.png`
- `wk09_waraka__zaynab_trust_10.png`
- `wk10_waraka__zaynab_trust_50.png`
- `wk11_waraka__zaynab_trust_80.png`
- `wk12_waraka__what_people_say_empty.png`
- `wk13_waraka__masjid_prayer.png`
- `wk14_waraka__masjid_first_prayer.png`
- `wk15_copyist__a.png`
- `wk16_copyist__fix.png`
- `wk17_copyist__let.png`
- `wk18_fake_hadith__a.png`
- `wk19_fake_hadith__scholars.png`
- `wk20_fake_hadith__warn.png`
- `wk21_fake_hadith__leave.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `waraka_data_V1.json` (copied byte for byte to `SOURCE/data/waraka.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 46 under the Founder's blanket LOCK (9 Nov) |
