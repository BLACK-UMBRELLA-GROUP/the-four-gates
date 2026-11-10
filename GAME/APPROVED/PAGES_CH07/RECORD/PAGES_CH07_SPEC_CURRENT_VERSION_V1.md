---
id: DOC-TFG-0220
type: SPEC
status: CURRENT
feature: PAGES_CH07
purpose: LOCK 70 - pages 61-70 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0221]
owner: THE FOUR GATES chat
---

# PAGES CH07 SPEC — CURRENT VERSION V1 (LOCK 70)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch07_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 77 comes after line 76 |
| Masters | `../MASTERS/pg01`-`pg20` at 1920 × 1080 |
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
| 61 | town `birana` | Wahb | `chapter2_done` | Bukhari 6464 |
| 62 | town `jisra` | Umm Hani | `chapter2_done`, `page_61_found` | Bukhari 39 |
| 63 | town `sahila` | Mukhtar | `chapter2_done`, `page_62_found` | Bukhari 1923 |
| 64 | town `sukara` | Sakhr | `chapter2_done`, `page_63_found` | Bukhari 2009 |
| 65 | town `safira` | Amina | `chapter2_done`, `page_64_found` | Bukhari 2017 |
| 66 | town `wadira` | Ghazi | `chapter2_done`, `page_65_found` | Bukhari 1933 |
| 67 | town `birana` | Wahb | `chapter2_done`, `page_66_found` | Bukhari 1902 |
| 68 | town `jisra` | Umm Hani | `chapter2_done`, `page_67_found` | Tirmidhi 807 |
| 69 | town `sahila` | Mukhtar | `chapter2_done`, `page_68_found` | Bukhari 1503 |
| 70 | town `sukara` | Sakhr | `chapter2_done`, `page_69_found` | Muslim 1162 |

## Masters

- `pg01_page_61__a.png`
- `pg02_read_61__a.png`
- `pg03_page_62__a.png`
- `pg04_read_62__a.png`
- `pg05_page_63__a.png`
- `pg06_read_63__a.png`
- `pg07_page_64__a.png`
- `pg08_read_64__a.png`
- `pg09_page_65__a.png`
- `pg10_read_65__a.png`
- `pg11_page_66__a.png`
- `pg12_read_66__a.png`
- `pg13_page_67__a.png`
- `pg14_read_67__a.png`
- `pg15_page_68__a.png`
- `pg16_read_68__a.png`
- `pg17_page_69__a.png`
- `pg18_read_69__a.png`
- `pg19_page_70__a.png`
- `pg20_read_70__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch07_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch07.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 70 under the Founder's blanket LOCK (9 Nov) |
