# ADD_ALEMBIC_WORKFLOW_SCRIPTS

**ID:** ADR-007
**Timestamp:** 2026-05-25 15:40
**Status:** Accepted
**Type:** feature

## Context
ADR-006 set up SQLAlchemy + Alembic. The raw `alembic` CLI works, but a couple of footguns are easy to hit:

- Running `alembic revision --autogenerate` while the DB is behind the head produces a migration that *re-creates* what is already in pending revisions — a silent duplicate that breaks the history.
- The venv's `alembic` binary lives at `.venv/Scripts/alembic` on Windows and `.venv/bin/alembic` on POSIX; remembering which to type is friction.
- There's no obvious "what state is my DB in?" command for someone returning to the project after a break.

We want a thin, safe wrapper layer the human and Claude both use.

## Decision
- **Wrapper scripts under `scripts/db/`**, one per common workflow:
  - `migrate-status.sh` — prints `alembic current`, `heads`, and `history`.
  - `migrate-up.sh` — runs `alembic upgrade head` and reports the resulting revision.
  - `migrate-new.sh "<message>"` — runs `alembic revision --autogenerate` **only if** the DB is at head; otherwise errors out with instructions to run `migrate-up.sh` first. This is the load-bearing safety check.
  - `migrate-down.sh` — runs `alembic downgrade -1` behind an interactive `[y/N]` confirmation.
- **`scripts/db/_alembic.sh`** is a small sourced helper that resolves the venv's alembic path across Windows and POSIX layouts. All four wrappers source it.
- **Slash command `/migrate-new`** at `.claude/commands/migrate-new.md`. It survey's the model diff (`git diff app/models/`), proposes a `snake_case` migration message, confirms with the user, then runs `migrate-new.sh`. The script's safety check still fires — the slash command does not bypass it.
- **`.claude/settings.json` allowlist** extended to `Bash(./scripts/db/migrate-*.sh:*)` so Claude can run these without a permission prompt.
- **Repo layout note**: kept `.claude/scripts/` (harness plumbing, e.g. the `UserPromptSubmit` hook script) and `scripts/` (project workflow scripts) as separate directories. They serve different audiences — `.claude/scripts/` only matters to Claude Code users, `scripts/` is the human-and-Claude shared workflow surface.

## Alternatives considered
- **Just document the alembic commands in a README**: lowest effort, but loses the at-head safety check (the original concern) and doesn't help anyone who doesn't read the README.
- **A `PreToolUse` hook that blocks `Bash(alembic revision ...)` when the DB isn't at head**: more aggressive, but it runs *every* time and adds latency; also, it makes a host-side network call (to MySQL) for every alembic invocation regardless of which subcommand. The wrapper is opt-in and scoped to the dangerous call.
- **A dedicated `migration-engineer` subagent (like `mysql-dev`)**: overkill for a project this small. The `/migrate-new` slash command captures most of the Claude-side reasoning value without a whole subagent.
- **Bake the scripts into `.claude/scripts/` instead of `scripts/db/`**: would conflate harness plumbing with project workflow. A future contributor not using Claude Code would still want to run `migrate-up`.

## Consequences
**Positive:**
- `./scripts/db/migrate-new.sh "<msg>"` can no longer silently produce a duplicate-of-pending migration — the at-head check refuses to run.
- One discovery surface (`scripts/db/`) for every migration verb; `/migrate-new` adds Claude-side intelligence (message proposal from the diff) without removing the safety check.
- Works identically on Windows host and inside the dev container — the alembic-path helper picks the right binary.

**Negative:**
- The at-head check is a heuristic on `alembic`'s textual output (regex on revision hashes). If Alembic ever changes the format substantially, the parse breaks. Acceptable risk; would surface as a script error, not silent corruption.
- We now have five scripts under `scripts/db/` for what is otherwise four CLI subcommands. Slight surface growth; if it bloats further, it's worth considering a single `scripts/db/migrate.sh <verb>` dispatcher.
- The `/migrate-new` slash command depends on the user having `git` history of model changes to summarize from. For brand-new repos with no prior commit it'll still work but the message proposal will be less informative.
