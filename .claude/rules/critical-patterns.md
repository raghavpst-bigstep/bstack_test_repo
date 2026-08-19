# bstack — Critical Patterns (BigStep Project Registry)

> Consolidated rules loaded as context by reviewers and commands. Edit ONCE here; do not duplicate into individual command/agent files.

**Registry status:** This file is BigStep's **project registry** implementing the
generic engineering standards in `docs/standards/` (README design rule 7). Its rules
keep their historical section numbers for citation stability (README design rule 6 —
IDs are never renumbered); cite them with the `bstack §` prefix (e.g. `bstack §4.1`)
so they can never collide with generic `E-/T-/R-/A-/P-` IDs. Every section **tightens**
the generic rules named in the refines map below — a rule here may never loosen a
generic rule. New registrations follow the same review-like-code process as any
registry change; brand-new project rules may alternatively use the `*P-` namespace
per the standards README.

## Refines map (registry → generic standards)

| Section | Refines |
|---|---|
| §1 DDD boundaries (Nx) | E-2.1–E-2.4, E-2.6, R-6.1 |
| §2 Async context propagation | E-3.6, R-6.5 |
| §3 Secrets | E-3.5, R-4.3, A-2.3 |
| §4 Migrations (Kysely) | E-4.1–E-4.5, T-3.1 |
| §5 Logging & observability | E-3.7, R-6.6, A-2.9, A-2.10 |
| §6 Auth & authz | E-3.4, E-5.2, R-4.1, R-4.2 |
| §7 Frontend | E-3.3, E-3.4 |
| §8 AI services (Python / Temporal) | R-4.4 (prompt injection), E-3.6, E-3.10 |
| §9 Performance | E-3.8, E-3.9, R-5.1–R-5.3 |
| §10 Android | E-3.4, E-3.5, E-9.x; registered review lens `mobile-manifest-auditor` (R §8) |
| §11 iOS | A-3.4, E-9.x; registered review lens `mobile-manifest-auditor` (R §8) |
| §12 Mobile cross-cutting | E-9.5 (kill switch), E-9.6 (monotonic versions), E-9.7 (staged rollout), A-2.10 (crash/symbols), A-4.2 (ADR-gated stack) |
| §13 Mobile compliance & legal | A-3.1–A-3.5 |
| §14 Feature protocol (R.I.C.E.) | A-4.2 (locked-stack gate) |

## 1. DDD boundaries (Nx)

| # | Rule | Failure mode |
|---|---|---|
| 1.1 | `apps/*` never imports from other `apps/*` | Tight coupling, deploy lockstep |
| 1.2 | `libs/*` never imports from `apps/*` | Inverted dependency, untestable libs |
| 1.3 | Cross-domain types live in `libs/api-interfaces` only | Type drift across services |
| 1.4 | Cross-app communication = REST / gRPC / SQS — NEVER shared DB tables | Hidden coupling |
| 1.5 | `project.json` declares the dependencies the imports actually use | Nx cache misses, broken affected graph |
| 1.6 | `apps/mobile-*` and `apps/native-*` never import from `apps/web-*` or any web-only lib; they consume cross-tier types only via `libs/api-interfaces` | Web ↔ mobile coupling, type drift across clients |

## 2. Async context propagation

| # | Rule | Failure mode |
|---|---|---|
| 2.1 | `requestId` / request context must be carried across `await`s, into queues, and into Temporal activities | Lost request scope → untraceable work |
| 2.2 | Background workers extract context from the message envelope, NEVER from process state | Wrong/stale context processed |
| 2.3 | Temporal activity inputs carry full context — no implicit shared state | Activity runs with the wrong inputs |

## 3. Secrets

| # | Rule | Failure mode |
|---|---|---|
| 3.1 | No secrets in source, env files committed to git, logs, or Temporal workflow inputs | Credential exposure |
| 3.2 | Secrets pulled at runtime from AWS Secrets Manager / SSM, never committed | Bootstrap leak |
| 3.3 | Logs never contain truncated secret prefixes — these are usable in brute-force | Credential exposure |
| 3.4 | No signing keys, keystores, provisioning profiles, App Store Connect API keys, or Play Console service accounts in the repo — pulled at CI time from AWS Secrets Manager | Store-account takeover, signed-malware risk |
| 3.5 | Mobile clients never embed long-lived API secrets (Stripe secret keys, admin tokens) — clients call a backend that holds them | Trivial secret extraction from any installed APK/IPA |

## 4. Migrations (Kysely)

| # | Rule | Failure mode |
|---|---|---|
| 4.1 | `down` actually reverses `up`, OR migration declares it irreversible | Stuck deploys |
| 4.2 | Large-table NOT NULL adds use default + backfill, not single statement | Lock-induced outage |
| 4.3 | Indexes on prod-sized tables use `CREATE INDEX CONCURRENTLY` | Lock contention |
| 4.4 | `up` is idempotent / safe to re-run if interrupted (`IF NOT EXISTS` etc.) | Half-applied migration |
| 4.5 | Never edit a shipped migration — write a new one | History divergence |

## 5. Logging & observability

| # | Rule | Failure mode |
|---|---|---|
| 5.1 | Every operation log carries `requestId` | Untraceable incidents |
| 5.2 | Errors include enough context to repro (input shape, not PII) | Slow incident response |
| 5.3 | Structured JSON logs only — no `console.log` in services | Lost in Datadog |
| 5.4 | Datadog metric / dashboard exists for every new SLO-impacting code path | Silent regressions |
| 5.5 | Mobile clients generate or propagate `requestId` on every backend call (header `x-request-id`) and include it in crash reports | Untraceable cross-device incidents |
| 5.6 | Every mobile app ships with crash reporting wired before first release. **By app type:** RN/Expo apps use Sentry React Native (ADR-001 lock) with ANR detection AND `sentry-android-ndk` for native crash capture. Native Android (`apps/native-android-*`) may use Sentry Android OR Firebase Crashlytics — the choice is per-app but documented in the per-app `CLAUDE.md`. Native iOS (`apps/native-ios-*`) uses Sentry Apple OR Crashlytics on the same terms. Source-of-truth for staged-rollout thresholds is Sentry per § 12.6 regardless of which SDK ships. | Silent crashes; cross-app metric drift |

## 6. Auth & authz

| # | Rule | Failure mode |
|---|---|---|
| 6.1 | Every endpoint declares required role/permission — no implicit "any logged-in user" | Privilege escalation |
| 6.2 | Token validation happens at the edge AND on cross-service calls | Trust boundary collapse |
| 6.3 | TOCTOU checks: re-check authorization at the action site, not just route entry | Race-window escalation |
| 6.4 | Object access is authorized against the current user — a user cannot reach another user's records by ID | IDOR class |

## 7. Frontend

| # | Rule | Failure mode |
|---|---|---|
| 7.1 | MUI form state validated on the server too — client validation is UX, not security | Tampered input |
| 7.2 | URLs / params never let a user reach another user's records without a server-side authz check | IDOR class |

## 8. AI services (Python / Temporal)

| # | Rule | Failure mode |
|---|---|---|
| 8.1 | LLM prompts pass user/request context as tagged fields — never free-form prefix where users can inject | Prompt injection escalation |
| 8.2 | Document chunks carry their source IDs through every transform | Wrong-source retrieval |
| 8.3 | Temporal activity retries are idempotent — no side effects on retry | Double charges, double messages |

## 9. Performance

| # | Rule | Failure mode |
|---|---|---|
| 9.1 | N+1 queries are blockers, not warnings | Linear cost growth |
| 9.2 | Any query over potentially-unbounded data has a `LIMIT` and/or pagination | OOM as data grows |
| 9.3 | Frontend lists virtualize beyond ~50 rows | Browser jank |
| 9.4 | Mobile lists use `@shopify/flash-list` (RN, default for variable-row), `LazyColumn` (Compose), or `LazyVStack` (SwiftUI); never map to a non-virtualized container beyond ~30 rows. RN `FlatList`/`SectionList` only for stable small lists. | Frame drops, scroll jank on mid-tier devices |
| 9.5 | Mobile images are sized server-side or via a transform CDN — never download the full original to display a thumbnail | Bandwidth + memory OOM |

## 10. Android

| # | Rule | Failure mode |
|---|---|---|
| 10.1 | Every dangerous permission has a runtime request gated on actual use, with a rationale UI for denied/permanently-denied | Store rejection, user trust loss |
| 10.2 | `android:exported` is explicit on every component; deep-link intent filters declare `android:autoVerify="true"` and host verification works | Activity hijacking, intent spoofing |
| 10.3 | No secrets in `BuildConfig`, `strings.xml`, or resource files — secrets fetched at runtime from backend or the platform Keystore | APK extraction leaks credentials |
| 10.4 | Background work uses `WorkManager` (or Foreground Service with the right type); never a bare `Thread` / `AsyncTask` for persistent work | Work killed silently, battery drain |
| 10.5 | `targetSdk` follows Play's annual enforcement window (Aug 31 each year): new apps and app **updates** must hit at least the previous year's API level (e.g., in 2024 the floor was API 34). Existing apps that don't bump by the deadline cannot ship updates until they do. Plan the bump within each release cycle, not at the deadline. | Forced de-listing; cannot release updates after the window |
| 10.6 | `usesCleartextTraffic="false"` (or scoped network security config); HTTP allowed only for documented localhost dev | MITM exposure |
| 10.7 | Release builds enable R8/ProGuard with keep-rules tested; no debuggable APK uploaded | Reverse-engineering, prod crashes from over-shrinking |
| 10.8 | Signing config (keystore, passwords) is **never** in the repo — injected by CI from AWS Secrets Manager | Signing-key compromise = account takeover |
| 10.9 | `StrictMode` is enabled in debug builds; main-thread disk/network is a build failure, not a warning | Frozen UI on real devices |
| 10.10 | `Context` retained references go through `applicationContext` or `WeakReference` — never hold an Activity across async boundaries | Memory leaks → OOM |
| 10.11 | Every `PendingIntent` on Android S+ (API 31+) sets `FLAG_IMMUTABLE` unless mutability is explicitly required and justified in a code comment | Implicit-intent hijack; runtime `IllegalArgumentException` |
| 10.12 | Every foreground service declares `android:foregroundServiceType=...` in the manifest AND calls `startForeground(id, notif, type)` with the matching type | Android 14+ `ForegroundServiceTypeException` at runtime |
| 10.13 | Cross-process file sharing goes through `FileProvider` with scoped `FLAG_GRANT_READ_URI_PERMISSION`; no `file://` URIs across processes | `FileUriExposedException` on N+, data leak |
| 10.14 | `POST_NOTIFICATIONS` is requested at runtime on Android 13+ (API 33+); silent notification posts before grant are blocked | Notifications silently dropped; user trust loss |

## 11. iOS

| # | Rule | Failure mode |
|---|---|---|
| 11.1 | Every Info.plist purpose string (`NS*UsageDescription`) is present and accurate for declared capabilities | App Review rejection, runtime crash on permission request |
| 11.2 | Capabilities in `*.entitlements` match what the app actually uses — no orphaned entitlements | Provisioning conflicts, review delay |
| 11.3 | App Transport Security (ATS) is on; any `NSAppTransportSecurity` exception has a written justification in the PR | MITM, review rejection |
| 11.4 | Secrets stored in Keychain with appropriate accessibility (`kSecAttrAccessibleWhenUnlocked*`); never in `UserDefaults` or plist | Backup extraction leaks credentials |
| 11.5 | Background tasks declare `UIBackgroundModes` exactly for what they do; long work uses `BGTaskScheduler` not legacy `beginBackgroundTask` for new code | Tasks killed, store rejection |
| 11.6 | UI mutations happen on `@MainActor` / `MainActor.run`; no main-thread blocking I/O | Beachball, watchdog termination (0x8badf00d) |
| 11.7 | `applicationDidReceiveMemoryWarning` (or SwiftUI equivalent) frees caches; no unbounded in-memory stores | Jetsam termination |
| 11.8 | App Store Connect API keys, signing certs, and provisioning profiles are in CI secret store only — never in the repo | Account takeover |
| 11.9 | Universal Links and custom URL schemes have associated-domain entitlements verified end-to-end before merge | Broken auth flows, hijacking |
| 11.10 | No `UIWebView` (deprecated, blocks submission); use `WKWebView` with `javaScriptEnabled` scoped to the minimum; no `allowsArbitraryLoads` / no JS↔native message handlers that expose native APIs without origin checks | Store rejection; web→native code execution |
| 11.11 | Every app and every bundled SDK ships `PrivacyInfo.xcprivacy` declaring data types, tracking, and required-reason APIs (`NSPrivacyAccessedAPITypes` — `UserDefaults`, `FileTimestamp`, `SystemBootTime`, `DiskSpace`, `ActiveKeyboards`). Required by Apple since May 2024. | ITMS-91053 / 91056 hard reject |
| 11.12 | Any IDFA access or cross-app tracking requires `NSUserTrackingUsageDescription` AND a call to `ATTrackingManager.requestTrackingAuthorization`. Purpose strings must state the user-facing benefit concretely; vague phrasing ("to improve your experience") is auto-rejected. | App Review reject; IDFA returns zeros |
| 11.13 | `ITSAppUsesNonExemptEncryption` is set in `Info.plist` (or the equivalent answer is recorded in App Store Connect) on every store build | TestFlight processing stalls indefinitely |
| 11.14 | If any third-party social login is offered (Google / Facebook / etc.), Sign in with Apple is offered at equal prominence (Guideline 4.8) | App Review auto-reject |
| 11.15 | `applinks:` entitlement requires a reachable `apple-app-site-association` file at the apex domain, served as `application/json` (no extension, no redirect), and verified end-to-end before release | Universal links silently fail in production |
| 11.16 | `aps-environment` is `production` on store builds (not `development`); APNs token type and environment match the server | Silent push delivery failure |
| 11.17 | Required-reason APIs apply to FIRST-PARTY code, not just SDKs — every use of `UserDefaults` / file timestamps / boot time / disk space / active keyboards is declared in `PrivacyInfo.xcprivacy` with a documented reason code | Same hard reject as 11.11 |

## 12. Mobile cross-cutting

| # | Rule | Failure mode |
|---|---|---|
| 12.1 | The locked-stack table in `docs/architecture/ADR-001-mobile-stack.md` is the vouched-for dependency list. Any PR adding a dep outside it is blocked unless the SAME PR extends the ADR-001 table with rationale (replacement / capability gap / measurement). | Silent stack expansion, divergent mobile stacks |
| 12.2 | Native escape hatches (`apps/native-*`) require an ADR amendment with the capability gap, measurement, or platform-exclusive UX justification | Maintenance cost without benefit |
| 12.3 | Cross-platform shared code lives in `libs/mobile-*` (RN/TS) or `libs/api-interfaces` (types); no copy-paste between mobile apps | Drift between iOS and Android |
| 12.4 | OTA updates use EAS Update only (Microsoft retired App Center / CodePush in March 2025). OTA ships JS/asset deltas only. **Any** of the following changes the runtime version fingerprint and MUST go through a store release, not OTA: native source (`*.swift`, `*.m`, `*.mm`, `*.kt`, `*.java`, `*.h`, `*.c`, `*.cpp`); native config (`Podfile*`, `*.podspec`, `*.xcconfig`, `*.xcodeproj/**`, `Gemfile*`, `build.gradle*`, `gradle.properties`, `gradle-wrapper.properties`, `settings.gradle*`); platform manifests (`AndroidManifest.xml`, `Info.plist`, `*.entitlements`, `PrivacyInfo.xcprivacy`); RN/Expo native-impacting (`app.json` `plugins:[]` / `runtimeVersion` / `expo.ios.*` / `expo.android.*`, `app.config.{js,ts}`, `metro.config.{js,ts}`, `babel.config.{js,ts}`, `react-native.config.js`, `expo-module.config.json`); package adds/removes of `expo-*`, `react-native-*`, `@react-native-*`, or `@expo/*`. | OTA targets the wrong build → crash loop, no JS-side rollback |
| 12.5 | OTA hotfixes go through `/bstack:hotfix` with a written rollback note (previous release channel + revert command) | Unrecoverable bad OTA |
| 12.6 | Store releases follow staged rollout (5% → 25% → 50% → 100%) with crash-free-sessions ≥ 99.5% AND Android ANR rate ≤ baseline between stages. **Source-of-truth dashboards (authoritative — no other source overrides):** crash-free sessions = Sentry (cross-platform); Android ANR rate = Play Console → Android Vitals; iOS crash rate cross-check = App Store Connect → Metrics. | Bad release reaches 100% of users before signal; agents argue over which dashboard to trust |
| 12.7 | Version code (Android) and build number (iOS) are strictly monotonic — never reused or decremented | Store reject, OTA targeting bugs |
| 12.8 | Three symbol artifacts are uploaded on every store build (and OTA, where applicable): (a) iOS dSYMs to Sentry (EAS auto-uploads when `SENTRY_AUTH_TOKEN` is in EAS Secrets and `@sentry/react-native/expo` is in `app.json` plugins); (b) Android R8 `mapping.txt` to Play Console AND the crash reporter; (c) Android NDK `native-debug-symbols.zip` to Play Console **separately** from `mapping.txt`. For RN/Expo: JS source-maps are also uploaded to Sentry on every store release AND every OTA (otherwise JS stacks are unreadable; Sentry RN release `dist` MUST match `versionCode` / `buildNumber` or crash grouping breaks). | Unreadable crash stacks across all layers |
| 12.9 | Deep links and universal/app links are tested on a real device per release — emulator passes are insufficient | Auth / share flows broken in production |
| 12.10 | PII (email, phone, location, device IDs beyond what the store policy allows) is never logged from the device; redact before send | Store-policy violation, privacy incident |
| 12.11 | Tokens, session IDs, PII, and other sensitive values are stored ONLY in `expo-secure-store` (RN) / Keychain (iOS) / Android Keystore — never in `AsyncStorage`, plain `UserDefaults`, plain `SharedPreferences`, or `MMKV` instances without encryption keys | Trivial extraction from device backups / rooted devices |
| 12.12 | Non-secret structured cache on RN uses `react-native-mmkv` (sync, ~10× faster, no JSON overhead) — `AsyncStorage` only for legacy compatibility | UI jank, redundant JSON serialization on every hot path |
| 12.13 | Reanimated worklets are pure: no closure over JS-thread mutable state, no `console.log` inside a worklet, no async/await, no Promise; cross-thread values use `runOnJS` / `useSharedValue` only | Runtime crash on UI thread, silent state corruption |
| 12.14 | No inline `require(...)` in a component render path — Metro cannot tree-shake or pre-bundle, every render pays the resolution cost | Frame drops, increased bundle size |
| 12.15 | The fingerprint check enforces § 12.4: `/bstack:hotfix` OTA-1 runs `expo prebuild --check` (Expo SDK 51+) or `expo fingerprint:hash` (SDK 52+) and compares to the prior shipped fingerprint. Any mismatch routes the change to `/bstack:mobile-release`, not OTA. | Wrong-fingerprint OTA → crash loop, no rollback |
| 12.16 | Native module additions follow the codegen + threading + lifecycle checklist enforced by `mobile-manifest-auditor` (TurboModule spec, no UI-thread JSI blocking, matched `addListener`/`remove`, ≤ ~1 MB bridge payloads, autolinking entries, Fabric parity across iOS/Android) | Bridge deadlocks, memory leaks, platform drift |
| 12.17 | RN monorepo `metro.config.js` declares `watchFolders` for workspace packages and `resolver.nodeModulesPaths` for hoisted dependencies; symlink resolution must match the package manager in use | Metro cannot resolve workspace imports; "Unable to resolve module" in CI but not locally |
| 12.18 | Every mobile release PR (store OR OTA) MUST contain a `## Fingerprint` section in the PR body with `Prior` and `Current` hashes from `expo fingerprint:hash` (or `expo prebuild --check` on SDK 51). For OTAs these MUST be equal; for store releases they MAY differ (a store release exists precisely because they differ). `mobile-release-gate` blocks if the section is missing. | OTA targets the wrong build; reviewer has no machine signal |
| 12.19 | RN apps lock the JS engine to **Hermes**. `app.json` MUST NOT set `expo.jsEngine = "jsc"` and bare projects MUST NOT enable JSC in Gradle / Podfile. Hermes is required for: New Architecture, ANR detection in Sentry, Hermes opcodes for size, source-map stability. | Stack drift; ANR/perf SLOs not measurable |
| 12.20 | `app.json` `expo.runtimeVersion` uses the `{"policy": "fingerprint"}` form on Expo SDK 52+ (or `"appVersion"` only on SDK ≤ 50 where fingerprint is unavailable). Constant string `runtimeVersion: "1.0.0"` is forbidden — every native dep upgrade silently invalidates OTAs. `mobile-manifest-auditor` reads the digest's `runtimeVersion` field and flags non-fingerprint policies as MEDIUM. | OTA invalidation on every store bump; users stuck on stale JS |
| 12.21 | No `EXPO_PUBLIC_*` env var contains a secret. `EXPO_PUBLIC_*` is bundled into the client JS at build time and shipped to every device — anyone can extract it. Secrets go through a backend endpoint. Pre-commit / CI greps `EXPO_PUBLIC_.*=` against a deny-list (`sk_`, `AKIA`, `Bearer `, JWT pattern). | Client-side secret extraction |
| 12.22 | Every mobile app declares a kill-switch path: (a) a feature-flag SDK (Statsig / LaunchDarkly / Unleash / GrowthBook — picked per consuming repo and documented in its per-app `CLAUDE.md`); (b) a server-enforced minimum-version gate that, if violated, renders a force-update screen with a single "Update now" CTA opening the store. The screen is NOT OTA-deliverable (must ship in the native bundle so it survives a bricked JS layer). | No recovery path from a bricked OTA or a regulatory takedown |
| 12.23 | Native escape-hatch Android (`apps/native-android-*`) ships a Baseline Profile (`baseline-prof.txt`) + a Macrobenchmark module that runs startup and scroll passes in CI. Releases without these fail `mobile-release-gate`. Cold-start budget: < 1500 ms on a current mid-tier reference device. | Startup regressions ship unmeasured |

## 13. Mobile compliance & legal

| # | Rule | Failure mode |
|---|---|---|
| 13.1 | **Apple App Tracking Transparency (ATT)** — no tracking SDK (Meta SDK, AppsFlyer, Adjust, Branch, Google Mobile Ads, AppLovin, ironSource, Mintegral, Unity Ads, Singular, Kochava) initializes BEFORE the user grants ATT. SDK init happens inside a `requestTrackingAuthorization` continuation, never on app launch. Auto-init flags MUST be disabled and re-enabled post-consent. | IDFA leak before consent → App Review reject (5.1.2), GDPR Art 6 violation |
| 13.2 | **iOS Privacy Nutrition Label (App Store Connect)** is kept in sync with `PrivacyInfo.xcprivacy` and the actual data the app collects. Source-of-truth file: `apps/<app>/privacy-label.yaml` (committed). `mobile-release-gate` diffs it vs. the declared SDK list. | ASC label drift → Apple notice + delisting risk |
| 13.3 | **Android Play Data Safety form** is kept in sync with `AndroidManifest.xml` perms + collected data. Source-of-truth file: `apps/<app>/data-safety.yaml` (committed). `mobile-release-gate` diffs it vs. manifest perms. | Play delisting risk for divergence |
| 13.4 | **iOS required-reason API codes (Apple-published list)** are documented per first-party use in `apps/<app>/privacy-label.yaml` under `accessed_apis:`. Approved reasons (subset): `UserDefaults` → CA92.1 / C617.1 / 1C8F.1 / AC6B.1; `FileTimestamp` → C617.1 / 3B52.1 / 0A2A.1 / DDA9.1; `SystemBootTime` → 35F9.1 / 8FFB.1 / 3D61.1; `DiskSpace` → 85F4.1 / E174.1 / 7D9E.1 / B728.1; `ActiveKeyboards` → 54BD.1. Wrong code = ITMS-91056 reject. | Submission reject; debugging the wrong code burns hours |
| 13.5 | **GDPR / CCPA consent SDK** is wired before any analytics or tracking SDK initializes. Picked per consuming repo (Didomi / OneTrust / Sourcepoint / in-house with documented schema); choice recorded in per-app `CLAUDE.md`. Record-of-consent (timestamp, scope, jurisdiction) is sent to backend on every grant/revoke. | GDPR Art 7 violation (proof of consent); CCPA "Do Not Sell" non-compliance |
| 13.6 | **DSA (EU Digital Services Act)** — store listing carries trader name + EU contact email + EU address for any app distributed in the EU (both stores enforce since Feb 2024). Source-of-truth: `apps/<app>/store-trader-info.yaml`. | EU delisting |
| 13.7 | **COPPA (US Children's Online Privacy Protection Act)** — if `apps/<app>/audience.yaml` declares `under_13: true` or `mixed: true`, the app may NOT use any SDK on the Play "Families" forbidden list, and ATT/tracking are unconditionally disabled. ASC age rating reflects the audience. | FTC enforcement; Play removal from Families program |
| 13.8 | **Regional store rules** — apps shipped to KSA / UAE / India / China declare any regional requirements in per-app `CLAUDE.md` (KSA: GAMR registration for some categories; UAE: TDRA license; India: DPDP-Act data residency for sensitive classes; China: ICP/MIIT filing). Bypass = regional delisting. | Regional delisting; legal exposure |
| 13.9 | **OSS license compliance** — every app bundles an attribution screen listing every third-party dependency (auto-generated from `package.json` + `Podfile.lock` + Gradle deps). Compose and Hilt require attribution. | Apple Guideline 5.6.2 reject; license non-compliance |
| 13.10 | **No PII / device IDs in product analytics events** — every analytics event passes through a schema validator (per-app `analytics-schema.yaml`) that rejects fields matching email regex, phone regex, lat/long, IDFA/AAID, IDFV, advertising-tracking-enabled. CI test runs the schema against committed event fixtures. | Apple App Review 5.1 / Play Data Safety violation; user-trust incident |

## 14. Feature protocol (R.I.C.E.)

| # | Rule | Failure mode |
|---|---|---|
| 14.1 | New-feature work follows the SKILL.md resolved by `bin/bstack-rice path <touched file>` (base + per-app, merged). For existing-code edits, match local conventions instead. | Drift from locked stack / forbidden list |
| 14.2 | The locked-stack table in the resolved SKILL.md is the vouched-for dependency list. PRs adding deps not in the table are surfaced to the reviewer (advisory — reviewer decides whether to extend the table or reject). | Silent stack expansion |
| 14.3 | Forbidden-list hits in a diff are review-blocking unless explicitly overridden in the PR description. | Re-introduction of known bad patterns |
