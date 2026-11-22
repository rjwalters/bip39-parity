# Findings — parity39.1

Cross-section observations. Line-level items are in `comments.md`; `R<n>` labels match `verdict.md`.

## 1. What was checked and holds

- **Field and code.** `GF.modulus = 0x805` is x^11 + x^2 + 1, a primitive trinomial; the harness confirms alpha has order 2047. Syndromes at alpha^0..alpha^(k-1) over length n <= 2047 define an MDS code of distance k+1, as §3.1 states. Encoding by erasure-decoding the parity positions is what `RS.encode` does.
- **Capacity.** `RS.decode` enforces 2e + s <= k and re-checks the syndromes before returning; the harness's 1,280-trial unit test covers k = 1..8.
- **Edit search.** The four hypothesis classes, the cap of three dropped or extra words, the swap restriction floor((k-2)/2), the cost rule and the BIP39 filter in §3.2 match `Repair.hypotheses` and `Repair.repair`.
- **Prop. 1 (b), (c), (d).** Correct for the header-stripped array. Evaluation points 1..n are distinct and nonzero; random rows are uniform in every data column including the digest columns; the dealer in `Main.lean` draws them from `IO.getRandomBytes`. The product-distance examples (2, 4, 7 words) are right.
- **Ramp arithmetic.** 264 - 11h, 132 and 124 bits are right.
- **Tables and figure.** All cells of Tables 1-4 and all 24 points of Fig. 2 match the logs. 28,000 = 28 x 400 + 16 x 300 + 48 x 250. The binomial explanation of the 36% cell is consistent (expected about 34%).
- **Cited study.** 40% and 49% failure, 41 failures and 14 near misses are in the extract.

## 2. The paper's object and its proof are one step apart (R1, R5, R12)

The proposition, the figure caption and the introduction describe cards without the header; the implementation and §4.2 describe cards with it. The digest text and the digest code differ. Step 5 of the decoder is described as verification and implemented as correction. None of these changes a measured number, but each is a place where a reader who implements from the paper gets something that does not interoperate with, or behave like, the code that produced the tables. A paper whose stated audience is wallet engineers should be implementable from its text.

## 3. Two results are credited to joint decoding that belong elsewhere (R2, R3, R11)

Of the "three things that stand out" in §5.3, the first two (word errors with spare cards; burns) are genuine joint-decoding results and are the paper's real contribution. The third (foreign cards) is a digest result, shown by the paper's own unreported "grid" column, and the format it is contrasted with already has the same defence. The abstract's 99.7 versus 36 is real but is the far corner of the table. The paper is stronger if it claims the first two results plainly, credits the digest for the third, and shows the 2-of-3 and exactly-t cases beside the headline.

## 4. The safety claim is stated more strongly than it is measured (R4, R6, R7, R8)

"Never returned a wrong secret" is the sentence a reader will repeat. It rests on 28,000 trials of mostly benign, independent, uniform faults, with no upper bound given, no swap faults on cards, and one logged instance of a wrong card being confirmed by the row stage when numbers are illegible. The 97.6% development figure, cited to justify the swap restriction that this safety depends on, has no artifact.

## 5. Reproducibility is close but not closed (R9)

Commands, seed and toolchain are given and the logs are stored. What is missing is the pointer: no URL, and the only recorded commit does not contain the grid code. This is the cheapest high-value fix in the list.

## 6. Reader flow (R13, R14)

Sentence-level prose is economical and free of promotional language. The friction is symbolic: four symbols change meaning between Sections 3 and 4 and eight terms or numbers are used before or without definition. These are mechanical fixes; they cap dim 7 at 2 until made.

## 7. Underclaiming check

Passed. The abstract and first paragraph state the organizing idea, and it is the brief's strongest claim rather than a subsidiary one. Inherited ingredients are labelled as inherited.

## Score outlook

Fixing R1, R5, R12 (dim 1), R2, R4, R6-R8 (dim 2), R3 and R16 (dim 4), R9 (dim 5), R13-R15 (dims 6, 7) and the bibliography is sufficient to reach the threshold without new theory. Only R2 and R7 need new harness runs.
