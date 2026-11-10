---
id: DOC-TFG-0084
type: SPEC
status: CURRENT
feature: QURANS_SCHOOL
purpose: LOCK 25 - lifetime goals, Qurans and school - paying for hand-copied Qurans and children's school years at the masjid, public or secret, the 1,000 / 100 counters
links: [AD-AIOS-115, DOC-TFG-0011, DOC-TFG-0017, DOC-TFG-0036, DOC-TFG-0085]
owner: THE FOUR GATES chat
---

# QURANS AND SCHOOL SPEC — CURRENT VERSION V1 (LOCK 25)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `qurans_school_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 (Idris, the masjid), LOCK 3 (Faris; giving in secret after page 1; What people say), LOCK 9 (the public/secret giving pattern, trust once a day). Queue line 32 comes after line 31 |
| Masters | `../MASTERS/u01`-`u11` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V76 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder 8 Nov: "a side mission can be donate 1000 qurans and send 100 kids to school" | Lifetime counters `goal_qurans` (1,000) and `goal_children` (100) |
| Secret giving earns no visible trust (LOCK 3) | Secret: no trust, no line |

Design reference (not shown in the game): charity that continues and knowledge that benefits (Sahih Muslim 1631).

## 2. The masjid button (masters u01, u11)

At the Masjid from `from` (420 = 07:00) until before `until` (930 = 15:30): `masjid_button`. Not after 15:30 (u11).

## 3. The panel (masters u02-u05, u07, u08, u10)

`panel.kicker`, `panel.title`, then `panel.text` (or the last result, §4), then two compact rows - `quran` with `quran_line`, `school` with `school_line` - each with `pay` (n = `quran_cost` 25 / `school_cost` 30) or `not_enough` (u10); then the secret row (`secret_label` after page 1, else `secret_locked`); then one line with `counter` (n = Qurans given, m = 1,000) · `counter_school` (n = children, m = 100) and the `back` button. Opening the panel clears the last result. The back button stays on screen.

## 4. Paying

| Choice | Effect | Result text |
|---|---|---|
| Quran | Coins − 25; Qurans given + 1 | `quran_done` (u05) |
| School | Coins − 30; children + 1 | `first_child` when it is the first child (Faris, u03), otherwise `more_child` (u04) |

Then `public` or `secret` after the result text. Public (not ticked, or before page 1): trust + `trust_per_day` (1) only on the first public payment of that day; What people say gains `say.qurans` and/or `say.school` (u06), after the LOCK 24 lines. Secret: no trust, no line (u08, u09).

## 5. Masters

| Master | Shows |
|---|---|
| u01 | Masjid at 10:00: the button |
| u02-u05 | Panel before page 1; Faris first; another child; a Quran copied |
| u06 | What people say: both Idris lines |
| u07-u09 | Secret ticked; a Quran in secret; no line |
| u10, u11 | Not enough coins (20); no button after 15:30 |

Coins (200) and trust (45) set for the pictures.

## 6. Not in this LOCK (do not build)

The copyists' quarter (west), schools outside River Market, children as walking capsules, Faris's later story, delivery of the Qurans as an event.

## 7. Build rules

Words and numbers only from `qurans_school_data_V1.json` (copied byte for byte to `SOURCE/data/qurans_school.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 25. Founder 8 Nov: "also a side mission can be donate 1000 qurans and send 100 kids to school"; 9 Nov: **"LOCK it (Recommended)"** after V75 |
