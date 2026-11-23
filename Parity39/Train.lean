import Parity39.Repair

open Parity39

/-!
# Rehearsal trainer

Checks a phrase typed from memory and coaches without knowing the answer in
advance: the parity words locate the mistakes. Nothing secret is stored. The
log records positions and kinds of mistakes, never words.
-/

namespace Train

def schedule : String :=
"Rehearse (a two-minute walk through the rooms, forwards then backwards):
  today: now, in an hour, and before sleep      then: tomorrow morning,
  day 3, 7, 14, 30, 60, 120, and twice a year after that.
Check with `parity39 train` at each of those from day 7 on: a mistake that is
rehearsed unchecked gets stronger."

def firstLine (s : String) : String := (s.splitOn "\n").headD ""

def nowIso : IO String := do
  let out ← IO.Process.output { cmd := "date", args := #["-u", "+%Y-%m-%dT%H:%M:%SZ"] }
  return firstLine out.stdout

def logPath : IO System.FilePath := do
  match ← IO.getEnv "PARITY39_LOG" with
  | some p => return p
  | none =>
    let home := (← IO.getEnv "HOME").getD "."
    return (home : System.FilePath) / ".parity39" / "train.tsv"

def appendLog (line : String) : IO Unit := do
  let path ← logPath
  if let some dir := path.parent then IO.FS.createDirAll dir
  let h ← IO.FS.Handle.mk path .append
  h.putStrLn line

/-- Where a word lives when the palace has four words to a room. -/
def place (pos : Nat) : String :=
  s!"word {pos} (room {(pos - 1) / 4 + 1}, spot {(pos - 1) % 4 + 1})"

def editTag (e : Repair.Edit) : String :=
  if e.kind == "swap" then s!"swap@{e.pos}-{e.pos2}" else s!"{e.kind}@{e.pos}"

def describe (e : Repair.Edit) (letters : Bool) : String :=
  let start := match e.word with
    | some w =>
      if letters then s!" It starts with '{String.ofList ((Wordlist.word w).toList.take 2)}'." else ""
    | none => ""
  match e.kind with
  | "swap" => s!"{place e.pos} and {place e.pos2} are in each other's places."
  | "wrong" => s!"{place e.pos} is not the right word.{start}"
  | "blank" => s!"{place e.pos} is the one you left blank.{start}"
  | "dropped" => s!"a word is missing: it belongs at {place e.pos}.{start}"
  | "extra" => s!"the word you typed in position {e.pos} does not belong."
  | _ => ""

inductive Outcome where
  | correct
  | fix (c : Repair.Candidate)
  | ambiguous (cs : Array Repair.Candidate)
  | lost

def judge (k n : Nat) (raw : Bool) (toks : Array (Option UInt16)) : Outcome :=
  let cands := Repair.repair k n toks (!raw)
  if cands.isEmpty then .lost
  else if cands.size > 1 then .ambiguous cands
  else if cands[0]!.edits.isEmpty then .correct
  else .fix cands[0]!

def Outcome.tag : Outcome → String
  | .correct => "ok\t0\t"
  | .fix c => s!"fix\t{c.edits.size}\t{",".intercalate (c.edits.map editTag).toList}"
  | .ambiguous cs => s!"ambiguous\t{cs.size}\t"
  | .lost => "lost\t\t"

/-- Feedback at hint level 1 (count), 2 (where), 3 (first letters) or 4 (everything). -/
def feedback (k : Nat) (o : Outcome) (level : Nat) : Array String :=
  match o with
  | .correct => #["Correct. Every word, in order."]
  | .lost =>
    #[s!"Too far off to locate: more mistakes than {k} parity words can pin down.",
      "Walk the rooms again and retype. (There is nothing to show: the trainer does not know your phrase.)"]
  | .ambiguous cs =>
    if level < 4 then
      #[s!"Close, but {cs.size} different phrases fit equally well, so the mistakes cannot be pinned down.",
        "Try again, or type `show` to see the candidates."]
    else cs.map (fun c => Wordlist.render c.phrase)
  | .fix c =>
    let head := s!"Not yet: {c.edits.size} thing{if c.edits.size == 1 then "" else "s"} to fix."
    if level ≤ 1 then #[head, "Think again and retype, or type `hint`."]
    else if level ≤ 3 then
      #[head] ++ c.edits.map (fun e => "  - " ++ describe e (level == 3))
        ++ #[if level == 2 then "Retype, or `hint` for first letters." else "Retype, or `show`."]
    else #[Wordlist.render c.phrase] ++ c.notes.map ("  - " ++ ·)

def readTokens (line : String) : Array (Option UInt16) :=
  ((line.splitOn " ").filter (· ≠ "")).toArray.map fun t =>
    if t == "?" || t == "_" then none else Wordlist.lookup t

def session (k nData : Nat) (raw : Bool) : IO UInt32 := do
  let n := nData + k
  let stdin ← IO.getStdin
  IO.println s!"Type all {n} words from memory: {nData} phrase words, then the {k} parity words"
  IO.println "(from memory or from your note). Use ? for a word you cannot recall."
  IO.println "Commands: hint, show, quit. Nothing you type is stored; only positions of mistakes are logged."
  let mut attempt := 0
  let mut level := 1
  let mut last : Option Outcome := none
  repeat
    IO.print "> "
    (← IO.getStdout).flush
    let raw_line ← stdin.getLine
    if raw_line.isEmpty then break
    let line := firstLine raw_line
    if line == "quit" || line == "q" then break
    if line == "" then continue
    if line == "hint" || line == "show" then
      match last with
      | none => IO.println "Type the phrase first."
      | some o =>
        level := if line == "show" then 4 else min 3 (level + 1)
        for l in feedback k o level do IO.println l
      continue
    attempt := attempt + 1
    let o := judge k n raw (readTokens line)
    appendLog s!"{← nowIso}\t{nData}\t{k}\t{attempt}\t{level}\t{o.tag}"
    level := 1
    last := some o
    for l in feedback k o 1 do IO.println l
    if let .correct := o then
      if attempt == 1 then IO.println "First try. Lengthen the gap before the next check."
      else IO.println s!"Got there on attempt {attempt}. Re-walk the spots that failed, and check again tomorrow."
      break
  return 0

def new (k nData : Nat) : IO UInt32 := do
  let some data := Bip39.fromEntropy (← IO.getRandomBytes (nData * 4 / 3).toUSize)
    | do IO.eprintln "--data must be 12, 15, 18, 21 or 24"; return 2
  let some c := RS.encode k data | do IO.eprintln "phrase too long"; return 2
  IO.println "PRACTICE PHRASE. For training only: never fund a wallet with it."
  IO.println ""
  for room in [0:(nData + 3) / 4] do
    let ws := (c.extract (4 * room) (min nData (4 * room + 4))).map Wordlist.word
    IO.println s!"  room {room + 1}:  {" ".intercalate ws.toList}"
  IO.println s!"  parity:  {" ".intercalate ((c.extract nData c.size).map Wordlist.word).toList}"
  IO.println ""
  IO.println "Four words to a room, clockwise from the door. Make each word's picture do"
  IO.println "something to the furniture at its spot. Recall each room before the next,"
  IO.println "then walk the whole route backwards. Keep the parity words on a note, or"
  IO.println "give them a last room of their own."
  IO.println ""
  IO.println schedule
  return 0

def stats : IO UInt32 := do
  let path ← logPath
  if !(← path.pathExists) then
    IO.println "No checks logged yet."; return 0
  let lines := ((← IO.FS.readFile path).splitOn "\n").filter (· ≠ "")
  let mut checks := 0
  let mut firstTry := 0
  let mut misses : Array Nat := Array.replicate 64 0
  let mut lastCheck := ""
  for l in lines do
    match l.splitOn "\t" with
    | [time, _, _, attempt, _, result, _, edits] =>
      if attempt == "1" then
        checks := checks + 1
        lastCheck := time
        if result == "ok" then firstTry := firstTry + 1
        for e in (edits.splitOn ",").filter (· ≠ "") do
          for p in (((e.splitOn "@").getD 1 "").splitOn "-").filterMap String.toNat? do
            if p < 64 then misses := misses.modify p (· + 1)
    | _ => pure ()
  IO.println s!"{checks} check(s), {firstTry} right first time. Last check: {lastCheck}"
  let weak := (Array.range 64).filter (misses[·]! > 0)
  if weak.isEmpty then IO.println "No position has failed on a first attempt."
  else
    IO.println "Positions that failed on a first attempt:"
    for p in weak do
      IO.println s!"  {place p}: {misses[p]!}×"
  return 0

end Train
