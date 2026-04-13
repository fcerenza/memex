---
name: memex-query
description: Answer a question by synthesizing knowledge from across the wiki — retrieves and connects relevant pages into a cited, coherent response.
---

- Treat the user's arguments as the question.
- Synthesize the answer with inline wiki citations in the form `[[Page Name]]`.
- Offer to file the answer as a new wiki page if it is substantive.
- If the question is missing, ask one concise follow-up question.
