# Numerical audit for parity39.4

Sources. E = `parity39/refs/experiments/` (unchanged; all 15 SHA-256 digests in
`README.txt` match the current source files). Lean = repository root. Line numbers for
`main.tex` are from `parity39.4/main.tex`. Every cell of Tables 1–4 and every coordinate
of `figures/rates.tex` was compared with the logs by a parser written for this audit
(54, 85, 6 and 48 cells; 24 coordinates). The numbers in the prose were checked by hand.

Harness column order (`GridTests.lean` L148–153, L193, L210): checksum only
(`detectOnly`) | card parity (`rowsOnly`) | parity+digest (`rowsDigest`) | grid, no
digest (`combineRows` with `digest := 0`) | grid + digest (`combineRows`).

Difference from version 3: 13 hunks of prose in `main.tex`. The four `table`
environments and the two `figure` environments are identical to version 3, and
`figures/`, `refs.bib` and `anvil-paper.cls` are byte-identical (`diff -r`, `cmp`).

## Round-three critical flag

| Flag | Status | Evidence |
|---|---|---|
| "both methods without a digest returned a wrong secret" (three methods have no digest; two returned it) | resolved | L563–565: "where card parity and the grid decoder without a digest both returned a wrong secret (the bracketed 0.2)". `grid-main-k4.txt` L31: checksum only 0.5 / 0.0, card parity 50.7 / 0.2, parity+digest 50.7 / 0.0, grid, no digest 50.7 / 0.2, grid + digest 50.7 / 0.0. Table 2 (L506) brackets [0 / 0.2] under Card parity and Grid, no digest only. |

## Mismatches

None. No number in the text disagrees with a table, a figure or a log.

## Sentences changed in this version

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L35 (abstract): "In 31,600 trials the grid decoder with its digest returned no wrong secret." | six grid files, column 5 | 13,600 + 3,000 + 3,000 + 4,500 + 4,500 + 3,000 = 31,600 trials; wrong = 0.0 in every row of column 5 | yes | Column 3 (parity+digest) is also 0.0 in every row. |
| L56: "the 41 participants who failed (of 92)" | SOUPS extract L41, L471, L604–608, L641–642 | N = 92; 26 + 15 = 41 did not recall BIP-39; "14 users out of the 41 users" | yes | |
| L127–131: disk arrays; first check is the plain sum of a single-parity array; further checks are the Reed–Solomon extension | eq. (1), L147–150; cited sources not on disk | S_0 is the exclusive-or of all words | yes for the paper's side | See citation-audit.md. |
| L165: "the user can enter the first N words into any existing wallet" | `RS.encode` (`RS.lean` L97–98) | systematic: data words unchanged | yes | |
| L195–196: a swap leaves S_0 unchanged, "nonzero unless the two wrong words err by the same value" | algebra | S_0 = e_1 + e_2 over a field of characteristic 2, zero exactly when e_1 = e_2 | yes | The round-three caveat is fixed. |
| L200–203: 325 swaps; 325 · 26/2047 ≈ 4; "under this assumption nearly every phrase with two wrong words would have such a wrong phrase among its cheapest candidates" | arithmetic; `Repair.lean` L114 | 325; 4.13 | yes | Derived, and now said to be under the uniformity assumption. No run without the swap limit exists on disk. |
| L256–258: cards "with the same number and threshold" differ in at least k+1 printed positions; different numbers, at least k | `Grid.lean` L41 (header = index + 32t) | equal headers leave all k+1 differences in the printed words | yes | |
| L298–299: correcting a wrong number "uses one of the floor(k/2) correctable symbols, so it needs k ≥ 2" | `Grid.lean` L159–163; `Repair.lean` L114–115; `RS.lean` L77 | the entered header is passed as a known symbol; `RS.decode` requires 2e + s ≤ k, so one error needs k ≥ 2 | yes | |
| L299–300: "at k = 4 leaves room for one other wrong word" | `RS.lean` L77 | e ≤ 2 at k = 4 with no unreadable word | yes | |
| L300–301: "A mislabelled card that does not repair alone is kept as unconfirmed evidence under the number entered." | `Grid.lean` L183–191 | `index := i` (the entered number), `verified := false`, header term of the entered number removed | yes, with a condition | Only if the card has the right count of words (L185); otherwise it is dropped (L192). Step 1 of the decoder (L334) states that condition. |
| L301–302: "Our experiments never enter a wrong number." | `GridTests.lean` L143 | `label := if sc.labels then some (i + 1) else none`: the true number or none | yes | `Tests.lean` has no card labels. |
| L343–347 (rescue): accept only if every guessed position then agrees "with another unconfirmed card" | `Grid.lean` L291–294 | `rows.any fun o => !o.verified && o.index != row.index && …` | yes | Preconditions unchanged and correct: one short of t, k ≥ 3, at most 14 unsettled columns, sets of 3 to k (L276, L282). |
| L348–352 (step 5): interpolate the secret row, decode it as a row, test the digest; "If that fails, test the reconstruction from each subset of t confirmed cards"; "If nothing passes, refuse." | `Grid.combineRows`, `Grid.lean` L329–350 | L336–340: joint candidate returned unless the row does not decode or the digest says false. L341–348: then every t-subset of the verified rows, accepted if a codeword and the digest says true. L349: refuse. | yes | The subsets are no longer conditioned on more than t confirmed cards, as in the code. With `digest = 0` (the "Grid, no digest" method) no subset is tested (L341). |
| L355–358: at most C(m,t) + 1 candidates; 2.6 × 10^-6 for m = 5, t = 3 | `Grid.lean` L336–348 | 11 · 2^-22 = 2.62 × 10^-6 | yes | |
| L432–435: with the filter, two parity words repair a swap or a dropped word, three repair two dropped words or a wrong word plus a dropped word, four repair any two wrong words, "in each case uniquely in at least 99.5% of trials" | `single-phrase.txt`, filter column | k = 2: L20–22 100, 100, 100; L56–58 100, 99.5, 100. k = 3: L35–36 99.5, 99.5; L71–72 100, 99.5. k = 4: L42, L78 100, 100 | yes | Minimum 99.5 in four cells. |
| L435–436: without the filter, "at k = 2 a swap is the unique repair in 84.5–96.5% of trials" | L20–21, L56–57, unfiltered | 94.0, 96.5, 87.0, 84.5 | yes | The rest is ambiguous (6.0, 3.5, 13.0, 15.5); wrong 0, refused 0. |
| L436–437: "at k = 3 the two-edit rows in 76–96%" | L35–36, L71–72, unfiltered | 96.0, 92.5, 82.0, 76.0 | yes | "Two-edit rows" has to be read as two dropped words and wrong + dropped. The "2 wrong words" row at k = 3 (0%, refused, L30, L66) is treated in the next sentence. See flags.md, non-critical. |
| L560–565: one wrong answer, 3-of-5, exactly t cards, 5% wrong; card parity and grid, no digest; "(the bracketed 0.2)" | `grid-main-k4.txt` L31 | 0.2 in columns 2 and 4 only; 1/400 = 0.25% truncated | yes | It is the only nonzero wrong entry outside the foreign-card rows in the six files. The foreign-card rows also hold wrong answers; see flags.md, non-critical. |
| L565–566: "The digest turned that trial into a refusal." | L31, columns 3 and 5 | 50.7 / 0.0 | yes | |
| L566–567: "Across all 31,600 grid trials in this paper the two methods with a digest returned no wrong secret." | six grid files, columns 3 and 5 | 0.0 in all 102 rows | yes | |
| L724–725: "The total of 31,600 trials counts every row of the six grid files, including rows that no table prints." | six files | 102 rows; 31,600 | yes | |
| L734–736 (conclusion): with the filter, two parity words repaired a swap or a dropped word in at least 99.5% of trials; four repaired any two wrong words in all of them | `single-phrase.txt` L20–22, L56–58; L42, L78 | minimum 99.5 (24+2 any swap); 100, 100 | yes | |
| L738–739 (conclusion): "with the digest it returned no wrong secret in 31,600 trials" | as above | 0 | yes | |

## Abstract, introduction

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L31–33: 99.5% vs 31% (3-of-5, all five cards, 10%) | `grid-main-k4.txt` L28 | 99.5 (grid), 30.5 (card parity) | yes | 30.5 is exactly 122/400; "31" is round-half-up. |
| L33: 61% vs 41% (2-of-3, all three cards, 10%) | `grid-main-k4.txt` L8 | 61.2, 40.7 | yes | 245/400 and 163/400. |
| L54–56: 40% after three days, 49% after seven | SOUPS extract L609–612 | success 60% and 51% | yes | |
| L57: 14 recoverable | extract L641–642, Table 4 | 14 | yes | |
| L60: checksum 4 bits (12 words), 8 bits (24) | BIP39 | 4, 8 | yes | |
| L78: "about 900 lines of Lean 4" | `Parity39/*.lean` | 867 lines | yes | |

## Sec. 3 and Sec. 4 (unchanged claims, rechecked)

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L179–185: swap then at most floor((k−2)/2) substitutions; dropped or extra words up to three | `Repair.lean` L114, L104–105 | `(k - 2) / 2`; `maxEdits := 3` | yes | |
| L230–235: h_i = i + 32t, n ≤ 31, t ≤ 63 | `Grid.lean` L41–43, L83 | same; 32 · 63 + 31 = 2047 | yes | |
| L236–237: g = 2, k = 4 gives 30 words | 24 + 2 + 4 | 30 | yes | |
| L283–286: bounds 2, 4, 7 | floor(((k+1)(m−t+1) − 1)/2), k = 4 | 2, 4, 7 | yes | |
| L294: tries each of the 31 numbers | `Grid.lean` L170–174 | `Array.range 31` | yes | |
| L295–298: a wrong number is one wrong symbol, corrected and reported; the number settled on is the one consistent with the words | `Repair.lean` L123–128; `Grid.lean` L175–179; `Main.lean` (combine prints row notes) | note "the card's label does not match its words"; index taken from the corrected header | yes | Not exercised by either harness, as the paper now says. |
| L311–316: digest rule and the vector `siege`, `say` | `Grid.lean` L62–66; recomputed with Python `hashlib` and `data/english.txt` | `siege`, `say` | yes | |
| L320: 2^-22 per candidate | g = 2 | 2^-22 | yes | |
| L336–340: columns: confirmed cards alone when at least t; exactly t taken as given; otherwise at least t+1 agree and no tie | `Grid.lean` L118–140, L241 | same | yes | |
| L366–368: 264 − 11q; 132 bits; 124 bits | arithmetic | 132, 124 | yes | |

## Sec. 5.1 setup

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L403–419: five methods | `GridTests.lean` L66–98, L147–153 | as described | yes | |
| L420–421: half-widths 4.9, 5.7, 6.2, 6.9 (n = 400, 300, 250, 200) | 1.96 · sqrt(0.25/n) | 4.90, 5.66, 6.20, 6.93 | yes | |
| L422–423: harness truncates to one decimal; a row can sum to 99.9 | `GridTests.lean` L61–64; `Tests.lean` L172 | integer division; `grid-main-k4.txt` L36: 40.2 + 59.7 = 99.9 | yes | |
| L423–425: repeated configurations differ within the margins | Table 2 vs Table 4, 3-of-5 | 99.7/99.6, 84.5/83.2, 50.7/54.8, 100/100, 98.2/98 | yes | Largest difference 4.1 points. |

## Sec. 5.2 and Table 1 (`single-phrase.txt`)

All 54 cells of Table 1 match the "unique" columns of the log (L17–25, L29–37, L41–49,
L53–61, L65–73, L77–85), without / with the filter. The three footnoted cells are the
three with a nonzero unfiltered "wrong" entry (L24 0.5, L54 1.5, L60 1.5).

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L431: everything inside the capacity is repaired | L17, L19 and the same rows of each block | 100 / 100 | yes | |
| L437–440: two wrong words at k ≤ 3 and wrong + dropped at k = 2 were refused, apart from 0.5–1.5% of unfiltered trials at k = 2 | L18, L30, L54, L66; L24, L60 | refused 100 except L24 99.5, L54 98.5, L60 98.5 unfiltered | yes | |
| L440–441: "With the filter, or with k ≥ 3, no trial was wrong" | every "wrong" column | nonzero only at L24, L54, L60, unfiltered, k = 2 | yes | |
| L693–694: for 24 words, k = 3 covers every single edit and k = 4 any two wrong words | L65–73, L78 | 100 / 100 | yes | |

## Sec. 5.3, Table 2 and Figure 2 (`grid-main-k4.txt`)

All 85 cells of Table 2 (17 rows × 5 methods), including the bracketed wrong-secret
pairs, match the log: [67 / 59.7] under Checksum only and Card parity (L16, L36),
[0 / 0.2] under Card parity and Grid, no digest (L11, L31), [100 / 100] under Checksum
only, Card parity and Grid, no digest (L17, L37). No bracket is missing and none is
extra. All 24 coordinates in `figures/rates.tex` match L5–8 and L25–28 (columns 1, 2
and 5).

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L518–519: 2-of-3 gains 20 points at 10% | L8 | 61.2 − 40.7 = 20.5 | yes | |
| L524–529: 99.5 vs 31; 61 vs 41 | L28, L8 | as above | yes | |
| L533: 90% and 98% (5 burnt words) | L13, L33 | 89.7, 98.2 | yes | |
| L536–541: swap 100%; with 3% wrong 86 and 93; joint 92.5 and 100 | L19, L21, L39, L41; L20, L40 | 100; 86.2, 92.7; 92.5, 100 | yes | |
| L541–542: dropped words 94.7 and 98.2 | L15, L35 | 94.7 (per-card 94.5); 98.2 (98.2) | yes | |
| L546–547: per-card methods without a digest wrong in 60–67% | L16, L36 | 67.0, 59.7 | yes | 59.7 is 239/400 = 59.75 truncated. |
| L547–550: no-digest joint decoding: 100% with two spares; refuses with one; wrong every time with none | L36; L16; L17, L37 | 100.0 / 0.0; 0.0 / 0.0; 0.0 / 100.0 | yes | Scenario files agree. |
| L550–552: the digest removes every wrong answer and recovers whenever a spare exists | L16, L36, columns 3 and 5 | 100.0 / 0.0 | yes | |
| L553–554: exactly t and one foreign: the two digest methods refuse | L17, L37 | 0.0 / 0.0 | yes | |
| L556–558: illegible numbers 98 and 99.7, against 99.7 and 100 | L18, L38; L6, L26 | 98.0, 99.7; 99.7, 100.0 | yes | |
| L567–570: below about 10^-4 at 95%; below 0.75% per 400-trial cell | 3/31,600; 3/400 | 0.95 × 10^-4; 0.75% | yes | Rule of three. |

## Sec. 5.4 and Table 3

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L577–578: 88% and 85% at 3% | `grid-main-k4.txt` L10, L30 | 87.7, 84.5 | yes | |
| Table 3, k = 4 | L10, L30; L11, L31 | 87.7 / 84.5; 62.0 / 50.7 | yes | |
| Table 3, k = 6 | `grid-minimal-k6.txt` L6, L14; L7, L15 | 95.6 / 94.0; 83.6 / 78.6 | yes | |
| Table 3, k = 8 | `grid-minimal-k8.txt` L6, L14; L7, L15 | 99.0 / 99.0; 95.6 / 94.6 | yes | |
| L579: k = 8 restores 99% for four more words | same | 99.0; 34 vs 30 words | yes | |
| Caption: grid decoder returned no wrong secret | column 5 | 0.0 | yes | |

## Sec. 6 and Table 4

All 48 cells match column 5 of `scenario-3of6.txt`, `scenario-3of5.txt` and
`scenario-4of9.txt`; the wrong entry of column 5 is 0.0 in every row.

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| L637: 98% at 3% (3-of-6, 4 cards) | `scenario-3of6.txt` L11 | 98.4 | yes | |
| L637–638: all three people recovered in every trial of every fault | L16–21 | 100.0 in all six rows | yes | |
| L643–644: 83% at 3%; nothing if burnt; 98.8% with a fourth card | `scenario-3of5.txt` L5, L9, L11 | 83.2; 0.0; 98.8 | yes | |
| L650–653: 4 + 2 + 3 = 9; 2 + 2 = 4; 5 | arithmetic | | yes | |

## Sec. 8

| Text claim | Source | Value | Match | Notes |
|---|---|---|---|---|
| Lean toolchain v4.36.0; seed 39 | `lean-toolchain`; `GridTests.lean` L198; `Tests.lean` L207 | same | yes | |
| Commands for each table | first line of each log | same | yes | The paper quotes `"only t cards,"` with double quotes, the logs with single quotes. |
| README lists the SHA-256 of every source file | E/README.txt L4–18 | all 15 digests match the current files | yes | Recomputed with `shasum -a 256`. |
| Six grid files | E | six | yes | |
| L677–683: unit tests cover field axioms, SHA-256 and BIP39 vectors, decoding for k = 1…8 | `single-phrase.txt` L2–13 | 12 passes | yes | |

## Figures

No `\includegraphics`. `figures/rates.tex` regenerated by `figures/src/tables.py` in a
scratch copy is byte-identical to the shipped file, and the script's mtime equals the
render's, so it is not stale. Running the script on a scratch copy of `main.tex` leaves
it unchanged. `figures/grid.tex` is hand-written and byte-identical to version 3.
