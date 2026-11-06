# THE FOUR GATES

An open-world adventure in stylised 3D, set in an old Arabian city at the height of its golden age of learning. You
arrive with nothing and make your way by taking on tasks, trading, exploring the city and the land around it, and
learning from the scholars, craftspeople and merchants who live there. The choices you make - how you trade, what you
do with what is yours and what is not - shape how the city sees you.

It is for players who enjoy exploration-led open worlds with a gentle, story-rich setting, and for anyone curious about
a period when a city's libraries, markets and workshops were the centre of the known world.

## Status

LOCK 1 part 1 is playable in Godot: River Market streets and collision, a third-person capsule player,
place actions, market/city maps and day/night lighting. Placeholder shapes; gameplay first.
The gate is closed. Tasks, earning, the scales lesson and gate progression are the next approved queue parts.
The earlier disposable look test remains available as an explicit scene.
See [ROADMAP.md](ROADMAP.md) for the planned game.

## Built with

- [Godot 4](https://godotengine.org) (MIT licence) and GDScript.
- Text-based scenes and resources, so every part of the game can be read, reviewed and changed.
- Asset sources and licences are listed in [SOURCE/assets/CREDITS.md](SOURCE/assets/CREDITS.md).

## Run it

1. Install Godot 4 (the exact version is recorded in [SOURCE/README.md](SOURCE/README.md)).
2. Open Godot, choose **Import**, and pick `SOURCE/project.godot`.
3. Press **Run**, then **Begin** to start at the quay.

WASD moves, mouse looks, Shift runs, E uses a nearby place, M opens the map, G shows the temporary goal message,
T switches day/night, and Esc closes maps or releases the mouse. Map markers choose a physical walking route.
Run `godot --headless --path SOURCE --script res://tests/run_tests.gd` for the plain automated checks.
[Source instructions](SOURCE/README.md) cover native captures, frame-rate measurement and the old look-test scene.

No accounts, keys or services are needed.

## Repository layout

- `SOURCE/`: the Godot 4 project.
- `GAME/`: game design overview and the approved build queue.
- `ARCHIVE/`: earlier versions of documents.
- `AGENTS.md` and `MAP.md`: working rules and document routes.
- `ROADMAP.md`: planned work.

## How work is done

The game is designed in conversation with an AI design assistant and built with an AI coding assistant. Shakeel
approves ("locks") each design before it is built; every build comes from an approved brief in
`GAME/APPROVED/BUILD_QUEUE.md`.

## License

Apache License 2.0 - see [LICENSE](LICENSE) and [NOTICE](NOTICE).
