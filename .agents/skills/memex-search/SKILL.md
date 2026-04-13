---
name: memex-search
description: Quick keyword lookup across all wiki pages — returns the top matching titles and summaries for a given set of search terms.
---

- Treat the user's arguments as search terms.
- Run `qmd search "<terms>" -c memex --json -n 10`.
- Return the top results with titles and one-line summaries.
- If the search terms are missing, ask one concise follow-up question.
