---
id: DOC-TFG-0093
type: SPEC
status: CURRENT
feature: REGULARS_REMEMBER
purpose: LOCK 28 - characters, the regulars remember - one extra memory line in the LOCK 6 talk panel per regular, from what they saw or heard in later LOCKs; secret deeds stay secret
links: [AD-AIOS-115, DOC-TFG-0027, DOC-TFG-0045, DOC-TFG-0054, DOC-TFG-0057, DOC-TFG-0081, DOC-TFG-0084, DOC-TFG-0087, DOC-TFG-0094]
owner: THE FOUR GATES chat
---

# REGULARS REMEMBER SPEC — CURRENT VERSION V1 (LOCK 28)

| Field | Value |
|---|---|
| Locked | 9 Nov 2026, Founder clickable **"LOCK it (Recommended)"** - record `LOCK_RECORD.md` beside this file |
| Words and numbers | `regulars_remember_data_V1.json` beside this file (exported from the prototype's own data object) |
| Builds on | LOCK 6 (talk panel: tier line, fact line, greeting, tip), LOCK 9 (feeding), LOCK 11 (dice), LOCK 12 (jars), LOCK 15 (fountain), LOCK 16 (loan), LOCK 24 V2 (pilgrims), LOCK 25 (school), LOCK 26 (Names). Queue line 35 comes after line 34 |
| Masters | `../MASTERS/rm01`-`rm17` at 1920 × 1080 |
| Prototype | "The Four Gates Prototype" V82 |
| ROADMAP | "Characters and dialogue" (closed by line 13); no new row |

## 1. Rules over everything

| Rule | Meaning in this LOCK |
|---|---|
| People decide, a bit like Fable (Founder 6 Nov) | Each regular remembers what they could have seen or heard |
| Secret giving stays secret (LOCK 3) | Secret deeds are never remembered as yours; a pilgrim sent in secret thanks "someone" |
| No hiding sins behind kindness | In each list the bad memories come before the good ones |

## 2. The memory line

In the LOCK 6 talk panel the lines are: the tier line, the LOCK 6 fact line (if any), then **one memory line**: the first entry in `memories.<id>` whose key is true, else nothing (rm17). Greeting reply and tip come after, as in LOCK 6.

| Key | True when |
|---|---|
| `jars_seen` | LOCK 12 trust hit at run 4 has happened |
| `dice_seen` | LOCK 11 trust hit at night 4 has happened |
| `fountain_named` | LOCK 15 fountain runs with your name |
| `feeds` | LOCK 9 public feeding has happened |
| `loan_riba` / `loan_demand` / `loan_forgive` / `loan_wait` | LOCK 16 choice made |
| `school` | LOCK 25: at least one child in school and a public school payment |
| `umrah_jamal` / `umrah_musa` | LOCK 24: that pilgrim home from a public trip |
| `umrah_jamal_secret` / `umrah_musa_secret` | LOCK 24: that pilgrim home from a secret trip |
| `name_hasib` | LOCK 26: Al-Hasib learned |

Order per regular (first true wins): as in the data file.

## 3. Masters

| Master | Shows |
|---|---|
| rm01-rm05 | Rashid: riba; demand; dice before a kindness; let ten go; waited |
| rm06-rm08 | Salma: jars before the fountain; the fountain; bread |
| rm09, rm10 | Layla: Faris's slate; the fountain |
| rm11-rm13 | Jamal: Qasim's boat; his Umrah; secret Umrah |
| rm14-rm16 | Old Musa: his Umrah; secret Umrah; Al-Hasib |
| rm17 | Layla with no memory yet |

Trust 45 (wary tier), set for the pictures. LOCK 6 fact lines (Layla's clothes, Old Musa's scales) show where LOCK 6 gives them.

## 4. Not in this LOCK (do not build)

Memories for Karim, Abbas, Saeed, Idris (his are LOCK 14), more than one memory line at a time, memories fading over time.

## 5. Build rules

Words only from `regulars_remember_data_V1.json` (copied byte for byte to `SOURCE/data/regulars_remember.json`) and the earlier data files. Placeholder shapes only; no art, no exports.

## Version history

| Date | Version | Change |
|---|---|---|
| 2026-11-09 | V1 | LOCK 28. Founder 6 Nov: trust "people will decide a bit liek fable", "Named regulars + crowd (Recommended)"; 9 Nov: **"LOCK it (Recommended)"** after V81 |
