---
id: DOC-TFG-0004
type: GUIDE
status: CURRENT
feature: SOURCE
purpose: Where the Godot 4 project lives and how to open it
links: [AD-AIOS-122]
owner: Codex
---

# SOURCE — the Godot 4 project

The game's Godot 4 project lives here (`project.godot` at this level). Codex creates the empty project in group queue
line 19 and records the exact Godot version below; gameplay is built only from LOCKed designs in `GAME/APPROVED/`.

| Item | Value |
|---|---|
| Engine | Godot 4.7.2.stable.official.ed1daf0bf |
| Language | GDScript |
| Scene format | Text (`.tscn`, `.tres`) |
| Art and sound | `assets/`, each item's source and licence in `assets/CREDITS.md` |

## Play the current greybox

Import `SOURCE/project.godot` in Godot 4.7.2 and press Run, or run `godot --path SOURCE` from the repository root.
The Ilmara title opens first. Begin starts the four arrival beats at the quay with zero coins.
The open scale gives 200 coins and the smiling changer gives 120. Paying for the first night leaves 198 or 118.
The sunset choice moves the clock to 18:15. Walk River Market opens the map at the Inn, Arrive again
restarts the arrival, and Meet the old man opens Idris's meeting at the Masjid.
At the Inn, choose **People are waiting at the door** to open the purse. Ask Salma about the people and
take her page to Idris to learn how to give in secret. **End the day** shows the next morning at 07:00.
The market map and morning panel both open **What people say**.
The game uses placeholder shapes.
LOCK 1 parts 1–3 provide the street layout, collision, capsule player, camera, maps and task board.
Use E at the board to take the three tasks, choose the honest or quick way, earn coins/trust, put quick choices right
and unload a boat once each day. Amends return the trust actually lost plus the honest reward. The job is available
again on the next game day, including after a rest at the Inn. Trust starts at 20 / 100 and stays within 0–100.
Use E at Market scales to try the three weights against the checked weight and name the light one. A correct answer
adds 25 trust once; later visits check the scales. Passing after using the smiling changer reveals the cheat at
the scales. Ask the gatekeepers with 100 trust and the lesson complete to swing the gate open for the session.
Three honest tasks plus the lesson give exactly 100 trust and add 12 coins to the arrival wallet. G or the trust bar
opens the four-gate goal panel. The city map marks the open Gate of Trust green.

At Spice row, use **Buy at the stall** to buy bread, dates or local clothes. The first purchase opens
**Your change**. At Weaver's lane, use **Visit Layla's loom** to buy clothes or the leather bag.
Click the coins box to open **What you carry** and choose **Wear** on an owned outfit. The pouch holds six things
and the leather bag holds twelve. Bread, dates and unworn outfits fill those spaces. Either shop can sell goods
when there is space, and the leather bag upgrade can be bought even when the pouch is full.
At the Quay, **Give bread to Faris** appears
while the bag holds bread. **What people say** shows the resulting reputation lines.

Use **Talk to {name}** at the Task board, Spice row, Weaver’s lane, Quay or Market scales to talk to the local regular.
You can greet each person once and ask for their market tip. **Goodbye** returns to the map. The third different
greeting adds one trust and the **Greets everyone** line in **What people say**.

WASD moves, mouse turns the third-person camera, Shift runs, E uses the nearby place, M opens/closes the market map,
G opens the goal panel, T waits until the next prayer, P prays when available, and Esc closes panels or releases
the mouse. Click the world to capture the mouse again. Map place markers choose a walking route along the approved streets; the player moves
physically. Use Rest until morning at the Inn to spend the prepaid night, pay two coins, or sweep the stable if
the wallet falls short. Each route wakes at 04:40 the next day.

The game starts at 06:30 on Thursday, after the first Fajr window. A day takes 48 real minutes. The clock drives
day and night lighting and announces when prayers begin. Use the Masjid action to pray in congregation during
its window, or use P or the on-screen action to pray where you are. On Friday, the Masjid offers Friday prayer
during congregation. Elsewhere and after congregation, pray Dhuhr. Click the clock to see the private prayer
record. A missed prayer can be made up and prayer leaves coins and trust as they were.

At the Masjid, Sit a while opens the first meeting with Idris at the current game time. Reply to learn town words.
Learned words appear in English with the town word in brackets. Leave or Esc returns to the Masjid on the market map.
Meet him again replays the meeting with the words you learned. After the meeting, the Masjid offers Look inside when
there is no prayer action due.

Open City map from the market map and tap any of Ilmara's five parts for its description. The Inn marker or River Market button returns to the
market map. Open World map from the city map and tap one of the twelve placeholder towns for its description.

`SOURCE/data/foundations.json` applies the line 5 names and map changes to the approved foundations V2 data.
`SOURCE/data/identity.json` is a byte-for-byte copy of the approved identity V3 data. The loader adds the locked Inn
and Masjid street points and routes from that copy. Content and gameplay settings stay in portable JSON.

## Checks and evidence

Run the GDScript integration suite from the root of a complete checkout:
`godot --headless --path SOURCE --script res://tests/run_tests.gd`

The suite uses the approved `foundations_data_V2.json` and `identity_data_V3.json` under `GAME/APPROVED/`.
It checks the scoped foundations changes and compares the runtime identity file byte for byte with the approved copy.
For a fixture containing only `SOURCE/`, use the independent player movement, progress restart and look-test
controller checks below.

Use `--log-file /private/tmp/tfg-tests.log` if the sandbox cannot write the default engine log.
Tests exercise actual capsule movement/collision, quay-to-gate walking, stepping, wall pull-in, production map routing,
data-driven input, real task/choice/result buttons, amends economics and daily job transitions. The headless display checks look transforms; native capture separately
checks actual mouse dispatch and both pitch limits.

Run `godot --headless --path SOURCE --script res://tests/test_player_movement.gd` for independent player movement
regressions. An in-memory floor and capsule exercise all four walking/running diagonals, movement after turning,
opposing inputs, and stopping/resuming held input when the controller is disabled/enabled. This loads the real player
controller without game scenes or content files; it does not verify the pending game integration.

Run `godot --headless --path SOURCE --script res://tests/test_progress_restart.gd` for independent session-reset
regression checks. An in-memory fixture completes tasks, amends, the daily job, the lesson and the gate, then starts
another session on the same progress object. It checks cleared progress, replayed rewards and replacement wallet
limits without loading game scenes or content files.

The following historical commands use the source revisions that generated their evidence. Begin at those
revisions opens the market directly.

At source revision `6e04efc`, `godot --path SOURCE -- --capture-foundations` records native 1920×1080 viewport PNGs and
`MEASUREMENTS.json` under `GAME/APPROVED/FOUNDATIONS/BUILT/V1/`. It measures day and night using three seconds of
warm-up and rendered frames over ten seconds per mode, with vsync disabled. Captures include f01–f05 states,
three world views and temporary action/toast states. `BUILD.json` records the source commit and honest visual differences.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd` after native capture to create the five side-by-side PNGs, with the approved master on the left and actual game on the right.

At source revision `9309960`, `godot --path SOURCE -- --capture-tasks` captures the six part-2 master states f06–f11 plus gameplay checks and
`PART2_MEASUREMENTS.json` in that same evidence folder. It preserves the earlier part-1 captures. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --tasks` for the six additional comparison
PNGs. f11's master retains 31 coins / 0 trust after the job; the game applies the approved +2 coins / +5 trust and
shows 33 / 5 for that sequence. Content and economic settings come from the unchanged V2 JSON.

## Earlier look test

The disposable Founder-named engine evaluation remains in `SOURCE/look_test/`, unchanged. Run it explicitly with
`godot --path SOURCE res://look_test/look_test.tscn`. Hold right mouse to look; WASD flies, Q/E lowers/raises,
Shift moves faster, and Escape releases the mouse. F1–F4 choose street, gate, river and market views;
F5/F6/F7 choose day/night/dusk. Its old capture flags remain available after the explicit scene path.
It is not the playable greybox or the locked art direction.

Run `godot --headless --path SOURCE --script res://tests/test_look_controls.gd` from the repository root for
independent checks of the look-test controller. These cover the four shot shortcuts, day/night/dusk transitions,
ignored key releases/repeats and shortcut suppression during capture, using a small in-memory scene. They do not
load the playable game, render screenshots or measure frame rate; mouse dispatch and flight still need the native
look-test control check.

At source revision `3a35ea6`, `godot --path SOURCE -- --capture-gate` captures part-3 states f12–f20, a wrong answer and six numbered playthrough
screenshots. The master-state fixtures are disclosed separately from the continuous playthrough, which begins at the
quay and walks to the board, scales and gate through production map routes. All GUI choices use viewport mouse hits.
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --gate` makes the nine master comparisons.
The plain runner also checks wrong answers, repeat lesson rewards, both gate prerequisites and persistent opening.

Append `--masters-only` after `--capture-gate` for a short independent refresh of f12–f20 fixtures. It writes
`PART3_MASTERS_MEASUREMENTS.json` and preserves the full playthrough receipt and its six numbered screenshots.

Use the original LOCK 1 source commit to reproduce the retired f02 and f20 city maps.
At source revision `262da0b`, `godot --path SOURCE -- --capture-identity` records the six line 5 states and `CHECKS.json` under
`GAME/APPROVED/IDENTITY/BUILT/V1/`. The native run uses map clicks and walks the player through the Inn, Masjid,
honest tasks, scales lesson and gate. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --identity`
to put each of the six approved masters beside the corresponding native capture.
Append `--masters-only` to the native command for a shorter capture. This sets up the player at the gate
for g14 and verifies the gate's prerequisites, hinge and collision through the real use action.

At the line 6 source revision, `godot --path SOURCE -- --capture-arrival` records the 13 line 6 states and `CHECKS.json` under
`GAME/APPROVED/IDENTITY/BUILT/V1/ARRIVAL/`. It uses viewport clicks for both arrival branches and walks the
player to the scales. The stable case seeds a zero wallet after using the prepaid night.
Append `--masters-only` to place the player at the scales for g30, then use the live lesson controls.
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --arrival` puts each approved
master on the left of its native capture. The line 6 receipt lives alongside those pairs in `ARRIVAL/BUILD.json`.

At source revision `a69dda5`, `godot --path SOURCE -- --capture-clock` records eight line 7 master states and the day and night street HUDs
in `GAME/APPROVED/IDENTITY/BUILT/V1/CLOCK/`. The runner fixes capture times and uses the production prayer
and record controls. `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --clock`
creates the eight master pairs and the street HUD day/night pair. See `CLOCK/BUILD.json` for the source hashes,
capture checks and visual differences.

`godot --path SOURCE -- --capture-idris` captures the six line 8 master states and both entry routes in
`GAME/APPROVED/IDENTITY/BUILT/V1/IDRIS/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --idris` to pair each master with
the corresponding build. Pass `--idris-output=/absolute/path` after either command to write to a separate directory.
See `IDRIS/BUILD.json` for the test counts, capture fixtures and visual differences.

`godot --path SOURCE -- --capture-open-purse` captures all 16 LOCK 3 V2 part 1 masters and two street views
in `GAME/APPROVED/CHAPTER_1/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --open-purse` to put each
master to the left of its native capture. Pass `--open-purse-output=/absolute/path` after either command
to use a separate directory. See `BUILD.json` for the provenance, visual differences and verified PNG hashes.

`godot --path SOURCE -- --capture-bread-grab` captures the 12 bread grab states and a second frame of Faris
running in `GAME/APPROVED/CHAPTER_1/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --bread-grab` for the 12 comparisons.
Both commands accept `--bread-grab-output=/absolute/path`. See `BUILD.json` under `line_10` and `LINE10_CHECKS.json`
for capture setup, checks and hashes.

At source revision `8c9b4d0`, `godot --path SOURCE -- --capture-market-stall` captures the 15 LOCK 4 masters and two street capsule views in
`GAME/APPROVED/MARKET_STALL/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --market-stall` for the 15 comparisons.
Both commands accept `--market-stall-output=/absolute/path`. See `BUILD.json` for capture fixtures,
source provenance, differences and the final PNG hashes.
Use a separate output folder when running the stall checks against the current wardrobe.

`godot --path SOURCE -- --capture-clothes` captures the 15 LOCK 5 masters and Layla's street capsule in
`GAME/APPROVED/CLOTHES/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --clothes` for the 15 comparisons.
Both commands accept `--clothes-output=/absolute/path`. See `LINE12_CHECKS.json` for the viewport checks and fixtures,
and `BUILD.json` for provenance, visual differences and verified PNG hashes.

`godot --path SOURCE -- --capture-talking` captures the 15 LOCK 6 states in `GAME/APPROVED/TALKING/BUILT/V1/`.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --talking` for the 15 comparisons.
Both commands accept `--talking-output=/absolute/path`. See `LINE13_CHECKS.json` for the viewport checks and fixture states,
and `BUILD.json` for source provenance, visual differences and verified PNG hashes.

LOCK 7 reads the regulars' hours from `SOURCE/data/market_day.json`. On Fridays, the five conversations,
Rashid's stall and Layla's loom close at the Friday adhan and reopen five minutes after the iqamah.
The scales lesson stays open, and Salma must be present to start the bread grab.

`godot --path SOURCE -- --capture-market-day` captures all ten LOCK 7 states in
`GAME/APPROVED/MARKET_DAY/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --market-day` to pair each master with
its native capture. Both commands accept `--market-day-output=/absolute/path`.
See `LINE14_CHECKS.json` and `BUILD.json` for the checks, fixture, provenance and visual differences.

`godot --path SOURCE -- --capture-prayer-record` captures the six LOCK 8 states in
`GAME/APPROVED/PRAYER_RECORD/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --prayer-record`
to pair each master with its native capture. Both commands accept `--prayer-record-output=/absolute/path`.
`LINE15_CHECKS.json` records the native checks and the setup for each screen.
