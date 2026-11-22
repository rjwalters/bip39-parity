import Parity39.Poly

/-!
# Reed–Solomon N+k over GF(2¹¹)

A codeword is `n = N + k` symbols `c₀ … cₙ₋₁` (the phrase, in order) such that
all `k` syndromes vanish:

    Sⱼ = Σₚ cₚ · α^(p·j) = 0        for j = 0 … k-1

`S₀` is the plain XOR of all words (RAID-5 "P"); `S₁` is the position-weighted
sum (RAID-6 "Q"); the rest generalise it. The code is MDS: any `e` wrong words
and `s` known-missing words are recoverable whenever `2e + s ≤ k`.

The code is systematic: the first `N` symbols are the data, untouched.
Encoding is just erasure-decoding with the `k` parity positions erased.
-/

namespace Parity39.RS

/-- Locator of phrase position `p`. -/
def locator (p : Nat) : UInt16 := GF.pow GF.alpha p

def locatorInv (p : Nat) : UInt16 :=
  GF.pow GF.alpha ((GF.order - p % GF.order) % GF.order)

/-- `Sⱼ` is the phrase, read as a polynomial, evaluated at `αʲ`. -/
def syndromes (k : Nat) (c : Array UInt16) : Array UInt16 :=
  (Array.range k).map fun j => Poly.eval c (GF.pow GF.alpha j)

def isCodeword (k : Nat) (c : Array UInt16) : Bool :=
  (syndromes k c).all (· == 0)

structure Decoded where
  codeword : Array UInt16
  /-- Positions where a present symbol was wrong and has been replaced. -/
  errors : Array Nat
  /-- Positions that were marked missing and have been filled in. -/
  erasures : Array Nat

/--
Errors-and-erasures decoding (Sugiyama / extended Euclid, Chien search, Forney).
`none` in the input marks a known-missing symbol. Returns `none` if the word is
not within `2e + s ≤ k` (and `e ≤ maxErrors`) of a codeword.

Lowering `maxErrors` below `(k - s) / 2` trades correction for detection.
-/
def decode (k : Nat) (recv : Array (Option UInt16)) (maxErrors : Nat := k) :
    Option Decoded := do
  let n := recv.size
  guard (n ≤ GF.order)
  let erasures := (Array.range n).filter fun p => recv[p]!.isNone
  let s := erasures.size
  guard (s ≤ k)
  let c : Array UInt16 := recv.map (·.getD 0)
  let synd := syndromes k c
  -- erasure locator Γ(x) = Π (1 + Xₚ x)
  let gamma : Poly := erasures.foldl (fun g p => Poly.mul g #[1, locator p]) #[1]
  let xi := (Poly.mul synd gamma).truncate k
  -- solve Λ·Ξ ≡ Ω (mod xᵏ) with 2·deg Ω < k + s
  let mut r0 : Poly := (Array.replicate k (0 : UInt16)).push 1
  let mut r1 : Poly := xi
  let mut t0 : Poly := #[]
  let mut t1 : Poly := #[1]
  for _ in [0:k + 1] do
    if 2 * Poly.degree r1 < Int.ofNat (k + s) then break
    let (q, r) := Poly.divMod r0 r1
    r0 := r1
    r1 := r
    let t := Poly.add t0 (Poly.mul q t1)
    t0 := t1
    t1 := t
  let l0 := Poly.coeff t1 0
  guard (l0 != 0)
  let lambda := Poly.scale t1 (GF.inv l0)
  let e := (Poly.degree lambda).toNat
  guard (2 * e + s ≤ k && e ≤ maxErrors)
  -- Chien search over the positions that are actually present
  let errs := (Array.range n).filter fun p =>
    recv[p]!.isSome && Poly.eval lambda (locatorInv p) == 0
  guard (errs.size == e)
  -- Forney: magnitude at p is Xₚ · Ω(Xₚ⁻¹) / Ψ'(Xₚ⁻¹), Ψ = Λ·Γ
  let psi := Poly.mul lambda gamma
  let omega := (Poly.mul synd psi).truncate k
  let dpsi := Poly.deriv psi
  let mut out := c
  for p in errs ++ erasures do
    let x := locatorInv p
    let den := Poly.eval dpsi x
    guard (den != 0)
    let mag := GF.mul (locator p) (GF.mul (Poly.eval omega x) (GF.inv den))
    out := out.set! p (out[p]! ^^^ mag)
  guard (isCodeword k out)
  return { codeword := out, errors := errs.filter (fun p => out[p]! != c[p]!), erasures }

/-- Append `k` parity symbols to `data`. `none` only if `N + k > 2047`. -/
def encode (k : Nat) (data : Array UInt16) : Option (Array UInt16) :=
  (decode k (data.map some ++ Array.replicate k none) 0).map (·.codeword)

end Parity39.RS
