---
id: DOC-TFG-0271
type: SPEC
status: CURRENT
feature: TRUTH
purpose: LOCK 87 - the truth system
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0272]
owner: THE FOUR GATES chat
---

# TRUTH SPEC — CURRENT VERSION V1 (LOCK 87)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `truth_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 94 comes after line 93 |
| Masters | `../MASTERS/dn01`-`dn01` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 6094 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |

## 2. The truth system

Choices that are lies (listed in `truth.lie_choices`: Sahila's boat “She's sound”, Ziyad's boat “Say you didn't know”, the spilled spice “Say it was Faris”) also add 1 to the private counter `lies`. At `found_out_at` (2) lies, River Market's What people say adds `truth.line`, and Idris has a quiet word (mission `truth_found`). Lies are only ever found out through people. More lie choices in later content are tagged the same way.

## Mission `truth_found` - The truth comes out (scene)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Listen` → `leave` · - |

## Masters

- `dn01_truth_found__a.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `truth_data_V1.json` (copied byte for byte to `SOURCE/data/truth.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 87 under the Founder's blanket LOCK (9 Nov) |
