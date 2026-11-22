# Comments — parity39.1

Line numbers refer to `parity39.1/main.tex`. Items within a severity group are in priority order. `R<n>` labels match the ranked list in `verdict.md`.

## Blocker

None.

## Major

**R1. §4.1 Prop. 1(a), Fig. 1 caption, §1 — printed cards are not valid parity phrases (L67-69, L203-207, L213, L242-248).**
"(a) Every card y_i satisfies (1)" is true of y_i as defined by Eq. (3). §4.2 then redefines the card: the printed parity words are y_i's parity plus h_i times a fixed vector (`Grid.applyHeader`, called from `Grid.deal`). Since h_i = i + 32t is never zero, no printed card satisfies Eq. (1) at length W; what satisfies it is the W+1-symbol word (printed words, h_i). The introduction ("Each card is a valid parity phrase"), the Fig. 1 caption ("Each printed card (a row) is a valid parity phrase") and the abstract ("every card repairs itself") all describe the header-less object. Consequences the paper should state: a card checked as a plain N+k phrase fails; with the number known the row code keeps distance k+1; with the number unknown it is punctured to distance k. Fix: define the card once, with the header, before the proposition; state (a) for the extended word; add the two distance statements; say that Prop. 1(d) holds for the header-stripped array and therefore assumes card numbers are known.

**R2. §5.3 "Wrong cards", Table 2 rows "one card is foreign", §9 — the comparison confounds the digest with joint decoding (L392-395, L419, L425, L597-599).**
Both baselines are run without the digest (`detectOnly`, `rowsOnly` in `GridTests.lean`), and only the "Grid" column gets it. The stored logs contain the ablation the paper omits: joint decoding without the digest returns a wrong secret in 100% of exactly-t foreign-card trials and recovers 0% in the 2-of-3 all-cards case (`grid-main-k4.final`, column "grid"). The foreign-card result is therefore a property of the digest plus subset search, which could be added to either baseline, not of grid decoding. The sentence "with a spare card the decoder survived burns and foreign cards that defeat per-card checks" attributes it to the wrong mechanism. Fix: report the "grid" (no digest) column, add a "card parity + digest" baseline, and reword §5.3 and §9.

**R3. §2 "Shared mnemonics", §1 L56-58 — SLIP39 is under-described in a way that favours the paper (L96-98).** `related-work`
SLIP39 shares carry a random identifier common to one share set, and the scheme shares a digest of the secret alongside it so that a reconstruction from inconsistent shares is rejected. codex32 shares likewise carry an identifier. These are the deployed answers to the foreign-card case, so "Checksum only ... models per-share detection" returning a wrong secret in 61-67% (100% with t cards) does not model a deployed format. Fix: describe both mechanisms in §2, say that the paper's digest follows SLIP39's in purpose, and present the foreign-card rows as "linear checks alone" rather than as existing practice. (Reviewer recall, not checked online this pass: verify against the SLIP-0039 and BIP-93 texts.)

**R4. §5.3 L397-398, abstract L31-32, §9 L599 — "never returned a wrong secret" needs a bound and a scope.**
Zero events in 28,000 trials gives a 95% upper bound of about 1.1e-4 on the pooled rate and 0.75% for any single 400-trial cell; the design target implied by §4.3 is 2^-22. The pool is also dominated by benign conditions (independent uniform substitutions). State the bound, state that it is for the tested fault mix, and break the 28,000 down: it equals 28 x 400 + 16 x 300 + 48 x 250 only when the six row types not printed in Table 2 are counted. The logs also show a non-zero wrong rate for a component the paper calls safe: "all cards, numbers illegible, 3%" in 3-of-5 has card parity at 99.7 / 0.2 wrong, i.e. a card "confirmed" by the row stage was wrong once in 400.

**R5. §4.3 L262-264 — the digest as specified is not the digest as implemented.**
Text: "the first d 11-bit groups of SHA-256(...)". Code (`Grid.digestWords`): word i is the low 11 bits of the i-th big-endian 16-bit group, `((h[2i] << 8) | h[2i+1]) & 0x7ff`. For d = 2 these differ in both words. The byte order of "seed words as two bytes each" is also unstated (big-endian in the code). Fix the text or the code, and add one test vector.

**R6. §3.2 L178-181 — "97.6% of trials during development" has no supporting artifact.**
No log, trial count or command exists in `refs/experiments/` and the repository contains no harness switch that disables the swap restriction. The number is plausible (325 swaps each with roughly a 1.3% chance of landing within one substitution of a codeword gives about 98%), but as written it is an unreproducible quantitative claim. Either add the ablation run to the harness and the logs, replace the number with that estimate labelled as an estimate, or delete it.

**R7. §5.1-5.3 — grids are never tested with the fault the introduction leads with.**
The cited study's recoverable failures are one wrong word or one wrong word plus a flipped pair (L52-54). The grid scenarios inject substitutions, burns, one dropped word and whole-card replacement; no scenario swaps words within a card. Single-phrase swap repair needs k >= 3 to be unambiguous without the BIP39 checksum (87.0% / 84.5% unique at 24+2), and cards cannot use that checksum because share words are not a mnemonic. Add a swap scenario to `gridtests`, or state that swap repair on cards is untested.

**R8. §5.3, Table 2 — rows that were run are not reported, including the only test of the header.**
`grid-main-k4.final` has "numbers illegible, 3%" (98.0 for 2-of-3, 100 for 3-of-5), "dropped words, 3%" (94.7 / 98.2) and "one is garbage, 1%" (99.2 / 100). The unprinted header is listed as a contribution and §4.2 makes behavioural claims about it with no reported measurement. Add the three rows.

**R9. §8 L571-574 — no way to obtain the source.**
"the accompanying source tree" has no URL, commit hash or archive identifier, and `refs/experiments/` is a path the reader cannot follow. The hash stored beside the logs (`README.txt`) identifies a tree without `Parity39/Grid.lean` or `GridTests.lean`, which are uncommitted at review time. Cite a public URL and the exact commit that produced the logs.

**R10. §1 L50-54 — the motivating study measures recall from memory, not transcription.**
Ambati et al. had participants memorise a 12-word mnemonic and authenticate from memory after 3 or 7 days (60% and 51% success; the paper's 40% and 49% are correct complements). "could not reproduce an assigned 12-word BIP39 phrase" sits in a paragraph about copying onto paper and reading back, and never says "from memory". The 14 of 41 are, in the source, attempts recoverable within a fixed search budget, not a classification of all 41 failures. Reword to say what was measured and that it is evidence about the shape of human word errors, not about transcription rates.

**R11. Abstract L32-34 — the one quantitative comparison is the best cell.**
99.7 vs 36 is 3-of-5, all five cards, 10% word errors. The same row for 2-of-3 is 61.2 vs 40.7, and with exactly t cards the grid decoder equals per-card repair at every error rate. The body says this plainly (§5.4, Fig. 2 caption); the abstract should carry one clause of it, and should say that 10% is an assumed rate.

**R12. §4.3 L265-268, §7 L535-536 — false-accept probability.**
2^-11d is the chance for one candidate. The fallback tries every t-subset of confirmed cards (`combineRows`), so the bound is C(m,t) x 2^-22: 126 subsets for 4 of 9, about 3e-5. Step 5 also runs error correction on the interpolated secret row (`RS.decode p.k row0`), not only a syndrome check as L292 says, which is a further miscorrection path guarded only by the digest. State the union bound and describe step 5 as implemented. For the altering holder, say that 2^-22 is per attempt and that a wrong reconstruction of a wallet seed is detected downstream.

**R13. §3.1-§4 notation (L129, L163-170, L188-190, L221, L303) — symbols change meaning.** (reader-flow, confirmed)
n: phrase length, then number of cards. N: mnemonic length, then mnemonic plus digest (26). d: dropped-word count, digest-word count, row index in the proof. h: header, then words held. Use W for phrase length from §3 on, keep N for the mnemonic length (W = N + d + k), index rows by j.

**R14. Define-before-use, body (reader-flow, confirmed; these set the dim 7 cap).**
- L140-141 "within reach": give the explicit condition.
- L190 "seed": for this audience "seed" is the 512-bit PBKDF2 output; say "mnemonic words" or define "seed words".
- L216-217 "dealing": define after Eq. (3).
- L234 "30-word cards": defined only at L272-273.
- L238 "bursts": the defined term is "burn" (L326).
- L245 "h_i = i + 32t" and L188 "n <= 31": say the card number takes the low 5 bits.
- L347-351: unfiltered-run numbers with no table; Table 1 has no "ambiguous" outcome although cells of 1 and 30 are almost entirely ambiguous.
- L485-494: "0" next to "refused" in Table 4.

**R15. Fig. 1 (`figures/grid.tex`) — overprinting in the compiled PDF (page 4).**
The vertical column arrow at x = 2.1 and the filled "each column: Shamir" label sit on top of "share words" in all three cards; the labels "k parity words" (x = 5.5) and "header" (x = 7.7) touch. Move the column annotation to the left margin or below the grid and shorten or stagger the two top labels.

**R16. Related work gaps.** `related-work`
(a) Robust secret sharing (error-correcting reconstruction of Shamir shares, from Rabin and Ben-Or onward) is the academic name for what §4.4 does and is not cited. (b) "Spreading one long codeword among parties without fresh randomness" is information dispersal (Rabin 1989); a ramp scheme uses partial randomness, so §4.5's shortcut is the zero-randomness end of the ramp family and should be described that way. (c) SSKR (Blockchain Commons) is a deployed word-based Shamir format with a per-share checksum. (d) L102-103 "dictionary words, which resist transcription slips better than character strings" needs a source or should be dropped. (e) L116-117: Patterson et al. 1988 defines RAID levels 1-5; cite a RAID-6 source, and note that it is the syndromes S_0 and S_1 that correspond to P and Q, not the two systematic parity words. Recommend a `paper-litsearch` run for (a)-(c).

## Minor

- **§4.1 L232-238.** "it handles bursts far beyond it" compares an error bound (half the distance) with erasures, for which the guarantee is the distance minus one (9 erasures for 2-of-3 with three cards, k = 4). Compare like with like and move the sentence after the decoder is described.
- **§4.5 L297-307, §2 L111-112.** "unsafe" is not what the arithmetic shows for 24 words: a 12-word segment leaves 124 bits. The defect is the absence of a threshold, and the 12-word mnemonic case (two 6-word halves leave about 62 bits each) is the one that is unsafe. Say so.
- **§5.1 L338-339.** The half-width is given for 400 trials only. It is about 6.9 points at 200 (Table 1), 6.2 at 250 (Table 4) and 5.7 at 300 (Table 3).
- **§5.4 L444 vs §6 L509.** The same configuration (3-of-5, three cards, 3%) is 79% in one section and 83% in the other, from separate runs, with no bridge. Also 50.7 vs 54.8 and 98.5 vs 98.0.
- **§5.2 L348.** "13--15%" should be 13-16%: the log values are 13.0 and 15.5. The harness truncates percentages (`pct` uses integer division), so 99.75 prints as 99.7; say "truncated" or round.
- **§5.2 L349-350.** "a single wrong candidate": the harness counts any trial where the right phrase is not among the candidates, single or not.
- **§5.2, Table 1.** Show the parity-only columns. "Two parity words repair a swap" (L345-346, L596) holds only with the BIP39 checksum as a filter: without it 24+2 is 87.0% / 84.5% unique, 24+3 is 82% (two dropped) and 76% (wrong plus dropped).
- **§4.4 L289-291.** The rescue step as implemented requires at least three guessed positions, k >= 3, at most 14 open columns, and agreement with another unconfirmed card. State these conditions.
- **§4.2 L254.** "a card with the wrong number attached fails its own check": in the code a wrong label is corrected as one symbol error and reported, at the cost of two parity words. Describe that.
- **§5.1 L324-325.** The substitution is not exactly uniform over wrong words: a collision is mapped to the word index with its low bit flipped.
- **Fig. 2 placement.** Discussed on page 6, printed on page 8 inside §6 together with Table 4, splitting a custody paragraph (float-proximity pre-flight, confirmed in the PDF).
- **Fig. 2 caption L434-436.** "gains little" for 2-of-3: up to 3 points through 5%, 20 points at 10%. Quantify.
- **Fig. 2, Tables 2-4.** No uncertainty shown; add intervals or a caption note.
- **§7 L549-553.** "Proposition 1(d) says a better decoder exists for some patterns": give one pattern the decoder misses, or a measured gap to the bound.
- **`refs.bib`.** `blakley2007security` is CRYPTO '84 (published 1985); `krawczyk2007secret` is CRYPTO '93 (1994) and is not cited; `patterson1988case`, `franklin1992communication`, `moura2021lean`, and the two LNCS entries are proceedings typed as `@article`; "goppa" needs braces for capitalisation.
- **§1 L70-72.** The header-and-digest contribution is the only one with no section pointer.
- **Repetition.** No-wrong-secret is stated in the abstract, §5.3, the captions of Tables 3 and 4, and §9; the spare-card rule in §5.4, §6, §7 and §9.
- **Naming.** Three methods under about a dozen labels (checksum only / per-card checksums / per-share detection; card parity / per-card repair; grid / combined / full / joint). "Checksum only" also collides with the BIP39 checksum. The reader-flow lint adds per-share / per share, per-word / per word, per-card / per card.

## Nit

- `figures/rates.tex` L1: the comment names `grid-main-k4.txt`, which is the empty run; the data are in `grid-main-k4.final`.
- §3.1 L136: S_1 weights each word by alpha to the power of its position, not by its position.
- §5.1 L314 "about 900 lines": `Parity39/*.lean` is 867 lines; `Main.lean` and the two harnesses add 606.
- hyperref warns about math in PDF bookmark strings (four occurrences in `main.log`).

## Procedural notes

- render-gate (step 4b): skipped — `parity39.1.audit/compile-log.txt` not present (audit has not completed); `main.log` was read by hand instead: no overfull boxes, no undefined references or citations.
- numeric-consistency (step 4c): ran; 8 advisory hits, all false positives (the detector read row labels such as "1\% of words wrong" against "100 / 100" table cells). Manual claim-vs-table cross-check done; real findings are R4, the 13-15% item and the 79/83 item above.
- pending-marker (step 4g): ran; no markers.
- evidence-drift (step 4h): ran; `EVIDENCE-DRIFT` on `refs/**` (see `verdict.md`).
- audience-fit (step 4i): ran; no hits. The scan reported no declared audience because the BRIEF states it in body prose, not frontmatter; the audience line in the BRIEF body was used for this review. One manual hit folded into R9 (repo-relative path with no public link).
- reader-flow lens (step 4j): ran with a fresh-context subagent; sidecar at `parity39.1.readerflow/` (18 major, 24 minor, 2 nit). Confirmed items are R13, R14 and the naming, repetition and number-variant entries above. Not confirmed as class 1: the swap "so" item (an argument gap, not an undefined term) and the half-width item (kept as a minor evidence comment). No prior readerflow sidecar, so no recurrence measure.
- reader-flow lint (step 4k): ran; 3 variant-pair hits, folded into Naming.
- float-proximity (step 4l): ran; 1 hit (Figure 2), confirmed.
- artifact verification (step 4f): no `artifact_verify` declaration; `lake` was not run. Code was checked by reading.
- venue overlay: `parity39/.anvil.json` absent, so none resolved (the BRIEF frontmatter names arXiv; the overlay reads `.anvil.json` only).
- No network requests were made; statements about SLIP39, codex32, SSKR and publication years are from reviewer knowledge and are marked as leads for `paper-litsearch` / `paper-audit`.
