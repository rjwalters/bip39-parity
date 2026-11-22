# Verdict — parity39.1

Total: 27 / 44
Decision: advance: false

Rubric `anvil-pub-v2`, threshold 35. The paper is blocked on score, not on a critical flag.

## Critical flags

None raised.

Two candidates were weighed and kept as top-priority major findings instead:

- **Foreign-card baseline (R2, R3).** The "Checksum only" and "Card parity" baselines are denied the digest, and SLIP39's identifier and digest are not described, so the 61-67% wrong-secret figure does not represent a deployed format. This misattributes one of three headline results. It stops short of a flag because the paper does not claim the digest as new ("hash checks are all decades old") and the joint-decoding results for word errors and burns are unaffected.
- **Prop. 1(a) versus the printed card (R1).** The proposition is true of the object in Eq. (3) and false of the card defined two paragraphs later. It is a statement-ordering defect with a one-paragraph repair, and the Lean code is consistent with the corrected statement.

No numerical inconsistency between text and tables was found at flag level: all cells of Tables 1-4 and both panels of Fig. 2 match the harness logs, and the 28,000 total is exact.

## Dimension summary

| # | Dimension | Weight | Score |
|---|---|---|---|
| 1 | Rigor of method / argument | 6 | 4 |
| 2 | Evidence sufficiency | 6 | 3 |
| 3 | Clarity of contribution | 5 | 4 |
| 4 | Related-work positioning | 5 | 3 |
| 5 | Reproducibility | 5 | 3 |
| 6 | Figure & table quality | 4 | 2 |
| 7 | Prose & structural quality | 4 | 2 |
| 8 | Citation hygiene | 5 | 3 |
| 9 | Rhetorical economy | 4 | 3 |
| | **Total** | **44** | **27** |

Dim 7 is capped at 2 by the reader-flow rule (three or more confirmed define-before-use defects in the body).

## Top 3 revision priorities

1. **Make the card the paper proves things about the card it prints (R1).** Define the card with its header before Prop. 1; restate (a) for the W+1-symbol word; give the row-code distance with the number known (k+1) and unknown (k); correct the introduction, the Fig. 1 caption and the abstract accordingly. In the same pass make §4.3's digest match `Grid.digestWords` (R5).
2. **Separate the digest from joint decoding and describe SLIP39 fully (R2, R3).** Report the no-digest grid column already in the logs, add a per-card-plus-digest baseline, describe SLIP39's and codex32's identifiers and SLIP39's digest in §2, and reword §5.3 and §9 so the foreign-card result is credited to the digest.
3. **Bound and complete the evidence (R4, R6, R7, R8).** Give the 95% upper bound on the wrong-secret rate and the breakdown of 28,000; support or remove the 97.6% figure; add a within-card swap scenario for grids; report the illegible-number, dropped-word and garbage rows.

## Ranked revision items

| Rank | Item | Where | Dim |
|---|---|---|---|
| R1 | Printed cards are not valid parity phrases as Prop. 1(a), Fig. 1 and §1 state | L67-69, L203-207, L213, L242-248 | 1 |
| R2 | Foreign-card comparison confounds digest with joint decoding; ablation omitted | L392-395, L419, L425, L597-599 | 2 |
| R3 | SLIP39 identifier and digest (and codex32 identifier) not described | L56-58, L96-103 | 4 |
| R4 | "Never returned a wrong secret" has no bound, scope or breakdown; logs show a wrong confirmed card | L31-32, L397-398, L599 | 2 |
| R5 | Digest specification differs from `Grid.digestWords` | L262-264 | 1, 5 |
| R6 | 97.6% figure has no artifact | L178-181 | 2, 5 |
| R7 | Grids never tested with swapped words | L324-337 | 2 |
| R8 | Header, dropped-word and garbage rows run but not reported | Table 2, L242-254 | 2, 3 |
| R9 | No URL or commit for the source; recorded hash predates the grid code | L571-574 | 5 |
| R10 | Motivating study is recall from memory, presented beside a transcription problem | L50-54 | 8, 2 |
| R11 | Abstract quotes only the most favourable cell | L32-34 | 3 |
| R12 | False-accept probability ignores the subset search; step 5 corrects, not verifies | L265-268, L292-294, L535-536 | 1 |
| R13 | n, N, d, h change meaning between sections | L129, L163-170, L188-190, L221, L303 | 7 |
| R14 | Eight define-before-use defects (within reach, seed, dealing, 30-word card, bursts, 32, unfiltered numbers and "ambiguous", "0" vs "refused") | see `comments.md` | 7 |
| R15 | Fig. 1 overprints its labels | `figures/grid.tex`, PDF p. 4 | 6 |
| R16 | Related-work gaps: robust secret sharing, information dispersal, SSKR; unsourced words-vs-characters claim; RAID-6 citation | L102-103, L110-117 | 4, 8 |

Minor and nit items follow in `comments.md`.

## Evidence drift

Advisory only; it changes no score, flag or decision. The evidence-drift check reported `EVIDENCE-DRIFT` on `refs/**`: files under `parity39/refs/experiments/` were modified after this version's snapshot. On this pass `single-phrase.txt` had finished (85 lines, all six configurations) and `grid-main-k4.final` had gained its last row. The paper was re-checked against the current files: every cell of Table 1 matches the completed `single-phrase.txt`, and Table 2 and Fig. 2 match `grid-main-k4.final`. The row that arrived late ("all cards, numbers illegible, 3%" for 3-of-5: card parity 99.7 correct / 0.2 wrong) is not in the paper and is the source of the last sentence of R4. `grid-main-k4.txt` is an empty run and should be replaced by the `.final` file.

## Pre-flight summary

Render-gate skipped (no audit compile log; `main.log` read by hand, clean). Numeric-consistency, pending-marker, audience-fit, reader-flow lint and float-proximity ran; reader-flow lens ran in a fresh context. No pending markers. No venue overlay resolved. Details are in the procedural notes of `comments.md`.
