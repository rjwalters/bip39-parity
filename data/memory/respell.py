"""Re-spell a BIP39+parity phrase in the memory vocabulary (same symbols, other words), and back.

Usage: respell.py <bip39 words...>
Rule for a room with no object: exchange its last word with a spare object from the
parity room (else from the nearest room with two or more). The decoder undoes it
by trying swaps; only one arrangement satisfies the parity checks.
"""
import sys
bip = open("data/english.txt").read().split()
mem = open("data/memory/words.txt").read().split()
nobj = len(open("data/memory/objects.txt").read().split())
idx = [bip.index(w) for w in sys.argv[1:]]
rooms = [idx[i:i + 4] for i in range(0, len(idx), 4)]
is_obj = lambda i: i < nobj
notes = []
for r, room in enumerate(rooms):
    if any(map(is_obj, room)):
        continue
    donors = sorted((d for d in range(len(rooms)) if sum(map(is_obj, rooms[d])) >= 2),
                    key=lambda d: (d != len(rooms) - 1, abs(d - r)))
    if not donors:
        notes.append(f"room {r + 1} has no object and nothing to borrow"); continue
    d = donors[0]; j = next(j for j, v in enumerate(rooms[d]) if is_obj(v))
    rooms[r][3], rooms[d][j] = rooms[d][j], rooms[r][3]
    notes.append(f"room {r + 1} had no object: swapped its 4th word with word {j + 1} of room {d + 1}")
for r, room in enumerate(rooms):
    name = "parity" if r == len(rooms) - 1 else f"room {r + 1}"
    print(f"  {name}:  " + "  ".join(mem[i] if is_obj(i) else mem[i].upper() for i in room))
for n in notes: print("  note:", n)
