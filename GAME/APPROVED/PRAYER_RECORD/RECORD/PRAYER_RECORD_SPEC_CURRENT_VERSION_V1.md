---
id: DOC-TFG-0033
type: SPEC
status: CURRENT
feature: PRAYER_RECORD
purpose: LOCK 8 - all your prayers - private all-time prayer totals on the title screen and under today's record
links: [AD-AIOS-115, DOC-TFG-0011, DOC-TFG-0034]
owner: THE FOUR GATES chat
---

# PRAYER RECORD SPEC — CURRENT VERSION V1 (LOCK 8)

| Field | Value |
|---|---|
| Locked | 8 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `prayer_record_data_V1.json` beside this file (exported from the prototype's own data object; 6 masters' text checked: 0 missing) |
| Builds on | LOCK 2 V3 prayer record ("Your prayers", statuses `jamaah`, `alone`, `dhuhr_fri`, `missed`, `madeup`). Queue line 15 comes after line 14 |
| Masters | `../MASTERS/r01`-`r06` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V42 |
| ROADMAP | No row (faith in play); noted for Fable |

## 1. Founder's words

"id want in the game like in start meni or wahetver a place t oshow how many times user prayed or missed prayer and if prayed prayed in congragtion / masjid / alone" (8 Nov 2026).

## 2. Where it is (masters r01, r04)

- Title screen: a `title_button` ("Your prayers") between Begin and Settings (r01).
- Today's record (LOCK 2, tap the clock): a second button `record_button` ("All your prayers") beside "Back to the market" (r04).

## 3. The panel (masters r02, r03, r05, r06)

| Rule | Number / words |
|---|---|
| Header | `panel.kicker`, `panel.title` |
| Empty | Before any prayer has a status: `panel.empty` (r02) |
| Rows, in this order | `on_time` = jamaah + alone at the masjid + alone elsewhere (all `alone` and `dhuhr_fri` prayers); indented beneath it: `jamaah`, `alone_masjid`, `alone_elsewhere`; then `friday` (jamaah on a Friday's Dhuhr), `dhuhr_fri`, `madeup`, `missed` (still missed). Each row shows its count (`count`) on the right |
| Note | `panel.note` |
| Buttons | Opened from the title: `back_title` (r02, r03). Opened from the record: `back_market` and `today` (back to today's record) (r05, r06) |
| No score | Counts only - no streaks, stars, coins or trust |

## 4. Change to LOCK 2

When a prayer is prayed on your own (`alone` or `dhuhr_fri`), the game also remembers where: at the Masjid → masjid, anywhere else → elsewhere. Congregation is always at the masjid.

## 5. Not in this LOCK (do not build)

Charts, per-week views, comparing with others, any reward or message about the totals, the girl's version (comes with the boy-or-girl LOCK).

## 6. Build rules

Words only from `prayer_record_data_V1.json` (copied byte for byte to `SOURCE/data/prayer_record.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-08 | V1 | LOCK 8. Founder 8 Nov: words in §1, then **"LOCK it (Recommended)"** after V41 |
