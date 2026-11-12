---
id: DOC-TFG-0289
type: SPEC
status: CURRENT
feature: MARRIAGE
purpose: LOCK 93 - marriage
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0290]
owner: THE FOUR GATES chat
---

# MARRIAGE SPEC — CURRENT VERSION V1 (LOCK 93)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `marriage_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 100 comes after line 99 |
| Masters | `../MASTERS/of01`-`of08` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 5090, 5167 - checked on sunnah.com; Quran 4:4 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: the whole marriage scene (wali, mahr, witnesses), for both the young man and the young woman |

## 2. The young woman's version

Scenes `man` and `woman` are chosen by the boy/girl choice (flag `girl`). For a young woman the proposal comes through her uncle, and she receives the mahr (+30) instead of paying it. Everything else is the same.

## Mission `marriage` - Marriage (scene)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; trust ≥ 80; after `chapter2_done`, `own_house`; not after `married`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask whom he has in mind` → `man` · -<br>`Ask whom he has in mind` → `woman` · -<br>`Not yet` → `later` · - |
| `man` | `Ask him to speak to Layla` → `meet` · -<br>`Not yet` → `later` · - |
| `woman` | `Agree to meet him with your uncle` → `meet` · -<br>`Not yet` → `later` · - |
| `meet` | `Say yes` → `mahr` · -<br>`Ask for more time` → `later` · - |
| `mahr` | `The nikah · 30 coins` (needs 30 coins) → `nikah` · coins -30<br>`The nikah` → `nikah` · coins +30 |
| `nikah` | `A wedding feast for the market · 20 coins` (needs 20 coins) → `walima` · coins -20; flag `married`; say `walima`; meals +50<br>`A small feast for the family · 5 coins` (needs 5 coins) → `walima` · coins -5; flag `married`; meals +10 |
| `walima` | End: Back; mission done |
| `later` | Back |

What people say lines (`say`): `walima` (good, River Market) - shown in River Market What people say.

## Masters

- `of01_marriage__a.png`
- `of02_marriage__man.png`
- `of03_marriage__woman.png`
- `of04_marriage__meet.png`
- `of05_marriage__mahr.png`
- `of06_marriage__nikah.png`
- `of07_marriage__walima.png`
- `of08_marriage__later.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `marriage_data_V1.json` (copied byte for byte to `SOURCE/data/marriage.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 93 under the Founder's blanket LOCK (9 Nov) |
