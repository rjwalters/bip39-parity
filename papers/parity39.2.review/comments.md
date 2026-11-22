# Comments — parity39.2

Line numbers refer to `parity39.2/main.tex`. Items within a severity group are in priority order. `S<n>` labels match the ranked list in `verdict.md`; `R<n>` labels are the round-one items from `parity39.1.review/`.

## Blocker

None.

## Major

**S1. §5.3 "Wrong cards are caught by the digest, not by joint decoding" (L514-521), §5.1 method list (L381-393), Table 2 — the no-digest ablation is quoted but not shown, and quoted one-sidedly.**
The harness runs five strategies; the paper lists four ("We compare four ways", L381) and Table 2 prints four. §5.3 then reports a fifth: "Joint decoding without the digest does not: in the same runs it refused every 2-of-3 trial with all cards, and with exactly t cards it returned a wrong secret every time." Both statements match `grid-main-k4.txt` (column "grid, no dig.": 0.0 / 0.0 and 0.0 / 100.0). The same column in the same file has 3-of-5 with all five cards at 100.0 / 0.0, and `scenario-3of6.txt` and `scenario-3of5.txt` have six-of-six and five-of-five at 100.0 / 0.0, while every row with exactly one spare card (4 of 3-of-6, 4 of 3-of-5, 5 of 4-of-9) is 0.0 / 0.0. So the data say: with no spare card joint decoding without a digest returns a wrong secret; with one spare it detects the foreign card and refuses; with two or more it out-votes the foreign card and recovers. That is the behaviour Proposition 1(d) predicts (column distance m-t+1), and it is a better result for the paper than the heading claims. As written, the heading overstates in the opposite direction from round one, and the reader has no table in which to check the sentence. Fix: list five methods in §5.1; add a "Grid, no digest" column to Table 2 (or a four-row table of the foreign-card rows for all five strategies); reword the heading and paragraph to the three-case statement above.

**S2. §8 L669-673 — the source is not obtainable (R9, open).**
The paper says so plainly ("The tree is not yet published at a public address"), which is the right disclosure, and the substitute it offers was checked: all 15 SHA-256 values in `refs/experiments/README.txt` match the files in the working tree today. On the merits this is still a gap for the declared audience. (a) The digests pin a tree that no reader can fetch, so they certify nothing to anyone outside. (b) "distributed with the paper sources" is true only if the arXiv submission carries `refs/experiments/` and the Lean tree as ancillary files; the PDF alone leads nowhere. (c) The README records "Base git commit ... plus uncommitted changes", so even the author cannot name a commit that reproduces the logs. (d) A wallet engineer's first question about a backup format is where the reference implementation is. Fix, in order of preference: commit the tree, publish it, and cite URL and commit; or deposit an archive (Zenodo or arXiv ancillary files containing the Lean sources, `data/english.txt`, the logs and the README) and cite that. Until one of these is done dim 5 stays at 3.

**S3. §4.3 L303-308 and §7 L633-635 — the false-accept bound (R12, mostly resolved).**
(a) The count is off by one candidate. `combineRows` tests the jointly decoded secret row first and then every t-subset of confirmed cards, so up to C(m,t)+1 candidates meet the digest, not C(m,t). The numeric example changes from 2.4e-6 to 2.6e-6. (b) "at most" holds only if the digest words of a wrong candidate are modelled as uniform and independent of its secret words; say "modelling SHA-256 as a random function". (c) The design figure (about 1e-6) is two orders of magnitude below what the experiments can confirm (1e-4, L533); one sentence should say that the measured bound does not test the design bound. (d) Round one asked that the altering-holder case be stated as 2^-22 per attempt, with a wrong reconstruction of a wallet secret detectable downstream; L633-635 still gives no number.

**S4. §5.2 L405-411, Table 1 caption L416-417, §7 L657, §9 L698 — three statements do not match Table 1.**
(a) "Two parity words repair a swap or a dropped word" (L405, repeated unqualified at L698): without the BIP39 filter the original is the unique repair in 84.5-96.5% of swap trials at k = 2, and the rest are ambiguous. Likewise "three repair two dropped words or a wrong word plus a dropped word": 76-96% without the filter. Both hold at 99.5-100% only with the filter. Cards cannot use the filter (L317-318), so the unqualified form matters. Add "with the BIP39 checksum as a filter; otherwise a minority of repairs are ambiguous". (b) "except beyond the capacity of k = 2: there the procedure refused" (L408-409): the two-wrong-words row is also refused at 12+3 and 24+3, which is beyond the capacity of k = 3. Write "beyond the capacity (2)". (c) Caption: "'Refused' means no candidate was offered in any trial, with or without the filter", but footnote a says a single wrong phrase was offered in 0.5% or 1.5% of unfiltered trials in three of the cells marked refused. Change the caption to "in any trial with the filter; see note a".

**S6. §5 as a whole, §4.2 L285-287 — scope of the evidence.**
The measurements are one fixed seed, 200-400 trials per cell, independent uniform substitutions. That is disclosed in §7 and is acceptable for a whitepaper, but three behaviours the paper states have no trial behind them. (a) "a card with the wrong number attached fails its own check unless k or more of its words also differ" (L285-287) is correct as a statement about the code. The implementation does something more specific: `Repair.repair` treats the supplied header as a symbol that may itself be in error, corrects it at the cost of two parity words, and reports "the card's label does not match its words". Neither the behaviour nor a mislabelled-card scenario is in the paper. (b) No scenario combines a foreign card with illegible numbers, the case in which the row distance is k and the digest is the only defence. (c) No scenario uses structured substitutions (similar words, the error §7 names as the realistic one). Add (a) and (b) to `gridtests`; (c) can stay a stated limit.

**S10. Reader-flow, confirmed class 1 (these set the dim 7 cap).**
- "joint decoding" (abstract L30; body L487, L509, L514, L518): the paper's central term is never defined and never equated with the "Grid" method of L392 or "the decoder of Section 4.4". Define it once in §4.4 and say at L392 that Grid is joint decoding with the digest.
- "the row decoder" (L282): used in §4.2 before the Rows step of §4.4 and never defined as the single-phrase repair of §3. Write "the single-card repair of Section 3".
- "numbers illegible" (Table 2 L468, prose L523): the fault list of §5.1 (L371-380) has no entry for it. Add "an illegible number withholds the card's number from every method".
- Class 5, confirmed: the fifth method (S1) and the subset fallback, which §4.3 L305-308 describes before the decoder exists and §4.4 step 5 points back to "as described above". Move the fallback and its bound into step 5.

Not confirmed as class 1 for this audience: "locator" (L190; standard Reed-Solomon vocabulary, but writing alpha^p is clearer), "capacity" (L404; it cites Eq. 2), "product code" (L47; the next paragraph and Fig. 1 describe it), "24+2" (L191; follows directly from L = N + k, though one defining clause would cost nothing).

## Minor

**S5. §8 L688-689 and §5.3 L531 — the trial total is described wrongly.**
"The trial total counts every row of the five grid files": there are six (`grid-main-k4`, `grid-minimal-k6`, `grid-minimal-k8`, `scenario-3of5`, `scenario-3of6`, `scenario-4of9`), and 31,600 = 34 x 400 + 20 x 300 + 48 x 250 only with all six. "Across all 31,600 grid trials in this paper" also counts 3,600 trials that appear in no table: the 1%, foreign-card and swap rows of the k = 6 and k = 8 files (12 rows x 300). Give the sum explicitly and either report those rows or say "including 3,600 trials at k = 6 and 8 not tabulated".

**S7. §3.2 L188-194 — the swap estimate needs its premises stated (R6, resolved as an estimate).**
The arithmetic is right: C(26,2) = 325, and 325 x 26/2047 = 4.1. The sentence carrying it is not: "A swap leaves S_0 unchanged, so for k = 2 a swapped phrase with wrong words decodes ... whenever S_1/S_0 happens to be the locator of one of the L positions". What is meant is: the phrase as read has two wrong words, so S_0 is non-zero; each hypothesised swap leaves S_0 as it is and changes S_1; a single substitution then explains the result when S_1/S_0 = alpha^p for some p < L; treating S_1/S_0 as uniform over the 2047 non-zero elements gives L/2047 per swap. Say that, and call it an estimate. It can be cross-checked against the paper's own data: with no swap hypothesis the same chance, 26/2047 = 1.3%, is what Table 1's footnote a measures (1.5% wrong phrases at 24+2).

**S8. §2 L97-108 — one prior-work lead.** `related-work`
An existing browser tool (Shamir39, Ian Coleman) splits a BIP39 mnemonic into shares that are themselves written as BIP39 words; from reviewer recall it shares in an 11-bit field and has no error correction or digest. If that is right it is the closest prior use of "one BIP39 word = one field symbol" for sharing, and §1 L42-44 presents that observation without it. Not verified this pass (no network). Recommend a `paper-litsearch` run; if confirmed, one sentence in "Shared mnemonics" suffices, since the paper's claimed increment (parity, header, joint decoding) is unaffected.

- **§4.4 step 4 L329-332.** "agrees with another card": the code requires agreement with another *unconfirmed* card, at the value interpolated through the confirmed cards and the rebuilt one (`Grid.rescue`). The qualifier matters because it is what makes each agreement an 11-bit coincidence.
- **§4.1 Prop. 1 L246-252.** (a) "two different cards with the same number" reads as two cards of one dealing, where numbers are distinct; the statement is about any two codewords with equal headers (cards of different dealings with the same t). (d) holds for cards with known numbers and no missing words; "holders" should be "cards" (a holder may have several, §6).
- **§7 L650-651.** "Proposition 1(d) says a better decoder exists for some patterns": still no example or measured gap (round-one minor, open).
- **§5.1 L372-373.** "a different uniformly random word": the harness maps a collision to the word with its low bit flipped, so the distribution is not exactly uniform over wrong words (round-one minor, open).
- **Tables 2-4.** The harness truncates percentages (`pct` uses integer division): 161/400 prints as 40.2 and 239/400 as 59.7, which sum to 99.9 under a caption that says all other trials were refused. State "truncated to one decimal" or round.
- **Table 3 caption L549.** "No trial returned a wrong secret" is true of the grid decoder shown; Table 2 has a bracketed 0.2 for card parity in the same k = 4, 5% cell. Name the method in the caption.
- **Fig. 1.** The header labels "1+32t" to "3+32t" run through the right edge of their dashed boxes; widen `hdr` by 3 mm.
- **§5.3 L497-498 against Fig. 2 caption L487.** "below 5%" and "up to 5%" leave the 5% point (96.7 against 93.5) unassigned; use "up to and including 5%".
- **Naming.** Three methods under about a dozen labels (joint decoding / Grid / grid decoder / decoded together; per-card repair / card parity / repairing cards separately / one at a time / card by card). "Checksum only" collides with the BIP39 checksum. A dealt set is a set, a dealing, a sharing, a scheme and an arrangement. "burnt" at L607 means a destroyed card, against the defined sense at L374. "wrong card" at L514 against the defined "foreign".
- **Symbols.** L is N + k in §3 and W + 1 in §4 (L210); the data-word count is N, then D. Flag the change in one clause.
- **Repetition.** No-wrong-secret: abstract, L531, captions of Tables 3 and 4, L702. Exactly-t caveat: L33, L77, L539, L621-623, L655, L702. Assumed error rates: L51-53, L84, L641, L663. The conclusion repeats L405-407 nearly verbatim.
- **§3.1 L144-145.** "S_1 weights each word by its position": by alpha to the power of its position (round-one nit, open).
- **§5.3 L533-534.** Cite a source for the rule of three (for example Hanley and Lippman-Hand, 1983).
- **`refs.bib`.** `sugiyama1975method`: brace "Goppa"; `forney1965decoding`: brace "BCH".
- **Length.** 13 pages against the brief's "about 10". Moving §8's command list to an appendix and removing the repeats above recovers most of it.

- **S9, S11, S12** in `verdict.md` collect the table and figure items, the repetition and length items, and the remaining minors of this section.

## Nit

- §4.1 L225: "(so t <= 63)" is vacuous given t <= n <= 31; say "six bits are reserved for t".
- hyperref still warns about math in PDF bookmark strings (four occurrences in `main.log`).
- Lint: "word-level" / "word level" (L107, L105), "per-word" / "per word", "per-card" / "per card".
- §1 L53-57: one sentence carries five numbers and no participant count.

## Status of round-one items

Each was checked against the text, the Lean sources and the logs, not against `changelog.md`.

| Item | Status | Basis |
|---|---|---|
| R1 | Resolved | §4.1 defines the card as a length-(W+1) codeword with header and u; matches `Grid.deal`, `headerOffset`, `applyHeader`, `header`. Prop. 1(a)-(d) re-derived; 2 / 4 / 7 examples correct. Intro and Fig. 1 caption aligned. |
| R2 | Partly | `rowsDigest` exists and is the third printed column (column order verified in `GridTests.lean` and `figures/src/tables.py`); §5.3 credits the digest. The no-digest grid column is still not tabulated and is summarised selectively (S1). |
| R3 | Resolved | §2 L98-108. Content agrees with reviewer knowledge of SLIP-0039, SSKR and BIP-93; not checked online. |
| R4 | Mostly | Rule-of-three and per-cell bounds correct (3/31,600 = 0.95e-4; 3/400 = 0.75%); scope stated; the logged miscorrection is reported. Breakdown still wrong in detail (S5). |
| R5 | Resolved | Text matches `Grid.digestWords`; test vector recomputed with Python `hashlib` and `data/english.txt`: siege, say. The round-one reading (first 11-bit groups) would give main, admit. |
| R6 | Resolved | Number removed; counting argument is arithmetically right, loosely worded (S7). |
| R7 | Resolved | Three swap scenarios in `GridTests.lean`, in the log and in Table 2. |
| R8 | Resolved | Dropped-word, illegible-number and garbage rows in Table 2 with prose. |
| R9 | Open | Disclosed; file digests verified; no URL or commit (S2). |
| R10 | Resolved | L52-57 says recall from memory and "could recover by bounded search". |
| R11 | Resolved | Abstract L29-34. |
| R12 | Mostly | Union bound added (off by one, S3a); step 5 and rescue conditions described; per-attempt statement for an altering holder not added (S3d). |
| R13 | Mostly | n, N, D, g, q, h_i are now single-valued; L is still rebound. |
| R14 | Mostly | All eight round-one terms fixed. Three new or surviving class-1 items (above). |
| R15 | Resolved | Checked in the PDF, page 4; one residual overflow (minor). |
| R16 | Resolved | Rabin, Rabin and Ben-Or, SSKR, Plank cited; unsourced claim removed; P and Q stated as parity checks. |

## Procedural notes

- render-gate (step 4b): skipped — `parity39.2.audit/compile-log.txt` not present (audit has not run on this version); `main.log` in the version directory was read by hand instead: 13 pages, no overfull boxes, one underfull box (badness 1810), no undefined references or citations. No `_gate.json` written.
- numeric-consistency (step 4c): ran; 11 advisory hits, none real. Eight read table row labels ("1\% of words wrong") against neighbouring cells; three `quoted_variant` hits pair different quantities (88 / 85 / 86, 98.8 / 99). A manual claim-versus-table pass was done in addition: every prose percentage was checked against the logs; real findings are S4, S5 and the truncation note.
- pending-marker (step 4g): ran; no markers.
- evidence-drift (step 4h): ran; `CLEAN`.
- audience-fit (step 4i): ran; 0 hits. The scan reported no declared audience because the BRIEF states it in body prose; the BRIEF's audience line was used. Manual read found no operator-addressed sentence; `refs/experiments/README.txt` (L672) is named with "not yet published" in the same paragraph and is treated under S2.
- reader-flow lens (step 4j): ran with a fresh-context subagent given the source tree, the PDF and the audience only; sidecar at `parity39.2.readerflow/` (8 major, 27 minor, 3 nit). Confirmed and unconfirmed items are listed above. The two float-placement findings were not confirmed (Fig. 2 and Table 4 print on the page where their discussion starts).
- readerflow recurrence: R = 4 / 42 = 0.095 against `parity39.1.readerflow/` (threshold 0.5); recorded in `parity39.2.readerflow/_meta.json`. Advisory.
- reader-flow lint (step 4k): ran; 2 define-before-use hits (not confirmed: "secret" in the abstract is the ordinary word; `c_i` is defined by Eq. 3) and 3 variant-pair hits (nits above).
- float-proximity (step 4l): ran; no hits.
- provenance and subject-voice tiers (steps 4d, 4e): inactive (no corpus or subjects declared).
- artifact verification (step 4f): no `artifact_verify` declaration; `lake` was not run, at the requester's instruction. The Lean sources were checked by reading, and the digest by recomputation in Python.
- venue overlay: `parity39/.anvil.json` absent, none resolved.
- evidence-check (step 5b): ran on the staged `scoring.md`; pass, 9 dimensions, no findings.
- No network requests were made. Statements about SLIP39, SSKR, codex32 and Shamir39 are from reviewer knowledge and are leads for `paper-litsearch` / `paper-audit`.
- No git commit was made (requester's instruction; git sync is off by default).
