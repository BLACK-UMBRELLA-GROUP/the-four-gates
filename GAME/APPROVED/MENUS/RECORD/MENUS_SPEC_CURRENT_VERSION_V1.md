---
id: DOC-TFG-0096
type: SPEC
status: CURRENT
feature: MENUS
purpose: LOCK 29 - menus - the Esc pause menu, saving and continuing, and the settings screen (text size, walking speed)
links: [AD-AIOS-115, AD-AIOS-137, DOC-TFG-0006, DOC-TFG-0011, DOC-TFG-0063, DOC-TFG-0097]
owner: THE FOUR GATES chat
---

# MENUS SPEC — CURRENT VERSION V1 (LOCK 29)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `menus_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 1 (title screen with its Settings button - its toast is replaced), LOCK 2 V5 (the Settings button stays - AD-AIOS-137), LOCK 18 (the date). Queue line 36 comes after line 35 |
| Masters | `../MASTERS/mn01`-`mn09` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V84 |
| ROADMAP | Advances "Save, menus and polish" (save and load, pause menu, settings). The playable Mac build is not in this LOCK, so the row stays open |

## 1. Pause (masters mn04-mn06)

| Rule | Number / words |
|---|---|
| Open / close | Esc on the market map opens `pause`; Esc in the pause menu returns to the map; Esc in settings goes back to where settings was opened from |
| Panel | `pause.title`; after saving, `pause.saved` (d = date · time from LOCK 18, e.g. "Thursday 1 Sha'ban · 10:00"); buttons `resume`, `save`, `settings`, `quit`; then `pause.hint` |
| Save game | Stores the whole game state in one save slot (replacing the last), kept when the game is closed |
| Save and quit | Saves, then shows the title |

## 2. Title (masters mn01, mn08, mn09)

When a save exists, the title shows `title_continue` (d = the save's date · time) first, as the main button; Begin is then a normal button. Continue loads the save onto the market map. The Settings button opens settings (§3) instead of LOCK 1's toast.

## 3. Settings (masters mn02, mn03, mn07)

| Row | Choices | Effect |
|---|---|---|
| `settings.text_size` | `normal` / `large` | Large scales every game text by `large_text_percent` (115%). A panel that becomes taller than the screen scrolls; its buttons stay reachable |
| `settings.walk` | `normal` / `fast` | Walking speed on the market map (`walk_normal` 110 / `walk_fast` 220 in prototype units - in Godot, fast = twice the normal walking speed) |

The chosen option is highlighted. Settings are kept between games and are not part of the save. Then `settings.later` and `settings.back` (returns to the title or the pause menu). Every setting changes the game (no setting that only changes the screen).

## 4. Masters

| Master | Shows |
|---|---|
| mn01 | Title with no save |
| mn02, mn03 | Settings from the title; Large and Fast chosen |
| mn04-mn06 | Market map; Esc → Paused; after Save game |
| mn07 | Settings from the pause menu |
| mn08, mn09 | Title with Continue; continued onto the map |

## 5. Not in this LOCK (do not build)

Several save slots, autosave, sound and volume, the real-life prayer reminder (a later settings LOCK), key rebinding, the Mac build.

## 6. Build rules

Words and numbers only from `menus_data_V1.json` (copied byte for byte to `SOURCE/data/menus.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 29. Founder via Fable 9 Nov (AD-AIOS-137): "WELL THERE WOULD BE A SETTING BUTTON O FOR THAT I WAS IN ERROR IF I SAID THAT"; 9 Nov: **"LOCK it (Recommended)"** after V83 |
