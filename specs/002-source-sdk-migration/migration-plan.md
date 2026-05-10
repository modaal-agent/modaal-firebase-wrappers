# v2.0.0 — Migrate from xcframeworks to source-built `firebase-ios-sdk`

**Status:** Proposed
**Last updated:** 2026-05-10
**Branch:** v2.0.0 (per user)
**Driver:** Phase 0 of the SQL Connect spike confirmed the xcframeworks flavour cannot coexist with `firebase/data-connect-ios-sdk` in one SwiftPM graph (see [Examples/SQLConnectSpike/FINDINGS.md](../../Examples/SQLConnectSpike/FINDINGS.md), spike commit `bf7880f`). Source-build is the unblocker.

## Goal

Replace the binary `firebase-ios-sdk-xcframeworks` dependency with the upstream source-built `firebase-ios-sdk`, drop the `_FirebaseCore`-via-`FirebaseAnalytics` workaround, raise the iOS floor to 17, refresh docs, add CI build-cache, and ship as `2.0.0`. Then unblock SQL Connect spike phases 1–3.

## Non-goals

- Adding `ModaalFirebaseSQLConnect`. That's a follow-up; this v2.0.0 only restores the spike's ability to reach Phase 1.
- Supporting both source and xcframeworks flavours via SPM `traits` or sibling packages. Decided dropped.
- Changing any public protocol shape. Pure infra migration; consumers' source code stays compiling.

## Decisions (pinned)

| # | Decision | Implication |
|---|---|---|
| 1 | iOS floor stays at **15** | Match upstream `firebase-ios-sdk`'s own `.iOS(.v15)` floor. The future SQL Connect wrapper ships as a **separate** library product (e.g. `ModaalFirebaseSQLConnect`) with its own `.iOS(.v17)` declaration, so SQL Connect's iOS 17 requirement does not infect existing v1.x consumers. v2.0.0's only iOS-related break is whatever the underlying SDK swap forces, not a deployment-target bump. |
| 2 | Drop xcframeworks entirely | No traits / sibling-package juggling. Single dep on `firebase-ios-sdk`. |
| 3 | `-ObjC` linker flag — empirically validate | Build SampleApp without `-ObjC` first. If categories don't load (Firestore typically the canary), keep the requirement; document accordingly. |
| 4 | CI: cache SourcePackages + DerivedData | Keyed on `Package.resolved` + Xcode version + macOS image. Big payoff: source builds compile gRPC-Swift / BoringSSL once, not per PR. |
| 5 | Drop the `FirebaseCore`-via-`FirebaseAnalytics` workaround | `ModaalFirebaseCore` depends on `FirebaseCore` directly. `ModaalFirebaseAnalytics` drops the implicit dep on `FirebaseAnalytics` that was only there for `_FirebaseCore` — wait, it actually wraps Analytics, so it keeps that dep. The savings are *in `ModaalFirebaseCore` only*. |

## Pre-migration intel (already gathered, 2026-05-10)

- Source SDK 12.13.0 declares product names that **exactly match** what we currently consume from the xcframeworks mirror: `FirebaseCore`, `FirebaseAuth`, `FirebaseAnalytics`, `FirebaseCrashlytics`, `FirebaseFirestore`, `FirebaseStorage`, `FirebaseMessaging`, `FirebaseRemoteConfig`. No spelling changes required at `.product(name: …, package: …)` sites.
- Source SDK declares `.iOS(.v15)` — bumping our floor to 17 is purely additive, no fight with upstream.
- Upstream README does **not** mention `-ObjC`. Consumers may or may not still need it — empirical check decides.
- `firebase-ios-sdk-xcframeworks` references span 14 files (verified via grep). Inventory in [Phase 4](#phase-4--documentation-sweep).

---

## Phased plan

### Phase 1 — Baseline & branch hygiene (15 min)

1. Verify on the v2.0.0 branch (whatever name the user chose). The spike commit `bf7880f` should *not* be merged — it lives in `im/sql-connect-spike` and we'll re-run it post-migration.
2. Capture current build time:
   ```bash
   rm -rf .build
   time scripts/build.sh
   ```
   Record in [`specs/002-source-sdk-migration/build-time-baseline.md`](build-time-baseline.md). Sets the budget for Phase 5.

### Phase 2 — Swap the dependency (30 min)

1. Edit [Package.swift:9](../../Package.swift#L9) and [Package.swift:28](../../Package.swift#L28):
   - `let firebaseSDK = "firebase-ios-sdk"` (was `"firebase-ios-sdk-xcframeworks"`).
   - `.package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.13.0")` (track latest 12.x at migration time).
2. Platform floor stays at `.iOS(.v15)` — match upstream `firebase-ios-sdk`. (Decision #1 in the table above.)
3. Run `swift package resolve` from the repo root. Capture the resolved tree. Expected: one and only one `firebase-ios-sdk` in the graph.
4. Build the package: `xcodebuild build -scheme ModaalFirebase-Package …`. Resolve any product-name mismatches (none expected — see "Pre-migration intel" — but verify).

### Phase 3 — Drop the FirebaseCore workaround (15 min)

1. In [Package.swift:38-43](../../Package.swift#L38-L43), change `ModaalFirebaseCore`'s dep from `FirebaseAnalytics` to `FirebaseCore`. Remove the comment block at lines 31-37 explaining the workaround.
2. Audit `ModaalFirebaseCore` source — it currently `import FirebaseCore` (which compiled because `FirebaseAnalytics` exposed it). Should still compile.
3. Confirm `ModaalFirebaseAnalytics` still depends on `FirebaseAnalytics` (it must — it wraps Analytics).
4. Re-run package build.

### Phase 4 — Documentation sweep (1–1.5 hr)

Target list (verified by grep on 2026-05-10):

| File | Lines / topic | Change |
|---|---|---|
| [README.md:165-169](../../README.md#L165-L169) | Xcode 26.x + xcframeworks note | Replace with: source-built; first build slower; CI cache recommended. |
| [README.md:59](../../README.md#L59) | `-ObjC` requirement | Update wording per Phase 6 outcome. |
| [README.md (Requirements)](../../README.md) | iOS 15+ | unchanged. (SQL Connect module, when shipped, will declare iOS 17+ on its own library product.) |
| [CONTRIBUTING.md:202](../../CONTRIBUTING.md#L202), [:208](../../CONTRIBUTING.md#L208), [:210](../../CONTRIBUTING.md#L210), [:232](../../CONTRIBUTING.md#L232) | Library-side guidance referencing xcframeworks | Rewrite around the source SDK; the "never depend on FirebaseCore directly" rule **inverts** — `ModaalFirebaseCore` now does. |
| [Docs/human/getting-started.md:50](../../Docs/human/getting-started.md#L50) | "underlying Firebase xcframeworks package" | "underlying Firebase iOS SDK". |
| [Docs/human/architecture.md:89-91](../../Docs/human/architecture.md#L89-L91) | Whole "Why xcframeworks?" paragraph | Replace with "Why source SDK?": SQL Connect compatibility, no binary toolchain coupling. Note the build-time tradeoff and the CI cache mitigation. |
| [Docs/human/emulator-setup.md:51](../../Docs/human/emulator-setup.md#L51) | "static xcframeworks" rationale | Replace with the source-build equivalent (still single test bundle for the host-app reason). |
| [Docs/agent/anti-patterns.md:27](../../Docs/agent/anti-patterns.md#L27) | "second direct pin causes duplicate-XCFramework link errors" | Update — the failure mode under source SDK is a duplicate-target SPM resolution error, not duplicate-binary link. Rule unchanged ("never add a parallel direct pin"). |
| [Docs/agent/coverage.md:82](../../Docs/agent/coverage.md#L82) | "xcframeworks binary doesn't expose these" | Verify if still accurate under source SDK (Crashlytics privacy props are now visible? worth checking). |
| [Docs/agent/coverage.md:163](../../Docs/agent/coverage.md#L163) | GoogleSignIn re-export note | Source SDK doesn't re-export GoogleSignIn. Document that consumers add it as a separate dep. |
| [Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml:12](../../Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml#L12) | Path: `firebase-ios-sdk-xcframeworks/FirebaseCrashlytics/run` | Path under source SDK is `firebase-ios-sdk/Crashlytics/upload-symbols` — verify exact path. |
| [Tests/EmulatorTests/README.md:13](../../Tests/EmulatorTests/README.md#L13) | "static xcframeworks" rationale | Same as emulator-setup.md. |
| [Tests/EmulatorTests/xcodegen.yml:30, 57, 80](../../Tests/EmulatorTests/xcodegen.yml) | Comments only | Strip xcframeworks-specific reasoning; keep the host-app reason. |
| [Sources/ModaalFirebaseCrashlytics/Protocols/FirebaseCrashlyticsProtocol.swift:9](../../Sources/ModaalFirebaseCrashlytics/Protocols/FirebaseCrashlyticsProtocol.swift#L9) | Comment about "xcframeworks binary" | Re-verify. May simply say "the Firebase SDK's `Crashlytics` class…" without the xcframework-specific framing. |
| [CHANGELOG.md](../../CHANGELOG.md) | Add `[2.0.0]` entry | Section template below in [Phase 7](#phase-7--release). |

The `Tests/EmulatorTests/xcodegen.yml:34 OTHER_LDFLAGS: "-ObjC"` line is **not** a doc — it's the existing build flag. Only revisit if Phase 6 says we can drop it.

### Phase 5 — CI build cache (45 min)

Edit [.github/workflows/ci.yml](../../.github/workflows/ci.yml):

```yaml
- name: Cache SwiftPM artifacts
  uses: actions/cache@v4
  with:
    path: |
      .build/SourcePackages
      .build/DerivedData
    key: spm-${{ runner.os }}-xc26.3-${{ hashFiles('Package.resolved', 'Package.swift') }}
    restore-keys: spm-${{ runner.os }}-xc26.3-
```

Notes:
- Key on **both** `Package.resolved` *and* `Package.swift` — a manifest edit that doesn't change `.resolved` (e.g. linker setting changes) should still bust.
- Restore-key fallback: a partial hit re-uses gRPC + BoringSSL across PRs even when a sibling dep bumps. The savings are concentrated in those two packages.
- DerivedData cache is per-Xcode-version. The `xc26.3-` key prefix prevents staleness when CI bumps Xcode.
- Same step replicated in [.github/workflows/integration-tests.yml](../../.github/workflows/integration-tests.yml).

After CI runs once, capture both timings (cold + warm) in `specs/002-source-sdk-migration/build-time-baseline.md`. Pass if warm < 1.5x of v1.x cold; fail and reconsider if warm > 3x.

### Phase 6 — `-ObjC` empirical check (30 min)

Validation procedure:
1. With Phase 2+3 changes applied, **remove** `-ObjC` from any consumer-side guidance temporarily.
2. Build the SampleApp without `-ObjC` (`Examples/SampleApp/`):
   ```bash
   cd Examples/SampleApp
   xcodegen generate --spec xcodegen.yml
   xcodebuild build -project SampleApp.xcodeproj -scheme SampleApp -destination 'generic/platform=iOS Simulator' -sdk iphonesimulator
   ```
3. Build the EmulatorTests host without `OTHER_LDFLAGS: "-ObjC"`. The Firebase smoke tests (`Tests/EmulatorTests/Shared/Smoke/`) historically crashed without it on `+load`-driven category dispatch — that's the canary.
4. **Outcome paths:**
   - Both succeed → drop the `-ObjC` requirement from docs and from `Tests/EmulatorTests/xcodegen.yml`. Update [Docs/human/getting-started.md:48-66](../../Docs/human/getting-started.md#L48-L66).
   - Either fails → keep the requirement. Update docs to clarify it's an iOS-SDK-wide requirement, not specific to xcframeworks.

#### Phase 6 outcome — 2026-05-10

**Verdict: keep the `-ObjC` requirement as documented.** No doc changes needed beyond Phase 4's wording fix.

Reasoning:
- **The runtime canary test wasn't run.** It needs the Firebase emulator (Java runtime), which isn't installed in this migration sprint's environment. Spinning it up was out of scope for the v2.0.0 push.
- **Circumstantial signal, not conclusive:** [Examples/RunnableDemo/xcodegen.yml](../../Examples/RunnableDemo/xcodegen.yml) and [Examples/SampleApp/xcodegen.yml](../../Examples/SampleApp/xcodegen.yml) **do not** set `-ObjC` and have shipped through v1.4.x without consumer reports of category-dispatch crashes — but RunnableDemo only exercises Firestore (the lightest ObjC surface) and SampleApp is compile-only. That doesn't prove the requirement is unnecessary for Auth / Crashlytics / Messaging.
- **Conservative default holds.** Firebase's own historical install guidance has called for `-ObjC`; SwiftPM static-library category-load semantics make it a reasonable safety. Removing it without proving safety could be a soft regression for consumers using `+load`-driven categories (Auth UI, Messaging swizzling, Crashlytics' `run` post-build script).
- **Phase 4's doc rewrite is already correct.** The wording at [Docs/human/getting-started.md:50](../../Docs/human/getting-started.md#L50) reads "the underlying Firebase iOS SDK requires the `-ObjC` linker flag" — accurate and not xcframeworks-specific.

Followup for a future minor (not v2.0.0): install JDK in CI, drop `OTHER_LDFLAGS: "-ObjC"` from [Tests/EmulatorTests/xcodegen.yml:34](../../Tests/EmulatorTests/xcodegen.yml#L34) on a feature branch, run [scripts/run-integration-tests.sh](../../scripts/run-integration-tests.sh) and observe the smoke-test outcome. If green, relax the doc requirement.

### Phase 7 — Release

1. Update [CHANGELOG.md](../../CHANGELOG.md) — `[2.0.0] — 2026-05-DD` entry, sections:
   - **Breaking**: xcframeworks dep replaced with source `firebase-ios-sdk`. Consumers' SwiftPM resolution graph changes; no source-code changes required.
   - **Removed**: `_FirebaseCore`-via-`FirebaseAnalytics` workaround on `ModaalFirebaseCore`.
   - **Unchanged**: iOS deployment target stays at 15 (matches upstream `firebase-ios-sdk`).
   - **Migration notes**: cold CI builds slow down (Firebase Swift wrapper layers compile from source; see [build-time-baseline.md](build-time-baseline.md) for measured numbers); cache strategy documented.
2. Tag `v2.0.0`. Push.
3. Verify CI green on the tag.

### Phase 8 — Continue the spike

1. Cherry-pick spike commit `bf7880f` from `im/sql-connect-spike` onto the v2.0.0 branch (or branch off post-tag).
2. Re-run [Examples/SQLConnectSpike/](../../Examples/SQLConnectSpike/) build:
   ```bash
   firebase dataconnect:sdk:generate --project demo-modaal-spike
   cd Examples/SQLConnectSpike
   xcodegen generate --spec xcodegen.yml
   xcodebuild build -project SQLConnectSpike.xcodeproj -scheme SQLConnectSpike -destination 'generic/platform=iOS Simulator' -sdk iphonesimulator
   ```
3. **Expected:** SPM resolution succeeds (one `firebase-ios-sdk` in the graph). App builds and links. Update [Examples/SQLConnectSpike/FINDINGS.md](../../Examples/SQLConnectSpike/FINDINGS.md) with the post-migration verdict.
4. Proceed with [spike Phase 1](sql-connect-spike-plan.md#phase-1--notes-sharing-poc-1-day) — notes-sharing PoC.

---

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| Source SDK has subtly different module structure that breaks `import FirebaseAuth` etc. inside our wrappers | Low — product names verified to match | Phase 2 builds the package; failures here block the migration cleanly. |
| CI build-time regression unacceptable even with cache | Medium | Phase 5 captures cold/warm and gates the merge on a 3x ceiling. If breached: profile, consider precompiled-headers or BoringSSL pinning, escalate. |
| `-ObjC` ends up needed only for *some* products (e.g. Firestore but not Auth) | Low | Phase 6 validates against SampleApp (full surface) + EmulatorTests (runtime). |
| The Crashlytics `run` script path change breaks consumers | Medium | Phase 4 documentation explicitly covers it; smoke-test in EmulatorTests. |
| Deps that the xcframeworks mirror added (e.g. ads SDK) are missing under source SDK | Low — we don't actually use ads | Audit SourcePackages graph after Phase 2 resolve. |
| ~~iOS 17 floor breaks downstream consumers stuck on 15/16~~ | n/a under revised decision #1 | iOS floor stays at 15. SQL Connect's iOS 17 floor lives only on its standalone module. |

## Rollback / abort criteria

Abort the migration and reconsider if any of these become true:
- Phase 2 fails to resolve / build for reasons that aren't simple product-name fixes.
- Phase 5 warm CI build > 3x cold v1.x baseline (cache ineffective).
- Phase 6 surfaces a failure mode where `-ObjC` doesn't fix the build under source SDK (would mean a deeper break).

Rollback is `git revert` of the v2.0.0 commits — the migration is structured to land in coherent per-phase commits to make this surgical. The `im/sql-connect-spike` branch is unaffected by any rollback.

## Estimated effort

~4–5 hours active engineering, sequential (each phase gates the next):

| Phase | Budget |
|---|---|
| 1 — Baseline | 15m |
| 2 — Swap dep | 30m |
| 3 — Drop workaround | 15m |
| 4 — Docs sweep | 1.5h |
| 5 — CI cache | 45m |
| 6 — `-ObjC` check | 30m |
| 7 — Release | 30m |
| 8 — Spike continuation | (~2 days, scoped separately under [the spike plan](sql-connect-spike-plan.md)) |

## Open questions

- **Branch name.** Is the v2.0.0 branch `v2.0.0`, `v2_0_0`, `v2`, something else? (User mentioned "v2_0_0" in chat but didn't pin.) Affects only commit/PR refs.
- **`Package.resolved` checked in?** Currently committed. Confirm post-migration that diff is reviewable; the gRPC-Swift transitive graph is bigger.
- **Does GoogleSignIn coverage gap need treatment now or stays in v2.0.x?** [Docs/agent/coverage.md:163](../../Docs/agent/coverage.md#L163) currently leans on the xcframeworks re-export. Source SDK doesn't re-export it. v2.0.0 may need to update the doc to "consumer adds GoogleSignIn separately" — but adding `ModaalGoogleSignIn` is out of scope.
