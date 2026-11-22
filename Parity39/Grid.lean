import Parity39.Repair
import Parity39.Sha256

/-!
# Grid shares: Shamir across cards, Reed–Solomon parity along each card

Picture a grid with one row per card and one column per word position.

* Row 0 is the secret: data words followed by `k` parity words.
* Rows 1 … t-1 (never printed as such) are random, each with its own parity.
* Card `i` is `row₀ + x·row₁ + x²·row₂ + …` evaluated word by word at `x = i`.

Every column is therefore a Shamir sharing of one word (any `t` cards fix it,
`t-1` reveal nothing), and because parity is linear every card is itself a
valid data+parity phrase. Rows repair word-level damage; columns replace lost
or bad cards; the two are decoded together.

## Self-indexing

Each card's codeword has one extra, *unprinted* symbol after the parity words:
a header holding the card's number and the threshold. It costs no words. If the
number written on the card is legible the header is known and the card has its
full correction strength; if not, the header is solved for like one unreadable
word. The secret row has header 0, so it is an ordinary N+k phrase.
-/

namespace Parity39.Grid

structure Params where
  /-- parity words per card -/
  k : Nat
  /-- cards needed -/
  t : Nat
  /-- data words per card: seed words plus digest words -/
  nData : Nat
  /-- digest words inside the data (0 = none) -/
  digest : Nat := 0

def Params.width (p : Params) : Nat := p.nData + p.k

def header (index t : Nat) : UInt16 := (index + 32 * t).toUInt16
def headerIndex (h : UInt16) : Nat := h.toNat % 32
def headerThreshold (h : UInt16) : Nat := h.toNat / 32

def validHeader (p : Params) (h : UInt16) : Bool :=
  headerThreshold h == p.t && headerIndex h ≥ 1

/-- Parity words of the codeword whose only nonzero symbol is a header of 1. -/
def headerOffset (p : Params) : Array UInt16 :=
  match RS.decode p.k
      (Array.replicate p.nData (some 0) ++ Array.replicate p.k none ++ #[some 1]) 0 with
  | some d => d.codeword.extract p.nData p.width
  | none => Array.replicate p.k 0

/-- Add (or, identically, remove) a header's contribution to a row's parity words. -/
def applyHeader (p : Params) (offset : Array UInt16) (row : Array UInt16) (h : UInt16) :
    Array UInt16 :=
  (Array.range row.size).map fun j =>
    if j ≥ p.nData then row[j]! ^^^ GF.mul h (offset.getD (j - p.nData) 0) else row[j]!

/-- `d` words of SHA-256 over the seed words: a non-linear check on any reconstruction. -/
def digestWords (d : Nat) (seed : Array UInt16) : Array UInt16 :=
  let bytes := seed.foldl (fun b w => (b.push (w >>> 8).toUInt8).push w.toUInt8)
    "bip39-parity/digest".toUTF8
  let h := Sha256.hash bytes
  (Array.range d).map fun i => ((h[2 * i]!.toUInt16 <<< 8) ||| h[2 * i + 1]!.toUInt16) &&& 0x7ff

def digestOk (p : Params) (row : Array UInt16) : Option Bool :=
  if p.digest == 0 then none
  else
    let seed := row.extract 0 (p.nData - p.digest)
    some (digestWords p.digest seed == row.extract (p.nData - p.digest) p.nData)

/-- The evaluation point of card `i`. -/
def point (i : Nat) : UInt16 := i.toUInt16

/--
Deal `n ≤ 31` cards. `data` is the secret's data words (seed ++ digest) and
`rand` is `t - 1` rows of uniformly random data words.
-/
def deal (p : Params) (data : Array UInt16) (rand : Array (Array UInt16)) (n : Nat) :
    Option (Array (Array UInt16)) := do
  guard (data.size == p.nData && rand.size + 1 == p.t && n ≤ 31 && p.t ≥ 1)
  let rows ← (#[data] ++ rand).mapM (RS.encode p.k)
  let offset := headerOffset p
  return (Array.range n).map fun i =>
    let x := point (i + 1)
    let row := (Array.range p.width).map fun j => Poly.eval (rows.map (·[j]!)) x
    applyHeader p offset row (header (i + 1) p.t)

/-- Lagrange interpolation through `(xs, ys)`, evaluated at `x`. -/
def interp (xs ys : Array UInt16) (x : UInt16) : UInt16 := Id.run do
  let mut acc : UInt16 := 0
  for i in [0:xs.size] do
    let mut num : UInt16 := 1
    let mut den : UInt16 := 1
    for j in [0:xs.size] do
      if j != i then
        num := GF.mul num (x ^^^ xs[j]!)
        den := GF.mul den (xs[i]! ^^^ xs[j]!)
    acc := acc ^^^ GF.mul ys[i]! (GF.mul num (GF.inv den))
  return acc

/-- A settled column: `t` points that define its polynomial, and how many cards disagreed. -/
structure Column where
  xs : Array UInt16
  ys : Array UInt16
  outvoted : Nat := 0
  deriving Inhabited

def Column.at (c : Column) (x : UInt16) : UInt16 := interp c.xs c.ys x

/--
Decode one column: the degree < t polynomial agreeing with the most cards.
`none` when the column is not settled (too few cards, a tie, or no card beyond
the bare `t` agrees). With exactly `t` cards there is nothing to check against.
-/
def columnDecode (t : Nat) (xs ys : Array UInt16) : Option Column := Id.run do
  let m := xs.size
  if m < t then return none
  if m == t then return some { xs, ys }
  let mut best : Column := { xs := #[], ys := #[] }
  let mut bestPred : Array UInt16 := #[]
  let mut bestAgree := 0
  let mut tie := false
  for sub in Repair.combos m t do
    let sx := sub.map (xs[·]!)
    let sy := sub.map (ys[·]!)
    let pred := xs.map (interp sx sy)
    let agree := (Array.range m).foldl (fun a i => if pred[i]! == ys[i]! then a + 1 else a) 0
    if agree == m then return some { xs := sx, ys := sy }
    if agree > bestAgree then
      best := { xs := sx, ys := sy, outvoted := m - agree }
      bestPred := pred
      bestAgree := agree
      tie := false
    else if agree == bestAgree && pred != bestPred then
      tie := true
  if tie || bestAgree < t + 1 then return none
  return some best

/-- A card as entered: its words (`none` = unreadable) and its number, if legible. -/
structure Card where
  toks : Array (Option UInt16)
  label : Option Nat := none
  deriving Inhabited

/-- A card after the row stage, with the header's contribution removed. -/
structure Row where
  index : Nat
  cells : Array (Option UInt16)
  /-- `true` if the card's own parity confirmed (or repaired) it. -/
  verified : Bool
  notes : Array String
  deriving Inhabited

/-- Repair one card on its own. -/
def readCard (p : Params) (offset : Array UInt16) (c : Card) : Option Row :=
  let suffix := match c.label with
    | some i => #[some (header i p.t)]
    | none => #[none]
  let first := (Repair.repair p.k p.width c.toks false 3 suffix).filter fun cand =>
    validHeader p (cand.virt.getD 0 0)
  -- With no legible number, solving for the header costs one parity word. If that
  -- is not enough, try each possible card number as if it were known: only the
  -- right one leaves the card within reach of its parity.
  let cands :=
    if first.size == 1 || c.label.isSome then first
    else
      let all := (Array.range 31).flatMap fun i =>
        let hd := header (i + 1) p.t
        (Repair.repair p.k p.width c.toks false 3 #[some hd]).filter (·.virt == #[hd])
      let best := all.foldl (fun m cand => min m cand.cost) 1000
      all.filter (·.cost == best)
  if h : cands.size = 1 then
    let cand := cands[0]
    let hd := cand.virt.getD 0 0
    some { index := headerIndex hd, verified := true, notes := cand.notes,
           cells := (applyHeader p offset cand.phrase hd).map some }
  else
    -- Not repairable alone. If we know which card it is, keep its words as
    -- unconfirmed evidence for the column stage.
    match c.label with
    | some i =>
      if c.toks.size == p.width then
        let hd := header i p.t
        let cells := (Array.range p.width).map fun j =>
          c.toks[j]!.map fun w =>
            if j ≥ p.nData then w ^^^ GF.mul hd (offset.getD (j - p.nData) 0) else w
        some { index := i, cells, verified := false,
               notes := #["not repairable on its own; used as unconfirmed evidence"] }
      else none
    | none => none

structure Result where
  /-- The secret row (data ++ parity), if one was accepted. -/
  secret : Option (Array UInt16)
  /-- Digest verdict on `secret` (`none` when the scheme has no digest). -/
  checked : Option Bool
  rows : Array Row
  notes : Array String

def readCards (p : Params) (cards : Array Card) : Array Row := Id.run do
  let offset := headerOffset p
  let mut rows : Array Row := #[]
  for c in cards do
    match readCard p offset c with
    | some r => if !rows.any (·.index == r.index) then rows := rows.push r
    | none => pure ()
  return rows

/-- Rebuild the secret row from `t` complete rows. -/
def fromSubset (p : Params) (rows : Array Row) : Array UInt16 :=
  let xs := rows.map (point ·.index)
  (Array.range p.width).map fun j => interp xs (rows.map (·.cells[j]!.getD 0)) 0

/-- A row's best current knowledge: settled columns override the card's own words. -/
private def rowView (p : Params) (cols : Array (Option Column)) (row : Row) :
    Array (Option UInt16) :=
  let x := point row.index
  (Array.range p.width).map fun j =>
    match cols[j]! with
    | some c => some (c.at x)
    | none => row.cells[j]!

/--
Alternate column and row decoding until nothing changes.
Columns use confirmed cards alone where there are at least `t` of them.
An unconfirmed card is retried with the settled positions filled in.
-/
private def settle (p : Params) (rows : Array Row) (cols : Array (Option Column)) :
    Array Row × Array (Option Column) := Id.run do
  let mut rows := rows
  let mut cols := cols
  for _ in [0:rows.size + 2] do
    let mut changed := false
    for j in [0:p.width] do
      if cols[j]!.isNone then
        let present := rows.filter (·.cells[j]!.isSome)
        let confirmed := present.filter (·.verified)
        let pool := if confirmed.size ≥ p.t then confirmed else present
        match columnDecode p.t (pool.map (point ·.index)) (pool.map (·.cells[j]!.getD 0)) with
        | some c =>
          cols := cols.set! j (some c)
          changed := true
        | none => pure ()
    for r in [0:rows.size] do
      let row := rows[r]!
      if !row.verified then
        let x := point row.index
        -- first trust the card's own words where the columns are silent, then drop them
        let blank : Array (Option UInt16) := cols.map fun c => c.map (·.at x)
        let fixed : Option (Array UInt16) := match RS.decode p.k (rowView p cols row) with
          | some d => some d.codeword
          | none => (RS.decode p.k blank 0).map RS.Decoded.codeword
        match fixed with
        | some cw =>
          rows := rows.set! r { row with cells := cw.map some, verified := true,
                                         notes := #["rebuilt with help from the other cards"] }
          changed := true
        | none => pure ()
    if !changed then break
  return (rows, cols)

/--
One confirmed card short, with several damaged cards disagreeing in a few
positions: guess which of those positions are wrong on one damaged card, rebuild
that card from its own parity, and accept the guess only if, in every guessed
position, the rebuilt word then agrees with another card. Each agreement is an
independent 11-bit coincidence, and at least three are required.
-/
private def rescue (p : Params) (rows : Array Row) (cols : Array (Option Column)) :
    Option (Nat × Array UInt16) := Id.run do
  let good := rows.filter (·.verified)
  let open_ := (Array.range p.width).filter fun j => cols[j]!.isNone
  if good.size + 1 != p.t || open_.size > 14 || p.k < 3 then return none
  let mut hit : Option (Nat × Array UInt16) := none
  for r in [0:rows.size] do
    let row := rows[r]!
    if !row.verified then
      let base := rowView p cols row
      for size in [3:min p.k open_.size + 1] do
        for pick in Repair.combos open_.size size do
          let erased := pick.map (open_[·]!)
          let recv := erased.foldl (fun a j => a.set! j none) base
          match RS.decode p.k recv 0 with
          | none => pure ()
          | some d =>
            let cw := d.codeword
            let xs := (good.map (point ·.index)).push (point row.index)
            let backed := erased.all fun j =>
              let ys := (good.map (·.cells[j]!.getD 0)).push cw[j]!
              rows.any fun o => !o.verified && o.index != row.index &&
                o.cells[j]! == some (interp xs ys (point o.index))
            if backed then
              match hit with
              | none => hit := some (r, cw)
              | some (r', cw') => if r' == r && cw' != cw then return none
  return hit

/--
Reconstruct from cards that have been through the row stage.

1. Columns and rows are decoded alternately (`settle`).
2. If still one confirmed card short, try `rescue` and settle again.
3. Secret row: positions still unsettled are filled by the secret's own parity.
4. If the digest rejects the result, try every `t`-subset of confirmed cards
   and keep the one the digest accepts.
-/
def combineRows (p : Params) (rows : Array Row) : Result := Id.run do
  let mut notes : Array String := #[]
  if rows.size < p.t then
    return { secret := none, checked := none, rows,
             notes := #[s!"only {rows.size} usable card(s); {p.t} needed"] }
  let (rows1, cols1) := settle p rows (Array.replicate p.width none)
  let mut rows := rows1
  let mut cols := cols1
  if cols.any Option.isNone then
    match rescue p rows cols with
    | some (r, cw) =>
      let old := rows[r]!
      let note := "rebuilt from its own parity after cross-checking with the other cards"
      let fixed : Row := { index := old.index, cells := cw.map some, verified := true, notes := #[note] }
      rows := rows.set! r fixed
      let (rows2, cols2) := settle p rows cols
      rows := rows2
      cols := cols2
    | none => pure ()
  let row0 : Array (Option UInt16) := cols.map fun c => c.map (·.at 0)
  let outvoted := cols.foldl (fun a c => a + (c.map (·.outvoted)).getD 0) 0
  let unsettled := (row0.filter Option.isNone).size
  if outvoted > 0 then
    notes := notes.push s!"{outvoted} word(s) outvoted by the other cards"
  if unsettled > 0 then
    notes := notes.push s!"{unsettled} word position(s) settled by the secret's own parity"
  match (RS.decode p.k row0).map RS.Decoded.codeword with
  | some s =>
    if digestOk p s != some false then
      return { secret := some s, checked := digestOk p s, rows, notes }
  | none => pure ()
  if p.digest > 0 then
    let good := rows.filter (·.verified)
    for sub in Repair.combos good.size p.t do
      let s := fromSubset p (sub.map (good[·]!))
      if RS.isCodeword p.k s && digestOk p s == some true then
        let used := ", ".intercalate (sub.map (fun i => toString good[i]!.index)).toList
        return { secret := some s, checked := some true, rows,
                 notes := #[s!"the cards disagree; the digest accepts cards {used}"] }
  return { secret := none, checked := none, rows,
           notes := notes.push "the cards do not agree on a secret that passes the checks" }

/-- Reconstruct from whatever cards are at hand: repair each alone, then decode jointly. -/
def combine (p : Params) (cards : Array Card) : Result :=
  combineRows p (readCards p cards)

end Parity39.Grid
