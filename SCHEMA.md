# Memex — Schema & Workflow

This is the configuration file for an LLM-maintained personal knowledge base.
Domain: personal life, health, finances, hobbies, relationships, goals, and self-improvement.
The LLM reads and follows these instructions in every session.

## Privacy

All data stays local. Never send personal information to external APIs or web services without explicit user permission. Do not quote sensitive personal details (account numbers, health values, relationship details) in plain-text tool outputs — reference the wiki page instead.

## Directory Layout

```
memex/
├── SCHEMA.md          ← this file (schema + workflow)
├── CLAUDE.md          ← Claude Code entry point → reads SCHEMA.md
├── AGENTS.md          ← Codex / OpenAI entry point → reads SCHEMA.md
├── raw/               ← immutable source documents (you add; LLM only reads)
│   └── assets/        ← locally downloaded images referenced by sources
└── wiki/              ← LLM-owned markdown pages (LLM creates and maintains)
    ├── index.md       ← content catalog (updated every ingest/journal)
    ├── log.md         ← append-only chronological record
    └── <pages>.md     ← all wiki pages
```

## Page Conventions

**Frontmatter** (YAML, at top of every wiki page):
```yaml
---
title: Page Title
type: journal | source | person | goal | habit | health | finance | concept | analysis | overview
domain: health | finance | relationships | hobbies | self | career | general
tags: [tag1, tag2]
sources: [raw-filename-or-title]
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

**Page types:**
- `journal` — summary/synthesis of a journal entry or personal note filed from `raw/`
- `source` — summary of an external article, book, podcast, or document
- `person` — someone in the user's life (family, friend, colleague); include relationship context, shared history, important facts to remember
- `goal` — a specific goal with current status, milestones, obstacles, related habits
- `habit` — a recurring practice being tracked or built; include streak info, what's working
- `health` — a health metric, condition, treatment, or pattern (symptoms, diet, exercise, sleep, mood)
- `finance` — a financial topic, account overview, budget category, or investment thesis (no raw account numbers)
- `concept` — a recurring idea across sources or life domains
- `analysis` — a comparison, synthesis, decision analysis, or answer to a specific question
- `overview` — high-level synthesis of a domain (e.g. "Current Goals Overview", "Health Summary")

**Cross-references:** Use Obsidian-style `[[Page Name]]` links. Every page must link to at least one other page. Orphan pages are a lint failure.

**Sections vary by type:**

*journal / source:* one-paragraph summary → `## Key Takeaways` → `## Connections` (links to relevant wiki pages) → `## See Also`

*person:* one-paragraph relationship summary → `## About` → `## History` → `## Notes` (things to remember) → `## See Also`

*goal / habit:* one-paragraph description → `## Status` → `## Milestones` → `## Obstacles` → `## Related` → `## See Also`

*health:* one-paragraph summary → `## Observations` → `## Patterns` → `## Actions Taken` → `## Sources` → `## See Also`

*finance:* one-paragraph summary → `## Current State` → `## Trends` → `## Actions` → `## See Also`

*analysis / overview:* one-paragraph summary → `## Key Points` → `## Sources` → `## See Also`

## Image Handling

LLMs cannot read markdown with inline images in one pass. Workflow:
1. Read the text of the source first, extract key points
2. Identify which images are referenced and relevant
3. Read each image file separately using the image-reading capability
4. Integrate image context into the wiki page

When using Obsidian Web Clipper: after clipping, use the "Download attachments" hotkey (Ctrl+Shift+D by default) to download images to `raw/assets/` before ingesting.

## Cloud Backup

After every wiki write, commit and push to your configured backup remote:

```bash
git add -A
git commit -m "<operation>: <slug>"
git push <your-remote> main
```

- Keep private wiki content on a private or encrypted remote.
- If your backup remote requires authentication or encryption, the push step may prompt for credentials or a passphrase.

## Search Tool

`qmd` is the search engine over the wiki. Use it before reading the index to find relevant pages.

```bash
# Best quality: hybrid + reranking (use this most)
qmd query "question or topic" -c memex

# Keyword search (fast, exact terms)
qmd search "query terms" -c memex

# Semantic search (natural language)
qmd vsearch "natural language query" -c memex

# Get a specific file (path relative to wiki collection root)
qmd get "page-name.md" --full

# Get multiple files by glob (relative to wiki collection root)
qmd multi-get "health-*.md"

# Structured JSON output for multi-step reasoning
qmd search "terms" -c memex --json -n 10
```

Use `qmd query` for wikis with more than ~50 pages. For smaller wikis, reading `wiki/index.md` directly is fine.

## Workflows

### JOURNAL — filing a personal note or journal entry

When the user says `journal <filename>` or shares a personal note/entry:

1. **Read** the source from `raw/` (if it's an image, follow the image handling workflow above)
2. **Ask** if there's a specific angle, mood, or context to emphasize
3. **Create** a journal page `wiki/journal-YYYY-MM-DD-<slug>.md` (type: journal)
4. **Update** relevant wiki pages: goals mentioned, habits tracked, people referenced, health observations, financial notes — create new pages where they don't exist
5. **Update** `wiki/index.md` — add the journal entry under Journal
6. **Append** to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] journal | <Entry Title or Date>
   Summary: <one sentence>
   Pages updated: <comma-separated list>
   ```
7. Aim to touch 3–8 wiki pages per journal entry
8. **Backup** — run `git add -A && git commit -m "journal: <slug>" && git push <your-remote> main`

### INGEST — adding an external source

When the user says `ingest <filename>` or drops an article/book/podcast in `raw/`:

1. **Read** the source file from `raw/` (handle images per the image workflow above)
2. **Discuss** key takeaways — ask what's most relevant to the user's life, goals, or current focus
3. **Create** a source summary page `wiki/<source-slug>.md` (type: source)
4. **Update** `wiki/index.md` — add under Sources
5. **Update** existing wiki pages touched by the source (concepts, goals, health pages, habits that the source informs or contradicts)
6. **Append** to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] ingest | <Source Title>
   Summary: <one sentence>
   Pages updated: <comma-separated list>
   ```
7. Aim to touch 5–15 wiki pages per ingest
8. **Backup** — run `git add -A && git commit -m "ingest: <source-slug>" && git push <your-remote> main`

### QUERY — answering a question

When the user asks a question:

1. **Search** with `qmd query "<question>" -c memex`
2. **Read** returned pages
3. **Synthesize** an answer with inline citations to wiki pages (`[[Page Name]]`)
4. **Offer to file** the answer as a new wiki page if substantive — analyses, decisions, patterns noticed — these shouldn't disappear into chat history
5. If filed, append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] query | <Question summary>
   Filed as: [[Page Name]]
   ```
6. If filed, **Backup** — run `git add -A && git commit -m "query: <slug>" && git push <your-remote> main`

### REFLECT — periodic synthesis

When the user says `reflect` (weekly, monthly, or quarterly):

1. **Search** for journal entries and goal/habit pages updated in the period
2. **Read** recent log entries: `grep "^## \[" wiki/log.md | tail -30`
3. **Synthesize**:
   - Patterns across journal entries (mood, energy, recurring themes)
   - Goal/habit progress
   - Health trends
   - Financial movements
   - What's working, what isn't
4. **Create** a reflection page `wiki/reflect-YYYY-MM-<period>.md` (type: analysis)
5. **Update** relevant goal, habit, and overview pages with new status
6. **Append** to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] reflect | <Period> Reflection
   Filed as: [[Page Name]]
   Themes: <brief>
   ```
6. **Backup** — run `git add -A && git commit -m "reflect: <period>" && git push <your-remote> main`

### LINT — health-checking the wiki

When the user says `lint`:

1. Read `wiki/index.md` for the full page list
2. Scan for:
   - **Orphan pages** — pages not linked from any other page
   - **Contradictions** — conflicting claims (e.g. two health pages with opposite conclusions)
   - **Stale data** — goals/habits not updated in >30 days, health pages with no recent entries
   - **Missing pages** — people, goals, or habits mentioned in journal entries but lacking their own page
   - **Missing cross-refs** — e.g. a goal page not linked from related habit pages
   - **Data gaps** — things worth tracking that aren't being tracked
   - **Patterns to surface** — connections across domains the user might want to know about
3. Report findings as a bulleted list with suggested fixes
4. Append to `wiki/log.md`:
   ```
   ## [YYYY-MM-DD] lint | Health check
   Issues found: N
   Summary: <brief>
   ```

### SEARCH — quick lookup

When the user says `search <terms>`:

Run `qmd search "<terms>" -c memex --json -n 10` and return top results with titles and one-line summaries.

### UPDATE — revising a page

When the user says `update [[Page Name]]` or after an ingest/journal that touches an existing page:

1. Read the current page
2. Apply changes (new observations, revised status, updated cross-refs)
3. Bump the `updated:` frontmatter date
4. Note the change in the relevant log entry
5. **Backup** — run `git add -A && git commit -m "update: <page-slug>" && git push <your-remote> main`

## Index Structure

`wiki/index.md` sections for a personal brain:

```markdown
## Journal
- [[journal-YYYY-MM-DD-slug]] — one-line summary

## Goals
- [[Goal Name]] — current status

## Habits
- [[Habit Name]] — one-line description

## Health
- [[Health Topic]] — one-line description

## Finance
- [[Finance Topic]] — one-line description

## People
- [[Person Name]] — relationship

## Sources
- [[Source Title]] — one-line description, domain

## Concepts
- [[Concept]] — one-line description

## Analyses & Reflections
- [[Analysis Title]] — one-line description
```

Update header stats (page count, sources ingested, last updated) on every write.

## Log Format

Each entry must start with:
```
## [YYYY-MM-DD] <operation> | <title>
```
where `<operation>` is one of: `journal`, `ingest`, `query`, `reflect`, `lint`, `update`, `init`.

Parse the log:
```bash
# Last 20 entries
grep "^## \[" wiki/log.md | tail -20

# All journal entries
grep "^## \[.*\] journal" wiki/log.md

# All reflections
grep "^## \[.*\] reflect" wiki/log.md
```

## Output Formats

Match format to the question:
- **"How am I doing on X?"** → prose summary with trend, citing journal entries and goal pages
- **Comparison** → markdown table
- **Data/trend** → suggest a Dataview query over frontmatter, or a matplotlib script
- **Decision** → pros/cons table or decision analysis page
- **Slide deck** → Marp format (frontmatter: `marp: true`)

All substantive outputs should be filed as wiki pages.

## Evolving This Schema

This file is co-evolved with the user. If a convention isn't working, suggest a change here. The schema should reflect how this wiki actually operates, not an idealized version.
