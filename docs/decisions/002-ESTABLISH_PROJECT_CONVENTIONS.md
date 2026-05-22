# ESTABLISH_PROJECT_CONVENTIONS

**ID:** ADR-002
**Timestamp:** 2026-05-22 14:15
**Status:** Accepted
**Type:** docs

## Context

This repository is a playground for codifying solid patterns for working with Claude Code. The structure itself is a learning artifact — it must be best-in-class so the project can serve as a reference. The aim is a repo that an experienced Claude Code user would recognize as well-organized on first contact.

Specific concerns:

- Where do project rules live, and how does the assistant discover them?
- How is the *why* behind each change preserved (not just the diff)?
- How is friction kept low enough that the discipline survives daily use?
- How is the structure discoverable to both the model and human readers?

## Decision

Adopt the following conventions from project inception:

1. **Two audiences, two entry points.** `README.md` targets humans landing in the repo; `CLAUDE.md` targets the model. They serve different purposes and do not duplicate content.

2. **Modular guidelines via `@`-imports.** `CLAUDE.md` is a thin index. Each rule-set lives in `docs/standards/<topic>.md` and is pulled in via Claude Code's `@`-import syntax, so it loads automatically into every conversation while remaining independently editable.

3. **One artifact per change.** Every change produces a decision record under `docs/decisions/`. The decisions index (date, status, one-line summary) doubles as the project's change history, so a single artifact serves both roles.

4. **Sequential ADR numbering: `NNN-FEATURE_NAME.md`.** Zero-padded three digits. Short, citeable as `ADR-NNN`, stable across branches, and the dominant industry convention.

5. **Nygard-format ADR template.** Every record contains `ID`, `Timestamp`, `Status`, `Type`, `Context`, `Decision`, `Alternatives considered`, and `Consequences`. Superseded records are never deleted — their `Status` is updated and they link forward to the replacement.

6. **`.claude/` ecosystem from day one.** Custom slash commands (`.claude/commands/`), subagents (`.claude/agents/`), and shared settings (`.claude/settings.json`) are version-controlled. Personal overrides go in `.claude/settings.local.json` (gitignored).

7. **`/log-decision` slash command** scaffolds a new ADR and inserts its row in the decisions index in a single step. Friction kept low so the discipline survives.

## Alternatives considered

- **Timestamp-based ADR naming (`FEATURE-YYYYMMDDTHHMM.md`)** — rejected. Sortable but verbose. Sequential numbering produces shorter references (`ADR-007`), composes cleanly with status pointers (`Superseded by ADR-012`), and is the dominant convention.
- **Monolithic `CLAUDE.md`** — rejected. Grows unboundedly, mixes concerns, hard to evolve. The `@`-import approach preserves always-loaded behavior with cleaner organization.
- **Separate scannable summary file alongside ADRs** — rejected. The decisions index already provides a date-sorted, one-line-per-change view linked to detail; a second file would duplicate that summary and inevitably drift from the ADRs themselves.
- **Skip ADRs entirely** — rejected. Loses the *why* behind each change, which is the highest-value artifact for future readers.
- **`documentation/` instead of `docs/`** — rejected. `docs/` is the dominant convention (GitHub Pages default), shorter, immediately recognized.
- **Diátaxis split (`tutorials/`, `how-to/`, `reference/`, `explanation/`)** — deferred. Premature for the current scale; revisit when `docs/` grows substantially.

## Consequences

**Positive:**
- Structure is immediately recognizable to anyone familiar with Claude Code or ADR conventions.
- Reasoning preserved alongside the code, not lost to chat history.
- `@`-imports let standards evolve independently without touching `CLAUDE.md`.
- `/log-decision` removes the cost of compliance — the discipline survives because following it is cheap.
- Sequential ADR numbers stay short and citeable forever.

**Negative:**
- Sequential numbering creates a coordination point if multiple branches add ADRs simultaneously — rare for a solo project; revisit if the team grows.
- More moving parts than a flat repository — justified by the project's purpose.
