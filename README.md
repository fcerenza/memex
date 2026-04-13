# Memex

An LLM-maintained personal wiki built around the pattern in Andrej Karpathy's [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

You keep raw source material in `raw/`. The LLM reads those sources, writes and updates the structured knowledge base in `wiki/`, maintains `wiki/index.md` and `wiki/log.md`, and files useful syntheses back into the wiki instead of losing them in chat history.

## Architecture

Three layers:

```text
raw/       immutable source documents
wiki/      LLM-owned markdown pages
SCHEMA.md  the rules for structure, privacy, and workflows
```

This repo is opinionated in the same way as `llm-wiki.md`:
- The wiki is the persistent artifact, not a temporary RAG layer.
- The LLM owns wiki maintenance: summaries, cross-links, updates, and synthesis.
- `index.md` is the navigational catalog.
- `log.md` is the append-only chronological record.
- Search is local via `qmd`; Obsidian is the preferred reader.

## Repo Layout

```text
memex/
├── SCHEMA.md
├── CLAUDE.md
├── AGENTS.md
├── setup.sh
├── raw/
│   └── assets/
└── wiki/
    ├── index.md
    └── log.md
```

## Requirements

- `qmd` for local search: `npm install -g @tobilu/qmd`
- Obsidian for browsing the wiki
- Git for version history

Optional:
- Obsidian Web Clipper for capturing web sources into `raw/`
- Dataview and Marp Obsidian plugins

## Quick Start

1. Install `qmd`:

```bash
npm install -g @tobilu/qmd
```

2. Initialize the local search index:

```bash
SKIP_EMBED=1 ./setup.sh
```

3. Verify the collection exists:

```bash
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd collection list
```

4. Open the repo root as an Obsidian vault.

5. Start using the wiki:

```text
ingest <filename>
journal <filename>
query <question>
reflect
lint
```

This is enough for the core project. Community plugins are optional.

## Setup Details

Default setup:

```bash
./setup.sh
```

Fast setup without downloading embedding models yet:

```bash
SKIP_EMBED=1 ./setup.sh
```

What `setup.sh` does:
- Registers `wiki/` as the `memex` qmd collection
- Creates repo-local qmd cache and config in `.cache/qmd` and `.config/qmd`
- Re-indexes cleanly on every run
- Generates embeddings for hybrid search

With `SKIP_EMBED=1`, setup still registers and indexes the wiki; you can generate embeddings later by running `XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd embed`.

Verify:

```bash
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd collection list
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd status
```

The repo-local qmd state keeps setup self-contained and avoids permissions issues in sandboxed agents. If you want machine-global qmd state instead, set `XDG_CACHE_HOME` and `XDG_CONFIG_HOME` before running `./setup.sh`.

## Agent Integration

`SCHEMA.md` is the single source of truth. Both entry points tell the agent to load it at session start:

- `CLAUDE.md`
- `AGENTS.md`

Project-local skills live in `.agents/skills/memex-<command>/`:

- `journal`
- `ingest`
- `query`
- `reflect`
- `lint`
- `search`
- `update`

## Obsidian

Open the repo root as an Obsidian vault.

The repo already includes:
- `.obsidian/app.json` with attachments set to `raw/assets`
- `.obsidian/app.json` with new notes set to `wiki/`
- `.obsidian/core-plugins.json` with a sensible default core-plugin set
- `.obsidian/community-plugins.json` listing `dataview` and `marp`

What works without any extra plugin installs:
- Reading and browsing the wiki
- Editing markdown notes
- Graph view and core Obsidian navigation
- The full LLM + `qmd` workflow

What still requires manual install in Obsidian:
- `Dataview`
- `Marp`

Those are optional. They are listed in the vault config so the intended plugin set is visible in git, but the plugin binaries themselves are not vendored into the repo.

Useful practice:
- Clip or save sources into `raw/`
- Download article images into `raw/assets/` before ingesting when they matter
- Use graph view to spot hubs and orphans
- Install Dataview and Marp if you want query dashboards or slide output

## Core Operations

The workflows are defined in detail in `SCHEMA.md`. At a high level:

- `journal <filename>` reads a personal note from `raw/`, files a journal page, updates related pages, then updates `index.md` and `log.md`.
- `ingest <filename>` reads an external source from `raw/`, creates a source page, updates related pages, then updates `index.md` and `log.md`.
- `query <question>` searches the wiki, reads relevant pages, answers with wiki citations, and can file strong answers back into the wiki.
- `reflect` synthesizes a time period into a reflection page and updates related overview, goal, and habit pages.
- `lint` checks for orphans, contradictions, stale pages, missing cross-links, and missing pages.
- `search <terms>` does fast lookup over the wiki.
- `update [[Page Name]]` revises an existing page and bumps its `updated` date.

This mirrors the operating model in `llm-wiki.md`: ingest sources, query the compiled wiki, periodically lint and reflect, and keep useful outputs as first-class pages.

## qmd Usage

```bash
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd query "how am I sleeping?" -c memex
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd search "magnesium sleep" -c memex
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd vsearch "patterns in my energy levels" -c memex
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd get "sleep.md" --full
XDG_CACHE_HOME="$PWD/.cache" XDG_CONFIG_HOME="$PWD/.config" qmd multi-get "journal-2026-04-*.md"
```

Re-run `./setup.sh` after large wiki changes if search results seem stale.

## Log Parsing

`wiki/log.md` is intentionally parseable:

```bash
grep "^## \[" wiki/log.md | tail -10
grep "^## \[.*\] ingest" wiki/log.md
grep "^## \[.*\] journal" wiki/log.md
grep "^## \[2026-04" wiki/log.md
```

## Notes

- Keep `raw/` immutable.
- Keep sensitive details local; the schema treats privacy as a first-class rule.
- If a query produces a valuable synthesis, file it back into the wiki.
- If the schema needs to evolve, change `SCHEMA.md`, not scattered prompts.
