---
id: DOC-TFG-0017
type: SPEC
status: CURRENT
feature: CHAPTER_1
purpose: LOCK 3 - chapter 1 first missions in River Market - the open purse, hadith page 1 (giving in secret), the bread grab (first truth scene) and the What people say page
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0011, DOC-TFG-0018, DOC-TFG-0001]
owner: THE FOUR GATES chat
---

# CHAPTER 1 SPEC — CURRENT VERSION V1 (LOCK 3)

| Field | Value |
|---|---|
| Locked | 7 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `chapter1_data_V1.json` beside this file - the only source for every word and number of this LOCK. Checked automatically against the visible text of all 25 masters before queuing |
| Builds on | LOCK 1 V2 (trust, coins, tasks, market map) and LOCK 2 V3 (Ilmara, inn, clock, Idris, learned words). Queue lines 9-10 come after line 8 |
| Masters | `../MASTERS/c01`-`c25` at 1920 × 1080 (content, words, states and positions - not the look) |
| Prototype | "The Four Gates Prototype" V32 |
| Look | Placeholder shapes in Godot ("the visual aint importantn"): people are capsules with a name label |

## 1. Rules over everything (Founder, 6 Nov 2026)

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every result comes from a person: Salma tells you Tariq lied; Faris tells the quay boys you covered for him. No luck, no reward or punishment from fate |
| Trust is a balance | People weigh the good and the bad they saw or heard ("people will decide a bit like Fable"). A gift people see earns trust; a secret gift earns nothing that shows |
| Faith is lived, not lectured | The hadith is read with Idris after you find the page; nothing is preached before a choice |

## 2. The people (placeholders: capsules with name labels)

| Person | Where | Role in this LOCK |
|---|---|---|
| Yusuf (son Ali) | Inn door | Asks for the healer's fee (honest) |
| Faris | Inn door; the oven (bread grab) | Orphan from the quay: asks for shoes; takes the loaf |
| Tariq | Inn door | Says his house burned (lie) |
| Umm Salim | Not at the door | Appears in the list only after Salma tells you about her |
| Salma | Her oven by the task board (the square) | Tells you about Umm Salim, gives page 1; asks about the bread |
| Nadir | Inn | Translates (named in the text only) |
| Idris | Masjid | Reads page 1 with you |

Other names in the data (Rania, Jamal, Old Musa, Yunus) appear only in text.

## 3. The open purse (masters c01-c16)

| Rule | Number / words |
|---|---|
| Start | At the Inn, the place bar shows `places.inn` while the open purse is not done (c01) |
| Door list | `purse.people` without `hidden` (c02). Each row: name, ask, and "Give {n} coins" (`purse.give`, n = cost) |
| Give in public | Coins − cost, trust + `numbers.gift_trust` (2), row shows `given_public` (c03). Each person once |
| Not enough coins | If coins < cost the row shows `not_enough` (c07) |
| Ask Salma | `ask_baker` opens Salma's panel (c04); after it, Umm Salim (`hidden: true`) joins the list and "Take the page to {teacher}" appears |
| Page 1 | Panel per c05: `page.story`, `page.hadith` with the learned word `sirr` shown by the LOCK 2 word system, `page.source` · `page.learned`. Reading it learns `sirr` and unlocks "In secret" (`give_secret`) on every row not yet given (c06). Before the page, the line `only_public` shows |
| Give in secret | Coins − cost, **no trust change**, row shows `given_secret` |
| End the day | The clock jumps to the next day at `numbers.next_morning_minute` (07:00) and shows the morning panel (c08, c10, c12, c13) |
| Morning lines, in this order | 1. If any public gift: `crowd` with n = `crowd_base` + `crowd_per_gift` × public gifts; else if any gift: `quiet`; else `none`. 2. Yusuf: `father_public` / `father_secret`. 3. Faris: `boy`. 4. Tariq: `fire`. 5. Umm Salim: `widow_secret` / `widow_public` |
| After the morning | `to_rep` opens What people say; `to_map` returns to the market map at the Inn and the open purse is done (the inn button no longer shows) |
| Not now | `not_now` returns to the market map; the open purse stays open |

## 4. The bread grab (masters c17-c24)

| Rule | Number / words |
|---|---|
| Start | At the Task board (the square), the place bar shows `places.board` while the bread grab is not done (c17) |
| See | `grab.see` (c18). In 3D: the Faris capsule runs from Salma's oven; `see.next` ("Walk on") continues |
| Asked | If the time is before `numbers.grab_ask_minute` (16:10) the clock jumps to 16:10 the same day; `grab.ask` panel with the four answer buttons in data order (c19) |
| Answers | `truth` trust +3 · `lie` trust −5 · `quiet` 0 · `pay` trust +2 and coins −1. Trust stays 0-100; coins never below 0 |
| After | `answers.<choice>.out` (c20-c23); for `lie` also `after.note`. `to_rep` / `to_map`; the bread grab is then done (the board button no longer shows, c24) |

## 5. What people say (masters c09, c11, c14, c15, c16, c25)

| Rule | Number / words |
|---|---|
| Open | A "What people say" button on the market map bar beside "Wait until next prayer" (c01), and the `to_rep` buttons |
| Title | `rep.title` with n = River Market trust |
| Lines, in this order | Each LOCK 1 task: honest → `task_honest`; quick and put right → `task_amended` (mixed); quick → `task_quick`; the second line of each row is the task's place from `foundations.json`. Then: boat job done → `boat`; scales lesson passed → `learned`; any prayer prayed in congregation → `masjid`; any public gift → `gives`; gave to Tariq → `fooled`; gave to Umm Salim in public → `widow_public`; morning reached with no gift → `shut`; the bread grab answer's `say` line (none for `quiet`) |
| Each row | “line” in quotes, who says it below, and `rep.tone` for 1 / −1 / 0 on the right |
| Empty | `rep.empty` (c15) |
| Notes | `secret_note` only if any secret gift (c11); `towns_note` always |
| Buttons | `to_map`, `to_goal` (the LOCK 1 goal panel) |

## 6. Masters

| Master | Shows |
|---|---|
| c01 | Market map at the Inn: inn bar with `places.inn`; "What people say" button |
| c02-c07 | The door list: start; a public gift; Salma; page 1; secret buttons and Umm Salim; not enough coins |
| c08, c10, c12, c13 | Morning panels: public + Tariq; in secret; Umm Salim in public; no gift |
| c09, c11, c14, c15, c16 | What people say: gives + fooled; secret note; purse shut; empty; LOCK 1 lines |
| c17-c24 | Board bar with `places.board`; see; asked; the four answers; board bar after |
| c25 | What people say after the lie |

HUD numbers in c07, c16 and c25 were set for the picture (coins 5; trust 20 with task lines; trust 15 after a lie) - the rules above decide real values. Every other HUD number follows the rules from the stated start (198 coins, trust 20, Thursday 10:00).

## 7. Not in this LOCK (do not build)

Temptations (dice house, wine, stolen animals) · wealth projects, lending, partnership, zakat · the other chapter 1 missions (sealed purse, Sahila's boat, Sukara) · the other 99 pages and other collectibles · Maryam and the girl's version (comes with the boy-or-girl LOCK) · regulars' daily routines and memory · repeated-lie build-up · the towns' own What people say · pilgrim missions.

## 8. Build rules

- Words and numbers only from `chapter1_data_V1.json` (copied byte for byte to `SOURCE/data/chapter1.json`), plus `foundations.json` and `identity.json`.
- The hadith text and source are copied exactly; nothing added or shortened.
- Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-07 | V1 | LOCK 3. Founder, 6-7 Nov 2026: main story and scholar's pages typed; "Scholar's hadith notebook (Recommended)"; trust "yes but its a balance of good and bad ... people will decide a bit liek fable"; "let add lying ..."; "Named regulars + crowd (Recommended)"; "B · River Market regulars (Recommended)"; **"LOCK it (Recommended)"** |
