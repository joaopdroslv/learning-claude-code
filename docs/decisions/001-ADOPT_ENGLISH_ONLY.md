# ADOPT_ENGLISH_ONLY

**ID:** ADR-001
**Timestamp:** 2026-05-22 14:00
**Status:** Accepted
**Type:** docs

## Context

The project exists in a polyglot environment — the primary contributor speaks Portuguese, the tooling and library ecosystem is English by default, and AI assistants are most fluent in English. Without an explicit rule, code, comments, and documentation will drift between languages, making the repository harder to navigate, share, and reason about.

## Decision

Persisted artifacts in this repository — code, comments, documentation, file and folder names, identifiers, commit messages, PR descriptions — are written 100% in English.

Chat communication with the assistant is exempt: the user may converse in any language; only what is committed to the repository must be in English.

## Alternatives considered

- **No explicit rule** — rejected. Without a rule, mixed-language drift is inevitable and irreversible after enough commits.
- **Portuguese-only** — rejected. Cuts the project off from external collaborators and from the majority of tooling examples and documentation.
- **Bilingual (Portuguese + English)** — rejected. Doubles maintenance, creates ambiguity about which version is canonical, and slows reviews.

## Consequences

**Positive:**
- Single canonical language for all artifacts.
- Friction-free sharing of code and documentation externally.
- Alignment with the language most tooling and AI assistants are optimized for.

**Negative:**
- Slight cognitive cost when switching from chat (any language) to writing artifacts (English).
