---
id: DOC-TFG-0184
type: SPEC
status: CURRENT
feature: SIDE_WATER_SELLER
purpose: LOCK 58 - River Market side mission - the overcharging water seller
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0185]
owner: THE FOUR GATES chat
---

# SIDE WATER SELLER SPEC — CURRENT VERSION V1 (LOCK 58)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `side_water_seller_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner and the River Market places and regulars. Queue line 65 comes after line 64 |
| Masters | `../MASTERS/sj01`-`sj04` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2358 (withholding surplus water from travellers) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: none |



## Mission `water_seller` - The overcharging water seller (side mission)

Button `button`, shown when: River Market place `gate`; 10:00-17:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Fetch Nasir the market inspector` → `nasir` · trust +6; say `reported`<br>`Buy water for the woman · 2 coins` (needs 2 coins) → `buy` · coins -2; trust +3; say `bought`<br>`Not your business` → `out` · - |
| `nasir` | End: Back; mission done |
| `buy` | End: Back; mission done |
| `out` | End: Back; mission done |

What people say lines (`say`): `reported` (good, Nasir the inspector); `bought` (good, the gate) - shown in River Market What people say.

## Masters

- `sj01_water_seller__a.png`
- `sj02_water_seller__nasir.png`
- `sj03_water_seller__buy.png`
- `sj04_water_seller__out.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Anything not written above.

## Build rules

Words and numbers only from `side_water_seller_data_V1.json` (copied byte for byte to `SOURCE/data/side_water_seller.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 58 under the Founder's blanket LOCK (9 Nov) |
