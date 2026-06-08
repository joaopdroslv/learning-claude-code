# SPLIT_REFERENCE_AND_STANDARDS

**ID:** ADR-009
**Timestamp:** 2026-06-08 11:56
**Status:** Accepted
**Type:** docs

## Context

`docs/standards/` was meant to hold rule-sets — the patterns to follow when editing
the project, `@`-imported into every Claude Code conversation via `CLAUDE.md`. Over
time it also accumulated `project-layout.md`, which is mostly *descriptive*: a tree of
the repository and notes on audiences and discoverability. That blurred the folder's
purpose — a reader could no longer tell, from the location alone, whether a file was a
rule to obey or a description to consult.

The repository already had an empty `docs/reference/` placeholder earmarked for
descriptive documentation, but nothing had been moved into it, and the project lacked a
single "what is this and how is it laid out" entry point separate from the
human-oriented root `README.md`.

## Decision

Establish a clean split:

- **`docs/standards/`** holds rules and patterns only: `language.md`,
  `change-tracking.md`, `decision-records.md`.
- **`docs/reference/`** holds descriptive documentation: `overview.md` (what the
  project is, the stack, getting started) and `layout.md` (the full repository tree and
  what lives where).

Concretely:

- Moved `docs/standards/project-layout.md` → `docs/reference/layout.md` and expanded its
  tree to cover the whole repository (`app/`, `migrations/`, `scripts/`, `docker/`,
  `.devcontainer/`), not just the docs skeleton.
- Added `docs/reference/overview.md`.
- Repointed the `## Project layout` `@`-import in `CLAUDE.md` to
  `@docs/reference/layout.md` — the layout stays auto-loaded into every conversation
  because the structure is useful standing context for the model.
- Updated every index (`docs/README.md`, `docs/reference/README.md`,
  `docs/standards/README.md`) and the root `README.md`, and brought the self-contained
  `SETUP.md` template in line with the new structure.

## Alternatives considered

- **Leave layout under `docs/standards/`**: rejected — it kept the rules/docs distinction
  muddy and made `standards/` a grab-bag rather than a focused rule-set.
- **Drop the layout `@`-import from `CLAUDE.md` once it became reference**: rejected —
  the repository tree is cheap, compact context that the model benefits from having in
  every conversation. `CLAUDE.md` now imports rule-sets from `standards/` *plus* this one
  reference doc, and its intro says so.

## Consequences

**Positive:**
- Location now signals intent: `standards/` = rules to obey, `reference/` = docs to consult.
- `docs/reference/` is populated with a real overview and a complete repository layout.
- `SETUP.md` reproduces the cleaner structure in any new repo bootstrapped from it.

**Negative:**
- `CLAUDE.md` no longer imports *exclusively* from `docs/standards/`; the one reference
  import is a documented exception that future maintainers must keep in mind when
  reasoning about "where do imports come from".
