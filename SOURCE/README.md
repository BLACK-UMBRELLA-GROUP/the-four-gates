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
The Six Gates title opens first. Begin starts the four arrival beats at the quay with zero coins.
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
opens the goal panel, which lists all six gates and their requirements. The city map marks the open Gate of Trust green.

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

The game starts at 06:30 on Thursday 1 Sha'ban, after the first Fajr window. A day takes 48 real minutes. The clock drives
day and night lighting and announces when prayers begin. Use the Masjid action to pray in congregation during
its window, or use P or the on-screen action to pray where you are. On Friday, the Masjid offers Friday prayer
during congregation. Elsewhere and after congregation, pray Dhuhr. Click the clock to see the private prayer
record. A missed prayer can be made up and prayer leaves coins and trust as they were.

At the Masjid, Sit a while opens the first meeting with Idris at the current game time. Reply to learn town words.
Learned words appear in English with the town word in brackets. Leave or Esc returns to the Masjid on the market map.
Meet him again replays the meeting with the words you learned. After the meeting, the Masjid offers Look inside when
there is no prayer action due.

Open City map from the market map to see the six gate markers. Tap any of Ilmara's five parts for its description. The Inn marker or River Market button returns to the
market map. Open World map from the city map and tap one of the twelve placeholder towns for its description.

`SOURCE/data/foundations.json` applies the line 5 names and map changes to the approved foundations V2 data.
`SOURCE/data/identity.json` is a byte-for-byte copy of the approved identity V3 data. The loader adds the locked Inn
and Masjid street points and routes from that copy. `SOURCE/data/six_gates.json` supplies the LOCK 103 text updates,
goal rows and city gate directions at runtime. Content and gameplay settings stay in portable JSON.

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

LOCK 9 opens **Feed the poor** at the Task board when Salma is at her oven. Ten loaves cost five coins and fifty
cost twenty. The first public payment each game day adds one trust. The first public payment also adds
**Feeds the poor** to **What people say**. After reading the first scholar’s page, tick **Ask Salma to keep it
quiet** to pay without adding trust or a reputation line. Both choices count toward 10,000 meals.

`godot --path SOURCE -- --capture-feeding` captures the eight LOCK 9 states in `GAME/APPROVED/FEEDING/BUILT/V1/`.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --feeding` to place each master
beside its native capture. Both commands accept `--feeding-output=/absolute/path`. See `LINE16_CHECKS.json` and
`BUILD.json` for the fixtures, checks, provenance and visual differences.

LOCK 10 offers **Karim has a job for you** at the Quay from 06:30 to 18:10 with River Market trust of at least 40,
outside the Friday prayer closure. After the coin choice, the map returns to the Task board with the purse.
At the Gate of Trust choose **Give the purse to Abbas**. The outcome appears in **What people say**.

`godot --path SOURCE -- --capture-sealed-purse` records the ten native LOCK 10 states under
`GAME/APPROVED/SEALED_PURSE/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --sealed-purse`
to pair the captures with their masters. Both commands accept `--sealed-purse-output=/absolute/path`.

LOCK 11 adds **A man whispers at the inn door** at the Inn from 19:30 through 04:44. After Mansur's
invitation, **The door with the blue cloth** opens the dice house during the same hours. Go to bed
dismisses the invitation without moving the clock. Repeated nights add a single evolving line in
**What people say**. Bets change the wallet and repeated visits can lower River Market trust.

`godot --path SOURCE -- --capture-dice-house` records the twelve native LOCK 11 states under
`GAME/APPROVED/DICE_HOUSE/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --dice-house`
to pair the captures with their masters. Both commands accept `--dice-house-output=/absolute/path`.

LOCK 12 adds **A boatman waves from the dark** at the Quay from 19:30 through 04:44. Carrying the jars pays
twenty coins once per night. After midnight the run still belongs to the previous evening. Walking away leaves the
offer open. Repeated runs change **What people say** and can lower River Market trust.

`godot --path SOURCE -- --capture-qasims-jars` records all nine LOCK 12 states under
`GAME/APPROVED/QASIMS_JARS/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --qasims-jars`
to pair the captures with their masters. Both commands accept `--qasims-jars-output=/absolute/path`.

LOCK 13 adds **A drover with two goats** at the Gate of Trust from 15:00 through 17:59. Buy for ten coins
and sell for thirty, walk away, or tell Saeed. The game allows one purchase per calendar day. Telling
Saeed ends the offer. Repeated purchases and telling Saeed change trust and **What people say**.

`godot --path SOURCE -- --capture-jabirs-goats` records all twelve LOCK 13 states under
`GAME/APPROVED/JABIRS_GOATS/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --jabirs-goats`
to pair the captures with their masters. Both commands accept `--jabirs-goats-output=/absolute/path`.

LOCK 14 adds Idris’s response to the six temptation trust hits. When he cools, he tells the player to come
back before he reads the first scholar’s page. Every prayer remains available. He warms at ten net trust
above the last hit or any later temptation while cool. Idris counts full trust changes, and the HUD still
displays 0–100. His current line appears in **What people say** after the goat lines and before the sealed purse.

`godot --path SOURCE -- --capture-idris-recovery` records the eight LOCK 14 states in
`GAME/APPROVED/IDRIS_HAS_HEARD/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --idris-recovery`
to pair each native frame with its master. Both commands accept `--idris-recovery-output=/absolute/path`.
Use separate output folders when regenerating the earlier temptation captures against the current game.

LOCK 15 offers **The dry fountain** at the Task board at any hour. The first of three 20-coin payments
fixes whether your name appears. The final payment starts the fountain and records one repair. Named
repairs add five trust once and a **What people say** line between the goats and Idris entries. The
square replaces the repair button with the days since completion, starting at zero.

`godot --path SOURCE -- --capture-dry-fountain` records nine native LOCK 15 states in
`GAME/APPROVED/DRY_FOUNTAIN/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --dry-fountain`
to pair each capture with its master. Both commands accept `--dry-fountain-output=/absolute/path`.
See `LINE22_CHECKS.json` for the capture fixtures and `BUILD.json` for provenance and verified PNGs.

LOCK 16 offers a 30-coin loan at Spice row during Rashid's stall hours when River Market trust is at least
30. Asking for 36 back is refused without a payment. Visit after three calendar days to give him time,
let the last ten go or collect the full loan. Giving time pays twenty now and ten seven days after the
due visit. Each outcome adds its own line to **What people say**.

`godot --path SOURCE -- --capture-rashids-loan` records all 18 native LOCK 16 states in
`GAME/APPROVED/RASHIDS_LOAN/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --rashids-loan`
to place each master beside its native capture. Both commands accept `--rashids-loan-output=/absolute/path`.
See `LINE23_CHECKS.json` for the capture fixtures and `BUILD.json` for provenance and verified PNGs.

### Harm in the road

LOCK 17 shows one harmful thing each day in River Market. The place and harm follow the game day.
At that place from 06:30 through 19:29, the bar describes the harm and offers its move button. Moving
it takes five game minutes and adds one to the private count in the result panel. Coins, trust and
**What people say** stay as they were.

Run `godot --path SOURCE -- --capture-harm-in-the-road` for the nine native states in
`GAME/APPROVED/HARM_IN_THE_ROAD/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --harm-in-the-road`
to put each master beside its capture. Both commands accept `--harm-in-the-road-output=/absolute/path`.
`LINE24_CHECKS.json` records the capture fixtures and `BUILD.json` records the source and image checks.

### The calendar

LOCK 18 adds the fixed Hijri date to the clock. At the Inn, **Rest for days** shows the next Ramadan,
Eids, Day of Arafah and end of your zakat year. Rest for three days for six coins or seven days for
fourteen coins. Both options wake at 04:40. Prayer windows that end while resting are excluded from
the private record totals. The one-night **Rest until morning** action remains available.

Run `godot --path SOURCE -- --capture-calendar` for the eleven native states in
`GAME/APPROVED/CALENDAR/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --calendar`
to put each master beside its capture.
Both commands accept `--calendar-output=/absolute/path`. See `LINE25_CHECKS.json` for the capture checks
and `BUILD.json` for the verified source and evidence.

### Ramadan

LOCK 19 adds the Ramadan fasting line to place bars from 04:45 through 18:09. At the Inn,
**Eat suhoor** is available from 03:30 through 04:44. At the Masjid, **Break your fast with the people**
is available from 18:10 through 19:29, and **Pray tarawih** is available from 19:45 through 22:59.
Each action is available once per day. Tarawih passes 60 game minutes. **All your prayers** includes
the private Ramadan record once Ramadan begins.

Run `godot --path SOURCE -- --capture-ramadan` to capture the eleven native states in
`GAME/APPROVED/RAMADAN/BUILT/V1/`. Use
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --ramadan` for the
master-left comparisons. Both commands accept `--ramadan-output=/absolute/path`.
See `LINE26_CHECKS.json` for the capture checks and `BUILD.json` for the verified source and images.

### Iftar for the fasting

During Ramadan, **Pay for iftar** appears at the Masjid from 16:00 through 18:09. Dates and water
for twenty cost four coins. Soup and bread for fifty cost fifteen. The first public payment each day
adds one trust and **Feeds the fasting** appears in **What people say**. Reading the first scholar's
page unlocks secret payment. Both choices add to the same 10,000-meal goal as **Feed the poor**.

Run `godot --path SOURCE -- --capture-iftar-giving` for the ten native viewport captures in
`GAME/APPROVED/IFTAR_GIVING/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --iftar-giving`
for the master-left pairs. Both commands accept `--iftar-giving-output=/absolute/path`.
See `LINE27_CHECKS.json` for the native checks and `BUILD.json` for provenance and verified images.

### The last ten nights and Eid al-Fitr

At the Masjid, **Stand in prayer through the night** is available once per night belonging
to 21–30 Ramadan, from 23:00 the evening before through 04:44. Standing passes 60 game
minutes. **Give zakat al-fitr** costs two coins once per game year and is available from
28 Ramadan through 08:59 on 1 Shawwal. **Pray the Eid prayer** is available once at the
Masjid from 06:30 through 08:59 on 1 Shawwal. The Eid greeting appears in place bars all day.
**All your prayers** adds the three private rows below the earlier Ramadan rows.

Run `godot --path SOURCE -- --capture-eid-al-fitr` for the native viewport captures in
`GAME/APPROVED/EID_AL_FITR/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --eid-al-fitr`
for the master-left pairs. Both commands accept `--eid-al-fitr-output=/absolute/path`.
See `LINE28_CHECKS.json` for the native checks and `BUILD.json` for provenance and verified images.

## LOCK 22 Zakat

The Masjid offers **Your zakat year has ended** when Zakat is due or on the day a zero-due assessment
is recorded. Each assessment uses the coins held when it is recorded. The panel serves the oldest unpaid
year and keeps its receipt until you leave. **All your prayers** shows the total unpaid, or the status of
the latest assessment once no debt remains.

Run `godot --path SOURCE -- --capture-zakat` for the 13 native viewport captures in
`GAME/APPROVED/ZAKAT/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --zakat`
to place each approved master beside the capture. Both commands accept `--zakat-output=/absolute/path`.
See `LINE29_CHECKS.json` for capture fixtures and day-708 checks, and `BUILD.json` for source and image verification.

## LOCK 23 Eid al-Adha

At the Gate, Saeed offers one sheep for 30 coins from 07:00 through 17:59 on
1–9 Dhu al-Hijjah. At the Inn on the 9th, the fast intention is available from
03:30 through 04:44. The Masjid offers the Eid prayer from 06:30 through 08:59 on
the 10th. Return to the Gate with the sheep after praying or from 09:00, through
18:09 on the 13th. Sharing in thirds adds 10 meals to the shared goal. Giving
it all to the poor adds 30. The fast, prayer and sacrifice appear in the private
Dhu al-Hijjah section of **All your prayers**.

Run `godot --path SOURCE -- --capture-eid-al-adha` for the 18 native viewport captures in
`GAME/APPROVED/EID_AL_ADHA/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --eid-al-adha`
for the master-left comparisons. Both commands accept `--adha-output=/absolute/path`.
See `LINE30_CHECKS.json` for the native checks and `BUILD.json` for provenance and verified images.

## LOCK 24 V2 Pilgrims you send

At the Gate of Trust from 07:00 through 17:59, choose **Abbas takes pilgrims**.
Old Musa, Yunus and Jamal each cost 40 coins to send on Umrah and return after 30 days.
Idris costs 120 coins to send on Hajj, with bookings open from 1 Shawwal through
25 Dhu al-Qa'dah and return on 25 Dhu al-Hijjah. Each person can go once.
After reading the scholar's first page, you can ask Abbas to keep the payment secret.
Public returns add two trust and a line to **What people say**. The panel counts public and secret
payments toward the 1,000 Umrah and 100 Hajj lifetime goals.

Run `godot --path SOURCE -- --capture-pilgrims` for the 11 native viewport captures in
`GAME/APPROVED/PILGRIMS/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --pilgrims`
for master-left comparisons. Both commands accept `--pilgrims-output=/absolute/path`.
See `LINE31_CHECKS.json` for the native checks and `BUILD.json` for provenance and verified images.

## LOCK 25 Qurans and school

At the Masjid from 07:00 through 15:29, choose **Idris's school and copyists**.
A hand-copied Quran costs 25 coins and a child's year of school costs 30. The first school payment
sponsors Faris. The panel counts payments toward 1,000 Qurans and 100 children in school.
The first public payment each day adds one trust, and each kind of public giving adds an Idris line
to **What people say**. After reading the first scholar's page, you can ask Idris to keep a payment quiet.

Run `godot --path SOURCE -- --capture-qurans-school` for the 11 native viewport captures in
`GAME/APPROVED/QURANS_SCHOOL/BUILT/V1/`. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --qurans-school`
for the master-left comparisons. Both commands accept `--qurans-school-output=/absolute/path`.

## LOCK 26 The Names of Allah

After meeting Idris, choose **Read the calligraphy** at the Masjid, Task board and Market scales.
Each Name can be learned once. Its panel shows the Arabic, Idris's explanation, the Quran reference
and a private count out of 99. Learning leaves coins, trust and reputation unchanged.

Run `godot --path SOURCE -- --capture-names-of-allah` for the eight native viewport captures.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --names-of-allah`
to put each master beside its capture. Both commands accept `--names-of-allah-output=/absolute/path`.

## LOCK 27 Regulars at prayer

Rashid, Jamal and Old Musa go to the Masjid from 12:05 through 12:29 for Dhuhr on days other than Friday,
and from 15:30 through 15:54 for Asr every day. Their place bars show where they are and the Masjid
lists the three names. Rashid's stall and loan controls return when he comes back. The existing
Friday Dhuhr closure still applies.

Run `godot --path SOURCE -- --capture-regulars-at-prayer` for the eight native viewport captures.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --regulars-at-prayer`
to put each master beside its capture. Both commands accept `--regulars-at-prayer-output=/absolute/path`.

## LOCK 28 The regulars remember

The talk panel shows the regular's trust-tier line, any earlier fact, then the first applicable
memory from their own list. Greeting replies and market tips still come after it. Secret feeding,
school payments and fountain gifts never earn an attributed memory. After returning, a secretly
funded pilgrim can thank an unnamed giver in their own talk panel.

Run `godot --path SOURCE -- --capture-regulars-remember` for the 17 native viewport captures.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --regulars-remember`
to put each master beside its capture. Both commands accept `--regulars-remember-output=/absolute/path`.
See `LINE35_CHECKS.json` and `BUILD.json` in `GAME/APPROVED/REGULARS_REMEMBER/BUILT/V1/`.

## LOCK 29 Pause, save and settings

Press Esc on the River Market map to pause, then Esc again or **Resume** to return.
**Save game** keeps the menu open and shows the in-game date and time.
**Save and quit to title** saves to the same slot and returns to the title.
A dated **Continue** loads the saved session. **Begin** starts a new session and
the existing slot is kept until the next save.

**Settings** opens from the title or pause. **Large** scales text to 115% and tall
panels can be scrolled. **Fast** doubles walking speed. Esc or **Back** returns to
the previous menu. Godot stores the slot in `user://market.save` and preferences
separately in `user://settings.cfg`.

Run the headless suite with `godot --headless --path SOURCE --script res://tests/run_tests.gd`.
For the nine native viewport captures, run
`godot --path SOURCE -- --capture-menus --menus-user-dir=/absolute/fresh/path`
with a fresh fixture directory. Then run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --menus`
to place each master beside its capture. Both commands accept `--menus-output=/absolute/path`.

## LOCK 30 Real-life prayer reminder

Turn on **Real-life prayer reminder** in **Settings** to select a city and Standard or Hanafi Asr.
Today's five times use the Muslim World League calculation and the selected city's local date.
The native Mac build uses macOS's offline time-zone database for daylight saving. Preferences
stay in `user://settings.cfg`, alongside the text-size and walking-speed settings.

While the game is open, a recent prayer can show one banner per prayer day. **Pause and pray**
opens the existing pause menu. **Later** closes the banner. The reminder runs on the real clock.

Capture the seven locked states with
`godot --path SOURCE -- --capture-prayer-reminder --reminder-user-dir=/absolute/fresh/path`.
Create the paired images with
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --prayer-reminder`.
Both commands accept `--reminder-output=/absolute/path`.

## LOCK 31 A partnership with Layla

Visit Weaver's lane while Layla is at her loom with at least 40 River Market trust. The second-loom
offer asks for 60 coins and splits the profit and loss equally. Layla refuses a fixed weekly return
and lowers trust by 3. If you become partners, return to the lane to collect each weekly share.
The agreement or refusal and any collected weeks persist in the single save slot. Each choice adds
its line under **What people say**.

Run `godot --path SOURCE -- --capture-partnership --partnership-user-dir=/absolute/fresh/path`
for the 12 native viewport captures. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --partnership`
to put each master beside its capture. Both commands accept `--partnership-output=/absolute/path`.

## LOCK 32 — The Gate of Trust and Jisra

At the Gate of Trust with 100 River Market trust and the market scales lesson complete, choose
**The gatekeepers will open the gate**. **Not yet** returns to the gate and remembers the opening.
**Take the road east to Jisra** advances the shared clock by 90 minutes while the roads are open.
From Jisra, use the **Road map** to return to Ilmara. The return takes 90 minutes and restores the
River Market trust display.

Choose **Watch the bridge** to play **One coin and three** once. Speaking adds five Jisra trust,
paying costs three coins and adds three Jisra trust, and saying nothing leaves both values as they are.
Prayers offered on the bridge are recorded as prayed alone. A save in Jisra continues in town with the
same wallet, prayer record, trust and toll choice.

Run `godot --path SOURCE -- --capture-gate-of-trust --gate-of-trust-user-dir=/absolute/fresh/path`
to capture the 12 states from the native viewport. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --gate-of-trust`
to place each master beside its capture. Both commands accept `--gate-of-trust-output=/absolute/path`.

## LOCK 33 — Jisra's masjid and Masjids you have prayed in

From Jisra, choose **Go to the boatmen's masjid**. Pray with the congregation through five minutes
after the iqamah, or pray on your own at the masjid later in the prayer window. Uthman greets you
after your first prayer there.

Click the clock and open **All your prayers** to see the private count after praying in a masjid.
Prayers at the River Market masjid and the boatmen's masjid each add that place once. The count
saves with the game, and prayers on the bridge leave it as it was.

Run `godot --path SOURCE -- --capture-jisra-masjid --jisra-masjid-user-dir=/absolute/fresh/path`
to capture eight native viewport states. Run
`godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --jisra-masjid`
to place each master beside its capture. Both commands accept `--jisra-masjid-output=/absolute/path`.

## LOCK 34 — Scene runner, towns and Journal

Choose **Journal** on the River Market bar. Chapter 1 lists seven missions. A completed mission shows
its title and **done**. Undiscovered missions show **…** and **not yet found**. The Journal also shows
side mission totals and lifetime goals. **Back** returns to the River Market view.

The loader reads `data/content_index.json` in order. A later entry with the same chapter number replaces
the earlier chapter. Lifetime goals keep their order by first appearance. A later definition of the same
goal ID updates that goal. Mission buttons and town actions appear when their content and conditions
are available. Jisra's bridge, masjid, prayer and road controls are live. The generic town fixtures live
under `tests/fixtures/scene_runner/`.

Run `godot --headless --path SOURCE --script res://tests/run_tests.gd` for the full suite, or add
`-- --scene-runner-only` for the LOCK 34 checks. Use a fresh capture save directory when running
`godot --path SOURCE -- --capture-scene-runner --scene-runner-user-dir=/absolute/fresh/path`.
Then run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd -- --scene-runner`.
Both capture commands accept `--scene-runner-output=/absolute/path`. See the line 41 captures and
master comparisons in `GAME/APPROVED/SCENE_RUNNER/BUILT/V1/`.

## LOCK 35 — Jisra's people, work and the weak rope

In Jisra, choose **Talk to people**, then **Talk** beside a resident who is available. Dialogue
reflects Jisra's trust and the first matching memory. Rafiq is away during Friday prayer.
From 06:00 up to 12:00, outside Friday prayer, carrying fish baskets for Umm Hani takes one hour
and pays four coins. The first shift each day adds one Jisra trust.

**Watch Bashir's stall** opens **The weak rope** from 10:00 up to 16:00 with at least 15 Jisra
trust. Each response adds its own account to **What Jisra says**. Choose **Back** on the ending
to complete the mission once and count it in the **Journal**. Resting at the inn costs two coins
and wakes you in Jisra at 04:40. If you cannot pay, you sleep by the wall and keep your coins.

Run `godot --headless --path SOURCE --script res://tests/run_tests.gd` for the full suite, including
both mission outcomes, resident dialogue, availability, work and the inn. The line 42 records are in
`GAME/APPROVED/JISRA_PEOPLE/BUILT/V1/`.

## LOCK 36 V2 — Road map and gates at night

Open **Road map** at the opened Gate of Trust or from a town hub. **Go** advances the shared clock
and takes you to the destination hub. Towns need a loaded hub, an open gate and any required flag.
The **Journal** shows your journey percentage. Patience, Mercy, Knowledge, the Witness and Return
open at 20%, 30%, 40%, 45% and 50%, respectively, and stay open in your save.

The roads shut at 20:00 and reopen at 04:40. Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --road-map-only`.

## LOCK 37 — Sahila and Sahila's boat

After visiting Jisra, take the Gate of Trust road to Sahila. The shore hub has its own trust,
residents, net-mending work, masjid and inn. The **Road map** is the way out.
**Mukhtar wants to sell his boat** appears from 07:00 up to 18:00. Completing **Sahila's boat**
counts in Chapter 1 of the **Journal**. If the plank went undisclosed, **Ziyad is waiting for you**
appears seven days later. The **What Sahila says** panel records the account your choices earn.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --sahila-only`.

## LOCK 38 — Sukara and the two offers

Complete **Sahila's boat** to open the Gate of Trust road to Sukara. The sugar press hub has
its own trust, three residents, work, a masjid and an inn. Use **Road map** to leave.
**Murad's press has cracked** appears from 07:00 up to 18:00. Partnership opens **Harvest share**
after 14 days. Lending through Sakhr opens **Sakhr pays** after 30 days. The **Journal** records
**Sukara's two offers** in Chapter 1. **What Sukara says** shows any account the choice earns.

Run the focused rules checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --sukara-only`.

## LOCK 39 V2 — Chapter 1 ends: Trust kept

After finishing the boat sale in Sahila and responding to the offers in Sukara, return to the River Market
masjid from 07:00 up to 20:00. Select **Idris wants to hear about your road**, then
**Ask about the road north**. Choose **Back** to record **Trust kept** in Chapter 1 of the **Journal**.
The Gate of Patience opens at 20% journey progress.

Run the focused rules checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --chapter1-end-only`.

## LOCK 40 V2 — Safira, the slow pilgrim and lost at night

Safira is 120 minutes from Ilmara through the Gate of Patience. The hub offers local
work, three residents, the caravanserai masjid and a two-coin inn. **The slow pilgrim**
is available from 05:00 up to 12:00. Completing it opens **Lost at night** from 18:00 up
to 22:00. Both missions finish with **Back** on the ending. **What Safira says** shows
the accounts your choices earn. The missions save their completion and appear in the
**Journal** when Chapter 2 is loaded.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --safira-only`.

## LOCK 41 V1 — Wadira, the sandstorm and cheated in public

The road to Wadira opens through the Gate of Patience after Safira's **Lost at night**.
Wadira has local work, three residents, the valley masjid and a two-coin inn.
**The sandstorm** is available from 05:00 up to 14:00. After it, **Cheated in public**
is available from 08:00 up to 18:00. Each mission records completion on **Back**.
**What Wadira says** shows the local accounts earned by your choices.
The missions appear in the **Journal** when Chapter 2 is loaded.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --wadira-only`.

## LOCK 42 V2 — Birana and the Chapter 2 ending

After the Gate of Patience opens and you finish Wadira, take the Road map to Birana. Talk to
Thabit, Safiyya and Wahb, draw water in the morning, or pray at the well masjid.
The dry well leads to The long wait. Waiting or reporting Wahb makes the permit available
five days later during his hours. The Journal lists seven Chapter 2 missions, and the permit
appears as a follow-up in Birana.

After Safira, Wadira and Birana, return to the River Market masjid for Patience kept.
The Gate of Mercy opens at 30% journey progress. Run the Birana headless checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --birana-only`.

## LOCK 43 V2 — Nahla, the sick child and the overloaded donkey

When the Gate of Mercy opens at 30% journey progress, take the 100-minute road to Nahla.
Talk to Dawud, Umm Yahya and Ayyub, carry honey jars during work hours, or pray at the
hillside masjid. Use the **Road map** to leave town.

Complete The sick child first. The overloaded donkey appears during its own hours.
Both missions save their completion. **What Nahla says** shows the accounts earned by
your choices. The Journal shows missions when their chapter is loaded.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --nahla-only`.

## LOCK 44 V2 — Tinara, the widow's harvest and the orphan's share

After finishing Nahla, use the **Road map** through the Gate of Mercy to reach Tinara.
Talk to Sumayya, Hakam and Usama, pick apricots during work hours, or visit the orchard masjid.
Complete **The widow's harvest** to open **The orphan's share** during its hours. If you lend
Sumayya the wages, her repayment opens 30 days later. **What Tinara says** shows the local
accounts earned by your choices. The Journal lists the loaded chapters and the repayment is
saved as a follow-up.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --tinara-only`.

## LOCK 45 V2 — Tahuna and the Chapter 3 ending

After completing Tinara, use the **Road map** through the Gate of Mercy to reach Tahuna.
Talk to Ma'n, Hafsa and Rami, carry sacks at the mill during work hours, or visit the
millstream masjid. Complete **The miller's debt** to open **The enemy's son** during its
hours. **What Tahuna says** shows the local accounts earned by your choices.

After completing Nahla, Tinara and Tahuna, return to the River Market masjid for **Mercy shown**.
All three Tahuna missions count toward **The Gate of Mercy** in the Journal.
The Gate of Knowledge opens at 40% journey progress.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --tahuna-only`.

## LOCK 46 V1 — Waraka, the copyist and the fake hadith seller

The **Road map** reaches Waraka through the Gate of Knowledge at 40% journey progress.
In Waraka, read a copy back for Yaqub, then deal with Fuad's false sayings.
**What Waraka says** records the local accounts those choices earn. Talk to Yaqub, Fuad
and Zaynab during their hours, work at the pulp vats, pray at the paper-makers' masjid
or rest at the inn. The two missions save completion. Their Chapter 4 Journal rows
come with the locked chapter data.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --waraka-only`.

## LOCK 47 V1 — Najmara, the qibla and the student who can't pay

After finishing Waraka, take the **Road map** through the Gate of Knowledge to Najmara.
Help Hilal with the new masjid's qibla or tell the builders to carry on. Either choice
opens Kamil's mission during his hours. Choices can add accounts to **What Najmara says**.
Talk to Hilal, Kamil and Sa'd, polish the brass instruments during work hours, pray at
the new masjid or rest at the inn. Both missions save completion. The Chapter 4 Journal
rows come with the locked chapter data.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --najmara-only`.

## LOCK 48 V2 — Shifara and the Chapter 4 ending

After finishing Najmara, take the **Road map** through the Gate of Knowledge to Shifara.
Talk to Rahma, Shakir and Malik during their hours, wash hospital bandages, pray at the
hospital masjid or rest at the inn. Complete **The fever** to unlock **The doctor's
secret** during its hours. **What Shifara says** shows the accounts your choices earn.

After finishing Waraka, Najmara and Shifara, return to the River Market masjid for
**Knowledge carried**. The three Shifara missions count toward **The Gate of Knowledge**
in the Journal.

Run the focused rules checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --shifara-only`.

## LOCK 49 V2 — The hoarders and the bread lines

After Chapter 6, River Market's board opens **The hoarders** from 08:00 until 18:00.
Finishing it opens **The bread lines** from 06:00 until 18:00. Buying Jalal's
share opens his payout after 30 days. The first two missions count toward the six
slots in Journal Chapter 7, **The hard year**. The payout saves as a follow-up.
The headless tests supply the Chapter 6 completion flag until that chapter ships.
Run them with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --finale-hoarders-only`.

## LOCK 50 — The rain prayer and the riot

After **The bread lines**, the River Market masjid offers **The rain prayer** from 05:00 until
10:00. Joining the prayer advances the clock by two hours and makes **The riot** available
at the board from 10:00 until 20:00. Use **Back** on each ending to record it in Chapter 7
of the **Journal**. The riot choice changes River Market trust and can add a witness account
to **What people say**. Run the focused headless checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --finale-rain-only`.

## LOCK 51 — The last page and your choice

After **The riot**, visit the River Market masjid from 07:00 until 20:00. Read the last
page with Idris and use **Back** to finish it. Idris then asks whether you will stay
in Ilmara or go home and return every year. Use **Back** on either ending to record
the final mission in Chapter 7 of the **Journal**. Run the focused headless checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --finale-ending-only`.

## LOCK 52 — Two brothers not speaking

At the River Market spice row, **Adil is complaining about his brother** is available from
08:00 up to 18:00 at River Market trust 30 or higher. Choose a response, then use **Back**
on the ending to complete the mission. The **Journal** counts the completion, and
**What people say** shows any account the response earned. The full headless suite covers
all three outcomes.

## LOCK 53 — The neighbour's wall

At Weaver's lane in the River Market, **Nadir and Saif are arguing over a wall**
is available from 08:00 up to 18:00. Choose a response, then use **Back** on
the ending to finish the mission once and count it in the **Journal**.
Helping them settle adds an account to **What people say**. The headless
suite covers all three responses.

## LOCK 54 — Goods left in trust

At the River Market inn, Ghalib asks you to keep his bag from 06:00 up to
20:00. Leave either ending with **Back** to complete the side mission in
the **Journal** and start the seven-day wait. When Ghalib comes back during
the same hours, choose **Watch him count** to see how your choice affected
River Market trust and **What people say**. Finish the return scene with
**Back**. Run the focused checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --side-goods-in-trust-only`.

## LOCK 55 — A creditor beating a debtor

At the River Market quay, **Zahir is beating Fadil at the quay** is available from
07:00 up to 18:00. Paying part of the debt requires 10 coins. Choose a response,
then use **Back** on the ending to finish the mission and count it once in the
**Journal**. Pulling them apart or paying adds the corresponding account to
**What people say**. The headless suite covers all three responses.

## LOCK 56 — A lost child at Friday prayer

At the River Market masjid on Fridays from 12:15 up to 14:00, choose
**A small boy is crying by the masjid door**. Either way of helping adds
four River Market trust and a masjid account to **What people say**. Use
**Back** on any of the three endings to count the mission once in the
**Journal**. Run the focused checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --side-lost-child-only`.

## LOCK 57 — A boy drowning in the canal

At the River Market quay, **Someone is shouting at the canal** is available from
10:00 up to 18:00. Choose a response, then use **Back** on the ending to finish
the mission and count it once in the **Journal**. Jumping in or throwing a rope
adds the boatmen's account to **What people say**. The headless suite covers all
three responses.

## LOCK 58 — The overcharging water seller

At the River Market gate from 10:00 up to 17:00, choose
**A water seller is charging travellers four times the price**. Fetching Nasir
adds six River Market trust. Buying water costs two coins and adds three trust.
Both actions add an account to **What people say**. Use **Back** on any ending
to complete the mission once in the **Journal**. Run the focused checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --side-water-seller-only`.

## LOCK 59 — A thirsty dog

At the River Market quay, **A dog is panting by the well** is available from
10:00 up to 18:00. Giving the dog water takes 10 in-game minutes. Use **Back**
on either ending to finish the mission and count it once in the **Journal**.
The headless suite covers both responses at trust 10, 50 and 80.

## LOCK 60 — The spilled spice

At the River Market spice row, **Old Sulayman knocked over a sack** is available
from 08:00 up to 18:00. Use **Remember it** to reach Rashid's question.
Telling the truth or blaming Faris adds the corresponding account to
**What people say**. Use **Back** on any ending to finish the mission once
and count it in the **Journal**. The headless suite covers all three responses
at trust 10, 50 and 80.

## LOCK 61 — A ring found in the masjid

At the River Market masjid, **Something is shining under a prayer mat** is
available from 07:00 up to 20:00. Ask Yunus to announce the ring or keep it
for eight coins. Use **Back** on either ending to count the mission once in
the **Journal**. Three days after the announcement, **Umm Salim is asking
about a ring** appears during the same hours. Returning it adds six River
Market trust and Salma's account to **What people say**. Use **Back** to
complete the follow-up. Run its focused checks with
`godot --headless --path SOURCE --script res://tests/run_tests.gd -- --side-ring-masjid-only`.

## LOCK 62 — A cheat at archery

At the River Market gate, **There's an archery contest outside the gate** is
available from 08:00 up to 15:00. Saying what you saw adds five River Market
trust and the young men's account to **What people say**. Entering the contest
takes one in-game hour. Use **Back** on any ending to finish the mission once
and count it in the **Journal**. The headless suite covers all three responses
at trust 10, 50 and 80.

## LOCK 63 — A stranger with nowhere to sleep

At the River Market inn, **A traveller is sitting outside the inn** is
available from 19:00 up to 23:00. Sharing your room adds five River Market
trust. Paying two coins for a straw bed adds three trust. Both choices add
the inn's account to **What people say**. Going to bed leaves coins, trust
and the inn's accounts as they were. Use **Back** on any ending to finish the
mission once and count it in the **Journal**.

## LOCK 64 V2 — The scholar's notebook, Chapter 1

Read the first page with Idris through the inn's open-purse story. People around
the River Market then offer pages 2–10 in order between 07:00 and 19:00. Take
each page to Idris and read it at the River Market masjid. The masjid offers the
lowest unread page you have found. Page 10 includes the chapter story. The private
Journal counts each page read under **The scholar's pages**.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch01-only`.

## LOCK 65 — The scholar's notebook, Chapter 2

After opening the Gate of Trust, find page 11 with Umm Hani in Jisra. Each
page found unlocks the next through page 20. The page buttons appear at the
town hubs from 07:00 up to 19:00 for Umm Hani in Jisra, Mukhtar in Sahila
and Sakhr in Sukara. At the River Market masjid, Idris offers the lowest unread
page you have found. Closing each reading adds one to **The scholar's pages**
in the Journal. Page 20 includes the chapter story.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch02-only`.

## LOCK 66 — The scholar's notebook, Chapter 3

After completing Chapter 1, find page 21 with Ghazi at the Wadira town hub.
Each find unlocks the next page through page 30. The page buttons appear at
the town hubs from 07:00 up to 19:00 for Ghazi in Wadira, Wahb in Birana and
Amina in Safira. Idris offers the lowest found unread page at the River Market
masjid. Closing each reading adds one to **The scholar's pages** in the
Journal. Page 30 includes the chapter story.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch03-only`.

## LOCK 67 — The scholar's notebook, Chapter 4

After completing Chapter 2, find page 31 with Ma'n at the Tahuna town hub.
Each find unlocks the next page through page 40. From 07:00 up to 19:00
the find actions appear at the town hubs for Ma'n in Tahuna, Dawud in Nahla
and Usama in Tinara. At the River Market masjid, Idris offers the lowest
found unread page. Closing the notebook adds one to **The scholar's pages**
in the Journal. Page 40 includes the chapter story.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch04-only`.

## LOCK 68 — The scholar's notebook, Chapter 5

After completing Chapter 3, find page 41 with Zaynab at the Waraka town hub.
Each find unlocks the next page through page 50. From 07:00 up to 19:00,
find actions appear with Zaynab in Waraka, Kamil in Najmara and Shakir in
Shifara. At the River Market masjid, Idris offers the lowest found unread
page. Closing the notebook adds one to **The scholar's pages** in the
Journal. Page 50 includes the chapter story.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch05-only`.

## LOCK 69 — The scholar's notebook, Chapter 6

After the Chapter 1 ending, find pages 51–60 around the River Market from
07:00 up to 19:00. Each find after page 51 requires taking the preceding
page. At the River Market masjid, Idris offers the lowest found unread
page. Read the chapter story on page 60. Each time you close the notebook
after reading a page, **The scholar's pages** in the private Journal goes
up by one.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch06-only`.

## LOCK 70 — The scholar's notebook, Chapter 7

After the Chapter 2 ending, find pages 61–70 in the town hubs from 07:00 up to 19:00.
Start with Wahb in Birana. Each subsequent pickup requires taking the preceding page.
At the River Market masjid, Idris offers the lowest found unread page. Page 70 includes
the Fasting and seasons chapter story. Closing each reading adds one to
**The scholar's pages** in the private Journal.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch07-only`.

### The scholar's notebook, Chapter 8 — Mercy and the weak (LOCK 71 V1)

After completing Chapter 3, find pages 71–80 from 07:00 up to 19:00 in
Tinara, Tahuna, Nahla and at the River Market quay. Start with Sumayya in
Tinara. Each subsequent pickup requires taking the preceding page. At the
River Market masjid, Idris offers the lowest found unread page. Page 80
includes the chapter story. Closing each reading adds one to **The scholar's
pages** in the private Journal.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch08-only`.

### The scholar's notebook, Chapter 9 — Knowledge and patience (LOCK 72 V1)

After completing Chapter 4, find pages 81–90 from 07:00 up to 19:00 in
Waraka, Najmara, Shifara and at the River Market masjid, weaver and inn.
Start with Yunus the muezzin at the River Market masjid. Each subsequent
pickup requires taking the preceding page. Idris offers the lowest found
unread page at the masjid. Page 90 includes the chapter story. Closing
each reading adds one to **The scholar's pages** in the private Journal.

Run the focused checks with `godot --headless --path SOURCE --script res://tests/run_tests.gd -- --pages-ch09-only`.

## LOCK 74 — Wudu with Idris

After meeting Idris, choose **Idris will show you wudu** at the River Market
masjid from 05:00 up to 21:00. **Make wudu with him** advances the clock by
five in-game minutes and finishes the lesson once. The lesson leaves trust,
coins and Journal totals unchanged.

## LOCK 75 — The adhan and the rows

After completing wudu with Idris, choose **Yunus the muezzin wants to show you
something** at the River Market masjid from 05:00 up to 21:00. Choose
**Repeat the adhan after him**, then **Stand in the row** to finish the
scene once. The scene leaves trust, coins and Journal totals unchanged.

## LOCK 77 — The extra prayers

After learning the adhan and the rows, choose **Idris prays two more rak'ahs**
at the River Market masjid from 08:00 up to 20:00 and **Ask him how** to
complete the lesson once. This unlocks Duha at the masjid from 08:00 up to
11:30 and the night prayer at the inn from 23:00 through midnight up to
04:30. Each can be completed once per in-game calendar day. **Finish** adds
one to the corresponding private Journal goal and advances the clock by
10 minutes for Duha or 20 minutes for the night prayer.

## LOCK 78 — Morning and evening remembrance

After completing the wudu lesson, choose **Idris is counting on his
fingers** at the River Market masjid from 07:00 up to 20:00. **Count with him**
completes the lesson once and adds one to the private Journal goal.

At the River Market inn, morning remembrance is available from 04:40 up to
08:00 and evening remembrance from 17:00 up to 19:00. Each can be completed
once per in-game day. **Finish** adds one to the same Journal goal of 1,000
and advances the clock by five in-game minutes. All three scenes leave
trust unchanged.

## LOCK 79 — Four surahs with Idris

After completing wudu with Idris, choose **Learn Al-Fatiha with Idris** at
the River Market masjid from 07:00 up to 20:00. Al-Ikhlas, Al-Falaq and An-Nas
follow in order, each becoming available on the next in-game calendar day
after the preceding lesson. Choose **Recite it back** to finish each lesson
once and add one to **Surahs learned with Idris** in the private Journal.

## LOCK 80 — Stories of the prophets after Isha

At the River Market masjid from 19:10 up to 21:30, choose **Idris is telling
a story after Isha**. Yusuf, Ibrahim's guests, Nuh, Yunus and Musa and the wise
servant follow in order. Each later story becomes available two in-game days
after the preceding story. Choose **Thank him** to finish each story once and
add one to **Stories of the prophets heard** in the private Journal. The
stories leave trust unchanged.
