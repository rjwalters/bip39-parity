import Std.Data.HashMap

/-! # The BIP39 English wordlist (embedded at compile time from `data/english.txt`). -/

namespace Parity39.Wordlist

private def raw : String := include_str "../data/english.txt"

def words : Array String :=
  ((raw.splitOn "\n").filter (· ≠ "")).toArray

private def index : Std.HashMap String Nat := Id.run do
  let mut m : Std.HashMap String Nat := {}
  for i in [0:words.size] do
    m := m.insert words[i]! i
  return m

def word (i : UInt16) : String := words.getD i.toNat "<invalid>"

/--
Look a token up. Exact match, or a unique prefix of at least 4 letters
(BIP39 words are uniquely determined by their first four letters).
-/
def lookup (tok : String) : Option UInt16 :=
  let tok := tok.toLower
  match index[tok]? with
  | some i => some i.toUInt16
  | none =>
    if tok.length < 4 then none
    else
      match (Array.range words.size).filter (fun i => tok.isPrefixOf words[i]!) with
      | #[i] => some i.toUInt16
      | _ => none

def render (ws : Array UInt16) : String :=
  " ".intercalate (ws.map word).toList

end Parity39.Wordlist
