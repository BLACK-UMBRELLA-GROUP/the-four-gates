---
id: DOC-TFG-0193
type: SPEC
status: CURRENT
feature: SIDE_RING_MASJID
purpose: LOCK 61 - River Market side mission - a ring found in the masjid
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0194]
owner: THE FOUR GATES chat
---

# SIDE RING MASJID SPEC — CURRENT VERSION V1 (LOCK 61)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_ring_masjid_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 68 comes after line 67 |
| Masters | `../MASTERS/sm01`-`sm05` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2426 (announce found property) - checked 6 Nov |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `ring_masjid` - A ring found in the masjid (side mission)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Ask Yunus to announce it after each prayer` → `announce` · flag `ring_announced`<br>`Keep it` → `keep` · coins +8; flag `ring_kept` |
| `announce` | End: Back; mission done |
| `keep` | End: Back; mission done |

## Mission `ring_owner` - The ring's owner (scene)

Button `button`, shown when: River Market place `masjid`; 07:00-20:00; after `ring_announced`; 3 days after `ring_announced`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Give it to her` → `b` · trust +6; say `returned` |
| `b` | End: Back; mission done |

What people say lines (`say`): `returned` (good, Salma the baker) - shown in River Market What people say.

## Masters

- `sm01_ring_masjid__a.png`
- `sm02_ring_masjid__announce.png`
- `sm03_ring_masjid__keep.png`
- `sm04_ring_owner__a.png`
- `sm05_ring_owner__b.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_ring_masjid_data_V1.json` (copied byte for byte to `SOURCE/data/side_ring_masjid.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 61 under the Founder's blanket LOCK (9 Nov) |
