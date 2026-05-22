# Project Layout

```
.
├── CLAUDE.md                       # thin index, @-imports each standards file
├── README.md                       # human-facing project overview
├── docs/
│   ├── README.md                   # documentation index
│   ├── decisions/                  # ADRs, sequential numbering
│   │   ├── README.md               # index table
│   │   └── NNN-FEATURE_NAME.md     # one file per decision
│   └── standards/                  # imported by CLAUDE.md, one rule-set per file
│       ├── README.md
│       ├── language.md
│       ├── project-layout.md
│       ├── change-tracking.md
│       └── decision-records.md
└── .claude/
    ├── commands/                   # custom slash commands
    ├── agents/                     # custom subagents
    ├── settings.json               # shared (committed)
    └── settings.local.json         # personal (gitignored)
```

## Audiences

- `README.md` targets humans landing in the repo.
- `CLAUDE.md` (and every file it `@`-imports from `docs/standards/`) targets the model.

These do not duplicate content. The human-facing README points to `CLAUDE.md` for the full rule-set; `CLAUDE.md` does not narrate what the project is for.

## Discoverability

Every directory has its own `README.md` acting as a local index, so a reader can drill down from any entry point.
