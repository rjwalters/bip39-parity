# Numerical audit for parity39.3

Sources. E = `parity39/refs/experiments/` (unchanged since the round-two audit). Lean =
repository root. Line numbers for `main.tex` are from `parity39.3/main.tex`. Tables 2 and
4 were checked cell by cell with a parser written for this audit (85 and 48 cells);
Tables 1 and 3 and every number in the prose were checked by hand. `figures/src/tables.py`
was then run on a scratch copy as a cross-check.

Harness column order (GridTests.lean L148–153, L193, L210): checksum only (`detectOnly`)
| card parity (`rowsOnly`) | parity+digest (`rowsDigest`) | grid, no digest
(`combineRows` with `digest := 0`) | grid + digest (`combineRows`). Table 2 now prints
all five.

## Round-two critical flags

| Flag | Status | Evidence |
|---|---|---|
| "five grid files" (six exist) | resolved | L714–715: "every row of the six grid files, including rows that no table prints". Six files, 31,600 trials (below). |
| Sec. 5.2 sentence contradicted Table 1 on refusals at k = 3 | resolved | L429–433: "Faults beyond the capacity (two wrong words at k ≤ 3; a wrong word plus a dropped word at k = 2) were refused, apart from 0.5–1.5% of unfiltered trials at k = 2". Matches `single-phrase.txt` L18, L30, L54, L66 (two wrong words) and L24, L60 (wrong + dropped). Caption L438–440 now agrees with footnote a. |

## Mismatches

| Text claim | Source (Tab/Fig) | Source value | Match | Notes |
|---|---|---|---|---|
| L554–555: "where **both methods without a digest** returned a wrong secret (the bracketed 0.2)" | Table 2, L498; `grid-main-k4.txt` L31; method list L399–412 | Three of the five methods have no digest: checksum only, card parity, and grid, no digest. In that row checksum only is 0.5 / **0.0**; card parity and grid, no digest are 50.7 / **0.2** | NO | Two of the three no-digest methods returned the wrong secret, not "both". Table 2 is right (no bracket under Checksum only). Critical flag. |

## Abstract, introduction, conclusion

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L31–33: 99.5% vs 31% (3-of-5, all five cards, 10%) | `grid-main-k4.txt` L28 | 99.5 (grid), 30.5 (card parity) | yes | 30.5 is exactly 122/400; "31" is round-half-up. |
| L33: 61% vs 41% (2-of-3, all three cards, 10%) | `grid-main-k4.txt` L8 | 61.2, 40.7 | yes | 245/400 and 163/400. |
| L35, L556, L728: 31,600 trials, no wrong secret from the decoder / the two digest methods | six grid files | 6,800 + 6,800 + 1,500 × 4 + 4,500 + 4,500 + 3,000 = 31,600; wrong = 0.0 in every row of columns 3 and 5 | yes | Recomputed independently and by `tables.py` ("total trials 31600 rows with a wrong answer from a digest method: 0"). |
| L60: checksum 4 bits (12 words), 8 bits (24) | BIP39 | 4, 8 | yes | |
| L78: "about 900 lines of Lean 4" | `Parity39/*.lean` | 867 lines | yes | |
| L724–725: with the filter, two parity words repair a swap or a dropped word; four repair any two wrong words | Table 1; `single-phrase.txt` L20–22, L56–58, L42, L78 | filter column: 100, 100, 100 (12+2); 100, 99.5, 100 (24+2); 100, 100 (k = 4) | yes | One 24+2 any-swap trial of 200 was ambiguous with the filter. See notes. |

## Sec. 3.2 swap estimate (L193–202)

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| 26·25/2 = 325 swaps | arithmetic | 325 | yes | |
| 325·26/2047 ≈ 4 | arithmetic | 4.13 | yes | Stated as an expectation under a uniformity assumption. |
| Swap followed by at most floor((k−2)/2) substitutions | `Repair.lean` L114 | `(k - 2) / 2` | yes | At k = 2 that is 0, so the estimate describes a decoder without the limit; it was not measured. |
| "S_0 unchanged (and nonzero)" | algebra | S_0 = e_1 + e_2 | yes, with a caveat | Zero when the two error values coincide (probability 1/2047). |

## Sec. 4 (construction, header, digest, decoder)

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L228–233: h_i = i + 32t, n ≤ 31, t ≤ 63 | `Grid.lean` L41–43, L83 | same; 32·63 + 31 = 2047 | yes | |
| L234: g = 2, k = 4 gives 30 words | 24 + 2 + 4 | 30 | yes | |
| L281–284: bounds 2, 4, 7 | floor(((k+1)(m−t+1) − 1)/2), k = 4 | 2, 4, 7 | yes | |
| L292: tries each of the 31 numbers | `Grid.lean` L170–174 | `Array.range 31` | yes | |
| L293–296: a card entered with the wrong number has one wrong symbol, the header, which the repair procedure corrects like any other wrong word and reports; the number it settles on is the one consistent with the words | `Repair.lean` L115, L123–128, L132; `Grid.lean` L159–163, L175–179; `Main.lean` L166–170 | The entered header is passed as a known suffix symbol; `RS.decode` treats it as an ordinary symbol and can return it in `errors`; the note "the card's label does not match its words" is attached; `readCard` takes the index from the corrected header and `combine` prints the note | yes, with conditions | See notes: needs k ≥ 2 and uses one of the floor(k/2) substitutions; outside that the card is kept as unconfirmed evidence under the wrong number. Not exercised by either harness. |
| L305–310: digest rule and the vector `siege`, `say` | `Grid.lean` L62–66; recomputed with Python `hashlib` and `data/english.txt` | `siege`, `say` | yes | |
| L314: 2^-22 per candidate | g = 2 | 2^-22 | yes | |
| L337–340: rescue when one short, k ≥ 3, at most 14 unsettled columns, sets of 3 to k | `Grid.lean` L276, L282 | same | yes | |
| L343–345: subsets of t tested "if that fails and more than t cards are confirmed" | `Grid.lean` L341–348 | subsets are tested whenever a digest is configured, also with exactly t confirmed | yes | No effect on the bound. |
| L348–351: at most C(m,t)+1 candidates; (C(m,t)+1)·2^-22 ≈ 2.6 × 10^-6 for m = 5, t = 3 | `Grid.lean` L336–348 | one joint candidate (L336–339), then every t-subset of the confirmed rows (L343–348); 11 · 2^-22 = 2.62 × 10^-6 | yes | The round-two note (bound one candidate short) is resolved. |
| L360–361: 264 − 11q; 132 bits; 124 bits | arithmetic | 132, 124 | yes | |

## Sec. 5.1 setup

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L396–412: five methods | GridTests.lean L66–98, L147–153 | as described | yes | "Grid, no digest" accepts the secret row on parity alone (`digestOk` returns `none`, `Grid.lean` L68–69, L338). |
| L413–414: half-widths 4.9, 5.7, 6.2, 6.9 (n = 400, 300, 250, 200) | 1.96·sqrt(0.25/n) | 4.90, 5.66, 6.20, 6.93 | yes | |
| L415–416: harness truncates to one decimal; a row can sum to 99.9 | GridTests.lean L61–64 (`x * 1000 / total`, integer division); Tests.lean L171–174 | truncation; e.g. `grid-main-k4.txt` L36: 40.2 + 59.7 = 99.9 | yes | |
| L416–418: repeated configurations differ within the margins | Table 2 vs Table 4, 3-of-5 | 99.7/99.6, 84.5/83.2, 50.7/54.8, 100/100, 98.2/98 | yes | Largest difference 4.1 points. |

## Sec. 5.2 and Table 1 (`single-phrase.txt`)

All 54 cells of Table 1 match the "unique" columns of the log (L17–25, L29–37, L41–49,
L53–61, L65–73, L77–85), without / with the filter.

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L428–429: unfiltered swap at k = 2 unique in 84.5–96.5%, otherwise ambiguous | L20–21, L56–57 | unique 94.0, 96.5, 87.0, 84.5; ambiguous 6.0, 3.5, 13.0, 15.5; wrong 0; refused 0 | yes | |
| L429–431: two wrong words at k ≤ 3 and wrong + dropped at k = 2 were refused | L18, L30, L54, L66; L24, L60 | refused 100 / 100 except the three unfiltered cells below | yes | |
| L431–432 and footnote a: 0.5–1.5% of unfiltered trials at k = 2 wrong | L24 (12+2 wrong + dropped 0.5), L54 (24+2 two wrong 1.5), L60 (24+2 wrong + dropped 1.5) | 0.5, 1.5, 1.5 | yes | The three footnoted cells are the right ones. |
| L432–433: "With the filter, or with k ≥ 3, no trial was wrong" | every "wrong" column | nonzero only at L24, L54, L60, unfiltered, k = 2 | yes | |
| L425–427: with the filter, k = 2 repairs a swap or a dropped word; k = 3 two dropped words or wrong + dropped; k = 4 two wrong words | filter column | k = 2: 100 except 24+2 any swap 99.5; k = 3: 99.5, 100, 99.5, 99.5; k = 4: 100 | yes, loosely | "Repair" is 99.5% in four of the cells. See notes. |
| L427–428: "Without the filter the same holds from one parity word more" | unfiltered column | k = 3 swap and dropped: 100; k = 4 two dropped, wrong + dropped: 100; two wrong words: 100 already at k = 4 | yes | For two wrong words no extra parity word is needed; no k = 5 run exists. |
| L683–684: for 24 words, k = 3 covers every single edit and k = 4 any two wrong words | L65–73, L78 | 100 / 100 | yes | |

## Sec. 5.3, Table 2 and Figure 2 (`grid-main-k4.txt`)

All 85 cells of Table 2 (17 rows × 5 methods), including the six bracketed wrong-secret
pairs, match the log: brackets [67 / 59.7] under Checksum only and Card parity (L16,
L36), [0 / 0.2] under Card parity and Grid, no digest (L11, L31), [100 / 100] under
Checksum only, Card parity and Grid, no digest (L17, L37). No bracket is missing and none
is extra. All 24 coordinates in `figures/rates.tex` match L5–8 and L25–28 (columns 1, 2
and 5).

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L509–511: 2-of-3 gains 20 points at 10% | L8 | 61.2 − 40.7 = 20.5 | yes | |
| L516–521: 99.5 vs 31; 61 vs 41 | L28, L8 | as above | yes | |
| L525: 90% and 98% (5 burnt words) | L13, L33 | 89.7, 98.2 | yes | |
| L528–533: swap 100%; with 3% wrong 86 and 93; joint 92.5 and 100 | L19, L21, L39, L41; L20, L40 | 100; 86.2, 92.7; 92.5, 100 | yes | |
| L533–534: dropped words 94.7 and 98.2, equal to per-card within error | L15, L35 | 94.7 vs 94.5; 98.2 vs 98.2 | yes | Card set aside: `Grid.lean` L185–192. |
| L538–539: per-card methods without a digest wrong in 60–67% | L16, L36 | 67.0 (2-of-3), 59.7 (3-of-5), for checksum only and card parity | yes | 59.7 is 239/400 = 59.75 truncated. |
| L539–542: no-digest joint decoding: 100% with two spares (3-of-5); refused with one (2-of-3); wrong every time with none | L36; L16; L17, L37 | 100.0 / 0.0; 0.0 / 0.0; 0.0 / 100.0 | yes | The scenario files agree: one spare 0.0 / 0.0 (`scenario-3of5.txt` L14, `-3of6.txt` L14, `-4of9.txt` L14); two or more 100.0 / 0.0 (`-3of5.txt` L20, `-3of6.txt` L20); none 0.0 / 100.0. |
| L542–544: the digest removes every wrong answer and recovers whenever a spare exists | L16, L36 columns 3, 5 | 100.0 / 0.0 | yes | Also 100 with one spare in the three scenario files. |
| L545–546: exactly t and one foreign: the two digest methods refuse | L17, L37 | 0.0 / 0.0 | yes | |
| L548–550: illegible numbers 98 and 99.7, against 99.7 and 100 | L18, L38; L6, L26 | 98.0, 99.7; 99.7, 100.0 | yes | |
| L553–556: one wrong secret, 3-of-5, exactly t, 5% | L31 | 0.2 = 1 of 400, in two columns | yes for the count | The methods are misdescribed; see Mismatches. No other non-foreign row in any of the six files has a nonzero wrong entry. |
| L557–560: below about 10^-4 at 95%; below 0.75% per 400-trial cell | 3/31,600; 3/400 | 0.95 × 10^-4; 0.75% | yes | Rule of three. |

## Sec. 5.4 and Table 3

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L567–568: 88% and 85% at 3% | `grid-main-k4.txt` L10, L30 | 87.7, 84.5 | yes | |
| Table 3, k = 4 | L10, L30; L11, L31 | 87.7 / 84.5; 62.0 / 50.7 | yes | |
| Table 3, k = 6 | `grid-minimal-k6.txt` L6, L14; L7, L15 | 95.6 / 94.0; 83.6 / 78.6 | yes | |
| Table 3, k = 8 | `grid-minimal-k8.txt` L6, L14; L7, L15 | 99.0 / 99.0; 95.6 / 94.6 | yes | |
| L569: k = 8 restores 99% for four more words | same | 99.0; 34 vs 30 words | yes | |
| Caption: grid decoder returned no wrong secret | column 5 | 0.0 | yes | Caption now names the method. |

## Sec. 6 and Table 4

All 48 cells match column 5 of `scenario-3of6.txt`, `scenario-3of5.txt` and
`scenario-4of9.txt`; the wrong entry of column 5 is 0.0 in every row.

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L627: 98% at 3% (3-of-6, 4 cards) | `scenario-3of6.txt` L11 | 98.4 | yes | |
| L627–628: all three people recovered in every trial of every fault | L16–21 | 100.0 in all six rows | yes | |
| L633–634: 83% at 3%; nothing if burnt; 98.8% with a fourth card | `scenario-3of5.txt` L5, L9, L11 | 83.2; 0.0; 98.8 | yes | |
| L640–643: 4 + 2 + 3 = 9; 2 + 2 = 4; 5 | arithmetic | | yes | |

## Sec. 8

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| Lean toolchain v4.36.0; seed 39 | E/README.txt L2; GridTests.lean L198; Tests.lean L207 | same | yes | |
| Commands for each table | first line of each log | same | yes | The paper quotes `"only t cards,"` with double quotes, the logs with single quotes. |
| README lists the SHA-256 of every source file | E/README.txt L4–18 | all 15 digests match the current files | yes | Recomputed with `shasum -a 256`. |
| Six grid files | E | six | yes | |
| Subcommands `encode`, `check`, `repair`, `split`, `combine` | Main.lean L8–12 | same | yes | |
| L372–373: depends only on the Lean core library | lakefile.toml | no `require` | yes | |
| L670–673: unit tests cover field axioms, SHA-256 and BIP39 vectors, decoding for k = 1…8 | `single-phrase.txt` L2–13 | 12 passes | yes | |

## Figures

No `\includegraphics`. `figures/rates.tex` regenerated by `figures/src/tables.py` in a
scratch copy is byte-identical to the shipped file; the script's mtime is 19 s later than
the render, so by mtime alone it would read as "script newer than render", but the
content is not stale. Running the script on a scratch copy of `main.tex` leaves it
unchanged (no `@@` markers remain). `figures/grid.tex` is hand-written; its only change
from version 2 is the header box width.
