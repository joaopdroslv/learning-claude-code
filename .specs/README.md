# Specs

Design and implementation specifications for this repository. A spec is written before
implementation to align on the problem, the approach, and the exact files that will change.
Once implemented, it serves as the authoritative record of why a decision was made.

Keep implemented specs accurate: if the implementation diverged from the spec, update the
spec to match what was actually built. The spec is the authoritative record.

---

## Index

The Index is the **source of truth for each spec's status** — the status lives here, not in
the spec file. Add a row when you create a spec, and update its status as it moves through
the lifecycle.

| Spec | Status |
|---|---|
| [implement-clients-feature](./implement-clients-feature.md) | implemented |

---

## Status values

| Value | Meaning |
|---|---|
| `draft` | Being written or reviewed — not ready to implement |
| `planned` | Finalized and approved — queued, not yet started |
| `in progress` | Partially implemented — see progress section in the spec |
| `implemented` | Fully implemented in the codebase |
| `superseded` | Replaced by a newer spec — kept for historical context |
| `cancelled` | Decided not to implement — kept with rationale |

Once a spec reaches `implemented` and its decisions are reflected in `docs/reference/`, the
spec file is removed from the repo — the reference docs become the authoritative record.

---

## Standard format

### File naming

One spec per file, in kebab-case, **always** prefixed with an imperative verb that describes
the change. The prefix is mandatory — a noun-phrase name (`runtime-config`, `customer-model`)
is not allowed. The filename (minus `.md`) is the spec's identifier used in the Index and in
`Depends on` links.

| Prefix | Use for |
|---|---|
| `implement-` | A new feature, table, model, endpoint, or capability that does not exist yet |
| `improve-` | An enhancement, tuning, or behaviour change to something that already exists |
| `refactor-` | A structural change with no behaviour change (file/package split, renaming, extraction) |
| `remove-` | Deleting a feature, column, table, or endpoint |

After the prefix, name the *subject* of the change, not its mechanism. Keep it specific enough
to be unambiguous in the Index.

Examples: `implement-customer-model.md`, `improve-db-connection-pooling.md`,
`refactor-models-into-package.md`, `remove-legacy-column.md`.

### Canonical section order

Sections must appear in this exact order. Do not use variant names — the canonical names
below are the only valid headings.

| # | Section | Required | Notes |
|---|---|---|---|
| — | Header block | yes | Before any `##` heading. Holds `Depends on` only. |
| 1 | `## Problem` | yes | Always first. What is broken or missing. No code here. |
| 2 | `## Solution` | yes | Always second. High-level approach. |
| 3 | `## Non-goals` | no | Optional. Explicit out-of-scope, to prevent scope creep. |
| 4 | `## <Named sections>` | yes | Implementation details. One or more sections. |
| 5 | `## Tests` | yes* | Always after implementation sections. *Omit only for specs that touch no code (docs-only, config-only). |
| 6 | `## Files Affected` | yes | Always second-to-last. |
| 7 | `## Checklist` | no | Always last, if present. |

**Banned section names** — use the canonical names above instead:

| Do not use | Use instead |
|---|---|
| Motivation, Context, Background, Context and Goal | `## Problem` |
| Approach, Decision, Summary of Changes | `## Solution` |
| Out of scope, Scope, Not doing, What Does Not Change, What This Does Not Change | `## Non-goals` |
| Impact on existing files, Files changed, Files Changed Summary, Full File Structure | `## Files Affected` |
| Testing, Test plan, Test coverage | `## Tests` |

### Header block

The single line after the title, before any `##` section:

```markdown
> **Depends on:** [spec-title](spec-file.md) · [spec-title-2](spec-file-2.md)  —  or  —  —
```

- `Depends on` lists specs that must be implemented first. Use `—` if none.

Status is **not** carried in the header — it lives in the [Index](#index), the single
source of truth. Whether the change needs a database migration is the spec's own
responsibility: describe the migration in the implementation sections and list the migration
file in `## Files Affected` (there is no header migration flag).

### `## Problem`

What is broken, missing, or inconsistent. Observable symptoms. No solution, no code here.

### `## Solution`

High-level approach. Why this approach over alternatives (if the choice is non-obvious).
One or two paragraphs maximum.

### `## Non-goals`

Optional. A short list of things this spec deliberately does **not** do, to keep the scope
honest and stop reviewers from asking "what about X?". Omit the section entirely if there is
nothing worth calling out.

### Named implementation sections

One or more sections with descriptive names. Must include:

- **Code examples** for any non-trivial logic, new signatures, or schema changes.
  Prefer showing before/after when changing existing code. Real Python syntax is required
  for anything that will be copied into code; pseudo-code is acceptable for high-level flows.
- **Data model table** if new tables or columns are introduced.
- **Migration** described here when the change alters the schema — the new/changed columns
  and tables, plus any backfill. The Alembic migration file itself is listed in
  `## Files Affected`.
- **New constants** listed if a shared constants module or configuration changes.

### `## Tests`

Required for every spec that creates, modifies, or deletes code. Lists what tests
must be created, updated, or removed as a result of this change.

Use a table with three columns: file path, test type, and what to cover.

```markdown
## Tests

| File | Type | What to cover |
|---|---|---|
| `tests/unit/test_<module>.py` | unit | `<function>`: the cases it must cover |
| `tests/integration/test_<feature>.py` | integration | behaviour verified against a real test DB |
```

**Guidance:**
- `unit` — pure function, no DB or network. Lives under `tests/unit/`.
- `integration` — repository, module, or task against a real test DB. Lives under
  `tests/integration/`.
- `api` — HTTP contract and auth against the app. Lives under `tests/api/`.
- If a spec **removes** code, list the test files that must be deleted or the test cases that must be removed.
- If a spec changes a function signature, list the existing tests that must be updated.
- If no tests are warranted (e.g. a spec only adds a constant), write `— no tests required` and explain why.

### `## Files Affected`

A table listing every file that changes. Migrations and doc updates must be included.

```markdown
## Files Affected

| File | Change |
|---|---|
| `app/path/to/file.py` | What changes |
| `migrations/versions/` | New migration: description |
| `docs/reference/xxx.md` | Update section: yyy |
```

### `## Checklist`

Optional. Use when implementation has ordering constraints or spans multiple sessions.

```markdown
## Checklist

- [ ] Task 1
- [ ] Task 2
```

---

## Template

Copy this into a new file and fill in the blanks.

```markdown
# Spec: <Title>

> **Depends on:** —

---

## Problem

<What is broken or missing. Observable symptoms, not the solution.>

---

## Solution

<High-level approach.>

---

## Non-goals

<Optional. What this spec deliberately does not do. Delete this section if not needed.>

---

## Implementation

### <Section>

<Detail, data model, code examples.>

---

## Tests

| File | Type | What to cover |
|---|---|---|
| `tests/...` | unit / integration / api | ... |

---

## Files Affected

| File | Change |
|---|---|
| `app/...` | ... |

---

## Checklist

- [ ] ...
```

---

## Rules

- **English only.** All spec content must be written in English.
- **Status lives in the Index.** Never carry a status field in the spec header — the
  [Index](#index) is the single source of truth.
- **Problem first.** Always describe the problem before proposing the solution.
- **Code examples are required** for non-trivial logic. Real Python syntax for anything that
  will be copied into code; pseudo-code is acceptable for high-level flows.
- **Files Affected is required.** Every file that changes must be listed, including docs and
  migrations. If you discover a file was missed after implementation, update the spec.
- **Migrations are described in the body**, not flagged in the header, and the migration file
  is listed in `## Files Affected`.
- **Keep implemented specs accurate** until they are removed. If implementation diverged from
  the spec, update the spec to match what was actually built before it is retired.
