---
id: DOC-TFG-0011
type: SPEC
status: SUPERSEDED
feature: IDENTITY
purpose: LOCK 2 - the game's identity (the traveller, Ilmara and its four virtue gates, five city parts, open field, Idris, learning the language, the arrival, the day and prayer clock) and the LOCK 1 words it renames
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0012, DOC-TFG-0001]
owner: THE FOUR GATES chat
---

# IDENTITY SPEC — ARCHIVED 2026-11-08 — V3 (LOCK 2)

> ARCHIVED 2026-11-08, replaced by `RECORD/IDENTITY_SPEC_CURRENT_VERSION_V4.md`. Reference only.

| Field | Value |
|---|---|
| LOCKed | 6 Nov 2026, Founder (clickable): "LOCK it (Recommended)" - see `LOCK_RECORD.md` beside this file |
| Words and numbers | `identity_data_V3.json` beside this file - the only source for every word and number. Checked against the visible text of every master (all 30) before queuing |
| Builds on | LOCK 1 V2 (`GAME/APPROVED/FOUNDATIONS/RECORD/`). LOCK 1 is built first (queue lines 2-4); this LOCK's lines come after |
| Masters | `../MASTERS/g01`–`g30` at 1920 × 1080 (content, words, states and positions - not the look) |
| Prototype | "The Four Gates Prototype" V29 |

## 1. The look (unchanged)

Placeholder shapes in Godot; the realistic look comes later in Unreal (Founder, 6 Nov). The masters' street pictures are
stand-ins - do not copy them.

## 2. Identity (Founder's words, 6 Nov - in `GAME/OVERVIEW/Summary.md`)

| Piece | Rule |
|---|---|
| The traveller | A boy or girl from a far-away, richer land - better off, not very rich - who comes to help poorer people with their wealth and to seek knowledge, learning how to help well (V3; Founder: "Both (Recommended)"); dressed differently; does not speak the language. The boy/girl choice is recorded here; its screen is designed later |
| City | **Ilmara** (say it IL-mah-rah; say it IL-mah-rah · made up, from ‘ilm (“knowledge”)) |
| Gates | North **Gate of Patience** · East **Gate of Trust** · South **Gate of Mercy** · West **Gate of Knowledge**. River Market's gate is the Gate of Trust |
| Outside | An open field with small towns without walls, reached by roads from the gates. The 12 towns on the world map are **placeholders** (names and places designed later) |
| Teacher | **Idris, the imam** of the River Market masjid. He teaches by sharing and stories, never by lecturing |
| Language | A word the traveller has not learned shows in the town's language, in a different colour; once learned it shows in English with the town word after it in brackets |

| City part | Name | Line |
|---|---|---|
| centre | Centre | The great masjid, the house of learning and the governor’s palace. The heart of the city. |
| east | East · River Market | Docks, traders and the inn. You land here and take a room on the edge of the market, inside the walls. |
| north | North | Gardens, orchards and the caravanserai where travellers rest. |
| west | West | Craftspeople: paper makers, bookbinders and potters. |
| south | South | Homes, wells, and the animal market where farmers bring their goods. |

## 3. Arrival (Founder, 6 Nov: "A · Wrong coins (Recommended)")

| Rule | Number / words |
|---|---|
| Start | Day 1 (Thursday) 06:30 at the River Market quay; 0 coins until the money-changer |
| Money-changer | Fair changer (open scale): **200 coins**. Smiling changer: **120 coins** (the cheat) (V3; Founder: "Bigger purse now") |
| Inn | **2 coins a night**, bread included. "Rest until morning" wakes you at 04:40; with no coins and no paid night you sweep the stable instead |
| Cheat found out | If you used the smiling changer, passing the scales lesson shows the `cheat_found_after_lesson` line instead of the lesson's normal line |
| Beats | `arrival.beats` - text, choices, effects (coins, fair, time) and replies, in order (masters g02–g10) |
| End | "Meet the old man" opens Idris's meeting; "Walk River Market" starts at the Inn |

## 4. Day and prayer clock (Founder, 6 Nov: "C · Game clock + real reminder (Recommended)"; reminder parked: "No no no setting no nothing")

One game day = 48 real minutes. Fixed spring day for now. Night: before 05:30 and from 18:40.

| Prayer | Begins | Ends | Iqamah after adhan |
|---|---|---|---|
| Fajr | 04:45 | 06:05 | 20 min |
| Dhuhr | 12:05 | 15:30 | 15 min |
| Asr | 15:30 | 18:10 | 15 min |
| Maghrib | 18:10 | 19:30 | 5 min |
| Isha | 19:30 | 04:45 | 15 min |

| Rule | Detail |
|---|---|
| Friday | Dhuhr becomes "Friday prayer", iqamah 30 min after the adhan (sermon first). **Friday prayer is only prayed in congregation at the masjid: away from it, or after its congregation time, the button is "Pray Dhuhr here" and a man's record shows "missed Friday prayer · prayed Dhuhr"** (V2) |
| Congregation | At the masjid from the adhan until 5 minutes after the iqamah; elsewhere or later: "Pray {prayer} here" (key P). Praying takes 10 game minutes |
| Missed / made up | A prayer not prayed before its time ends is missed; a prayer whose time ended before the game started is not counted. A missed prayer can be made up (button "Make up {prayer}") |
| Record | "Your prayers" (tap the clock): private; **prayer gives no coins and no trust** |
| HUD | Centre top: weekday · time, then next / now / done line (masters g15, g20, g21, g24) |
| Replaces | LOCK 1's T day/night switch: T is now "Wait until next prayer"; day and night follow the clock |
| Not in this LOCK | The real-life prayer reminder (parked) |

## 5. River Market additions (layout points, metres, same axes as LOCK 1)

| Place | x | z | Joined to | Line |
|---|---:|---:|---|---|
| Inn | 36.8 | 66.4 | quay | Your room by the quay. Bread included. |
| Masjid | 68.8 | 23.2 | sq (the square) | The adhan is called from its roof five times a day. |

Masjid actions: pray (when a prayer is on), "Sit a while" before you have met Idris (opens the meeting), "Look inside" after.

## 6. The first meeting with Idris (masters g25–g29)

Four beats from `teacher.beats`; each choice may teach one word (`learns`). A word shows in the town's language until
learned, then in English with the town word in brackets. The counter "words you know" goes up. End line: the invitation
back after Isha.

## 7. LOCK 1 words this LOCK renames (apply to `SOURCE/data/foundations.json` after lines 2-4)

| LOCK 1 | LOCK 2 |
|---|---|
| Khurasan Gate | Gate of Trust |
| The heart of the round city. | The heart of Ilmara. |
| Be trusted by all four quarters of the round city and open all four gates. | Be trusted by all four quarters of Ilmara and open all four gates. |
| Open all four gates. Each one leads out to a region beyond the walls. | Open all four gates. Each one leads out to the open field and its towns. |
| The Khurasan Gate needs 100 trust and the market scales lesson. | The Gate of Trust needs 100 trust and the market scales lesson. |
| goal.gates | [["Gate of Trust","River Market trust"],["Gate of Patience","North trust"],["Gate of Mercy","South trust"],["Gate of Knowledge","West trust"]] |
| city_map (whole section) | replaced by city and world below; the old round-city map (masters f02, f20) is retired |
| numbers.start_coins = 0 | the arrival sets the coins (20 or 12, minus the first night at the inn) |
| keys.wait_day_night = T and the night/day switch | replaced by the clock: T = "Wait until next prayer"; day and night follow the clock |
| ui.buttons.wait_night / wait_day | ui.buttons.wait_prayer |

## 8. Masters

| File |
|---|
| `g01_title__ilmara.png` |
| `g02_arrival__dawn_quay.png` |
| `g03_arrival__quay_reply.png` |
| `g04_arrival__money_changers.png` |
| `g05_arrival__fair_changer.png` |
| `g06_arrival__smiling_changer.png` |
| `g07_arrival__inn.png` |
| `g08_arrival__sunset_adhan.png` |
| `g09_arrival__end_fair.png` |
| `g10_arrival__end_cheated.png` |
| `g11_world_map.png` |
| `g12_city_map.png` |
| `g13_city_map__district_east.png` |
| `g14_city_map__gate_of_trust_open.png` |
| `g15_market_map__day_inn_masjid_clock.png` |
| `g16_market_map__at_inn_night.png` |
| `g17_market_map__morning_after_rest.png` |
| `g18_market_map__rest_cannot_pay.png` |
| `g19_market_map__masjid_sit_a_while.png` |
| `g20_market_map__asr_adhan_congregation.png` |
| `g21_market_map__pray_here.png` |
| `g22_record__day.png` |
| `g23_market_map__make_up.png` |
| `g24_market_map__friday_prayer.png` |
| `g25_meet__start_unknown_word.png` |
| `g26_meet__new_word.png` |
| `g27_meet__word_to_learn.png` |
| `g28_meet__learned_words_show_english.png` |
| `g29_meet__end.png` |
| `g30_after_lesson__cheat_found.png` |

## 9. Must not change

- Words and numbers only from `identity_data_V3.json` (and the renamed `foundations.json`).
- Prayer never gives coins or trust; the record stays private.
- The gate still needs 100 trust and the scales lesson (LOCK 1).
- Placeholder shapes only; nothing imported or paid.

## 10. Not decided (do not build)

Boy/girl choice screen and its rules (congregation and Friday prayer differ for a girl) · the player's age · wudu ·
the real-life reminder and any settings · seasons and real prayer times · town names and quests · the central square,
North, South and West parts (only their map entries) · fasting days · deals with interest · how the traveller spends his wealth to help (the main story).

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-06 | V3 | Founder, 6 Nov 2026: main story typed ("He came to build a better future in this town by soending his wealth best he can to help pooer people ect. Hes not extremly wealthy but better off"), then clickable "Both (Recommended)" (why he came: help with his wealth and seek knowledge), "Bigger purse now" (fair changer 200, cheat 120) and **"LOCK it (Recommended)"**. Data V3 changes `identity.player`, the two changer coins and replies, `end_fair`, `cheat_found_after_lesson` and the renames note. Masters g05-g10, g15-g17, g30 re-made (coins); all others unchanged |
| 2026-11-06 | V2 | Correction found by the THE FOUR GATES chat while testing (its own mistake in V1): Friday prayer away from the masjid is Dhuhr - V1 allowed "Pray Friday prayer here". Data V2 adds `clock.friday.away_rule`, `pray_here_friday`, `toast_alone_friday` and status `dhuhr_fri`. Nothing else changed; masters unchanged |
| 2026-11-06 | V1 | LOCK 2. Founder, 6 Nov 2026: identity in his words (traveller, world, city parts), "Ilmara (Recommended)", "Four virtues (Recommended)", "C · Idris", "A · Wrong coins (Recommended)", "C · Game clock + real reminder (Recommended)" with the reminder parked ("No no no setting no nothing"), "Drop the word rule" (LOCK 1 V2), and **"LOCK it (Recommended)"** |
