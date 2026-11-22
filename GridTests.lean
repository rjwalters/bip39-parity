import Parity39

open Parity39 Parity39.Grid

/-! Fault-injection experiments for grid shares (Shamir across cards, parity along each). -/

def randSym : IO UInt16 := return (← IO.rand 0 2047).toUInt16

def randBytes (n : Nat) : IO ByteArray := do
  let mut b := ByteArray.empty
  for _ in [0:n] do
    b := b.push (← IO.rand 0 255).toUInt8
  return b

def randRow (n : Nat) : IO (Array UInt16) := do
  let mut r : Array UInt16 := #[]
  for _ in [0:n] do
    r := r.push (← randSym)
  return r

def randPositions (n count : Nat) : IO (Array Nat) := do
  let mut ps : Array Nat := #[]
  for _ in [0:10000] do
    if ps.size ≥ count then break
    let p ← IO.rand 0 (n - 1)
    if !ps.contains p then ps := ps.push p
  return ps

structure Scenario where
  name : String
  /-- only `t` cards survive (otherwise all `n`) -/
  minimal : Bool := false
  /-- exact number of cards in hand (overrides `minimal`) -/
  count : Option Nat := none
  /-- chance per word, in thousandths, of being replaced by a wrong word -/
  wordErr : Nat := 0
  /-- cards replaced by random words -/
  garbage : Nat := 0
  /-- cards replaced by the same-numbered card of a different dealing -/
  foreign : Nat := 0
  /-- length of an unreadable block on every card -/
  burn : Nat := 0
  /-- every card has a 50% chance of one dropped word -/
  drops : Bool := false
  /-- card numbers are legible -/
  labels : Bool := true
  /-- two words exchanged on every card -/
  swap : Bool := false

structure Tally where
  ok : Nat := 0
  wrong : Nat := 0
  deriving Inhabited

def Tally.add (t : Tally) (truth : Array UInt16) (got : Option (Array UInt16)) : Tally :=
  match got with
  | none => t
  | some s => if s.extract 0 truth.size == truth then { t with ok := t.ok + 1 }
              else { t with wrong := t.wrong + 1 }

def pct (x total : Nat) : String :=
  let t := x * 1000 / total
  let s := s!"{t / 10}.{t % 10}"
  "".pushn ' ' (6 - s.length) ++ s

/-- Checksum-only baseline: a card counts only if it is exactly valid as written. -/
def detectOnly (p : Params) (cards : Array Card) : Option (Array UInt16) := Id.run do
  let offset := headerOffset p
  let mut rows : Array Row := #[]
  for c in cards do
    if c.toks.size == p.width && c.toks.all Option.isSome then
      let suffix := match c.label with
        | some i => some (header i p.t)
        | none => none
      match RS.decode p.k (c.toks.push suffix) 0 with
      | some d =>
        let hd := d.codeword[p.width]!
        if validHeader p hd then
          rows := rows.push { index := headerIndex hd, verified := true, notes := #[],
                              cells := (applyHeader p offset (d.codeword.extract 0 p.width) hd).map some }
      | none => pure ()
  if rows.size < p.t then return none
  return some (fromSubset p (rows.extract 0 p.t))

/-- Per-card parity only: repair each card alone, then use the first `t` that repaired. -/
def rowsOnly (p : Params) (all : Array Row) : Option (Array UInt16) :=
  let rows := all.filter (·.verified)
  if rows.size < p.t then none else some (fromSubset p (rows.extract 0 p.t))

/-- Per-card parity plus the digest: the first `t`-subset of repaired cards whose
reconstruction passes the digest. No cross-card decoding. -/
def rowsDigest (p : Params) (all : Array Row) : Option (Array UInt16) := Id.run do
  let rows := all.filter (·.verified)
  if rows.size < p.t then return none
  for sub in Repair.combos rows.size p.t do
    let cand := fromSubset p (sub.map (rows[·]!))
    if digestOk p cand == some true then return some cand
  return none

def runScenario (p : Params) (n trials : Nat) (sc : Scenario) : IO (Array Tally) := do
  let seedWords := p.nData - p.digest
  let mut tallies : Array Tally := #[{}, {}, {}, {}, {}]
  for _ in [0:trials] do
    let mkDeal : IO (Array UInt16 × Array (Array UInt16)) := do
      let some seed := Bip39.fromEntropy (← randBytes (seedWords * 4 / 3)) | throw (IO.userError "entropy")
      let mut rand : Array (Array UInt16) := #[]
      for _ in [0:p.t - 1] do
        rand := rand.push (← randRow p.nData)
      let some cards := deal p (seed ++ digestWords p.digest seed) rand n | throw (IO.userError "deal")
      return (seed, cards)
    let (seed, printed) ← mkDeal
    let (_, other) ← mkDeal
    let present ← match sc.count with
      | some m => randPositions n m
      | none => if sc.minimal then randPositions n p.t else randPositions n n
    let mut cards : Array Card := #[]
    for slot in [0:present.size] do
      let i := present[slot]!
      let mut words := printed[i]!
      let mut intactOnly := false
      if slot < sc.garbage then
        words ← randRow p.width
        intactOnly := true
      else if slot < sc.garbage + sc.foreign then
        words := other[i]!
        intactOnly := true
      let mut toks : Array (Option UInt16) := words.map some
      if !intactOnly then
        for j in [0:toks.size] do
          if (← IO.rand 0 999) < sc.wordErr then
            let bad ← randSym
            toks := toks.set! j (some (if bad == words[j]! then bad ^^^ 1 else bad))
        if sc.swap then
          let ab ← randPositions toks.size 2
          let a := toks[ab[0]!]!
          toks := (toks.set! ab[0]! toks[ab[1]!]!).set! ab[1]! a
        if sc.burn > 0 then
          let start ← IO.rand 0 (p.width - sc.burn)
          for j in [start:start + sc.burn] do
            toks := toks.set! j none
        if sc.drops && (← IO.rand 0 1) == 1 then
          toks := toks.eraseIdx! (← IO.rand 0 (toks.size - 1))
      cards := cards.push { toks, label := if sc.labels then some (i + 1) else none }
    -- shuffle so that bad cards are not always entered first
    let order ← randPositions cards.size cards.size
    cards := order.map (cards[·]!)
    let noDigest := { p with digest := 0 }
    tallies := tallies.set! 0 (tallies[0]!.add seed (detectOnly p cards))
    let rows := readCards p cards
    tallies := tallies.set! 1 (tallies[1]!.add seed (rowsOnly p rows))
    tallies := tallies.set! 2 (tallies[2]!.add seed (combineRows noDigest rows).secret)
    tallies := tallies.set! 3 (tallies[3]!.add seed (combineRows p rows).secret)
    tallies := tallies.set! 4 (tallies[4]!.add seed (rowsDigest p rows))
  return tallies

def scenarios : List Scenario := [
  { name := "all cards, 1% word errors", wordErr := 10 },
  { name := "all cards, 3% word errors", wordErr := 30 },
  { name := "all cards, 5% word errors", wordErr := 50 },
  { name := "all cards, 10% word errors", wordErr := 100 },
  { name := "only t cards, 1% word errors", minimal := true, wordErr := 10 },
  { name := "only t cards, 3% word errors", minimal := true, wordErr := 30 },
  { name := "only t cards, 5% word errors", minimal := true, wordErr := 50 },
  { name := "all cards, one is garbage, 1%", wordErr := 10, garbage := 1 },
  { name := "all cards, 5 words burnt on each", burn := 5 },
  { name := "all cards, 8 words burnt on each", burn := 8 },
  { name := "all cards, dropped words, 3%", wordErr := 30, drops := true },
  { name := "all cards, one from another set", foreign := 1 },
  { name := "only t cards, one from another set", minimal := true, foreign := 1 },
  { name := "all cards, numbers illegible, 3%", wordErr := 30, labels := false },
  { name := "all cards, one swap on each", swap := true },
  { name := "all cards, one swap on each, 3%", wordErr := 30, swap := true },
  { name := "only t cards, one swap on each", minimal := true, swap := true }]

/-- `gridtests custom <trials> <k> <t> <n> <cards in hand>…` -/
def custom (args : List String) : IO UInt32 := do
  let nums := args.filterMap String.toNat?
  let (trials :: k :: t :: n :: hands) := nums | do IO.eprintln "custom <trials> <k> <t> <n> <m>…"; return 2
  let p : Params := { k, t, nData := 26, digest := 2 }
  IO.println s!"{t}-of-{n}, {p.width}-word cards (k = {k}), {trials} trials; % correct / % wrong (rest refused)"
  IO.println "                                      checksum only |  card parity  | parity+digest | grid, no dig. | grid + digest"
  for m in hands do
    let list : List Scenario := [
      { name := s!"{m} cards, 1% word errors", wordErr := 10 },
      { name := s!"{m} cards, 3% word errors", wordErr := 30 },
      { name := s!"{m} cards, 5% word errors", wordErr := 50 },
      { name := s!"{m} cards, one is garbage, 1%", wordErr := 10, garbage := 1 },
      { name := s!"{m} cards, one from another set", foreign := 1 },
      { name := s!"{m} cards, 5 burnt words on each", burn := 5 }]
    for sc in list do
      let ts ← runScenario p n trials { sc with count := some m }
      let cell (x : Tally) := s!"{pct x.ok trials} /{pct x.wrong trials}"
      IO.println s!"  {sc.name}{"".pushn ' ' (36 - sc.name.length)}{cell ts[0]!} | {cell ts[1]!} | {cell ts[4]!} | {cell ts[2]!} | {cell ts[3]!}"
      (← IO.getStdout).flush
  return 0

def main (args : List String) : IO UInt32 := do
  IO.setRandSeed 39
  if args.head? == some "custom" then return ← custom args.tail
  let trials := (args.head?.bind String.toNat?).getD 300
  let only := args.getD 1 ""
  for (t, n) in [(2, 3), (3, 5)] do
    let p : Params := { k := ((args.getD 2 "").toNat?).getD 4, t, nData := 26, digest := 2 }
    IO.println ""
    IO.println s!"{t}-of-{n}, 24 seed + 2 digest + {p.k} parity words per card, {trials} trials per row; % correct / % wrong (rest refused)"
    IO.println "                                      checksum only |  card parity  | parity+digest | grid, no dig. | grid + digest"
    for sc in scenarios.filter (fun sc => only.isEmpty || (sc.name.splitOn only).length > 1) do
      let ts ← runScenario p n trials sc
      let cell (x : Tally) := s!"{pct x.ok trials} /{pct x.wrong trials}"
      IO.println s!"  {sc.name}{"".pushn ' ' (36 - sc.name.length)}{cell ts[0]!} | {cell ts[1]!} | {cell ts[4]!} | {cell ts[2]!} | {cell ts[3]!}"
      (← IO.getStdout).flush
  return 0
