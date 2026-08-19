# bstack — Code Ownership

> Who owns what. Loaded by `/bstack:review`, `/bstack:hotfix`, `/bstack:retro` to route findings, tag reviewers, and notify owners.
>
> **Maintenance:** keep this current. Stale ownership = wrong people paged at 3 AM.

## Apps

| App | Primary owner | Backup | Slack |
|---|---|---|---|
| frontend-web | — | — | — |
| brand-website | — | — | — |
| backend-api | — | — | — |
| workflow-engine | — | — | — |
| browser-automation | — | — | — |
| ai-agent | — | — | — |
| ai-agent-builder | — | — | — |
| ai-extraction | — | — | — |
| data-api | — | — | — |
| agent-api | — | — | — |
| doc_parser | — | — | — |
| email-trigger-forwarder | — | — | — |
| mail-parser | — | — | — |
| voice-agent | — | — | — |
| abstract-pipeline | — | — | — |

## Shared libs

| Lib | Primary owner | Backup |
|---|---|---|
| api-interfaces | — | — |
| auth | — | — |
| db | — | — |
| logger | — | — |
| utils | — | — |

## Cross-cutting concerns

| Concern | Owner | Notes |
|---|---|---|
| Infra / Terraform | — | `tools/infra/` |
| Migrations | — | Final reviewer for `kysely-migration-validator` findings |
| Security | — | Receives all `security-sentinel` HIGH/CRITICAL |
| Observability (Datadog) | — | Dashboard / alert ownership |
| Release engineering | — | `/bstack:ship` + `/bstack:deploy` gatekeeper |

## How commands use this file

| Command | Use |
|---|---|
| `/bstack:review` | Tag the owner of each affected app in the PR |
| `/bstack:hotfix` | Page primary owner for the affected app + backup if no response in 10 min |
| `/bstack:deploy` | Require owner approval before production |
| `/bstack:retro` | Group shipped work / incidents by owner |

## Template

```
| App | Primary owner | Backup | Slack |
|---|---|---|---|
| <app-name> | @<github-handle> | @<github-handle> | <@slack-id> |
```

> When a person changes role / leaves: update both the apps + cross-cutting tables, and `git blame` this file to confirm no stale references elsewhere.
