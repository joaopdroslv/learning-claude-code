# HARDEN_SETUP_SETTINGS_DEFAULTS

**ID:** ADR-011
**Timestamp:** 2026-06-08 12:07
**Status:** Accepted
**Type:** docs

## Context

The `.claude/settings.json` template shipped in `SETUP.md` was minimal: a three-entry git
`allow` list and an empty `deny`. The live repository's settings had since grown a useful
secret-protection `deny` list and an `ask` list for destructive/outward-facing commands.
A fresh project bootstrapped from `SETUP.md` got none of that protection by default.

The constraint: `SETUP.md` is meant to be language-agnostic, so the template must not bake
in Python-specific entries (the live repo's `ask` gates `pip`, and its `deny` lists
Django/Flask paths like `local_settings.py` and `instance/`).

## Decision

Ship a fuller, language-agnostic `settings.json` in the `SETUP.md` template:

- **`deny`** — universal secret protection only: `.env` files (all depths), `secrets/`,
  `*.pem` / `*.key` / `id_rsa` / `credentials`, `.aws/` / `.ssh/`, plus
  `Bash(cat:*.env*)` and `Bash(curl:*)`. Dropped the framework-specific entries
  (`local_settings.py`, `settings_local.py`, `instance/`).
- **`ask`** — `Bash(rm:*)`, `Bash(git push:*)`, `Bash(git reset:*)`. Dropped the Python
  `pip` entries and the project-specific `migrate-down.sh` gate.
- **`allow`** — read-only git only (`status`, `diff`, `log`).

Added prose above the snippet explaining each list, and a Customization bullet telling
adopters how to extend `deny`/`ask` for their stack (framework secret paths, package
manager commands). The live repository's own `.claude/settings.json` is unchanged — it
keeps its Python- and project-specific entries.

## Alternatives considered

- **Copy the live settings verbatim into the template**: rejected — it would bake `pip`
  and Django/Flask paths into a template meant for any language.
- **Keep the template minimal (empty `deny`)**: rejected — secret protection is valuable
  from the first commit and is entirely language-agnostic, so there is no reason to defer it.

## Consequences

**Positive:**
- New projects get secret-leak protection and destructive-command gating out of the box.
- The template stays language-neutral; stack-specific hardening is documented as an
  explicit, opt-in customization step.

**Negative:**
- The template and the live `settings.json` now diverge intentionally (the live one has
  extra Python/project entries), so a reader comparing the two should not expect them to match.
