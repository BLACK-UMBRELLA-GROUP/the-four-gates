---
id: DOC-TFG-0060
type: SPEC
status: CURRENT
feature: HARM_IN_THE_ROAD
purpose: LOCK 17 - character and community, harm in the road - one harmful thing a day in River Market, moved unseen and unrewarded, with a private count
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0011, DOC-TFG-0033, DOC-TFG-0061]
owner: THE FOUR GATES chat
---

# HARM IN THE ROAD SPEC — CURRENT VERSION V1 (LOCK 17)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `harm_in_the_road_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (River Market places), LOCK 2 (clock, day numbers), LOCK 8 (private records). Queue line 24 comes after line 23 |
| Masters | `../MASTERS/p01`-`p09` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V60 |
| ROADMAP | No row (character and community); noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder's deen groups (6 Nov: "Character & community") | Moving harm off the road |
| Faith is lived, not scored | No coins, no trust, no What people say line. The count is private |
| The game never plays God | Walking past changes nothing - nobody gets hurt, nothing is punished |

Design reference (not shown in the game): removing harmful things from the road is charity (Sahih al-Bukhari 2989).

## 2. Today's harm

| Rule | Number / words |
|---|---|
| Which | Day number d (from the LOCK 2 clock, day 0 = arrival day): place = `places[d mod 7]`, harm = `harms[d mod 3]` |
| When | From `from` (390 = 06:30) until before `until` (1170 = 19:30). Not at night, not before 06:30 (p07, p08) |
| Where | Only at that place (p06 shows another place with nothing) |
| Once a day | After moving it, it is gone until the next day (p03) |

## 3. The bar (masters p01, p04, p05)

At the place, after every other bar item and before the LOCK 10 carrying line: the harm's `bar` text, then a button with its `move` text.

## 4. Moving it (masters p02, p09)

The clock moves forward `minutes` (5). The day is marked done, the private count goes up by 1, and the panel shows `panel.kicker`, the harm's `move` as the title, its `done` text, `panel.count` (n = the private count) and `panel.to_map`.

## 5. Masters

| Master | Shows |
|---|---|
| p01-p03 | Day 0 at Weaver's lane: thorns; moved (count 1); gone after |
| p04, p05 | Day 1 Spice row: shards; day 2 Quay: rope |
| p06-p08 | Nothing at another place, at night, before 06:30 |
| p09 | Day 4 with the count set to 6 before moving (now 7) |

Start: trust 45, set for the picture. Other bar items in the masters come from earlier LOCKs.

## 6. Not in this LOCK (do not build)

Harm objects as 3D models (a placeholder shape is allowed but not required), harm outside River Market, anyone seeing you do it, people getting hurt, the count shown anywhere else.

## 7. Build rules

Words and numbers only from `harm_in_the_road_data_V1.json` (copied byte for byte to `SOURCE/data/harm_in_the_road.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 17. Founder 6 Nov deen group "Character & community"; 9 Nov: **"LOCK it (Recommended)"** after V59 |
