---
id: DOC-TFG-0021
type: SPEC
status: CURRENT
feature: MARKET_STALL
purpose: LOCK 4 - the market stall (shop) at the spice row, your bag, the extra change, bread for Faris - closes ROADMAP "Tasks and money"
links: [AD-AIOS-115, AD-AIOS-131, DOC-TFG-0006, DOC-TFG-0011, DOC-TFG-0017, DOC-TFG-0022]
owner: THE FOUR GATES chat
---

# MARKET STALL SPEC — CURRENT VERSION V1 (LOCK 4)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `market_stall_data_V1.json` beside this file - the only source for every word and number of this LOCK (exported from the prototype's own data object; all 15 masters' text checked against the data files: 0 missing) |
| Builds on | LOCK 1 V2 (coins, trust, places), LOCK 2 V3 (clock, days), LOCK 3 V1 (Faris, What people say). Queue line 11 comes after line 10 |
| Masters | `../MASTERS/s01`-`s15` at 1920 × 1080 (content, words, states and positions - not the look) |
| Prototype | "The Four Gates Prototype" V34 |
| ROADMAP | Closes "Tasks and money" (the shop was the missing part) |

## 1. Rules (Founder, 6 Nov 2026)

The game never plays God: the kept change is found out because Rashid counts his box. Trust is a balance: people weigh what they saw.

## 2. The stall (masters s01-s08)

| Rule | Number / words |
|---|---|
| Place | At Spice row the bar's action is `place.spice_button` ("Buy at the stall"), replacing LOCK 1's "Look around" for that place only (s01). Rashid is a capsule with a name label at the spice row |
| Panel | `stall.kicker`, `stall.title`, `stall.intro`, one row per `items` entry: name, line, and "Buy · {n} coins" (`buy`; `buy_one` when n = 1) (s02) |
| Buy | Coins − price; the item goes into the bag (count +1). `once: true` items (local clothes) can be bought once, then the row shows `owned` (s07). Repeatable items show `have` with the count |
| Not enough | If coins < price the row shows `not_enough` (s08) |
| The extra change | The **first** purchase ever: coins + `numbers.change_extra` (5) and the `stall.change` panel (s03): `give_back` → coins − 5, trust + `change_return_trust` (2), stall shows `change.returned` (s04); `keep` → no change that day, stall shows `change.kept` (s05) |
| Found out | If kept: the first time you open the stall on a **later day**, trust + `change_kept_trust` (−3, once) and the stall shows `change.found` (s06) |
| Back | `stall.back` returns to the market map |

## 3. Your bag (masters s09-s11)

| Rule | Number / words |
|---|---|
| Open | Tap the coins box on the HUD (it becomes a button; same look) |
| Panel | `bag.kicker`, `bag.title`, `bag.coins`, one row per item held: name (× count for repeatable items) and the item's `use` line; `bag.empty` when nothing is held (s09, s10) |
| Clothes | `wear` / `take_off` toggles wearing; while worn the coins line adds "Local clothes · wearing" (s11) |
| Back | `bag.back` returns to the market map |

## 4. Bread for Faris (masters s12-s13)

At the Quay, while the bag holds bread, the bar shows `place.quay_feed` (s12). Giving: bread − 1, toast `feed` (s13); trust + `feed_trust` (1) the first time only. Faris is a capsule at the quay.

## 5. What people say (masters s14-s15)

Added after the LOCK 3 lines, in this order: returned → `say.returned`; kept and found out → `say.kept`; bread given at least once → `say.fed`; clothes worn → `say.clothes`. Same row format and tones as LOCK 3.

HUD numbers in s10, s14 and s15 were set for the picture (coins 160; trust 23; trust 17) - the rules above decide real values.

## 6. Not in this LOCK (do not build)

Selling, haggling, other stalls, food or hunger, using dates (Ramadan comes later), how clothes change other people's lines beyond `say.clothes`, Rashid's daily routine.

## 7. Build rules

Words and numbers only from `market_stall_data_V1.json` (copied byte for byte to `SOURCE/data/market_stall.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 4. Fable/Founder 8 Nov (AD-AIOS-131): steady small LOCKs, one ROADMAP row each; Founder clickable "LOCK 4 · Market stall (Recommended)" and **"LOCK it (Recommended)"** |
