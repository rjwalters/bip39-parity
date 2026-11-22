import Parity39.RS
import Parity39.Bip39
import Parity39.Wordlist

/-!
# Phrase repair

Reed–Solomon handles wrong words and known-missing words algebraically. Humans
also make *synchronisation* mistakes (swap two words, drop a word, write one
twice), which shift or permute symbols. Those are handled by enumerating edit
hypotheses, letting the RS decoder accept or reject each one, and keeping the
candidates with the fewest total edits. When the data part is a BIP39 phrase,
its SHA-256 checksum bits are used as an additional, independent filter.
-/

namespace Parity39.Repair

structure Candidate where
  phrase : Array UInt16
  /-- Number of edits: each substitution, swap, restored word or removed word counts 1. -/
  cost : Nat
  notes : Array String
  /-- BIP39 checksum of the data words, if they have a BIP39 length. -/
  bip39 : Option Bool
  /-- Decoded values of the unprinted suffix symbols (see `repair`). -/
  virt : Array UInt16 := #[]
  deriving Inhabited

/-- All sorted `d`-element subsets of `{0, …, n-1}`. -/
def combos (n d : Nat) : Array (Array Nat) := Id.run do
  let mut acc : Array (Array Nat) := #[#[]]
  for _ in [0:d] do
    let mut next : Array (Array Nat) := #[]
    for c in acc do
      let lo := match c.back? with
        | some x => x + 1
        | none => 0
      for x in [lo:n] do
        next := next.push (c.push x)
    acc := next
  return acc

private structure Hypothesis where
  recv : Array (Option UInt16)
  cost : Nat
  notes : Array String
  /-- Erased positions that stand for a word the hypothesis says was dropped. -/
  restored : Array Nat := #[]
  isSwap : Bool := false

private def q (w : UInt16) : String := s!"'{Wordlist.word w}'"

private def hypotheses (n : Nat) (toks : Array (Option UInt16)) (maxEdits : Nat) :
    Array Hypothesis := Id.run do
  let len := toks.size
  let mut hs : Array Hypothesis := #[]
  if len == n then
    hs := hs.push { recv := toks, cost := 0, notes := #[] }
    for i in [0:n] do
      for j in [i + 1:n] do
        match toks[i]!, toks[j]! with
        | some a, some b =>
          if a != b then
            let recv := (toks.set! i (some b)).set! j (some a)
            hs := hs.push { recv, cost := 1, notes := #[s!"swapped words {i + 1} and {j + 1}"],
                             isSwap := true }
        | _, _ => pure ()
  else if len < n && n - len ≤ maxEdits then
    -- `n - len` words were dropped: choose where the gaps are
    for gaps in combos n (n - len) do
      let mut recv : Array (Option UInt16) := #[]
      let mut src := 0
      for p in [0:n] do
        if gaps.contains p then
          recv := recv.push none
        else
          recv := recv.push toks[src]!
          src := src + 1
      hs := hs.push { recv, cost := n - len, notes := #[], restored := gaps }
  else if len > n && len - n ≤ maxEdits then
    -- extra words: choose which to remove
    for extra in combos len (len - n) do
      let mut recv : Array (Option UInt16) := #[]
      let mut notes : Array String := #[]
      for p in [0:len] do
        if extra.contains p then
          let what := match toks[p]! with
            | some w => q w
            | none => "unreadable word"
          notes := notes.push s!"removed extra {what} at position {p + 1}"
        else
          recv := recv.push toks[p]!
      hs := hs.push { recv, cost := len - n, notes }
  return hs

/--
Find the phrases of `n` words (`n - k` data + `k` parity) closest to `toks`.
`none` tokens are known-missing or unreadable words. Returns every candidate of
minimal edit cost; more than one means the repair is ambiguous.

With `requireBip39`, candidates whose data words fail the BIP39 checksum are
discarded before the minimum is taken.
-/
def repair (k n : Nat) (toks : Array (Option UInt16)) (requireBip39 : Bool)
    (maxEdits : Nat := 3) (suffix : Array (Option UInt16) := #[]) : Array Candidate := Id.run do
  -- `suffix` holds symbols that belong to the codeword but are not printed
  -- (positions n, n+1, …): `some v` if known from elsewhere, `none` to solve for.
  let mut found : Array Candidate := #[]
  let mut best := maxEdits + k + 1
  for h in hypotheses n toks maxEdits do
    if h.cost > best then continue
    -- A swap is invisible to S₀ and there are n(n-1)/2 of them, so a swap plus
    -- further substitutions is only accepted when two syndromes stay in reserve.
    let maxErrors := if h.isSwap then (k - 2) / 2 else k
    match RS.decode k (h.recv ++ suffix) maxErrors with
    | none => pure ()
    | some d =>
      let mut notes := h.notes
      for p in d.erasures do
        if p < n then
          let verb := if h.restored.contains p then "restored dropped word" else "filled in"
          notes := notes.push s!"{verb} {q d.codeword[p]!} at position {p + 1}"
      for p in d.errors do
        if p < n then
          notes := notes.push
            s!"replaced {q (h.recv[p]!.getD 0)} with {q d.codeword[p]!} at position {p + 1}"
        else
          notes := notes.push "the card's label does not match its words"
      let cand : Candidate :=
        { phrase := d.codeword.extract 0 n, cost := h.cost + d.errors.size, notes,
          bip39 := Bip39.checksumOk (d.codeword.extract 0 (n - k)),
          virt := d.codeword.extract n d.codeword.size }
      if requireBip39 && cand.bip39 != some true then
        pure ()
      else
        best := min best cand.cost
        match found.findIdx? (fun c => c.phrase == cand.phrase && c.virt == cand.virt) with
        | some i => if cand.cost < found[i]!.cost then found := found.set! i cand
        | none => found := found.push cand
        -- an exactly valid phrase cannot be beaten or tied by any edit
        if cand.cost == 0 then return #[cand]
  return found.filter (·.cost == best)

end Parity39.Repair
