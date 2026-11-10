---
id: DOC-TFG-0262
type: SPEC
status: CURRENT
feature: GOSSIP
purpose: LOCK 84 - gossip at the square
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0263]
owner: THE FOUR GATES chat
---

# GOSSIP SPEC — CURRENT VERSION V1 (LOCK 84)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `gossip_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and earlier LOCKs named in the data. Queue line 91 comes after line 90 |
| Masters | `../MASTERS/dk01`-`dk04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Quran 49:12 |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `gossip` - The gossip at the square (scene)

Button `button`, shown when: River Market place `board`; 08:00-18:00; after `chapter1_done`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Say you'd rather not talk about her` → `stop` · trust +4; say `stopped`<br>`Join in` → `join` · trust -3; say `joined`<br>`Walk away` → `away` · - |
| `stop` | End: Back; mission done |
| `join` | End: Back; mission done |
| `away` | End: Back; mission done |

What people say lines (`say`): `stopped` (good, the square); `joined` (bad, the square) - shown in River Market What people say.

## Masters

- `dk01_gossip__a.png`
- `dk02_gossip__stop.png`
- `dk03_gossip__join.png`
- `dk04_gossip__away.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `gossip_data_V1.json` (copied byte for byte to `SOURCE/data/gossip.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 84 under the Founder's blanket LOCK (9 Nov) |
