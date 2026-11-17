---
id: DOC-TFG-0322
type: PLAN
status: CURRENT
feature: OVERVIEW
purpose: How THE FOUR GATES moves from Godot to Unreal Engine - when, on what PC, how Codex builds in Unreal, and the steps - Founder 12 Nov 2026
links: [DOC-TFG-0001, DOC-TFG-0002, AD-AIOS-141, AD-AIOS-122]
owner: THE FOUR GATES chat
---

# THE FOUR GATES — MOVING TO UNREAL ENGINE (PLAN V1)

## 1. Purpose and scope

The Founder wants the game in Unreal Engine with much better graphics (12 Nov 2026: "i think we gotta look to switch to unreal engine tho cos gadot aint for me im aware we need a more powerful windows pc but yeh everything gotta have better graphics").
This plan covers the timing, the PC, how Codex can build in Unreal, the order of the move and the risks. It does not change any LOCK: every LOCK is written in plain rules, words and numbers, not in Godot terms.

## 2. Decisions (Founder, 12 Nov 2026, clickable)

| # | Decision | Founder's answer |
|---|---|---|
| 1 | When to switch | **"Godot keeps building rules, Unreal when PC is ready (Recommended)"** |
| 2 | Write this plan | **"Yes, write the plan (Recommended)"** |

This follows the earlier decisions: 4 Nov (stay on Godot for now, keep content in data files so a switch stays cheap, final engine check when the gaming PC is ready) and 6 Nov (build gameplay in Godot, move to Unreal for the realistic look).

## 3. What carries over and what does not

| Part | Carries over? | Why |
|---|---|---|
| The 109 LOCKs, specs and briefs | Yes, unchanged | Plain rules, not engine code |
| Every word and number (`*_data_V*.json`) | Yes, byte for byte | Unreal can load the same JSON files (DataTables import JSON, or a C++ loader) |
| The Godot tests (5,800+ checks) | Yes, as the checklist | Each test states inputs and expected results; Unreal must pass the same list |
| The prototype and the 3D world map draft | Yes, as the design target | The map's heights and roads can be exported as a 16-bit heightmap and road lines for an Unreal Landscape |
| Godot scenes and GDScript | No | Rewritten in Unreal (C++ for rules, Unreal tools for art) |
| Godot placeholder art | No | Replaced by real art |

## 4. Hardware

Unreal's best features (Nanite, Lumen, large open worlds) want a strong Windows PC with an NVIDIA RTX graphics card with 16 GB of video memory, at or above Epic's recommended specification. On Mac, Epic recommends Apple Silicon M3 with 32 GB; Nanite needs M2 or later and is beta there.

The hardware choice is the Founder's and is kept in the private Group folder, not in this repository.

Software: Windows 11, Visual Studio 2022 (C++ game tools), Git and Git LFS, Unreal Engine 5 (latest).

## 5. How Codex builds in Unreal

| Rule | Detail |
|---|---|
| Rules in C++ | Codex writes game rules in C++ (text files it can read, diff and test). No game logic in Blueprints: Blueprints are binary files an AI cannot reliably read or edit |
| Words and numbers in JSON | The same `SOURCE/data/*.json` files, loaded at start; nothing typed into Unreal by hand |
| Tests from the command line | Unreal's automation tests run headless from a terminal; the Godot test list is ported first and must pass |
| Screenshots | Unreal automation screenshots need the graphics card, so captures stay a night job (AD-AIOS-141 night-only rule continues) |
| Art | From licensed asset libraries (Fab / Quixel Megascans and similar) and Blender, imported by Unreal's Python editor scripts so imports are repeatable. Each pack's licence recorded |
| Repository | Git with Git LFS for large binary files; the size limits and storage cost of LFS need checking before the first art import |
| Machine | Codex runs on the Windows PC for Unreal work; the Mac keeps the documents and chats |

## 6. Steps

| Phase | When | What | Done when |
|---|---|---|---|
| 0 | Now (Mac) | Godot queue keeps building the rules at night (lines 42-109). The design chat keeps designing the world map and the look. No new Godot art work | Queue finished or PC ready, whichever first |
| 1 | PC ready | Install Windows, Visual Studio, Unreal, Git LFS. Codex creates an empty Unreal project in its own folder and one JSON loader with one passing test | Empty project opens, one test passes |
| 2 | +1 week | **Unreal look test**: the world from the 3D map draft as a real landscape (heightmap import) and River Market built with real art. The Founder judges it, as with the Godot look test (4 Nov) | Founder approves the look |
| 3 | After 2 | Port the rules in the LOCK order (clock and prayers, trust, tasks, people, the scene runner, then the towns), each line passing its old Godot checks | All ported lines pass |
| 4 | After 3 | Godot project archived (kept for history), Unreal becomes the only build | Founder confirms |

## 7. Risks

| Risk | Effect | Mitigation |
|---|---|---|
| Codex is weaker at Unreal than at Godot | Slower builds, more questions | C++ and JSON only; small queue lines; tests first |
| Art takes far longer than code | Graphics lag behind rules | Use licensed asset packs; Founder judges look tests early |
| Big binary files in git | Repository grows fast; storage cost | Git LFS; check limits before importing art |
| Two machines (Mac + PC) | Files out of step | One repository; the PC builds, the Mac plans |
| The 800-hour estimate grows | Later release | Re-estimate after the Unreal look test |

## 8. Dependencies and decisions still needed

| Item | Owner |
|---|---|
| Record the engine move in the decision register and the ROADMAP | Fable (admin) |
| The Windows PC | Founder |
| New repository or the same one for the Unreal project | Founder, on Fable's advice, before phase 1 |
| Which asset libraries and their licences | Design chat proposes, Founder approves, before phase 2 |

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-12 | V1 | First plan after the Founder's 12 Nov decisions |
| 2026-11-16 | V1 | Parts list moved to the private Group folder (OA-AIOS-445); no decision changed |
