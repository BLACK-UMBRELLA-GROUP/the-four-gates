---
id: DOC-TFG-0126
type: SPEC
status: CURRENT
feature: CHAPTER_1_END
purpose: LOCK 39 - the end of chapter 1 with Idris, and the Gate of Patience opening
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0127]
owner: THE FOUR GATES chat
---

# CHAPTER 1 END SPEC — CURRENT VERSION V1 (LOCK 39)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `chapter1_end_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 Idris, LOCKs 32-38. Queue line 46 comes after line 45 |
| Masters | `../MASTERS/ce01`-`ce02` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 4:58 (render trusts to whom they are due) |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `trust_home` - Trust kept (main story)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; after `sahila_boat_done`, `sukara_chosen`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask about the road north` → `b` · flag `chapter1_done` |
| `b` | End: Back; mission done |

## Masters

- `ce01_trust_home__a.png`
- `ce02_trust_home__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Idris judging your choices (he listens; the game never plays God).

## Build rules

Words and numbers only from `chapter1_end_data_V1.json` (copied byte for byte to `SOURCE/data/chapter1_end.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 39 under the Founder's blanket LOCK (9 Nov) |
