# Verdict — parity39.2

Total: 33 / 44
Decision: advance: false

Rubric `anvil-pub-v2`, threshold 35. The paper is blocked on score, not on a critical flag. It is scored as it stands; the round-one total (27) is not an input.

## Critical flags

None raised.

Three candidates were weighed and kept as scored findings:

- **Numerical inconsistency.** No number in the abstract, prose, tables or Fig. 2 disagrees with the harness logs: every cell of Tables 1-4 was re-read against `refs/experiments/`, the 31,600 total is exact, and the rule-of-three and half-width figures are right. The two slips found are descriptive, not results: "five grid files" where there are six (S5), and a Table 1 caption that its own footnote contradicts (S4c).
- **Missing experiment for a claim.** §5.3's heading says wrong cards are caught "not by joint decoding". The supporting figures it quotes are correct, but the same logs show joint decoding without the digest recovering every foreign-card trial once two spare cards are present, and the column is not tabulated (S1). This is a one-sided summary of an ablation that was run, not a claim without an experiment, and it understates the paper's own method; it is the top revision item, not a flag.
- **Unobtainable source.** The paper discloses that the source tree is unpublished and points to file digests, which were verified against the working tree. A disclosed gap in reproducibility is a dimension-5 score (3 / 5), not a defect that makes a reader stop trusting the paper (S2).

## Dimension summary

| # | Dimension | Weight | Score |
|---|---|---|---|
| 1 | Rigor of method / argument | 6 | 5 |
| 2 | Evidence sufficiency | 6 | 4 |
| 3 | Clarity of contribution | 5 | 5 |
| 4 | Related-work positioning | 5 | 4 |
| 5 | Reproducibility | 5 | 3 |
| 6 | Figure & table quality | 4 | 3 |
| 7 | Prose & structural quality | 4 | 2 |
| 8 | Citation hygiene | 5 | 4 |
| 9 | Rhetorical economy | 4 | 3 |
| | **Total** | **44** | **33** |

Dim 7 is capped at 2 by the reader-flow rule (three confirmed define-before-use defects in the body); uncapped it would be 3, for a total of 34, still below the threshold.

## Top 3 revision priorities

1. **Show the no-digest ablation and state what it says (S1).** List five methods, add the "Grid, no digest" column (or a foreign-card table for all five strategies), and replace the §5.3 heading with the three-case result: no spare card, wrong secret; one spare, refusal; two or more, recovery without the digest. Worth a point on dim 2 and one on dim 6.
2. **Publish the source, or archive it with the paper (S2).** Commit the tree, cite a URL and commit, or attach sources, wordlist, logs and README as ancillary files and cite them. This is the only route to more than 3 on dim 5 and it needs the author.
3. **Clear the three define-before-use items and the Table 1 wording (S10, S4).** Define "joint decoding" and tie it to the Grid column, define "row decoder", add the illegible-number fault to §5.1; qualify "two parity words repair a swap", fix the "capacity of k = 2" sentence and the "Refused" caption. This lifts the dim 7 cap.

Items 1 and 3 need no new experiments: the data are already in the logs.

## Ranked revision items

| Rank | Item | Where (`main.tex`) | Dim | Severity |
|---|---|---|---|---|
| S1 | No-digest grid ablation quoted but not tabulated, and summarised one-sidedly; "four ways" where five were run | L381-393, L514-521, Table 2 L453-479 | 2, 6 | major |
| S2 | Source tree not obtainable; digests pin an unpublished, uncommitted tree (R9 open) | L669-673 | 5 | major |
| S3 | False-accept bound: C(m,t)+1 candidates, random-hash assumption unstated, design bound untested by the experiments, no per-attempt figure for an altering holder | L303-308, L533-535, L633-635 | 1 | major |
| S4 | Three statements contradict Table 1: unqualified "two parity words repair a swap" (also L698), "beyond the capacity of k = 2", caption "Refused ... in any trial" against footnote a | L405-411, L416-417, L434-435, L657, L698 | 2, 6 | major |
| S6 | Evidence scope: one seed, uniform independent substitutions; no mislabelled-card or foreign-plus-illegible scenario; wrong-label behaviour of the code undocumented | L285-287, L370-380, L640-643 | 2 | major |
| S10 | Define-before-use: "joint decoding" never defined or tied to "Grid"; "row decoder" before §4.4; "numbers illegible" absent from the fault list; subset fallback described before the decoder | L30, L282, L305-308, L371-380, L392, L468, L487 | 7 | major |
| S5 | Trial total: six grid files, not five; 3,600 of the 31,600 trials are in no table | L531, L688-689 | 2, 5 | minor |
| S7 | Swap estimate: the "so" does not follow; premises (S_0 non-zero, S_1/S_0 treated as uniform) unstated | L188-194 | 1 | minor |
| S8 | Related-work lead: an existing tool that writes Shamir shares as BIP39 words (unverified) | L42-44, L97-108 | 4 | minor |
| S9 | Tables and figure: truncated percentages sum to 99.9 under "all other trials were refused"; Table 3 caption does not name the method; Fig. 1 header labels overflow their boxes | L445-449, L470, L547-549, `figures/grid.tex` L7 | 6 | minor |
| S11 | Repetition and length: no-wrong-secret five times, exactly-t caveat six times, assumed-rate caveat four times; 13 pages against 10 | L33-34, L77, L84, L531, L539, L549, L572, L621-623, L641, L655, L663, L698-704 | 9 | minor |
| S12 | Smaller items: rescue step agrees with another *unconfirmed* card; Prop. 1 wording ("two different cards with the same number", "holders"); no example for "a better decoder exists"; substitution not exactly uniform; naming drift; L rebound; rule of three uncited; S_1 weighting | L144-145, L210, L246-252, L329-332, L372-373, L533-534, L650-651 | 1, 7, 8 | minor |

Round-one status (detail in `comments.md`): R1, R3, R5, R6, R7, R8, R10, R11, R15, R16 resolved; R4, R12, R13, R14 mostly resolved; R2 partly resolved (S1); R9 open (S2).

## Pre-flight summary

Render-gate skipped (no audit compile log for this version; `main.log` read by hand, clean). Numeric-consistency, pending-marker, evidence-drift (`CLEAN`), audience-fit, reader-flow lint and float-proximity ran; the reader-flow lens ran in a fresh context (recurrence against version 1: 4 / 42 = 0.095). No pending markers, so no outstanding dependencies. No venue overlay resolved. `lake` was not run; the implementation was checked by reading and the digest test vector by recomputation. Details are in the procedural notes of `comments.md`.
