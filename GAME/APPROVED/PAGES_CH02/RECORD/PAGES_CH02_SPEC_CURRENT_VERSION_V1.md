---
id: DOC-TFG-0205
type: SPEC
status: CURRENT
feature: PAGES_CH02
purpose: LOCK 65 - pages 11-20 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0206]
owner: THE FOUR GATES chat
---

# PAGES CH02 SPEC — CURRENT VERSION V1 (LOCK 65)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch02_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 72 comes after line 71 |
| Masters | `../MASTERS/pb01`-`pb20` at 1920 × 1080 |
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
| 11 | town `jisra` | Umm Hani | `gate_opened` | Nawawi 40, no. 12 |
| 12 | town `sahila` | Mukhtar | `gate_opened`, `page_11_found` | Nawawi 40, no. 13 |
| 13 | town `sukara` | Sakhr | `gate_opened`, `page_12_found` | Tirmidhi 1956 |
| 14 | town `jisra` | Umm Hani | `gate_opened`, `page_13_found` | Nawawi 40, no. 15 |
| 15 | town `sahila` | Mukhtar | `gate_opened`, `page_14_found` | Nawawi 40, no. 16 |
| 16 | town `sukara` | Sakhr | `gate_opened`, `page_15_found` | Nawawi 40, no. 17 |
| 17 | town `jisra` | Umm Hani | `gate_opened`, `page_16_found` | Nawawi 40, no. 18 |
| 18 | town `sahila` | Mukhtar | `gate_opened`, `page_17_found` | Muslim 102 |
| 19 | town `sukara` | Sakhr | `gate_opened`, `page_18_found` | Bukhari 2079 |
| 20 | town `jisra` | Umm Hani | `gate_opened`, `page_19_found` | Bukhari 2072 |

## Masters

- `pb01_page_11__a.png`
- `pb02_read_11__a.png`
- `pb03_page_12__a.png`
- `pb04_read_12__a.png`
- `pb05_page_13__a.png`
- `pb06_read_13__a.png`
- `pb07_page_14__a.png`
- `pb08_read_14__a.png`
- `pb09_page_15__a.png`
- `pb10_read_15__a.png`
- `pb11_page_16__a.png`
- `pb12_read_16__a.png`
- `pb13_page_17__a.png`
- `pb14_read_17__a.png`
- `pb15_page_18__a.png`
- `pb16_read_18__a.png`
- `pb17_page_19__a.png`
- `pb18_read_19__a.png`
- `pb19_page_20__a.png`
- `pb20_read_20__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch02_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch02.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 65 under the Founder's blanket LOCK (9 Nov) |
