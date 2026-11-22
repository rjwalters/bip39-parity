# bip39-parity

Reed–Solomon parity words for BIP39 mnemonics: an **N+k** scheme that lets a
phrase survive wrong, swapped, dropped, extra and unreadable words.

Status: experimental draft. No BIP number is assigned (numbers are allocated by
the BIP editors on submission, not chosen by authors). Do not protect real funds
with this yet.

## The scheme

- A BIP39 word is one 11-bit symbol, i.e. one element of GF(2¹¹)
  (polynomial x¹¹ + x² + 1, generator α = x).
- A protected phrase is `N` data words followed by `k` parity words, `N + k ≤ 2047`.
- The word at 0-based position `p` has locator `αᵖ`. The phrase is valid when
  all `k` syndromes vanish:

      Sⱼ = Σₚ wordₚ · α^(p·j) = 0      j = 0 … k-1

  `S₀` is the XOR of all words (RAID 5's P), `S₁` is RAID 6's Q, and so on.
- The code is systematic: the first `N` words are untouched. If they are a valid
  BIP39 mnemonic, any existing wallet can use them and ignore the tail.
- Guarantee: `e` wrong words and `s` known-missing words are corrected whenever
  `2e + s ≤ k`.

Swaps, dropped words and extra words are not symbol errors, so `repair`
enumerates those edits, lets the decoder accept or reject each hypothesis, and
returns every candidate with the fewest edits. For BIP39 data, the SHA-256
checksum bits are an extra filter. More than one candidate is reported as
ambiguous, never silently resolved.

## Use

    lake build
    lake exe parity39 encode -k 3 legal winner thank year wave sausage worth useful legal winner thank yellow
    lake exe parity39 check  -k 3 <15 words>
    lake exe parity39 repair -k 3 <words, ? for a word you cannot read>

`--raw` treats the data words as arbitrary symbols (no BIP39 checksum);
`--data N` sets the data length explicitly. Words may be shortened to four letters.

Lean compiles to C: the generated sources are in `.lake/build/ir/` after a build.

## Measured behaviour

`lake exe tests [trials]` runs the unit tests (field axioms, SHA-256 and BIP39
reference vectors, RS within capacity for k = 1…8) and a fault-injection table.
Summary of 200 trials per cell, percentage where the single correct phrase is
returned, without / with the BIP39 checksum filter:

| Fault | 12+2 | 12+3 | 12+4 | 24+2 | 24+3 | 24+4 |
|---|---|---|---|---|---|---|
| 1 wrong word | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 |
| 2 unreadable (`?`) | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 |
| adjacent swap | 94 / 100 | 100 / 100 | 100 / 100 | 87 / 100 | 100 / 100 | 100 / 100 |
| swap, any two | 96.5 / 100 | 100 / 100 | 100 / 100 | 84.5 / 99.5 | 100 / 100 | 100 / 100 |
| 1 dropped word | 99 / 100 | 100 / 100 | 100 / 100 | 99.5 / 100 | 100 / 100 | 100 / 100 |
| 1 extra word | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 | 100 / 100 |
| 2 dropped words | 0 / 1 | 96 / 99.5 | 100 / 100 | 0 / 30 | 82 / 100 | 100 / 100 |
| 1 wrong + 1 dropped | refused | 92.5 / 99.5 | 100 / 100 | refused | 76 / 99.5 | 100 / 100 |
| 2 wrong words | refused | refused | 100 / 100 | refused | refused | 100 / 100 |

Where the result is not unique it is almost always *ambiguous* (the right phrase
is among the candidates shown). The dangerous outcome, offering only a wrong
phrase, appeared only for faults beyond a k = 2 code's capacity, without the
BIP39 filter, in 0.5–1.5% of trials.

## Not secret sharing

Splitting a high-parity phrase among several parties is a *ramp* scheme, not
Shamir: every word a party holds reveals 11 bits of the secret. See the notes in
the design discussion before using it that way.

## Layout

- `Parity39/GF.lean`, `Poly.lean` — GF(2¹¹) and polynomial arithmetic
- `Parity39/RS.lean` — syndromes, errors-and-erasures decoder, encoder
- `Parity39/Bip39.lean`, `Sha256.lean`, `Wordlist.lean` — BIP39 layer
- `Parity39/Repair.lean` — edit-hypothesis search
- `Main.lean` — CLI; `Tests.lean` — tests and fault injection
- `data/english.txt` — the BIP39 English wordlist (from bitcoin/bips)
