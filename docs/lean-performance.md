# Lean 4 performance notes

Notes for people and agents writing compiled Lean in this repository. Every
entry comes from a measurement made here; add to it only what you have
measured, and say how. Toolchain at the time of writing: Lean 4.36, arm64.

The running example is Argon2id (`Parity39/Argon2.lean`): the first version
took 148 s for 2 GiB × 4 passes, the current one 8.4 s, the C reference
library about 5 s.

## Method

1. **Keep the slow version.** Write the direct transcription first, keep it
   (`argon2idRef`), and test the fast version against it on several input
   shapes as well as on published vectors (`KdfTests.lean`).
2. **Time a small, fixed case after every change**
   (`lake exe kdftests 262144 1`). Two of the changes below that should have
   helped made things slower or failed to compile.
3. **Read the generated C** in `.lake/build/ir/<Module>.c`. Find the hot
   function and count what it calls:

       grep -o "lean_[a-z_0-9]*\|lp_[A-Za-z_0-9]*" hot_function.c | sort | uniq -c | sort -rn

   `lean_alloc_*`, `lean_box_uint64`, `lean_inc`/`lean_dec`, or calls to
   `…___lam__N` in an inner loop are the things to remove.

## What is boxed and what is not

- `Array UInt64` (and `Array` of any 64-bit scalar) is an array of pointers to
  heap objects. Every write allocates, every read follows a pointer.
  *Measured: about 11× of the Argon2id run time.*
- `UInt64`, `USize`, `UInt8` as **local variables, function arguments and
  return values** are plain machine words.
- `ByteArray` is flat memory. There is no 64-bit read or write on it; build
  one from eight byte accesses (`get64`/`set64` in `Argon2.lean`).
- `Nat` is a tagged machine word when small. Fine for loop counters and
  per-block index arithmetic; keep it out of per-word arithmetic.

## Tips

1. **Hold scalars in locals, bulk data in one `ByteArray`.** Thread the array
   through the computation and update it in place. In-place update happens
   only while the array has a single reference, so never keep a second copy
   alive across a write, or each write copies the whole array.

2. **Return several scalars through a continuation, not a tuple.**

       @[always_inline, inline] def gbK (a b c d : UInt64)
           (k : UInt64 → UInt64 → UInt64 → UInt64 → α) : α := … k a b c d

   Once inlined, the continuation disappears and nothing is allocated.

3. **Do not use local lambdas as helpers in hot code.** A
   `let f := fun j => …` used many times is lifted into a separate function
   and called, not inlined. Make it a top-level `@[always_inline, inline]`
   definition taking its context as arguments.
   *Measured: 0.36 s → 0.48 s when helpers were written as local lambdas.*

4. **Do not inline everything.** One function holding 16 inlined permutations
   and about 640 inlined word accesses hit the LCNF compiler's heartbeat
   limit. Split at a natural boundary with `@[noinline]`; a call per 16 words
   costs little. *Measured: the split version was the fastest (0.24 s).*

5. **Check ranges once per word, not once per byte.** `a[i]!` checks every
   access and stops the C compiler from merging byte reads. One
   `if i + 8 ≤ a.usize` followed by eight `uget`s compiles to a single 64-bit
   load.

6. **`uget`/`uset` need a proof; `lcProof` is `unsafe`.** The pattern used
   here: give the function a plain checked definition as its meaning, write
   the fast body as an `unsafe def`, and connect them with
   `attribute [implemented_by fastImpl] slowDef`. The checker never sees the
   fast body, so keep it tiny, keep a run-time range check in it, and test it.

7. **Build big buffers by appending chunks.** `Array.replicate n 0` converted
   to a `ByteArray` goes through a boxed array. Use
   `ByteArray.emptyWithCapacity n` and append a 64 KiB chunk repeatedly.

## Known remaining costs (not yet measured)

- `ByteArray.uset` checks that the array is unshared before every byte, so a
  64-bit store is eight checks and eight stores. This is the suspected cause
  of the remaining 1.7× against C.
- `for … in [a:b]` with more than one `let mut` threads a tuple through the
  loop. Keeping a single mutable variable in hot loops avoids the question.

## Not tried

- C through the FFI for the word accessors.
- `FloatArray` with `Float.ofBits`/`toBits` as a flat 64-bit array. The
  conversions are calls into the runtime, and the result would depend on the
  platform preserving NaN bit patterns.
- Carrying real bounds proofs instead of `implemented_by`.
