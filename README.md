# learning-claude-code

A playground for codifying solid patterns for working with [Claude Code](https://claude.com/claude-code) — custom slash commands, subagents, hooks, settings, and disciplined documentation conventions.

## Repository layout

| Path | What lives here |
|------|-----------------|
| `CLAUDE.md` | Project guidelines (thin index, auto-loaded into every conversation). |
| `README.md` | This file. Human-facing overview. |
| `docs/standards/` | Project rule-sets, `@`-imported by `CLAUDE.md`. |
| `docs/decisions/` | Decision records (ADRs), one Markdown file per change. |
| `.claude/commands/` | Custom slash commands (e.g. `/log-decision`). |
| `.claude/agents/` | Custom Claude Code subagents. |
| `.claude/settings.json` | Shared Claude Code settings (committed). |
| `.claude/settings.local.json` | Personal overrides (gitignored). |

## How changes are tracked

Every change — feature, fix, refactor, or documentation update — is logged as a numbered decision record (ADR) under `docs/decisions/`. ADRs carry the full rationale (context, decision, alternatives, consequences); the [decisions index](./docs/decisions/README.md) doubles as a scannable change history (date, status, one-line summary).

Use `/log-decision <FEATURE_NAME> "<summary>" [type]` to scaffold a new ADR and update the index in one step. ADRs are numbered sequentially (`001`, `002`, ...) and referenced in prose as `ADR-NNN`.

## Conventions in one sentence

All code, comments, and documentation are written in English; every change is captured as a numbered ADR under `docs/decisions/`.

For the full rule-set see [`CLAUDE.md`](./CLAUDE.md), which `@`-imports each standard from [`docs/standards/`](./docs/standards/README.md).
