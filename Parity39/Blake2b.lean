/-! # BLAKE2b (RFC 7693), unkeyed, any output length 1…64. -/

namespace Parity39.Blake2b

def iv : Array UInt64 := #[
  0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
  0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179]

def sigma : Array (Array Nat) := #[
  #[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
  #[14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
  #[11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4],
  #[7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
  #[9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13],
  #[2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9],
  #[12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11],
  #[13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10],
  #[6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5],
  #[10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0]]

@[inline] def rotr (x : UInt64) (n : UInt64) : UInt64 := (x >>> n) ||| (x <<< (64 - n))

/-- Little-endian 64-bit word at byte offset `off` (missing bytes read as zero). -/
def le64 (b : ByteArray) (off : Nat) : UInt64 := Id.run do
  let mut x : UInt64 := 0
  for i in [0:8] do
    if off + i < b.size then
      x := x ||| (b[off + i]!.toUInt64 <<< (8 * i).toUInt64)
  return x

def pushLe64 (b : ByteArray) (x : UInt64) : ByteArray := Id.run do
  let mut b := b
  for i in [0:8] do
    b := b.push (x >>> (8 * i).toUInt64).toUInt8
  return b

private def g (v : Array UInt64) (a b c d : Nat) (x y : UInt64) : Array UInt64 := Id.run do
  let mut va := v[a]!
  let mut vb := v[b]!
  let mut vc := v[c]!
  let mut vd := v[d]!
  va := va + vb + x
  vd := rotr (vd ^^^ va) 32
  vc := vc + vd
  vb := rotr (vb ^^^ vc) 24
  va := va + vb + y
  vd := rotr (vd ^^^ va) 16
  vc := vc + vd
  vb := rotr (vb ^^^ vc) 63
  return (((v.set! a va).set! b vb).set! c vc).set! d vd

/-- Compress the 128-byte block at `off` (zero-padded) with byte counter `t`. -/
private def compress (h : Array UInt64) (msg : ByteArray) (off : Nat) (t : UInt64) (last : Bool) :
    Array UInt64 := Id.run do
  let m := (Array.range 16).map fun i => le64 msg (off + 8 * i)
  let mut v := h ++ iv
  v := v.set! 12 (v[12]! ^^^ t)
  if last then v := v.set! 14 (~~~ v[14]!)
  for r in [0:12] do
    let s := sigma[r % 10]!
    v := g v 0 4 8 12 m[s[0]!]! m[s[1]!]!
    v := g v 1 5 9 13 m[s[2]!]! m[s[3]!]!
    v := g v 2 6 10 14 m[s[4]!]! m[s[5]!]!
    v := g v 3 7 11 15 m[s[6]!]! m[s[7]!]!
    v := g v 0 5 10 15 m[s[8]!]! m[s[9]!]!
    v := g v 1 6 11 12 m[s[10]!]! m[s[11]!]!
    v := g v 2 7 8 13 m[s[12]!]! m[s[13]!]!
    v := g v 3 4 9 14 m[s[14]!]! m[s[15]!]!
  return (Array.range 8).map fun i => h[i]! ^^^ v[i]! ^^^ v[i + 8]!

def hash (outLen : Nat) (msg : ByteArray) : ByteArray := Id.run do
  let mut h := iv.set! 0 (iv[0]! ^^^ 0x01010000 ^^^ outLen.toUInt64)
  let blocks := if msg.size == 0 then 1 else (msg.size + 127) / 128
  for i in [0:blocks - 1] do
    h := compress h msg (128 * i) (128 * (i + 1)).toUInt64 false
  h := compress h msg (128 * (blocks - 1)) msg.size.toUInt64 true
  let mut out := ByteArray.empty
  for w in h do
    out := pushLe64 out w
  return out.extract 0 outLen

end Parity39.Blake2b
