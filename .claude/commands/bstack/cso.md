---
name: bstack:cso
description: 'Chief Security Officer mode — OWASP + STRIDE + secrets audit of the repo or a diff, with evidence-backed findings and a remediation plan'
argument-hint: '[--scope=repo|this-branch|<path>]'
model: opus
---

# /bstack:cso

> **TASK TRACKING:** Create one task per audit dimension and one per CRITICAL/HIGH finding. Mark each complete as you go.
>
> **Use when:** periodic security audit, pre-release hardening pass, or "is this repo safe?" For per-diff security review, `/bstack:review` already runs the security lens (R §4) — this command is the deeper, system-level pass (standards A §2).

## MCP usage

| MCP | When | What for |
|---|---|---|
| GitHub | repo scope | Dependency alerts, branch-protection settings, exposed workflow secrets |
| Datadog | prod-facing findings | Confirm whether a suspect path is actually reachable/exercised |
| context7 | library CVE context | Current advisories for pinned dependency versions |

## Steps

1. **Scope** — `repo` (default), `this-branch`, or a path. Announce what is and isn't covered.
2. **Deterministic pre-pass** — run and reason over digests, not the raw tree (P-2.2):
   - secrets sweep: grep for key patterns (`AKIA`, `sk_`, `Bearer `, JWT shape, `-----BEGIN`), committed env files, `EXPO_PUBLIC_*` values (bstack §12.21, §3)
   - dependency surface: lockfile age, direct deps count, known-CVE check where tooling exists
   - `bin/bstack-mobile-digest` if mobile apps are in scope (signing material, cleartext, exported components)
3. **OWASP pass** — injection surfaces, authn/authz (every endpoint declares its role — E-3.4; IDOR probes on object access), sensitive-data exposure (PII in logs — bstack §5.2/§12.10), security misconfiguration, vulnerable components.
4. **STRIDE pass per trust boundary** — walk the architecture diagram (or build a minimal one): Spoofing, Tampering, Repudiation (audit trail — A-3.6), Information disclosure, DoS (rate limiting — E-3.13), Elevation of privilege (TOCTOU — E-3.4). One finding per concrete gap, not per category.
5. **Secrets & supply chain** — runtime secret fetch only (E-3.5, A-2.3); CI credential scope; branch protection on default branch (E-9.3); artifact provenance (A-2.7).
6. **Findings** — standard format (R-2.1) with severity per README defaults (security violations = BLOCKER). Every finding cites its rule and carries evidence (file:line, digest output) or is marked `unverified` (R-7.3).
7. **Remediation plan** — ordered by blast radius; quick wins separated from structural fixes. Write to `docs/security/YYYY-MM-DD-cso-audit.md`.
8. **Compound** — recurring finding classes → `/bstack:compound` + registry rule proposal (R-2.6).

## Hard rules

- Report-only by default: no fixes applied without user approval (E-8.1).
- Never print discovered secret values — name the location and pattern class only (bstack §3.3).
- A clean dimension gets one PASS line, not padding (R-2.3).
