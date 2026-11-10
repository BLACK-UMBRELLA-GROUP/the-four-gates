---
id: DOC-TFG-0105
type: SPEC
status: CURRENT
feature: GATE_OF_TRUST
purpose: LOCK 32 - chapter 1 beyond the walls - the Gate of Trust opens at trust 100 after the scales lesson, the 90-minute road east, Jisra (bridge of boats) with its own trust starting at 10, and the first Jisra scene "One coin and three" (Hamid's unfair toll)
links: [AD-AIOS-115, DOC-TFG-0006, DOC-TFG-0017, DOC-TFG-0033, DOC-TFG-0063, DOC-TFG-0106]
owner: THE FOUR GATES chat
---

# GATE OF TRUST SPEC — CURRENT VERSION V1 (LOCK 32)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `gate_of_trust_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (the gate rule: trust 100 + the scales lesson; towns), LOCK 2 (prayer), LOCK 8 (prayer record), LOCK 18 (clock and date). Queue line 39 comes after line 38 |
| Masters | `../MASTERS/gj01`-`gj12` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V89 (draft) / V90 (locked) |
| ROADMAP | No row for the world beyond River Market; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| Trust is earned per place | Jisra has its own trust; River Market trust is kept unchanged and shown again on return |
| The game never plays God | No reward line for speaking up; the outcome is shown, nothing is judged |
| Justice over charity | Paying the family's toll helps once; the injustice stays (the text says so) |

Design reference (not shown in the game): Muslim 49 (sunnah.com/muslim:49 - changing a wrong with the hand, the tongue, then the heart). Scholar check (open): speaking up to an official in public.

## 2. The gate bar (masters gj01, gj10, gj11)

At the Gate of Trust only, when River Market trust = 100 **and** the scales lesson is learned:

| State | Bar button |
|---|---|
| Gate not yet opened | `gate_open_button` (gj01) |
| Gate opened before | `road_button` (gj10) |
| Trust below 100 or lesson not learned | nothing new; the LOCK 1 gate bar as before (gj11) |

## 3. The opening (master gj02)

Panel `opening` (kicker, title, text) with `go` (the road east) and `no` (back to the gate). Opening the gate is remembered for good.

## 4. The road (masters gj03, gj10)

`road_button` / `opening.go`: the clock moves `travel_minutes` (90) with the normal advance rule (LOCK 18; prayers whose time ends during the walk follow LOCK 8 as for any wait), then Jisra. `jisra.back`: the clock moves 90 again and you stand at the Gate of Trust in River Market.

## 5. Jisra (masters gj03, gj06, gj09)

Panel `jisra` (kicker, title, text). Buttons: `watch` (only until the toll scene is played), the LOCK 2 prayer button when a prayer time is open (prayed here counts as prayed alone, no masjid in Jisra yet), `back`.

The trust meter label is `jisra.meter` and shows Jisra trust, starting at `jisra_start` (10), capped at 100. Coins and the clock are the same everywhere.

## 6. One coin and three (masters gj04, gj05, gj07, gj08, gj12)

Panel `toll` (kicker, title, text). Once only:

| Choice | Effect | Panel text |
|---|---|---|
| `speak` | Jisra trust + `speak_trust` (5) | `out_speak` (gj05) |
| `pay` (only with ≥ `pay_coins` 3 coins; hidden otherwise, gj12) | Coins − 3; Jisra trust + `pay_trust` (3) | `out_pay` (gj07) |
| `quiet` | Nothing changes | `out_quiet` (gj08) |

Then `to_town` back to Jisra; `watch` is gone (gj06).

## 7. Masters

| Master | Shows |
|---|---|
| gj01-gj03 | Gate button at trust 100; the opening; Jisra at 10:30, Trust · Jisra 10 / 100 |
| gj04-gj06 | The toll; spoke up (15); Jisra after the toll |
| gj07, gj08 | Paid their toll (195 coins, 13); said nothing (10) |
| gj09, gj10 | Pray Dhuhr in Jisra; back at the gate at 13:50 with "Trust · River Market" and the road button |
| gj11, gj12 | Trust 99, no gate button; 2 coins, no pay choice |

Coins 198 set for the pictures. The clock shows the LOCK 18 date.

## 8. Not in this LOCK (do not build)

Jisra's people, masjid, task board and What people say; Sahila's boat and Sukara (scholar check open); a world map; travelling at night; the masjids-visited goal (Founder 8 Nov, not locked); Hamid as a recurring character.

## 9. Build rules

Words and numbers only from `gate_of_trust_data_V1.json` (copied byte for byte to `SOURCE/data/gate_of_trust.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 32. Founder 9 Nov clickable "Open the Gate of Trust (Recommended)"; then **"LOCK it (Recommended)"** after V89 |
