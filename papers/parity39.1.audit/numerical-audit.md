# Numerical audit for parity39.1

Paper lines are `parity39.1/main.tex`. Evidence files are under
`parity39/refs/experiments/` unless a path says otherwise.

## Sources used

- **Table 2, Figure 2**: `grid-main-k4.final` (28 data rows). `grid-main-k4.txt` holds
  headers only (empty run) and was not used.
- **Table 1**: `single-phrase.txt`. The file was still being written when the audit
  began (it stopped mid-row in the 24+2 block); it was complete (all six blocks,
  L15–85) by the time the checks below were run, and the checks use the complete
  file. The "Measured behaviour" table in the repo-root `README.md` (L51–61) was
  read as a cross-check and agrees with it in every cell.
- `grid-main-k4.final` also grew during the audit: its last row (3-of-5,
  "numbers illegible, 3%") arrived after the first read. Counts below use the final
  28-row state.
- **Table 3**: `grid-main-k4.final`, `grid-minimal-k6.txt`, `grid-minimal-k8.txt`.
- **Table 4**: `scenario-3of6.txt`, `scenario-3of5.txt`, `scenario-4of9.txt`.
- Implementation: `Parity39/*.lean`, `GridTests.lean`, `Tests.lean`, `Main.lean`
  (read only; `lake` not run).

## Mismatches

| Text claim | Source (Tab/Fig) | Source value | Match | Notes |
|---|---|---|---|---|
| L348: "24+2 leaves 13–15% of swaps ambiguous" | `single-phrase.txt` L56–57 (24+2, parity only) | adjacent swap 13.0% ambiguous; swap of any two words **15.5%** ambiguous (84.5% unique) | **NO** | Upper end is 15.5%, not 15%. README.md L55–56 agrees (87 and 84.5 unique). Critical flag (numerical inconsistency). |
| L263–264: digest words are "the first d 11-bit groups of SHA-256(...)" | `Parity39/Grid.lean` L62–66 | word i = `((h[2i] << 8) | h[2i+1]) & 0x7ff`: the **low 11 bits of the i-th 16-bit big-endian group** of the hash | **NO** | For d = 2 the paper's rule takes hash bits 0–21; the code takes bits 5–15 and 21–31. Domain string and the two-bytes-per-seed-word encoding do match. Critical flag (description does not match the implementation that produced every grid number). |
| L434–436 (Fig. 2 caption): "Joint decoding gains little over per-card repair with one spare card (2-of-3)" | `grid-main-k4.final` L5–8; `figures/rates.tex` L13–14 | card parity → grid: 100 → 100, 99.2 → 99.7, 93.5 → 96.7, **40.7 → 61.2** | **partly** | True at 1–5% (gains of 0, 0.5, 3.2 points). At 10% the gain is 20.5 points, four times the 5-point resolution the paper sets for itself at L338–339. Non-critical (wording), but the caption contradicts its own right-most data point. |
| L444–445: 3-of-5 with exactly 3 cards at 3% recovers "79%"; L509: the same arrangement recovers "83%" | `grid-main-k4.final` L27 (79.0, 400 trials); `scenario-3of5.txt` L5 (83.2, 250 trials) | 79.0 vs 83.2 | each matches its own source | Same configuration (3-of-5, k = 4, exactly t cards, 3% word errors), two independent samples, two different headline numbers, no remark in the text. The 4.2-point gap is inside sampling noise. Same pattern at 5% (50.7 in Table 2 vs 54.8 in Table 4) and for 5 burnt words with all five cards (98.5 vs 98.0). Non-critical note. |
| L178–181: without the swap restriction "a 24+2 phrase with two wrong words was 'repaired' to a different valid phrase in 97.6% of trials during development" | none | no record on disk | **unverifiable** | No experiment file, README passage, doc or test contains this figure (repo-wide search for "97.6" finds only this sentence and an unrelated cell in `scenario-3of6.txt` L18). Unsupported claim. |

## Verified values

### Abstract and headline numbers

| Text claim | Source | Source value | Match | Notes |
|---|---|---|---|---|
| L31, L397, L599: 28,000 fault-injection trials | row count × trials per row over the six grid files | 28×400 + 8×300 + 8×300 + 18×250 + 18×250 + 12×250 = 11,200 + 2,400 + 2,400 + 4,500 + 4,500 + 3,000 = **28,000** | yes | Each trial is one dealing run through all four decoders. The total includes rows the paper does not tabulate (garbage card, dropped words, illegible numbers in `grid-main-k4.final`). It depends on the 28th row of `grid-main-k4.final`; with the 27 rows present at first read the total was 27,600. |
| L31–32, L397–398, L599–600: combined decoder never returned a wrong secret | "grid + digest" column, all 92 rows of the six files | % wrong = 0.0 in every row | yes | Holds for the decoder **with digest** only. The "grid" column without digest returns a wrong secret in 100% of trials in every "only t cards / exactly t cards, one from another set" row. The paper's wording ("combined decoder", "grid decoder with digest") is consistent with that. |
| L32–34, L382–384: 3-of-5, all cards, 10% wrong: grid 99.7%, per-card repair 36%, checksums none | `grid-main-k4.final` L25 | 99.7 / 36.0 / 0.0 | yes | |
| L389: 5 burnt words: grid recovers 90% (2-of-3) and 98.5% (3-of-5) | `grid-main-k4.final` L13, L30 | 89.7, 98.5 | yes | 89.7 rounded to 90 in text; Table 2 prints 89.7. |
| L393–394: per-card methods return a wrong secret in 61–67% of trials | `grid-main-k4.final` L16, L33 | 67.0 (2-of-3), 61.0 (3-of-5) | yes | |
| L394–395: grid with digest right every time with a spare card, refuses every time with none | `grid-main-k4.final` L16–17, L33–34; scenario files "one from another set" rows | 100.0 / 0.0 with a spare; 0.0 / 0.0 with exactly t | yes | |
| L444–446: only t cards at 3%: k = 4 recovers 88% (2-of-3) and 79% (3-of-5); k = 8 restores 99% | `grid-main-k4.final` L10, L27; `grid-minimal-k8.txt` L6, L13 | 87.7, 79.0; 99.0, 99.6 | yes | |
| L338–339: 400 trials give a 95% half-width of at most 5 points | arithmetic | 1.96·sqrt(0.25/400) = 4.9 | yes | Applies to Table 2 / Fig. 2 only. Worst-case half-widths elsewhere: 6.9 (Table 1, 200 trials), 5.7 (Table 3 k = 6, 8, 300 trials), 6.2 (Table 4, 250 trials). Non-critical note. |

### Table 1 (L353–375) against `single-phrase.txt` (right-hand block, "parity + BIP39 checksum", "unique" column)

| Row | 12+2 | 12+3 | 12+4 | 24+2 | 24+3 | 24+4 | Match |
|---|---|---|---|---|---|---|---|
| 1 wrong word | 100 (L17) | 100 (L29) | 100 (L41) | 100 (L53) | 100 (L65) | 100 (L77) | yes |
| 2 unreadable | 100 (L19) | 100 (L31) | 100 (L43) | 100 (L55) | 100 (L67) | 100 (L79) | yes |
| adjacent swap | 100 (L20) | 100 (L32) | 100 (L44) | 100 (L56) | 100 (L68) | 100 (L80) | yes |
| any 2 swapped | 100 (L21) | 100 (L33) | 100 (L45) | 99.5 (L57) | 100 (L69) | 100 (L81) | yes |
| 1 dropped | 100 (L22) | 100 (L34) | 100 (L46) | 100 (L58) | 100 (L70) | 100 (L82) | yes |
| 1 extra | 100 (L25) | 100 (L37) | 100 (L49) | 100 (L61) | 100 (L73) | 100 (L85) | yes |
| 2 dropped | 1 (L23: 1.0) | 99.5 (L35) | 100 (L47) | 30 (L59: 30.0) | 100 (L71) | 100 (L83) | yes |
| 1 wrong + 1 dropped | refused (L24: 100% refused) | 99.5 (L36) | 100 (L48) | refused (L60) | 99.5 (L72) | 100 (L84) | yes |
| 2 wrong | refused (L18) | refused (L30) | 100 (L42) | refused (L54) | refused (L66) | 100 (L78) | yes |

All 54 cells match. Caption "200 trials" matches the block headers.

Text around Table 1:

| Text claim | Source | Source value | Match |
|---|---|---|---|
| L345–347: two parity words repair a swap or a dropped word; three repair two dropped words or a wrong plus a dropped word; four repair any two wrong words | Table 1 cells above | 99.5–100 with the checksum filter | yes (with the filter; without it 24+2 swaps are unique in 84.5–87% of trials, as L348 goes on to say) |
| L349–351: a single wrong candidate appeared only beyond the capacity of k = 2, without the filter, in 0.5–1.5% of trials | `single-phrase.txt` L24 (12+2, 1 wrong + 1 dropped: 0.5%), L54 (24+2, 2 wrong: 1.5%), L60 (24+2, 1 wrong + 1 dropped: 1.5%) | 0.5, 1.5, 1.5; every "wrong" cell in the filtered block is 0.0 | yes |
| L351: with k ≥ 3 it did not appear | all "wrong" cells of the 12+3, 12+4, 24+3, 24+4 blocks | 0.0 | yes |
| L559–560: for an unshared 24-word phrase k = 3 covers every single edit and k = 4 any two wrong words | 24+3 and 24+4 blocks | 100 on every single-edit row; 24+4 "2 wrong" 100 | yes |
| L547–548: unit tests cover field axioms, SHA-256 and BIP39 vectors, decoding within capacity for k = 1…8 | `single-phrase.txt` L2–13 | all "pass" | yes |

### Table 2 (L400–428) against `grid-main-k4.final` (2-of-3 block L5–18 / 3-of-5 block L22–35)

| Row | Checksum only | Card parity | Grid (= "grid + digest" column) | Match |
|---|---|---|---|---|
| all, 1% | 80.7 / 88.2 | 100 / 100 | 100 / 100 | yes |
| all, 3% | 33.0 / 36.0 | 99.2 / 99.5 | 99.7 / 100 | yes |
| all, 5% | 12.7 / 3.7 | 93.5 / 96.2 | 96.7 / 100 | yes |
| all, 10% | 1.0 / 0.0 | 40.7 / 36.0 | 61.2 / 99.7 | yes |
| all, 5 burnt | 0 / 0 | 0 / 0 | 89.7 / 98.5 | yes |
| all, 8 burnt | 0 / 0 | 0 / 0 | 34.7 / 63.0 | yes |
| all, one foreign | 33.0 / 39.0 [67.0 / 61.0 wrong] | 33.0 / 39.0 [67.0 / 61.0 wrong] | 100 / 100 | yes |
| only t, 1% | 57.2 / 45.7 | 99.5 / 99.2 | 99.5 / 99.2 | yes |
| only t, 3% | 16.7 / 6.2 | 87.7 / 79.0 | 87.7 / 79.0 | yes |
| only t, 5% | 3.2 / 0.7 | 62.0 / 50.7 | 62.0 / 50.7 | yes |
| only t, one foreign | 0 / 0 [100 / 100 wrong] | 0 / 0 [100 / 100 wrong] | 0 / 0 | yes |

All 66 values and all 8 bracketed values match. Caption: "30-word cards (k = 4), 400 trials per cell" matches the file headers (24 + 2 + 4; 400 trials per row).

### Figure 2 (`figures/rates.tex`) against `grid-main-k4.final`

| Series | rates.tex | Source rows | Match |
|---|---|---|---|
| 2-of-3 checksum only (L12) | 80.7, 33.0, 12.7, 1.0 | L5–8 col 1 | yes |
| 2-of-3 card parity (L13) | 100, 99.2, 93.5, 40.7 | L5–8 col 2 | yes |
| 2-of-3 grid (L14) | 100, 99.7, 96.7, 61.2 | L5–8 col 4 | yes |
| 3-of-5 checksum only (L16) | 88.2, 36.0, 3.7, 0.0 | L22–25 col 1 | yes |
| 3-of-5 card parity (L18) | 100, 99.5, 96.2, 36.0 | L22–25 col 2 | yes |
| 3-of-5 grid (L20) | 100, 100, 100, 99.7 | L22–25 col 4 | yes |

All 24 plotted points match. The comment at `rates.tex` L1 names `refs/experiments/grid-main-k4.txt`, which on disk is the header-only empty run; the data are in `grid-main-k4.final`.

### Table 3 (L448–463)

| Cell | Paper | Source | Match |
|---|---|---|---|
| k = 4, 3% | 87.7 / 79.0 | `grid-main-k4.final` L10, L27 | yes |
| k = 4, 5% | 62.0 / 50.7 | `grid-main-k4.final` L11, L28 | yes |
| k = 6, 3% | 95.6 / 95.0 | `grid-minimal-k6.txt` L6, L13 | yes |
| k = 6, 5% | 83.6 / 78.0 | `grid-minimal-k6.txt` L7, L14 | yes |
| k = 8, 3% | 99.0 / 99.6 | `grid-minimal-k8.txt` L6, L13 | yes |
| k = 8, 5% | 95.6 / 91.6 | `grid-minimal-k8.txt` L7, L14 | yes |
| card lengths 30 / 32 / 34 words | 26 + 4, 26 + 6, 26 + 8 | file headers "24 seed + 2 digest + k parity" | yes |
| trials 400 / 300 / 300 | | file headers | yes |
| "No trial returned a wrong secret" | | wrong = 0.0 in all four columns of the word-error rows | yes |

### Table 4 (L472–497)

| Scheme, cards | Paper (1% / 3% / 5% / garbage / foreign / burnt) | Source | Match |
|---|---|---|---|
| 3-of-6, 3 | 99.2 / 82.4 / 50.8 / 0 / refused / 0 | `scenario-3of6.txt` L4–9 | yes |
| 3-of-6, 4 | 100 / 98.4 / 94.0 / 100 / 100 / 76.8 | L10–15 | yes |
| 3-of-6, 6 | 100 / 100 / 100 / 100 / 100 / 100 | L16–21 | yes |
| 3-of-5, 3 | 99.6 / 83.2 / 54.8 / 0 / refused / 0 | `scenario-3of5.txt` L4–9 | yes |
| 3-of-5, 4 | 100 / 98.8 / 89.6 / 99.6 / 100 / 72.0 | L10–15 | yes |
| 3-of-5, 5 | 100 / 100 / 100 / 100 / 100 / 98.0 | L16–21 | yes |
| 4-of-9, 4 | 98.4 / 73.6 / 40.0 / 0 / refused / 0 | `scenario-4of9.txt` L4–9 | yes |
| 4-of-9, 5 | 100 / 99.2 / 87.6 / 96.8 / 100 / 62.8 | L10–15 | yes |

All 48 cells match ("grid + digest" column). 250 trials and k = 4 match the file headers. The "garbage" and "burnt" cells printed as "0" and the "foreign" cells printed as "refused" are the same outcome in the data (0.0 correct / 0.0 wrong, i.e. every trial refused); the table uses two labels for it.

Text in Section 6: L503 "98% at a 3% word error rate" (98.4, yes); L504 six cards insensitive to every fault (all 100, yes); L509 "83%" (83.2, yes); L509 "nothing if one card is lost or burnt" (garbage 0, burnt 0; note the burnt scenario burns five words on *every* card, not one); L510 "98.8%" (yes). Card arithmetic: 3-of-6 with two cards each (2 below threshold, 4 = t + 1); 4-of-9 as 4 + 2 + 3×1 = 9, executor + two heirs = 4, + third heir = 5, heirs alone 3 (all correct).

### Arithmetic and derived values

| Text claim | Check | Match |
|---|---|---|
| L304–305: 264 − 11h; 12-word segment leaves 132 bits, 124 after the 8-bit checksum | 24 × 11 = 264; 264 − 132 = 132; 132 − 8 = 124 | yes |
| L232–236: ⌊((k+1)(m−t+1) − 1)/2⌋ = 2 (2-of-3, two cards), 4 (all three), 7 (3-of-5, all five), k = 4 | 5·1 = 5 → 2; 5·2 = 10 → 4; 5·3 = 15 → 7 | yes |
| L266, L536: wrong candidate passes with probability 2^(−11d), d = 2 → 2^(−22) | 11 × 2 = 22 | yes |
| L272–273: 24 + 2 + k = 30 words for k = 4; Table 3: 32, 34 | | yes |
| L55: BIP39 checksum 4 bits for 12 words, 8 for 24 | 132 − 128, 264 − 256 | yes |
| L42: 2048 = 2^11; L126: group order 2047 | `Parity39/GF.lean` L17; unit test `single-phrase.txt` L2 | yes |
| L73, L314: "900-line" / "about 900 lines of Lean 4" | `wc -l Parity39/*.lean` = 867 (759 non-blank); 875 with the 8-line `Parity39.lean` root. `Main.lean` (CLI, 200), `Tests.lean` (214), `GridTests.lean` (192) excluded | yes ("about") |
| L314: toolchain 4.36.0; L572 | `lean-toolchain`: `leanprover/lean4:v4.36.0` | yes |
| L315–316: no dependencies beyond the Lean core library | `lake-manifest.json`: `"packages": []` | yes |
| L586: random seed 39 | `GridTests.lean` L178, `Tests.lean` L207 | yes |
| L576–584: commands | first line of each experiment file | yes (file uses single quotes around `only t cards,`) |
| L587–589: subcommands encode, check, repair, split, combine | `Main.lean` L8–12 | yes |

### Algorithm descriptions against the Lean source

| Paper | Source | Match | Notes |
|---|---|---|---|
| L124–127: field built with x^11 + x^2 + 1, α = class of x | `GF.lean` L14 (0x805), L20 | yes | |
| L129–135: n = N + k ≤ 2047, syndromes at α^0…α^(k−1) | `RS.lean` L28–29, L51 | yes | |
| L146–149: systematic encoding by erasing the parity positions | `RS.lean` L97–98 | yes | |
| L151–154: Sugiyama, position search, Forney; accept only if syndromes vanish and 2e + s ≤ k | `RS.lean` L60–93 | yes | |
| L163: as written, up to ⌊k/2⌋ substitutions | `Repair.lean` L114–115 with `RS.lean` L77 | yes | |
| L164–166: swap any two positions; at most ⌊(k−2)/2⌋ further substitutions | `Repair.lean` L59–66, L114 (`(k - 2) / 2`) | yes | |
| L167–170: dropped / extra words, d ≤ 3 | `Repair.lean` L68–93, `maxEdits := 3` L105 | yes | |
| L172–176: cost = edits + substitutions; all candidates of minimum cost; BIP39 checksum filter applied before the minimum | `Repair.lean` L130, L133–142 | yes | |
| L188: n ≤ 31 | `Grid.lean` L83 | yes | |
| L190–196: t − 1 random rows with own parity; card i = polynomial in x_i, x_i = bit pattern of i | `Grid.lean` L75, L84–88; `GridTests.lean` L94–97 | yes | |
| L244–248: header h_i = i + 32t at position W; parity computed over data and header; decoder subtracts h_i times a fixed vector | `Grid.lean` L41, L49–59, L89, L179 | yes | |
| L250–253: illegible number → header is one more erasure; else try each of the 31 numbers | `Grid.lean` L159–174 | yes | |
| L263–264: digest = SHA-256("bip39-parity/digest" ‖ seed words as two bytes each) | `Grid.lean` L62–65 | yes | domain string and big-endian two-byte encoding match |
| L263: "the first d 11-bit groups" of that hash | `Grid.lean` L66 | **NO** | see Mismatches |
| L265–268: accept only if digest matches; on failure try each t-subset | `Grid.lean` L336–348 | yes | subsets are of confirmed cards |
| L279–281: rows; confirmed vs unconfirmed evidence | `Grid.lean` L158–193 | yes | unconfirmed evidence also requires the card to have exactly W words (L185), which L550 states |
| L282–286: column rule (most-agreeing polynomial of degree < t; confirmed cards alone when ≥ t; exactly t taken as given; otherwise ≥ t + 1 agreeing and no tie) | `Grid.lean` L118–140, L239–242 | yes | |
| L287–288: iterate | `Grid.lean` L231–263 | yes | |
| L289–291: rescue when confirmed cards are one short of t | `Grid.lean` L272–299 | yes, simplified | code additionally requires k ≥ 3, at most 14 open columns, at least 3 guessed positions, and agreement with another *unconfirmed* card |
| L292–294: check: interpolate, "verify its syndromes" and digest, fall back to t-subsets, else refuse | `Grid.lean` L329–350 | partly | the code does more than verify: it runs the full row decoder on the interpolated secret row, filling columns that never settled from the secret's own parity (L329–336) |
| L330–332: checksum only = card counts only if exactly valid as written; first t interpolated | `GridTests.lean` L65–81 | yes | |
| L333–334: card parity = each card repaired alone; first t repaired cards interpolated | `GridTests.lean` L84–86 | yes | |
| L335–336: grid = full decoder with digest | `GridTests.lean` L136 (column 4) | yes | |
| L324–328: word error, burn, foreign, garbage definitions | `GridTests.lean` L109–124 | yes | |
| L213 (Prop. 1a), L68, L203–204: "every card satisfies (1)" / "each card is a valid parity phrase" | `Grid.lean` L86–89 | **only with the header** | A printed card has `h_i` × offset added to its parity words, so its W printed words satisfy the syndromes only when the unprinted header symbol is appended. Eq. (3) at L194 also omits the header term. Section 4.2 explains the header afterwards, but Prop. 1(a) as stated is not true of the W printed words. Non-critical note. |

## Figure source-of-truth check (step 7)

No `\includegraphics`; both figures are TikZ sources `\input` directly
(`figures/grid.tex`, `figures/rates.tex`). `figures/src/` is empty. Nothing to
compare for staleness. `figures/grid.tex` content (header 0 on hidden rows,
`i + 32t` on cards, t = 2, n = 3) matches the text and `Grid.lean`.

## Summary

- Values checked: 54 (Table 1) + 74 (Table 2) + 24 (Figure 2) + 12 (Table 3) + 48 (Table 4), all matching, plus the text and arithmetic items above.
- Numerical mismatches: 1 (L348, 15% vs 15.5%).
- Description-vs-implementation mismatches: 1 (L263, digest word extraction).
- Unverifiable numbers: 1 (L179, 97.6%).
- Non-critical numerical notes: 4 (Fig. 2 caption wording; duplicate measurements of one condition; confidence statement scope; Prop. 1(a) and the header).
