# Project Standards

Each file in this folder is a focused, independently-editable rule-set imported by [`CLAUDE.md`](../../CLAUDE.md) via Claude Code's `@`-syntax. The rules become part of every conversation automatically.

## Files

| File | Scope |
|------|-------|
| [`language.md`](./language.md) | The English-only rule for persisted artifacts. |
| [`change-tracking.md`](./change-tracking.md) | When to log a change; how the decisions index serves as the change history. |
| [`decision-records.md`](./decision-records.md) | ADR naming, template, and status lifecycle. |

## Adding a new standard

1. Create `docs/standards/<topic>.md` with the rule.
2. Add an `@docs/standards/<topic>.md` import to `CLAUDE.md` under a matching heading.
3. Log it as a decision record (`/log-decision`).

Keep each file narrow and focused. If a file starts to mix concerns, split it.
