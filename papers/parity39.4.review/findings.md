# Findings — parity39.4

Cross-section observations. Line-level items are in `comments.md`; `U<n>` labels match `verdict.md`.

## 1. What the revision changed, and whether each change is right

Version 4 differs from version 3 in 14 diff hunks in `main.tex`; tables, figures and `refs.bib` are byte-identical. Each changed sentence was checked against the Lean sources and the logs (table in `comments.md`). All are accurate. None contradicts a table, the abstract or another section.

- The audit's critical flag is closed: §5.3 names card parity and the grid decoder without a digest, which are the two bracketed columns of Table 2 and the two non-zero cells of `grid-main-k4.txt` L31. The cause is now stated as an inference.
- The mislabelled-card paragraph says what the code does: the header correction is one of floor(k/2) substitutions, so k ≥ 2 is needed and k = 4 leaves one; a card that does not repair is kept as unconfirmed evidence under the entered number; no trial enters a wrong number.
- Decoder step 5 and the rescue step now match `combineRows` and `rescue` word for word in their conditions.
- §5.2 and the conclusion carry "at least 99.5%" and the unfiltered ranges, which are the minima and extremes of the logged cells.

## 2. What was re-confirmed

- **Counts.** 31,600 = 34 × 400 + 20 × 300 + 48 × 250 over six grid files. Both digest columns are 0 wrong in all 102 rows. The single wrong answer outside the foreign-card rows is the one the paper reports.
- **Abstract and conclusion.** 99.5 / 30.5 and 61.2 / 40.7 in Table 2 and the log; the exactly-t statement holds row by row; the conclusion's single-phrase figures hold.
- **Source digests.** All 15 SHA-256 values in the README match the working tree.
- **Cited study.** N = 92; 26 + 15 = 41 failed BIP-39; 14 of 41 recoverable.
- **Build.** 13 pages, no overfull box, no undefined reference or citation; the PDF contains the revised text.

## 3. Why the total did not move

Round three withheld eight points. This revision addressed the reasons behind parts of two of them (dim 1's wrong-number sentence; dim 7's referents and the unclear §5.2 sentence). In each case a second reason for the same point was left in place: the grid decoder is still a heuristic with no stated correction class (dim 1), and naming drift and float placement are untouched (dim 7). The other six points sit on items the changelog lists as not changed. The score is therefore the same number for a paper that is more accurate than version 3.

## 4. The revision introduced a few small flow defects (U7)

Six, all one-clause fixes: a decoder state used before its definition, a count whose relation to the two rates beside it is not stated, a coined row label, a loose "these runs", a sentence about the experiments placed in the construction, and "digest" in the abstract against "hash check" in the introduction. Two count as define-before-use in the body; the cap needs three.

## 5. Reproducibility cannot be closed by revision (U1)

Unchanged from rounds two and three. The remaining step is the author's and is worth up to two points on dim 5.

## 6. Reader flow

Recurrence against version 3 is 18 of 31 (0.581), above the 0.5 guide. That is expected for a revision that did not attempt naming, repetition or float placement, and it is reported as measured.
