---
id: DOC-TFG-0151
type: SPEC
status: CURRENT
feature: NAJMARA
purpose: LOCK 47 - Najmara, the star hill (chapter 4): town, masjid, people; missions The new masjid's qibla and The student who can't pay
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0152]
owner: THE FOUR GATES chat
---

# NAJMARA SPEC — CURRENT VERSION V1 (LOCK 47)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `najmara_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads and earlier chapter LOCKs. Queue line 54 comes after line 53 |
| Masters | `../MASTERS/nj01`-`nj21` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 2:144; Muslim 2699 (a path to knowledge) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: how far a qibla may be off before a wall is rebuilt |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `najmara` | Najmara | knowledge | 10 | 2 | `Polish the brass instruments · 4 coins` 10:00-15:00, 60 min, +4 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `najmara` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `hilal` | Hilal | the astronomer | 10:00-23:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `qibla_fixed` |
| `kamil` | Kamil | a student | 08:00-21:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `student_helped` |
| `saad` | Sa'd | the builder | 06:00-17:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | - |

## Mission `qibla` - The new masjid's qibla (main story)

Button `button`, shown when: town `najmara` hub; 10:00-22:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Help Hilal take the star sightings tonight` → `stars` · trust +8; flag `qibla_fixed`, `qibla_done`; say `fixed`; stars +1; clock +240 min<br>`Tell them to build on` → `build` · flag `qibla_done` |
| `stars` | End: Back; mission done |
| `build` | End: Back; mission done |

What people say lines (`say`): `fixed` (good, Sa'd the builder) - shown in What Najmara says.

## Mission `student` - The student who can't pay (main story)

Button `button`, shown when: town `najmara` hub; 08:00-21:00; after `qibla_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Pay his term · 10 coins` (needs 10 coins) → `pay` · coins -10; trust +6; flag `student_helped`, `najmara_done`; say `paid`<br>`Sit and study with him for an evening` → `study` · trust +4; flag `najmara_done`; clock +180 min<br>`Tell him to work and save` → `none` · flag `najmara_done` |
| `pay` | End: Back; mission done |
| `study` | End: Back; mission done |
| `none` | End: Back; mission done |

What people say lines (`say`): `paid` (good, the observatory) - shown in What Najmara says.

## Masters

- `nj01_najmara__town.png`
- `nj02_najmara__people.png`
- `nj03_najmara__hilal_trust_10.png`
- `nj04_najmara__hilal_trust_50.png`
- `nj05_najmara__hilal_trust_80.png`
- `nj06_najmara__kamil_trust_10.png`
- `nj07_najmara__kamil_trust_50.png`
- `nj08_najmara__kamil_trust_80.png`
- `nj09_najmara__saad_trust_10.png`
- `nj10_najmara__saad_trust_50.png`
- `nj11_najmara__saad_trust_80.png`
- `nj12_najmara__what_people_say_empty.png`
- `nj13_najmara__masjid_prayer.png`
- `nj14_najmara__masjid_first_prayer.png`
- `nj15_qibla__a.png`
- `nj16_qibla__stars.png`
- `nj17_qibla__build.png`
- `nj18_student__a.png`
- `nj19_student__pay.png`
- `nj20_student__study.png`
- `nj21_student__none.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above; walking around inside towns.

## Build rules

Words and numbers only from `najmara_data_V1.json` (copied byte for byte to `SOURCE/data/najmara.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 47 under the Founder's blanket LOCK (9 Nov) |
