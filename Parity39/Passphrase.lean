import Parity39.Repair
import Parity39.Argon2

/-!
# Memorised passphrase, version 1 (experimental)

Twelve words from the memory vocabulary, pictured as three rooms of four:
ten secret words followed by two parity words. The salt is three upper-case
words (by convention the user's name). A symbol derived from the salt is
covered by the parity words without being part of the phrase, so the right
words under the wrong salt are detected instead of opening an empty wallet.

    seed = Argon2id(password = the ten secret words, lower case, single spaces,
                    salt = "parity39/passphrase/v1:" ++ SALT,
                    2 GiB, 4 passes, 1 lane, 32 bytes)

and the seed is shown as a 24-word BIP39 phrase.
-/

namespace Parity39.Passphrase

private def lines (s : String) : Array String := ((s.splitOn "\n").filter (· ≠ "")).toArray

def objects : Array String := lines (include_str "../data/memory/objects.txt")
def modifiers : Array String := lines (include_str "../data/memory/modifiers.txt")
/-- Symbol `i` is `words[i]`: objects first, then modifiers. -/
def words : Array String := objects ++ modifiers

def isObject (w : UInt16) : Bool := w.toNat < objects.size

/-- Objects in lower case, modifiers in capitals. -/
def word (w : UInt16) : String :=
  let s := words[w.toNat]!
  if isObject w then s else s.toUpper

/-- Exact word, or its first four or more letters; case is ignored. -/
def lookup (s : String) : Option UInt16 :=
  let s := s.toLower
  match words.findIdx? (· == s) with
  | some i => some i.toUInt16
  | none =>
    if s.length < 4 then none
    else
      let hits := (Array.range words.size).filter fun i => words[i]!.startsWith s
      if hits.size == 1 then some hits[0]!.toUInt16 else none

def parityWords : Nat := 2
def secretWords : Nat := 10
def length : Nat := secretWords + parityWords
def memoryKiB : Nat := 2 * 1024 * 1024
def passes : Nat := 4

/-- Three words of A–Z separated by single spaces. -/
def validSalt (salt : String) : Bool :=
  let parts := salt.splitOn " "
  parts.length == 3 && parts.all fun p => !p.isEmpty && p.all fun c => 'A' ≤ c && c ≤ 'Z'

/-- The unspoken symbol that ties a phrase to its salt. -/
def saltSymbol (salt : String) : UInt16 :=
  let h := Sha256.hash ("parity39/salt:" ++ salt).toUTF8
  ((h[0]!.toUInt16 <<< 8) ||| h[1]!.toUInt16) &&& 0x7ff

/-- Append the two parity words to ten secret words. -/
def encode (secret : Array UInt16) (salt : String) : Option (Array UInt16) :=
  (RS.decode parityWords
    (secret.map some ++ Array.replicate parityWords none ++ #[some (saltSymbol salt)]) 0).map
    (·.codeword.extract 0 length)

/-- A phrase is easy to picture when every room ends in an object. -/
def roomsEndInObject (phrase : Array UInt16) : Bool :=
  (Array.range (phrase.size / 4)).all fun r => isObject phrase[4 * r + 3]!

def generate (salt : String) : IO (Option (Array UInt16)) := do
  for _ in [0:10000] do
    let b ← IO.getRandomBytes (2 * secretWords).toUSize
    let secret := (Array.range secretWords).map fun i =>
      ((b[2 * i]!.toUInt16 <<< 8) ||| b[2 * i + 1]!.toUInt16) &&& 0x7ff
    if let some p := encode secret salt then
      if roomsEndInObject p then return some p
  return none

def render (phrase : Array UInt16) : Array String :=
  (Array.range ((phrase.size + 3) / 4)).map fun r =>
    s!"  room {r + 1}:  " ++ "  ".intercalate ((phrase.extract (4 * r) (4 * r + 4)).map word).toList

def derive (phrase : Array UInt16) (salt : String)
    (kib : Nat := memoryKiB) (t : Nat := passes) : ByteArray :=
  let pwd := " ".intercalate ((phrase.extract 0 secretWords).map (words[·.toNat]!)).toList
  Argon2.argon2id pwd.toUTF8 ("parity39/passphrase/v1:" ++ salt).toUTF8 t kib 1 32

inductive Reading where
  /-- the phrase, and what had to be corrected -/
  | ok (phrase : Array UInt16) (fixes : Array String)
  | wrongSalt
  | ambiguous (count : Nat)
  | unreadable

private def place (pos : Nat) : String := s!"word {pos} (room {(pos - 1) / 4 + 1}, spot {(pos - 1) % 4 + 1})"

def read (toks : Array (Option UInt16)) (salt : String) : Reading :=
  let sym := saltSymbol salt
  let cands := Repair.repair parityWords length toks false 3 #[some sym]
  if cands.isEmpty then .unreadable
  else if cands.size > 1 then .ambiguous cands.size
  else
    let c := cands[0]!
    if c.virt != #[sym] then .wrongSalt
    else .ok c.phrase <| c.edits.map fun e =>
      let w := (e.word.map word).getD ""
      match e.kind with
      | "swap" => s!"{place e.pos} and {place e.pos2} were in each other's places"
      | "wrong" => s!"{place e.pos} should be {w}"
      | "blank" => s!"{place e.pos} is {w}"
      | "dropped" => s!"a word was missing: {place e.pos} is {w}"
      | _ => s!"the word typed in position {e.pos} does not belong"

end Parity39.Passphrase
