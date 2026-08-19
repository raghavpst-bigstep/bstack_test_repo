# bstack deterministic tools

> **Install / update:** `bin/setup` is the first-run installer (Python deps from
> `../requirements.txt` + user-wide registration); `bin/update` fetches latest and
> refreshes everything, then re-runs the gates. See the repo `readme.md`.


Small, deterministic CLIs that **digest raw data into a compact, understandable format so the agent acts on a summary instead of reading the whole tree.** This is the cheapest token economy bstack has: a `grep`/`awk` pass costs nothing and returns ten lines; letting the model read a directory of files costs thousands of tokens and invites mistakes.

> **The pattern:** data → deterministic digest → *then* the agent reasons & acts.
> Deterministic digest helpers for the BigStep stack.

## Tools

| Tool | Digests | Used by | Emits |
|---|---|---|---|
| `bstack-solutions` | `docs/solutions/**` | plan, debug, brainstorm, compound | ranked compact hits, regenerated `INDEX.md` |
| `bstack-ddd-check` | imports across `apps/` + `libs/` | `ddd-boundary-enforcer`, review | only the illegal app→app / lib→app edges |
| `bstack-migrate-check` | a Kysely migration file | `kysely-migration-validator`, migrate | PASS/WARN/FAIL §4 checklist |
| `bstack-affected` | the diff vs. base | review, plan | affected apps/libs + DDD + risk flags |
| `bstack-learn` | `docs/solutions/learnings.jsonl` | learn, SessionStart, compound | recent / search / stats over learnings |
| `bstack-rice` | `.claude/skills/**/SKILL.md` (base + per-app) | rice, rice-init, plan, review | resolved/merged SKILL.md path + validate/diff verdicts |
| `bstack-mobile-digest` | `AndroidManifest.xml` + `Info.plist` + entitlements + Gradle/Podfile + `app.json`/`eas.json` | `mobile-manifest-auditor`, `mobile-release-gate`, mobile-release | compact platform-config summary (text, or `--json`) |
| `bstack-mobile-parity` | Android dangerous perms ↔ iOS purpose strings, per app | mobile reviewers, CI | iOS↔Android capability-drift flags |

## Validators & checkpoints

Not digests — these gate via exit codes or write a recovery checkpoint. Listed here so
the `bin/` surface is documented in one place.

| Tool | Reads | Used by | Emits / writes |
|---|---|---|---|
| `bstack-command-lint` | `.claude/commands/bstack/*.md` | improve, review, CI | structural-drift PASS/FAIL (frontmatter, task-tracking, dead refs); non-zero exit on any FAIL |
| `bstack-doc-drift` | command files ↔ `readme.md` / `MANIFEST.md` / `SessionStart.sh` / tier table / `routes.tsv` | improve, CI | index-drift PASS/FAIL (counts, coverage, phantom refs); non-zero exit on drift |
| `bstack-eval` | golden suites under `evals/` | swap-safety gate before prompt/route/model/overlay changes | per-suite pass/fail with gating exit codes (standards P-5.1/P-5.2) |
| `bstack-context-stamp` | git commit + session state | post-commit hook | crash-recovery checkpoint written under `.claude/context/` |

## Contract

- **Read-mostly.** Writers are `bstack-solutions index` and `bstack-learn log` (under `docs/`) and `bstack-context-stamp` (under `.claude/context/`); everything else only reads.
- **Compact by design.** Output is for an agent to scan, then `Read` the *one* file that matters — never a dump.
- **Graceful degradation.** No `apps/`/`libs/`, no `nx`, empty store → a one-line note, never a crash.
- **Gating exit codes.** `bstack-ddd-check`, `bstack-migrate-check`, `bstack-command-lint`, and `bstack-eval` exit non-zero on violations so commands and CI can block.
- **Dependencies:** `bash`, `git`, `python3` (already required by `bstack-learn`), and optionally `nx` (falls back to git path-mapping).

## Usage

```bash
bin/bstack-solutions search "requestid temporal"   # ranked hits — Read the top one
bin/bstack-solutions index                         # regenerate docs/solutions/INDEX.md
bin/bstack-ddd-check --diff                         # boundary violations on the current diff
bin/bstack-migrate-check libs/db/.../0001_add_x.ts  # §4 PASS/WARN/FAIL checklist
bin/bstack-affected main                            # affected apps/libs + risk flags vs main
```

When adding a command or agent that needs to survey data, ask first: **can a script digest it deterministically?** If yes, add it here and have the command call it — don't make the model read the raw data.
