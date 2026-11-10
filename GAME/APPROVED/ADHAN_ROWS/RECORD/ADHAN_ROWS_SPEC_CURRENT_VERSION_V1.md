---
id: DOC-TFG-0235
type: SPEC
status: CURRENT
feature: ADHAN_ROWS
purpose: LOCK 75 - the adhan and the rows
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0236]
owner: THE FOUR GATES chat
---

# ADHAN ROWS SPEC — CURRENT VERSION V1 (LOCK 75)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `adhan_rows_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 82 comes after line 81 |
| Masters | `../MASTERS/db01`-`db02` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Muslim 384, Bukhari 723 - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: the reply to the adhan as shown |



## Mission `adhan_rows` - The adhan and the rows (scene)

Button `button`, shown when: River Market place `masjid`; 05:00-21:00; after `wudu_learned`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Repeat the adhan after him` → `b` · - |
| `b` | `Stand in the row` → `leave` · flag `rows_learned` |

## Masters

- `db01_adhan_rows__a.png`
- `db02_adhan_rows__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `adhan_rows_data_V1.json` (copied byte for byte to `SOURCE/data/adhan_rows.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 75 under the Founder's blanket LOCK (9 Nov) |
