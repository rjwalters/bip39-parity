# Audit flags for parity39.4

Build: OK. `pdflatex`, `bibtex`, then two more `pdflatex` passes (3 in all); the last
pass has no "Label(s) may have changed" warning and its `.aux` is byte-identical to the
previous pass. 13 pages, no `??`, no undefined citation or reference in the final pass,
no overfull box, one underfull box in the bibliography, 0 BibTeX warnings. Compiled in a
scratch copy at the requester's instruction; `main.tex` there is byte-identical to
`parity39.4/main.tex`.

Round-three critical flag: resolved. main.tex:L563–565 now reads "where card parity and
the grid decoder without a digest both returned a wrong secret (the bracketed 0.2)".
`grid-main-k4.txt` L31 gives 0.2 under card parity and grid, no digest, and 0.0 under
checksum only, and Table 2 (L506) carries the bracket under those two columns only.

Scope of the change from version 3: 13 hunks of prose. The four tables and two figures
are identical to version 3; `figures/`, `refs.bib` and `anvil-paper.cls` are
byte-identical. Every changed sentence was checked against the logs, the SOUPS extract
or the Lean code (numerical-audit.md, "Sentences changed in this version").

## Critical flags (block advancement to AUDITED)

None.

## Non-critical notes

- **"The one wrong answer in these runs"** (Sec. 5.3 "Wrong answers", main.tex:L561–562
  vs Table 2 L501, L508 and `grid-main-k4.txt` L16–17, L36–37): the sentence is new in
  this version. Read alone it says the runs hold one wrong answer. The foreign-card rows
  hold many: 59.7–67% for checksum only and card parity with all cards, and 100% for the
  three methods without a digest with exactly t cards. The sentence names its row, and
  the paragraph before it (L545–554) reports the foreign-card wrong answers, so no
  number disagrees with the table. The count is right for wrong answers outside the
  foreign-card rows: `grid-main-k4.txt` L31 is the only such nonzero entry in the six
  files. Suggested wording: "the one wrong answer outside the foreign-card rows".

- **"Two-edit rows"** (Sec. 5.2, main.tex:L436–437): "at k = 3 the two-edit rows in
  76–96%" matches two dropped words (96, 82) and wrong + dropped (92.5, 76) in
  `single-phrase.txt` L35–36, L71–72. The paper counts edits and substitutions
  separately (L187), so wrong + dropped is one edit and one substitution, and the "2
  wrong words" row at k = 3 (0% unique, refused, L30, L66) is outside the range. The
  next sentence covers that row. Naming the two rows would remove the doubt.

- **Mislabelled card kept as evidence: one condition left out** (Sec. 4.2,
  main.tex:L300–301 vs `Parity39/Grid.lean` L183–192): the card is kept under the number
  entered only if it has the right count of words; a short or long one is dropped.
  Decoder step 1 (L333–335) states the condition. Two further behaviours are not in the
  text: the card's parity words are stripped with the header of the entered number
  (L186–189), so its unconfirmed words are evidence at the wrong evaluation point, and a
  card whose corrected number equals that of a card already read is dropped (L208). No
  run on disk exercises any of this, which the paper now says (L301–302).

- **Wrong-number capacity** (main.tex:L298–300): confirmed in the code. The entered
  header is a known symbol (`Grid.lean` L159–160), `RS.decode` requires 2e + s ≤ k
  (`RS.lean` L77), so one wrong header needs k ≥ 2 and at k = 4 one more wrong word
  fits. This is read from the code, not measured.

- **Swap estimate is derived, not measured** (Sec. 3.2, main.tex:L194–204): the
  arithmetic is right (325; 325 · 26/2047 = 4.13) and the conclusion is now stated under
  its assumption. No run without the swap limit exists on disk.

- **Cause of the single wrong answer is inferred** (main.tex:L560–562): now worded as
  "We take that to be the cause". The log has no per-trial detail. That both methods'
  0.2 is the same trial follows from the harness running all five methods on the same
  cards in each trial (`GridTests.lean` L147–153), not from the log.

- **Decoder step 5** (main.tex:L348–352 vs `Grid.lean` L336–349): now agrees with the
  code. The subsets are tested only when a digest is configured (L341), which is the
  decoder the step describes.

- **Truncated percentages** (carried forward; disclosed at main.tex:L422–423): Table 3
  prints 95.6, 83.6, 78.6 and 94.6 where the counts round to 95.7, 83.7, 78.7 and 94.7.
  The abstract's "31%" is 122/400 = 30.5% exactly. Tables agree with the logs in every
  cell.

- **Recall figures pool two groups** (main.tex:L54–57): 40% and 49% are the three-day
  and seven-day groups; 41 of 92 (44.6%) is both groups together (SOUPS extract Table 2,
  L604–608). The wording is accurate.

- **Unsupported statement of absence** (main.tex:L52–53): "We know of no published
  measurement of word error rates in hand-copied mnemonics." Phrased as the author's
  knowledge; nothing on disk bears on it.

- **Unverified citations** (21): claim-support unverified — source not on disk, for
  `bip39`, `reed1960polynomial`, `shamir1979how`, `moura2021lean`, `polyseed`, `slip39`,
  `sskr`, `shamir39`, `bip93`, `mceliece1981sharing`, `tompa1989how`,
  `rabin1989verifiable`, `rabin1989efficient`, `blakley1985security`,
  `franklin1992communication`, `elias1954error`, `schmidt2009collaborative`,
  `patterson1988case`, `plank1997tutorial`, `sugiyama1975method`, `forney1965decoding`.
  The auditor has no specific reason to think any characterisation inaccurate. The
  round-three reservation about the dual-parity sentence is withdrawn: L127–131 now
  attributes a plain sum to single-parity arrays and a Reed–Solomon extension to
  tolerance of several failures. The author should still verify off-disk.

- **Bibliography**: all 22 entries are cited and all 22 cites resolve.
  `ambati2026notall` lacks pages; `blakley1985security` and `moura2021lean` lack
  publisher and series.

- **Reproducibility pin** (main.tex:L705–709): all 15 SHA-256 digests in
  `refs/experiments/README.txt` match the current files. The README's base commit does
  not contain every source file, so the digests are what pins the tables. The paper says
  the tree is not yet published.

- **Link hygiene** (step 6c): `audience_check` reported 0 hits and no public repository
  URL, declared or derived. `refs/experiments/README.txt` (L708) is a bare path that a
  reader of the PDF cannot follow; L707 says the tree is not published. Declare
  `public_repo_url` and link the path once an address exists.

- **Figures**: no `\includegraphics`. `figures/rates.tex` regenerated from
  `figures/src/tables.py` in a scratch copy is byte-identical to the shipped file.
  `figures/grid.tex` is hand-written.

- **Changelog** (`changelog.md`): its entries match the diff from version 3, and its
  statement that tables and the figure are unchanged is confirmed. One hunk it does not
  list separately is the abstract's "the grid decoder with its digest" (covered by its
  T9 line).

- **Version metadata** (`parity39.4/_progress.json`): both phases record `completed`
  (19:02Z) earlier than `started` (19:40Z). This does not affect the paper.

- **Tooling**: `anvil.lib.sidecar` (cleanup, stage, copy, commit),
  `anvil.lib.pending_marker --write-review` (pass, no markers; wrote
  `parity39.4.pending/_review.json`), `anvil.lib.audience_check` (pass) and
  `anvil.lib.tex_includes` were run with `uv run --project .anvil`. Corpus tier inactive
  (`resolve_corpus_dirs` returns no dirs), so no `.corpus-audit/` sibling.
  `.anvil/config.json` is absent, so no git sync. A sibling critic's staging dir
  `.parity39.4.review.tmp/` was present and left untouched. `lake` was not run, no
  network request was made, nothing was committed, and nothing under `parity39.4/`,
  earlier version dirs or `parity39/` was edited.

## Audience-fit notes (non-critical — step 6c, issue #1322)

- None. `audience_check` reported 0 governance-vocabulary and 0 private-locator hits.
