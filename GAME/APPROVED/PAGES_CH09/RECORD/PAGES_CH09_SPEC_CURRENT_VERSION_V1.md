---
id: DOC-TFG-0226
type: SPEC
status: CURRENT
feature: PAGES_CH09
purpose: LOCK 72 - pages 81-90 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0227]
owner: THE FOUR GATES chat
---

# PAGES CH09 SPEC — CURRENT VERSION V1 (LOCK 72)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch09_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 79 comes after line 78 |
| Masters | `../MASTERS/pi01`-`pi20` at 1920 × 1080 |
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
| 81 | River Market `masjid` | Yunus the muezzin | `chapter4_done` | Bukhari 5728 |
| 82 | town `waraka` | Fuad | `chapter4_done`, `page_81_found` | Bukhari 110 |
| 83 | town `najmara` | Hilal | `chapter4_done`, `page_82_found` | Bukhari 5027 |
| 84 | town `shifara` | Malik | `chapter4_done`, `page_83_found` | Muslim 2674 |
| 85 | River Market `weaver` | Layla | `chapter4_done`, `page_84_found` | Bukhari 6094 |
| 86 | town `waraka` | Zaynab | `chapter4_done`, `page_85_found` | Muslim 2605 |
| 87 | town `najmara` | Kamil | `chapter4_done`, `page_86_found` | Bukhari 2426 |
| 88 | town `shifara` | Shakir | `chapter4_done`, `page_87_found` | Bukhari 2463 |
| 89 | River Market `inn` | The innkeeper | `chapter4_done`, `page_88_found` | Bukhari 2358 |
| 90 | town `waraka` | Yaqub | `chapter4_done`, `page_89_found` | Bukhari 6018 |

## Masters

- `pi01_page_81__a.png`
- `pi02_read_81__a.png`
- `pi03_page_82__a.png`
- `pi04_read_82__a.png`
- `pi05_page_83__a.png`
- `pi06_read_83__a.png`
- `pi07_page_84__a.png`
- `pi08_read_84__a.png`
- `pi09_page_85__a.png`
- `pi10_read_85__a.png`
- `pi11_page_86__a.png`
- `pi12_read_86__a.png`
- `pi13_page_87__a.png`
- `pi14_read_87__a.png`
- `pi15_page_88__a.png`
- `pi16_read_88__a.png`
- `pi17_page_89__a.png`
- `pi18_read_89__a.png`
- `pi19_page_90__a.png`
- `pi20_read_90__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch09_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch09.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 72 under the Founder's blanket LOCK (9 Nov) |
