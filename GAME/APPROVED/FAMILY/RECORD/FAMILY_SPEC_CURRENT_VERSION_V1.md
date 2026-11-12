---
id: DOC-TFG-0292
type: SPEC
status: CURRENT
feature: FAMILY
purpose: LOCK 94 - a daughter and the aqiqah
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0293]
owner: THE FOUR GATES chat
---

# FAMILY SPEC — CURRENT VERSION V1 (LOCK 94)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `family_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 101 comes after line 100 |
| Masters | `../MASTERS/og01`-`og05` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 5472 - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: the aqiqah for a girl |



## Mission `expecting` - Expecting (scene)

Button `button`, shown when: River Market place `quay`; 08:00-19:00; after `married`; 300 days after `married`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Tell Idris` → `leave` · flag `expecting` |

## Mission `baby_born` - A daughter (scene)

Button `button`, shown when: River Market place `quay`; 05:00-21:00; after `expecting`; 270 days after `expecting`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Name her Khadija` → `b` · flag `baby_born`, `baby_khadija`<br>`Name her Ruqayya` → `b` · flag `baby_born`, `baby_ruqayya`<br>`Name her Asma` → `b` · flag `baby_born`, `baby_asma` |
| `b` | End: Back; mission done |

## Mission `aqiqah` - The aqiqah (scene)

Button `button`, shown when: River Market place `gate`; 07:00-18:00; after `baby_born`; 7 days after `baby_born`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `The aqiqah · 15 coins` (needs 15 coins) → `b` · coins -15; say `aqiqah`; meals +30<br>`A smaller aqiqah · 8 coins` (needs 8 coins) → `b` · coins -8; meals +15 |
| `b` | End: Back; mission done |

What people say lines (`say`): `aqiqah` (good, the quay) - shown in River Market What people say.

## Masters

- `og01_expecting__a.png`
- `og02_baby_born__a.png`
- `og03_baby_born__b.png`
- `og04_aqiqah__a.png`
- `og05_aqiqah__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `family_data_V1.json` (copied byte for byte to `SOURCE/data/family.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 94 under the Founder's blanket LOCK (9 Nov) |
