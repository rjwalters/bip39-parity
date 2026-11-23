"""Random three-room passphrases: 10 secret words + 2 parity words, in the memory vocabulary.
Regenerates until every room ends in an object, so each modifier describes the
next object in its room. Practice only."""
import secrets, subprocess, sys
bip = open("data/english.txt").read().split()
mem = open("data/memory/words.txt").read().split()
nobj = len(open("data/memory/objects.txt").read().split())
for n in range(int(sys.argv[1]) if len(sys.argv) > 1 else 2):
    tries = 0
    while True:
        tries += 1
        data = [secrets.randbelow(2048) for _ in range(10)]
        out = subprocess.run([".lake/build/bin/parity39", "encode", "-k", "2", "--raw", *[bip[i] for i in data]],
                             capture_output=True, text=True).stdout.split()
        idx = [bip.index(w) for w in out]
        rooms = [idx[i:i + 4] for i in range(0, 12, 4)]
        if all(r[3] < nobj for r in rooms): break
    print(f"example {n + 1}" + (f"  (regenerated {tries - 1}x until every room ends in an object)" if tries > 1 else ""))
    for r, room in enumerate(rooms):
        print(f"  room {r + 1}:  " + "  ".join(mem[i] if i < nobj else mem[i].upper() for i in room))
    print()
