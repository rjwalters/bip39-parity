<!-- BEGIN ANVIL -->
This repository uses [Anvil](https://github.com/rjwalters/anvil) for AI-powered artifact creation. See `.anvil/CLAUDE.md` for the full guide (skills, rubric, state machine). To upgrade Anvil, re-run `install-anvil.sh .` from the anvil checkout without `--skills=` to pick up newly-shipped skills; pass `--skills=...` only to install a strict subset.
In Codex, an installed skill is registered at `.agents/skills/anvil-<skill>/SKILL.md` -- invoke it from the skill picker by name; the registration is a thin pointer back to the canonical body under `.anvil/skills/<skill>/`.
<!-- END ANVIL -->
