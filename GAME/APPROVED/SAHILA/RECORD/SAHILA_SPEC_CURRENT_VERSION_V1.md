---
id: DOC-TFG-0120
type: SPEC
status: CURRENT
feature: SAHILA
purpose: LOCK 37 - Sahila, the fishing shore (town, masjid, people) and chapter 1 mission Sahila's boat with its found-out week later
links: [AD-AIOS-115, DOC-TFG-0111, DOC-TFG-0117, DOC-TFG-0121]
owner: THE FOUR GATES chat
---

# SAHILA SPEC — CURRENT VERSION V1 (LOCK 37)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026 under the Founder's blanket LOCK: "OK INSTEAD OF SHOWING ME 1 BY 1 LETS LOCK IN ALL 100 AND CODEX WILL BUILD WE CAN CHANGE AFTER"; then clickable "Lock all 100 now" - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `sahila_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 34 runner, LOCK 36 roads. Queue line 44 comes after line 43 |
| Masters | `../MASTERS/sh01`-`sh21` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V92 |
| ROADMAP | No row; noted for Fable |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| The game never plays God | Every consequence comes from a person who saw or was told |
| Trust is per place | Trust effects apply to the town the mission is in (LOCK 34) |
| Design reference (not shown in the game) | Bukhari 2079 (buyer and seller who speak the truth and make things clear are blessed) - checked on sunnah.com |
| Scholar check | Set aside by the Founder 9 Nov ("Lock all 100 now") - a post-build action: a seller's agent's duty to disclose a defect |


## Towns

| Id | Name | Gate | Start trust | Inn | Work |
|---|---|---|---|---|---|
| `sahila` | Sahila | trust | 10 | 2 | `Mend nets with Hind · 3 coins` 07:00-15:00, 60 min, +3 coins, +1 trust once a day |

The town hub (LOCK 34 §3) shows the town `kicker`, `name` and `text`, then: open missions, Talk to people, the work button (in its hours, not during Friday prayer), What {town} says, the masjid buttons, the prayer button when a prayer is open, the inn and the road map.

## Masjids

| Id | Button | Rules |
|---|---|---|
| `sahila` | `button` | LOCK 33 rules exactly; counts once toward Masjids you have prayed in; `first` after the first prayer there |

## People

| Id | Name | Role | Hours | First line | Memory (first true wins) |
|---|---|---|---|---|---|
| `mukhtar` | Mukhtar | the old fisherman | 05:00-19:00; away at Friday prayer | `lines` by town trust: wary < 30, friendly < 70, warm | `sahila_honest`, `sahila_lied` |
| `hind` | Hind | the net mender, Mukhtar's daughter | 07:00-16:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `sahila_honest` |
| `ziyad` | Ziyad | a boat trader | 08:00-17:00 | `lines` by town trust: wary < 30, friendly < 70, warm | `sahila_honest`, `sahila_found` |

## Mission `sahila_boat` - Sahila's boat (main story)

Button `button`, shown when: town `sahila` hub; 07:00-18:00; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Agree to sell her` → `b` · - |
| `b` | `Tell him about the soft plank` → `honest` · coins +5; trust +10; flag `sahila_honest`, `sahila_boat_done`; say `honest`<br>`“She's sound”` → `lied` · coins +5; flag `sahila_lied`, `sahila_boat_done`<br>`Say nothing; let him look` → `lied` · coins +5; flag `sahila_lied`, `sahila_boat_done` |
| `honest` | End: Back; mission done |
| `lied` | End: Back; mission done |

What people say lines (`say`): `honest` (good, Ziyad the boat trader) - shown in What Sahila says.

## Mission `sahila_found` - Ziyad's boat (main story)

Button `button`, shown when: town `sahila` hub; after `sahila_lied`; 7 days after `sahila_lied`; once.

| Scene | Choices → next scene · effects |
|---|---|
| `a` | `Admit it and offer to pay` (needs 30 coins) → `paid` · coins -30; trust -5; flag `sahila_found`; say `admitted`<br>`Say you didn't know` → `denied` · trust -15; flag `sahila_found`; say `found` |
| `paid` | End: Back; mission done |
| `denied` | End: Back; mission done |

What people say lines (`say`): `admitted` (mixed, Ziyad the boat trader); `found` (bad, the whole shore) - shown in What Sahila says.

## Masters

- `sh01_sahila__town.png`
- `sh02_sahila__people.png`
- `sh03_sahila__mukhtar_trust_10.png`
- `sh04_sahila__mukhtar_trust_50.png`
- `sh05_sahila__mukhtar_trust_80.png`
- `sh06_sahila__hind_trust_10.png`
- `sh07_sahila__hind_trust_50.png`
- `sh08_sahila__hind_trust_80.png`
- `sh09_sahila__ziyad_trust_10.png`
- `sh10_sahila__ziyad_trust_50.png`
- `sh11_sahila__ziyad_trust_80.png`
- `sh12_sahila__what_people_say_empty.png`
- `sh13_sahila__masjid_prayer.png`
- `sh14_sahila__masjid_first_prayer.png`
- `sh15_sahila_boat__a.png`
- `sh16_sahila_boat__b.png`
- `sh17_sahila_boat__honest.png`
- `sh18_sahila_boat__lied.png`
- `sh19_sahila_found__a.png`
- `sh20_sahila_found__paid.png`
- `sh21_sahila_found__denied.png`

Trust, coins and the clock are set for each picture; other buttons come from earlier LOCKs.

## Not in this LOCK (do not build)

Fishing yourself; buying a boat (owning things comes later).

## Build rules

Words and numbers only from `sahila_data_V1.json` (copied byte for byte to `SOURCE/data/sahila.json`), read by the LOCK 34 runner - no mission or person in code. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 37 under the Founder's blanket LOCK (9 Nov) |
