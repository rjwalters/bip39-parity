# Citation audit for parity39.3

Files read: `parity39.3/main.tex` (the only file with `\cite`; `figures/grid.tex` and
`figures/rates.tex`, resolved through `anvil.lib.tex_includes`, contain none),
`parity39.3/refs.bib` (byte-identical to `parity39/refs.bib`),
`parity39/refs/ambati2026-soups-extract.txt`.

## Resolution

- Distinct keys cited: 22. Entries in `refs.bib`: 22 (`shamir39` is new in this version).
- Unresolved keys: 0. Uncited entries: 0.
- Compiled bibliography (`main.bbl`): 22 `\bibitem`s, 0 BibTeX warnings, no undefined
  citation in the final pass, no `??` in the PDF text.

## Entry completeness

- All 22 entries have author, title, year and a venue or `howpublished`; all have a URL.
- `ambati2026notall` has no pages. `blakley1985security` and `moura2021lean` have no
  publisher or series. None of these produces a BibTeX warning.
- Title capitals are now protected (`{R}eed-{S}olomon`, `{BCH}`, `{RAID}`, `{G}oppa`,
  `{L}ean`). The round-two note is resolved.
- Volume, issue, pages and year of the journal and proceedings entries agree with the
  auditor's memory of those publications. They were not checked against a source (no
  network, sources not on disk).

## Claim support

One cited source is on disk (`ambati2026notall`). The others are recorded as unverified.
The Notes column says where the auditor has a specific reason, from general knowledge of
the cited document, to think a characterisation is accurate or loose. Those remarks are
not verifications.

| Key | Resolved | Surrounding claim (main.tex line) | Verdict | Notes |
|---|---|---|---|---|
| `ambati2026notall` | yes | L54–59: controlled study; 40% of participants could not reproduce an assigned 12-word BIP39 phrase after three days and 49% after seven; of the 41 participants who failed, 14 had entered a phrase the authors could in principle recover by bounded search; each of those was one wrong word, or one wrong word plus a change of order. L667–668: the study measures recall from memory, not copying. | supports | Extract L609–612: BIP-39 success 60% at three days and 51% at seven, so 40% and 49% are the complements. L638–643: "we theoretically recover 14 users out of the 41 users (34.1%) who failed BIP-39 authentication" within 168.5 minutes. Table 4 (L650–670): 14 rows, 10 "1 wrong word" and 4 "1 wrong word, 1 flipped order". Extract L41–48, L452–453: lab-based randomized controlled trial, system-assigned keys, 12-word BIP-39. The round-two wording notes ("attempts", "could recover") are fixed: the text now says participants and "in principle". |
| `bip39` | yes | L43: wordlist has 2048 = 2^11 entries. L60: checksum 4 bits for 12 words, 8 for 24. L94–95: truncated SHA-256 checksum appended to the entropy before cutting into 11-bit words; detection only. | unverified — source not on disk | Consistent with `Parity39/Bip39.lean`, `data/english.txt` (2048 words) and the BIP39 vectors in `single-phrase.txt` L8–12. |
| `reed1960polynomial` | yes | L46: Reed–Solomon codes add redundancy. L151: minimum distance k+1. | unverified — source not on disk | Standard result. |
| `shamir1979how` | yes | L47: Shamir's scheme spreads a secret over several phrases. L270: each data column is Shamir's scheme. | unverified — source not on disk | Standard result. |
| `moura2021lean` | yes | L78: implementation in Lean 4. | unverified — source not on disk | Tool citation. |
| `polyseed` | yes | L95–97: one Reed–Solomon check word over a 2048-element field in a 16-word phrase. | unverified — source not on disk | Agrees with the auditor's knowledge of the Polyseed README. No reason to doubt. |
| `slip39` | yes | L101–104: shares bytewise over GF(2^8); each share carries a random identifier common to the set and a three-word RS1024 checksum used for detection; the shared data include a digest of the secret verified on reconstruction. L304: "As SLIP39 does", a hash of the secret is shared with it. | unverified — source not on disk | Agrees with the auditor's knowledge of SLIP-0039. The digest there is a truncated HMAC-SHA256 keyed with a random value, stored as a digest share; "a digest of the secret" is a fair summary. No reason to doubt. |
| `sskr` | yes | L104–105: "SSKR uses the same identifier and digest." L109–111: one of three formats that defend against mixing sets; decodes each share on its own. | unverified — source not on disk | The round-two note is resolved: the sentence no longer implies an RS1024 checksum. To the auditor's knowledge SSKR's identifier is 16 bits where SLIP39's is 15, so "the same" means the same kind. No reason to think the characterisation inaccurate. |
| `shamir39` | yes | L105–106: "writes Shamir shares in BIP39 words with no correction." L110–111: among "all of these formats" that decode each share on its own. | unverified — source not on disk | New in this version. Agrees with the auditor's recollection of the Shamir39 draft (parameter words plus share words, no error correction). The paper correctly leaves Shamir39 out of the list that defends against mixed sets. No reason to doubt. |
| `bip93` | yes | L106–109: codex32 shares bech32 strings with a set identifier and a BCH checksum able to correct a few character substitutions; the checksum is linear, so shares derived by interpolation stay valid. | unverified — source not on disk | Agrees with the auditor's knowledge of BIP-93 (correction of up to 4 substitutions). No reason to doubt. |
| `mceliece1981sharing` | yes | L115–117: Shamir shares form a Reed–Solomon codeword, so m shares tolerate floor((m−t)/2) wrong ones. L274: column code of distance m−t+1. | unverified — source not on disk | Standard result. |
| `tompa1989how` | yes | L117–119: a participant who lies about a share can steer the reconstruction undetected; forgery made detectable by restricting the set of legal secrets. | unverified — source not on disk | Agrees with the auditor's knowledge of the paper. No reason to doubt. |
| `rabin1989verifiable` | yes | L119–121 and L661–662: robust and verifiable sharing gives stronger guarantees against malicious parties (out of scope). | unverified — source not on disk | Agrees with the auditor's knowledge. No reason to doubt. |
| `rabin1989efficient` | yes | L121–122: spreading one codeword among parties without fresh randomness is information dispersal. | unverified — source not on disk | Agrees with the auditor's knowledge. No reason to doubt. |
| `blakley1985security` | yes | L122–124: with partial secrecy, a ramp scheme. | unverified — source not on disk | No reason to doubt. |
| `franklin1992communication` | yes | L122–124: cited with Blakley–Meadows for ramp schemes. | unverified — source not on disk | The paper is known for packed secret sharing, which has ramp-type secrecy. The citation is indirect but not wrong. |
| `elias1954error` | yes | L125: product codes go back to Elias. L275: distances of a product multiply. | unverified — source not on disk | Standard attribution. |
| `schmidt2009collaborative` | yes | L125–127: decoding several Reed–Solomon words whose errors share positions is studied as interleaved Reed–Solomon decoding. | unverified — source not on disk | Matches the title. No reason to doubt. |
| `patterson1988case` | yes | L127–130: "Disk arrays use the same arithmetic: our first two parity checks are the plain sum and the position-weighted sum that a dual-parity array stores." | unverified — source not on disk | Specific reason for doubt, carried from round two: to the auditor's knowledge this paper defines RAID levels 1–5 and has no dual-parity array. It supports "plain sum" (single parity) only. See flags.md, non-critical. |
| `plank1997tutorial` | yes | Same sentence, L127–130. | unverified — source not on disk | To the auditor's knowledge the tutorial treats general n+m Reed–Solomon coding with a Vandermonde matrix and has a published correction (Plank and Ding, 2005). It supports "the same arithmetic"; it does not describe a two-checksum array in those words. Non-critical. |
| `sugiyama1975method` | yes | L166: Euclidean key-equation solver. | unverified — source not on disk | Standard attribution; `Parity39/RS.lean` L42, L60–72 implements the extended-Euclid solver. |
| `forney1965decoding` | yes | L167–168: error-value formula. | unverified — source not on disk | Standard attribution; `Parity39/RS.lean` L82–92. |

Verdict counts: supports 1, does-not-support 0, partial 0, unverified 21.
