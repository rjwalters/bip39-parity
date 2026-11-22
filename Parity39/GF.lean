/-!
# GF(2¹¹)

One BIP39 word is one 11-bit symbol, i.e. one element of GF(2048).
Elements are stored in a `UInt16` (always < 2048) as polynomials over GF(2),
reduced modulo the primitive polynomial x¹¹ + x² + 1.

Addition is XOR. `alpha = x = 2` generates the multiplicative group (order 2047).
-/

namespace Parity39.GF

/-- x¹¹ + x² + 1 -/
def modulus : UInt16 := 0x805

/-- Order of the multiplicative group. -/
def order : Nat := 2047

/-- The primitive element x. -/
def alpha : UInt16 := 2

/-- Carry-less multiply with reduction (shift-and-add, 11 rounds). -/
def mul (a b : UInt16) : UInt16 := Id.run do
  let mut r : UInt16 := 0
  let mut a := a
  let mut b := b
  for _ in [0:11] do
    if b &&& 1 != 0 then r := r ^^^ a
    b := b >>> 1
    a := a <<< 1
    if a &&& 0x800 != 0 then a := a ^^^ modulus
  return r

/-- `a ^ e` by square-and-multiply. -/
def pow (a : UInt16) (e : Nat) : UInt16 := Id.run do
  if a == 0 then return (if e == 0 then 1 else 0)
  let mut e := e % order
  let mut r : UInt16 := 1
  let mut b := a
  for _ in [0:11] do
    if e % 2 == 1 then r := mul r b
    b := mul b b
    e := e / 2
  return r

/-- Multiplicative inverse (`inv 0 = 0`). -/
def inv (a : UInt16) : UInt16 := pow a (order - 1)

end Parity39.GF
