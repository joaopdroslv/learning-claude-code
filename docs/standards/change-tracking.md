# Change Tracking

Every change to this project — feature, fix, refactor, or documentation update — is logged as a decision record (ADR) under `docs/decisions/`. The ADR captures **what** changed and **why**.

The [decisions index](../decisions/README.md) sorts ADRs by date with a one-line summary, status, and link to detail. That single artifact serves both as the project's change history and as the entry point into the long-form rationale.

Use the `/log-decision <FEATURE_NAME> "<summary>" [type]` slash command to scaffold a new ADR and insert its index row in one step.

For ADR naming, template, and status lifecycle see [`decision-records.md`](./decision-records.md).

## What counts as a change

- Any modification to project conventions, structure, or tooling.
- Any new feature, fix, refactor, or documentation update worth being able to find later.
- Trivial typo fixes or whitespace-only edits do not need an ADR.

When in doubt, log it. ADRs are cheap to write and expensive to wish you had.
