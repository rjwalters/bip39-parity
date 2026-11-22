# Citation audit for parity39.2

Files read: `parity39.2/main.tex` (the only file with `\cite`; `figures/grid.tex` and
`figures/rates.tex` contain none), `parity39.2/refs.bib` (byte-identical to
`parity39/refs.bib`), `parity39/refs/ambati2026-soups-extract.txt`.

## Resolution

- Distinct keys cited: 21. Entries in `refs.bib`: 21.
- Unresolved keys: 0. Uncited entries: 0.
- Compiled bibliography (`main.bbl`): 21 `\bibitem`s; no undefined-citation warning in the
  final pass; no `??` in the PDF text.

## Claim support

Only one cited source is on disk (`ambati2026notall`). All others are recorded as
unverified. The Notes column says where the auditor has a specific reason, from general
knowledge of the cited document, to think a characterisation is accurate or loose. Those
remarks are not verifications.

| Key | Resolved | Surrounding claim (main.tex line) | Verdict | Notes |
|---|---|---|---|---|
| `ambati2026notall` | yes | L53–57: controlled study; 40% could not reproduce an assigned 12-word BIP39 phrase after three days, 49% after seven; of the 41 failed attempts, the 14 the authors could recover by bounded search were all one wrong word, or one wrong word plus a change of order. L641–642: the study measures recall from memory, not copying. | supports | Extract L609–612: BIP-39 success 60% at three days, 51% at seven, so 40% and 49% failed (the paper's figures are the complements). L641–643: 14 of the 41 users who failed BIP-39 authentication (34.1%). Table 4 (L650–670): 10 rows "1 wrong word", 4 rows "1 wrong word, 1 flipped order". Lab RCT, N = 92, system-assigned 12-word phrases (L41–42, L269). Three wording points, none changing the numbers: the 41 are participants, not attempts; the study says "we theoretically recover 14 users" under a time limit of 168.5 minutes (L639–641), which the paper renders as "could recover by bounded search"; the study does not describe the other 27 failures. |
| `bip39` | yes | L42: wordlist has 2048 = 2^11 entries. L58: checksum 4 bits for 12 words, 8 for 24. L91–92: truncated SHA-256 checksum appended to the entropy before cutting into 11-bit words; detection only. | unverified — source not on disk | Consistent with the repository's own implementation (`Parity39/Bip39.lean` L15–28: `cs = words/3` bits from the first byte of SHA-256) and with `data/english.txt` (2048 words, checked). |
| `reed1960polynomial` | yes | L45: Reed–Solomon codes add redundancy. L146: the code has minimum distance k+1. | unverified — source not on disk | Standard result. |
| `shamir1979how` | yes | L46: Shamir's scheme spreads a secret over several phrases. L262: each data column is Shamir's scheme. | unverified — source not on disk | Standard result. |
| `moura2021lean` | yes | L75: implementation in Lean 4. | unverified — source not on disk | Tool citation. |
| `polyseed` | yes | L92–94: one Reed–Solomon check word over a 2048-element field in a 16-word phrase. | unverified — source not on disk | Agrees with the auditor's knowledge of the Polyseed README. No reason to doubt. |
| `slip39` | yes | L98–101: shares bytewise over GF(2^8); each share carries a random identifier common to the set and a three-word RS1024 checksum used for detection; shared data include a digest of the secret verified on reconstruction. L295: "As SLIP39 does", a hash of the secret is shared with it. | unverified — source not on disk | Agrees with the auditor's knowledge of SLIP-0039 (15-bit identifier, 3-word RS1024 checksum, digest share at x = 254). The digest there is an HMAC-SHA256 keyed with a random value and truncated to 4 bytes, over the shared (encrypted) master secret; "a digest of the secret" is a fair summary. |
| `sskr` | yes | L101–102: "SSKR follows the same design." L105–107: one of "all three" that defend against mixing sets and decode each share on its own. | unverified — source not on disk | Loose in one respect. SSKR shares over GF(2^8), carries a 16-bit set identifier and inherits the digest check from its Shamir layer, but to the auditor's knowledge it has no RS1024 checksum: its Bytewords text encoding carries a CRC-32. "The same design" can be read to include the checksum. See flags.md, non-critical. |
| `bip93` | yes | L102–105: codex32 shares bech32 strings with a set identifier and a BCH checksum able to correct a few character substitutions; the checksum is linear, so shares derived by interpolation stay valid. | unverified — source not on disk | Agrees with the auditor's knowledge of BIP-93 (4-character identifier, 13-character BCH checksum, up to 4 substitutions corrected). The paper does not attribute a secret digest to codex32, which is right. |
| `mceliece1981sharing` | yes | L111–113: Shamir shares form a Reed–Solomon codeword, so m shares tolerate floor((m−t)/2) wrong ones. L266: column code of distance m−t+1. | unverified — source not on disk | Standard result. |
| `tompa1989how` | yes | L113–115: a participant who lies about a share can steer the reconstruction undetected; forgery made detectable by restricting the set of legal secrets. | unverified — source not on disk | Agrees with the auditor's knowledge of the paper. The round-one wording concern is resolved. |
| `rabin1989verifiable` | yes | L115–117: robust and verifiable sharing gives stronger guarantees against malicious parties. L635–636: verifiable sharing addresses a cheating dealer or a holder who knows the secret. | unverified — source not on disk | General attribution; no reason to doubt. |
| `rabin1989efficient` | yes | L117–118: spreading one codeword among parties without fresh randomness is information dispersal. | unverified — source not on disk | Agrees with the auditor's knowledge of the IDA paper. |
| `blakley1985security` | yes | L119: with partial secrecy, a ramp scheme. | unverified — source not on disk | No reason to doubt. |
| `franklin1992communication` | yes | L119–120: same sentence (ramp scheme). | unverified — source not on disk | Franklin–Yung is the usual citation for packed sharing, which is a ramp construction. |
| `elias1954error` | yes | L121: product codes go back to Elias. L267: distances of a product multiply. | unverified — source not on disk | Standard attribution. |
| `schmidt2009collaborative` | yes | L121–123: decoding several Reed–Solomon words whose errors share positions is studied as interleaved Reed–Solomon decoding. | unverified — source not on disk | No reason to doubt. |
| `patterson1988case` | yes | L123–125: "Disk arrays use the same arithmetic: our first two parity checks are the P and Q checks of a dual-parity array." | unverified — source not on disk | Loose. To the auditor's knowledge Patterson, Gibson and Katz define RAID levels 1–5 and no dual-parity (P+Q) array. The round-one error (parity words called P and Q blocks) is fixed: the sentence now speaks of parity checks, matching `Parity39/RS.lean` L11–12. See flags.md, non-critical. |
| `plank1997tutorial` | yes | L123–125: same sentence. | unverified — source not on disk | Plank's tutorial covers Reed–Solomon coding for RAID-like systems in general. The names P and Q come from the RAID-6 literature, not from this tutorial, and the tutorial's construction has a published correction (Plank and Ding, 2005). The paper does not rely on the construction. |
| `sugiyama1975method` | yes | L161: Euclidean key-equation solver. | unverified — source not on disk | Matches the implementation (`Parity39/RS.lean` L60–72). |
| `forney1965decoding` | yes | L162–163: error-value formula. | unverified — source not on disk | Matches the implementation (`Parity39/RS.lean` L82–92). |

Totals: 1 supports, 0 does-not-support, 0 partial, 20 unverified.

## refs.bib completeness

Every entry has author, title, year and a venue or URL. Remaining defects, none blocking:

- Capitals in titles are not brace-protected, so `plainnat` prints "On decoding bch codes",
  "reed-solomon" (twice), "reed–solomon", "(raid)", "raid-like", "The lean 4 theorem prover"
  and "goppa codes" (`main.bbl` L44, L67, L75, L89, L97, L142, L160).
- `blakley1985security` and `moura2021lean` have no publisher or series (Springer LNCS 196
  and LNCS 12699).
- `ambati2026notall` has no page range.
- `schmidt2009collaborative` has a literal Unicode en dash in the title. It compiles under
  the current class.
- `tompa1989how`: volume 1, number 3, 1989 agrees with the auditor's recollection of the
  journal record; some bibliographies give 1988.
