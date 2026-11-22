import Parity39

open Parity39

/-! Unit tests plus a fault-injection harness that measures repair outcomes. -/

def check (name : String) (ok : Bool) : IO Bool := do
  IO.println s!"{if ok then "pass" else "FAIL"}  {name}"
  return ok

def randSym : IO UInt16 := return (← IO.rand 0 2047).toUInt16

def randBytes (n : Nat) : IO ByteArray := do
  let mut b := ByteArray.empty
  for _ in [0:n] do
    b := b.push (← IO.rand 0 255).toUInt8
  return b

def hexBytes (s : String) : ByteArray := Id.run do
  let cs := s.toList.toArray
  let v (c : Char) : Nat := if c.isDigit then c.toNat - 48 else c.toNat - 87
  let mut b := ByteArray.empty
  for i in [0:cs.size / 2] do
    b := b.push (v cs[2 * i]! * 16 + v cs[2 * i + 1]!).toUInt8
  return b

/-- `count` distinct random positions below `n`. -/
def randPositions (n count : Nat) : IO (Array Nat) := do
  let mut ps : Array Nat := #[]
  for _ in [0:1000] do
    if ps.size ≥ count then break
    let p ← IO.rand 0 (n - 1)
    if !ps.contains p then ps := ps.push p
  return ps

def unitTests : IO Bool := do
  let mut ok := true
  -- field
  ok := (← check "alpha has order 2047 = 23 * 89"
    (GF.pow 2 2047 == 1 && GF.pow 2 23 != 1 && GF.pow 2 89 != 1)) && ok
  ok := (← check "every nonzero element has an inverse"
    ((Array.range 2047).all fun i => GF.mul (i + 1).toUInt16 (GF.inv (i + 1).toUInt16) == 1)) && ok
  let mut ring := true
  for _ in [0:20000] do
    let a ← randSym
    let b ← randSym
    let c ← randSym
    ring := ring && GF.mul a b == GF.mul b a
      && GF.mul a (GF.mul b c) == GF.mul (GF.mul a b) c
      && GF.mul a (b ^^^ c) == (GF.mul a b ^^^ GF.mul a c)
      && GF.mul a b < 2048
  ok := (← check "multiplication is commutative, associative, distributive (sampled)" ring) && ok
  -- sha256
  ok := (← check "sha256(\"\")" (Sha256.hex (Sha256.hash ByteArray.empty)
    == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")) && ok
  ok := (← check "sha256(\"abc\")" (Sha256.hex (Sha256.hash "abc".toUTF8)
    == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")) && ok
  -- bip39 reference vectors
  ok := (← check "wordlist has 2048 words" (Wordlist.words.size == 2048)) && ok
  let vectors := [
    ("00000000000000000000000000000000",
     "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"),
    ("7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f",
     "legal winner thank year wave sausage worth useful legal winner thank yellow"),
    ("80808080808080808080808080808080",
     "letter advice cage absurd amount doctor acoustic avoid letter advice cage above"),
    ("ffffffffffffffffffffffffffffffff",
     "zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo wrong"),
    ("0000000000000000000000000000000000000000000000000000000000000000",
     "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art")]
  for (ent, phrase) in vectors do
    let got := (Bip39.fromEntropy (hexBytes ent)).map Wordlist.render
    let ws := (phrase.splitOn " ").toArray.filterMap Wordlist.lookup
    ok := (← check s!"bip39 vector {ent.take 8}… ({ws.size} words)"
      (got == some phrase && Bip39.checksumOk ws == some true)) && ok
  -- reed–solomon: everything within 2e + s ≤ k must decode to the original
  let mut rsOk := true
  let mut trials := 0
  for k in [1:9] do
    for n' in [1, 12, 24, 40] do
      for _ in [0:40] do
        let mut data : Array UInt16 := #[]
        for _ in [0:n'] do
          data := data.push (← randSym)
        let some c := RS.encode k data | rsOk := false
        rsOk := rsOk && RS.isCodeword k c && c.extract 0 n' == data
        let s ← IO.rand 0 k
        let e ← IO.rand 0 ((k - s) / 2)
        let ps ← randPositions c.size (s + e)
        let mut recv : Array (Option UInt16) := c.map some
        for i in [0:ps.size] do
          if i < s then
            recv := recv.set! ps[i]! none
          else
            let bad ← randSym
            recv := recv.set! ps[i]! (some (if bad == c[ps[i]!]! then bad ^^^ 1 else bad))
        match RS.decode k recv with
        | some d => rsOk := rsOk && d.codeword == c && d.errors.size == e && d.erasures.size == s
        | none => rsOk := false
        trials := trials + 1
  ok := (← check s!"RS corrects e errors + s erasures whenever 2e + s ≤ k ({trials} trials, k = 1…8)" rsOk) && ok
  return ok

/-! ## Fault injection -/

inductive Fault
  | wrong (count : Nat)
  | adjacentSwap
  | anySwap
  | dropped (count : Nat)
  | wrongAndDropped
  | extra
  | unreadable (count : Nat)

def Fault.name : Fault → String
  | .wrong 1 => "1 wrong word"
  | .wrong c => s!"{c} wrong words"
  | .adjacentSwap => "adjacent swap"
  | .anySwap => "swap, any two words"
  | .dropped 1 => "1 dropped word"
  | .dropped c => s!"{c} dropped words"
  | .wrongAndDropped => "1 wrong + 1 dropped"
  | .extra => "1 extra word"
  | .unreadable c => s!"{c} unreadable (marked ?)"

def substitute (toks : Array (Option UInt16)) (p : Nat) : IO (Array (Option UInt16)) := do
  let bad ← randSym
  return toks.set! p (some (if some bad == toks[p]! then bad ^^^ 1 else bad))

/-- Returns `none` when the fault happens to be a no-op (e.g. swapping equal words). -/
def inject (f : Fault) (c : Array UInt16) : IO (Option (Array (Option UInt16))) := do
  let n := c.size
  let toks : Array (Option UInt16) := c.map some
  match f with
  | .wrong count =>
    let mut t := toks
    for p in ← randPositions n count do
      t ← substitute t p
    return some t
  | .adjacentSwap =>
    let i ← IO.rand 0 (n - 2)
    if c[i]! == c[i + 1]! then return none
    return some ((toks.set! i (some c[i + 1]!)).set! (i + 1) (some c[i]!))
  | .anySwap =>
    let ps ← randPositions n 2
    if c[ps[0]!]! == c[ps[1]!]! then return none
    return some ((toks.set! ps[0]! (some c[ps[1]!]!)).set! ps[1]! (some c[ps[0]!]!))
  | .dropped count =>
    let ps ← randPositions n count
    return some ((Array.range n).filter (!ps.contains ·) |>.map (toks[·]!))
  | .wrongAndDropped =>
    let ps ← randPositions n 2
    let t ← substitute toks ps[0]!
    return some ((Array.range n).filter (· != ps[1]!) |>.map (t[·]!))
  | .extra =>
    let p ← IO.rand 0 n
    let w ← randSym
    return some (toks.insertIdx! p (some w))
  | .unreadable count =>
    let mut t := toks
    for p in ← randPositions n count do
      t := t.set! p none
    return some t

structure Tally where
  unique : Nat := 0     -- exactly the right phrase
  ambiguous : Nat := 0  -- right phrase offered alongside others
  wrong : Nat := 0      -- only wrong phrase(s) offered: silent miscorrection
  none : Nat := 0       -- refused

def pct (x total : Nat) : String :=
  let t := x * 1000 / total
  let s := s!"{t / 10}.{t % 10}%"
  "".pushn ' ' (7 - s.length) ++ s

def runTrials (nData k trials : Nat) (f : Fault) (requireBip39 : Bool) : IO Tally := do
  let mut t : Tally := {}
  let mut done := 0
  for _ in [0:trials * 4] do
    if done ≥ trials then break
    let some data := Bip39.fromEntropy (← randBytes (nData * 4 / 3)) | continue
    let some c := RS.encode k data | continue
    let some toks ← inject f c | continue
    done := done + 1
    let cands := Repair.repair k c.size toks requireBip39
    if cands.isEmpty then t := { t with none := t.none + 1 }
    else if !cands.any (·.phrase == c) then t := { t with wrong := t.wrong + 1 }
    else if cands.size == 1 then t := { t with unique := t.unique + 1 }
    else t := { t with ambiguous := t.ambiguous + 1 }
  return t

def faultTable (trials : Nat) : IO Unit := do
  let faults := [Fault.wrong 1, .wrong 2, .unreadable 2, .adjacentSwap, .anySwap, .dropped 1,
    .dropped 2, .wrongAndDropped, .extra]
  for nData in [12, 24] do
    for k in [2, 3, 4] do
      IO.println ""
      IO.println s!"{nData}+{k}   ({trials} trials per row)      parity only               | parity + BIP39 checksum"
      IO.println "                            unique  ambig.   wrong refused |  unique  ambig.   wrong refused"
      for f in faults do
        let a ← runTrials nData k trials f false
        let b ← runTrials nData k trials f true
        let row (t : Tally) := s!"{pct t.unique trials} {pct t.ambiguous trials} {pct t.wrong trials} {pct t.none trials}"
        IO.println s!"  {f.name}{"".pushn ' ' (25 - f.name.length)}{row a} | {row b}"

def main (args : List String) : IO UInt32 := do
  IO.setRandSeed 39
  let ok ← unitTests
  if !ok then
    IO.println "unit tests FAILED"
    return 1
  let trials := (args.head?.bind String.toNat?).getD 100
  if trials > 0 then faultTable trials
  return 0
