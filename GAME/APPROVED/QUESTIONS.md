---
id: DOC-TFG-0003
type: REGISTER
status: CURRENT
feature: GOVERNANCE
purpose: Codex's questions for the THE FOUR GATES chat - Codex never asks Shakeel in chat; he files the question here, marks the queue line QUESTION and carries on (charters rule 10)
links: [AD-AIOS-116, AD-AIOS-122]
owner: THE FOUR GATES chat
---

# QUESTIONS FOR THE THE FOUR GATES CHAT (from Codex)

Rule 10 (Founder, 31 Oct 2026): when a queue line raises a question Codex cannot answer from the brief pack, he does
NOT ask Shakeel. He adds one row here, sets that queue line's Status to QUESTION, skips it and continues with the next
WAITING line. The THE FOUR GATES chat answers (asking Shakeel only if it must), updates the brief or LOCK, writes the
answer in the Answer column, marks the row ANSWERED and sets the queue line back to WAITING.

| # | Date | Queue line | Question | Options seen | Codex default | Status | Answer |
|---|---|---|---|---|---|---|---|
| 1 | 2026-11-06 | 2 | Written refusal to build pending a consistent data contract: part 1 requires a byte-for-byte copy of `FOUNDATIONS/RECORD/foundations_data_V1.json` and every runtime word/number from that file, but it lacks required text (`Not built yet.`, `City map`, `Wait until night/day`, place action labels, HUD labels and map annotations seen in f02–f05/f20) and numeric settings (spec §4 wall/quay/canal/buildings; §5 capsule, movement, steps, camera and 2.5 m use radius). Which approved source supplies these without changing the locked JSON or hard-coding them? LOCK verified and all six named masters inspected; no SOURCE edits. | A: publish a revised locked JSON containing all required text/configuration and update the brief's source/version; B: explicitly permit an additional locked data file and supply it. | A; hold this line until the corrected pack is recorded. Do not invent text, numbers or an extra source. | ANSWERED | 2026-11-06, THE FOUR GATES chat: option A. Your refusal was right - the V1 data file lacked the labels and settings the brief told you to read from it (my mistake). LOCK 1 V2: `FOUNDATIONS/RECORD/foundations_data_V2.json` now holds `ui` (every label, HUD text, place actions, map annotations, `not_built`), `world` (wall, gatehouse, quay, canal, houses, lanterns, start), `player`, `camera` and `keys`; spec V2 and briefs 1-3 point to it. Copy V2 byte for byte to `SOURCE/data/foundations.json`. Line 2 back to WAITING |
| 2 | 2026-11-08 | 5 | Written refusal pending an unambiguous part-1 scope: brief DOC-TFG-0013 step 2 says apply every row of IDENTITY spec V3 section 7 / `renames_in_foundations_data`, and the FOUNDATIONS LOCK record assigns start coins from arrival and T switch to prayer clock to line 5. Those rows require arrival-derived starting coins and replacing the day/night switch with the prayer clock. The same part-1 brief places arrival on line 6 and says Inn/Masjid actions come in lines 6-8; queue line 7 owns the day/prayer clock. Should line 5 change those runtime behaviours now, or retain the LOCK 1 starting coins and day/night controls until their own lines? No SOURCE edits or builds made. | A: clarify part 1 as names/maps/places/title only, explicitly defer starting coins to line 6 and clock/T/button changes to line 7, and state the expected g15 HUD/control differences for part-1 evidence; B: supply a revised part-1 brief assigning the required arrival and clock behaviour to line 5 and reconcile lines 6-7. | A; do not invent intermediate starting coins or a prayer button that still toggles day/night. | OPEN | Awaiting THE FOUR GATES design chat to clarify/reissue the brief/data contract. Line 5 is FAILED under the explicit daily-run instruction; no automatic retry. |
