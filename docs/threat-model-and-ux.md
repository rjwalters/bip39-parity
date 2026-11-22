# Storing a 256-bit secret: threat model and UX flow

Draft, 2026-11-22. Synthesised from three research reports (threat model, state
of the art, human factors). Their sources were fetched by the research agents,
not re-checked here; figures marked (vendor) come from vendor-run surveys, and
figures marked (thin) rest on one source or on analogy.

Scope: one person keeping a 256-bit value (wallet seed, password-manager root
key, disk or backup recovery key) usable for 10 to 30 years, with no vendor in
the loop.

## 1. What the evidence says

1. **People lose secrets more often than they have them stolen.** In one survey
   35% of holders had lost access to a wallet or account and 31% of those never
   got back in (vendor). Only 15% had ever tested a recovery (vendor).
2. **Theft follows digitisation, not burglary.** The LastPass 2022 vault theft
   is still producing thefts years later, and the victims had stored seed
   phrases in the vault. Malware has shipped in both app stores that reads
   photo galleries for mnemonics. About 80,000 people had personal wallets
   compromised remotely in 2025, against roughly 70 known physical attacks.
3. **Memory is not storage.** About half of people cannot recall an assigned
   12-word phrase after a week. No study covers unrehearsed recall over years.
4. **Failures are near misses.** Failed recalls are mostly one wrong word, or
   one wrong word plus an order flip. Recovery tools exist specifically to
   search swaps, missing words and misread words. This is the case error
   correction serves. There are no published per-word error rates for
   handwritten word lists (thin).
5. **Without a vendor there is no short PIN.** Apple, Google, Signal and
   WhatsApp all protect a low-entropy secret with hardware that allows about
   ten guesses. A no-vendor design cannot do that, so the stored artefact must
   carry the full entropy itself.
6. **Every mass-market system ends in a printed high-entropy code** typed by
   hand with little or no error tolerance (Apple 28 characters, Signal 64,
   WhatsApp 64 digits, 1Password's Emergency Kit).
7. **Splitting schemes fail in practice** through implementation bugs, shares
   that cannot be verified or revoked, and holders who die or move. Trezor
   moved its default back to a single share.
8. **Recovery is the dangerous moment.** The user is stressed, the secret is
   whole on one device, and fake-support phishing targets exactly this step.
9. **Coercion is rare but mostly succeeds** (about 66% of recorded attacks), and
   decoy or duress wallets have no evidence of working.
10. **Few holders plan for death**: a quarter to a half have any plan (vendor).

## 2. Threat model

### Goals by use case

| Use | If stolen | If lost | Weight |
|---|---|---|---|
| Wallet seed | Irreversible, instant | Irreversible | Both terminal |
| Password-manager root | Needs the vault too; credentials can be rotated | Painful, often recoverable site by site | Availability first |
| Disk or backup key | Needs the ciphertext too | Data gone | Availability first |

### Adversaries

| Adversary | Reach | Who should plan for it |
|---|---|---|
| Remote opportunistic: stealers, photo-OCR malware, bulk phishing, breach crackers | Anything ever digitised | Everyone |
| Remote targeted: impersonates vendor, heir or share holder | Uses leaked customer lists | Anyone on such a list |
| Household or visitor | Minutes alone, a phone camera | Everyone |
| Determined burglar | Hours, opens safes | Known holders |
| Coercive | Defeats anything one person can unlock alone | Public or identifiable large holders |
| Legal process | Safe-deposit boxes, lawyers, custodians | Depends on jurisdiction |
| Future | Decades of compute against anything copied today | Everyone |

A raw 256-bit secret is safe against brute force and against known quantum
search. The exposure is in weak passphrases, weak key stretching, and partial
knowledge leaked by shares.

### Threats

| Threat | Likelihood over 10–30 years | Mitigation | Cost of the mitigation |
|---|---|---|---|
| Forget the secret, its passphrase or where it is | High | Written copy plus instructions | More to steal |
| Backup never made or never tested | High | Forced verification and drill | Friction; exposure during the test |
| Copy or ordering error | Medium | Parity words | Longer phrase |
| Fire, water, decay | Low to medium per site | Punched steel, second site | More copies |
| Death or incapacity | Medium to high | Heir letter, executor | Earlier disclosure |
| Lost context (what is this, which tool) | Medium | Self-describing artefact | Tells a finder what it is |
| Digitised copy stolen | High if digitised | Never digitise | Loses convenient redundancy |
| Phishing at recovery | Medium | Offline recovery, never from an inbound request | Friction |
| Household access | Low to medium | Split, or passphrase kept elsewhere | More loss risk |
| Burglary | Low | Split across sites | "Where is it" loss |
| Coercion | Very low for most, material for large known holders | Nothing recoverable from one place quickly | Slow legitimate access |
| Bad randomness or tampered device | Low | Vetted generator, user-added dice | Complexity |
| Share holders collude or are duped | Low to medium | Real threshold scheme, holders unknown to each other | Lower availability |
| Shares lost over time | Medium to high | Margin, periodic audit, re-split procedure | Audit effort |

### The loss/theft trade

Every measure moves risk between the columns. More copies, digitising and
written passphrases reduce loss and raise theft. Memorising, splitting and
distance reduce theft and raise loss. Parity words are the exception: they
reduce loss and cost nothing in confidentiality.

## 3. Design rules that follow

1. **Never digitise the phrase.** No screenshots, clipboard, cloud, photos or
   networked printers, and never a password-only online vault.
2. **Parity on every written copy.** Default **24+4**: guaranteed repair of any
   two wrong words, or four unreadable ones. (The earlier 24+3 suggestion is
   superseded: the fourth word buys the two-wrong-word guarantee and matters
   most for non-BIP39 secrets, which have no checksum to help.)
3. **Never correct silently.** Show position, old word and new word; ask for
   confirmation; check the result against an independent fingerprint.
4. **Verification is not optional.** Full re-entry from each physical copy, then
   a wipe-and-restore drill, before the secret is used for anything.
5. **Memory is never the only copy of anything.** A passphrase is an optional
   second secret, written down, stored apart from the words and reachable by
   the executor.
6. **The artefact describes itself**: scheme and version, "24+4", set
   identifier, date, a short fingerprint, and the note that words 1–24 are a
   standard BIP39 phrase.
7. **Splitting is for theft of a single copy, not a default.** See section 5.
8. **Recovery runs offline** and is never started because someone asked.
9. **Inheritance is part of setup**, not a later project.

## 4. UX flow

| Stage | What the person does | What the software enforces |
|---|---|---|
| 1. Generate | Runs the tool on an offline or hardware device | Vetted randomness; no user-chosen words; shows 24 words, then 4 "repair words" in a separate block |
| 2. Record | Writes on a pre-numbered card, one word per cell, block capitals | Card carries set ID, date, "24+4", version and fingerprint; steel copies punch position plus first four letters |
| 3. Verify | Hides the screen, types all 28 words back from each copy | No skip; differences shown position by position; copy fixed and re-entered until clean |
| 4. Drill | Wipes the device and restores from one copy; covers two words to watch a repair | No address or key export until the drill passes |
| 5. Distribute | Places copies in separate sites; fills a location sheet (places, never words) | Refuses two copies at one address; passphrase copy kept apart from every word copy |
| 6. Check | Yearly: copy is present, sealed and legible. Every 3–5 years: full re-entry offline | Any repair needed marks that copy degraded: rewrite and re-verify |
| 7. Recover | Enters what survives, `?` for unreadable words | Shows every change; confirms against the fingerprint; ambiguous results are listed, never chosen |
| 8. Inherit | Keeps a plain-language letter: what exists, where, who holds what, the steps | Letter never contains the secret; names an executor |
| 9. Rotate | On suspected exposure, a move, a death or a holder falling out | New set ID; old copies destroyed against a checklist before rotation is marked complete |

### Tiers

Value bands are rough guides, not thresholds.

| | Everyday | Serious | High-value |
|---|---|---|---|
| Typical use | Password-manager root, disk key, small wallet | Savings-scale holdings | Life-changing sums, or a publicly known holder |
| Encoding | 24+4 (12+4 if 128 bits is enough) | 24+4 | 24+4 on every copy or share |
| Copies | 2 paper | 3: one punched steel, two paper | One steel per share or key, plus a paper index |
| Sites | Home and one other | 3, at least one fire-independent | 3 or more, nothing complete at home |
| Passphrase | No | Optional, written, stored apart | Yes, or multisig where the asset allows |
| Splitting | No | No | Yes: real secret sharing or multisig |
| Full re-entry | Every 5 years | Every 3 years and after a move | Yearly, one share in rotation |
| Heirs | One-page letter | Letter and named executor | Letter, executor, rehearsed |

For coercion the only measure with support is that nothing is recoverable from
one place quickly, which the upper two tiers get from separation alone. No
decoy feature is proposed.

## 5. Splitting a high-parity phrase among holders

The idea: make a 24+k phrase with large k and hand different word subsets to
different people. It works, but as a *ramp* scheme with a fixed limitation.

- Any 24 words recover the secret.
- A coalition holding h words faces 256 − 11h bits. Holding 12 words leaves
  124 bits; holding 19 leaves 47, which is breakable.
- So "can recover" (24 words) and "learns nothing useful" (about 11 words or
  fewer) are 13 words apart, whatever k is.

Consequences:

- **24+24 in four 12-word shares** is a clean 2-of-4: one holder faces 124
  bits, any two recover, but with no error margin left in that pair.
- **Finer thresholds do not work.** With 6-word shares, four holders recover
  and three face only 58 bits.
- For anything other than 2-of-n, use Shamir (SLIP39, codex32) or multisig, and
  add parity words *inside each share* so a damaged share is still usable.
  That combination, correction within a share and a threshold across shares,
  is the part existing schemes lack.

Advantages over Shamir that remain: shares are half the secret's length instead
of full length, and a mis-copied share is caught by the code. Disadvantages:
below-threshold holders learn real bits, and (as with Shamir) a share cannot be
revoked without re-splitting.

## 6. Prior art

- **Polyseed** (Monero): one Reed–Solomon check word over GF(2048); corrects a
  single known-missing word. The closest ancestor.
- **SLIP39**: three RS1024 check words, detection only by policy.
- **codex32 (BIP-93)**: real correction, but over bech32 characters.
- No published BIP39-compatible scheme with multi-word parity correcting wrong
  words at unknown positions was found (thin: a handful of targeted searches).

## 7. What this means for the prototype

1. Make k=4 the documented default.
2. Add a self-describing header: version, N+k, set ID, short fingerprint.
3. Add "one wrong word plus one swap" and row/column order exchange to the
   fault table; neither is measured yet.
4. Measure miscorrection beyond capacity for non-BIP39 data.
5. Add a `drill` / `verify` mode that needs only the fingerprint.
6. Specify per-share parity for use with SLIP39 or Shamir shares.
7. Decide whether a passphrase should be verifiable (catches typos) or not
   (keeps deniability); BIP39 and SLIP39 chose not.

## 8. Open questions

- Real per-word error rates for handwriting and for punched steel. A study of
  about 100 people copying 28 words and reading them back weeks later would
  settle the choice of k.
- Whether forced verification drives people to shortcuts such as photographing
  the card.
- How often to re-enter: each check exposes the secret to a device.
- Whether a one-page printed description of the decoding algorithm is enough
  for recovery in 30 years.
- Long-run reliability of trusted contacts: no longitudinal data exists.
