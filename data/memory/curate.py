"""Curate the memory vocabulary to exactly 2048 words.

Rules: 4-9 letters; the first four letters identify the word (as in BIP39); no two
words one letter apart; no word a prefix of another; listed near-synonyms removed.
Modifiers are kept first (they are scarcer), then objects closest to six letters.
"""
import sys
MIN, MAX, TOTAL = 4, 9, 2048
SYN = """vessel boat sofa couch pony stallion colt foal hound bunny piglet swine cab limo limousine lorry trolley
purse satchel knapsack rucksack valise luggage pail tub washtub dustbin gown frock cloak cape overcoat raincoat
grandma grandpa infant toddler padre vicar friar abbot pontiff rabbi sheik emir earl duke viscount baron
tepee wigwam teepee hut shack shanty lodge cottage chalet villa manor inn hostel motel pub tavern saloon
skiff dinghy rowboat towboat tugboat lifeboat longboat gunboat riverboat speedboat warship cruiser frigate galleon schooner
creek gorge ravine crevasse quay wharf jetty pier marsh swamp quagmire glade meadow pasture prairie savanna
stone pebble boulder rubble gravel dagger saber rapier cutlass scimitar katana machete pistol revolver musket rifle shotgun popgun
tiny mini miniature little huge giant gigantic massive colossal jumbo smelly stinky filthy dirty wicked evil
burnt scorched toasted soaked drenched wet damp angry furious sad happy jolly speedy fast quick silent quiet loud noisy
crawfish codfish whitefish shellfish jaybird bluejay blackbird wildcat bobcat polecat woodchuck groundhog possum opossum
mailbag postbox mailman milkman doorman rifleman nursemaid servant valet steward waitress waiter seagull gull
pianola victrola phonograph telegram telegraph xerox virgin nipple navel udder urinal latrine commode manure hearse morgue gallows pillory napalm landmine
""".split()
def one_apart(a, b):
    if abs(len(a) - len(b)) > 1: return False
    if len(a) == len(b): return sum(x != y for x, y in zip(a, b)) == 1
    if len(a) > len(b): a, b = b, a
    return any(b[:i] + b[i + 1:] == a for i in range(len(b)))
read = lambda f: open(f"data/memory/{f}").read().split()
mods = read("modifiers_pool.txt"); objs = read("objects_pool.txt") + read("extra_objects.txt")
pool = [(w, "m") for w in sorted(set(mods), key=lambda w: (abs(len(w) - 6), w))] + \
       [(w, "o") for w in sorted(set(objs) - set(mods), key=lambda w: (abs(len(w) - 6), w))]
kept, pre, why = [], set(), {"length": 0, "synonym": 0, "prefix": 0, "lookalike": 0}
for w, kind in pool:
    if not (w.isalpha() and MIN <= len(w) <= MAX): why["length"] += 1; continue
    if w in SYN: why["synonym"] += 1; continue
    if w[:4] in pre: why["prefix"] += 1; continue
    if any(one_apart(w, k) for k, _ in kept): why["lookalike"] += 1; continue
    kept.append((w, kind)); pre.add(w[:4])
obj = sorted(w for w, k in kept if k == "o"); mod = sorted(w for w, k in kept if k == "m")
print(f"pool {len(pool)}; rejected {why}; kept {len(obj)} objects + {len(mod)} modifiers = {len(kept)}")
if len(kept) >= TOTAL:
    obj = sorted(sorted(obj, key=lambda w: (abs(len(w) - 6), w))[:TOTAL - len(mod)])
    open("data/memory/objects.txt", "w").write("\n".join(obj) + "\n")
    open("data/memory/modifiers.txt", "w").write("\n".join(mod) + "\n")
    open("data/memory/words.txt", "w").write("\n".join(obj + mod) + "\n")
    print(f"wrote {len(obj)} objects ({100 * len(obj) // TOTAL}%) + {len(mod)} modifiers = {len(obj) + len(mod)}")
else:
    print(f"SHORT by {TOTAL - len(kept)}; lists not rewritten")
