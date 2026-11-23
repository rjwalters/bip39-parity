import Parity39.Argon2
import Parity39.Sha256

open Parity39

def msg (n : Nat) : ByteArray :=
  if n == 3 then "abc".toUTF8 else ⟨(Array.range n).map fun i => ((i * 7 + 1) % 256).toUInt8⟩

def fill (n : Nat) (v : UInt8) : ByteArray := ⟨Array.replicate n v⟩

def check (name got want : String) : IO Bool := do
  IO.println s!"{if got == want then "pass" else "FAIL"}  {name}"
  if got != want then IO.println s!"      got  {got}\n      want {want}"
  return got == want

def main (args : List String) : IO UInt32 := do
  let mut ok := true
  -- BLAKE2b: reference values from Python's hashlib
  for (n, o, want) in [
      (0, 64, "786a02f742015903c6c6fd852552d272912f4740e15847618a86e217f71f5419d25e1031afee585313896444934eb04b903a685b1448b755d56f701afe9be2ce"),
      (3, 64, "ba80a53f981c4d0d6a2797b69f12f6e94c212f14685ac4b74b12bb6fdbffa2d17d87c5392aab792dc252d5de4533cc9518d38aa8dbf1925ab92386edd4009923"),
      (128, 64, "c6d375fd4421510489194b8ccd9b1fc9e96dd25eab56f33bd698266fb38d8fbde447b617cdb5779c5fbeafe53fae640c85c457f6449ce307a11d88d18788d7f0"),
      (129, 32, "524a9dc9d008a9ce1d9d2a111bcd10d2461a02dadf30ec5a47225501608a87eb"),
      (300, 20, "960d402e8a8a61a2a4b2521f2993608d4fcfde68")] do
    ok := (← check s!"blake2b-{8 * o}, {n}-byte message" (Sha256.hex (Blake2b.hash o (msg n))) want) && ok
  -- Argon2id: RFC 9106 section 5.3
  let tag := Argon2.argon2id (fill 32 1) (fill 16 2) 3 32 4 32 (fill 8 3) (fill 12 4)
  ok := (← check "argon2id RFC 9106 test vector (t=3, m=32, p=4)" (Sha256.hex tag)
    "0d640df58d78766c08c037a34a8b53c9d01ef0452d75b65eb52520e96b01e659") && ok
  let tagRef := Argon2.argon2idRef (fill 32 1) (fill 16 2) 3 32 4 32 (fill 8 3) (fill 12 4)
  ok := (← check "argon2id reference version, same vector" (Sha256.hex tagRef) (Sha256.hex tag)) && ok
  -- the fast version against the reference version on other shapes
  for (t, m, p, len) in [(1, 8, 1, 32), (2, 64, 1, 32), (1, 300, 1, 16), (3, 257, 2, 80), (2, 1024, 3, 64), (4, 96, 6, 32)] do
    let a := Argon2.argon2id (msg 20) (msg 16) t m p len
    let b := Argon2.argon2idRef (msg 20) (msg 16) t m p len
    ok := (← check s!"argon2id fast = reference (t={t}, m={m}, p={p}, {len} bytes)" (Sha256.hex a) (Sha256.hex b)) && ok
  -- optional timing: kdftests <m in KiB> [t]
  if let some m := args.head?.bind String.toNat? then
    let t := ((args.getD 1 "").toNat?).getD 1
    let t0 ← IO.monoMsNow
    let out := Argon2.argon2id "correct horse".toUTF8 "FIRST MIDDLE LAST".toUTF8 t m 1 32
    IO.println s!"argon2id t={t} m={m} KiB p=1 -> {Sha256.hex out}  ({(← IO.monoMsNow) - t0} ms)"
  return (if ok then 0 else 1)
