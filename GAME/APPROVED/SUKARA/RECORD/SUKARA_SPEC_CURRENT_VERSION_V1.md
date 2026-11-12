---
id: DOC-TFG-0123
type: SPEC
status: CURRENT
feature: SUKARA
purpose: LOCK 38 - Sukara, the sugar presses (town, masjid, people) and chapter 1 mission Sukara's two offers - partnership or interest
links: [AD-AIOS-115, DOC-TFG-0102, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0124]
owner: THE FOUR GATES chat
---

# SUKARA SPEC — CURRENT VERSION V1 (LOCK 38)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `sukara_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 16 riba refused, LOCK 31 partnership, LOCK 34 runner, LOCK 36 roads. Queue line 45 comes after line 44 |
| Masters | `../MASTERS/su01`-`su23` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 2:275-279 (riba forbidden; you may have your principal) |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: the partnership terms and returning the principal only |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `sukara` | Sukara | trust | 10 | 3 | `Feed cane into the press · 5 coins` 06:00-17:00, 90 min, +5 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `sukara` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `murad` | Murad | the press owner | 06:00-18:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `sukara_partner`, `sukara_riba` |
| `sakhr` | Sakhr | the money lender | 08:00-19:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `sukara_refused` |
| `nuha` | Nuha | the sweet seller | 09:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | - |

## Mission `sukara_offers` - Sukara's two offers (main story)

Button `button`, shown when: town `sukara` hub; 07:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Partner with Murad · 60 coins` (needs 60 coins) → `partner` · coins -60; trust +5; flag `sukara_partner`, `sukara_chosen`; say `partner`<br>`Lend through Sakhr · 60 coins` (needs 60 coins) → `riba` · coins -60; flag `sukara_riba`, `sukara_chosen`<br>`Keep your coins` → `none` · flag `sukara_chosen` |
| `partner` | End: Back; mission done |
| `riba` | End: Back; mission done |
| `none` | End: Back; mission done |

What people say lines (`say`): `partner` (good, the press-men) - shown in What Sukara says.

## Mission `sukara_share` - Harvest share (main story)

Button `button`, shown when: town `sukara` hub; after `sukara_partner`; 14 days after `sukara_partner`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take 90 coins` → `b` · coins +90 |
| `b` | End: Back; mission done |

## Mission `sukara_due` - Sakhr pays (main story)

Button `button`, shown when: town `sukara` hub; after `sukara_riba`; 30 days after `sukara_riba`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Take all 72` → `took` · coins +72; trust -10; say `took`<br>`Take only your 60; give Murad the rest` → `refused` · coins +60; trust +5; flag `sukara_refused`; say `refused` |
| `took` | End: Back; mission done |
| `refused` | End: Back; mission done |

What people say lines (`say`): `took` (bad, the press-men); `refused` (good, Murad the press owner) - shown in What Sukara says.

## Masters

- `su01_sukara__town.png`
- `su02_sukara__people.png`
- `su03_sukara__murad_trust_10.png`
- `su04_sukara__murad_trust_50.png`
- `su05_sukara__murad_trust_80.png`
- `su06_sukara__sakhr_trust_10.png`
- `su07_sukara__sakhr_trust_50.png`
- `su08_sukara__sakhr_trust_80.png`
- `su09_sukara__nuha_trust_10.png`
- `su10_sukara__nuha_trust_50.png`
- `su11_sukara__nuha_trust_80.png`
- `su12_sukara__what_people_say_empty.png`
- `su13_sukara__masjid_prayer.png`
- `su14_sukara__masjid_first_prayer.png`
- `su15_sukara_offers__a.png`
- `su16_sukara_offers__partner.png`
- `su17_sukara_offers__riba.png`
- `su18_sukara_offers__none.png`
- `su19_sukara_share__a.png`
- `su20_sukara_share__b.png`
- `su21_sukara_due__a.png`
- `su22_sukara_due__took.png`
- `su23_sukara_due__refused.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

A harvest that fails (the first harvest is good); further loans from Sakhr.

## Build rules

Words and numbers only from `sukara_data_V1.json` (copied byte for byte to `SOURCE/data/sukara.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 38 under the Founder's blanket LOCK (9 Nov) |
