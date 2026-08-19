---
name: bstack:devops
description: 'CI/CD pipelines + local dev environment for the Nx/DDD stack — author/repair GitHub Actions, Nx affected wiring, and reproducible local bring-up.'
argument-hint: '[--target=ci|local|all] [--service=<app>]'
model: opus
---

# /bstack:devops

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.
>
> **Use when:** you need CI/CD pipeline work (GitHub Actions, Nx `affected`, release automation) or a reproducible local dev environment. For shipping to an environment use `/bstack:deploy`; for mobile store/OTA use `/bstack:mobile-release`. Delegates to the `bstack-devops` skill.

## MCP usage

| MCP | When | What for |
|---|---|---|
| GitHub | CI work | Read/author workflow files, check Actions run status |
| Datadog | Pipeline touches SLO paths | Confirm a metric/dashboard exists for what CI gates |
| Slack | Pipeline or local-stack changes teams rely on | Announce the change |

## Steps

1. **Scope** — `--target=ci`, `local`, or `all`. Read `.claude/config/command-conventions.md` for the canonical service ports and the local-stack rule before touching anything.
2. **CI/CD (target=ci)**
   - Use `nx affected` for build/test/lint so pipelines only run what the diff touches — never a blanket rebuild.
   - Every gate is deterministic and cacheable; secrets come from the CI secret store (AWS Secrets Manager / repo secrets), never committed (critical-patterns §3).
   - Release automation aligns with `/bstack:ship` (VERSION + CHANGELOG) — do not duplicate its logic, invoke it.
   - Keep workflow YAML minimal and commented; a new SLO-impacting job pairs with a Datadog check (critical-patterns §5.4).
3. **Local dev environment (target=local)**
   - Bring the full stack up with `npm run local` — authenticated pages need backend-api + ai-agent + workflow-engine together (never a single `nx serve`). Ports are the ones in command-conventions.
   - Verify required env vars are documented and pulled at runtime, not committed. Surface any missing service or port collision.
4. **Verify** — CI: trigger or dry-run the workflow and read the result; do not claim green from inspection alone. Local: confirm each service answers on its port.
5. **Report** — what changed, how it was verified, and any follow-up (missing secret, undocumented env var) as a tracker item.

## Hard rules

- Never commit secrets, keystores, or tokens into workflow files or env files (critical-patterns §3; hard rule enforced by `/bstack:cso`).
- CI status is asserted only from an actual run in this session — never inferred from the YAML (standards A-1.2).
- Deploy/rollout judgment stays in `/bstack:deploy`; this command builds the pipeline, it does not push to production.
