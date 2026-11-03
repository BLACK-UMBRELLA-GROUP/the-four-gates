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

Open the look test: import `SOURCE/project.godot` in Godot 4.7.2 and press Run (or run `godot --path SOURCE` from the repository root).

The Founder-named look test is a disposable scene for judging the engine, not a locked game design.
Hold the right mouse button to look; WASD flies, Q/E lowers/raises, Shift moves faster, and Escape releases the mouse.
F1–F4 select street, gate, river and market views; F5/F6/F7 select day/night/dusk. No interface text appears in the scene.

To reproduce the six actual 1920×1080 viewport screenshots and day/night measurements, run
`godot --path SOURCE -- --capture` from the repository root. Results overwrite the six final PNGs and
`MEASUREMENTS.json` in `GAME/APPROVED/LOOK_TEST/BUILT/`. `--measure` records performance only,
and `--check-controls` exercises camera and lighting input. Measurements disable vsync, warm up for
three seconds, then count rendered frames over ten seconds for each lighting mode. The render viewport
is 1920×1080 even when the desktop window is smaller. Forward+ uses Metal, 2× MSAA with TAA, SSAO, SSIL, glow,
soft shadow maps and light fog. There are no exports or downloaded assets.
