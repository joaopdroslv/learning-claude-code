# Decision Records

Long-form rationale for every change in this project. One Markdown file per decision, stored under `docs/decisions/`.

## Naming

Pattern: `NNN-FEATURE_NAME.md`

- `NNN` — zero-padded sequential number (`001`, `002`, ..., `999`). A new decision takes `<highest existing number> + 1`.
- `FEATURE_NAME` — short English name, all uppercase, words joined by `_` (e.g. `ADD_LOGIN_FLOW`).
- Examples: `001-ADOPT_ENGLISH_ONLY.md`, `042-MIGRATE_TO_POSTGRES.md`.

Reference shorthand in prose: **ADR-NNN** (e.g. "see ADR-002").

## Required sections

```markdown
# <FEATURE_NAME>

**ID:** ADR-NNN
**Timestamp:** YYYY-MM-DD HH:mm
**Status:** Proposed | Accepted | Superseded by ADR-NNN | Deprecated
**Type:** feature | fix | docs | chore | refactor

## Context
What problem is this solving? What constraints matter?

## Decision
What we are doing, concretely.

## Alternatives considered
- option: why not.

## Consequences
**Positive:**
- what this unlocks.

**Negative:**
- trade-off we accept.
```

## Status lifecycle

- **Proposed** — written but not yet acted on.
- **Accepted** — implemented; this is the current rule.
- **Superseded by ADR-NNN** — a later decision overrides this one. The old file is **never deleted**; the new decision's Context section links back.
- **Deprecated** — the practice is no longer in use, but no direct replacement exists.

When superseding: update the old record's `Status:` line to `Superseded by ADR-NNN` and add a short `## Superseded by` section at the bottom linking to the new record.

## Index

[`docs/decisions/README.md`](../decisions/README.md) is a table indexing every ADR (number, status, date, summary). Add a row when you create a new record — the `/log-decision` command does this for you.

## Tone

ADRs are written for a future reader who has none of today's context. Favor:

- Concrete problem statements over abstract motivation.
- Named alternatives with concrete rejection reasons.
- Honest trade-offs in the Consequences section — including the *negative* ones.
