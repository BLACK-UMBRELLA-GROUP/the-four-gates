---
id: DOC-TFG-0057
type: SPEC
status: CURRENT
feature: RASHIDS_LOAN
purpose: LOCK 16 - wealth, Rashid's loan - lending without increase, the refused interest, and giving time, letting go or demanding when he is short
links: [AD-AIOS-115, DOC-TFG-0021, DOC-TFG-0027, DOC-TFG-0030, DOC-TFG-0042, DOC-TFG-0058]
owner: THE FOUR GATES chat
---

# RASHID'S LOAN SPEC — CURRENT VERSION V1 (LOCK 16)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `rashids_loan_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (trust, coins), LOCK 3 (What people say), LOCK 4 (Rashid's stall), LOCK 6 (Rashid), LOCK 7 (his hours and Friday prayer), LOCK 11 (Mansur, named in text). Queue line 23 comes after line 22 |
| Masters | `../MASTERS/l01`-`l18` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V58 |
| ROADMAP | No row (wealth); noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Founder's deen groups (6 Nov: "Wealth") | Lending without increase; riba shown through people's reaction |
| The game never plays God | Every result is Rashid's answer or what people say |

Design reference (not shown in the game): Quran 2:275 (riba forbidden), 2:280 (give time to one in hardship; letting it go as charity is better).

## 2. The spice row bar (masters l01, l06, l07, l10, l17)

Only while Rashid is at his stall (LOCK 7: not at night, not at Friday prayer). After the LOCK 4 stall button:

| Loan state | Bar |
|---|---|
| Not asked, trust ≥ `min_trust` (30) | `ask_button` (l01). Below 30 nothing (l17) |
| Lent, fewer than `due_days` (3) days since lending | `owed` with n = 30 (l06) |
| Lent, 3 or more days | `pay_button` (l07) |
| Waiting, fewer than `more_days` (7) days since the due visit | `owed` with n = 10 (l10) |
| Waiting, 7 or more days | `pay_button` |
| Refused or repaid | nothing - the loan is over for good |

Days are calendar days.

## 3. The ask (masters l02, l03, l05, l18)

Panel `ask`: `lend` (n = `loan`), `lend_more` (n = 30, m = `ask_back` 36), `no`. If coins < 30, `not_enough` replaces both lend buttons (l18).

| Choice | Effect |
|---|---|
| `lend` | Coins − 30, the lending day is kept, panel `lent` with `lent.to_map` (l05) |
| `lend_more` | No coins move, trust + `riba_trust` (−5), loan refused for good, panel `riba` with `to_rep` / `to_map` (l03) |
| `no` | Back to the market map; the ask stays |

## 4. When it is due (masters l08, l09, l13, l15)

`pay_button` opens panel `due` with three buttons:

| Choice | Coins | Trust | Then |
|---|---|---|---|
| `wait` | + `first_pay` (20) | + `wait_trust` (3) | Waiting; the due-visit day is kept (l09) |
| `forgive` | + 20 | + `forgive_trust` (5) | Repaid (l13) |
| `demand` | + `loan` (30) | + `demand_trust` (−5) | Repaid (l15) |

The panel then keeps the `due` kicker and title and shows `after.<choice>` with `after.to_rep` / `after.to_map`.

## 5. The last ten (master l11)

After waiting, `pay_button` adds `loan − first_pay` (10) coins straight away and shows panel `last` with `to_rep` / `to_map`. Repaid.

## 6. What people say (masters l04, l12, l14, l16)

One line: `say.riba`, `say.wait`, `say.forgive` or `say.demand` for the choice made. Placed after the LOCK 15 fountain line and before the LOCK 14 Idris line.

## 7. Masters

| Master | Shows |
|---|---|
| l01, l17 | Spice row with the ask; trust too low |
| l02-l04 | The ask; asking 36 back; What people say |
| l05-l07 | Lent; owes 30; has your money (3 days later) |
| l08-l12 | Due; gave time; owes 10; the last ten; What people say |
| l13, l14 | Let the ten go; What people say |
| l15, l16 | Demanded all; What people say |
| l18 | Not enough coins |

Start in every master: 198 coins, trust 45 (25 in l17, coins 20 in l18), set for the picture.

## 8. Not in this LOCK (do not build)

Other borrowers, Mansur's loans with increase (later LOCK), written contracts and witnesses (Quran 2:282 - later), Rashid walking routes, the caravan as a place.

## 9. Build rules

Words and numbers only from `rashids_loan_data_V1.json` (copied byte for byte to `SOURCE/data/rashids_loan.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 16. Founder 6 Nov deen group "Wealth" (lending without increase); 9 Nov: **"LOCK it (Recommended)"** after V57 |
