---
id: DOC-TFG-0217
type: SPEC
status: CURRENT
feature: PAGES_CH06
purpose: LOCK 69 - pages 51-60 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0218]
owner: THE FOUR GATES chat
---

# PAGES CH06 SPEC — CURRENT VERSION V1 (LOCK 69)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch06_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 76 comes after line 75 |
| Masters | `../MASTERS/pf01`-`pf20` at 1920 × 1080 |
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
| 51 | River Market `gate` | Abbas | `chapter1_done` | Nawawi 40, no. 37 |
| 52 | River Market `scales` | Karim | `chapter1_done`, `page_51_found` | Nawawi 40, no. 38 |
| 53 | River Market `inn` | The innkeeper | `chapter1_done`, `page_52_found` | Nawawi 40, no. 39 |
| 54 | River Market `masjid` | Yunus the muezzin | `chapter1_done`, `page_53_found` | Nawawi 40, no. 40 |
| 55 | River Market `quay` | Faris | `chapter1_done`, `page_54_found` | Nawawi 40, no. 41 |
| 56 | River Market `board` | Salma | `chapter1_done`, `page_55_found` | Nawawi 40, no. 42 |
| 57 | River Market `spice` | Rashid | `chapter1_done`, `page_56_found` | Muslim 2593 |
| 58 | River Market `weaver` | Layla | `chapter1_done`, `page_57_found` | Bukhari 334 |
| 59 | River Market `quay` | Jamal | `chapter1_done`, `page_58_found` | Bukhari 1012 |
| 60 | River Market `gate` | Abbas | `chapter1_done`, `page_59_found` | Bukhari 6407 |

## Masters

- `pf01_page_51__a.png`
- `pf02_read_51__a.png`
- `pf03_page_52__a.png`
- `pf04_read_52__a.png`
- `pf05_page_53__a.png`
- `pf06_read_53__a.png`
- `pf07_page_54__a.png`
- `pf08_read_54__a.png`
- `pf09_page_55__a.png`
- `pf10_read_55__a.png`
- `pf11_page_56__a.png`
- `pf12_read_56__a.png`
- `pf13_page_57__a.png`
- `pf14_read_57__a.png`
- `pf15_page_58__a.png`
- `pf16_read_58__a.png`
- `pf17_page_59__a.png`
- `pf18_read_59__a.png`
- `pf19_page_60__a.png`
- `pf20_read_60__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch06_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch06.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 69 under the Founder's blanket LOCK (9 Nov) |
