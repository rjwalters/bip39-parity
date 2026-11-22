# Findings — parity39.3

Cross-section observations. Line-level items are in `comments.md`; `T<n>` labels match `verdict.md`.

## 1. What was checked and holds

- **Tables, figure and prose against the logs.** All cells of Tables 1-4, including the new "Grid, no digest" column, and all 24 points of Fig. 2 match `refs/experiments/`. The harness prints its five tallies in the order checksum, card parity, parity + digest, grid without digest, grid with digest (`GridTests.lean` L193, L210), and `figures/src/tables.py` reads them in that order. Every percentage quoted in the abstract, §5 and §6 is the logged value, rounded or as printed.
- **Counts.** 31,600 = 34 rows × 400 + 20 × 300 + 48 × 250 over six grid files. No digest method returned a wrong secret in any row. The one logged miscorrection (3-of-5, exactly t cards, 5% wrong, 0.2%) is in the two methods without a digest and is reported.
- **Bounds and estimates.** (C(5,3)+1)·2^-22 = 2.62e-6. 325·26/2047 = 4.13. 3/31,600 = 0.95e-4; 3/400 = 0.75%. Half-widths 4.9, 5.7, 6.2, 6.9.
- **Proposition 1.** As in round two: linearity gives validity at length W+1; printed distances k+1 and k follow from the header being one position; stripped cards lie in the shortened code; the product distance and the examples 2, 4, 7 follow.
- **Decoder description against `Grid.lean`.** Steps 1-5, the settle rule (t+1 agreeing values, no tie), the rescue conditions (one short, k ≥ 3, at most 14 open columns, 3 to k guesses) and the subset fallback are what `readCard`, `columnDecode`, `settle`, `rescue` and `combineRows` do.
- **Illegible numbers.** L289-293 matches `readCard`: solve for the header as an erasure; if that does not give one candidate, try the 31 numbers as known and keep the least cost.
- **Digest.** §4.3 is `Grid.digestWords`; the test vector was recomputed: siege, say.
- **Source digests.** All 15 SHA-256 values in the README match the working tree.
- **Cited study.** The extract supports 40% / 49% (complements of 60% / 51%), 14 of 41, and the error types.

## 2. The wrong-number sentence is right about the common case and silent about the rest (T2)

Round two asked what the code does with a mislabelled card. The answer in §4.2 is correct for a card that is otherwise clean or nearly so: the header is one more symbol in the received word, the decoder corrects it, the row takes its index from the corrected header, and a note is attached. Two things follow from the same code that the text does not say. The correction spends parity: at k = 4 a mislabelled card has room for one other wrong word. And a mislabelled card that does not repair is not set aside; because a number was supplied it becomes unconfirmed evidence under that number. Neither leads to a wrong secret, since the digest stands behind both, but the second is the kind of behaviour a reader of §4.4 step 1 should be told about, and none of it has a trial. A mislabelled-card row in Table 2 would close S6 properly.

## 3. The paper now reports its ablation straight

The foreign-card result has moved twice: credited to joint decoding in version 1, denied to it in version 2. Version 3 prints the column and says what it shows: no spare card, wrong secret; one, refusal; two, recovery; and with the digest, recovery whenever a spare exists. That is the statement Proposition 1(d) predicts and the logs support in all four dealings sizes.

## 4. Reproducibility cannot be closed by revision (T1)

Unchanged. Commands, seed, toolchain, logs, file digests and a plain statement that the tree is unpublished are all there. The remaining step is the author's. The paper is re-implementable from its text; its tables are not rerunnable by anyone else.

## 5. What a further pass would buy

The score is one point over the threshold and the open items are of three kinds. T1 needs the author and is worth up to two points on dim 5. T2 needs one harness scenario and two sentences. T4 and T5 are editing: the repetition counts did not move between versions 2 and 3, and the naming of the two main methods is still spread over nine labels. None of these is a reason to hold the paper from audit.

## 6. Reader flow

Recurrence against version 2 is 12 of 35 (0.343), under the 0.5 guide. The three round-two define-before-use defects are gone and one new one is confirmed, so the dim 7 cap is lifted. What recurs is naming and repeated caveats.
