# Hook & Helper Scripts

Drop shell scripts here that back Claude Code hooks or other automation for this project.
Wire them up under the `hooks` key in [`../settings.json`](../settings.json) — the path is
relative to the repository root (e.g. `.claude/scripts/dev-context-light.sh`).

Conventions:

- Start each script with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Hook scripts should fail soft — if a precondition is missing (not a git repo, a tool
  absent), exit `0` quietly rather than polluting the conversation with errors.
- Anything a hook prints on stdout is injected into the conversation, so keep output
  focused and Markdown-friendly.

Scripts are useful for feeding live project state into context (git status, branch
position) or running checks at lifecycle points (prompt submit, pre/post tool use).
