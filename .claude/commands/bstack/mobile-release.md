---
name: bstack:mobile-release
description: 'Mobile store release — pre-flight, build (EAS / native), submit (App Store / Play Store), staged rollout, crash-free gate, rollback ready'
argument-hint: '[--app=<app-name>] [--platform=ios|android|both] [--track=internal|beta|production] [--rollout=5|25|50|100]'
model: opus
---

# /bstack:mobile-release

> **TASK TRACKING:** Create one task per numbered step. Mark each complete as you go.
>
> **Use when:** shipping a mobile app to App Store / Play Store. For JS-only OTA fixes use `/bstack:hotfix` instead (OTA branch). Production track ALWAYS requires explicit user confirmation at Step 3.

## MCP usage

| MCP | When | What for |
|---|---|---|
| GitHub | Always | PR status, release-workflow trigger, release notes |
| Sentry | Always | Crash-free sessions (cross-platform — source of truth per § 12.6) |
| Play Console (Android Vitals) | Android release | ANR rate, native crashes — source of truth per § 12.6 |
| App Store Connect | iOS release | Crash count, processing state, phased release — source of truth per § 12.6 |
| Slack | Always | Pre-release + per-stage notifications |
| Linear / JIRA | If release ships tickets | Transition status |
| context7 | If touching EAS / Fastlane / Gradle config | Verify usage |

## Deterministic pre-pass

Run `bin/bstack-mobile-digest --diff` once. Use its output to **decide which apps and platforms are in scope** instead of grepping the tree yourself. Hand the digest to the `mobile-release-gate` agent (Step 1) and the `mobile-manifest-auditor` agent (Step 2); they re-run their own focused checks.

**Shell pre-pass (this command runs, not the agents).** Before Step 1, collect facts the agents need but cannot fetch themselves (their tools are Glob/Grep/Read only). Paste each result into the PR body under the labeled section:

```bash
# 1. Fingerprint pair (§ 12.4 / § 12.15) — required for OTA gate
prior=$(git show "$(git describe --tags --abbrev=0)":apps/mobile-<app>/app.json 2>/dev/null \
        | npx expo fingerprint:hash --json 2>/dev/null | jq -r .hash) || prior="(no prior tag)"
current=$(npx expo fingerprint:hash --json --project apps/mobile-<app> 2>/dev/null | jq -r .hash)
echo "## Fingerprint"; echo "- Prior:   $prior"; echo "- Current: $current"

# 2. AASA verification (§ 11.15) — for every associated-domains entry
for domain in $(bin/bstack-mobile-digest apps/mobile-<app> | awk -F'[, ]+' '/associated-domains/{for(i=3;i<=NF;i++)print $i}'); do
  echo "## AASA verification"; echo "- $domain:"
  curl -sI -L "https://${domain#applinks:}/.well-known/apple-app-site-association" | head -2
done

# 3. Prior versionCode / buildNumber (§ 12.7) — for monotonicity check
git show "$(git describe --tags --abbrev=0)":apps/mobile-<app>/app.json 2>/dev/null \
  | grep -E '"versionCode"|"buildNumber"'
```

The agent reasons over the PR-body sections produced above — it does not re-execute these calls.

## Steps

1. **Release-gate review** — spawn `mobile-release-gate` against the diff. MUST pass (no CRITICAL/HIGH) before continuing. Blockers: non-monotonic version, OTA touching native, dSYM/mapping/native-debug-symbols upload steps MISSING from `eas.json` / Fastlane lane, signing material in repo. (Verification of the actual upload happens at Step 6.)

2. **Manifest audit** — spawn `mobile-manifest-auditor` against the diff. New dangerous perms / new ATS exceptions / new exported components MUST have justifications cited in the PR body.

3. **Confirm (production track only)** — show: app name, platforms, current vs. next version code/build number, expected blast radius, rollout schedule (5% → 25% → 50% → 100%), rollback command. Wait for user "yes".

4. **Pre-release Slack** — post: app, platforms, version, track, who's releasing, expected window.

5. **Build**
   - **React Native / Expo:** `eas build --platform <ios|android|all> --profile production --non-interactive`. Capture build IDs.
   - **Native Android:** trigger the release Gradle workflow (signed AAB).
   - **Native iOS:** trigger the release Xcode/Fastlane lane (archive + export).
   - Fail loud on any build error. Save build artifacts URLs.

6. **Symbol upload** (three SEPARATE uploads — § 12.8):
   - **iOS:** dSYMs uploaded to Sentry / App Store Connect / Crashlytics (EAS Build configures this automatically when wired).
   - **Android R8:** `mapping.txt` uploaded to Play Console AND to the crash reporter.
   - **Android NDK / native:** `native-debug-symbols.zip` (or per-arch `.so` symbol files) uploaded to Play Console — this is a DIFFERENT upload from `mapping.txt`; without it, native crash stacks are unreadable.
   Block if any of the three is missing.

7. **Submit**
   - **iOS:** `eas submit --platform ios --profile production` OR Fastlane `pilot`/`deliver` to TestFlight → App Store Connect.
   - **Android:** `eas submit --platform android --profile production` OR Fastlane `supply` to the requested track (internal / beta / production).
   - For App Store production: confirm phased release is enabled in App Store Connect (7-day default).
   - For Play production: set rollout percentage to the `--rollout` flag (default: 5%).

8. **Per-stage canary** — for each rollout stage, watch a 2–24h window depending on traffic:
   - Crash-free sessions ≥ 99.5% (Sentry — source of truth per § 12.6).
   - Error rate vs. prior release baseline.
   - Store-listing rating dip (Play / App Store) — any sudden drop = STOP.
   - ANR rate (Android) ≤ baseline (Play Console → Android Vitals — § 12.6).

9. **Advance rollout** — if all stages pass, advance to next % (5→25, 25→50, 50→100). If any stage fails, halt rollout, post Slack, go to Step 11.

10. **Post-release** — when at 100%: tag the release in git (`mobile-<app>-v<version>`), update CHANGELOG, post Slack success, transition Linear/JIRA tickets.

11. **Rollback / halt (if needed)**
    - **Play Store:** halt the rollout in Play Console; previous version remains for users who haven't updated. Optionally push a forward-fix via `/bstack:hotfix` (OTA branch) if JS-only fix exists.
    - **App Store:** pause phased release in App Store Connect. Forward-fix via OTA (if JS-only) or a new build (if native).
    - Open Linear incident ticket. Post Slack with status.

12. **Monitor for 48h** — keep watching crash-free + ratings. Document in the release notes / ticket.

## Hard rules

- Production track without explicit user confirmation = aborted.
- Single-shot 100% rollout to production = aborted (use staged).
- Symbol upload missing = aborted.
- Non-monotonic version code = aborted at Step 1.
- Signing material in repo = aborted at Step 1.
- Rollback path must be known and documented BEFORE Step 7. If it isn't, stop and document it first.
