# Comments — parity39.3

Line numbers refer to `parity39.3/main.tex`. Items within a severity group are in priority order. `T<n>` labels match the ranked list in `verdict.md`; `S<n>` labels are the round-two items from `parity39.2.review/`.

## Blocker

None.

## Major

**T1. §8 L695-699 — the source is not obtainable (S2, open).**
"The tree is not yet published at a public address. To pin the version, the file `refs/experiments/README.txt` distributed with the paper sources lists the SHA-256 of every source file used." The disclosure is the right one and the substitute was checked: all 15 digests in the README match the working tree today. On the merits nothing has changed since round two. The digests certify a tree that no reader can fetch; the README records "Base git commit ... plus uncommitted changes", so no commit reproduces the logs; and the first question the declared audience asks of a backup format is where the reference implementation is. Fix, in order of preference: commit and publish the tree and cite URL and commit; or attach the Lean sources, `data/english.txt`, the logs and the README as ancillary files or a deposited archive and cite that. This needs the author. Until then dim 5 stays at 3.

**T2. §4.2 L293-296, §4.4 step 1 L327-329, §5.1 L396, §7 L667-670 — the wrong-number claim is unqualified and untested (S6, partly resolved).**
The text: "A card entered with the wrong number has one wrong symbol, the header, which the repair procedure corrects like any other wrong word and reports; the number it settles on is the one consistent with the card's words."

What the code does, read from `Parity39/Repair.lean` L104-142 and `Parity39/Grid.lean` L158-193:

- `readCard` passes the entered number to `Repair.repair` as a known suffix symbol `some (header i t)`. `repair` appends it to the received word and calls `RS.decode k (recv ++ suffix) maxErrors`. The suffix position is an ordinary present symbol to the decoder (the Chien search in `RS.decode` L79-80 runs over every position of `recv`, the suffix included), so a wrong header is found as one error at position W, the corrected value is returned in `virt`, the candidate costs 1, and the note "the card's label does not match its words" is attached (`Repair.lean` L123-128).
- `readCard` then keeps candidates whose corrected header passes `validHeader` (threshold equal to t, number at least 1) and, if exactly one remains, sets the row's index from the corrected header (`Grid.lean` L175-179). So the number used is the one the words imply, and the mismatch is reported. For this case the paper's sentence is accurate.
- The nearest-codeword argument supports uniqueness: the true card is at distance 1 from what was entered and every other codeword is at distance at least k from it, so no second candidate lies within ⌊k/2⌋ for k ≥ 2.

What the sentence leaves out:

- It needs parity to spare. The header error is one of the e in 2e + s ≤ k. With k = 4 a mislabelled card can carry one other wrong word, not two; a mislabelled card with a swap is still within reach (`maxErrors = (k-2)/2 = 1` for swap hypotheses); with k = 1 a wrong number cannot be corrected at all. "Like any other wrong word" implies this but a reader planning k will not draw it out.
- Beyond that capacity the card does not repair, and because a number was supplied `readCard` keeps it as unconfirmed evidence under the number that was entered, with the wrong header's contribution subtracted from its parity words (`Grid.lean` L183-191). Its data words then sit at the wrong evaluation point in every column. With at least t confirmed cards this is harmless (columns use confirmed cards alone); with fewer, the columns are polluted and the outcome rests on the digest, which refuses. Step 1 of §4.4 ("a legible number and the right count of words, is kept as unconfirmed evidence") is where this should be said.
- Nothing tests it. `GridTests.lean` always supplies the right number or none (L143), `Tests.lean` has no label case, and §5.1 says "Card numbers are otherwise given correctly". The claim rests on reading the code.

Fix: add "provided the card has parity to spare: the header counts as one wrong word, so with k = 4 one further wrong word is still corrected" and one sentence on the beyond-capacity case; add a mislabelled-card scenario to `gridtests` (one card entered under another card's number, with and without word errors) and report it as a row of Table 2. The remaining scope points from S6 stand as stated limits: one fixed seed, independent uniform substitutions, and no scenario combining a foreign card with illegible numbers, the case in which the row distance is k and the digest is the only defence.

## Minor

**T3. §1 L54-63, §2 L93-98 — a baseline the audience will raise (`related-work`).**
The introduction cites a study in which 14 of 41 failed phrases were recoverable "by bounded search", then moves on. Bounded search over near-miss phrases, tested against the BIP39 checksum and a known address or public key, is how a mistyped mnemonic is repaired in practice today, and there are established open-source recovery tools for it (reviewer recall: `btcrecover`'s seed recovery is the best known; not checked online, no entry proposed). The paper should say in two sentences what parity words give that search does not: no need for an address oracle, a guarantee rather than a time budget, more than one or two errors, and applicability to share words, which have no checksum at all. Recommend a `paper-litsearch` pass for this cluster.

**T4. Repetition and length (S11, not resolved).**
Still 13 pages against the brief's "about 10". The no-wrong-secret result is at L35, L556-557, L575 (Table 3 caption), L598 (Table 4 caption) and L728. The exactly-t caveat is given in full at L34-35, L79-80, L565-567 with the §5.4 heading, L632-633, L646-649, L681-682 and L728-730. The assumed-rate caveat is at L52-54, L86-88, L667-669 and L689. State each in full once (§5.3, §5.4, §7) and point to it elsewhere; drop the sentence from the two captions; let the conclusion carry the planning rule (bring a spare card, otherwise raise k) instead of restating numbers from §5.2 and the abstract.

**T5. Naming (reader-flow class 2, confirmed).**
- Per-card repair: "repairing cards separately" (L32), "Card parity" (L402, Table 2, Fig. 2 legend), "per-card repair" (L510, L530), "repairing cards one at a time" (L518), "per-card method(s)" (L524, L538), "repair card by card" (L727). The grid decoder: "Grid", "grid decoder", "the full decoder" (L410), "joint decoding". Fig. 2's caption says "joint decoding" and "per-card repair" where its legend says "Grid" and "Card parity". Choose one name each and bind the table label to it once.
- "Checksum only" (L399) is a detection-only use of the card's parity; "checksum" everywhere else is BIP39's SHA-256 checksum, which §4.4 says does not apply to cards. "Detection only" avoids the collision.
- "Row" is the unwritten r_d in §4.1 and a card in §4.4 (L325, L336) and at L566 ("no spare rows"). Write "no spare cards" at L566.
- L259 "any m ≥ t holders": m counts cards everywhere else (L280-283, L348) and §6 gives one holder several cards. Write "any m ≥ t stripped cards".
- L633 "lost or burnt" uses "burnt" for a destroyed card after L388 defined a burn as a run of unreadable words.
- L84 "a hash check on the shared secret": the introduction never uses "digest", the word the rest of the paper depends on.
- L218 rebinds L (from N+k to W+1) and §4 writes D where §3 wrote N; one bridging clause would do.

**T6. §5.2 L425-428 and §9 L724-725 — "repair" against Table 1 (S4, residue).**
"With the filter, two parity words repair a swap or a dropped word, three repair two dropped words or a wrong word plus a dropped word". Table 1 has 99.5 in four of those filtered cells (24+2 any swap; 12+3 two dropped; 12+3 and 24+3 wrong plus dropped), the remaining 0.5% being ambiguous. Write "in at least 99.5% of trials" or "uniquely in all but one trial of 200". "Without the filter the same holds from one parity word more" makes the reader work out a three-part mapping, and the example that follows (k = 2 swaps) illustrates the failing case; spell out "three for a swap or a dropped word, four for two dropped words or a wrong word plus a dropped word".

**T7. Floats and figures.**
- Fig. 2 (L505-514) prints at the top of page 9; its discussion ("Spare cards turn into error correction") is on page 7, with the full-page pair of Tables 1 and 2 between. Confirmed by `float_proximity` and in the PDF. Place it after the "Spare cards" paragraph.
- Table 1 (L435) prints on page 8, after the §5.3 heading and three paragraphs of grid results, and splits the "Swaps and dropped words" paragraph across pages 7 and 8.
- Table 1's column heads "12+2 ... 24+4" and "A 24+2 phrase" (L198) use an N+k shorthand that is never stated. Add "columns are data words + parity words" to the caption.
- Fig. 2 plots three methods. Say in the caption that card parity + digest coincides with card parity, and grid without digest with Grid, in these rows.
- Fig. 1: "never written" and "printed cards" (`figures/grid.tex` L23-24, x = 9.4) start at the right edge of the dashed header boxes (7.8 + 1.7 = 9.5). Move them to x = 9.7.

**T8. `refs.bib` — web sources are not pinned.**
`bip39`, `slip39`, `bip93`, `polyseed`, `sskr` and `shamir39` cite `.../blob/master/...` or a repository root, with no commit, tag or access date. These six entries carry every statement §2 makes about deployed formats. Add `note = {Accessed ...}` or cite a commit. `ambati2026notall` has no page range (the extract shows the proceedings page numbers).

**T9. Referents (reader-flow class 1; the first is confirmed in the body).**
- L714-715 "The trial total counts every row of the six grid files": name the number ("The 31,600 grid trials of Section 5.3 count ...").
- L35 "In 31{,}600 trials the decoder returned no wrong secret": the body restricts this to grid trials and the two methods with a digest; single-phrase trials did offer wrong phrases (Table 1 note a). Write "In 31,600 grid trials the decoder with the digest returned no wrong secret".
- L56 "Of the 41 participants who failed": give the study size (92) or say "across both groups", since the sentence before quotes two per-group rates.

## Nit

**T10. Points of precision (S12, partly resolved).**
- L255-256 "two different cards with the same number differ in at least k+1 positions": the header is i + 32t, so the condition is same number and same threshold.
- L194 "Any swap leaves S_0 unchanged (and nonzero)": S_0 is the sum of the two error values and is zero when they are equal (probability 1/2047). "nonzero unless the two errors cancel" is exact.
- L199-201 "nearly every phrase with two wrong words would be 'repaired' to one of them": with about four candidates of equal cost the procedure would return an ambiguous result made of wrong phrases, by the definitions at L186-188. "would be offered wrong phrases" is what follows.
- L340 "agrees with another card": `rescue` requires agreement with another unconfirmed card (`Grid.lean` L293-294).
- L163-164 "any existing wallet reads the first N words and ignores the rest": a wallet given N + k words rejects them; the user enters the first N.
- L676 "Proposition 1(d) says a better decoder exists for some patterns": one example pattern would make this concrete.
- L557-560: the pooled bound averages over scenarios in which a wrong answer is nearly impossible (1% errors, all cards) and ones in which it is the main risk (exactly t cards, 5% errors); the per-cell bound is the one a reader should carry.
- L109 / L111 "word level" / "word-level"; L387 / L508 "per word" / "per-word".

## Reader-flow lens: confirmation

The lens returned 8 major, 23 minor, 1 nit (`parity39.3.readerflow/`). Each was read against the text.

Class 1, confirmed in the body (counts toward the dim 7 cap): 1.
- "The trial total" (L714): no referent in the section (T9).

Class 1, not confirmed as define-before-use for this audience, kept as suggestions:
- "card" (L28, L73, L211): §4.1 L212-216 says a dealing produces n cards and gives a card's contents; the abstract's "any t of n cards" reads as shares. One clause ("each share is written on one card") at L72 would still help. Same judgment as round two.
- "spare card" (L29, L79): ordinary sense, and Fig. 2's caption and §6 use it with the count beside it. A one-line definition in §1 costs nothing.
- "product code" (L48): Fig. 1 and its caption show it; the audience knows Reed-Solomon codes. Same judgment as round two.
- "24+2" (L198): follows from L = N + k; the Table 1 caption gap is under T7.
- "Of the 41 participants who failed" (L56): the count has its object; the missing study size is under T9.
- "the same holds from one parity word more" (L427): a clarity defect, not an undefined term; under T6.
- Abstract "31,600 trials" (L35): minor, under T9.

Class 5: Related Work refers to "our first two parity checks" (L128-130), "the property our cards have" (L109) and Section 4.5 (L124) before those objects are introduced. Confirmed as minor: forward comparison is normal in a related-work section placed second, and each has a pointer or is self-explaining.

Classes 2, 4, 6, 7: confirmed; folded into T5, T7, T4 and T6. The number-variant findings on rounding (86% / 93% beside 92.5%; 83% in §6 against 85% in §5.4 for the same configuration run twice) are real and minor: L416-418 gives the bridge once; a parenthesis at L633 would repeat it where it is needed. "below 5%" (L520) against "up to 5%" (L510) should be one phrase.

Class 9: Reproducibility between Discussion and Conclusion (L692), §4.5 placed after the decoder (L353), and the digest absent from the abstract and the Grid shares bullet (L72). The third is worth acting on: the no-wrong-secret result depends on the digest and the abstract does not mention it.

## Status of round-two items

Each was checked against the text, the Lean sources and the logs, not against `changelog.md`.

| Item | Status | Basis |
|---|---|---|
| S1 | Resolved | §5.1 lists five methods (L396-412) and binds "Grid" to joint decoding. Table 2 has the "Grid, no digest" column; all 34 cells of that column match column 4 of `grid-main-k4.txt`, and `GridTests.lean` L147-153, L210 confirm the print order (checksum, card parity, parity + digest, grid without digest, grid with digest). The foreign-card paragraph (L537-546) gives three regimes and each matches the logs: two spares, 100 / 0 (3-of-5 with five cards; also 3-of-6 with six); one spare, 0 / 0 refused (2-of-3 with three; 3-of-5 and 3-of-6 with four; 4-of-9 with five); none, 0 / 100 wrong. "60--67%" is 59.7 and 67.0. |
| S2 | Open | L695-699 unchanged in substance; digests verified (T1). |
| S3 | Resolved | L348-351: (C(m,t)+1)·2^-22, 2.6e-6 for m = 5, t = 3 (11 / 4,194,304 = 2.62e-6). `combineRows` tests the jointly decoded row and then each t-subset of confirmed cards (`Grid.lean` L336-348), so the count is right. The assumption is at L313 ("modelled as uniformly random"), the bound follows the decoder, L351 says the experiments do not test it, and L314-316 gives the per-attempt odds for a holder who alters a card. |
| S4 | Resolved, residue | §5.2 L424-433 now agrees with Table 1 and `single-phrase.txt` row by row: refusals at k ≤ 3 for two wrong words and at k = 2 for wrong plus dropped; 0.5-1.5% wrong only without the filter at k = 2; 84.5-96.5% for unfiltered swaps at k = 2. Caption L437-440 agrees with note a. The conclusion carries the filter condition. Residue: 99.5 cells described as "repair" (T6). |
| S5 | Resolved | L714-715 "six grid files, including rows that no table prints"; 34·400 + 20·300 + 48·250 = 31,600. |
| S6 | Partly | Behaviour documented at L293-296 and accurate within capacity; qualification and a trial are missing (T2). L396 states numbers are otherwise correct. |
| S7 | Resolved | L193-202 states that S_0 is unchanged by a swap, that S_1 changes, the exact condition S_1/S_0 = α^p, and the uniformity assumption; "on average" marks the expectation. Two wording nits (T10). |
| S8 | Resolved | Shamir39 cited at L105-106; entry present. Content from reviewer knowledge, not checked online. |
| S9 | Resolved | Truncation stated at L415-416; Table 3 caption names the grid decoder; Fig. 1 header labels inside their boxes on PDF page 4. |
| S10 | Resolved | "joint decoding" defined at L29-30 and L75-76 and bound to the Grid methods at L408-411; "row decoder" no longer occurs; "numbers illegible" in the fault list at L394; the subset fallback is step 5 (L341-345) and the bound follows it. |
| S11 | Not resolved | Counts above (T4). |
| S12 | Partly | Rule of three explained inline (L558-560); SOUPS wording now "participants" and "in principle"; dual-parity wording fixed. Still open: rescue wording, Prop. 1 wording, "holders", no example for "a better decoder exists" (T5, T10). |

## Procedural notes

- render-gate (step 4b): skipped — `parity39.3.audit/compile-log.txt` not present (audit has not run on this version); `main.log` in the version directory was read by hand: 13 pages, no overfull box, one underfull box (badness 1810, bibliography), no undefined reference or citation. No `_gate.json` written.
- numeric-consistency (step 4c): ran; 9 advisory hits, none real. Six read table row labels ("3\% of words wrong") against neighbouring cells; three `quoted_variant` hits pair different quantities (88 / 85 / 86; 98.8 / 99). A manual claim-against-log pass was done in addition; findings are T6 and the rounding note above.
- pending-marker (step 4g): ran; no markers.
- evidence-drift (step 4h): ran; `CLEAN`.
- audience-fit (step 4i): ran; 0 hits. The scan reported no declared audience because the BRIEF states it in body prose; the BRIEF's audience line was used. Manual read found no operator-addressed sentence; `refs/experiments/README.txt` (L698) is named with "not yet published" in the same paragraph and is treated under T1.
- reader-flow lens (step 4j): ran with a fresh-context subagent given the source tree, the PDF and the audience only; sidecar at `parity39.3.readerflow/` (8 major, 23 minor, 1 nit). Confirmation above.
- readerflow recurrence: R = 12 / 35 = 0.343 against `parity39.2.readerflow/` (threshold 0.5); recorded in `parity39.3.readerflow/_meta.json`. Advisory. Most recurring items are naming and repetition.
- reader-flow lint (step 4k): ran; 2 define-before-use hits (not confirmed: "secret" in the abstract is the ordinary word; `c_i` is defined by Eq. 3) and 3 variant-pair hits (nits above).
- float-proximity (step 4l): ran; one hit, Fig. 2 two pages from its first reference; confirmed (T7).
- provenance and subject-voice tiers (steps 4d, 4e): inactive (no corpus or subjects declared).
- artifact verification (step 4f): no `artifact_verify` declaration; `lake` was not run, at the requester's instruction. The Lean sources were checked by reading; the digest test vector (siege, say) was recomputed in Python from `data/english.txt`.
- venue overlay: `parity39/.anvil.json` absent, none resolved.
- evidence-check (step 5b): ran on the staged `scoring.md`; pass, 9 dimensions, no findings.
- No network requests were made. Statements about SLIP39, SSKR, codex32, Polyseed, Shamir39 and recovery tools are from reviewer knowledge and are leads for `paper-litsearch` / `paper-audit`.
- No git commit was made (requester's instruction; git sync is off by default).
