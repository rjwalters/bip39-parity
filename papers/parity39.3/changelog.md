# Changelog — parity39.3 (revised from parity39.2)

Critic siblings consumed: `parity39.2.review/` (33/44, advance false, no critical flags),
`parity39.2.audit/` (2 critical flags), `parity39.2.readerflow/`, `.floats/`, `.numeric/`.

## Audit critical flags
| Flag | Change |
|---|---|
| "five grid files" should be six | §8 corrected to six, and says the total includes rows no table prints. |
| Text contradicted Table 1 on refusals at k = 3 | §5.2 rewritten: faults beyond capacity (two wrong words at k ≤ 3; wrong + dropped at k = 2) were refused; caption of Table 1 aligned with footnote a. |

## Review items
| Item | Change |
|---|---|
| S1 no-digest grid quoted selectively, not tabulated | Table 2 gains a "Grid, no digest" column; setup lists five methods; the foreign-card paragraph reports all three regimes (two spares: outvoted; one: refused; none: wrong). |
| S2 source not obtainable | Unchanged: needs the author to publish or archive the tree. Paper states this and pins file digests. |
| S3 false-accept bound | Bound is now (C(m,t)+1)·2^-22 (2.6e-6), stated with the random-hash assumption, placed after the decoder, marked as a design figure not tested by the experiments; per-attempt odds for a holder who alters a card stated. |
| S4 statements contradicting Table 1 | "Two parity words repair a swap" now qualified by the filter, with the unfiltered range; conclusion qualified; caption fixed. |
| S5 file count / untabulated rows | Fixed (see audit flag). |
| S6 evidence scope | Wrong-number behaviour documented in §4.2 (corrected as one wrong symbol and reported); setup states numbers are otherwise given correctly. No new fault scenarios were run; the limits section stands. |
| S7 swap estimate | Rewritten with its premises (S0 invariant, S1 treated as uniform) and the expectation stated as such. |
| S8 Shamir39 | Added to related work. |
| S9 truncation, Table 3 caption, Fig. 1 | Truncation stated in setup; caption names the method; header boxes widened. |
| S10 define-before-use | "Joint decoding" defined in abstract and introduction and tied to the Grid methods; "row decoder" replaced; "numbers illegible" added to the fault list; subset fallback moved into decoder step 5. |
| S11 repetition | Foreign-card paragraph and digest section tightened; floats pinned near their references. |
| S12 minors | Rule of three explained inline; SOUPS wording corrected (participants; "in principle"); SSKR and dual-parity wording corrected; BibTeX capitalisation protected. |

## Evidence changes
None. Tables 2–4 and Figure 2 regenerated from the same logs by `figures/src/tables.py`.
The version-2 changelog understated the 3-of-5 shifts between versions 1 and 2: they were up
to 7.7 points (36.0 → 30.5 in the cell behind the abstract).
