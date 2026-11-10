---
id: DOC-TFG-0024
type: SPEC
status: CURRENT
feature: CLOTHES
purpose: LOCK 5 - clothes at Layla's loom, the wardrobe in your bag, the leather bag and the carrying limit
links: [AD-AIOS-115, AD-AIOS-131, DOC-TFG-0021, DOC-TFG-0025]
owner: THE FOUR GATES chat
---

# CLOTHES SPEC — CURRENT VERSION V1 (LOCK 5)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `clothes_data_V1.json` beside this file (exported from the prototype's own data object; all 15 masters' text checked against the data files: 0 missing) |
| Builds on | LOCK 4 V1 (bag, Rashid's stall, local clothes) and LOCK 2 V3 (clock, Fridays). Queue line 12 comes after line 11 |
| Masters | `../MASTERS/w01`-`w15` at 1920 × 1080 (content, words, states and positions - not the look) |
| Prototype | "The Four Gates Prototype" V36 |
| ROADMAP | Row "Clothes and inventory" requested from Fable on 8 Nov |

## 1. Rules

Clothes never play God and never change trust: they change only what people say. Founder 8 Nov: "i would want player to be able to by skins - ie clothes and have inventory".

## 2. Layla's loom (masters w01-w05)

| Rule | Number / words |
|---|---|
| Place | At Weaver's lane the bar's action is `place.weaver_button`, replacing LOCK 1's "Look around" for that place only (w01). Layla is a capsule with a name label |
| Panel | `loom.kicker`, `loom.title`, `loom.intro`, then in two columns: the leather bag first, then each `clothes` entry with `seller: "Layla"` - name, line and "Buy · {n} coins" (w02) |
| Buy clothes | Coins − price; the clothes go into the wardrobe (not worn). Each set once; then `owned` (w03) |
| Blocked | Coins < price → `not_enough`; bag full → `full` (w04). The leather bag is never blocked by a full bag |
| Leather bag | Coins − 20; capacity becomes `numbers.leather_bag` (12); then `owned` (w05) |

## 3. Your bag becomes a wardrobe (masters w06-w10) - replaces LOCK 4's wear toggle

| Rule | Number / words |
|---|---|
| Start | You own and wear the traveller's clothes (`start: true`) |
| Header | Kicker "Your bag · Pouch" or "· Leather bag"; line `bag.coins` · `carrying` with n = things carried, m = capacity |
| Clothes | Section `clothes_title`: every owned set, its line, and `wear` (button) or `wearing` (w06, w07). Local clothes bought at Rashid's stall join the wardrobe |
| Things | Section `things_title`: bread and dates with counts and their `use` lines (LOCK 4 data); `bag.empty` (LOCK 4) when none |
| Carrying | Things carried = bread + dates + owned clothes not being worn. Capacity: pouch `numbers.pouch` (6), leather bag 12. When full, `full_note` shows (w08) and buying is blocked at the loom and at Rashid's stall (the stall rows show `loom.full`, w10) |

## 4. What people say (masters w11-w15)

Added after the LOCK 4 lines, for the clothes being worn: local → LOCK 4 `say.clothes`; work → `say.work`; best, on a Friday only → `say.best_friday`; scholar → `say.scholar` (mixed); merchant → `say.merchant` (mixed); silk → `say.silk` (bad). Traveller's clothes add nothing.

Deen sources (checked 8 Nov, web): silk and gold forbidden for men, permitted for women - Tirmidhi 1720, Nasai 5148; dressing well for Friday prayer - Ibn Majah 1095, Bukhari 886. This LOCK has the boy's version only; the girl's version comes with the boy-or-girl LOCK.

HUD coins in w06-w10 were set for the picture.

## 5. Not in this LOCK (do not build)

The 3D look of each outfit (comes with a real character), selling or dropping things, storage, the scholar's cloak opening the House of Learning, the merchant's coat bringing partnerships, Eid, saddlebags and animals.

## 6. Build rules

Words and numbers only from `clothes_data_V1.json` (copied byte for byte to `SOURCE/data/clothes.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 5. Founder 8 Nov: "yeh in the game i would want player to be able to by skins - ie clothes and have inventory ..."; clickable "Clothes + bigger bag (Recommended)"; **"LOCK it (Recommended)"** |
