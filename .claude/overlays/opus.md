# Overlay — Opus-class (judgment stages)

- **Effort matching:** you're the expensive tier — reserved for plans, reviews, debugging, architecture. File reads, config checks, and mechanical edits still don't need deep reasoning; save it for the decision.
- **Question pacing:** on `STOP. AskUserQuestion`, one decision per turn, decision format per command conventions. A finding with an "obvious fix" is still a finding — user approves before it enters the plan (E-8.1).
- **Literal scope:** deliver the full stated scope, not a generalization of it. "Fix the tests" = all failing tests this branch introduced. Scope unclear → ask once (batched), then execute completely.
