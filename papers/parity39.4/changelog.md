# Changelog — parity39.4 (revised from parity39.3)

Critic siblings consumed: `parity39.3.review/` (36/44, advance true, no critical flags) and
`parity39.3.audit/` (1 critical flag, which is why a further version was required).

## Audit critical flag
| Flag | Change |
|---|---|
| "both methods without a digest" contradicted Table 2 (three methods have no digest; two returned the wrong secret) | §5.3 now names them: card parity and the grid decoder without a digest. The cause is stated as an inference, not a logged fact. |

## Other changes (audit notes and review items T2, T6, T9, T10)
| Item | Change |
|---|---|
| T2 wrong-number claim unqualified | §4.2 adds the capacity cost (one of ⌊k/2⌋ symbols, k ≥ 2), what happens beyond capacity, and that no experiment enters a wrong number. No new scenario was run. |
| T6 "repair" stated flat | §5.2 and the conclusion give "at least 99.5% of trials"; the unclear "one parity word more" sentence is replaced by the unfiltered ranges (k = 2 swaps 84.5–96.5%; k = 3 two-edit rows 76–96%). |
| T9 referents | Abstract names the grid decoder with its digest; §8 names the 31,600 total; study size (92) given. |
| T10 nits | Prop. 1(a) "same number and threshold"; S0 caveat; swap-estimate conclusion phrased under its assumption and in terms of candidates; rescue step agrees with another unconfirmed card; wallet sentence. |
| Audit: decoder step 5 | Subsets are tested whenever the first check fails, as in the code. |
| Audit: dual-parity sentence | Reworded to what the cited sources support (single parity sum; Reed–Solomon extension for multiple failures). |

## Not changed
T1 (source not published: author only), T3 (positioning against brute-force recovery tools), T4
(length and repeated caveats), T5 (naming drift), T7 (float placement), T8 (URL revisions in
refs.bib). No experiments were rerun; tables and figure are unchanged from version 3.
