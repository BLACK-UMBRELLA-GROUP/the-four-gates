---
id: DOC-TFG-0051
type: SPEC
status: CURRENT
feature: IDRIS_HAS_HEARD
purpose: LOCK 14 - temptations, Idris has heard - Idris cools when temptation talk costs trust, holds back new pages (never prayer), and warms again when you do good
links: [AD-AIOS-115, DOC-TFG-0011, DOC-TFG-0017, DOC-TFG-0042, DOC-TFG-0045, DOC-TFG-0048, DOC-TFG-0052]
owner: THE FOUR GATES chat
---

# IDRIS HAS HEARD SPEC — CURRENT VERSION V1 (LOCK 14)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `idris_has_heard_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 2 (Idris, masjid), LOCK 3 (page 1, What people say), LOCK 11-13 (the six one-time trust hits of the temptations). Queue line 21 comes after line 20 |
| Masters | `../MASTERS/i01`-`i08` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V54 |
| ROADMAP | No row (temptations); noted for Fable |

## 1. Rules over everything (Founder, 6 Nov 2026)

| Rule | Meaning in this LOCK |
|---|---|
| "idris likes u less emaning ur games slows down forcing you to do good" | Idris is a person who hears the talk. When he is cool he will not read new pages with you, so learning waits until you do good |
| The game never plays God | Nothing happens by fate - only Idris's choice, from what people say |
| Faith is lived, not scored | Prayer is never blocked or changed. You can always pray, with the congregation or alone; Idris still leads it |

## 2. When Idris cools

The six temptation trust hits are: dice night 4 and 10 (LOCK 11), jar run 4 and 10 (LOCK 12), goat deal 4 and 10 (LOCK 13). Each time a **new** hit happens, Idris becomes cool and remembers River Market trust right after that hit (the "cool point").

## 3. What changes while he is cool (masters i02-i05, i08)

| Place | Change |
|---|---|
| Masjid bar | `masjid_line` after the other buttons (i02). Every prayer button stays (i08) |
| Page 1 | "Take the page to Idris" (LOCK 3) opens `page_refused` instead of the page (i03, i04). The page is not read, the word is not learned, "In secret" stays locked. `page_refused.to_map` returns to the market map; the open purse stays where it was |
| What people say | `say.cool` (bad) (i05) |

Later pages (not built yet) follow the same rule when they come.

## 4. The way back (masters i06, i07)

| Rule | Number / words |
|---|---|
| Warming | When River Market trust reaches the cool point + `warm_gain` (10), Idris is no longer cool. What people say then shows `say.warm` (good) instead of `say.cool` (i06), and page 1 can be read (i07) |
| Going back | A new dice night, jar run or goat deal while he is cool moves the cool point to the trust at that moment (the count starts again) |
| Cooling again | A new hit after warming makes him cool again (`say.cool` replaces `say.warm`) |

Only one Idris line shows at a time. Its place in What people say: straight after the LOCK 13 lines (the last line).

## 5. Masters

| Master | Shows |
|---|---|
| i01, i02 | Masjid before any talk; while cool |
| i03, i04 | The door list with "Take the page to Idris"; the page refused |
| i05, i06 | What people say while cool; after warming |
| i07 | Page 1 read after warming |
| i08 | Masjid at Dhuhr while cool: the prayer button is there |

Trust in i02-i07 was set for the picture (40 after the hit; 50 to warm). The dice line above the Idris line in i05 and i06 comes from LOCK 11. In i08 the Dhuhr call message was showing when the picture was taken.

## 6. Not in this LOCK (do not build)

Idris walking routes or a capsule with dialogue, any change to prayer, other people cooling, later pages, tawbah shown as a score (repentance is between the player and Allah and is never counted).

## 7. Build rules

Words and numbers only from `idris_has_heard_data_V1.json` (copied byte for byte to `SOURCE/data/idris_has_heard.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |
| 2026-11-11 | — | §4 "(the last line)" is superseded: the Idris line comes after the LOCK 13, 15, 16 and 31 lines and before the LOCK 10 sealed-purse line (DOC-TFG-0321 row 18) |
| 2026-11-11 | 10 | At the trust cap: Idris uses a private uncapped tally of River Market trust (every change added in full, including what the 100 cap cuts off; shown trust stays 0-100). The cool point is that tally after the hit or after a later temptation while cool; he warms when the tally reaches cool point + `warm_gain` (10). Below the cap this is the §4 rule unchanged. Example: 100 → 95 → +5 (100, tally 100) → +5 (100, tally 105) = warm |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 14. Founder 6 Nov: "idris likes u less emaning ur games slows down forcing you to do good"; 8 Nov: **"LOCK it (Recommended)"** after V53 |
