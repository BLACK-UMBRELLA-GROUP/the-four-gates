---
id: DOC-TFG-0211
type: SPEC
status: CURRENT
feature: PAGES_CH04
purpose: LOCK 67 - pages 31-40 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0212]
owner: THE FOUR GATES chat
---

# PAGES CH04 SPEC — CURRENT VERSION V1 (LOCK 67)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch04_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 74 comes after line 73 |
| Masters | `../MASTERS/pd01`-`pd20` at 1920 × 1080 |
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
| 31 | town `tahuna` | Ma'n | `chapter2_done` | Bukhari 1410 |
| 32 | town `nahla` | Dawud | `chapter2_done`, `page_31_found` | Bukhari 1417 |
| 33 | town `tinara` | Usama | `chapter2_done`, `page_32_found` | Muslim 1631 |
| 34 | town `tahuna` | Ma'n | `chapter2_done`, `page_33_found` | Bukhari 1395 |
| 35 | town `nahla` | Dawud | `chapter2_done`, `page_34_found` | Muslim 1605 |
| 36 | town `tinara` | Usama | `chapter2_done`, `page_35_found` | Ibn Majah 2443 |
| 37 | town `tahuna` | Ma'n | `chapter2_done`, `page_36_found` | Bukhari 2078 |
| 38 | town `nahla` | Dawud | `chapter2_done`, `page_37_found` | Abu Dawud 3580 |
| 39 | town `tinara` | Usama | `chapter2_done`, `page_38_found` | Tirmidhi 1295 |
| 40 | town `tahuna` | Ma'n | `chapter2_done`, `page_39_found` | Abu Dawud 2574 |

## Masters

- `pd01_page_31__a.png`
- `pd02_read_31__a.png`
- `pd03_page_32__a.png`
- `pd04_read_32__a.png`
- `pd05_page_33__a.png`
- `pd06_read_33__a.png`
- `pd07_page_34__a.png`
- `pd08_read_34__a.png`
- `pd09_page_35__a.png`
- `pd10_read_35__a.png`
- `pd11_page_36__a.png`
- `pd12_read_36__a.png`
- `pd13_page_37__a.png`
- `pd14_read_37__a.png`
- `pd15_page_38__a.png`
- `pd16_read_38__a.png`
- `pd17_page_39__a.png`
- `pd18_read_39__a.png`
- `pd19_page_40__a.png`
- `pd20_read_40__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch04_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch04.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 67 under the Founder's blanket LOCK (9 Nov) |
