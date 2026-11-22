# Reader-flow glossary — parity39.1

Emitted by the fresh-context reader-flow lens (paper-review step 4j). Declared audience: wallet and key-management engineers, and applied cryptographers who know BIP39, Shamir sharing and the basics of Reed-Solomon codes.

| Term | First use (section/page) | Definition site | Variants seen |
|---|---|---|---|
| parity words | Abstract, p1 | Abstract (inline); formal in 3.1 | parity, Reed--Solomon parity, "check word" (for Polyseed) |
| grid shares | Abstract, p1 | Abstract (inline); 4.1 | grid, grids, "shared as a grid" |
| card | Abstract, p1 | None explicit (implicit at Eq. 3, 4.1) | share, phrase, row, printed card, parity phrase |
| combined decoder | Abstract, p1 | None | grid decoder, grid decoder with digest, full decoder, joint decoding, "our decoder", Grid |
| 99.7% (abstract) | Abstract, p1 | Referents named: per-card repair 36%, per-card checksums none; object "3-of-5 set", all cards, "one word in ten" wrong; trial count only in Table 2 | "99.7\%", 99.7 (Table 2, Fig. 2) |
| 36% (abstract) | Abstract, p1 | Baseline "per-card repair" defined only in 5.1 as "Card parity" | 36.0 (Table 2) |
| "none" (per-card checksums) | Abstract, p1 | Baseline defined only in 5.1 as "Checksum only" | 0.0 (Table 2) |
| 28,000 trials | Abstract, p1 | None (no breakdown anywhere) | "28{,}000 fault-injection trials", "every grid experiment in this paper (28{,}000 trials)" |
| per-card repair | Abstract, p1 | 5.1 ("Card parity") | Card parity, per-share correction, repairing cards one at a time, per-card methods |
| per-card checksums | Abstract, p1 | 5.1 ("Checksum only") | Checksum only, per-share detection, per-card checks, per-card methods |
| $N$, $k$, "$N{+}k$ format" | 1, p1 | 1 (inline); 3.1 | 24+2, 12+4 (never introduced); in Section 4 $N$ includes the digest words |
| 24+2 shorthand | 3.2, p3 | None | 12+2 ... 24+4 (Table 1) |
| header | 1, p1 | 4.2 | hidden header, unprinted header, header symbol, "never printed", "never written" |
| digest | 1, p1 | 1 (gloss); 4.3 | digest words, hash, "check to the secret", non-linear check |
| product code | 1, p1 | Not defined (assumed known); used in the proof of Prop. 1(d) | product |
| ramp scheme | 2, p2 | 2 (gloss); 4.5 | "ramp-style leakage", segment |
| RS1024, bech32, BCH | 2, p2 | None (assumed known) | none |
| P and Q blocks | 2, p2 | None | none |
| $\F$, $\alpha$ | 1 / 3.1, p1-2 | 3.1 | $\F_{2^{11}}$, "field with 2048 elements" |
| $n$ | 3.1, p2 | 3.1 (phrase length); redefined in 4.1 (number of cards) | $W$ (phrase length in Section 4) |
| syndromes $S_j$ | 3.1, p2 | 3.1, Eq. (1) | none |
| $e$, $s$ | Abstract, p1 | Abstract; 3.1 | wrong/unreadable, substitutions/erasures, missing |
| within reach | 3.1, p2 | None | "brings the card within reach" (4.2), capacity (5.2) |
| capacity | 3.1 (Eq. 2); the word first in 5.2, p6 | Eq. (2), not named there | "within capacity", "the capacity of $k=2$" |
| edit hypotheses | 3.2, p3 | 3.2 | edits, edit search, candidate |
| cost (of a candidate) | 3.2, p3 | 3.2 | minimum cost |
| ambiguous | 1, p1 | 3.2 | not among the outcome categories of 5.1 |
| $d$ | 3.2, p3 | 3.2 (dropped/extra count); 4.1/4.3 (digest words); proof of Prop. 1 (row index) | none |
| secret row $r_0$ | 4.1, p3 | 4.1 | secret, "the dealing" |
| seed | 4.1, p3 | None | seed words, secret, data words, entropy, mnemonic, key |
| $W$ | 4.1, p3 | 4.1 | $n$ (Section 3), "30-word cards" |
| dealing | 4.1 (Prop. 1d), p4 | None | dealer, deals, "another dealing" |
| $m$ | 2, p2 | 2 (inline); Prop. 1(d) | holders, cards at hand |
| 30-word card | 4.1, p4 | 4.3 | standard card, "$k=4$ (30 words)" |
| $h_i = i+32t$ | 4.2, p4 | 4.2 (32 unexplained) | $h$ = words held (4.5) |
| confirmed / unconfirmed | 4.4, p5 | 4.4 | "repairs uniquely", "repaired" |
| settled (column) | 4.4, p5 | 4.4 | none |
| rescue | 4.4, p5 | 4.4 | "the rescue step" |
| correct / wrong / refused | 5.1, p5 | 5.1; "Refused" redefined in the Table 1 caption | "refuse", "refused" vs "0" (Table 4) |
| burn | 4.1 as "bursts", p4 | 5.1 | burst, burnt, unreadable, erasure, missing |
| foreign card | 5.1, p5 | 5.1 | wrong card, card from another dealing, "card that does not belong" |
| garbage card | 5.1, p5 | 5.1 | none |
| spare card | Abstract, p1 | None explicit (implied: cards beyond $t$) | spare rows, "one more card than the threshold", margin |
| 97.6% (swap restriction) | 3.2, p3 | None (no trial count or table) | none |
| 13--15%, 0.5--1.5% (unfiltered) | 5.2, p6 | None (no table) | none |
| 95% half-width of 5 points | 5.1, p5 | 5.1, for 400 trials only | none for 200/250/300 trials |
| parity39 (tool) | 8, p9 | 8 | \code{tests}, \code{gridtests} |
