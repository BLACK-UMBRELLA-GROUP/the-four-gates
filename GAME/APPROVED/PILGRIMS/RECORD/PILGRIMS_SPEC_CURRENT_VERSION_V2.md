---
id: DOC-TFG-0081
type: SPEC
status: CURRENT
feature: PILGRIMS
purpose: LOCK 24 - lifetime goals, pilgrims you send - paying Abbas to send Old Musa, Yunus or Jamal on Umrah and Idris on Hajj, their return, the 1,000 / 100 counters
links: [AD-AIOS-115, DOC-TFG-0017, DOC-TFG-0039, DOC-TFG-0063, DOC-TFG-0082]
owner: THE FOUR GATES chat
---

# PILGRIMS SPEC — CURRENT VERSION V2 (LOCK 24)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"**; V2 the same day, Founder clickable **"Show nothing (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `pilgrims_data_V2.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 3 (giving in secret after page 1; What people say), LOCK 6 (Old Musa, Jamal), LOCK 10 (Abbas at the Gate of Trust), LOCK 18 (calendar months). Queue line 31 comes after line 30 |
| Masters | `../MASTERS/b01`-`b11` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V76 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything (Founder, 6 Nov 2026)

| Rule | Meaning in this LOCK |
|---|---|
| "side mission - pay for 1000 umrah trips pay for 100 hajj trips" | Lifetime counters `goal_umrah` (1,000) and `goal_hajj` (100) |
| "Send others only" | The player never goes; Makkah is never shown |
| Secret giving earns no visible trust (LOCK 3) | A secret trip gives no trust |

Design references (not shown in the game), checked on sunnah.com: Quran 3:97; Sahih al-Bukhari 1773.

## 2. The gate button (masters b01, b11)

At the Gate of Trust from `from` (420 = 07:00) until before `until` (1080 = 18:00): `gate_button`. Not at night (b11).

## 3. The panel (masters b02-b05, b07, b09, b10)

`panel.kicker`, `panel.title`, `panel.text`, then one compact row per `pilgrims` entry in order: name · `kind_umrah`/`kind_hajj`, the line below, and on the right:

| State | Right side |
|---|---|
| Sent and on the road | `panel.away` (n = days until home) |
| Home | `panel.home` |
| Hajj outside its window | `panel.hajj_closed` (b09) |
| Coins < cost | `panel.not_enough` (b10) |
| Otherwise | `panel.send` (n = `umrah_cost` 40 or `hajj_cost` 120) |

Then the secret row (`secret_label` tick box after page 1, else `secret_locked`), then one line with `counter` (n = Umrah trips paid, m = 1,000) · `counter_hajj` (n, m = 100) and the `back` button on the same line. The whole panel fits the screen with the back button visible.

## 4. Sending

| Rule | Number / words |
|---|---|
| Umrah | Coins − 40; home on the day sent + `umrah_days` (30) |
| Hajj window | 1 Shawwal (`hajj_book_from_month` 9) to 25 Dhu al-Qa'dah (`hajj_book_until_month` 10, `hajj_book_until_day` 25) |
| Hajj | Coins − 120; home on the next 25 Dhu al-Hijjah (`hajj_back_month` 11, `hajj_back_day` 25) |
| Secret | Fixed when sent (tick box on and page 1 read) |
| Each person | Once in this LOCK |

## 5. Coming home (masters b05, b06, b08)

The first time the game is on or after the home day: home; public trip → trust + `return_trust` (2); secret → no trust. What people say then shows the person's `say` line for a public trip (good, b06), after the LOCK 20 line. **A secret trip leaves no line** (b08), the same as all other secret giving (V2).

## 6. Masters

| Master | Shows |
|---|---|
| b01 | Gate at 10:00 on 2 Shawwal: the button |
| b02-b05 | All open; Old Musa sent; Idris sent (home in 82 days); Old Musa home |
| b06 | What people say: "Sent Old Musa on Umrah" |
| b07, b08 | Secret ticked; What people say after Yunus came home in secret: no line |
| b09-b11 | Hajj closed in Ramadan; not enough coins (30); no Abbas at night |

Coins (300) and trust (45) set for the pictures. Other bar items come from earlier LOCKs.

## 7. Not in this LOCK (do not build)

Going yourself, Makkah shown, other caravan masters, wells and rest stops, pilgrims from other quarters and towns, Hajj al-badal, pilgrims' stories beyond the What people say line.

## 8. Build rules

Words and numbers only from `pilgrims_data_V2.json` (V2, copied byte for byte to `SOURCE/data/pilgrims.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V2 | Founder clickable "Show nothing (Recommended)" (asked after the LOCK: a secret trip showed "Someone sent Yunus on Umrah", unlike secret feeding). Secret trips now leave no What people say line; data V2 removes every `say_secret`; master b08 replaced (`b08_people_say__secret_no_line`). Nothing else changes; queue line 31 builds V2 |
| 2026-11-09 | V1 | LOCK 24. Founder 6 Nov: "side mission - pay for 1000 umrah trips pay for 100 hajj trips", "Send others only"; 9 Nov: **"LOCK it (Recommended)"** after V73 |
