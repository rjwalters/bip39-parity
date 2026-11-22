# Glossary (parity39.4, source-led read)

Rows marked **[F]** have a matching class-1 finding in `readerflow_findings.json` (first use precedes definition, or no definition site).

| term | first use (section/page) | definition site | variants seen |
|---|---|---|---|
| parity words | Abstract, l.24 (p1) | Abstract l.24; formal in 3.1 l.143-149 | "words of Reed-Solomon parity", "parity", "check word" (Polyseed) |
| grid shares | Abstract, l.27 (p1) | Abstract l.27; 4.1 | "grid", "grids", "Shared as a grid" |
| joint decoding | Abstract, l.30 (p1) | Abstract l.29-30; intro l.75-76 | "decoding across shares", "decoding across cards", "Grid", "grid decoder", "the full decoder", "our decoder" |
| card **[F]** | Abstract, l.28 (p1) | none | "share", "phrase", "printed cards", "row" (decoder steps) |
| spare card **[F]** | Abstract, l.29 (p1) | none | "spares", "spare rows" (l.576), "one more card than the threshold" |
| digest **[F]** | Abstract, l.35 (p1) | 4.3, l.304-316 (p5) | "a hash check on the shared secret" (l.84), "hash" (Fig. 1), "digest words" |
| edit / edit search **[F]** | Abstract, l.26 (p1) | 3.2, l.176-187 (p3) | "edit hypotheses", "edits", "two-edit rows", "single edit" |
| secret **[F]** | Abstract, l.19 (p1) | 4.1, l.211 (p4) | "key", "mnemonic", "secret words", "secret row" |
| 31,600 trials **[F]** | Abstract, l.35 (p1) | 8, l.724-725 (p11) | "all 31,600 grid trials in this paper" |
| 99.5% vs 31% (abstract) **[F: no card design label]** | Abstract, l.31-33 | referent named: repairing cards separately; 3-of-5, all five cards, one word in ten wrong | 30.5 (Table 2), "31%" (l.526) |
| 61% vs 41% (abstract) **[F: same finding]** | Abstract, l.33 | referent named: repairing cards separately; 2-of-3, all three cards, one word in ten wrong | 61.2 / 40.7 (Table 2), "gains 20 points" (Fig. 2 caption) |
| "one word in ten wrong" | Abstract, l.31 | 5.1 l.393 (word error, independent per word) | "10% of words wrong", "word error rate", "per-word error rate", "Words wrong (%)" |
| product code **[F]** | 1, l.48 (p1) | none | "product of ... code with a row code" (l.275) |
| 41 participants who failed (of 92) **[F]** | 1, l.56 (p1) | none (no stated relation to the 40% / 49%) | - |
| header **[F]** | 1, l.85 (p2) ("one unprinted symbol" l.73) | 4.1, l.218 (p4) | "unprinted symbol", "card number", "number", "h_i" |
| t-of-n ("3-of-5") | Abstract, l.32 | implicit from "any t of n cards" l.28 | "3-of-5 set", "3-of-5 sharing", "Scheme" (Table 4) |
| k | Abstract, l.24 | Abstract l.24; 3.1 l.143 | "parity per card" |
| e, s | Abstract, l.25 | Abstract l.25; 3.1 l.153 | "wrong" / "unreadable", "missing" |
| N, L | 1 l.67; 3.1 l.143 | 3.1 l.143; L redefined as W+1 at l.220 | - |
| N+k shorthand ("24+2") **[F]** | 3.2, l.200 (p3) | none | "12+2 ... 24+4" (Table 1 heads), "30-word cards" |
| protected phrase | 3.1, l.143 (p3) | 3.1 l.143 | "parity phrases" (l.73), "single phrases", "unshared 24-word phrase", "single-phrase format" |
| valid / syndromes | 3.1, l.144-145 | same | "exactly valid as written" |
| capacity | 5.2, l.431 (p7) | eq. (2), l.156, named only at l.431 | "the standard guarantee", "within capacity" |
| repair procedure | 1, l.69 | 3.2 l.176-192 | "repair", "decoder", "edit search" |
| cost | 3.2, l.187 | same | "minimum cost", "least cost", "cheapest candidates" |
| ambiguous | 1 l.70 ("reports ambiguity") | 3.2 l.189; outcome label 5.1 l.386 | - |
| (BIP39) filter | 3.2, l.191 | 3.2 l.190-192 | "the BIP39 filter", "the BIP39 checksum as a filter", "the filter" |
| dealing | 4.1, l.214 | same | "set", "sharing", "scheme", "arrangement" |
| D, W, g | 4.1, l.217-223 | same | "printed width", "30 words" |
| secret row r_0 / rows r_d | 4.1, l.222 | same | "random row", "row" (= card, l.331), "row code" |
| stripped card | 4.1, l.251 | same | "stripped of its header term" |
| m | 2, l.116 (shares) | 4.1 l.261 (holders); l.355 (confirmed cards) | three different counts |
| confirmed / unconfirmed evidence **[F]** | 4.2, l.300-301 (p5) | 4.4 step 1, l.333-335 (p5) | "confirmed cards", "unconfirmed card" |
| settled column | 4.4, l.339 | same | "columns that did not settle", "unsettled" |
| rescue (step) | 4.4, l.343 | same | "the rescue step" |
| ramp scheme | 2, l.123 | 2 l.121-123 (loosely); 4.5 l.364-366 | "ramp-style leakage" |
| correct / wrong / refused; unique | 5.1, l.383-387 | same (two definitions of "wrong") | "wrong secret", "wrong answer", "refuses" |
| word error | 1 l.53 ("word error rates") | 5.1 l.393 | "wrong word", "substitution", "words wrong" |
| burn | 5.1, l.395 | same | "burnt", "words burnt per card", "runs of unreadable words", "lost or burnt" |
| foreign / garbage card | 5.1, l.399-400 | same | "wrong cards", "a card that does not belong", "mixed-up cards", "a card that is wrong as a whole" |
| Checksum only | 5.1, l.406 | same | "a detection checksum", "per-share detection checksum" |
| Card parity | 5.1, l.409 | same | "repairing cards separately", "per-card repair", "per-card methods", "one at a time", "card by card", "per-share correction" |
| Grid / Grid, no digest | 5.1, l.415-418 | same | "joint decoding without a digest", "the two methods with a digest" |
