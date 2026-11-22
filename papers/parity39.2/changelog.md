# Changelog — parity39.2 (revised from parity39.1)

Critic siblings consumed: `parity39.1.review/` (27/44, advance false, no critical flags),
`parity39.1.audit/` (2 critical flags), `parity39.1.readerflow/`, `.floats/`, `.numeric/`.

## Audit critical flags
| Flag | Change |
|---|---|
| 13–15% swap ambiguity vs 15.5 in the log | Sentence removed; Table 1 now prints the unfiltered and filtered values for every cell (87 and 84.5 unique). |
| Digest text did not match `Grid.digestWords` | §4.3 now states the construction exactly (low 11 bits of each successive big-endian 16-bit group) and gives a test vector (`siege say`). |

## Review items
| Item | Change |
|---|---|
| R1 printed cards are not valid phrases | §4.1 rewritten: the card is defined as a length-(W+1) codeword including header and the vector u; Prop. 1(a) restated with row distance k+1 (number known) and k (unknown); (b)–(d) stated for stripped cards; intro and Fig. 1 caption aligned. |
| R2 foreign-card result confounded digest and joint decoding | New baseline "card parity + digest" added to the harness (`rowsDigest` in `GridTests.lean`) and to Tables 2; §5.3 credits the digest, reports the no-digest grid behaviour; abstract and conclusion reworded. |
| R3 SLIP39 under-described | Related work now states SLIP39's set identifier and digest, SSKR, codex32's identifier, and that all defend against mixed sets; our digest is described as following SLIP39. |
| R4 "never wrong" unbounded | Pooled bound (rule of three) and per-cell bound given, scope stated; the one logged per-card miscorrection is reported. |
| R5 digest | see audit flag. |
| R6 97.6% without artifact | Number removed; replaced by a counting argument (325 swaps × 26/2047). |
| R7 no swap faults on cards | Three swap scenarios added to the harness and reported in Table 2 and §5.3. |
| R8 unreported rows | Dropped-word, illegible-number and garbage rows now in Table 2 with prose. |
| R9 no source pointer | §8 states the tree is unpublished and points to SHA-256 file digests in `refs/experiments/README.txt`. A public URL/commit still needs the author (not resolvable by the reviser). |
| R10 study measures recall | Intro now says so, and that the 14 were those recoverable by bounded search. |
| R11 abstract quotes best cell | Abstract gives 3-of-5, 2-of-3 and the exactly-t case. |
| R12 false-accept probability; step 5 | Union bound over subsets added; step 5 described as decoding the secret row; rescue conditions spelled out. |
| R13 symbols change meaning | L (phrase length), n (cards), D (data words), g (digest words), q (words held), h_i (header) used consistently. |
| R14 define-before-use | "within reach" removed; "secret" defined and distinguished from the BIP39 seed; "dealing", "stripped card", "ambiguous" defined; 30-word card stated at definition; "burn" used throughout; header layout explained; Table captions define 0 = refused. |
| R15 Fig. 1 overprint | Redrawn. |
| R16 related-work gaps | Rabin (IDA), Rabin–Ben-Or, SSKR, Plank added; unsourced words-vs-characters claim removed; RAID-6 statement corrected to parity checks P and Q. |
| Minors | CI half-widths for every trial count; duplicate configurations explained; "unsafe" reworded; bibliography years/types fixed, uncited entry removed; evidence file renamed `grid-main-k4.txt`; Fig. 2 caption corrected. |

## Evidence changes
All grid experiments were rerun with the extended harness (five strategies, three added
scenarios). The 2-of-3 numbers are unchanged; 3-of-5 numbers in the main table and the k = 6, 8
tables differ slightly because the added scenarios shift the random stream. Total grid trials:
31,600. Tables 2–4 and Figure 2 are generated from the logs by `figures/src/tables.py`.
