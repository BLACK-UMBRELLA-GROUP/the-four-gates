---
id: DOC-TFG-0208
type: SPEC
status: CURRENT
feature: PAGES_CH03
purpose: LOCK 66 - pages 21-30 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0209]
owner: THE FOUR GATES chat
---

# PAGES CH03 SPEC — CURRENT VERSION V1 (LOCK 66)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch03_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 73 comes after line 72 |
| Masters | `../MASTERS/pc01`-`pc20` at 1920 × 1080 |
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
| 21 | town `wadira` | Ghazi | `chapter1_done` | Bukhari 1471 |
| 22 | town `birana` | Wahb | `chapter1_done`, `page_21_found` | Nawawi 40, no. 19 |
| 23 | town `safira` | Amina | `chapter1_done`, `page_22_found` | Nawawi 40, no. 20 |
| 24 | town `wadira` | Ghazi | `chapter1_done`, `page_23_found` | Nawawi 40, no. 21 |
| 25 | town `birana` | Wahb | `chapter1_done`, `page_24_found` | Nawawi 40, no. 22 |
| 26 | town `safira` | Amina | `chapter1_done`, `page_25_found` | Nawawi 40, no. 23 |
| 27 | town `wadira` | Ghazi | `chapter1_done`, `page_26_found` | Nawawi 40, no. 24 |
| 28 | town `birana` | Wahb | `chapter1_done`, `page_27_found` | Nawawi 40, no. 25 |
| 29 | town `safira` | Amina | `chapter1_done`, `page_28_found` | Nawawi 40, no. 26 |
| 30 | town `wadira` | Ghazi | `chapter1_done`, `page_29_found` | Muslim 2588 |

## Masters

- `pc01_page_21__a.png`
- `pc02_read_21__a.png`
- `pc03_page_22__a.png`
- `pc04_read_22__a.png`
- `pc05_page_23__a.png`
- `pc06_read_23__a.png`
- `pc07_page_24__a.png`
- `pc08_read_24__a.png`
- `pc09_page_25__a.png`
- `pc10_read_25__a.png`
- `pc11_page_26__a.png`
- `pc12_read_26__a.png`
- `pc13_page_27__a.png`
- `pc14_read_27__a.png`
- `pc15_page_28__a.png`
- `pc16_read_28__a.png`
- `pc17_page_29__a.png`
- `pc18_read_29__a.png`
- `pc19_page_30__a.png`
- `pc20_read_30__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch03_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch03.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 66 under the Founder's blanket LOCK (9 Nov) |
