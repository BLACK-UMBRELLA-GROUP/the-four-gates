---
id: DOC-TFG-0323
type: SPEC
status: CURRENT
feature: SIX_GATES
purpose: LOCK 103 - THE SIX GATES - Ilmara's six gates, the pillar of iman each one teaches, the journey % that opens them, six chapters and the hard year, the two new lands, and how the 31 held queue lines change
links: [DOC-TFG-0117, DOC-TFG-0111, DOC-TFG-0322, DOC-TFG-0320, AD-AIOS-115]
owner: THE FOUR GATES chat
---

# THE SIX GATES SPEC — CURRENT VERSION V1 (LOCK 103)

| Field | Value |
|---|---|
| Locked | 17 Nov 2026 - see section 2 and `LOCK_RECORD.md` beside this file |
| Words and numbers | `six_gates_data_V1.json` beside this file; the gates' opening and the journey % are in `ROAD_MAP/RECORD/road_map_data_V2.json` (LOCK 36 V2) |
| Builds on | LOCK 1-2 (the city and its words), LOCK 32 (the Gate of Trust), LOCK 34 (towns and Journal), LOCK 36 (road map), 16 Nov drafts (the closed river, journey %) |
| Design reference | The prototype V81: the 3D world map (six gates, the gate list with pillars and %, the planned towns) |
| Masters | None: no native pictures (QUESTIONS 15). The prototype is the reference |

## 1. Purpose and scope

The city gets six gates instead of four, and each gate teaches one of the six pillars of iman through its towns' missions (from hadith). This LOCK fixes the gates, their order and opening %, the chapters, the two new lands with their planned towns, and the changes to the 31 queue lines held on 16 Nov. The new towns' people and missions, and the opening cutscene and the road home (16 Nov draft), are later LOCKs.

## 2. Decisions (Founder's words, exact)

| Date | Decision | Words |
|---|---|---|
| 16 Nov | Six gates, themed on the six pillars of iman | "maybe we can chane it to 6 gates and theme is around 6 pillars of eman or something" |
| 16 Nov | No angels shown; good and evil; missions from hadith | "no we wont show angles but its about learning maybe that stage is good and evil but we will work it out soon and based missions around those from hadiths but yeh make city have 6 gates" |
| 16 Nov | Name; held lines | clickable "THE SIX GATES (Recommended)"; "Hold the gate lines, build the rest (Recommended)" |
| 16 Nov | All gates open by 50%; everything counts | clickable "Your numbers: all open by 50% (Recommended)"; "Everything you do" |
| 17 Nov | Pillars | clickable "My draft (Recommended)" |
| 17 Nov | Order and % | clickable "Story order (Recommended)" |
| 17 Nov | New lands | clickable "My draft (Recommended)" |
| 17 Nov | Held lines | clickable "Only what the gates touch (Recommended)" |
| 17 Nov | LOCK | clickable **"LOCK it (Recommended)"** |

## 3. The six gates

| Gate | Direction | Teaches (design reference, never a label) | Opens | Towns |
|---|---|---|---|---|
| Gate of Trust | east | belief in Allah - trusting Him | trust 100 and the scales lesson (LOCK 32, unchanged; about 10%) | Jisra, Sahila, Sukara |
| Gate of Patience | north-west | qadr - patience with what is written | 20% of your journey | Safira, Wadira, Birana |
| Gate of Mercy | south-west | the messengers - the Prophet as a mercy | 30% | Nahla, Tinara, Tahuna |
| Gate of Knowledge | west | the books | 40% | Waraka, Najmara, Shifara |
| Gate of the Witness | north-east | the angels - never shown; your deeds are written down | 45% | Raqima, Hafiza, Shahida (planned) |
| Gate of Return | south-east | the Last Day - what you did comes back to you | 50% | Mizana, Milhara, Mirsana (planned) |

Rules: the angels are never shown or voiced; a pillar is taught by people, stories and hadith in missions, never by a lecture (LOCK 2: Idris teaches by sharing). The game never plays God (LOCK 1).

## 4. Your journey %

Exactly as `journey.rule` in LOCK 36 V2: done = missions done (main and side) + notebook pages found + Names of Allah learned + masjids prayed in + each lifetime goal's tenths reached; total = the same items available in the loaded data (each goal counts 10); journey % = floor(100 × done ÷ total). A gate opens when the % reaches its number and stays open. The Journal shows "Your journey · n%".

## 5. Chapters

| Chapter | Name | Ends with | Status |
|---|---|---|---|
| 1-4 | The Gate of Trust · Patience · Mercy · Knowledge | `chapter1_done` … `chapter4_done` (as locked) | Endings reworded: they no longer open the next gate (LOCK 39, 42, 45, 48 V2) |
| 5 | The Gate of the Witness | `chapter5_done` | Later LOCK (the hill country) |
| 6 | The Gate of Return | `chapter6_done` | Later LOCK (the salt coast) |
| 7 | The hard year | the ending | Starts after `chapter6_done` (LOCK 49 V2) |

## 6. The two new lands (planned; designed in later LOCKs)

| Land | Gate | Towns (made-up names) | Themes |
|---|---|---|---|
| The hill country - shepherds and watchtowers | Gate of the Witness | Raqima · Hafiza · Shahida | good done in secret; a lie that is written down; the one who keeps score |
| The salt coast - the port, the salt pans, the weighing house | Gate of Return | Mizana · Milhara · Mirsana | rights returned before the Day; a dying man's will; debts paid back |

## 7. The 31 held lines

| Line | LOCK | Change |
|---|---|---|
| 42 | 35 Jisra's people | No data change. Uses `words.people.talk` from LOCK 34 V2 (QUESTIONS 16) |
| 43 | 36 road map | **V2**: six gates, journey %, Journal line |
| 46 | 39 chapter 1 ends | **V2**: Idris's line about the north-west gate |
| 49 | 42 Birana | **V2**: chapter 2 ending wording |
| 52 | 45 Tahuna | **V2**: chapter 3 ending wording |
| 55 | 48 Shifara | **V2**: "Four of the six gates are open" |
| 56 | 49 the hoarders | **V2**: after `chapter6_done`; Journal chapter 7 |
| 44-45, 47-48, 50-51, 53-54, 57-58, 72-75, 77-79, 96-99, 102-104 | as locked | No data change; reissued brief (Needs row, real build-after line, no native pictures) |

New line 110 (this LOCK): the built screens' four-gate words become six (`renames`), the goal screen lists six gates (`goal_gates`), and the city map shows six gates (`city_gates`).

## 8. Not in this LOCK

The new towns' people, missions and roads; chapters 5 and 6; the opening cutscene and the road home (16 Nov draft); renaming the repository and folders (Fable).

## 9. Risks

| Risk | Mitigation |
|---|---|
| A pillar taught wrongly | Scholar check row 39 (after the build, does not block) |
| The angels shown by mistake | Rule in section 3; every later brief repeats it |
| The finale cannot start until chapters 5-6 exist | Expected; tests set `chapter6_done` |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-17 | V1 | LOCK 103 |
