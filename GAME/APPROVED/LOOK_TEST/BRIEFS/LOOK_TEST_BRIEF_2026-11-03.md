---
id: DOC-TFG-0005
type: PLAN
status: CURRENT
feature: LOOK_TEST
purpose: Build brief for Codex - a small stylised Godot 4 scene (a market street at night with lanterns, and by day) so the Founder can judge Godot's look before the engine is final
links: [AD-AIOS-122, OA-AIOS-423]
owner: Fable (Founder-named task; the THE FOUR GATES chat takes over design once it is open)
---

# BUILD BRIEF — GODOT LOOK TEST — 3 Nov 2026

**Founder decision (3 Nov 2026, clickable question in the BLACK UMBRELLA GROUP chat):** asked Godot 4 vs Unreal 5, he
chose **"See a Godot look test first"** - a quick stylised scene so he can judge Godot's look before deciding. This is a
throwaway look test, not gameplay and not a LOCK: nothing here becomes part of the game unless the design chat later
locks it.

## What to build

One small scene, `SOURCE/look_test/look_test.tscn`, about 60 x 30 metres:

| Element | Detail |
|---|---|
| Street | A short market street of packed sand and worn stone, gently curving, ending at an arched city gate |
| Buildings | Two- and three-storey plastered mud-brick houses in warm sand and ochre tones, flat roofs, arched doorways, wooden balconies, a few awnings in deep red, indigo and saffron cloth |
| Market | A few stalls with crates, pots, rugs and baskets (simple shapes are fine) |
| Water | A river edge or canal along one side, with a small stone quay |
| Lanterns | 10-15 hanging and wall lanterns with warm light (the night shot depends on them) |
| Sky | Day: warm afternoon sun and soft clouds. Night: deep blue sky, moon, stars |
| Atmosphere | Light fog or haze, soft shadows, global illumination if it runs well on the Mac mini |
| Style | **Stylised**, not photo-real: clean shapes, soft colours, painterly feel (Founder choice, 2 Nov) |
| Camera | A free-look camera the Founder can move with mouse and WASD, plus 4 fixed shots |
| Words | No text, signs or symbols of any religion anywhere in the scene |

## Assets and rules

- Only assets you may publish openly: made by you in Godot (primitive meshes, CSG, shaders) or **CC0** packs (for
  example Kenney, Quaternius, Poly Haven, ambientCG). Record each one in `SOURCE/assets/CREDITS.md` (name, source URL,
  licence). Nothing with a non-commercial or "no redistribution" licence.
- Keep the whole look test under **40 MB** in the repo; no single file over 10 MB (use 1K textures). Text scenes only.
- Renderer: Forward+ (Mac Metal). If it runs below 30 fps on the Mac mini, lower settings and say so.
- No gameplay, scripts beyond the camera and the screenshot helper, plugins or exports.

## What to deliver

1. Screenshots at 1920x1080, saved with a small capture script, into `GAME/APPROVED/LOOK_TEST/BUILT/`:
   `01_street_day.png`, `02_street_night.png`, `03_gate_night.png`, `04_river_night.png`,
   `05_market_day.png`, `06_overview_dusk.png`.
2. Frame rate on the Mac mini for day and night (fps), and disk size of the look test.
3. How to open it: one line in `SOURCE/README.md`.
4. Task note with "Built from: this brief", public checks A-F, commit and push (core rule 2).

If a fresh queue chat cannot write to the repo or download assets, the line waits for group line 20 (write access) -
mark it WAITING with "waits for group line 20", never FAILED.
