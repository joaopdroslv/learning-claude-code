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
