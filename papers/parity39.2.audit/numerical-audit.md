# Numerical audit for parity39.2

Sources. E = `parity39/refs/experiments/`. Lean = repository root. Line numbers for
`main.tex` are from `parity39.2/main.tex`. Tables were checked by an independent parser
written for this audit, not by `figures/src/tables.py`; `tables.py` was then run on a
scratch copy as a cross-check.

Harness column order (GridTests.lean L148–153 and L193, L210): checksum only (`detectOnly`)
| card parity (`rowsOnly`) | parity+digest (`rowsDigest`) | grid, no digest
(`combineRows` with `digest := 0`) | grid + digest (`combineRows`). Table 2 prints columns
1, 2, 3 and 5.

Percentages in the logs are truncated to one decimal, not rounded (`pct`, GridTests.lean
L61–64 and Tests.lean: `x * 1000 / total` in integer arithmetic).

## Mismatches

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L688–689: "The trial total counts every row of the **five** grid files." | E directory; `tables.py` L87–88; main.tex L678–686 | **Six** grid files: `grid-main-k4.txt`, `grid-minimal-k6.txt`, `grid-minimal-k8.txt`, `scenario-3of6.txt`, `scenario-3of5.txt`, `scenario-4of9.txt` | NO | 31,600 is the sum over all six (13,600 + 3,000 + 3,000 + 4,500 + 4,500 + 3,000). No five of them sum to 31,600. Probably a confusion with the five strategy columns. |
| L407–409: "Where the original was not the unique repair the outcome was ambiguous, except beyond the capacity of $k=2$: there the procedure refused" | Table 1 L432; E/single-phrase.txt L30, L66 | "2 wrong words" at 12+3 and 24+3: 0% unique, 0% ambiguous, **100% refused**, with and without the filter | NO | Two wrong words exceed the capacity of k = 3 as well (2e = 4 > 3), and those two cells are printed "refused" in the table. The exception has to cover k = 3. |

## Abstract

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L30–32: 99.5% from all five cards of 3-of-5 at one word in ten wrong | E/grid-main-k4.txt L28, col 5 | 99.5 | yes | |
| L32: repairing cards separately recovered 31% | same line, col 2 | 30.5 | yes | Rounded to an integer. |
| L32: 61% against 41%, all three cards of 2-of-3 | E/grid-main-k4.txt L8, cols 5 and 2 | 61.2, 40.7 | yes | |
| L33–34: with exactly t cards joint decoding adds nothing | every "only t cards" and "t cards" row in all six files | grid + digest equals parity+digest in every such row | yes | |
| L34: 31,600 trials, no wrong secret | all six grid files | total 31,600; wrong = 0.0 in the grid + digest column of all 102 rows | yes | Also 0.0 in the parity+digest column of all 102 rows. |
| L25: 2e + s ≤ k | `Parity39/RS.lean` L54, L77 | guard `2 * e + s ≤ k` | yes | |

## Table 1 (L424–435) against E/single-phrase.txt

All 54 cells match (unique %, parity only / parity + BIP39 checksum), 200 trials per row.

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| 24+2 adjacent swap 87 / 100; any swap 84.5 / 99.5 | L56, L57 | 87.0 / 100.0; 84.5 / 99.5 | yes | Round-one flag cells. |
| 12+2 adjacent 94 / 100; any 96.5 / 100; 1 dropped 99 / 100; 2 dropped 0 / 1 | L20–23 | same | yes | |
| 12+3: 2 dropped 96 / 99.5; 1 wrong + 1 dropped 92.5 / 99.5 | L35, L36 | same | yes | |
| 24+2: 1 dropped 99.5 / 100; 2 dropped 0 / 30 | L58, L59 | same | yes | |
| 24+3: 2 dropped 82 / 100; 1 wrong + 1 dropped 76 / 99.5 | L71, L72 | same | yes | |
| "refused" cells: 2 wrong at 12+2, 12+3, 24+2, 24+3; 1 wrong + 1 dropped at 12+2, 24+2 | L18, L30, L54, L66, L24, L60 | 0 unique, 0 ambiguous in both halves | yes | |
| Footnote a: single wrong phrase without the filter in 0.5% (12+2) or 1.5% (24+2) | L24; L54, L60 | 0.5; 1.5, 1.5 | yes | Three cells carry the mark, and they are the only three rows with a non-zero "wrong" value in the file. |
| L409: "0.5--1.5% of unfiltered trials in three rows" | same | same | yes | |
| L410–411: with the filter, or with k ≥ 3, no trial was wrong | all blocks | wrong = 0.0 in every filtered row and every row of 12+3, 12+4, 24+3, 24+4 | yes | |
| L404: everything inside the capacity is repaired | 1 wrong, 2 unreadable (all k); 2 wrong (k = 4) | 100.0 in all | yes | |
| L405–407: two parity words repair a swap or a dropped word; three repair two dropped words or a wrong plus a dropped word; four repair any two wrong words | Table 1 | k = 2: swap 84.5–96.5 unfiltered, 99.5–100 filtered; dropped 99–99.5 / 100. k = 3: 76–96 unfiltered, 99.5–100 filtered. k = 4: 100 | partial | True as "unique repair in at least 99.5% of trials" only with the BIP39 filter. Not flagged as a mismatch; see flags.md, non-critical. Repeated in the conclusion (L698–699). |
| Caption: 200 trials | file header and block headers | 200 | yes | |

## Table 2 (L459–477) against E/grid-main-k4.txt

All 68 cells match, including the four bracketed wrong-secret entries.

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| one card is foreign, all cards: 33 / 40.2 [67 / 59.7] for checksum only and card parity; 100 / 100 with digest | L16, L36 | 33.0 / 67.0 and 40.2 / 59.7; 100.0 / 0.0 | yes | |
| only t cards, 5% wrong, card parity: 62 / 50.7 [0 / 0.2] | L11, L31 | 62.0 / 0.0; 50.7 / 0.2 | yes | 0.2 is one trial in 400 (0.25%, truncated). |
| only t cards, one foreign: 0 / 0 [100 / 100] without digest; 0 / 0 with | L17, L37 | 0.0 / 100.0; 0.0 / 0.0 | yes | |
| Caption: 30-word cards, k = 4, 400 trials | file headers L3, L23 | 24 + 2 + 4, 400 | yes | |

## Figure 2 (figures/rates.tex) against E/grid-main-k4.txt

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| 2-of-3 checksum only (1,80.7) (3,33.0) (5,12.7) (10,1.0) | L5–8 col 1 | same | yes | |
| 2-of-3 card parity (1,100.0) (3,99.2) (5,93.5) (10,40.7) | L5–8 col 2 | same | yes | |
| 2-of-3 grid (1,100.0) (3,99.7) (5,96.7) (10,61.2) | L5–8 col 5 | same | yes | |
| 3-of-5 checksum only (1,89.2) (3,33.2) (5,7.0) (10,0.0) | L25–28 col 1 | same | yes | |
| 3-of-5 card parity (1,100.0) (3,99.7) (5,95.5) (10,30.5) | L25–28 col 2 | same | yes | |
| 3-of-5 grid (1,100.0) (3,100.0) (5,100.0) (10,99.5) | L25–28 col 5 | same | yes | |
| Caption L487–488: matches per-card repair up to 5%, gains 20 points at 10% | L5–8 | gaps 0, 0.5, 3.2 and 20.5 points | yes | Round-one caption note resolved. |

`rates.tex` regenerated by `tables.py` in a scratch copy is byte-identical to the file in
`parity39.2/figures/`.

## Table 3 (L556–557)

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| 3%: 87.7 / 84.5; 95.6 / 94; 99 / 99 | grid-main-k4 L10, L30; k6 L6, L14; k8 L6, L14 (col 5) | same | yes | |
| 5%: 62 / 50.7; 83.6 / 78.6; 95.6 / 94.6 | grid-main-k4 L11, L31; k6 L7, L15; k8 L7, L15 | same | yes | 95.6, 83.6, 78.6 and 94.6 are truncations of 95.67, 83.67, 78.67 and 94.67 (287, 251, 236 and 284 of 300). |
| Caption: k = 4, 400 trials; k = 6, 8, 300 trials | file headers | 400; 300 | yes | |
| Caption: no trial returned a wrong secret | col 5 of those rows | 0.0 | yes | True for the grid decoder shown. Card parity without digest returned one in the k = 4, 5%, 3-of-5 cell (L31). The caption does not name the method. |
| Card lengths 30, 32, 34 | 24 + 2 + k | 30, 32, 34 | yes | |

## Table 4 (L583–592)

All 48 cells match the grid + digest column of `scenario-3of6.txt` (L4–21),
`scenario-3of5.txt` (L4–21) and `scenario-4of9.txt` (L4–15). 250 trials each; wrong = 0.0
in that column throughout.

## Body text, Sections 5 and 6

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L494–495: 99.5% vs 31% | grid-main-k4 L28 | 99.5, 30.5 | yes | |
| L497: 61% vs 41% | L8 | 61.2, 40.7 | yes | |
| L502: burns, 90% (2-of-3) and 98% (3-of-5) | L13, L33 | 89.7, 98.2 | yes | |
| L506: one swap, 100% with all cards and with exactly t; checksum only recovers nothing | L19, L21, L39, L41 | 100.0; 0.0 | yes | |
| L508: swap + 3%, per-card 86% and 93% | L20, L40 | 86.2, 92.7 | yes | |
| L510: joint decoding 92.5% and 100% | L20, L40 | 92.5, 100.0 | yes | |
| L510–511: dropped words 94.7% and 98.2%, equal to per-card within error | L15, L35 | 94.7 vs 94.5; 98.2 vs 98.2 | yes | |
| L516: wrong secret in 60–67% of trials | L16, L36 | 67.0, 59.7 | yes | |
| L518–520: joint decoding without the digest refused every 2-of-3 trial with all cards; with exactly t cards returned a wrong secret every time | L16 col 4; L17, L37 col 4 | 0.0 / 0.0; 0.0 / 100.0 | yes | Not reported: the same column recovered 100% for 3-of-5 with all cards (L36). See flags.md, non-critical. |
| L520–521: with exactly t cards and one foreign, the two digest methods refuse | L17, L37 | 0.0 / 0.0 | yes | |
| L524–525: illegible numbers 98% and 99.7%, against 99.7% and 100% with legible numbers | L18, L38; L6, L26 | 98.0, 99.7; 99.7, 100.0 | yes | |
| L528–530: one wrong answer, 3-of-5, exactly t, 5% (bracketed 0.2) | L31 | card parity 50.7 / 0.2; parity+digest 50.7 / 0.0 | yes | |
| L531: 31,600 grid trials | six files | 31,600 | yes | |
| L533: pooled bound below about 10^-4 | 3 / 31,600 | 9.5 × 10^-5 | yes | |
| L534: below 0.75% for a 400-trial cell | 3 / 400 | 0.75% | yes | |
| L541–543: 88% and 85% at 3%; k = 8 restores 99% for four more words | L10, L30; k8 L6, L14 | 87.7, 84.5; 99.0, 99.0; 34 − 30 = 4 | yes | |
| L394–395: half-widths 4.9, 5.7, 6.2, 6.9 for 400, 300, 250, 200 trials | 1.96·sqrt(0.25/n) | 4.90, 5.66, 6.20, 6.93 | yes | |
| L396–398: repeated configurations differ within these margins | Table 2 vs Table 4, 3-of-5 | 84.5 vs 83.2; 50.7 vs 54.8; 99.7 vs 99.6; 98.2 vs 98.0; 100 vs 100 | yes | Largest gap 4.1 points. |
| L601: 3-of-6, four cards, 98% at 3% | scenario-3of6 L11 | 98.4 | yes | |
| L601–602: all six cards recovered in every trial of every fault | scenario-3of6 L16–21 | 100.0 in all six | yes | |
| L607: owner alone 83% at 3% | scenario-3of5 L5 | 83.2 | yes | |
| L608: one backup card restores the margin, 98.8% | scenario-3of5 L11 | 98.8 | yes | |
| L614–617: 4 + 2 + 3 = 9 cards; executor + two heirs = 4, + third = 5; heirs alone 3 | arithmetic | same | yes | |
| L657–658: for 24 words, k = 3 covers every single edit and k = 4 any two wrong words | single-phrase.txt L67–70, L73, L78 | 100.0 in each | yes | |

## Arithmetic and constants

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L346–347: 264 − 11q; 12 words leave 132 bits, 124 after the 8-bit checksum | 24·11; 264 − 132; 132 − 8 | 264; 132; 124 | yes | |
| L273–276: floor(((k+1)(m−t+1) − 1)/2) = 2, 4, 7 | k = 4; (m,t) = (2,2), (3,2), (5,3) | 2, 4, 7 | yes | |
| L304: 2^(−11g), g = 2 | | 2^−22 | yes | |
| L308: C(5,3)·2^−22 about 2.4 × 10^−6 | 10 / 4,194,304 | 2.38 × 10^−6 | yes | The decoder tests one joint reconstruction before the subsets (`Grid.lean` L336–348), so the count of candidates is C(m,t) + 1: 2.6 × 10^−6. See flags.md, non-critical. |
| L191–192: 325 swaps; 325·26/2047 about 4 | C(26,2); product | 325; 4.13 | yes | |
| L226–227, Table 3 header: cards of 30, 32, 34 words | 24 + 2 + k | 30, 32, 34 | yes | |
| L204, L225: n ≤ 31, t ≤ 63, five low bits | `Grid.lean` L41–43, L83 | header = i + 32t; index = h mod 32; n ≤ 31 guarded | yes | t ≤ 63 follows from the 11-bit symbol; the code does not check it. |
| L132–134: x^11 + x^2 + 1; group order 2047 | `GF.lean` L14, L17 | 0x805; 2047 | yes | |
| L284: 31 possible numbers | `Grid.lean` L170 | `Array.range 31` | yes | |
| L329–330: rescue needs k ≥ 3, at most 14 unsettled columns, 3 to k guessed columns | `Grid.lean` L276, L282 | same | yes | |
| L176, L178, L651: up to three dropped or extra words | `Repair.lean` L105 (`maxEdits := 3`); `Grid.lean` L162 | 3 | yes | |
| L175: at most floor((k−2)/2) substitutions after a swap | `Repair.lean` L114 | `(k - 2) / 2` | yes | |
| L75: about 900 lines of Lean 4 | `wc -l` | `Parity39/*.lean` 867 lines, 875 with `Parity39.lean`; `Main.lean` 200; harnesses 426 | yes | True of the library. |
| L671, L688: toolchain v4.36.0; seed 39 | `lean-toolchain`; `Tests.lean` and `GridTests.lean` `IO.setRandSeed 39` | same | yes | |
| L645–646: unit tests cover field axioms, SHA-256 and BIP39 vectors, decoding within capacity for k = 1..8 | single-phrase.txt L2–13 | 12 passing checks, 1,280 RS trials for k = 1…8 | yes | |

## Digest test vector (L299–301)

Recomputed with Python `hashlib` and `data/english.txt`: SHA-256 of the 19 ASCII bytes
`bip39-parity/digest` followed by the 24 word indices of `abandon` × 23 + `art` as two
big-endian bytes each; word j is the low 11 bits of bytes 2j, 2j+1. Result: `siege`, `say`.
Matches the paper. The mnemonic is a valid BIP39 phrase. The construction in the text
matches `Grid.digestWords` (`Grid.lean` L62–66). The round-one reading ("first 11-bit
groups") would give `main`, `admit`, so the vector separates the two rules.

## SHA-256 digests in E/README.txt

All 15 listed files were hashed with `shasum -a 256` and compared: `lean-toolchain`,
`lakefile.toml`, `Parity39.lean`, the eight files in `Parity39/`, `Main.lean`,
`Tests.lean`, `GridTests.lean`, `data/english.txt`. All 15 match. The base commit named
in the README (24d4d93…) is the current `HEAD`; `Grid.lean` and `GridTests.lean` are
untracked and four listed files are modified, as the README's "plus uncommitted changes"
says. Every evidence file is newer than the harness source that produced it.

## Algorithm descriptions against the Lean source

| Paper statement | Source | Match | Notes |
|---|---|---|---|
| L207–227: card is a codeword of length W+1; rows r_0..r_{t-1} with header 0; u has zero data and header 1; c_i = sum x_i^d r_d + h_i u; h_i = i + 32t; x_i has bit pattern i | `Grid.lean` L41, L49–53, L56–59, L75, L81–89 | yes | Rows are encoded at length W, which is the length-(W+1) codeword with header 0. `headerOffset` is the parity of u. |
| L281–287: known number supplied as a known symbol; otherwise header unreadable; if no unique repair, try each of 31 numbers and keep least cost | `Grid.lean` L158–174 | yes | |
| L296–299: digest construction | `Grid.lean` L62–66 | yes | Round-one flag resolved. |
| L303–308: accept only if digest matches; on failure try each t-subset of repaired cards | `Grid.lean` L336–348 | yes | |
| L317–321, step 1 | `Grid.lean` L158–193; `requireBip39 = false` at L162 | yes | A card with several equally cheap repairs is treated like one with none. Duplicate card numbers are dropped (L208); not mentioned. |
| L322–326, step 2 (column rule) | `Grid.lean` L118–140, L239–242 | yes | Exactly t values taken as given; otherwise at least t+1 agreeing and no tie. |
| L327–328, step 3 | `Grid.lean` L231–263 | yes | |
| L329–332, step 4 (rescue) | `Grid.lean` L272–299 | yes | "Another card" is another unconfirmed card (L293). |
| L333–336, step 5 | `Grid.lean` L329–350 | yes | Round-one note resolved. |
| L172–186: edit hypotheses, cost, minimum-cost set, BIP39 filter before the minimum | `Repair.lean` L53–94, L104–142 | yes | |
| L161–164: Sugiyama, position search, Forney; accept only if syndromes vanish and capacity respected | `RS.lean` L48–94 | yes | |
| L383–392: the four compared methods | `GridTests.lean` L67–83, L86–88, L92–98; `Grid.lean` L310 | yes | |
| L372–379: faults (word error, burn, swap, dropped word with probability one half, foreign, garbage) | `GridTests.lean` L121–142 | yes | Swap picks two distinct positions (L134). Foreign and garbage cards receive no further damage (`intactOnly`). |
| L363–366: single-phrase outcomes | `Tests.lean` `Tally`, `runTrials` | yes | |
| L690–691: subcommands encode, check, repair, split, combine | `Main.lean` L80, L90, L98, L188, L192 | yes | |
| L358–359: depends only on the Lean core library | `lakefile.toml` | yes | No `require` entries. |

## Figure source-of-truth check

No `\includegraphics`. Both figures are TikZ files read with `\input`. `figures/rates.tex`
is generated by `figures/src/tables.py`; the script's mtime (10:37:09) is 41 s later than
the figure's (10:36:28), but regenerating in a scratch copy gives a byte-identical file,
so the figure is not stale. `figures/grid.tex` is hand-written and has no source script.
