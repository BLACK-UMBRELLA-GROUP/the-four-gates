---
id: DOC-TFG-0229
type: SPEC
status: CURRENT
feature: PAGES_CH10
purpose: LOCK 73 - pages 91-99 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0230]
owner: THE FOUR GATES chat
---

# PAGES CH10 SPEC — CURRENT VERSION V1 (LOCK 73)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch10_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 80 comes after line 79 |
| Masters | `../MASTERS/pj01`-`pj18` at 1920 × 1080 |
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
| 91 | River Market `quay` | Faris | `hoarders_done` | Bukhari 6114 |
| 92 | River Market `board` | Salma | `hoarders_done`, `page_91_found` | Abu Dawud 4800 |
| 93 | River Market `spice` | Rashid | `hoarders_done`, `page_92_found` | Bukhari 3559 |
| 94 | River Market `weaver` | Layla | `hoarders_done`, `page_93_found` | Tirmidhi 2004 |
| 95 | River Market `quay` | Jamal | `hoarders_done`, `page_94_found` | Muslim 2626 |
| 96 | River Market `gate` | Abbas | `hoarders_done`, `page_95_found` | Bukhari 5971 |
| 97 | River Market `scales` | Karim | `hoarders_done`, `page_96_found` | Bukhari 2587 |
| 98 | River Market `inn` | The innkeeper | `hoarders_done`, `page_97_found` | Bukhari 2449 |
| 99 | River Market `masjid` | Yunus the muezzin | `hoarders_done`, `page_98_found` | Bukhari 5376 |

## Masters

- `pj01_page_91__a.png`
- `pj02_read_91__a.png`
- `pj03_page_92__a.png`
- `pj04_read_92__a.png`
- `pj05_page_93__a.png`
- `pj06_read_93__a.png`
- `pj07_page_94__a.png`
- `pj08_read_94__a.png`
- `pj09_page_95__a.png`
- `pj10_read_95__a.png`
- `pj11_page_96__a.png`
- `pj12_read_96__a.png`
- `pj13_page_97__a.png`
- `pj14_read_97__a.png`
- `pj15_page_98__a.png`
- `pj16_read_98__a.png`
- `pj17_page_99__a.png`
- `pj18_read_99__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch10_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch10.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 73 under the Founder's blanket LOCK (9 Nov) |
