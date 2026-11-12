---
id: DOC-TFG-0114
type: SPEC
status: CURRENT
feature: JISRA_PEOPLE
purpose: LOCK 35 - Jisra's four people, carrying fish for Umm Hani, side mission The weak rope, and What Jisra says
links: [AD-AIOS-115, DOC-TFG-0105, DOC-TFG-0111, DOC-TFG-0115]
owner: THE FOUR GATES chat
---

# JISRA PEOPLE SPEC — CURRENT VERSION V1 (LOCK 35)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `jisra_people_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 32 Jisra and the toll, LOCK 33 Jisra's masjid, LOCK 34 runner. Queue line 42 comes after line 41 |
| Masters | `../MASTERS/jp01`-`jp18` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Muslim 102 (whoever cheats is not of us) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none beyond the reference |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `jisra` | Jisra | trust | 10 | 2 | `Carry fish baskets for Umm Hani · 4 coins` 06:00-12:00, 60 min, +4 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `hamid` | Hamid | the toll keeper | 06:00-19:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `toll:speak`, `toll:pay` |
| `rafiq` | Rafiq | the bridge master | 05:00-20:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `rope_told`, `rope_hid` |
| `umm_hani` | Umm Hani | the fish seller | 06:00-13:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `toll:quiet` |
| `bashir` | Bashir | the rope maker | 07:00-18:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `rope_told`, `rope_hid` |

## Mission `weak_rope` - The weak rope (side mission)

Button `button`, shown when: town `jisra` hub; 10:00-16:00; trust ≥ 15; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Tell him it frays` → `told` · trust +5; flag `rope_told`; say `told`<br>`Sell it to him` → `sold` · coins +3; flag `rope_hid`; say `hid` |
| `told` | End: Back; mission done |
| `sold` | End: Back; mission done |

What people say lines (`say`): `told` (good, the boatmen); `hid` (bad, Rafiq the bridge master) - shown in What Jisra says.

## Lines from earlier LOCKs

- `toll:speak` → Spoke up to Hamid at the toll (the boatmen)
- `toll:pay` → Paid a poor family's toll (the family with the donkey)

## Masters

- `jp01_jisra__town.png`
- `jp02_jisra__people.png`
- `jp03_jisra__hamid_trust_10.png`
- `jp04_jisra__hamid_trust_50.png`
- `jp05_jisra__hamid_trust_80.png`
- `jp06_jisra__rafiq_trust_10.png`
- `jp07_jisra__rafiq_trust_50.png`
- `jp08_jisra__rafiq_trust_80.png`
- `jp09_jisra__umm_hani_trust_10.png`
- `jp10_jisra__umm_hani_trust_50.png`
- `jp11_jisra__umm_hani_trust_80.png`
- `jp12_jisra__bashir_trust_10.png`
- `jp13_jisra__bashir_trust_50.png`
- `jp14_jisra__bashir_trust_80.png`
- `jp15_jisra__what_people_say_empty.png`
- `jp16_weak_rope__a.png`
- `jp17_weak_rope__told.png`
- `jp18_weak_rope__sold.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Hamid changing his toll for good; floods; more Jisra missions.

## Build rules

Words and numbers only from `jisra_people_data_V1.json` (copied byte for byte to `SOURCE/data/jisra_people.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 35 under the Founder's blanket LOCK (9 Nov) |
