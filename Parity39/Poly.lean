import Parity39.GF

/-! # Polynomials over GF(2¹¹), coefficient of xⁱ at index i. -/

namespace Parity39

abbrev Poly := Array UInt16

namespace Poly

/-- Degree, with the zero polynomial at -1. -/
def degree (p : Poly) : Int := Id.run do
  let mut d : Int := -1
  for i in [0:p.size] do
    if p[i]! != 0 then d := Int.ofNat i
  return d

def coeff (p : Poly) (i : Nat) : UInt16 := p.getD i 0

/-- Horner evaluation. -/
def eval (p : Poly) (x : UInt16) : UInt16 :=
  p.foldr (fun c acc => GF.mul acc x ^^^ c) 0

def add (a b : Poly) : Poly :=
  (Array.range (max a.size b.size)).map fun i => coeff a i ^^^ coeff b i

def scale (p : Poly) (s : UInt16) : Poly := p.map (GF.mul s)

def mul (a b : Poly) : Poly := Id.run do
  if a.isEmpty || b.isEmpty then return #[]
  let mut r : Poly := Array.replicate (a.size + b.size - 1) 0
  for i in [0:a.size] do
    for j in [0:b.size] do
      r := r.set! (i + j) (r[i + j]! ^^^ GF.mul a[i]! b[j]!)
  return r

/-- Reduce modulo xᵏ. -/
def truncate (p : Poly) (k : Nat) : Poly := p.extract 0 k

/-- Long division: `a = q * b + r` with `deg r < deg b`. Requires `b ≠ 0`. -/
def divMod (a b : Poly) : Poly × Poly := Id.run do
  let da := degree a
  let db := degree b
  if db < 0 || da < db then return (#[], a)
  let da := da.toNat
  let db := db.toNat
  let invLead := GF.inv b[db]!
  let mut r := a
  let mut q : Poly := Array.replicate (da - db + 1) 0
  for s in [0:da - db + 1] do
    let i := da - db - s
    let c := GF.mul r[i + db]! invLead
    if c != 0 then
      q := q.set! i c
      for j in [0:db + 1] do
        r := r.set! (i + j) (r[i + j]! ^^^ GF.mul c b[j]!)
  return (q, r)

/-- Formal derivative. In characteristic 2 only odd-degree terms survive. -/
def deriv (p : Poly) : Poly :=
  (Array.range (p.size - 1)).map fun i => if i % 2 == 0 then p[i + 1]! else 0

end Poly
end Parity39
