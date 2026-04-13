---
name: memex-update
description: Revise an existing wiki page — edits content, bumps the `updated:` date, and logs the change in the relevant journal entry.
---

- Treat the user's arguments as the page name or `[[Page Name]]` target to revise.
- Bump the `updated:` frontmatter date.
- Note the change in the relevant log entry when applicable.
- If the target page or requested revision is missing, ask one concise follow-up question.
