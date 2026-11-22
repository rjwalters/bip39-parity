import Parity39.Sha256

/-! # BIP39 entropy ⇄ word indices, and the built-in SHA-256 checksum bits. -/

namespace Parity39.Bip39

def validLengths : List Nat := [12, 15, 18, 21, 24]

private def natToBytes (v : Nat) (len : Nat) : ByteArray := Id.run do
  let mut out := ByteArray.empty
  for i in [0:len] do
    out := out.push ((v >>> (8 * (len - 1 - i))) % 256).toUInt8
  return out

private def checksumBits (entropy : ByteArray) (cs : Nat) : Nat :=
  (Sha256.hash entropy)[0]!.toNat >>> (8 - cs)

/--
`some true/false`: the words are a BIP39-length phrase with a valid/invalid
checksum. `none`: not a BIP39 length, so there is no checksum to consult.
-/
def checksumOk (ws : Array UInt16) : Option Bool :=
  if !validLengths.contains ws.size then none
  else
    let cs := ws.size / 3
    let v := ws.foldl (fun acc w => acc * 2048 + w.toNat) 0
    let entropy := natToBytes (v >>> cs) ((ws.size * 11 - cs) / 8)
    some (v % (1 <<< cs) == checksumBits entropy cs)

/-- Standard BIP39 encoding of 16/20/24/28/32 bytes of entropy. -/
def fromEntropy (entropy : ByteArray) : Option (Array UInt16) :=
  if !([16, 20, 24, 28, 32] : List Nat).contains entropy.size then none
  else
    let cs := entropy.size / 4
    let n := (entropy.size * 8 + cs) / 11
    let v := (entropy.foldl (fun acc b => acc * 256 + b.toNat) 0) <<< cs
      ||| checksumBits entropy cs
    some <| (Array.range n).map fun i => ((v >>> (11 * (n - 1 - i))) % 2048).toUInt16

end Parity39.Bip39
