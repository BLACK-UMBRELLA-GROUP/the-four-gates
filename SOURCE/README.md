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
The title opens first; Begin starts at the quay in River Market. These are placeholder shapes; gameplay first.
LOCK 1 parts 1–2 provide the street layout, collision, capsule player, camera, maps, day/night switch and task board.
Use E at the board to take the three tasks, choose the honest or quick way, earn coins/trust, put quick choices right
and unload a boat once each day. Amends return the trust actually lost plus the honest reward. Only night turning
to day restores the daily job. Coins start at 0 and trust at 20 / 100; trust stays within 0–100.
The scales lesson, gate progression and goal panel are later work. Their actions show the approved temporary message;
the gate stays closed. There is no shop yet.

WASD moves, mouse turns the third-person camera, Shift runs, E uses the nearby place, M opens/closes the market map,
G shows the temporary goal message, T switches day/night, and Esc closes panels or releases the mouse. Click the world
to capture the mouse again. Map place markers choose a walking route along the approved streets; the player moves
physically. City map opens from the market map; its River Market area returns to the market map.

The unchanged locked `GAME/APPROVED/FOUNDATIONS/RECORD/foundations_data_V2.json` is copied to
`SOURCE/data/foundations.json`. One loader reads it and configures runtime bindings from its keys. Content and gameplay
settings stay in portable JSON. No art assets, plugins, packages or exports were added.

## Checks and evidence

Run the plain GDScript checks from the repository root:
`godot --headless --path SOURCE --script res://tests/run_tests.gd`

Use `--log-file /private/tmp/tfg-tests.log` if the sandbox cannot write the default engine log.
Tests exercise actual capsule movement/collision, quay-to-gate walking, stepping, wall pull-in, production map routing,
data-driven input, real task/choice/result buttons, amends economics and daily job transitions. The headless display checks look transforms; native capture separately
checks actual mouse dispatch and both pitch limits.

`godot --path SOURCE -- --capture-foundations` records native 1920×1080 viewport PNGs and
`MEASUREMENTS.json` under `GAME/APPROVED/FOUNDATIONS/BUILT/V1/`. It measures day and night using three seconds of
warm-up and rendered frames over ten seconds per mode, with vsync disabled. Captures include f01–f05 states,
three world views and temporary action/toast states. `BUILD.json` records the source commit and honest visual differences.
Run `godot --headless --path SOURCE --script res://tests/create_comparisons.gd` after native capture to create the five side-by-side PNGs, with the approved master on the left and actual game on the right.

`godot --path SOURCE -- --capture-tasks` captures the six part-2 master states f06–f11 plus gameplay checks and
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
