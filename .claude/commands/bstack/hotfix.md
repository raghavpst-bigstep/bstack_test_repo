---
name: bstack:hotfix
description: 'Emergency production fix — diagnose, fix, test, review, PR, notify — in one pass'
argument-hint: '[bug description, error message, or Linear ticket]'
model: opus
---

# /bstack:hotfix

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.
>
> **Use when:** production broken, users impacted, speed matters. For non-urgent bugs, use `/bstack:debug`.

## MCP usage

| MCP | When | What for |
|---|---|---|
| Datadog | **Always, FIRST** | `search_datadog_logs` / `get_datadog_trace` / `get_datadog_error_tracking_issue` — get blast radius and real stack trace before reading code |
| Linear | Always | `save_issue` to create incident ticket (Urgent + `hotfix` label). `get_issue` if exists |
| Slack | Always | `slack_send_message` to incident channel with status updates |
| GitHub | At PR time | `create_pull_request` against `main` or `production` per release process |
| context7 | Library-related | Quick lookup of fix patterns |

## Steps

1. **Rapid intake (< 1 min)** — Symptom · Impact (all users? one feature?) · Since when (last deploy? migration? config?).
2. **Incident ticket** — Linear ticket created or fetched.
3. **Evidence** — Datadog: error tracking issue, recent traces, blast radius (request count, affected users). Confirm severity.
4. **Solutions search** — `learnings-researcher`, 30 seconds. If match: apply.
5. **Minimal-scope fix** — smallest possible code change. No refactor, no cleanup, no "while we're at it".
6. **Test the fix** — unit test for the regression. Re-run the failing path locally.
7. **Safety check** — does the fix introduce any auth, data-loss, or migration risk? Confirm not.
8. **Self-review** — `/bstack:review --scope=this-branch`, limited for speed to the always-on lenses (security, boundary/architecture, pattern) plus the migration validator if migrations are touched — skip the optional lenses.
9. **PR** — title: `hotfix: <one-line>`. Body: incident link, root cause, fix, test plan, rollback plan, blast radius.
10. **Notify** — Slack update with PR link.
11. **Monitor** — after merge + deploy, watch Datadog for 30 minutes. Document in the incident ticket.
12. **Compound** — `/bstack:compound` once stable.

## Mobile OTA branch (React Native / Expo via EAS Update)

If the bug is mobile and the fix is **JS / asset only** (no `*.swift`, `*.kt`, `*.java`, `AndroidManifest.xml`, `Info.plist`, `*.entitlements`, `Podfile*`, `build.gradle*`, `PrivacyInfo.xcprivacy`, no native module add/remove, no `app.json` `plugins:[]` or `runtimeVersion` change), an OTA hotfix is preferred — it ships in minutes instead of waiting for store review.

Note: CodePush is **not** an option — Microsoft retired App Center in March 2025. EAS Update is the only sanctioned OTA channel.

| Step | Action |
|---|---|
| OTA-1 | **Verify JS-only and fingerprint unchanged** — `bin/bstack-mobile-digest --diff` confirms no native config changes. Then run `npx expo-doctor` and either `npx expo prebuild --check` or `npx expo fingerprint:hash` and compare to the prior shipped fingerprint. If anything differs, this is NOT an OTA — go to `/bstack:mobile-release`. |
| OTA-2 | **Rollback note** — PR body MUST contain the prior EAS Update release ID and the revert command. Use `eas update:republish --branch production --group <prior-group-id>` (eas-cli ≥ 7.0) or `eas update:roll-back-to-embedded --branch production` to fall back to the bundled JS shipped with the last store release. Pin eas-cli version in CI (`eas-cli@^7.0.0`) so the revert command is stable. § 12.5 enforces this. |
| OTA-3 | **`mobile-release-gate` review** — must pass; it re-checks OTA-vs-store consistency, fingerprint, and the rollback note. |
| OTA-4 | **Publish** — `eas update --branch production --message "<one-line>"`. Capture the update group ID. |
| OTA-5 | **Targeted rollout with thresholds** — start at 5% via EAS Update channel rollout (matches `/bstack:mobile-release` Step 8 staging). Advance 5 → 25 → 50 only after 30 min per stage with crash-free sessions ≥ 99.5% (Sentry) AND Android ANR rate ≤ baseline (Play Console → Android Vitals) — § 12.6. Advance 50 → 100 only after a 24 h soak with the same thresholds. Any stage that fails the thresholds → revert via OTA-2, do NOT advance. |
| OTA-6 | **Monitor** — watch crash-free sessions AND Android ANR rate for 60 minutes vs. the prior release baseline at every stage. Source-of-truth dashboards per § 12.6. Any regression → revert via OTA-2 command, post Slack. |
| OTA-7 | **Compound** — `/bstack:compound`. |

## Hard rules

- No refactor in a hotfix PR.
- No new feature in a hotfix PR.
- Rollback plan is REQUIRED in the PR body. For mobile OTA, the rollback is the revert update command (see OTA-2).
- The incident ticket must be updated at: created · fix-in-PR · merged · deployed · monitored-clean.
- A mobile hotfix that touches native code MUST go through `/bstack:mobile-release`, not OTA — no exceptions.
