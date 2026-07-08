# Project Guidelines

Each section below imports a focused rule-set from `docs/standards/`, plus the repository layout from `docs/reference/`. Every `@`-referenced file is auto-loaded by Claude Code into the context of every conversation in this repository.

## Language
@docs/standards/language.md

## Architecture
@docs/standards/architecture.md

## Project layout
@docs/reference/layout.md

## Change tracking
@docs/standards/change-tracking.md

## Decision records
@docs/standards/decision-records.md

## Maintaining these guidelines

This file is an **index**, not a rule-set. Rules live in `docs/standards/`.

When a new rule emerges:

1. If it fits an existing standard, extend that file.
2. If it is a new concern, create `docs/standards/<topic>.md` and add an `@`-import above under a matching heading.
3. Log it as a decision record with `/log-decision`.

Keep this file lean — its job is to point, not to explain.
