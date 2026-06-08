# Project Setup

Replicate the documentation conventions from this project in any new repository. This file is self-contained — drop it at the root of a fresh project, follow the steps below (manually or by handing the file to Claude Code), and you end up with the same structure.

## What you get

- **Modular project guidelines** auto-loaded into every Claude Code conversation via the `@`-import syntax.
- **Numbered decision records (ADRs)** as the single source of change history. The decisions index doubles as a scannable summary — one artifact carries both the rationale and the timeline.
- **`/log-decision` slash command** that scaffolds a new ADR and updates the index in one step.
- **A clean split between rules and docs**: `docs/standards/` holds the rule-sets to follow; `docs/reference/` holds descriptive docs (what the project is, how it's structured).
- **Sensible permission defaults** in `.claude/settings.json`: a language-agnostic `deny` list that protects secrets, an `ask` list gating destructive/outward-facing commands, and a read-only git `allow` list.
- **A home for hooks**: `.claude/scripts/` with a README documenting the fail-soft convention; wire scripts into the `hooks` key of `settings.json`.
- **A self-documenting `.claude/`**: every subdirectory (`commands/`, `agents/`, `scripts/`) ships a README explaining its file format.
- **Two audiences, two entry points**: `README.md` for humans, `CLAUDE.md` for the model. They do not duplicate content.

## Conventions in one paragraph

`CLAUDE.md` is a thin index of `@`-imports pointing to focused rule-sets in `docs/standards/`. Every change to the project is logged as a numbered decision record (`docs/decisions/NNN-FEATURE_NAME.md`) following the Nygard ADR format with explicit `Status`, `Context`, `Decision`, `Alternatives considered`, and `Consequences` sections. Superseded ADRs are never deleted — their status is updated and they link forward to the replacement. The decisions index (a table in `docs/decisions/README.md`) doubles as the project's change history.

## Directory structure

```
.
├── CLAUDE.md
├── README.md
├── docs/
│   ├── README.md
│   ├── reference/
│   │   ├── README.md
│   │   ├── overview.md
│   │   └── layout.md
│   ├── decisions/
│   │   ├── README.md
│   │   └── NNN-FEATURE_NAME.md      # added as you log decisions
│   └── standards/
│       ├── README.md
│       ├── language.md
│       ├── change-tracking.md
│       └── decision-records.md
└── .claude/
    ├── commands/
    │   ├── README.md
    │   └── log-decision.md
    ├── agents/
    │   └── README.md
    ├── scripts/
    │   └── README.md
    ├── settings.json                 # committed
    └── settings.local.json           # gitignored, created on demand
```

## Quick start with Claude Code (recommended)

Place this `SETUP.md` at the root of a fresh project, then open Claude Code and run:

```
Read SETUP.md and create every file listed under "File contents" at the indicated path with the content shown verbatim. Use the templates for README.md, docs/reference/overview.md, and docs/decisions/README.md, substituting placeholders. Stop and ask me for the project name, one-line tagline, and stack before writing README.md and overview.md.
```

Claude will create the directory structure and every file. After it's done, delete `SETUP.md` if you do not want to keep it in the new project.

## Manual setup

### 1. Create the directories

PowerShell:

```
New-Item -ItemType Directory -Force -Path docs/standards, docs/reference, docs/decisions, .claude/commands, .claude/agents, .claude/scripts | Out-Null
```

Bash:

```
mkdir -p docs/standards docs/reference docs/decisions .claude/commands .claude/agents .claude/scripts
```

### 2. Add to `.gitignore`

```
.claude/settings.local.json
```

### 3. Create each file below at the indicated path

For files that include a triple-backtick code block in their content, the outer fence in this document uses four backticks so the inner triple-backtick block is preserved.

---

## File contents

### `CLAUDE.md`

```
# Project Guidelines

Each section below imports a focused rule-set from `docs/standards/`, plus the repository layout from `docs/reference/`. Every `@`-referenced file is auto-loaded by Claude Code into the context of every conversation in this repository.

## Language
@docs/standards/language.md

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
```

### `README.md` (template — substitute the placeholders)

```
# <PROJECT_NAME>

<one-line project tagline>

## Repository layout

| Path | What lives here |
|------|-----------------|
| `CLAUDE.md` | Project guidelines (thin index, auto-loaded into every conversation). |
| `README.md` | This file. Human-facing overview. |
| `docs/reference/` | Descriptive docs — what the project is and how it's structured. |
| `docs/standards/` | Project rule-sets, `@`-imported by `CLAUDE.md`. |
| `docs/decisions/` | Decision records (ADRs), one Markdown file per change. |
| `.claude/commands/` | Custom slash commands (e.g. `/log-decision`). |
| `.claude/agents/` | Custom Claude Code subagents. |
| `.claude/scripts/` | Hook & helper scripts wired up in `settings.json`. |
| `.claude/settings.json` | Shared Claude Code settings (committed). |
| `.claude/settings.local.json` | Personal overrides (gitignored). |

## How changes are tracked

Every change — feature, fix, refactor, or documentation update — is logged as a numbered decision record (ADR) under `docs/decisions/`. ADRs carry the full rationale (context, decision, alternatives, consequences); the [decisions index](./docs/decisions/README.md) doubles as a scannable change history (date, status, one-line summary).

Use `/log-decision <FEATURE_NAME> "<summary>" [type]` to scaffold a new ADR and update the index in one step. ADRs are numbered sequentially (`001`, `002`, ...) and referenced in prose as `ADR-NNN`.

## Conventions in one sentence

All code, comments, and documentation are written in English; every change is captured as a numbered ADR under `docs/decisions/`.

For the full rule-set see [`CLAUDE.md`](./CLAUDE.md), which `@`-imports each standard from [`docs/standards/`](./docs/standards/README.md).
```

### `docs/README.md`

```
# Documentation

| Path | Purpose |
|------|---------|
| [`standards/`](./standards/README.md) | Project rule-sets, `@`-imported by `CLAUDE.md`. |
| [`reference/`](./reference/README.md) | Descriptive docs — what the project is and how it's structured. |
| [`decisions/`](./decisions/README.md) | Decision records (ADRs), one Markdown file per change. |
```

### `docs/decisions/README.md`

````
# Decision Records

Long-form rationale for every change in this project. Format details in [`../standards/decision-records.md`](../standards/decision-records.md).

To scaffold a new record (and its index row) run:

```
/log-decision <FEATURE_NAME> "<summary>" [type]
```

## Index

| ADR | Status | Date | Summary |
|-----|--------|------|---------|

_No decisions logged yet. Use `/log-decision` to add the first one._
````

### `docs/standards/README.md`

```
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
```

### `docs/standards/language.md`

> **Note:** this rule is opinionated. Drop or adapt it if your project needs a different language policy. If you remove this standard, also remove the `## Language` import from `CLAUDE.md`.

```
# Language

All persisted artifacts in this repository are written 100% in English:

- Source code and identifiers.
- Comments and docstrings.
- Documentation, including this file.
- File and folder names.
- Commit messages and PR titles/descriptions.
- User-facing copy.

Chat with the assistant is exempt — the user may converse in any language. Only what is committed to the repository must be in English.

Rationale and trade-offs: see [ADR-001](../decisions/001-ADOPT_ENGLISH_ONLY.md).
```

> Adjust the ADR reference at the bottom once you have logged the corresponding decision in the new project.

### `docs/reference/README.md`

```
# Reference

Descriptive documentation — what this project is and how it's structured. For
rules to follow when editing, see [`../standards/`](../standards/README.md).

| File | Purpose |
|------|---------|
| [`overview.md`](./overview.md) | What the project is, the stack, and how to get started. |
| [`layout.md`](./layout.md) | Full repository structure and what lives where. |
```

### `docs/reference/overview.md` (template — substitute the placeholders)

```
# Project Overview

## What this is

<one paragraph: what the project is and who/what it's for>

## Stack

- **<language / runtime>** — <how it's pinned or installed>.
- **<framework / library>** — <what it does here>.
- **<datastore / service>** — <how it runs in development>.

## Getting started

<the minimal commands to go from a fresh clone to a running project>

## Documentation map

- **[`layout.md`](./layout.md)** — full repository structure and what lives where.
- **[`../standards/`](../standards/README.md)** — the rules to follow when editing the project.
- **[`../decisions/`](../decisions/README.md)** — numbered ADRs recording every change and its rationale.
```

### `docs/reference/layout.md`

> Imported by `CLAUDE.md` so the model always has the structure in context. Keep the tree current as the project grows.

````
# Project Layout

The full repository structure and what lives where.

```
.
├── CLAUDE.md                       # thin index, @-imports each standards file + the reference layout
├── README.md                       # human-facing project overview
├── docs/
│   ├── README.md                   # documentation index
│   ├── reference/                  # descriptive docs — what the project is and how it's structured
│   │   ├── README.md
│   │   ├── overview.md
│   │   └── layout.md               # this file
│   ├── standards/                  # imported by CLAUDE.md, one rule-set per file
│   │   ├── README.md
│   │   ├── language.md
│   │   ├── change-tracking.md
│   │   └── decision-records.md
│   └── decisions/                  # ADRs, sequential numbering
│       ├── README.md               # index table
│       └── NNN-FEATURE_NAME.md     # one file per decision
└── .claude/
    ├── commands/                   # custom slash commands (each has a README)
    ├── agents/                     # custom subagents (README)
    ├── scripts/                    # hook & helper scripts (README)
    ├── settings.json               # shared (committed)
    └── settings.local.json         # personal (gitignored)
```

## Where things go

- **Descriptive documentation** — what the project is, how it's structured, how to run it — lives in `docs/reference/`.
- **Rules and patterns to follow** when editing the project live in `docs/standards/`, which `CLAUDE.md` `@`-imports.
- **Change history and rationale** lives in `docs/decisions/` as numbered ADRs.

## Audiences

- `README.md` targets humans landing in the repo.
- `CLAUDE.md` (and every file it `@`-imports from `docs/standards/`, plus this layout) targets the model.

These do not duplicate content. The human-facing README points to `CLAUDE.md` for the full rule-set; `CLAUDE.md` does not narrate what the project is for.

## Discoverability

Every directory under `docs/` has its own `README.md` acting as a local index, so a reader can drill down from any entry point.
````

### `docs/standards/change-tracking.md`

```
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
```

### `docs/standards/decision-records.md`

````
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
````

### `.claude/commands/README.md`

````
# Custom Slash Commands

Drop a Markdown file here to define a custom Claude Code slash command for this project.
The file name becomes the command name (`log-decision.md` → `/log-decision`).

File format:

```markdown
---
description: One-line summary shown in the command picker.
argument-hint: <ARG_ONE> "<arg two>" [optional]
---

Instructions for Claude to follow when the command runs.
Reference arguments with `$ARGUMENTS`.
```

Slash commands package a repeatable prompt — scaffolding a file, running a workflow,
enforcing a checklist — into a single invocation so it stays consistent across sessions.
````

### `.claude/commands/log-decision.md`

````
---
description: Scaffold a new decision record (ADR) and update the decisions index
argument-hint: <FEATURE_NAME> "<summary>" [type]
---

Scaffold a new project decision record.

Arguments: $ARGUMENTS

1. Parse the arguments:
   - `FEATURE_NAME` (required) — uppercase, words joined by `_` (e.g. `ADD_LOGIN_FLOW`).
   - `"summary"` (required) — quoted one-liner for the decisions-index row.
   - `type` (optional) — one of `feature` | `fix` | `docs` | `chore` | `refactor`. Defaults to `feature`.

   If any required argument is missing or malformed, stop and ask the user for the missing piece — do not invent values.

2. Determine the next ADR number:
   - List files in `docs/decisions/` whose names match `^\d{3}-`.
   - Take the highest `NNN` and add 1.
   - Zero-pad the result to three digits (e.g. `007`).
   - If no ADRs exist yet, use `001`.

3. Get the current timestamp via PowerShell: `Get-Date -Format "yyyy-MM-dd HH:mm"`.

4. Create `docs/decisions/<NNN>-<FEATURE_NAME>.md` using the template below. Leave Context / Decision / Alternatives / Consequences as italicized placeholders — do not invent content; the user will fill them in.

   ```markdown
   # <FEATURE_NAME>

   **ID:** ADR-<NNN>
   **Timestamp:** <HUMAN_TIMESTAMP>
   **Status:** Proposed
   **Type:** <type>

   ## Context
   _What problem is this solving? What constraints matter?_

   ## Decision
   _What are we doing, concretely?_

   ## Alternatives considered
   - _option_: _why not_

   ## Consequences
   **Positive:**
   - _what this unlocks_

   **Negative:**
   - _trade-off we accept_
   ```

5. Insert a new row at the top of the index table in `docs/decisions/README.md`:

   ```
   | [ADR-<NNN>](./<NNN>-<FEATURE_NAME>.md) | Proposed | <HUMAN_TIMESTAMP> | <summary> |
   ```

6. Report the new file's absolute path so the user can open it and fill the sections in. Do not fill Context / Decision / Consequences yourself — those require the human's intent.
````

### `.claude/agents/README.md`

````
# Custom Subagents

Drop a Markdown file here to define a custom Claude Code subagent for this project.

File format:

```markdown
---
name: agent-name
description: When this agent should be used (Claude reads this to decide).
tools: Read, Grep, Glob
---

System prompt for the agent.
```

Subagents are useful for delegating focused, repeatable tasks — code review, doc audits, codebase exploration — without polluting the main conversation's context.
````

### `.claude/scripts/README.md`

````
# Hook & Helper Scripts

Drop shell scripts here that back Claude Code hooks or other automation for this project.
Wire them up under the `hooks` key in [`../settings.json`](../settings.json) — the path is
relative to the repository root (e.g. `.claude/scripts/dev-context.sh`).

Conventions:

- Start each script with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Hook scripts should fail soft — if a precondition is missing (not a git repo, a tool
  absent), exit `0` quietly rather than polluting the conversation with errors.
- Anything a hook prints on stdout is injected into the conversation, so keep output
  focused and Markdown-friendly.

Scripts are useful for feeding live project state into context (git status, branch
position) or running checks at lifecycle points (prompt submit, pre/post tool use).
````

### `.claude/settings.json`

The `deny` list protects secrets and is language-agnostic — keep it. `ask` gates
destructive or outward-facing commands. `allow` starts with read-only git only; expand it
as you notice repeated prompts for safe commands (the `/fewer-permission-prompts` skill can
generate additions from your session history).

```
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./**/.env)",
      "Read(./**/.env.*)",
      "Read(./secrets/**)",
      "Read(./**/*.pem)",
      "Read(./**/*.key)",
      "Read(./**/id_rsa)",
      "Read(./**/credentials)",
      "Read(./**/.aws/**)",
      "Read(./**/.ssh/**)",
      "Bash(cat:*.env*)",
      "Bash(curl:*)"
    ],
    "ask": [
      "Bash(rm:*)",
      "Bash(git push:*)",
      "Bash(git reset:*)"
    ],
    "allow": [
      "Bash(git status)",
      "Bash(git diff:*)",
      "Bash(git log:*)"
    ]
  }
}
```

---

## After the files exist

1. **Fill in `README.md`** — substitute the project name and tagline placeholders.
2. **Log your first ADR.** Open Claude Code and run:

   ```
   /log-decision ESTABLISH_PROJECT_CONVENTIONS "Adopt project documentation conventions" docs
   ```

   Then open the generated file under `docs/decisions/001-ESTABLISH_PROJECT_CONVENTIONS.md` and fill in `Context`, `Decision`, `Alternatives considered`, and `Consequences` for your specific project. Flip the `Status` from `Proposed` to `Accepted` when the conventions are in force.

3. **Verify the imports load.** Start a Claude Code conversation and ask "what guidelines apply to this project?" — Claude should reference the rules from `docs/standards/*.md` via the `@`-imports in `CLAUDE.md`.

## Customization

- **Drop the English-only rule** — delete `docs/standards/language.md`, remove its `@`-import from `CLAUDE.md`, and skip `ADOPT_ENGLISH_ONLY` as the founding ADR.
- **Add new standards** — create `docs/standards/<topic>.md` (e.g. `git.md`, `testing.md`, `security.md`) and add an `@`-import to `CLAUDE.md` under a matching heading. Log each addition with `/log-decision`.
- **Expand the permission allowlist** in `.claude/settings.json` once you notice repeated prompts for the same safe commands. Use the `/fewer-permission-prompts` skill if available to auto-generate the allowlist from your session history.
- **Extend the `deny`/`ask` lists for your stack** — the template ships only language-agnostic rules. Add framework-specific secret paths to `deny` (e.g. `Read(./**/local_settings.py)` for Django, `Read(./instance/**)` for Flask) and gate your package manager under `ask` (e.g. `Bash(pip install:*)`, `Bash(npm install:*)`).
- **Add custom subagents** under `.claude/agents/` for repeatable focused tasks (code review, doc audits, codebase exploration). See the README in that folder for the file format.
- **Add more slash commands** under `.claude/commands/` — `/log-decision` is the starter; add `/supersede-decision`, `/run-tests`, etc. as the project's workflow demands them. See the README in that folder for the file format.
- **Add hook scripts** under `.claude/scripts/` and wire them under the `hooks` key in `.claude/settings.json` — e.g. a `UserPromptSubmit` script that injects live git state into context. See the README in that folder for conventions.

## Removing this file

`SETUP.md` is a bootstrap artifact, not part of the conventions themselves. After your project is up and running, you can delete it. The full setup is reproducible from the contents of `CLAUDE.md`, `docs/`, and `.claude/`.
