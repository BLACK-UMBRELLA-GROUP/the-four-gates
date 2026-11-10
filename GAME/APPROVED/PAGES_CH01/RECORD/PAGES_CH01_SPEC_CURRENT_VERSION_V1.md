---
id: DOC-TFG-0202
type: SPEC
status: CURRENT
feature: PAGES_CH01
purpose: LOCK 64 - pages 2-10 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0203]
owner: THE FOUR GATES chat
---

# PAGES CH01 SPEC — CURRENT VERSION V1 (LOCK 64)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch01_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner. Queue line 71 comes after line 70 |
| Masters | `../MASTERS/pa01`-`pa18` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | each page's hadith, listed in the Pages table - all checked on sunnah.com on 9 Nov 2026 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: every page's wording against the full hadith (the game shows a plain-words version) |

## 2. How pages work

The notebook has 100 pages: page 1 is LOCK 3, page 100 is the last page in the finale (LOCK 51), and pages 2-99 are in LOCKs 64-73, ten chapters. Pages are always found through a person, never lying on the ground. Reading happens with Idris at the masjid. The Journal goal “The scholar's pages” counts page 1 (when read) plus every page read. The game shows the saying in plain words and never the reference.

## Pages

Each page is two runner missions (LOCK 34): **find** - at the place or town hub below, button `words.find_button` with the person, scene `find_title` + the `found` text, choice `take` (flag `page_n_found`); **read** - at the River Market masjid, button `read_button`, kicker `read_kicker`, the saying in quotes, `idris` with Idris's words, and on the last page of the chapter `story` with the chapter story; choice `read_turn` (flag `page_n_read`, pages +1). Only the lowest unread found page is offered at a time. Hours `words.hours`. Each page needs the chapter flag and the page before it found (the first page of a chapter needs only the chapter flag).

| Page | Where | Person | Needs | Reference (not shown) |
|---|---|---|---|---|
| 2 | River Market `board` | Salma | `sirr` | Nawawi 40, no. 1 |
| 3 | River Market `spice` | Rashid | `sirr`, `page_2_found` | Nawawi 40, no. 2 |
| 4 | River Market `weaver` | Layla | `sirr`, `page_3_found` | Nawawi 40, no. 3 |
| 5 | River Market `quay` | Jamal | `sirr`, `page_4_found` | Nawawi 40, no. 5 |
| 6 | River Market `gate` | Abbas | `sirr`, `page_5_found` | Nawawi 40, no. 6 |
| 7 | River Market `scales` | Karim | `sirr`, `page_6_found` | Nawawi 40, no. 7 |
| 8 | River Market `inn` | The innkeeper | `sirr`, `page_7_found` | Nawawi 40, no. 9 |
| 9 | River Market `masjid` | Yunus the muezzin | `sirr`, `page_8_found` | Nawawi 40, no. 10 |
| 10 | River Market `quay` | Faris | `sirr`, `page_9_found` | Nawawi 40, no. 11 |

## Masters

- `pa01_page_2__a.png`
- `pa02_read_2__a.png`
- `pa03_page_3__a.png`
- `pa04_read_3__a.png`
- `pa05_page_4__a.png`
- `pa06_read_4__a.png`
- `pa07_page_5__a.png`
- `pa08_read_5__a.png`
- `pa09_page_6__a.png`
- `pa10_read_6__a.png`
- `pa11_page_7__a.png`
- `pa12_read_7__a.png`
- `pa13_page_8__a.png`
- `pa14_read_8__a.png`
- `pa15_page_9__a.png`
- `pa16_read_9__a.png`
- `pa17_page_10__a.png`
- `pa18_read_10__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch01_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch01.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 64 under the Founder's blanket LOCK (9 Nov) |
