# Audit flags for parity39.2

Build: OK. `pdflatex`, `bibtex`, then two more `pdflatex` passes (3 in all); the last
pass has no "Label(s) may have changed" warning and its `.aux` is byte-identical to the
previous pass. 13 pages, no `??`, no undefined citation or reference, no overfull box, one
underfull box in the bibliography. Compiled in a scratch copy at the requester's
instruction; `main.tex` there is byte-identical to `parity39.2/main.tex`.

Round-one critical flags: both resolved.

- "13--15% of swaps ambiguous" (15.5 in the log): the sentence is gone. Table 1 prints
  87 / 100 and 84.5 / 99.5 for 24+2, which match `single-phrase.txt` L56–57.
- Digest description: Sec. 4.3 (L296–299) now states the rule of `Grid.digestWords`
  (`Parity39/Grid.lean` L62–66). The test vector was recomputed independently with Python
  `hashlib` and `data/english.txt`: 23 × `abandon` + `art` gives `siege`, `say`, as printed.

## Critical flags (block advancement to AUDITED)

- **Numerical inconsistency** (Sec. 8, main.tex:L688–689 vs the evidence folder): "The
  trial total counts every row of the five grid files." There are six grid files:
  `grid-main-k4.txt`, `grid-minimal-k6.txt`, `grid-minimal-k8.txt`, `scenario-3of6.txt`,
  `scenario-3of5.txt`, `scenario-4of9.txt` (also `figures/src/tables.py` L87–88, and the
  paper's own list at L678–686). The stated total of 31,600 is the sum over all six
  (13,600 + 3,000 + 3,000 + 4,500 + 4,500 + 3,000); no five of them give it. The total
  itself is right. Fix: "six". The harness prints five strategy columns, which is the
  likely source of the slip.

- **Text contradicts Table 1** (Sec. 5.2, main.tex:L407–409 vs L432 and
  `single-phrase.txt` L30, L66): "Where the original was not the unique repair the outcome
  was ambiguous, except beyond the capacity of $k=2$: there the procedure refused". Two
  wrong words at k = 3 are also beyond capacity (2e = 4 > 3), were not ambiguous, and were
  refused in 100% of trials at 12+3 and 24+3, with and without the filter. Table 1 prints
  "refused" in both cells. Fix: "except beyond the capacity (the refused cells of
  Table 1, at k = 2 and k = 3)". The rest of the sentence (0.5–1.5% wrong in three
  unfiltered rows, all at k = 2) is correct.

## Non-critical notes

- **Selective report of the no-digest grid column** (main.tex:L514–521): "Wrong cards are
  caught by the digest, not by joint decoding ... Joint decoding without the digest does
  not". The two cases quoted are right (2-of-3 with all cards refused every trial,
  `grid-main-k4.txt` L16; exactly t cards wrong every time, L17 and L37). The same column
  shows that with two or more spare cards joint decoding alone recovered every trial and
  returned no wrong secret: 3-of-5 with all five cards 100.0 / 0.0 (`grid-main-k4.txt` L36,
  `scenario-3of5.txt` L20) and 3-of-6 with all six (`scenario-3of6.txt` L20). With one
  spare it refused every trial and returned none wrong (`scenario-3of5.txt` L14,
  `scenario-3of6.txt` L14, `scenario-4of9.txt` L14). So the heading holds for zero or one
  spare card, not in general. This column is in the logs but in no table.

- **"Two parity words repair a swap or a dropped word"** (main.tex:L405, L698; also
  "three repair two dropped words or a wrong word plus a dropped word", L406): as a unique
  repair this holds at 99.5–100% only with the BIP39 checksum filter. Without it Table 1
  gives 84.5–96.5% for swaps at k = 2 and 76–96% for the two k = 3 cases, the remainder
  ambiguous. The conclusion states it without the qualifier.

- **Logged percentages are truncated, not rounded** (`GridTests.lean` L61–64,
  `Tests.lean` `pct`): Table 3 prints 95.6, 83.6, 78.6 and 94.6 where the counts
  (287, 251, 236, 284 of 300) round to 95.7, 83.7, 78.7 and 94.7. The bracketed 0.2 in
  Table 2 is 1 of 400 (0.25%); 59.7 is 59.75. The tables agree with the logs in every
  cell; the bias is at most 0.1 point downward.

- **False-accept bound counts one candidate too few** (main.tex:L305–308 vs
  `Grid.lean` L336–348): the decoder tests the joint reconstruction first and then every
  t-subset, so up to C(m,t) + 1 candidates meet the digest: 11 · 2^-22 = 2.6 × 10^-6 for
  m = 5, t = 3, not 2.4 × 10^-6.

- **Table 3 caption** (main.tex:L547–549): "No trial returned a wrong secret" is true of
  the grid decoder, whose numbers the table shows, but the caption does not name the
  method, and per-card repair without the digest returned one wrong secret in the k = 4,
  5%, 3-of-5 cell (`grid-main-k4.txt` L31), as Sec. 5.3 reports.

- **Table 1 caption and footnote a** (main.tex:L416–417, L434–435): the caption defines
  "refused" as no candidate in any trial with or without the filter; the three cells marked
  a had a candidate in 0.5–1.5% of unfiltered trials. The footnote says so, but the two
  statements conflict as written.

- **SOUPS wording** (main.tex:L53–57): the numbers are supported (see citation-audit.md).
  The 41 are participants who failed, not attempts. The study says it could "theoretically
  recover" 14 of them within a time limit of 168.5 minutes; it does not report running the
  search on BIP-39 phrases. 40% and 49% are the complements of the reported 60% and 51%
  success rates.

- **SSKR "follows the same design"** (main.tex:L101–102; source not on disk): to the
  auditor's knowledge SSKR shares over GF(2^8) with a set identifier and inherits the
  digest check, but has no RS1024 checksum; its Bytewords encoding uses a CRC-32. Say which
  parts of the design are shared.

- **P and Q citation** (main.tex:L123–125, `patterson1988case`, `plank1997tutorial`;
  sources not on disk): the sentence is now correct about the code (parity checks, not
  parity words). To the auditor's knowledge neither source names P and Q checks: Patterson
  et al. define RAID levels 1–5, and Plank's tutorial treats general Reed–Solomon coding
  and has a published correction (Plank and Ding, 2005). A RAID-6 reference would support
  the P and Q wording directly.

- **Unsupported statement of absence** (main.tex:L51–52): "We know of no published
  measurement of word error rates in hand-copied mnemonics." Phrased as the author's
  knowledge; nothing on disk bears on it.

- **Unverified citations** (20): claim-support could not be verified because the sources
  are not in `parity39/refs/`: `bip39`, `reed1960polynomial`, `shamir1979how`,
  `moura2021lean`, `polyseed`, `slip39`, `sskr`, `bip93`, `mceliece1981sharing`,
  `tompa1989how`, `rabin1989verifiable`, `rabin1989efficient`, `blakley1985security`,
  `franklin1992communication`, `elias1954error`, `schmidt2009collaborative`,
  `patterson1988case`, `plank1997tutorial`, `sugiyama1975method`, `forney1965decoding`.
  The characterisations of SLIP39 (set identifier, RS1024 checksum, digest of the shared
  secret), codex32, Polyseed, Tompa–Woll, Rabin and Rabin–Ben-Or agree with the auditor's
  knowledge of those documents. The author should still verify off-disk.

- **Bibliography**: all 21 entries are cited and all 21 cites resolve. Capitals in titles
  are unprotected, so the PDF prints "bch", "reed-solomon", "(raid)", "lean 4" and "goppa".
  `blakley1985security` and `moura2021lean` lack publisher and series; `ambati2026notall`
  lacks pages.

- **Changelog** (`changelog.md` L35–36): "3-of-5 numbers in the main table ... differ
  slightly". Against `parity39.1/main.tex` the 2-of-3 cells are unchanged, as stated. The
  3-of-5 cells moved by up to 7.7 points (checksum only, exactly t, 1%: 45.7 to 38.0) and
  5.5 points in two cells the paper quotes (card parity at 10%: 36.0 to 30.5, the
  abstract's "31%"; exactly t at 3%: 79.0 to 84.5). The explanation given (the added
  scenarios shift the random stream for the second block) is consistent with
  `GridTests.lean`, where the three new scenarios are appended to the list.

- **Reproducibility pin** (main.tex:L669–673): all 15 SHA-256 digests in
  `refs/experiments/README.txt` match the current files. The README's base commit is the
  current `HEAD`, but `Parity39/Grid.lean` and `GridTests.lean` are untracked, so the
  commit alone does not reproduce the grid tables. The paper says the tree is not yet
  published.

- **Link hygiene** (step 6c): `audience_check` reported 0 hits and no public repository
  URL, declared or derived. `refs/experiments/README.txt` (L672) is a bare path that a
  reader of the PDF cannot follow; L671 says the tree is not published. Declare
  `public_repo_url` and link the path once an address exists.

- **Figures**: no `\includegraphics`. `figures/rates.tex` regenerated from
  `figures/src/tables.py` in a scratch copy is byte-identical to the shipped file, so it
  is not stale although the script's mtime is 41 s later. `figures/grid.tex` is
  hand-written.

- **Tooling**: `anvil.lib.sidecar` (cleanup, stage, copy, commit),
  `anvil.lib.pending_marker --write-review` (pass, no markers; wrote
  `parity39.2.pending/_review.json`) and `anvil.lib.audience_check` (pass) were run with
  `uv run --project .anvil`. Corpus tier inactive (`resolve_corpus_dirs` returns no dirs),
  so no `.corpus-audit/` sibling. `.anvil/config.json` is absent, so no git sync. A sibling
  critic's staging dir `.parity39.2.review.tmp/` was present and left untouched. `lake`
  was not run, no network request was made, nothing was committed, and nothing under
  `parity39.2/`, `parity39.1*/` or `parity39/` was edited.

## Audience-fit notes (non-critical — step 6c, issue #1322)

- None. `audience_check` reported 0 governance-vocabulary and 0 private-locator hits.
