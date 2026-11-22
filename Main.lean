import Parity39

open Parity39

def usage : String :=
"parity39 — Reed–Solomon parity words for BIP39 phrases (N+k)

  parity39 encode -k K <words…>     append K parity words to a phrase
  parity39 check  -k K <words…>     verify a protected phrase
  parity39 repair -k K <words…>     find the closest valid phrase(s)

Options:
  -k K        number of parity words (required)
  --data N    number of data words (repair; default: nearest BIP39 length)
  --raw       data words are not a BIP39 phrase: ignore the BIP39 checksum

In `repair`, write ? for a word you know is missing or cannot read.
Words may be abbreviated to their first four letters.
"

structure Args where
  k : Option Nat := none
  data : Option Nat := none
  raw : Bool := false
  words : Array String := #[]

def parseArgs : List String → Args → Except String Args
  | [], a => pure a
  | "-k" :: v :: rest, a =>
    match v.toNat? with
    | some k => parseArgs rest { a with k := some k }
    | none => throw s!"-k expects a number, got '{v}'"
  | "--data" :: v :: rest, a =>
    match v.toNat? with
    | some n => parseArgs rest { a with data := some n }
    | none => throw s!"--data expects a number, got '{v}'"
  | "--raw" :: rest, a => parseArgs rest { a with raw := true }
  | w :: rest, a =>
    parseArgs rest { a with words := a.words ++ ((w.splitOn " ").filter (· ≠ "")).toArray }

/-- Tokens to symbols; `?`/`_` and unrecognised words become erasures. -/
def readTokens (toks : Array String) : IO (Array (Option UInt16)) :=
  toks.mapIdxM fun i t => do
    if t == "?" || t == "_" then return none
    match Wordlist.lookup t with
    | some w => return some w
    | none =>
      IO.eprintln s!"note: word {i + 1} '{t}' is not in the wordlist; treating it as missing"
      return none

def bip39Label : Option Bool → String
  | some true => "BIP39 checksum ok"
  | some false => "BIP39 checksum INVALID"
  | none => "not a BIP39 length"

def run (cmd : String) (a : Args) : IO UInt32 := do
  let some k := a.k | do IO.eprintln "missing -k"; return 2
  let toks ← readTokens a.words
  match cmd with
  | "encode" =>
    if toks.any Option.isNone then
      IO.eprintln "encode needs every word"; return 2
    let data := toks.map (·.getD 0)
    if !a.raw && Bip39.checksumOk data != some true then
      IO.eprintln s!"data words: {bip39Label (Bip39.checksumOk data)} (use --raw to encode anyway)"
      return 1
    match RS.encode k data with
    | some c => IO.println (Wordlist.render c); return 0
    | none => IO.eprintln "phrase too long"; return 2
  | "check" =>
    if toks.any Option.isNone || toks.size < k then
      IO.println "INVALID"; return 1
    let c := toks.map (·.getD 0)
    let b := Bip39.checksumOk (c.extract 0 (c.size - k))
    let ok := RS.isCodeword k c && (a.raw || b == some true)
    IO.println s!"{if ok then "OK" else "INVALID"}  parity: {if RS.isCodeword k c then "ok" else "MISMATCH"}; {bip39Label b}"
    return (if ok then 0 else 1)
  | "repair" =>
    let n := match a.data with
      | some d => d + k
      | none =>
        if a.raw then toks.size
        else
          let dist (len : Nat) := if len + k ≥ toks.size then len + k - toks.size else toks.size - (len + k)
          k + Bip39.validLengths.foldl (fun best len => if dist len < dist best then len else best) 12
    let cands := Repair.repair k n toks (!a.raw)
    if cands.isEmpty then
      IO.println s!"No repair found for a {n - k}+{k} phrase within the code's correction capacity."
      return 1
    if cands.size == 1 && cands[0]!.cost == 0 && cands[0]!.notes.isEmpty then
      IO.println s!"Phrase is valid ({n - k}+{k}); nothing to repair."
      return 0
    if cands.size > 1 then
      IO.println s!"AMBIGUOUS: {cands.size} equally close candidates. Verify each against a known address."
    for c in cands do
      IO.println ""
      IO.println (Wordlist.render c.phrase)
      for note in c.notes do
        IO.println s!"  - {note}"
      IO.println s!"  ({c.cost} edit(s); {bip39Label c.bip39})"
    return (if cands.size == 1 then 0 else 3)
  | _ => IO.eprint usage; return 2

def main (args : List String) : IO UInt32 :=
  match args with
  | cmd :: rest =>
    match parseArgs rest {} with
    | .ok a => run cmd a
    | .error e => do IO.eprintln e; return 2
  | [] => do IO.eprint usage; return 2
