import Parity39

open Parity39

def usage : String :=
"parity39 — Reed–Solomon parity words for BIP39 phrases (N+k)

  parity39 encode -k K <words…>     append K parity words to a phrase
  parity39 check  -k K <words…>     verify a protected phrase
  parity39 repair -k K <words…>     find the closest valid phrase(s)
  parity39 split   -k K -t T -n N <seed words…>          deal N cards, any T recover
  parity39 combine -k K -t T <card> / <card> / …         recover from cards

Options:
  -k K        number of parity words (required)
  --data N    number of data words (repair; default: nearest BIP39 length)
  --raw       data words are not a BIP39 phrase: ignore the BIP39 checksum
  --digest D  digest words inside each card (split/combine; default 2)

A card is its words, optionally preceded by its number and a colon: 3: word word …

In `repair`, write ? for a word you know is missing or cannot read.
Words may be abbreviated to their first four letters.
"

structure Args where
  k : Option Nat := none
  data : Option Nat := none
  raw : Bool := false
  t : Option Nat := none
  n : Option Nat := none
  digest : Nat := 2
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
  | "-t" :: v :: rest, a =>
    match v.toNat? with
    | some t => parseArgs rest { a with t := some t }
    | none => throw s!"-t expects a number, got '{v}'"
  | "-n" :: v :: rest, a =>
    match v.toNat? with
    | some n => parseArgs rest { a with n := some n }
    | none => throw s!"-n expects a number, got '{v}'"
  | "--digest" :: v :: rest, a =>
    match v.toNat? with
    | some d => parseArgs rest { a with digest := d }
    | none => throw s!"--digest expects a number, got '{v}'"
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

def randomRow (n : Nat) : IO (Array UInt16) := do
  let b ← IO.getRandomBytes (2 * n).toUSize
  return (Array.range n).map fun i =>
    ((b[2 * i]!.toUInt16 <<< 8) ||| b[2 * i + 1]!.toUInt16) &&& 0x7ff

def runSplit (a : Args) : IO UInt32 := do
  let (some k, some t, some n) := (a.k, a.t, a.n)
    | do IO.eprintln "split needs -k, -t and -n"; return 2
  let toks ← readTokens a.words
  if toks.any Option.isNone then
    IO.eprintln "split needs every seed word"; return 2
  let seed := toks.map (·.getD 0)
  if !a.raw && Bip39.checksumOk seed != some true then
    IO.eprintln s!"seed words: {bip39Label (Bip39.checksumOk seed)} (use --raw to split anyway)"
    return 1
  let p : Grid.Params := { k, t, nData := seed.size + a.digest, digest := a.digest }
  let mut rand : Array (Array UInt16) := #[]
  for _ in [0:t - 1] do
    rand := rand.push (← randomRow p.nData)
  match Grid.deal p (seed ++ Grid.digestWords a.digest seed) rand n with
  | none => IO.eprintln "cannot deal: need 1 ≤ t ≤ n ≤ 31"; return 2
  | some cards =>
    IO.println s!"{n} cards, any {t} recover. Each: {seed.size} seed-share + {a.digest} digest + {k} parity words."
    for i in [0:cards.size] do
      IO.println s!"{i + 1}: {Wordlist.render cards[i]!}"
    return 0

def runCombine (a : Args) : IO UInt32 := do
  let (some k, some t) := (a.k, a.t) | do IO.eprintln "combine needs -k and -t"; return 2
  let seedWords := a.data.getD 24
  let p : Grid.Params := { k, t, nData := seedWords + a.digest, digest := a.digest }
  let mut cards : Array Grid.Card := #[]
  for group in (a.words.toList.splitBy (· != "/" && · != "/")).map (·.filter (· != "/")) do
    if group.isEmpty then continue
    let (label, rest) := match group with
      | first :: more =>
        match first.splitOn ":" with
        | [num, ""] => (num.toNat?, more)
        | _ => (none, group)
      | [] => (none, [])
    cards := cards.push { toks := ← readTokens rest.toArray, label }
  let res := Grid.combine p cards
  for row in res.rows do
    let state := if row.verified then "confirmed" else "NOT confirmed"
    IO.println s!"card {row.index}: {state}"
    for note in row.notes do
      IO.println s!"  - {note}"
  for note in res.notes do
    IO.println s!"note: {note}"
  match res.secret with
  | none => IO.println "No secret recovered."; return 1
  | some s =>
    let seed := s.extract 0 seedWords
    IO.println ""
    IO.println (Wordlist.render seed)
    let check := match res.checked with
      | some true => "digest ok"
      | some false => "digest FAILED"
      | none => "no digest"
    IO.println s!"  ({check}; {bip39Label (Bip39.checksumOk seed)})"
    return 0

def main (args : List String) : IO UInt32 :=
  match args with
  | "split" :: rest =>
    match parseArgs rest {} with
    | .ok a => runSplit a
    | .error e => do IO.eprintln e; return 2
  | "combine" :: rest =>
    match parseArgs rest {} with
    | .ok a => runCombine a
    | .error e => do IO.eprintln e; return 2
  | cmd :: rest =>
    match parseArgs rest {} with
    | .ok a => run cmd a
    | .error e => do IO.eprintln e; return 2
  | [] => do IO.eprint usage; return 2
