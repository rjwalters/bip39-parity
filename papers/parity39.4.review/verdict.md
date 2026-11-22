# Verdict — parity39.4

Total: 36 / 44
Decision: advance: true

Rubric `anvil-pub-v2`, threshold 35. No critical flag is raised, so the paper advances to `READY` and should go to `paper-audit`. It is scored as it stands, at the round-three standard. The total equals round three's (36): the revision closed the audit's critical flag and several small items, none of which carried a full point on its own, and left the items that hold points (source availability, repetition and length, naming, related-work lead, moving URLs) as they were. The margin is one point.

## Critical flags

None raised.

Candidates weighed:

- **Numerical inconsistency (the `parity39.3.audit/` flag).** Resolved. §5.3 (L561-565) now reads "card parity and the grid decoder without a digest both returned a wrong secret (the bracketed 0.2)". `grid-main-k4.txt` L31 gives checksum only 0.5 / 0.0, card parity 50.7 / 0.2, parity + digest 50.7 / 0.0, grid without digest 50.7 / 0.2, grid with digest 50.7 / 0.0, and Table 2 brackets exactly those two columns. It is the only row in the six grid logs with a wrong answer outside the foreign-card rows.
- **Numerical inconsistency (new sentences).** None found. Every figure in the edited sentences was recomputed from the logs: filtered unique-repair rates of at least 99.5% for the faults listed (minimum cells 99.5 at 24+2 any swap, 12+3 two dropped, 12+3 and 24+3 wrong + dropped); unfiltered swaps at k = 2 of 94.0, 96.5, 87.0, 84.5; unfiltered two dropped and wrong + dropped at k = 3 of 96.0, 82.0, 92.5, 76.0; two wrong words at k = 4 of 100 in all four cells; 31,600 = 34·400 + 20·300 + 48·250, with 0 wrong in both digest columns of all 102 rows. "41 ... (of 92)" matches the study extract (26 + 15 failed BIP-39 of N = 92). The abstract's 99.5 / 31 and 61 / 41 are 99.5 / 30.5 and 61.2 / 40.7 in Table 2 and the log.
- **Missing experiment for a claim.** §4.2 describes what the implementation does with a mislabelled card and now says in the same paragraph that no experiment enters one. The description was checked against `Repair.repair` and `Grid.readCard` and is accurate. A described and disclosed-as-untested behaviour is a scored scope finding (U2), not a claimed measurement.
- **Citation error.** `refs.bib` is unchanged; all keys resolve. The reworded disk-array sentence claims less than before.
- **Unobtainable source.** Disclosed in §8 with digests that match the working tree; scored under dim 5 (U1), as in rounds two and three.

## Dimension summary

| # | Dimension | Weight | Score |
|---|---|---|---|
| 1 | Rigor of method / argument | 6 | 5 |
| 2 | Evidence sufficiency | 6 | 5 |
| 3 | Clarity of contribution | 5 | 5 |
| 4 | Related-work positioning | 5 | 4 |
| 5 | Reproducibility | 5 | 3 |
| 6 | Figure & table quality | 4 | 4 |
| 7 | Prose & structural quality | 4 | 3 |
| 8 | Citation hygiene | 5 | 4 |
| 9 | Rhetorical economy | 4 | 3 |
| | **Total** | **44** | **36** |

The dim 7 cap (three or more confirmed define-before-use defects in the body) does not apply: two are confirmed this pass, both introduced by this revision (U7).

## Remaining revision items, ranked

The paper advances; these are what the author, or a further pass, should take up. Line numbers are `parity39.4/main.tex`.

| Rank | Item | Where | Dim | Severity |
|---|---|---|---|---|
| U1 | Source tree not obtainable: no public URL, commit or archive; the digests pin a tree no reader can fetch, and the README records uncommitted changes (T1, open; needs the author) | L705-709 | 5 | major |
| U2 | Evidence scope: no trial enters a mislabelled card (now disclosed) or a foreign card with illegible numbers; one seed; independent uniform substitutions. §4.2 residue: a mislabelled card is kept only if it has the right count of words, is dropped if its corrected number duplicates a card already read, and when kept is used at the entered number's evaluation point (T2, text resolved, test open) | L296-302, L333-335, L404, L677-680 | 2, 1 | major |
| U3 | Related-work lead: repair of a near-miss mnemonic by bounded search against the checksum or a known address is not positioned against parity words (T3, not changed) | L54-63, L93-111 | 4 | minor |
| U4 | Repetition and length: no-wrong-secret five times, exactly-t caveat seven times, assumed-rate caveat four times; 13 pages against the brief's 10; this revision adds lines and removes none (T4, not changed) | L35, L566-567, L585, L608, L739 and as listed in `comments.md` | 9 | minor |
| U5 | Naming drift: six labels for per-card repair, four for the grid decoder; "Checksum only" against the BIP39 checksum; "row" for unwritten rows, cards and table rows; "holders" as the unit of m; "burnt" for a destroyed card; "hash check" for the digest (T5, not changed) | L32, L84, L261, L331, L406, L409, L518, L524-526, L546, L576, L643, L737 | 7 | minor |
| U6 | Floats and tables: Fig. 2 prints on page 9, two pages after its discussion; Table 1 prints inside §5.3; Table 1 column heads (N+k) not glossed; the k = 2 two-dropped-words cells (0 / 1, 0 / 30) are not explained in the text; Fig. 2 shows three of five methods without saying the other two coincide; Fig. 1 side labels touch the header boxes (T7, not changed) | L443-449, L513-521, L200, `figures/rates.tex`, `figures/grid.tex` | 6, 7 | minor |
| U7 | Small defects introduced by this revision: "unconfirmed evidence" is used in §4.2 before step 1 of §4.4 defines it; "(of 92)" gives 45%, which matches neither the 40% nor the 49% beside it, with no word that the 41 pools both groups; "the two-edit rows" is a new label with no definition, clashes with "edits plus substitutions" at L187, and could be read to include two wrong words (refused at k = 3); "the one wrong answer in these runs" sits one paragraph after foreign-card rows that return wrong answers; "Our experiments never enter a wrong number" repeats L404 in the construction section; the abstract says "digest" where the introduction says "hash check" | L300-302, L56, L436-437, L561-562, L301-302, L35 | 7 | minor |
| U8 | Specification and repository entries cite moving `master` URLs with no revision or access date; SOUPS entry has no pages (T8, not changed) | `refs.bib` | 8 | minor |
| U9 | Carried nits: no example for "a better decoder exists"; the pooled bound of about 1e-4 mixes scenarios of different risk | L686-687, L567-570 | 1 | nit |

## Status of round-three items

Checked against the text, the Lean sources and the logs, not against `changelog.md`. Detail in `comments.md`.

| Item | Status |
|---|---|
| Audit flag: "both methods without a digest" | Resolved |
| T1 source not obtainable | Open (U1) |
| T2 wrong-number claim | Text resolved and accurate; still untested, now disclosed (U2) |
| T3 related-work lead | Not changed (U3) |
| T4 repetition and length | Not changed (U4) |
| T5 naming drift | Not changed (U5) |
| T6 "repair" stated flat | Resolved; one new label (U7) |
| T7 floats | Not changed (U6) |
| T8 URL revisions | Not changed (U8) |
| T9 referents | Resolved; "(of 92)" needs one more word (U7) |
| T10 precision nits | Five of seven resolved; two carried (U9) |
| Audit notes: decoder step 5, dual-parity sentence, inferred cause | Resolved |

## Pre-flight summary

- Pending markers: none; nothing holds the `READY` transition.
- Evidence drift: `CLEAN`.
- Render gate: not run (`parity39.4.audit/compile-log.txt` does not exist yet). `main.log` read by hand: 13 pages, no overfull box, one underfull box in the bibliography, no undefined reference or citation. `main.pdf` contains the revised sentences.
- Numeric-consistency, audience, reader-flow lint, float-proximity and the reader-flow lens all ran; results in `comments.md`.
- No venue overlay and no artifact verification (`parity39/.anvil.json` absent). `lake` was not run.
