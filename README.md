# THE FOUR GATES

An open-world adventure in stylised 3D, set in an old Arabian city at the height of its golden age of learning. You
arrive with nothing and make your way by taking on tasks, trading, exploring the city and the land around it, and
learning from the scholars, craftspeople and merchants who live there. The choices you make - how you trade, what you
do with what is yours and what is not - shape how the city sees you.

It is for players who enjoy exploration-led open worlds with a gentle, story-rich setting, and for anyone curious about
a period when a city's libraries, markets and workshops were the centre of the known world.

## Status

Started 2 Nov 2026. The game is being designed. A disposable Godot look test shows a stylised market street,
city gate and canal in day, night and dusk lighting. It has free-look and four fixed camera views, with no gameplay.
The scene is a Founder-named engine evaluation and has not been locked as game design.
See [ROADMAP.md](ROADMAP.md) for the planned game.

## Built with

- [Godot 4](https://godotengine.org) (MIT licence) and GDScript.
- Text-based scenes and resources, so every part of the game can be read, reviewed and changed.
- Asset sources and licences are listed in [SOURCE/assets/CREDITS.md](SOURCE/assets/CREDITS.md).

## Run it

1. Install Godot 4 (the exact version is recorded in [SOURCE/README.md](SOURCE/README.md)).
2. Open Godot, choose **Import**, and pick `SOURCE/project.godot`.
3. Press **Run** to open the look test. Hold right mouse to look and use WASD to fly.

F1–F4 choose street, gate, river and market views; F5/F6/F7 change day/night/dusk.
[Source instructions](SOURCE/README.md) cover camera controls, native screenshot capture and frame-rate measurement.

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
