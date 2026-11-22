# Citation audit for parity39.1

Scope: `parity39.1/main.tex` (no `\input` children carry cites; `figures/grid.tex` and
`figures/rates.tex` contain none). 17 distinct cite keys, all resolve in `refs.bib`
(18 entries; `krawczyk2007secret` is never cited). bibtex: 0 warnings, 0 errors.

Sources on disk under `parity39/refs/`: only `ambati2026-soups-extract.txt` (text of the
SOUPS 2026 study) and `experiments/*.txt`. Every other citation is
"unverified — source not on disk"; where the Notes column says more, it is from the
auditor's own knowledge of the cited work and is marked as such, not a verification.

| Key | Resolved | Surrounding claim | Verdict | Notes |
|---|---|---|---|---|
| `ambati2026notall` | yes | L51–54: "40% of participants could not reproduce an assigned 12-word BIP39 phrase after three days and 49% could not after seven; of 41 failures examined, 14 were one wrong word or one wrong word plus two words out of order" | supports (with caveats) | Extract L609–612: BIP-39 recall 60% at 3 days, 51% at 7 days, so 40% / 49% failed. Extract L608–611 (Table 2): 26 + 15 = 41 participants failed BIP-39 of 92. Extract L641–642 and Table 4 (L647–670): 14 of the 41 recoverable; 10 rows "1 wrong word", 4 rows "1 wrong word, 1 flipped order". Caveats: (a) the study tests recall **from memory** of a memorised phrase, not copying or reading back a written one; the sentence does not say so and sits in a paragraph about stored backups. (b) "two words out of order" is the paper's reading of "1 flipped order"; the extract does not define the term. (c) The 14 are the attempts recoverable inside the study's 168.5-minute search budget; the study does not characterise the other 27 failures. (d) The 3-day and 7-day figures come from two different participant groups. Title, authors, venue and URL in `refs.bib` match the extract header (L1–15). |
| `bip39` | yes | L42: wordlist has 2048 = 2^11 entries. L88–89: truncated SHA-256 checksum appended to the entropy before cutting into 11-bit words; detection only. L55: 4 bits for 12 words, 8 for 24 | unverified — source not on disk | Consistent with the implementation (`Parity39/Bip39.lean`, unit tests "wordlist has 2048 words", BIP39 vectors in `single-phrase.txt` L7–12) and with the auditor's knowledge of BIP39. |
| `reed1960polynomial` | yes | L45: RS codes add redundancy. L137–138: valid phrases form an RS code of minimum distance k+1 | unverified — source not on disk | Standard MDS property; no reason to doubt. |
| `shamir1979how` | yes | L46: spreads a secret over several phrases. L224: each data column is Shamir's scheme | unverified — source not on disk | Standard. |
| `moura2021lean` | yes | L73–74: Lean 4 implementation | unverified — source not on disk | Bib entry is typed `@article` with journal "Lecture Notes in Computer Science"; it is the CADE-28 proceedings paper. Metadata only. |
| `polyseed` | yes | L89–91: "one Reed–Solomon check word over a 2048-element field in a 16-word phrase, enough to detect a wrong word or fill in one missing word" | unverified — source not on disk | Matches the auditor's recollection of the Polyseed README (16 words, one checksum word over GF(2048), detects one error or corrects one erasure). No specific reason to doubt. |
| `slip39` | yes | L96–98: shares bytewise over F_{2^8}; three-word RS1024 checksum used for detection | unverified — source not on disk | Matches the auditor's recollection of SLIP-0039. No specific reason to doubt. Note L102: "Our cards use dictionary words" is offered as a contrast with codex32 only; SLIP39 shares are also dictionary words. |
| `bip93` | yes | L98–102: bech32 strings with a BCH checksum correcting up to four character substitutions; checksum linear so interpolated shares stay valid; applied per share, no decoding across shares | unverified — source not on disk | Matches the auditor's recollection of BIP-93 (short checksum corrects up to 4 substitutions). No specific reason to doubt. |
| `mceliece1981sharing` | yes | L106–108: Shamir shares form an RS codeword, so m shares tolerate ⌊(m−t)/2⌋ wrong ones. L228: length-m RS code of distance m−t+1 | unverified — source not on disk | Matches the auditor's knowledge of the paper. No specific reason to doubt. |
| `tompa1989how` | yes | L108–109: "a participant who lies about a share can steer the reconstruction undetected and added a check to the secret" | unverified — source not on disk | First half matches the auditor's knowledge. "Added a check to the secret" is loose: the Tompa–Woll remedy encodes the secret as one of a sparse set of legal values in a larger field (with randomised evaluation points), so a forged reconstruction lands on an illegal value with high probability. Not a checksum on the secret. Imprecise, not wrong; reviser may want to reword. |
| `blakley2007security` | yes | L110–112: splitting one long codeword without fresh randomness is a ramp scheme | unverified — source not on disk | Bib metadata: year 2007 is the Springer online date; the paper is in the CRYPTO '84 proceedings (LNCS 196, 1985). The cite key and rendered year will read "2007". Non-critical bib error. |
| `franklin1992communication` | yes | same sentence as above | unverified — source not on disk | The paper introduces packed secret sharing (for MPC); citing it for "ramp scheme" is acceptable but the BRIEF's own wording ("ramp / packed sharing") is more exact. |
| `elias1954error` | yes | L113: product codes go back to Elias. L229: distances of a product multiply | unverified — source not on disk | Standard attribution. |
| `schmidt2009collaborative` | yes | L113–115: decoding several RS words that share error positions is interleaved RS decoding | unverified — source not on disk | Title matches the claim. |
| `patterson1988case` | yes | L115–117: "The redundancy arithmetic is that of RAID: the first two parity words are the P and Q blocks of a RAID-6 stripe" | unverified — source not on disk; **specific reason to doubt** | (a) Patterson, Gibson and Katz (1988) define RAID levels 1–5 only; RAID-6 and the P+Q scheme are later work, so this citation does not cover the RAID-6 half of the sentence. (b) The correspondence in the implementation is between the *syndromes* and P/Q (`Parity39/RS.lean` L11–12: "S₀ is the plain XOR of all words (RAID-5 'P'); S₁ is the position-weighted sum (RAID-6 'Q')"), not between the two printed parity words and the P and Q blocks. Recorded as a non-critical note because the source is not on disk. |
| `sugiyama1975method` | yes | L151: Euclidean key-equation solver | unverified — source not on disk | Matches `Parity39/RS.lean` L42 and L60–72 (extended Euclid on the key equation). |
| `forney1965decoding` | yes | L152–153: error-value formula | unverified — source not on disk | Matches `Parity39/RS.lean` L82–92 (Forney magnitudes). |

## Unresolved keys

None.

## Uncited bib entries

- `krawczyk2007secret` ("Secret Sharing Made Short"): in `refs.bib`, never cited. Its year (2007) is also the Springer online date; the paper is CRYPTO '93.

## Uncited claims that need a source or a hedge

- L102–103: "Our cards use dictionary words, which resist transcription slips better than character strings" — no citation, no measurement in the paper.
- L543: "There are no published per-word error rates for handwritten word lists" — a negative claim about the literature with no support on disk.
- L178–181: "a 24+2 phrase with two wrong words was 'repaired' to a different valid phrase in 97.6% of trials during development" — see numerical-audit.md; no record on disk.

## Summary

- 17 cite keys, 17 resolved, 0 unresolved.
- 1 verified against an on-disk source (`ambati2026notall`: supports, with caveats).
- 16 unverified — source not on disk. Of these, 1 (`patterson1988case`) is believed inaccurate as characterised, 1 (`tompa1989how`) imprecise.
- 0 does-not-support verdicts.
