# Audit flags for parity39.3

Build: OK. `pdflatex`, `bibtex`, then two more `pdflatex` passes (3 in all); the last
pass has no "Label(s) may have changed" warning and its `.aux` is byte-identical to the
previous pass. 13 pages, no `??`, no undefined citation or reference, no overfull box, one
underfull box in the bibliography, 0 BibTeX warnings. Compiled in a scratch copy at the
requester's instruction; `main.tex` there is byte-identical to `parity39.3/main.tex`.

Round-two critical flags: both resolved.

- "five grid files": main.tex:L714–715 now says "the six grid files, including rows that
  no table prints". The six files sum to 31,600 trials.
- Sec. 5.2 against Table 1: main.tex:L429–433 now says faults beyond the capacity (two
  wrong words at k ≤ 3; a wrong word plus a dropped word at k = 2) were refused, apart
  from 0.5–1.5% of unfiltered trials at k = 2. This matches `single-phrase.txt` L18, L24,
  L30, L54, L60, L66 and Table 1, whose caption (L438–440) now agrees with footnote a.

## Critical flags (block advancement to AUDITED)

- **Numerical inconsistency** (Sec. 5.3 "Wrong answers", main.tex:L554–555 vs Table 2
  L498 and `grid-main-k4.txt` L31): "where both methods without a digest returned a wrong
  secret (the bracketed 0.2)". The paper compares five methods (L399–412) and three of
  them have no digest: checksum only, card parity, and grid, no digest. In the 3-of-5
  row with exactly t cards and 5% of words wrong the log gives checksum only 0.5 / 0.0,
  card parity 50.7 / 0.2, and grid, no digest 50.7 / 0.2. So two of the three no-digest
  methods returned the wrong secret, and Table 2 correctly prints no bracket under
  Checksum only. "Both methods without a digest" was accurate before the fifth column was
  added only if checksum only was not counted; as written it contradicts the table. Fix:
  "where card parity and the grid decoder without a digest both returned a wrong secret".
  The count (one trial, 1 of 400) and the row are right.

## Non-critical notes

- **Wrong-number sentence holds under conditions the text leaves out** (Sec. 4.2,
  main.tex:L293–296 vs `Parity39/Repair.lean` L115, L123–128 and `Parity39/Grid.lean`
  L159–163, L175–193): the mechanism is as described. `readCard` passes the entered
  header as a known suffix symbol, `RS.decode` can return position W among its errors,
  `repair` attaches the note "the card's label does not match its words", `readCard`
  takes the card's index from the corrected header, and `combine` prints the note
  (`Main.lean` L166–170). Three things are not said. (1) The correction uses one of the
  card's floor(k/2) substitutions, so it needs k ≥ 2, and at k = 4 a mislabelled card
  tolerates one further wrong word, not two. (2) A mislabelled card that does not repair
  alone is kept as unconfirmed evidence under the wrong number (L183–191). (3) If the
  corrected number equals that of a card already read, the card is dropped (`readCards`
  L208). No experiment or unit test enters a wrong number: `GridTests.lean` L143 gives
  the true number or none. The paper does say numbers are otherwise given correctly
  (L396).

- **"Repair" at 99.5%** (Sec. 5.2, main.tex:L425–427; conclusion L724–725): "With the
  filter, two parity words repair a swap or a dropped word, three repair two dropped
  words or a wrong word plus a dropped word". With the filter the unique-repair rate is
  99.5%, not 100%, in four cells of Table 1: any swap at 24+2, two dropped words at 12+3,
  and wrong + dropped at 12+3 and 24+3 (`single-phrase.txt` L57, L35, L36, L72); the rest
  was ambiguous. The table shows this; the prose and the conclusion state it without a
  qualifier.

- **"The same holds from one parity word more"** (main.tex:L427–428): true for swaps,
  dropped words and wrong + dropped. For two wrong words the unfiltered rate is already
  100% at k = 4 (`single-phrase.txt` L42, L78), so no extra word is needed there, and
  there is no k = 5 run.

- **Swap estimate is derived, not measured** (Sec. 3.2, main.tex:L193–202): the
  arithmetic is right (325; 325 · 26/2047 = 4.13). "Nearly every phrase with two wrong
  words would be repaired to one of them" follows from the expectation under the stated
  uniformity assumption (about 98% if the count is Poisson); no run without the limit
  exists on disk. "(and nonzero)" fails when the two error values coincide, probability
  1/2047.

- **Cause of the single wrong answer is inferred** (main.tex:L552–554): "A card with
  more wrong words than its parity can correct occasionally repairs to a different valid
  card. This happened once". The log records one wrong secret in that row and none from
  checksum only, which fits a miscorrected card. It has no per-trial detail, so the cause
  is not shown, and a miscorrected card that was later outvoted would not appear in any
  log. "Once" counts wrong secrets returned, not miscorrected cards.

- **Decoder step 5** (main.tex:L343–345 vs `Grid.lean` L341–348): the paper says subsets
  of t are tested when "more than t cards are confirmed". The code tests them whenever a
  digest is configured, including with exactly t confirmed. This does not change the
  bound of C(m,t) + 1 candidates, which matches the code (11 · 2^-22 = 2.62 × 10^-6).

- **Truncated percentages** (carried forward; now disclosed at main.tex:L415–416):
  Table 3 prints 95.6, 83.6, 78.6 and 94.6 where the counts round to 95.7, 83.7, 78.7 and
  94.7. The abstract's "31%" is 122/400 = 30.5% exactly. Tables agree with the logs in
  every cell.

- **Dual-parity citation** (main.tex:L127–130, `patterson1988case`,
  `plank1997tutorial`; sources not on disk): carried from round two. To the auditor's
  knowledge Patterson et al. define RAID levels 1–5 and describe no dual-parity array,
  and Plank's tutorial treats general Reed–Solomon coding and has a published correction
  (Plank and Ding, 2005). A RAID-6 reference would support "the sums that a dual-parity
  array stores" directly.

- **Unsupported statement of absence** (main.tex:L52–53): "We know of no published
  measurement of word error rates in hand-copied mnemonics." Phrased as the author's
  knowledge; nothing on disk bears on it.

- **Unverified citations** (21): claim-support could not be verified because the sources
  are not in `parity39/refs/`: `bip39`, `reed1960polynomial`, `shamir1979how`,
  `moura2021lean`, `polyseed`, `slip39`, `sskr`, `shamir39`, `bip93`,
  `mceliece1981sharing`, `tompa1989how`, `rabin1989verifiable`, `rabin1989efficient`,
  `blakley1985security`, `franklin1992communication`, `elias1954error`,
  `schmidt2009collaborative`, `patterson1988case`, `plank1997tutorial`,
  `sugiyama1975method`, `forney1965decoding`. The auditor has no specific reason to think
  the characterisations of SLIP39, SSKR, Shamir39, codex32, Polyseed, Tompa–Woll, Rabin
  or Rabin–Ben-Or inaccurate; the one reservation is the dual-parity sentence above. The
  author should still verify off-disk.

- **Bibliography**: all 22 entries are cited and all 22 cites resolve. Title capitals
  are now protected. `ambati2026notall` lacks pages; `blakley1985security` and
  `moura2021lean` lack publisher and series.

- **Reproducibility pin** (main.tex:L695–699): all 15 SHA-256 digests in
  `refs/experiments/README.txt` match the current files. `Parity39/Grid.lean` and
  `GridTests.lean` are still outside the base commit the README names, so the digests,
  not the commit, are what pins the grid tables. The paper says the tree is not yet
  published.

- **Link hygiene** (step 6c): `audience_check` reported 0 hits and no public repository
  URL, declared or derived. `refs/experiments/README.txt` (L698) is a bare path that a
  reader of the PDF cannot follow; L697 says the tree is not published. Declare
  `public_repo_url` and link the path once an address exists.

- **Figures**: no `\includegraphics`. `figures/rates.tex` regenerated from
  `figures/src/tables.py` in a scratch copy is byte-identical to the shipped file, so it
  is not stale although the script's mtime is 19 s later. `figures/grid.tex` is
  hand-written.

- **Changelog** (`changelog.md`): its entries match the diff from version 2. The
  correction of the version-2 changelog ("up to 7.7 points; 36.0 → 30.5 in the cell
  behind the abstract") agrees with the round-two audit.

- **Tooling**: `anvil.lib.sidecar` (cleanup, stage, copy, commit),
  `anvil.lib.pending_marker --write-review` (pass, no markers; rewrote
  `parity39.3.pending/_review.json`), `anvil.lib.audience_check` (pass) and
  `anvil.lib.tex_includes` were run with `uv run --project .anvil`. Corpus tier inactive
  (`resolve_corpus_dirs` returns no dirs), so no `.corpus-audit/` sibling.
  `.anvil/config.json` is absent, so no git sync. A sibling critic's staging dir
  `.parity39.3.review.tmp/` was present and left untouched. `lake` was not run, no
  network request was made, nothing was committed, and nothing under `parity39.3/`,
  earlier version dirs or `parity39/` was edited.

## Audience-fit notes (non-critical — step 6c, issue #1322)

- None. `audience_check` reported 0 governance-vocabulary and 0 private-locator hits.
