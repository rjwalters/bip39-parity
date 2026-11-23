import Parity39.Blake2b

/-!
# Argon2id (RFC 9106, version 0x13)

Two implementations that must agree:

* `argon2idRef` is a direct transcription of the specification, written to be
  read. It keeps each block's 128 words in an `Array UInt64`, which Lean stores
  as 128 pointers to heap objects, so it spends its time allocating.
* `argon2id` is the one to run. All memory is a single `ByteArray` updated in
  place, and 64-bit words exist only as local variables, which Lean keeps in
  machine registers.

Lanes are filled one after another, which gives the same result as filling
them in parallel.
-/

namespace Parity39.Argon2

open Blake2b (rotr le64 pushLe64)

def le32 (n : Nat) : ByteArray :=
  ⟨#[n.toUInt8, (n >>> 8).toUInt8, (n >>> 16).toUInt8, (n >>> 24).toUInt8]⟩

/-- Variable-length hash H′ of the specification. -/
def hPrime (len : Nat) (a : ByteArray) : ByteArray := Id.run do
  if len ≤ 64 then return Blake2b.hash len (le32 len ++ a)
  let r := (len + 31) / 32 - 2
  let mut v := Blake2b.hash 64 (le32 len ++ a)
  let mut out := v.extract 0 32
  for _ in [1:r] do
    v := Blake2b.hash 64 v
    out := out ++ v.extract 0 32
  return out ++ Blake2b.hash (len - 32 * r) v

@[inline] def lo (x : UInt64) : UInt64 := x &&& 0xffffffff

private def gb (v : Array UInt64) (a b c d : Nat) : Array UInt64 := Id.run do
  let mut va := v[a]!
  let mut vb := v[b]!
  let mut vc := v[c]!
  let mut vd := v[d]!
  va := va + vb + 2 * lo va * lo vb
  vd := rotr (vd ^^^ va) 32
  vc := vc + vd + 2 * lo vc * lo vd
  vb := rotr (vb ^^^ vc) 24
  va := va + vb + 2 * lo va * lo vb
  vd := rotr (vd ^^^ va) 16
  vc := vc + vd + 2 * lo vc * lo vd
  vb := rotr (vb ^^^ vc) 63
  return (((v.set! a va).set! b vb).set! c vc).set! d vd

/-- The permutation P on the sixteen words at positions `i`. -/
private def perm (v : Array UInt64) (i : Array Nat) : Array UInt64 :=
  let v := gb v i[0]! i[4]! i[8]! i[12]!
  let v := gb v i[1]! i[5]! i[9]! i[13]!
  let v := gb v i[2]! i[6]! i[10]! i[14]!
  let v := gb v i[3]! i[7]! i[11]! i[15]!
  let v := gb v i[0]! i[5]! i[10]! i[15]!
  let v := gb v i[1]! i[6]! i[11]! i[12]!
  let v := gb v i[2]! i[7]! i[8]! i[13]!
  gb v i[3]! i[4]! i[9]! i[14]!

private def rowIdx : Array (Array Nat) :=
  (Array.range 8).map fun i => (Array.range 16).map (16 * i + ·)

private def colIdx : Array (Array Nat) :=
  (Array.range 8).map fun i => (Array.range 16).map fun k => 2 * i + 16 * (k / 2) + k % 2

def xorWords (x y : Array UInt64) : Array UInt64 :=
  (Array.range x.size).map fun i => x[i]! ^^^ y[i]!

/-- The compression function G on two 128-word blocks. -/
def compress (x y : Array UInt64) : Array UInt64 := Id.run do
  let r := xorWords x y
  let mut z := r
  for idx in rowIdx do
    z := perm z idx
  for idx in colIdx do
    z := perm z idx
  return xorWords z r

def toWords (b : ByteArray) : Array UInt64 := (Array.range 128).map fun i => le64 b (8 * i)

def fromWords (w : Array UInt64) : ByteArray := w.foldl pushLe64 (ByteArray.emptyWithCapacity 1024)

/--
Argon2id, reference version. `t` passes, `m` kibibytes of memory, `p` lanes,
`tagLen` output bytes.
-/
def argon2idRef (pwd salt : ByteArray) (t m p tagLen : Nat)
    (key ad : ByteArray := ByteArray.empty) : ByteArray := Id.run do
  let m' := 4 * p * (m / (4 * p))
  let q := m' / p
  let sl := q / 4
  let h0 := Blake2b.hash 64 <|
    le32 p ++ le32 tagLen ++ le32 m ++ le32 t ++ le32 0x13 ++ le32 2
      ++ le32 pwd.size ++ pwd ++ le32 salt.size ++ salt
      ++ le32 key.size ++ key ++ le32 ad.size ++ ad
  let zero : Array UInt64 := Array.replicate 128 0
  let mut mem : Array ByteArray := Array.replicate m' ByteArray.empty
  for l in [0:p] do
    mem := mem.set! (l * q) (hPrime 1024 (h0 ++ le32 0 ++ le32 l))
    mem := mem.set! (l * q + 1) (hPrime 1024 (h0 ++ le32 1 ++ le32 l))
  for r in [0:t] do
    for s in [0:4] do
      for l in [0:p] do
        -- Argon2id: the first half of the first pass picks references independently of the data
        let indep := r == 0 && s < 2
        let mut input : Array UInt64 := zero
        input := (((((input.set! 0 r.toUInt64).set! 1 l.toUInt64).set! 2 s.toUInt64).set! 3
          m'.toUInt64).set! 4 t.toUInt64).set! 5 2
        let mut addr : Array UInt64 := #[]
        for idx in [(if r == 0 && s == 0 then 2 else 0):sl] do
          let j := s * sl + idx
          let prev := toWords mem[l * q + (if j == 0 then q - 1 else j - 1)]!
          let mut rnd := prev[0]!
          if indep then
            if idx % 128 == 0 || addr.isEmpty then
              input := input.set! 6 (input[6]! + 1)
              addr := compress zero (compress zero input)
            rnd := addr[idx % 128]!
          let j1 := lo rnd
          let j2 := rnd >>> 32
          let refLane := if r == 0 && s == 0 then l else j2.toNat % p
          let same := refLane == l
          let edge := if idx == 0 then 1 else 0
          let area : Nat :=
            if r == 0 then
              if s == 0 then idx - 1
              else if same then s * sl + idx - 1
              else s * sl - edge
            else if same then q - sl + idx - 1
            else q - sl - edge
          let x := (j1 * j1) >>> 32
          let y := (area.toUInt64 * x) >>> 32
          let rel := area - 1 - y.toNat
          let start := if r == 0 || s == 3 then 0 else (s + 1) * sl
          let ref := toWords mem[refLane * q + (start + rel) % q]!
          let cur := l * q + j
          let fresh := compress prev ref
          let out := if r == 0 then fresh else xorWords fresh (toWords mem[cur]!)
          mem := mem.set! cur (fromWords out)
  let mut c := zero
  for l in [0:p] do
    c := xorWords c (toWords mem[l * q + q - 1]!)
  return hPrime tagLen (fromWords c)

/-! ## The fast version -/

/-- Little-endian word at byte offset `i`: the meaning of `get64`. -/
def get64 (a : ByteArray) (i : USize) : UInt64 :=
  (List.range 8).foldr (fun k acc => (acc <<< 8) ||| (a[i.toNat + k]!).toUInt64) 0

/-- Store `v` little-endian at byte offset `i`: the meaning of `set64`. -/
def set64 (a : ByteArray) (i : USize) (v : UInt64) : ByteArray :=
  (List.range 8).foldl (fun a k => a.set! (i.toNat + k) (v >>> (8 * k.toUInt64)).toUInt8) a

/--
What `get64` compiles to. One range check per word; the eight byte reads
behind it are unchecked, which lets the C compiler merge them into a single
64-bit load. `unsafe` because the checker is not shown that the reads are in
range, only the run-time test guarantees it.
-/
@[inline] unsafe def get64Impl (a : ByteArray) (i : USize) : UInt64 :=
  if i + 8 ≤ a.usize then
    (a.uget i lcProof).toUInt64
      ||| ((a.uget (i + 1) lcProof).toUInt64 <<< 8)
      ||| ((a.uget (i + 2) lcProof).toUInt64 <<< 16)
      ||| ((a.uget (i + 3) lcProof).toUInt64 <<< 24)
      ||| ((a.uget (i + 4) lcProof).toUInt64 <<< 32)
      ||| ((a.uget (i + 5) lcProof).toUInt64 <<< 40)
      ||| ((a.uget (i + 6) lcProof).toUInt64 <<< 48)
      ||| ((a.uget (i + 7) lcProof).toUInt64 <<< 56)
  else panic! "argon2: read out of range"

@[inline] unsafe def set64Impl (a : ByteArray) (i : USize) (v : UInt64) : ByteArray :=
  if i + 8 ≤ a.usize then
    let a := a.uset i v.toUInt8 lcProof
    let a := a.uset (i + 1) (v >>> 8).toUInt8 lcProof
    let a := a.uset (i + 2) (v >>> 16).toUInt8 lcProof
    let a := a.uset (i + 3) (v >>> 24).toUInt8 lcProof
    let a := a.uset (i + 4) (v >>> 32).toUInt8 lcProof
    let a := a.uset (i + 5) (v >>> 40).toUInt8 lcProof
    let a := a.uset (i + 6) (v >>> 48).toUInt8 lcProof
    a.uset (i + 7) (v >>> 56).toUInt8 lcProof
  else panic! "argon2: write out of range"

attribute [implemented_by get64Impl] get64
attribute [implemented_by set64Impl] set64

@[inline] private def rot (x n : UInt64) : UInt64 := (x >>> n) ||| (x <<< (64 - n))

/-- The quarter-round GB. Results go to a continuation so that no tuple is built. -/
@[always_inline, inline] private def gbK {α : Type} (a b c d : UInt64)
    (k : UInt64 → UInt64 → UInt64 → UInt64 → α) : α :=
  let a := a + b + 2 * lo a * lo b
  let d := rot (d ^^^ a) 32
  let c := c + d + 2 * lo c * lo d
  let b := rot (b ^^^ c) 24
  let a := a + b + 2 * lo a * lo b
  let d := rot (d ^^^ a) 16
  let c := c + d + 2 * lo c * lo d
  let b := rot (b ^^^ c) 63
  k a b c d

/-- The permutation P on sixteen words held in local variables. -/
@[always_inline, inline] private def permK {α : Type}
    (v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 : UInt64)
    (k : UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 →
         UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → α) : α :=
  gbK v0 v4 v8 v12 fun v0 v4 v8 v12 =>
  gbK v1 v5 v9 v13 fun v1 v5 v9 v13 =>
  gbK v2 v6 v10 v14 fun v2 v6 v10 v14 =>
  gbK v3 v7 v11 v15 fun v3 v7 v11 v15 =>
  gbK v0 v5 v10 v15 fun v0 v5 v10 v15 =>
  gbK v1 v6 v11 v12 fun v1 v6 v11 v12 =>
  gbK v2 v7 v8 v13 fun v2 v7 v8 v13 =>
  gbK v3 v4 v9 v14 fun v3 v4 v9 v14 =>
  k v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15

/-- Word of `x ⊕ y` at byte offset `o` of the two blocks. -/
@[always_inline, inline] private def ld (m : ByteArray) (x y o : USize) : UInt64 :=
  get64 m (x + o) ^^^ get64 m (y + o)

/-- Store `v ⊕ x ⊕ y` (⊕ the old word when `xorOld`) at byte offset `o` of block `out`. -/
@[always_inline, inline] private def put (m : ByteArray) (x y out o : USize) (xorOld : Bool)
    (v : UInt64) : ByteArray :=
  let v := v ^^^ ld m x y o
  set64 m (out + o) (if xorOld then v ^^^ get64 m (out + o) else v)

/-- P on one row of `x ⊕ y`: sixteen consecutive words, read from memory. -/
@[always_inline, inline] private def rowK {α : Type} (m : ByteArray) (x y : USize)
    (k : UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 →
         UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → UInt64 → α) : α :=
  permK (ld m x y 0) (ld m x y 8) (ld m x y 16) (ld m x y 24)
        (ld m x y 32) (ld m x y 40) (ld m x y 48) (ld m x y 56)
        (ld m x y 64) (ld m x y 72) (ld m x y 80) (ld m x y 88)
        (ld m x y 96) (ld m x y 104) (ld m x y 112) (ld m x y 120) k

/--
P on one column (two words from each of the eight rows), then the final XOR
with `x ⊕ y` (and with the old contents of `out` on later passes), stored at
`out`. `c` is the byte offset of the column's first word within a block.
-/
@[noinline] private def colOut (m : ByteArray) (x y out c : USize) (xorOld : Bool)
    (v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 : UInt64) : ByteArray :=
  permK v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15
    fun v0 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 =>
  let m := put m x y out (c + 0) xorOld v0
  let m := put m x y out (c + 8) xorOld v1
  let m := put m x y out (c + 128) xorOld v2
  let m := put m x y out (c + 136) xorOld v3
  let m := put m x y out (c + 256) xorOld v4
  let m := put m x y out (c + 264) xorOld v5
  let m := put m x y out (c + 384) xorOld v6
  let m := put m x y out (c + 392) xorOld v7
  let m := put m x y out (c + 512) xorOld v8
  let m := put m x y out (c + 520) xorOld v9
  let m := put m x y out (c + 640) xorOld v10
  let m := put m x y out (c + 648) xorOld v11
  let m := put m x y out (c + 768) xorOld v12
  let m := put m x y out (c + 776) xorOld v13
  let m := put m x y out (c + 896) xorOld v14
  put m x y out (c + 904) xorOld v15

/--
The compression function G, in place. `x`, `y` and `out` are byte offsets of
1024-byte blocks in `m`. Writes `G(x, y)` to `out`, XORed with what was there
when `xorOld` is set. `out` may equal `y`.

All 128 words of the state are local variables: row `a` is words 0–15, row `b`
words 16–31, and so on. Nothing is written until the column rounds finish.
-/
def compressAt (m : ByteArray) (x y out : USize) (xorOld : Bool) : ByteArray :=
  rowK m (x + 0) (y + 0) fun a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 =>
  rowK m (x + 128) (y + 128) fun b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 =>
  rowK m (x + 256) (y + 256) fun c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 =>
  rowK m (x + 384) (y + 384) fun d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10 d11 d12 d13 d14 d15 =>
  rowK m (x + 512) (y + 512) fun e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 e10 e11 e12 e13 e14 e15 =>
  rowK m (x + 640) (y + 640) fun f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 =>
  rowK m (x + 768) (y + 768) fun g0 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 g11 g12 g13 g14 g15 =>
  rowK m (x + 896) (y + 896) fun h0 h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 h14 h15 =>
  let m := colOut m x y out 0 xorOld a0 a1 b0 b1 c0 c1 d0 d1 e0 e1 f0 f1 g0 g1 h0 h1
  let m := colOut m x y out 16 xorOld a2 a3 b2 b3 c2 c3 d2 d3 e2 e3 f2 f3 g2 g3 h2 h3
  let m := colOut m x y out 32 xorOld a4 a5 b4 b5 c4 c5 d4 d5 e4 e5 f4 f5 g4 g5 h4 h5
  let m := colOut m x y out 48 xorOld a6 a7 b6 b7 c6 c7 d6 d7 e6 e7 f6 f7 g6 g7 h6 h7
  let m := colOut m x y out 64 xorOld a8 a9 b8 b9 c8 c9 d8 d9 e8 e9 f8 f9 g8 g9 h8 h9
  let m := colOut m x y out 80 xorOld a10 a11 b10 b11 c10 c11 d10 d11 e10 e11 f10 f11 g10 g11 h10 h11
  let m := colOut m x y out 96 xorOld a12 a13 b12 b13 c12 c13 d12 d13 e12 e13 f12 f13 g12 g13 h12 h13
  let m := colOut m x y out 112 xorOld a14 a15 b14 b15 c14 c15 d14 d15 e14 e15 f14 f15 g14 g15 h14 h15
  m

/-- `n` zero bytes, without building a list of them. -/
private def zeros (n : Nat) : ByteArray := Id.run do
  let mut chunk := ByteArray.emptyWithCapacity 65536
  for _ in [0:65536] do
    chunk := chunk.push 0
  let mut b := ByteArray.emptyWithCapacity n
  for _ in [0:n / 65536] do
    b := b ++ chunk
  return b ++ chunk.extract 0 (n % 65536)

/--
Argon2id. `t` passes, `m` kibibytes of memory, `p` lanes, `tagLen` output bytes.

Layout of the working array: four auxiliary blocks (zero, counter input,
address block, one spare) followed by the `m′` memory blocks.
-/
def argon2id (pwd salt : ByteArray) (t m p tagLen : Nat)
    (key ad : ByteArray := ByteArray.empty) : ByteArray := Id.run do
  let m' := 4 * p * (m / (4 * p))
  let q := m' / p
  let sl := q / 4
  let h0 := Blake2b.hash 64 <|
    le32 p ++ le32 tagLen ++ le32 m ++ le32 t ++ le32 0x13 ++ le32 2
      ++ le32 pwd.size ++ pwd ++ le32 salt.size ++ salt
      ++ le32 key.size ++ key ++ le32 ad.size ++ ad
  let inputAt : USize := 1024
  let addrAt : USize := 2048
  let blk (i : Nat) : USize := (1024 * (i + 4)).toUSize
  let mut mem := zeros (1024 * (m' + 4))
  for l in [0:p] do
    mem := (hPrime 1024 (h0 ++ le32 0 ++ le32 l)).copySlice 0 mem (1024 * (l * q + 4)) 1024
    mem := (hPrime 1024 (h0 ++ le32 1 ++ le32 l)).copySlice 0 mem (1024 * (l * q + 5)) 1024
  for r in [0:t] do
    for s in [0:4] do
      for l in [0:p] do
        -- Argon2id: the first half of the first pass picks references independently of the data
        let indep := r == 0 && s < 2
        let first := if r == 0 && s == 0 then 2 else 0
        if indep then
          mem := set64 mem inputAt r.toUInt64
          mem := set64 mem (inputAt + 8) l.toUInt64
          mem := set64 mem (inputAt + 16) s.toUInt64
          mem := set64 mem (inputAt + 24) m'.toUInt64
          mem := set64 mem (inputAt + 32) t.toUInt64
          mem := set64 mem (inputAt + 40) 2
          mem := set64 mem (inputAt + 48) 0
        for idx in [first:sl] do
          let j := s * sl + idx
          let prev := blk (l * q + (if j == 0 then q - 1 else j - 1))
          let mut rnd := get64 mem prev
          if indep then
            if idx % 128 == 0 || idx == first then
              mem := set64 mem (inputAt + 48) (get64 mem (inputAt + 48) + 1)
              mem := compressAt mem 0 inputAt addrAt false
              mem := compressAt mem 0 addrAt addrAt false
            rnd := get64 mem (addrAt + 8 * (idx % 128).toUSize)
          let j1 := lo rnd
          let j2 := rnd >>> 32
          let refLane := if r == 0 && s == 0 then l else j2.toNat % p
          let same := refLane == l
          let edge := if idx == 0 then 1 else 0
          let area : Nat :=
            if r == 0 then
              if s == 0 then idx - 1
              else if same then s * sl + idx - 1
              else s * sl - edge
            else if same then q - sl + idx - 1
            else q - sl - edge
          let x := (j1 * j1) >>> 32
          let y := (area.toUInt64 * x) >>> 32
          let rel := area - 1 - y.toNat
          let start := if r == 0 || s == 3 then 0 else (s + 1) * sl
          let ref := blk (refLane * q + (start + rel) % q)
          mem := compressAt mem prev ref (blk (l * q + j)) (r != 0)
  let mut c := mem.extract (1024 * (q + 3)) (1024 * (q + 4))
  for l in [1:p] do
    let o := 1024 * (l * q + q + 3)
    for i in [0:1024] do
      c := c.set! i (c[i]! ^^^ mem[o + i]!)
  return hPrime tagLen c

end Parity39.Argon2
