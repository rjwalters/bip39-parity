# Findings — parity39.2

Cross-section observations. Line-level items are in `comments.md`; `S<n>` labels match `verdict.md`.

## 1. What was checked and holds

- **Proposition 1 as restated.** With rows r_0..r_{t-1} valid at length W+1 and header 0, and u valid with zero data words and header 1, every c_i in Eq. (3) is valid by linearity and has header h_i. Two codewords of the length-(W+1) code differ in at least k+1 places, so printed words differ in k+1 places when the headers are equal and in k when they are not. Codewords with header 0 form the shortened code of length W and distance k+1, so stripped cards lie in it; columns are evaluations of a polynomial of degree below t at distinct non-zero points, a code of distance m-t+1; the product bound (k+1)(m-t+1) and the examples 2, 4, 7 follow. Secrecy below the threshold holds because every data column, digest columns included, has independent uniform coefficients, and parity and header are functions of data words, number and t. This is what `Grid.deal`, `headerOffset` and `applyHeader` compute.
- **Digest.** The sentence in §4.3 is `Grid.digestWords` word for word. Recomputed in Python (`hashlib`, `data/english.txt`): for 23 x abandon + art the digest words are siege, say.
- **Swap count.** C(26,2) = 325; 325 x 26/2047 = 4.1. The implementation's rule (`maxErrors := (k - 2) / 2` for swap hypotheses) is what §3.2 states.
- **Statistics.** 31,600 = 13,600 + 6,000 + 12,000. 3/31,600 = 0.95e-4; 3/400 = 0.75%. Half-widths 4.9, 5.7, 6.2, 6.9 are right. The binomial account of the 31% cell gives 34%, inside the margin.
- **Tables and figure.** All cells of Tables 1-4 and all 24 points of Fig. 2 match the logs. `figures/src/tables.py` reads printed columns 0, 1, 2, 4, which the harness prints as checksum, card parity, parity + digest, grid + digest; the mapping is right.
- **Abstract and introduction.** Every figure in the abstract is in Table 2 (99.5 / 30.5, 61.2 / 40.7) and the exactly-t statement is the lower half of that table.
- **Source digests.** All 15 SHA-256 values in `refs/experiments/README.txt` match the working tree.

## 2. The remaining evidence problem is one of presentation, and it cuts against the paper (S1)

Round one found the foreign-card result credited to joint decoding when it belonged to the digest. The revision added the right baseline and then over-corrected: the heading now says joint decoding does not catch wrong cards, and the prose quotes only the two cases where that is true. The logs give a cleaner statement that matches the theory in §4.1: zero spare cards, wrong secret; one, refusal; two, recovery. A reader who checks the logs will see that the paper reports its own method less favourably than its data, and will wonder what else is summarised selectively. Printing the fifth column removes the question.

## 3. Statements that the text makes more strongly than Table 1 (S4)

"Two parity words repair a swap" is the sentence a wallet engineer will carry away, and it is repeated in the conclusion. It is true with the BIP39 checksum as a second filter. Cards are not mnemonics and have no such filter, which is why they use k = 4; the single-phrase claim should carry its condition.

## 4. Reproducibility cannot be closed by revision (S2)

Everything a reviser can do has been done: commands, seed, toolchain, logs, file digests, and a plain statement that the tree is unpublished. The remaining step is the author's. Until then the paper is re-implementable from its text (field polynomial, syndromes, header layout, digest with a test vector, decoder steps) but its tables are not rerunnable by anyone else, and the heuristic parts of the decoder (rescue, tie rules) are described more briefly than they are coded.

## 5. Reader flow

Recurrence against version 1 is 4 of 42 (0.095), so the round-one flow defects are gone. The fresh read found three new or surviving undefined terms in the body, which is enough to hold the cap. They are one-clause fixes. The larger residue is naming: one method has about six names and one baseline about six more.

## 6. Underclaiming check

Passed. The first two sentences state the organising idea, it is the brief's strongest claim, and inherited ingredients are labelled. The one place the paper undersells itself is §5.3 (section 2 above).

## Score outlook

33 now. S10 lifts the dim 7 cap (+1). S1 with S4 is worth a point on dim 2 and one on dim 6 (+2). That reaches 36 without the author publishing anything; S2 would add up to two more.
