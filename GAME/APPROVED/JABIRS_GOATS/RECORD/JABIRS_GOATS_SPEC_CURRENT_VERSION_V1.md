---
id: DOC-TFG-0048
type: SPEC
status: CURRENT
feature: JABIRS_GOATS
purpose: LOCK 13 - temptations, Jabir's goats - buying stolen animals for profit, walking away, or telling the owner; talk builds up over the deals
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0017, DOC-TFG-0027, DOC-TFG-0042, DOC-TFG-0049]
owner: THE FOUR GATES chat
---

# JABIR'S GOATS SPEC — CURRENT VERSION V1 (LOCK 13)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `jabirs_goats_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (trust), LOCK 2 (clock, Gate of Trust), LOCK 3 (What people say), LOCK 11 (the build-up rule). Queue line 20 comes after line 19 |
| Masters | `../MASTERS/j01`-`j12` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V52 |
| ROADMAP | No row (temptations); noted for Fable |

## 1. Rules over everything (Founder, 6 Nov 2026)

| Rule | Meaning in this LOCK |
|---|---|
| Your choice | "somone offers you money to buy animals which dont belong to them and again u can do it or not". The owner's mark is stated in the offer; you are never tricked |
| The game never plays God | Every result comes from people: the butcher, Saeed, the market |
| It builds up | The same build-up rule as LOCK 11, counted on its own for this temptation |

Saeed the herder is a new name (named in text only). Old Musa stays the scale-keeper of LOCK 6. Deen reference for the design (not shown in the game): Quran 2:188.

## 2. Hours and the gate bar (masters j01, j02, j05, j09)

At the Gate of Trust, `gate_button` shows from `open_from` (900 = 15:00) until before `open_until` (1080 = 18:00), when no deal has been made that day and Saeed has not been told (j02). Not in the morning (j01), not after a deal that day (j05), never again after telling Saeed (j09).

## 3. The offer (masters j03, j06)

Panel `offer` with three buttons in this order: `offer.buy` (n = `price`), or `offer.not_enough` in its place if coins < `price` (j06); `offer.tell`; `offer.no` (back to the market map at the gate, nothing changed).

## 4. Buying (master j04)

Coins − `price` + `butcher_pays` (net +20), the day is marked, deals + 1, then panel `bought` with `bought.deals` (n = deals so far) and `bought.to_map`. One deal a day (the day is the calendar day).

## 5. Telling Saeed (masters j07-j09)

Trust + `tell_trust` (3), panel `told` with `told.to_rep` and `told.to_map`. Jabir never comes back (the temptation ends for good). What people say gains `say.told` (good) (j08). Deals made before telling still count.

## 6. Talk that builds up (masters j10-j12)

| Deals | What people say line | Trust |
|---|---|---|
| 1 | none | none |
| `talk_from_deals` (2) to 3 | `say.talk` (mixed) (j10) | none |
| `seen_from_deals` (4) to 9 | `say.seen` (bad) (j11) | `seen_trust` (−5), once, on the 4th deal |
| `fence_from_deals` (10) or more | `say.fence` (bad) (j12) | `fence_trust` (−10) more, once, on the 10th deal |

Lines in What people say: straight after the LOCK 12 jars line - first the highest build-up line reached (if any), then `say.told` (if told). Trust stays 0-100. Deals never add to dice nights or jar runs.

## 7. Masters

| Master | Shows |
|---|---|
| j01, j02 | Gate in the morning (no drover); in the afternoon (`gate_button`) |
| j03, j04 | The offer; after buying (198 → 218 coins) |
| j05, j06 | Gate after a deal the same day; not enough coins |
| j07-j09 | Told Saeed; What people say; Jabir gone the next day |
| j10-j12 | What people say after 2, 4 and 10 deals |

HUD numbers in j06 (coins 6) and the deals in j10-j12 were set for the picture (start trust 45). In j02 and j09 the Asr call message was showing when the picture was taken and is not part of this LOCK.

## 8. Not in this LOCK (do not build)

Owning animals yourself (property LOCK), Saeed or Jabir capsules walking routes or goat models (text only), the gatekeepers stopping Jabir, Idris growing cooler, the butcher as a place.

## 9. Build rules

Words and numbers only from `jabirs_goats_data_V1.json` (copied byte for byte to `SOURCE/data/jabirs_goats.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 13. Founder 6 Nov: "somone offers you money to buy animals which dont belong to them and again u can do it or not"; 8 Nov: **"LOCK it (Recommended)"** after V51 |
