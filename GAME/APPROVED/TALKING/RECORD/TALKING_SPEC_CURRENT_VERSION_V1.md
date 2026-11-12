---
id: DOC-TFG-0027
type: SPEC
status: CURRENT
feature: TALKING
purpose: LOCK 6 - talking to people - five River Market regulars whose lines follow your trust and what they saw; greeting with salam; closes ROADMAP "Characters and dialogue"
links: [AD-AIOS-115, AD-AIOS-131, DOC-TFG-0017, DOC-TFG-0021, DOC-TFG-0024, DOC-TFG-0028]
owner: THE FOUR GATES chat
---

# TALKING SPEC — CURRENT VERSION V1 (LOCK 6)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder typed **"lock 6"**, then clickable **"LOCK it (Recommended)"** after seeing the prototype - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `talking_data_V1.json` beside this file (exported from the prototype's own data object; all 15 masters' text checked against the data files: 0 missing) |
| Builds on | LOCK 1-5 (trust, places, bread grab, stall, clothes, What people say). Queue line 13 comes after line 12 |
| Masters | `../MASTERS/t01`-`t15` at 1920 × 1080 (content, words, states and positions - not the look) |
| Prototype | "The Four Gates Prototype" V38 |
| ROADMAP | Closes "Characters and dialogue" (talkable townspeople, a dialogue system, choices that change how people treat you) |

## 1. Rules

People only know what they saw or heard; trust is a balance (Founder, 6 Nov). The game never plays God.

## 2. Who you can talk to

| Person (`people`) | Place | Capsule |
|---|---|---|
| Salma, the baker | Task board (the square, by her oven) | yes |
| Rashid, the spice seller | Spice row | yes |
| Layla, the weaver | Weaver's lane | yes |
| Jamal, the boat master | Quay | yes |
| Old Musa, the scale-keeper | Market scales | yes |

At each of these places the bar adds "Talk to {name}" (`talk_button`) after the place's other buttons (t01).

## 3. The talk panel (masters t02-t14)

| Rule | Number / words |
|---|---|
| Header | `panel.kicker` with the place name; title "{name}, {role}" |
| Line 1 | The person's `tier` line: River Market trust under `wary_below` (40) → `wary`; `warm_from` (80) and above → `warm`; otherwise `friendly` |
| Line 2 (only if it applies) | Salma: bread grab answer lie / truth / pay → `grab_lie` / `grab_truth` / `grab_pay` (none for quiet or no grab). Rashid: extra change returned → `returned`; kept and found out → `kept`. Layla: wearing clothes sold by Layla → `own_cloth`; wearing traveller's clothes → `traveller`. Jamal: bread given to Faris → `fed`, else boat job done → `boat`. Old Musa: lesson passed → `learned`, else `not_learned` |
| Line 3 | After greeting: `panel.reply`. After asking: the person's `tip` |
| Buttons | `panel.greet` (only until this person has been greeted once; then the label `panel.greeted`), `panel.ask`, `panel.bye` (back to the market map) |
| Greeting trust | When the third different person is greeted (`greet_count`), trust + `greet_trust` (1), once |

## 4. What people say (master t15)

After greeting 3 different people, `say.greets` is added first among the LOCK 4-5 lines (before the clothes lines).

Deen link: spreading salam, to people you know and people you don't.

HUD trust in t05-t15 was set for the picture (to show each tier).

## 5. Not in this LOCK (do not build)

Talking to anyone else (Idris has his own meeting from LOCK 2), branching conversations, people's daily routines, languages beyond the greeting, gossip and lying scenes beyond LOCK 3.

## 6. Build rules

Words and numbers only from `talking_data_V1.json` (copied byte for byte to `SOURCE/data/talking.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |
| 2026-11-11 | — | §4 "first among the LOCK 4-5 lines (before the clothes lines)": the greeting line comes straight before the clothes lines, after the LOCK 4 change and bread lines and all later LOCKs' lines (DOC-TFG-0321 row 24) |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 6. Founder 8 Nov: "lock 6", then **"LOCK it (Recommended)"** after trying the prototype draft (V37) |
