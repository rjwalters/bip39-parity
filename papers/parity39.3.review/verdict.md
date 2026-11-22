# Verdict — parity39.3

Total: 36 / 44
Decision: advance: true

Rubric `anvil-pub-v2`, threshold 35. No critical flag is raised, so the paper advances to `READY` and should go to `paper-audit`. It is scored as it stands; the earlier totals (27, 33) are not inputs. The margin is one point, and the largest open item (T1, source not published) can only be closed by the author.

## Critical flags

None raised.

Four candidates were weighed:

- **Numerical inconsistency.** None found. Every cell of Tables 1-4, every point of Fig. 2, and every percentage and count in the abstract and prose was re-read against `refs/experiments/`; 31,600 = 13,600 + 6,000 + 12,000 over six grid files; the bound (C(5,3)+1)·2^-22 = 2.6e-6, the swap expectation 325·26/2047 = 4.1, the rule-of-three figures and the four confidence half-widths are right. The two critical flags of `parity39.2.audit/` ("five grid files"; §5.2 against Table 1 at k = 3) are both corrected in the text.
- **Missing experiment for a claim.** §4.2 now states that a card entered with the wrong number is corrected and reported. No trial exercises this. It is a description of the implementation, and it was checked by reading `Repair.repair` and `Grid.readCard`: it is accurate while the card has parity to spare and incomplete beyond that (T2). That is a scored finding under dims 1 and 2, not a claim of a measured property without its measurement.
- **Citation error.** All cited keys resolve. The one source on disk (the SOUPS extract) supports the introduction's figures: 60% and 51% success, so 40% and 49% failure; 14 of 41 failed participants recoverable; all 14 one wrong word, or one wrong word plus a change of order.
- **Unobtainable source.** Disclosed in §8 with file digests that match the working tree. A disclosed reproducibility gap is a dim 5 score (3 / 5), as in round two.

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

The dim 7 cap (three or more confirmed define-before-use defects in the body) no longer applies: one is confirmed this pass.

## Remaining revision items, ranked

The paper advances; these are what a further pass, or the author before posting, should take up. Line numbers are `parity39.3/main.tex`.

| Rank | Item | Where | Dim | Severity |
|---|---|---|---|---|
| T1 | Source tree not obtainable: no public URL, commit or archive; digests pin a tree no reader can fetch (S2, open; needs the author) | L695-699 | 5 | major |
| T2 | Wrong-number claim is unqualified and untested: holds only with k ≥ 2 and uses one of the ⌊k/2⌋ correctable symbols; beyond that the card is kept as unconfirmed evidence under the number entered. Evidence scope otherwise as in round two: one seed, uniform independent substitutions, no foreign-card-with-illegible-numbers trial (S6, partly resolved) | L293-296, L327-329, L396, L667-670 | 1, 2 | major |
| T3 | Related-work lead: repair of a near-miss mnemonic by bounded search against the checksum or a known address (existing recovery tools; the cited study's own method) is not positioned against parity words | L54-63, L93-98 | 4 | minor |
| T4 | Repetition and length: no-wrong-secret five times, exactly-t caveat seven times, assumed-rate caveat four times; 13 pages against the brief's 10 (S11, not resolved) | L35, L556-557, L575, L598, L728; L34-35, L79-80, L565-567, L632-633, L646-649, L681-682, L728-730; L52-54, L86-88, L667-669, L689 | 9 | minor |
| T5 | Naming drift: five names for per-card repair and four for the grid decoder; "Checksum only" collides with the BIP39 checksum; "row" for both unwritten rows and cards; "holders" as the unit of m; "burnt" for a destroyed card; "hash check" for the digest | L32, L402, L510, L518, L524, L530, L538, L727; L399; L325, L336, L566; L259; L633; L84 | 7 | minor |
| T6 | "Repair" stated flat where Table 1 has 99.5 in four filtered cells; "the same holds from one parity word more" leaves the reader to recompute which k goes with which fault (S4, residue) | L425-428, L724-725 | 2, 7 | minor |
| T7 | Floats: Fig. 2 prints on page 9, two pages after its discussion on page 7; Table 1 prints inside §5.3; Table 1 column heads (N+k) not glossed; Fig. 2 shows three of five methods without saying the other two coincide; Fig. 1 side labels touch the header boxes | L505-514, L435-445, L198, `figures/rates.tex` L13-22, `figures/grid.tex` L23-24 | 6, 7 | minor |
| T8 | Six specification and repository entries cite moving `master` URLs with no revision or access date; SOUPS entry has no pages | `refs.bib` (`bip39`, `slip39`, `bip93`, `polyseed`, `sskr`, `shamir39`, `ambati2026notall`) | 8 | minor |
| T9 | Referents: "The trial total" names no number; the abstract's "the decoder" should say the grid decoder with the digest; "the 41 participants who failed" has no study size | L714-715, L35, L56 | 7 | minor |
| T10 | Small points of precision: Prop. 1(a) "same number" should be "same number and threshold"; S_0 "(and nonzero)" fails when the two error values are equal; "repaired to one of them" would be an ambiguous result by the paper's own definition; rescue step agrees with another *unconfirmed* card; an existing wallet does not "ignore the rest", the user enters the first N words; no example for "a better decoder exists"; pooled bound mixes scenarios of different risk (S12, partly resolved) | L255-256, L194, L199-201, L340, L163-164, L676, L557-560 | 1 | nit |

## Status of round-two items

Checked against the text, the Lean sources and the logs, not against `changelog.md`. Detail in `comments.md`.

| Item | Status |
|---|---|
| S1 no-digest ablation | Resolved |
| S2 source not obtainable | Open (T1) |
| S3 false-accept bound | Resolved |
| S4 statements against Table 1 | Resolved, small residue (T6) |
| S5 six grid files | Resolved |
| S6 evidence scope, wrong-number behaviour | Partly: behaviour documented, accurately within capacity; not qualified, not tested (T2) |
| S7 swap estimate premises | Resolved, two wording nits (T10) |
| S8 Shamir39 | Resolved |
| S9 truncation, Table 3 caption, Fig. 1 | Resolved |
| S10 define-before-use, fault list, decoder step 5 | Resolved; cap lifted |
| S11 repetition and length | Not resolved (T4) |
| S12 smaller items | Partly (T10) |

## Pre-flight summary

- Pending markers: none; nothing holds the `READY` transition.
- Evidence drift: `CLEAN`.
- Render gate: not run (no `parity39.3.audit/compile-log.txt` yet); `main.log` read by hand: 13 pages, no overfull box, one underfull box in the bibliography, no undefined reference or citation.
- Numeric-consistency, audience, reader-flow lint, float-proximity and the reader-flow lens all ran; results in `comments.md`.
- No venue overlay (`parity39/.anvil.json` absent).
