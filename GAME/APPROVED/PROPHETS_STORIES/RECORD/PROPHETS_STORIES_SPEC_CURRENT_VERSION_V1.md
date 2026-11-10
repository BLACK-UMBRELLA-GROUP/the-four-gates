---
id: DOC-TFG-0250
type: SPEC
status: CURRENT
feature: PROPHETS_STORIES
purpose: LOCK 80 - stories of the prophets after Isha
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0251]
owner: THE FOUR GATES chat
---

# PROPHETS STORIES SPEC — CURRENT VERSION V1 (LOCK 80)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `prophets_stories_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 87 comes after line 86 |
| Masters | `../MASTERS/dg01`-`dg05` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 12; 51:24-30; 11:25-48; 37:139-148; 18:60-82 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: each story retold in plain words |



## Mission `story_yusuf` - Yusuf (scene)

Button `button`, shown when: River Market place `masjid`; 19:10-21:30; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Thank him` → `leave` · flag `story_1`; stories +1 |

## Mission `story_ibrahim` - Ibrahim's guests (scene)

Button `button`, shown when: River Market place `masjid`; 19:10-21:30; after `story_1`; 2 days after `story_1`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Thank him` → `leave` · flag `story_2`; stories +1 |

## Mission `story_nuh` - Nuh (scene)

Button `button`, shown when: River Market place `masjid`; 19:10-21:30; after `story_2`; 2 days after `story_2`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Thank him` → `leave` · flag `story_3`; stories +1 |

## Mission `story_yunus` - Yunus (scene)

Button `button`, shown when: River Market place `masjid`; 19:10-21:30; after `story_3`; 2 days after `story_3`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Thank him` → `leave` · flag `story_4`; stories +1 |

## Mission `story_musa` - Musa and the wise servant (scene)

Button `button`, shown when: River Market place `masjid`; 19:10-21:30; after `story_4`; 2 days after `story_4`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Thank him` → `leave` · flag `story_5`; stories +1 |

## Masters

- `dg01_story_yusuf__a.png`
- `dg02_story_ibrahim__a.png`
- `dg03_story_nuh__a.png`
- `dg04_story_yunus__a.png`
- `dg05_story_musa__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `prophets_stories_data_V1.json` (copied byte for byte to `SOURCE/data/prophets_stories.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 80 under the Founder's blanket LOCK (9 Nov) |
