---
description: Scaffold a new decision record (ADR) and update the decisions index
argument-hint: <FEATURE_NAME> "<summary>" [type]
---

Scaffold a new project decision record.

Arguments: $ARGUMENTS

1. Parse the arguments:
   - `FEATURE_NAME` (required) — uppercase, words joined by `_` (e.g. `ADD_LOGIN_FLOW`).
   - `"summary"` (required) — quoted one-liner for the decisions-index row.
   - `type` (optional) — one of `feature` | `fix` | `docs` | `chore` | `refactor`. Defaults to `feat`.

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
