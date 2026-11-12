---
id: DOC-TFG-0069
type: SPEC
status: CURRENT
feature: IFTAR_GIVING
purpose: LOCK 20 - wealth, iftar for the fasting - paying for dates or soup at the masjid before Maghrib in Ramadan, counted toward the 10,000 meals, public or secret
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0036, DOC-TFG-0066, DOC-TFG-0070]
owner: THE FOUR GATES chat
---

# IFTAR GIVING SPEC — CURRENT VERSION V1 (LOCK 20)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `iftar_giving_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (page 1 unlocks giving in secret), LOCK 9 (meals for the poor and its goal of 10,000 - the same counter), LOCK 19 (Ramadan days, the masjid). Queue line 27 comes after line 26 |
| Masters | `../MASTERS/v01`-`v10` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V66 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder 8 Nov: "in ramaadan pay to feed poor also same concept but of course ramadan a little different" | The LOCK 9 feeding, moved to the masjid before Maghrib in Ramadan |
| Secret giving earns no visible trust (LOCK 3) | Secret: no trust, no line |

Design reference (not shown in the game): whoever gives iftar to a fasting person has a reward like his (Jami' at-Tirmidhi 807, checked on sunnah.com).

## 2. The button (masters v01, v09, v10)

At the Masjid on a Ramadan day (LOCK 19) from `from` (960 = 16:00) until before `until` (1090 = 18:10): `masjid_button`, before the LOCK 19 items. Not after Maghrib (v09), not outside Ramadan (v10).

## 3. The panel (masters v02-v04, v06-v08)

Built like the LOCK 9 panel: `panel.kicker`, `panel.title`, then `panel.intro` (or the last result: `done_public` / `done_secret`), one row per `options` entry (name, line, and `pay` with n = cost, or `not_enough` when coins < cost, v08), then the secret row - `secret_label` tick box (and `secret_on` when ticked, v06) only after page 1, otherwise `secret_locked` (v02) - then `counter` (n = meals for the poor, m = 10,000 from LOCK 9) and `back`. Opening the panel clears the last result.

## 4. Paying

Coins − cost; meals for the poor + the option's meals (the same counter as LOCK 9). Public (not ticked, or before page 1): `done_public`; trust + `trust_per_day` (1) only the first public payment of that day (v03, v04); What people say gains `say.feeds` (v05), straight after the LOCK 9 line. Secret: `done_secret`, no trust, no line (v07).

## 5. Masters

| Master | Shows |
|---|---|
| v01 | Masjid at 16:40 on 1 Ramadan: the button |
| v02-v04 | Panel before page 1; dates paid in public (194 coins, 20 meals); soup the same day (179, 70; trust only once) |
| v05 | What people say: "Feeds the fasting" |
| v06, v07 | Secret ticked; dates paid in secret |
| v08 | Not enough coins (coins 3) |
| v09, v10 | No button after Maghrib; none on 29 Sha'ban |

Set for the pictures: trust 45, coins 198, meals 0; page 1 read only in v06-v07.

## 6. Not in this LOCK (do not build)

Iftar crowds or food models, feeding outside Ramadan at the masjid, zakat al-fitr, Laylat al-Qadr, Eid.

## 7. Build rules

Words and numbers only from `iftar_giving_data_V1.json` (copied byte for byte to `SOURCE/data/iftar_giving.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 20. Founder 8 Nov: "you can also pay to feed poor in game and in ramaadan pay to feed poor also same concept but of course ramadan a little different"; 9 Nov: **"LOCK it (Recommended)"** after V65 |
