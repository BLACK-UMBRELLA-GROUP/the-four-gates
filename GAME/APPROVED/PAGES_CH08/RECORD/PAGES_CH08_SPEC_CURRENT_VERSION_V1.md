---
id: DOC-TFG-0223
type: SPEC
status: CURRENT
feature: PAGES_CH08
purpose: LOCK 71 - pages 71-80 of the scholar's notebook - where each is found, through whom, and what Idris says when you read it
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0111, DOC-TFG-0224]
owner: THE FOUR GATES chat
---

# PAGES CH08 SPEC — CURRENT VERSION V1 (LOCK 71)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pages_ch08_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1), LOCK 34 runner, LOCK 64 (how pages work). Queue line 78 comes after line 77 |
| Masters | `../MASTERS/ph01`-`ph20` at 1920 × 1080 |
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
| 71 | town `tinara` | Sumayya | `chapter3_done` | Bukhari 5560 |
| 72 | town `tahuna` | Rami | `chapter3_done`, `page_71_found` | Bukhari 1773 |
| 73 | River Market `quay` | Faris | `chapter3_done`, `page_72_found` | Abu Dawud 2548 |
| 74 | town `nahla` | Dawud | `chapter3_done`, `page_73_found` | Bukhari 2363 |
| 75 | town `tinara` | Usama | `chapter3_done`, `page_74_found` | Bukhari 5304 |
| 76 | town `tahuna` | Ma'n | `chapter3_done`, `page_75_found` | Bukhari 2766 |
| 77 | River Market `quay` | Jamal | `chapter3_done`, `page_76_found` | Bukhari 6011 |
| 78 | town `nahla` | Umm Yahya | `chapter3_done`, `page_77_found` | Bukhari 2442 |
| 79 | town `tinara` | Hakam | `chapter3_done`, `page_78_found` | Bukhari 5645 |
| 80 | town `tahuna` | Hafsa | `chapter3_done`, `page_79_found` | Muslim 2999 |

## Masters

- `ph01_page_71__a.png`
- `ph02_read_71__a.png`
- `ph03_page_72__a.png`
- `ph04_read_72__a.png`
- `ph05_page_73__a.png`
- `ph06_read_73__a.png`
- `ph07_page_74__a.png`
- `ph08_read_74__a.png`
- `ph09_page_75__a.png`
- `ph10_read_75__a.png`
- `ph11_page_76__a.png`
- `ph12_read_76__a.png`
- `ph13_page_77__a.png`
- `ph14_read_77__a.png`
- `ph15_page_78__a.png`
- `ph16_read_78__a.png`
- `ph17_page_79__a.png`
- `ph18_read_79__a.png`
- `ph19_page_80__a.png`
- `ph20_read_80__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Pages that open new choices in missions; a page list screen (the Journal shows the count).

## Build rules

Words and numbers only from `pages_ch08_data_V1.json` (copied byte for byte to `SOURCE/data/pages_ch08.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | 13 (general) | Masters were drawn from the full prototype, so they can also show content from LATER queue lines (Journal chapters, missions, people, buttons, ticks). Those are set-up too: build only what this line's data holds, and capture the same state without the later content. Missing later content is never a reason to stop. |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 71 under the Founder's blanket LOCK (9 Nov) |
