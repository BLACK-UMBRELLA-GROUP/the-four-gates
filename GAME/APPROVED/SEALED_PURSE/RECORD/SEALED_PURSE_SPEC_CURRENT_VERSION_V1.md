---
id: DOC-TFG-0039
type: SPEC
status: CURRENT
feature: SEALED_PURSE
purpose: LOCK 10 - chapter 1, the sealed purse - Karim's job, the coin on the stones, Abbas counting at the Gate of Trust
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0011, DOC-TFG-0030, DOC-TFG-0040]
owner: THE FOUR GATES chat
---

# SEALED PURSE SPEC — CURRENT VERSION V1 (LOCK 10)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `sealed_purse_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (trust, gate), LOCK 2 (quay; Karim is the fair money-changer of the arrival), LOCK 7 (opening hours, Friday prayer). Queue line 17 comes after line 16 |
| Masters | `../MASTERS/h01`-`h10` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V46 |
| ROADMAP | No row (chapter missions); noted for Fable |

## 1. The offer (masters h01, h02, h10)

At the Quay, when River Market trust is at least `offer_from_trust` (40), the job has not been taken, the time is 06:30-18:10 and it is not Friday-prayer time (LOCK 7), the bar shows `quay_button` (h01). Below 40 nothing shows (h10). The panel `offer` (h02): `accept` takes the purse; `refuse` returns to the map (the offer stays).

## 2. The coin (master h03)

Straight after accepting, the `coin` panel: `back_in` → purse whole; `keep` → coins + `kept_coin` (1), purse one short. Both return to the market map at the Task board, with the line `carrying` on every place bar until delivery (h04).

## 3. Delivery (masters h05, h06, h08)

At the Gate of Trust while carrying, the bar shows `gate_button` (h05). Delivering: whole → trust + `honest_trust` (5), coins + `fee` (4), text `deliver.honest` (h06); one short → trust + `kept_trust` (−8), no fee, text `deliver.kept` (h08). Buttons `to_rep`, `to_map`. The job is then done for good.

## 4. What people say (masters h07, h09)

After delivery, `say.honest` or `say.kept` is added before the LOCK 9 line.

Deen link: `deen` - "Allah commands you to render trusts to whom they are due" (Quran 4:58).

## 5. Not in this LOCK (do not build)

Carrying to Jisra or anywhere beyond the gate, Abbas's caravans and pilgrims, Karim's other jobs, the purse being stolen, walking Karim/Abbas capsules on routes (they stand at the quay and the gate).

## 6. Build rules

Words and numbers only from `sealed_purse_data_V1.json` (copied byte for byte to `SOURCE/data/sealed_purse.json`) and the earlier data files. Placeholder shapes only (Karim at the quay, Abbas at the gate as capsules with name labels); no art, no exports.

## Clarifications (11 Nov 2026 review; no change to the LOCK, data or masters)

| Date | QUESTIONS row | Clarification |
|---|---|---|
| 2026-11-11 | — | Masters are pictures with a set-up state: the HUD's weekday, time, date, coins and trust, and bar items or toasts from other LOCKs, are not evidence targets unless this spec names them. A master at "Thursday 10:00" is a set-up time (the live game reaches the market only after the arrival, 18:15 on day 1): test the same state at the same time on a later day that is not a Friday (Friday turns Dhuhr into Friday prayer) |
| 2026-11-11 | — | The order of What people say lines across all LOCKs is `GAME/OVERVIEW/WHAT_PEOPLE_SAY_ORDER_CURRENT_VERSION_V1.md` (DOC-TFG-0321). Where this spec's "before / after" wording differs, that list wins |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 10. Founder 8 Nov: **"LOCK it (Recommended)"** after V45 (chapter 1 mission 5 from the 6 Nov paper design, moved inside the walls) |
