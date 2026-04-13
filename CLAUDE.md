# Memex — Agent Entry Point

On session start, immediately read `SCHEMA.md` and treat it as the authoritative source for schema, privacy, layout, and workflow rules.

Built-in repo commands:
- `journal`
- `ingest`
- `query`
- `reflect`
- `lint`
- `search`
- `update`

Skills live in `.agents/skills/memex-<command>/`, symlinked from `.claude/skills/<command>/`.
