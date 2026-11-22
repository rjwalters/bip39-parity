---
title: "Parity Words and Grid Shares: Error-Correcting Mnemonics and Secret Sharing over the BIP39 Wordlist"
author: "Robb Walters"
venue: "arXiv"
anonymous: false
claim: "Treating each BIP39 word as one symbol of GF(2^11) gives a backup format in which a written phrase repairs its own wrong, swapped, dropped and unreadable words, and in which Shamir shares are themselves repairable phrases that are decoded jointly, so a split secret survives damage that defeats per-share checksums."
keywords:
  - BIP39
  - mnemonic
  - Reed-Solomon codes
  - secret sharing
  - product codes
  - key backup
documentclass: anvil-paper
---

# Brief: parity words and grid shares for BIP39

Audience: wallet and key-management engineers, and applied cryptographers who
know BIP39, Shamir sharing and the basics of Reed-Solomon codes. Whitepaper
length (about 10 pages). Not double-blind.

## Motivation

A 256-bit secret that no vendor can reset has to be written down in full and
read back correctly years later. BIP39 detects a mistake but cannot repair one,
and the documented failures are near misses: one wrong word, two words out of
order. Shamir-style splitting multiplies the number of hand-copied artefacts and
gives each one only a detection checksum, so reliability gets worse exactly
where the value is highest.

## Claim

One BIP39 word is one element of GF(2^11). Appending k Reed-Solomon parity words
to a phrase corrects e wrong and s missing words when 2e + s <= k, leaves the
original mnemonic untouched, and with a small edit search also repairs swaps,
dropped and extra words. Sharing such phrases word-wise with Shamir's scheme
yields cards that are each a valid parity phrase and jointly a product code.

## Strongest claim

**Strongest honest statement**: Because the BIP39 wordlist is already a
2048-symbol alphabet, error correction and threshold sharing can live in the
same field, and then they compose: any t of n cards recover the secret, fewer
reveal nothing, every card repairs itself, and spare cards repair each other.
In fault injection the combined decoder never returned a wrong secret, and it
recovers from damage (five consecutive unreadable words on every card; a card
from a different dealing) where per-card checks recover nothing or return a
wrong secret.

**Why surprising or generative**: Deployed formats pick one of the two.
SLIP39 and codex32 put a checksum on each share but decode shares independently;
Polyseed corrects one erasure in an unshared phrase. The McEliece-Sarwate
observation that Shamir shares are a Reed-Solomon codeword has been known since
1981 but is not used at the human-transcription layer, where the errors are.

**What it could inspire**: transcription-error studies that measure the word
error rates the design needs; a packed variant with 12-word cards; formal proofs
of the decoder in Lean; a BIP-style specification.

**Demonstrated / derived / synthesis / conjecture**:
- *Demonstrated*: the fault-injection tables in `refs/experiments/` produced by
  the Lean implementation (single phrase; 2-of-3, 3-of-5, 3-of-6, 4-of-9 grids).
- *Derived*: the 2e + s <= k capacity; card linearity; perfect secrecy below
  threshold; product-code distance (k+1)(m-t+1); ramp leakage of 11 bits per
  word when a single phrase is split.
- *Synthesis*: Reed-Solomon, Shamir, product codes and a hash digest are all
  inherited. New is their arrangement on the BIP39 alphabet, the unprinted
  header symbol, and the edit-hypothesis repair with refusal on ambiguity.
- *Conjecture*: that 1-5% per-word error rates bracket real handwriting; that
  k = 4 (k = 6 when no spare card is expected) is the right default.

**Opening**: lead with "shares that repair themselves and each other", then the
single-phrase result as the building block.

**Reader should remember**: put the redundancy where the human errors are, in
the same field as the sharing, and never let a linear code have the last word:
a hash digest decides.

**Excluded for focus**: the full UX flow and tiering (kept in
`docs/threat-model-and-ux.md`), comparison with keytool's prime-field index
embedding, the packed ramp variant beyond a mention, passphrase handling.

## Method (sketch)

Implementation: Lean 4, `Parity39/*.lean` (about 900 lines), compiled to native
code through C. GF(2^11) with x^11 + x^2 + 1; syndromes at alpha^0..alpha^(k-1);
Sugiyama/Chien/Forney errors-and-erasures decoder; edit-hypothesis repair;
grid dealing, joint row/column decoding, digest check.

## Experiments

`refs/experiments/*.txt` are verbatim harness outputs (fixed random seed 39),
each headed by the command that produced it. No handwriting data exists; error
rates are parameters.

## Related work

BIP39, SLIP39, codex32 (BIP-93), Polyseed; Shamir; McEliece-Sarwate; Tompa-Woll
(cheater detection); Blakley-Meadows and Franklin-Yung (ramp / packed sharing);
Elias (product codes); Schmidt-Sidorenko-Bossert (interleaved RS); Ambati et al.
SOUPS 2026 (BIP39 recall failures are near misses).
