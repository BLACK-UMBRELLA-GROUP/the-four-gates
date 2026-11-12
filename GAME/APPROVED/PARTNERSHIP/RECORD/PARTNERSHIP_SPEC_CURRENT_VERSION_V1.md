---
id: DOC-TFG-0102
type: SPEC
status: CURRENT
feature: PARTNERSHIP
purpose: LOCK 31 - wealth, a partnership with Layla - 60 coins for a second loom, profit shared by portion including the bad weeks; a fixed weekly return refused as interest
links: [AD-AIOS-115, DOC-TFG-0024, DOC-TFG-0027, DOC-TFG-0030, DOC-TFG-0057, DOC-TFG-0103]
owner: THE FOUR GATES chat
---

# PARTNERSHIP SPEC — CURRENT VERSION V1 (LOCK 31)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `partnership_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 5 (Layla's loom), LOCK 6 (Layla), LOCK 7 (her hours), LOCK 3 (What people say), LOCK 16 (riba refused through a person). Queue line 38 comes after line 37 |
| Masters | `../MASTERS/ps01`-`ps12` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V88 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder's deen groups (6 Nov: "Wealth" - partnership) | Partners share profit and loss by a portion |
| Riba through people | A fixed return "whatever happens" is refused by Layla |
| Scholar check (open) | The partnership terms |

Design reference (not shown in the game): Quran 2:275.

## 2. The weaver's lane bar (masters ps01, ps06, ps07, ps11)

Only while Layla is at her loom (LOCK 7, LOCK 27 unaffected - she is not a goer). After the loom button:

| State | Bar |
|---|---|
| Not asked, trust ≥ `min_trust` (40) | `ask_button` (ps01). Below 40 nothing (ps11) |
| Partners, share not yet due | `running` (n = days until the next share) (ps06) |
| Partners, share due | `share_button` (ps07) |
| Refused | Nothing, for good |

A share is due every `week_days` (7) days from the day you became partners: week k is due on that day + 7 × k.

## 3. The offer (masters ps02, ps03, ps05, ps12)

Panel `ask` with `partner` (n = `capital` 60) and `fixed` (n = 60, m = `fixed_ask` 5), or `not_enough` instead of both (ps12), and `no`.

| Choice | Effect |
|---|---|
| `partner` | Coins − 60; partners from today; panel `agreed` (ps05) |
| `fixed` | No coins move; trust + `riba_trust` (−3); refused for good; panel `riba` (ps03) |

## 4. The weekly share (masters ps08, ps09)

Week k (1, 2, 3 ...) uses `profits[(k − 1) mod 4]` (10, 6, 0, 12). Coins + profit × `share_percent` (50%) rounded down. Panel `week` (kicker with n = k): `week.good` (m = profit, n = your half) or `week.none` when the profit is 0 (ps09).

## 5. What people say (masters ps04, ps10)

`say.partner` (good) or `say.riba` (bad), straight after the LOCK 16 loan line.

## 6. Masters

| Master | Shows |
|---|---|
| ps01-ps04 | The button; the offer; the fixed return refused; What people say |
| ps05-ps10 | Partners (138 coins); next share in 7 days; share due; week 1 (+5); week 3 the bad week; What people say |
| ps11, ps12 | Trust too low (35); not enough coins (20) |

Trust 45 and coins 198 set for the pictures. Other bar items come from earlier LOCKs.

## 7. Not in this LOCK (do not build)

Ending the partnership and taking the capital back, other partners, Layla's niece as a character, losing capital, contracts and witnesses.

## 8. Build rules

Words and numbers only from `partnership_data_V1.json` (copied byte for byte to `SOURCE/data/partnership.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 31. Founder 6 Nov deen group "Wealth" (partnership); 9 Nov: **"LOCK it (Recommended)"** after V87 |
