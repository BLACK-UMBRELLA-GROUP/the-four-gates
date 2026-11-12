---
id: DOC-TFG-0214
type: SPEC
status: CURRENT
feature: PAGES_CH05
purpose: LOCK 68 - pages 41-50 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0215]
owner: THE FOUR GATES chat
---

# PAGES CH05 SPEC — CURRENT VERSION V1 (LOCK 68)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch05_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 75 comes after line 74 |
| Masters | `../MASTERS/pe01`-`pe20` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | each page's hadith, listed in the Pages table - all checked on sunnah.com on 9 Nov 2026 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: every page's wording against the full hadith (the game shows a plain-words version) |



## Pages

Each page is two runner missions (LOCK 34): **find** - at the place or town hub below, button `words.find_button` with the person, scene `find_title` + the `found` text, choice `take` (flag `page_n_found`); **read** - at the River Market masjid, button `read_button`, kicker `read_kicker`, the saying in quotes, `idris` with Idris's words, and on the last page of the chapter `story` with the chapter story; choice `read_turn` (flag `page_n_read`, pages +1). Only the lowest unread found page is offered at a time. Hours `words.hours`. Each page needs the chapter flag and the page before it found (the first page of a chapter needs only the chapter flag).

| Page | Where | Person | Needs | Reference (not shown) |
|---|---|---|---|---|
| 41 | town `waraka` | Zaynab | `chapter3_done` | Nawawi 40, no. 27 |
| 42 | town `najmara` | Kamil | `chapter3_done`, `page_41_found` | Nawawi 40, no. 28 |
| 43 | town `shifara` | Shakir | `chapter3_done`, `page_42_found` | Nawawi 40, no. 29 |
| 44 | town `waraka` | Zaynab | `chapter3_done`, `page_43_found` | Nawawi 40, no. 30 |
| 45 | town `najmara` | Kamil | `chapter3_done`, `page_44_found` | Nawawi 40, no. 31 |
| 46 | town `shifara` | Shakir | `chapter3_done`, `page_45_found` | Nawawi 40, no. 32 |
| 47 | town `waraka` | Zaynab | `chapter3_done`, `page_46_found` | Nawawi 40, no. 33 |
| 48 | town `najmara` | Kamil | `chapter3_done`, `page_47_found` | Nawawi 40, no. 34 |
| 49 | town `shifara` | Shakir | `chapter3_done`, `page_48_found` | Nawawi 40, no. 35 |
| 50 | town `waraka` | Zaynab | `chapter3_done`, `page_49_found` | Nawawi 40, no. 36 |

## Masters

- `pe01_page_41__a.png`
- `pe02_read_41__a.png`
- `pe03_page_42__a.png`
- `pe04_read_42__a.png`
- `pe05_page_43__a.png`
- `pe06_read_43__a.png`
- `pe07_page_44__a.png`
- `pe08_read_44__a.png`
- `pe09_page_45__a.png`
- `pe10_read_45__a.png`
- `pe11_page_46__a.png`
- `pe12_read_46__a.png`
- `pe13_page_47__a.png`
- `pe14_read_47__a.png`
- `pe15_page_48__a.png`
- `pe16_read_48__a.png`
- `pe17_page_49__a.png`
- `pe18_read_49__a.png`
- `pe19_page_50__a.png`
- `pe20_read_50__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch05_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch05.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 68 under the Founder's blanket LOCK (9 Nov) |
