---
id: DOC-TFG-0006
type: SPEC
status: SUPERSEDED
feature: FOUNDATIONS
purpose: LOCK 1 - game design foundations (game shape, first area, engine and look rule, numbers) - what Codex builds the first playable greybox from
links: [AD-AIOS-115, AD-AIOS-122, DOC-TFG-0007, DOC-TFG-0001]
owner: THE FOUR GATES chat
---

# FOUNDATIONS SPEC — ARCHIVED 2026-11-06 — V1 (LOCK 1)

> ARCHIVED 2026-11-06, replaced by `RECORD/FOUNDATIONS_SPEC_CURRENT_VERSION_V2.md`. Reference only.

| Field | Value |
|---|---|
| LOCKed | 6 Nov 2026, Founder (clickable): "LOCK it, lesson required (Recommended)" - see `LOCK_RECORD.md` |
| Masters | `../MASTERS/f01…f21` (1920 × 1080) |
| Words and numbers | `foundations_data_V1.json` beside this file - **the only source for every word and number**. Copy it byte for byte into the game; never retype it |
| Prototype | "The Four Gates Prototype" V10 (Artifact), the THE FOUR GATES chat's tap-through page |

## 1. What the masters are (read first)

The masters show **content, order, words, numbers, states and where things sit**. They are drawn in a web prototype. They
are **not** the look of the game: Shakeel decided on 6 Nov 2026, "lets build gameplay in gadot but the visual aint
importantn and move over once we are ready for unreal engine". So in Godot: simple shapes (boxes, capsules, planes) and
flat colours only, no art pass, no imported art. Judge the build on how it plays.

The street-view pictures in the masters (f01, f06–f14, f18, f19, f21) use the old look-test images as backgrounds.
**Do not copy those backgrounds.** In Godot the 3D world behind the panel is the background.

## 2. Game shape (Founder, 6 Nov: "A · Four Gates journey (Recommended)")

| Part | Rule |
|---|---|
| Loop | Take a task from the task board → choose the honest way or the quick way → earn coins and trust → learn a skill (the scales lesson) → when trust is full and the lesson is done, the quarter's gate opens |
| Goal (whole game) | Be trusted by all four quarters of the round city and open all four gates (Khurasan, Basra, Kufa, Syrian). This slice builds the first: River Market and the Khurasan Gate |
| Values | Taught only through choices and results. Never a lecture, never religious words or symbols, never the two words banned by the AGENTS.md wording rule |

## 3. Engine and look (Founder, 6 Nov - quoted in §1)

| Rule | Detail |
|---|---|
| Engine now | Godot 4 (the existing `SOURCE/` project) for gameplay |
| Look now | Placeholder: simple shapes and flat colours. No textures, no imported models, no lighting polish beyond a sun, a night setting and lantern point lights |
| Later | The game moves to Unreal when Shakeel is ready. So every word, number, place and task lives in the data file, and scripts read it - no words or numbers written into scenes or scripts |

## 4. River Market - Gate street layout (Founder, 6 Nov: "A · Gate street (Recommended)")

Area 160 × 90 m. Units: metres, x east, z south, origin at the north-west corner. Ground level y = 0.

| Point | x | z | What |
|---|---:|---:|---|
| `gate` | 127.2 | 6.4 | Khurasan Gate |
| `a1` | 120 | 19.2 | street point |
| `sq` | 94.4 | 38.4 | street point |
| `board` | 84.8 | 33.6 | Task board |
| `scales` | 104 | 44 | Market scales |
| `a2` | 70.4 | 56 | street point |
| `quay` | 52.8 | 73.6 | Quay |
| `pier` | 100 | 73.6 | street point |
| `sp1` | 136 | 24 | street point |
| `spice` | 149.6 | 28 | Spice row |
| `weaver` | 41.6 | 38.4 | Weaver’s lane |
| `centre` | 4.8 | 38.4 | To the central square |

| Element | Number |
|---|---|
| Streets (walkable paths between points) | gate–a1, a1–sq, sq–board, sq–scales, sq–a2, a2–quay, quay–pier, a1–sp1, sp1–spice, sq–weaver, weaver–centre |
| Street width | 4.8 m |
| Market square | circle around `sq`, radius 9.6 m |
| City wall | along the north edge, z 0–4 m, 6 m high, with the gatehouse at the `gate` point (gatehouse 17.6 m wide; arch 6.4 m wide, closed by a gate until it opens) |
| Quay | strip z 74.4–78.4 m along the south edge |
| Canal | z 78.4–90 m, water level y = −1 m, not walkable |
| Buildings | Everything that is not street, square, quay or canal is blocks of houses: boxes 6–9 m high, gaps no wider than 1 m, so the player stays on the streets |
| Start | The player starts at `quay`, facing north up the street toward the gate |
| West exit | `centre` is blocked by a closed passage; using it shows the "central square" line |
| Lanterns | One lantern point light at the middle of every street, lit only at night |

## 5. Player, camera and controls (standard defaults set by the THE FOUR GATES chat under LOCK 1; Shakeel may change any)

| Item | Number |
|---|---|
| View | Third person, character in the lower centre of the screen |
| Character | Capsule 1.8 m tall, radius 0.4 m |
| Walk / run | 4 m/s / 7 m/s (hold Shift) |
| Steps | Climbs steps up to 0.4 m |
| Camera | 4.5 m behind, 1.7 m above the feet; mouse turns it; tilt −40° to +20°; pulls in when a wall is in the way |
| Keys | W A S D move · mouse look · Shift run · **E** use the place you are standing at · **M** market map · **G** goal screen · **T** wait until night / day · Esc close panel |
| Using a place | Within 2.5 m of a place point, the bottom bar shows the place name, its line and the action button (master f05). E or a click does the action |

## 6. Screens and states (match each master)

| Master | Screen / state | Rule |
|---|---|---|
| f01 | Title | `title_screen` words. Begin → game at the quay. Settings → its toast |
| f02 / f20 | City map (from the market map) | `city_map` words; gate tags; tapping a gate shows its message; the Khurasan Gate turns green only when open |
| f03 / f04 | Market map (M), day / night | Top-down plan of §4 with the player marker; buttons: City map, Wait until night/day, the place bar |
| f05 | Standing at a place | Bottom bar: place name · line · action. Actions: Task board → "Read the board"; Market scales → "Learn the scales" (after the lesson "Check the scales"); Khurasan Gate → "Ask the gatekeepers"; To the central square → "Go"; others → "Look around" (in Godot: no action, the player is already looking) |
| f06 | Task board, start | The three tasks + the daily job; "Take it · n coins" |
| f07 | A task | Story + two choices (honest first, quick second) + "‹ Not now" |
| f08 / f09 | Result, honest / quick | Label, result line, "+coins", "±trust", Back to the board, See your goal |
| f10 | Board after quick choices | Each quick task shows "done the quick way" and its "Put it right" row (cost, trust it gives back); a row the player cannot afford shows "need n coins" |
| f11 | Daily job done | "come back tomorrow" until the next morning (T from night to day) |
| f12–f14 | Scales lesson | Three weights; trying a weight tilts the scale (only weight 2 is false); the answer button names the tried weight; right answer → +25 trust, the lesson is done, back to the street with the `win` line |
| f15 / f16 / f17 | At the gate | Gate messages: needs trust / needs the lesson / open. The gate opens only when trust = 100 **and** the lesson is done |
| f18 / f19 | Goal screen (G, or the trust bar) | Four gates with bars; the gate rule line |
| f21 | Street view | Prototype only - not built (the 3D world replaces it) |
| HUD (all) | Coins top left; "Trust · River Market n / 100" with a bar top right |

## 7. Numbers (Founder, 6 Nov: "Both" and "LOCK it, lesson required (Recommended)")

| Rule | Number |
|---|---|
| Start | 20 trust, 0 coins |
| Trust range | 0 to 100 (never below 0, never above 100) |
| Gate | 100 trust **and** the scales lesson done |
| Scales lesson | +25 trust, once |
| Daily job | Unload a boat at the quay: +5 trust, +2 coins, once a day |

| Task | Shown pay | Honest | Quick | Put it right (appears only after the quick way) |
|---|---:|---|---|---|
| Carry spice to the river quay | 6 | +15 trust · +4 coins | -10 trust · +6 coins | Make it right with the spice seller: costs 6 coins, gives back the trust actually lost + 15 |
| Look for a lost purse | 3 | +20 trust · +3 coins | -20 trust · +20 coins | Return the weaver’s purse: costs 20 coins, gives back the trust actually lost + 20 |
| Help the scale-keeper | 5 | +20 trust · +5 coins | -15 trust · +5 coins | Own up to the scale-keeper: costs 5 coins, gives back the trust actually lost + 20 |

"Trust actually lost" = trust before the quick choice minus trust after it (after the 0 floor). Checks that must hold:
all honest + lesson = exactly 100 trust and 12 coins; all quick + all amends = 75 trust and 0 coins; + lesson = 100.

## 8. Must not change

- Words and numbers come only from `foundations_data_V1.json`.
- Honest choice listed first, quick second, in every task.
- The gate never opens without the lesson.
- No religious words, signs or symbols; never the two words banned by the AGENTS.md wording rule.
- No art pass, no imported or paid assets (public repo, Apache 2.0).

## 9. Not decided (do not build)

Real art and the Unreal move · characters you can talk to (ROADMAP "Characters and dialogue") · the shop (ROADMAP
"Tasks and money" mentions one) · saving · the other three quarters and the central square · sound · how long a day lasts
(for now T switches day and night) · what is beyond the gate (opening it ends the slice with its message).

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-06 | V1 | LOCK 1. Founder, clickable, 6 Nov 2026: "A · Four Gates journey (Recommended)", "A · Gate street (Recommended)", engine path in his typed words (§1), "Both", "LOCK it, lesson required (Recommended)". The earlier "A · Warm storybook (Recommended)" look choice was withdrawn by the engine decision |
