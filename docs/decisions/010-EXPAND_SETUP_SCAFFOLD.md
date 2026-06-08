# EXPAND_SETUP_SCAFFOLD

**ID:** ADR-010
**Timestamp:** 2026-06-08 12:02
**Status:** Accepted
**Type:** docs

## Context

After [ADR-009](./009-SPLIT_REFERENCE_AND_STANDARDS.md) split descriptive docs into
`docs/reference/`, the self-contained `SETUP.md` template still treated `overview.md` as
an optional afterthought ("add one later") and left two gaps in the `.claude/` scaffold:
only `agents/` shipped a README, and `.claude/scripts/` — where this project keeps its
hook scripts — was not part of the bootstrap at all. A fresh repo created from `SETUP.md`
therefore came out less discoverable than this one: no overview, no place for hook
scripts, and `commands/`/`scripts/` with no local index explaining their file format.

## Decision

Make the scaffold complete and self-documenting:

- `docs/reference/overview.md` is now a **default file** the setup creates, with a
  placeholder template (what it is / stack / getting started / documentation map).
- `.claude/scripts/` is created by default, alongside `commands/` and `agents/`.
- Every `.claude/` subdirectory ships a `README.md` documenting its file format —
  added `commands/README.md` (slash-command format) and `scripts/README.md` (hook-script
  conventions) to match the existing `agents/README.md`, in both the repository and the
  `SETUP.md` templates.
- Updated the `SETUP.md` directory tree, the PowerShell/Bash `mkdir` commands, the
  quick-start prompt (now also asks for the stack and substitutes the `overview.md`
  template), and the Customization section.

## Alternatives considered

- **Leave `overview.md` optional**: rejected — every project benefits from a single
  "what is this and how do I run it" doc; making it default removes a decision and a gap.
- **Skip per-directory READMEs for `commands/` and `scripts/`**: rejected — `agents/`
  already sets the precedent, and the local index is what makes each folder
  self-explanatory to a newcomer or to Claude.
- **Fold this into ADR-009**: rejected — 009 is Accepted and scoped to the reference/
  standards split; scaffold completeness is a separate, independently-useful change.

## Consequences

**Positive:**
- A repo bootstrapped from `SETUP.md` is as discoverable as this one: overview present,
  hook-script home present, every `.claude/` subdir indexed.
- The `scripts/README.md` documents the fail-soft hook convention so new hook scripts
  follow it.

**Negative:**
- More files to keep in sync between the live repo and the `SETUP.md` templates; drift
  between them is now a slightly larger surface.
