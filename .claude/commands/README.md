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
