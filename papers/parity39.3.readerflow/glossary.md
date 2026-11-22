# Glossary — parity39.3 (reader-flow lens)

| term | first use (section/line) | definition site | variants seen |
|---|---|---|---|
| parity words / k | Abstract, l.24 | Abstract l.24 (same sentence); formal at §3.1 l.142-143 | parity, check word, redundancy, "k alone" |
| e, s (wrong / unreadable counts) | Abstract, l.25 | Abstract l.25 (same sentence); §3.1 l.152-153 | wrong, substitution, symbol error, word error; unreadable, missing, burnt |
| edit search / edit hypotheses | Abstract, l.26 | §3.2 l.175-185 (abstract use is self-explaining) | edits, edit hypotheses, "As written / Swap / Dropped / Extra" |
| grid shares | Abstract, l.27 | Abstract l.27 (same sentence); §4.1 | grid, grids, shares, cards |
| card | Abstract, l.28 | none (never defined) | share, row, phrase, codeword, printed words |
| spare card | Abstract, l.29 | none (implicit at l.510 and l.624-625) | spare rows, spares, "one more than the threshold" |
| joint decoding | Abstract, l.30 | Abstract l.29-30 (same sentence); §1 l.75-76 | Grid, grid decoder, full decoder, decoding across cards/shares |
| 99.5% (abstract) | Abstract, l.31 | compares against 31% for repairing cards separately; same cards: all five of a 3-of-5 set, one word in ten wrong (l.31-33) | 99.5 (Table 2), "nearly removes the dependence" |
| 31% (abstract) | Abstract, l.33 | the baseline for the 99.5%: per-card repair, same condition | 30.5 (Table 2), 31% (l.518) |
| 61% against 41% (abstract) | Abstract, l.33 | joint decoding against separate repair; all three cards of a 2-of-3 set, same error rate | 61.2 / 40.7 (Table 2), "gains 20 points" (l.510) |
| 31,600 trials | Abstract, l.35 | none in the abstract (which trials, which decoder); partly at §5.3 l.556 and §8 l.714 | "31,600 grid trials", "the trial total" |
| product code | §1, l.48 | none explicit (implicit in proof, l.273-275) | product, grid, m×W array |
| "41 participants who failed" | §1, l.56 | none (no study size or time point) | 40%, 49% |
| unprinted header | §1, l.85 (described l.73) | §4.1 l.216 | unprinted symbol, header, header term, card number, h_i |
| digest | §1, l.84 as "hash check" | §4.3 l.304-310 (forward-referenced at l.221) | hash check, hash, digest words, mix-up defence |
| F, α | §3.1, l.137 | l.137-138 (same sentence) | F_{2^11}, "field with 2048 elements" |
| valid / syndromes | §3.1, l.143 | l.143-148 | parity checks, S_0, S_1 |
| N, L | §1 l.67 (N); §3.1 l.142 (L) | l.67 and l.142 (in place) | L redefined as W+1 at l.218; N becomes D in §4 |
| capacity | §5.2, l.424 | l.424 by reference to eq. (2) | "the standard guarantee", "within capacity" |
| N+k shorthand ("24+2") | §3.2, l.198 | none | 12+2 ... 24+4 (Table 1 heads), "30-word cards (k=4)" |
| cost / ambiguous | §3.2, l.186-188 | l.186-188 (in place) | least cost, minimum cost |
| BIP39 filter | §3.2, l.189-191 | l.189-191 | the filter, BIP39 checksum filter, checksum |
| secret | Abstract, l.19 (ordinary sense) | §4.1 l.209 | mnemonic, secret words, secret row, key, entropy |
| dealing | §4.1, l.212 | l.212 (same sentence) | set, sharing, grid, scheme, arrangement |
| D, W, g | §4.1, l.215-221 | in place | printed width, "30 words" |
| secret row r_0 / rows r_d | §4.1, l.220 | l.220-222 | row (also used for cards), random row |
| stripped card y_i | §4.1, l.249 | l.249 (same sentence) | stripped values |
| holder | §4.1, l.259 | none (ordinary word; used as a unit for m) | party, participant, person, owner, backup holder |
| confirmed / settled | §4.4, l.327 / l.333 | in place | unconfirmed evidence, set aside |
| word error, burn, swap, dropped, foreign, garbage | §5.1, l.386-394 | in place | wrong word, burnt, "lost or burnt" (l.633) |
| Checksum only | §5.1, l.399 | l.399-401 (collides with the BIP39 checksum) | detection checksum, per-share detection checksum |
| Card parity | §5.1, l.402 | l.402-403 | per-card repair, repairing separately / one at a time / card by card |
| "the trial total" | §8, l.714 | none (referent 31,600 not named) | 31,600 trials, 31,600 grid trials |
