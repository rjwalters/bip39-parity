# Audit flags for parity39.1

Build: OK (3 `pdflatex` passes + `bibtex`, converged, 11 pages, no `??`, no undefined
references or citations, no overfull boxes). Compiled in a scratch copy, not in
`parity39.1/`, at the requester's instruction; `main.tex` byte-identical to the audited one.

## Critical flags (block advancement to AUDITED)

- **Numerical inconsistency** (Sec. 5.2, main.tex:L348 vs `refs/experiments/single-phrase.txt` L56–57): text says "24+2 leaves 13--15\% of swaps ambiguous". The harness output for 24+2 without the checksum filter gives 13.0% ambiguous for an adjacent swap (L56) and **15.5%** ambiguous for a swap of any two words (L57: 84.5% unique, 15.5% ambiguous). The upper end of the range is 15.5, not 15. `README.md` L55–56 agrees with the harness (87 and 84.5 unique). Fix: "13--16\%" or "13.0--15.5\%".

- **Description does not match the implementation** (Sec. 4.3, main.tex:L263–264 vs `Parity39/Grid.lean` L62–66): the paper defines the digest words as "the first $d$ 11-bit groups of SHA-256(...)". The code takes, for word i, `((h[2*i] << 8) ||| h[2*i+1]) &&& 0x7ff`, i.e. the low 11 bits of the i-th 16-bit big-endian group of the hash. For d = 2 the paper's rule reads hash bits 0–21; the code reads bits 5–15 and 21–31. A reader who implements the paper's sentence produces cards that the reference tool rejects, and every grid number in the paper was produced by the code's rule. The domain string `"bip39-parity/digest"` and the two-bytes-per-seed-word input do match. Fix: reword L263–264 to say what the code does (or change the code and re-run every grid experiment). Not one of the procedure's named flag categories; raised as critical because the requester asked for algorithm descriptions to be checked against the source and this one is a specification error.

## Non-critical notes

- **Unsupported number** (main.tex:L178–181): "a 24+2 phrase with two wrong words was 'repaired' to a different valid phrase in 97.6\% of trials during development". No record of this run exists on disk: not in `refs/experiments/`, `README.md`, `docs/`, or the test harnesses. It is the only quantitative claim in the paper with no evidence file. Either store the output of a run with the restriction disabled, or state it without a figure.

- **Caption contradicts its right-most data point** (Fig. 2 caption, main.tex:L434–436): "Joint decoding gains little over per-card repair with one spare card (2-of-3)". At 1%, 3% and 5% the gain is 0, 0.5 and 3.2 points; at 10% it is 40.7 → 61.2, a gain of 20.5 points (`grid-main-k4.final` L8; `figures/rates.tex` L13–14), four times the 5-point resolution set at L338–339. Qualify the sentence ("up to 5% wrong words").

- **One condition, two reported values** (main.tex:L423 and L444–445 vs L489 and L509): 3-of-5, k = 4, exactly three cards, 3% wrong words is 79.0% in Table 2 (`grid-main-k4.final` L27, 400 trials) and 83.2% in Table 4 (`scenario-3of5.txt` L5, 250 trials); the text quotes "79%" in Sec. 5.4 and "83%" in Sec. 6. Both are transcribed correctly from independent samples and differ by less than the sampling error, but the paper does not say they are the same condition measured twice. Same at 5% (50.7 vs 54.8) and for five burnt words with all five cards (98.5 vs 98.0).

- **Confidence statement covers one table only** (main.tex:L338–339): "With 400 trials ... at most 5 points" is correct (4.9) for Table 2 and Fig. 2. Worst-case half-widths for the other tables are 6.9 points (Table 1, 200 trials), 5.7 (Table 3, k = 6 and 8, 300 trials) and 6.2 (Table 4, 250 trials).

- **Proposition 1(a) and the header** (main.tex:L213, also L68, L194, L203–204): "Every card $y_i$ satisfies (1)" and "each card is a valid parity phrase" hold for the card with its unprinted header symbol appended, not for the W printed words. `Grid.lean` L86–89 adds `header(i, t)` × offset to each card's parity words, and Eq. (3) omits that term. Section 4.2 introduces the header after the proposition. State the proposition for the extended codeword, or for header-removed cards.

- **Decoder step 5 understated** (main.tex:L292–294 vs `Grid.lean` L329–340): the paper says the secret row is interpolated and its syndromes verified. The code runs the full row decoder on the interpolated row and fills columns that never settled from the secret row's own parity.

- **Rescue step simplified** (main.tex:L289–291 vs `Grid.lean` L272–299): the code also requires k ≥ 3, at most 14 unsettled columns, at least 3 guessed positions, and that each guessed position agree with another *unconfirmed* card. Consistent with the paper's one-line description; listed so the reviser knows the description is partial.

- **Evidence file naming** (`figures/rates.tex` L1; main.tex:L572–578): the comment in `rates.tex` and the reproducibility section point to the stored output of `lake exe gridtests 400`. On disk `refs/experiments/grid-main-k4.txt` is a header-only empty run; the data are in `grid-main-k4.final`. Replace the `.txt` with the complete output before release.

- **Evidence files changed during the audit**: `single-phrase.txt` was incomplete at the first read (cut off inside the 24+2 block) and complete at the second; `grid-main-k4.final` gained its 28th row (3-of-5, numbers illegible) between reads. All checks use the complete files. The 28,000-trial total depends on that 28th row (27,600 without it). `README.md` "Measured behaviour" (L51–61) was used as a cross-check for Table 1 and agrees with the complete file in every cell.

- **RAID citation** (main.tex:L115–117, `\citep{patterson1988case}`; source not on disk): "the first two parity words are the P and Q blocks of a RAID-6 stripe". Two problems, from the auditor's knowledge of the cited paper and from the source tree. Patterson, Gibson and Katz (1988) define RAID levels 1–5; RAID-6 and P+Q are later. And the correspondence in the code is between the syndromes S0, S1 and P, Q (`Parity39/RS.lean` L11–12), not between the two parity words and the P and Q blocks.

- **Tompa–Woll wording** (main.tex:L108–109; source not on disk): "added a check to the secret" is loose. Their remedy restricts the secret to a sparse set of legal values in a larger field so that a forged reconstruction is detected with high probability.

- **SOUPS study context** (main.tex:L51–54): the numbers are right (see citation-audit.md). The study measures recall of a memorised phrase, not transcription of a written one, and the sentence does not say so. "Two words out of order" is the paper's reading of the study's "1 flipped order". The 14 are the failures recoverable inside the study's search budget (10 with one wrong word, 4 with one wrong word and one flipped order); the study does not describe the other 27.

- **Uncited claims** (main.tex:L102–103, L543): "dictionary words, which resist transcription slips better than character strings" and "There are no published per-word error rates for handwritten word lists" have no citation and no support on disk.

- **Unverified citations** (16): claim-support could not be verified because the sources are not in `parity39/refs/`: `bip39`, `reed1960polynomial`, `shamir1979how`, `moura2021lean`, `polyseed`, `slip39`, `bip93`, `mceliece1981sharing`, `tompa1989how`, `blakley2007security`, `franklin1992communication`, `elias1954error`, `schmidt2009collaborative`, `patterson1988case`, `sugiyama1975method`, `forney1965decoding`. The characterisations of SLIP39, codex32/BIP-93, Polyseed and McEliece–Sarwate agree with the auditor's knowledge of those documents; the author should still verify off-disk.

- **Bibliography metadata**: `blakley2007security` carries year 2007 (Springer online date) for a CRYPTO '84 paper; `krawczyk2007secret` is never cited and has the same kind of year error (CRYPTO '93); several proceedings papers are typed `@article` with the proceedings title as journal.

- **Table 4 labels** (main.tex:L485–493): "0" (garbage, burnt) and "refused" (foreign) denote the same outcome in the data, 0.0% correct and 0.0% wrong.

- **Figures**: no `\includegraphics` and no `figures/src/` scripts; both figures are TikZ `\input` files. No staleness check applies.

- **Tooling**: `anvil.lib.sidecar` (stage / copy / commit), `anvil.lib.pending_marker --write-review` (pass, no markers; rewrote `parity39.1.pending/_review.json`) and `anvil.lib.audience_check` (pass, 0 hits, no `public_repo_url` declared or derived) were run. Corpus tier inactive (`resolve_corpus_dirs` returns no dirs), so no `.corpus-audit/` sibling. `lake` was not run; no network requests; nothing committed.

## Audience-fit notes (non-critical — step 6c, issue #1322)

- None. `audience_check` reported 0 governance-vocabulary, 0 private-locator and 0 unlinked-artifact-path hits. No public repository URL is declared; `refs/experiments/` (main.tex:L573) is named as a folder with the paper sources, which a reader of the PDF alone cannot follow. Declare `public_repo_url` and link it, or mark it "not published", if the paper is released without its source tree.
