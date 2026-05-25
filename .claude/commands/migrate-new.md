---
description: Generate a new Alembic migration via autogenerate after proposing a name from the model diff
argument-hint: [optional message hint]
---

Generate a new Alembic migration from the current model changes.

Arguments: $ARGUMENTS

1. Survey what changed:
   - Run `git status app/models/` and `git diff app/models/` (both staged and unstaged) to see which model files were added or modified.
   - If there are no model changes at all and no new files under `app/models/`, stop and tell the user there is nothing to migrate. Do not proceed.

2. Propose a migration message:
   - Format: lowercase `snake_case`, no spaces, short and descriptive of *what changes* (e.g. `add_phone_to_customers`, `create_orders_table`, `drop_users_legacy_status`).
   - If the user provided an argument, treat it as a hint and refine it into that format. If they provided no argument, derive the message from the diff alone.
   - Show the proposed message to the user and ask them to confirm or amend it. Do not run anything until they confirm.

3. Once the user confirms, run:

   ```
   ./scripts/db/migrate-new.sh "<confirmed_message>"
   ```

   If that exits with `error: DB is not at the head migration.`, tell the user verbatim that the DB is behind, suggest they run `./scripts/db/migrate-up.sh` first, and stop. Do not try to "fix" by running migrate-up yourself — applying migrations is a decision the user should make explicitly.

4. After the script succeeds, read the new file under `migrations/versions/` (Alembic prints the path on the last line of its output) and summarize for the user:
   - Tables/columns it creates, drops, or alters.
   - Any indexes or constraints.
   - Anything that looks suspicious (e.g. an unintended `op.drop_table(...)` because a model was renamed instead of recreated).

5. Remind the user to:
   - Review the generated file before applying.
   - Apply with `./scripts/db/migrate-up.sh` when ready.
