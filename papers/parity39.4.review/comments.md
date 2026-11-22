# Comments — parity39.4

Line numbers are `parity39.4/main.tex`. `U<n>` labels match `verdict.md`; `T<n>` are round-three labels.

## Blocker

None.

## Major

- **U1 — §8 Reproducibility, L705-709** "The tree is not yet published at a public address." Unchanged. The 15 SHA-256 digests in `refs/experiments/README.txt` match the working tree (re-hashed this pass), but a reader cannot fetch the tree, the logs or the README, and the README's base commit is "plus uncommitted changes". Fix: publish the repository and cite URL and commit, or archive sources, wordlist, logs and README and cite the archive. Needs the author.
- **U2 — §4.2 L296-302 and §5.1 L404** The mislabelled-card paragraph is now accurate (see the check below), and says no experiment enters a wrong number. The behaviour therefore rests on code reading alone. Fix: add a mislabelled-card scenario to `gridtests` and report it as a row of Table 2. Other scope points stand as stated limits: one seed, independent uniform substitutions, no foreign card with illegible numbers.

## Minor

- **U2 residue — §4.2 L300-301** "A mislabelled card that does not repair alone is kept as unconfirmed evidence under the number entered." True when the card has the right count of words (`Grid.readCard`: `c.toks.size == p.width`), which step 1 of §4.4 says and this sentence does not. Two further consequences are unstated: a card whose corrected number equals that of a card already read is dropped (`readCards`), and a card kept under a wrong number enters the column stage at the wrong evaluation point with the wrong header term subtracted from its parity words. Neither can produce a wrong secret past the digest. One clause each would do.
- **U3 `related-work` — §1 L54-63, §2 L93-111** Not changed. Bounded search against the BIP39 checksum or a known address repairs the same near misses the introduction cites, and the cited study uses it. Say what parity words give that search does not (no address needed, no wallet-specific derivation, a bound on ambiguity). Reviewer recall, not checked online; a `paper-litsearch` run should cover this cluster.
- **U4 — repetition and length** Not changed. No-wrong-secret: L35, L566-567, L585, L608, L739. Exactly-t caveat: abstract L34-35, §1 L79-80, §5.3, §5.4 L575-577, §6 (twice), §7, §9 L739-741. Assumed-rate caveat: L52-54, L86-88, L677-679, L699. 13 pages against the brief's 10. State each once in full and point to it; drop the sentence from the captions of Tables 3 and 4.
- **U5 — naming** Not changed. Per-card repair: "repairing cards separately" (L32), "Card parity" (L409), "per-card repair" (L518), "one at a time" (L526), "per-card methods" (L546), "card by card" (L737). "Checksum only" (L406) is a parity check; "checksum" elsewhere is BIP39's. "Row" is an unwritten coefficient row in §4.1, a card in §4.4 (L331) and at L576 ("no spare rows"), and a table row in §5. "holders" as the unit of m (L261); "burnt" for a destroyed card (L643) against the defined run of unreadable words; "hash check" (L84) for the digest.
- **U6 — floats and tables** Not changed. Fig. 2 prints on page 9 and is discussed on page 7 (float-proximity tool: 2 pages). Table 1 prints inside §5.3. The Table 1 column heads and "A 24+2 phrase" (L200) use N+k without a gloss. The cells for two dropped words at k = 2 (0 / 1 and 0 / 30) are neither a repair nor a refusal and §5.2 does not say that the rest was ambiguous. Fig. 2 plots three methods and does not say the two digest variants coincide with them. Fig. 1 side labels touch the dashed boxes.
- **U7 — §4.2 L300-301** "kept as unconfirmed evidence": "unconfirmed" and "confirmed" are defined in step 1 of §4.4 (L333-335), after this use. Add "(Section 4.4, step 1)" or move the sentence into step 1.
- **U7 — §1 L56** "Of the 41 participants who failed (of 92)": 41 of 92 is 45%, between the 40% and 49% in the previous sentence, and nothing says the 41 pools the three-day and seven-day groups. Write "Of the 41 participants who failed at either interval (of 92 in all)".
- **U7 — §5.2 L436-437** "at $k=3$ the two-edit rows in 76--96\%": the label is new and undefined. §3.2 L187 counts "edits plus substitutions" as different things, so a wrong word plus a dropped word is one edit there; and "two wrong words" at k = 3 is also a two-fault row but is refused. Name the rows: "two dropped words, or a wrong word plus a dropped word".
- **U7 — §5.3 L561-562** "the one wrong answer in these runs": the preceding paragraph reports wrong answers in the foreign-card rows of the same runs. Write "the one wrong answer outside the foreign-card rows".
- **U7 — §4.2 L301-302** "Our experiments never enter a wrong number." repeats §5.1 L404 ("Card numbers are otherwise given correctly") in the construction section, before the experiments exist. Keep it in §5.1 and point to it, or fold it into the limits list in §7.
- **U7 — abstract L35** "the grid decoder with its digest": the introduction calls the same thing "a hash check on the shared secret" (L84) and the term is defined in §4.3. Use one word in all three places, or gloss it once in the abstract.
- **U8 — `refs.bib`** Not changed. `bip39`, `slip39`, `bip93`, `polyseed`, `sskr`, `shamir39` cite moving URLs with no revision or access date; `ambati2026notall` has no pages.

## Nit

- **U9 — §7 L686-687** "says a better decoder exists for some patterns": give one pattern that Proposition 1(d) covers and the decoder refuses.
- **U9 — §5.3 L567-570** The pooled bound of about 1e-4 mixes scenarios of different risk; the per-cell bound (0.75%) is the one a reader should carry for the exactly-t, 5% cell.
- §5.2 L431 "Everything inside the capacity is repaired, as it must be" and L435 "in each case uniquely in at least 99.5\% of trials" now sit two sentences apart; say that the 99.5 cells are edits outside the capacity guarantee.
- L111 / L113 "word level" / "word-level"; L394 / L516 "per word" / "per-word"; L398 / L518 "per card" / "per-card" (reader-flow lint).

## Check of each changed sentence (diff of `parity39.3/main.tex` against `parity39.4/main.tex`, 14 hunks)

| Lines | Change | Checked against | Result |
|---|---|---|---|
| L35 | "the grid decoder with its digest returned no wrong secret" | Column 5 of all 102 rows in the six grid logs | Accurate: 0 wrong in every row |
| L56 | "(of 92)" | Study extract: N = 92; 26 + 15 failed BIP-39 | Accurate; wording under U7 |
| L128-131 | Disk-array sentence | `RS.syndromes`: S_j evaluates at α^j, so S_0 is the plain sum | Accurate for the code; claims no dual-parity array of the cited sources |
| L165 | "the user can enter the first N words into any existing wallet" | Encoding is systematic (§3.1) | Accurate |
| L195-196 | S_0 "nonzero unless the two wrong words err by the same value" | In characteristic 2 a swap adds the same value at both positions, so S_0 is the sum of the two error values | Accurate |
| L202-203 | "under this assumption ... among its cheapest candidates" | Expectation 325·26/2047 = 4.13 | Follows as stated; now conditional |
| L257 | "same number and threshold" | Header encodes number and threshold (`header i p.t`) | Accurate |
| L298-302 | Capacity cost, beyond-capacity behaviour, no trial | `Repair.repair` (`maxErrors`, note on error at position ≥ n), `Grid.readCard`, `GridTests.lean` L143 (true number or none) | Accurate; residue under U2 |
| L346-347 | "agrees with another unconfirmed card" | `rescue`: `!o.verified && o.index != row.index` | Accurate |
| L350-352 | Subsets tested whenever the first check fails | `combineRows`: subsets tried if `p.digest > 0`, with no condition on the count of confirmed cards | Accurate; bound C(m,t)+1 unchanged |
| L434-437 | "at least 99.5%"; 84.5-96.5%; 76-96% | `single-phrase.txt` | Accurate; label under U7 |
| L561-565 | Cause as inference; two methods named | `grid-main-k4.txt` L31 | Accurate; resolves the audit flag |
| L724 | "The total of 31,600 trials" | 34·400 + 20·300 + 48·250 | Accurate |
| L734-736 | Conclusion: 99.5%, "in all of them" | `single-phrase.txt`: filtered swap and dropped word at k = 2 are 100, 100, 100, 99.5 and 100; two wrong words at k = 4 are 100 in four cells | Accurate |

Tables 1-4 and `figures/` are byte-identical to version 3 (`diff`), `refs.bib` likewise.

## Abstract and conclusion against the tables

- 99.5% against 31% (3-of-5, all five cards, 10%): Table 2 and log 99.5 and 30.5.
- 61% against 41% (2-of-3, all three cards, 10%): 61.2 and 40.7.
- "With exactly t cards joint decoding adds nothing": the lower half of Table 2 has identical card-parity and grid columns in every non-foreign row.
- Conclusion "runs of unreadable words that defeat repair card by card": 0 against 89.7 / 98.2.

## Pre-flight results

- `numeric_consistency`: 9 warnings, none real. Six `percent_mismatch` hits (L439, L491-493, L505-506) read table cells as fractions. Three `quoted_variant` hits: 88 / 85 at L577-578 against 86 at L539 are different configurations; 98.8 at L644 against 99 at L579 are different configurations.
- `pending_marker`: no markers.
- `evidence_drift`: CLEAN.
- `audience_check`: 0 hits. No public repository URL declared or derived.
- `reader_flow_lint`: `per-word` / `per word`, `per-card` / `per card` variants and symbol-order hits inside §4.1; the spelling variants are listed under Nit.
- `float_proximity`: Figure 2, two pages from first reference (U6).
- `evidence_check` on `scoring.md`: pass, 9 dimensions, no findings.
- render-gate: skipped, `parity39.4.audit/compile-log.txt` not present; `main.log` read by hand (13 pages, no overfull box, no undefined reference).
- `score_history`: not appended, because this pass was instructed not to edit `parity39.4/`.

## Reader-flow lens: confirmation

The lens (`parity39.4.readerflow/`) returned 9 major, 33 minor, 5 nit. Recurrence against version 3: 18 of 31 (0.581), above the 0.5 guide; this revision was not a flow revision and left naming, repetition and float placement alone. Each finding was read against the text.

Class 1, confirmed in the body (count toward the dim 7 cap): 2, both new in this version.
- "unconfirmed evidence under the number entered" (L300-301) before its definition (U7).
- "Of the 41 participants who failed (of 92)" (L56): referent of the 41 against the two rates (U7).

Class 1, not confirmed as define-before-use for this audience, kept as suggestions (same judgments as round three where the text is unchanged):
- "card", "spare card", "product code", "24+2": as in round three; the Table 1 gloss is under U6.
- "the unprinted header" (L85): the bullet two lines above says "one unprinted symbol that carries its number".
- "31,600 trials" (L35): the count has its object; §8 now names it. A clause in §5.3 saying the total includes Tables 3 and 4 would help.
- "digest" and "edit" in the abstract, "secret" before §4.1, card design not named in the abstract: abstract-level, ordinary sense; "digest" is under U7.
- Table 1 two-dropped cells: a table explanation gap, under U6.

Class 5: "Across all 31,600 grid trials" (L566) before Tables 3 and 4, and "Our experiments never enter a wrong number" (L301) in the construction: confirmed as minor (U7 for the second).

Classes 2, 4, 6, 7, 9: confirmed and folded into U5, U6, U4. Number variants (86 / 93 beside 92.5; 83% in §6 against 85% in §5.4 for the same configuration run twice; "60--67%" for 59.7 and 67) are as in round three.
