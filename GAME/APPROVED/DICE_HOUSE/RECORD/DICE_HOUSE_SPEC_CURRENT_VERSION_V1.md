---
id: DOC-TFG-0042
type: SPEC
status: CURRENT
feature: DICE_HOUSE
purpose: LOCK 11 - temptations, the dice house - Mansur's invitation after Isha, fair dice, and talk that builds up with the nights you go
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0011, DOC-TFG-0017, DOC-TFG-0030, DOC-TFG-0043]
owner: THE FOUR GATES chat
---

# DICE HOUSE SPEC — CURRENT VERSION V1 (LOCK 11)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `dice_house_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (trust), LOCK 2 (clock, Isha, Fajr, inn), LOCK 3 (What people say). Queue line 18 comes after line 17 |
| Masters | `../MASTERS/x01`-`x12` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V48 |
| ROADMAP | No row (temptations); noted for Fable |

## 1. Rules over everything (Founder, 6 Nov 2026)

| Rule | Meaning in this LOCK |
|---|---|
| You can really win | "where you can gamble and actually win but again its somethign wrong". The dice are fair: `win_chance_percent` (50). Nothing in the game changes the odds - not prayer, not trust, not luck |
| The game never plays God | No bad luck after winning, no punishment from fate. Every result comes from people talking |
| Kept secret, but it builds up | "its kept secret but doesnt mean you get caught ... if u do it once comapred to 10 times the crowed speak differntly about u and ur respect loswers". One night: nobody knows. More nights: talk grows, then trust falls |

Deen reference for the design (not shown in the game; faith is lived, not lectured): Quran 5:90 and 2:219 (gambling, *maysir*).

## 2. Opening hours and the inn bar (masters x01, x02, x08, x12)

| Rule | Number / words |
|---|---|
| Open | From `open_from` (1170 = 19:30, after Isha) until before `open_until` (285 = 04:45, Fajr), every night. Outside these times nothing shows at the inn (x01) |
| Not yet invited | The inn bar shows `inn_invite` (x02) |
| Invited | After the invitation (followed or not) the inn bar shows `inn_button` every open night (x08, x12) |

## 3. The invitation (master x03)

Panel `invite`: `go` enters the dice house (§4); `no` returns to the market map at the Inn, marks the player as invited, and changes nothing else (the clock does not move; sleep belongs to a later calendar LOCK) (x12).

## 4. The dice house (masters x04-x07)

| Rule | Number / words |
|---|---|
| Entering | From `invite.go` or `inn_button`. Counts a **night** only once per night: the night is the day of the evening, and a visit before 04:45 belongs to the night before. Entering again the same night adds nothing |
| Panel | `house.kicker`, `house.title`, then `house.text` (or the last result), then `house.visits` with n = nights so far (x04) |
| Bets | One button per entry in `bets` (5, 10, 20): `house.bet` with n. If coins < bet the button is replaced by `house.not_enough` (x07) |
| Roll | Win chance `win_chance_percent`. Win: coins + bet, text `house.won` (x05). Lose: coins − bet, text `house.lost` (x06). Coins never below 0. Trust does not change from betting |
| Leave | `house.leave` returns to the market map at the Inn |

## 5. Talk that builds up (masters x09-x11)

| Nights | What people say line (`say`) | Trust |
|---|---|---|
| 1 | none | none |
| `talk_from_visits` (2) to 3 | `say.talk` (mixed) (x09) | none |
| `seen_from_visits` (4) to 9 | `say.seen` (bad) (x10) | `seen_trust` (−5), once, on entering the 4th night |
| `gambler_from_visits` (10) or more | `say.gambler` (bad) (x11) | `gambler_trust` (−10) more, once, on entering the 10th night |

Only one dice line shows at a time (the highest reached). Its place in What people say: after the LOCK 4 market-stall lines and before the LOCK 10 sealed-purse line. Trust stays 0-100.

## 6. Masters

| Master | Shows |
|---|---|
| x01 | Inn in the day: no dice button |
| x02 | Inn after Isha, not yet invited: `inn_invite` |
| x03 | Mansur's invitation |
| x04-x07 | First night; won 10; lost 20; not enough coins |
| x08, x12 | Inn bar after the invitation (after leaving; after "Go to bed") |
| x09-x11 | What people say after 2, 4 and 10 nights |

HUD numbers in x07 (coins 7) and x09-x11 (nights set directly, start trust 45) were set for the picture - the rules above decide real values. In x02 and x11 the Isha call message was showing when the picture was taken and is not part of this LOCK.

## 7. Not in this LOCK (do not build)

Idris growing cooler and the game slowing (Founder 6 Nov - a later LOCK), the inspector's raid, Mansur's loans with increase (riba), Yusuf losing the healer's money, wine smuggling, stolen animals, other gambling games, a Mansur capsule walking routes (he is named in text only), sleeping or skipping time.

## 8. Build rules

Words and numbers only from `dice_house_data_V1.json` (copied byte for byte to `SOURCE/data/dice_house.json`) and the earlier data files. The roll uses the engine's random number; tests must be able to force a win or a loss. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 11. Founder 6 Nov: "we can do somethign in game wher you can be offered backstreet or hidden gamble houses where you can gamble and actually win but again its somethign wrong" and the build-up rule; 8 Nov: **"LOCK it (Recommended)"** after V47 |
