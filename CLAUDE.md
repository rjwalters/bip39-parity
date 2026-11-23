<!-- BEGIN ANVIL -->
This repository uses [Anvil](https://github.com/rjwalters/anvil) for AI-powered artifact creation. See `.anvil/CLAUDE.md` for the full guide (skills, rubric, state machine). To upgrade Anvil, re-run `install-anvil.sh .` from the anvil checkout without `--skills=` to pick up newly-shipped skills; pass `--skills=...` only to install a strict subset.
In Claude Code, invoke an installed skill via `/anvil:<skill>` (e.g. `/anvil:paper-draft <slug>`) -- the per-skill registration shim lives at `.claude/skills/anvil-<skill>/`.
<!-- END ANVIL -->

When writing or optimising compiled Lean here, read `docs/lean-performance.md` first, and add what you measure to it.

<!-- BEGIN REPO-SKILLS -->
This repository has [Repo Skills](https://github.com/2AMLogic/repo) v0.27.0 installed —
general repository hygiene and environment commands invoked as `/repo:<command>`. Run
`/repo:help` for the command list, or see `.claude/skills/repo/SKILL.md` for the full
guide. Hygiene commands apply safe, reversible fixes by default and report each
change; run with `--ask` to review first, and `--prune` to allow irreversible
removals. Managed by `install.sh` — edit outside the markers only.
<!-- END REPO-SKILLS -->
