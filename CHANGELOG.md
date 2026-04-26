# Changelog

## [1.3.0] — 2026-04-26

### Added

- **`Timestamp` and `FieldValue` re-exported from `ModaalFirestore`** — public typealiases in `Sources/ModaalFirestore/Types/RawTypeReExports.swift` make these write-payload value types resolvable under `import ModaalFirestore` alone, without `import FirebaseFirestore` at the call site. Reference types (`CollectionReference`, `DocumentReference`, `ListenerRegistration`, etc.) intentionally stay un-re-exported — they have dedicated wrapper protocols.
- **Provider-credential static factories on `FirebaseAuthCredentialProtocol`** — `Sources/ModaalFirebaseAuth/Wrappers/FirebaseAuthCredential+Providers.swift` exposes:
  - `.apple(idToken:rawNonce:fullName:)` — wraps `OAuthProvider.appleCredential(withIDToken:rawNonce:fullName:)`. `provider` on the returned credential is `"apple.com"`.
  - `.google(idToken:accessToken:)` — wraps `GoogleAuthProvider.credential(withIDToken:accessToken:)`. `provider` is `"google.com"`.

  Call via implicit-member syntax — `let credential: FirebaseAuthCredentialProtocol = .apple(idToken: …, rawNonce: …, fullName: nil)`. Mirrors the `FirebaseCrashlyticsProtocol.makeDefault()` pattern; requires no `import FirebaseAuth` at the call site.

  **Not in this release:** a `.oauth(...)` factory for Microsoft / Yahoo / custom OIDC providers. Firebase iOS SDK 12.x marked the String-providerID overloads of `OAuthProvider.credential(...)` as `unavailable in Swift`; the modern API takes an `AuthProviderID` enum (`.custom("oidc.my-provider")`), which would need its own wrapper to keep `import FirebaseAuth` out of consumer code. OIDC remains escape-hatch territory pending a `ModaalAuthProviderID` enum design.
- **`RawTypeReExportsTests`** in `Tests/ModaalFirestoreCombineTests/` — type-resolution smoke tests verifying `Timestamp` / `FieldValue` resolve and construct under `import ModaalFirestore` alone.
- **`FirebaseAuthCredentialFactoriesTests`** in `Tests/ModaalFirebaseAuthCombineTests/` — factory smoke tests verifying each new factory resolves under `import ModaalFirebaseAuth` alone and assigns the correct provider id.
- **SampleApp coverage** — `Examples/SampleApp/SampleApp/AuthUsage.swift` gains `exerciseAuthCredentialProviderFactories(...)` exercising all three new factories.

### Documentation

- **`Docs/agent/coverage.md`** — `ModaalFirebaseAuth` table now lists Apple / Google / OIDC factories as wrapped (with their static-factory call form). `ModaalFirestore` table now lists `Timestamp` and `FieldValue` as re-exported, with a note clarifying that this is a write-payload-only carve-out (reference types remain protocol-wrapped).
- **`Docs/human/getting-started.md`** — migration swap table gains five new rows for Apple / Google / OIDC credentials and Firestore `Timestamp` / `FieldValue` re-exports.

### Why

A real-world consumer migration (the 2026-04-26 `wikimemory-dgra0` Firebase migration) surfaced a recurring failure mode: agents and developers reasonably *expected* `ModaalFirestore` and `ModaalFirebaseAuth` to re-export the most-used Firebase value types and provider credential factories, because (a) other wrapped types were accessible without `import Firebase*`, and (b) the wrapper's `data() -> [String: Any]?` already let value types pass through opaquely. The expectation was wrong, but the alternative — sprinkling `import FirebaseFirestore` / `import FirebaseAuth` across consumer call sites — undermines the wrapper boundary the library exists to provide. These additions close the gap without changing the protocol architecture: typealiases for value types that were already crossing the boundary opaquely; protocol-static factories for credential construction.

## [1.2.2] — 2026-04-25

### Documentation
- **Coverage gap: Google Sign-In** — new `ModaalGoogleSignIn (not yet wrapped)` section in [`Docs/agent/coverage.md`](Docs/agent/coverage.md) documenting the unwrapped `GIDSignIn` surface, the re-exported `GoogleSignIn` library product, the already-wrapped `GoogleAuthProvider.credential(...)` bridge, and links to interim consumer guidance and the roadmap entry in the Modaal repo.

## [1.2.1] — 2026-04-25

### Documentation
- **Consumer-side anti-patterns** — new section in [`Docs/agent/anti-patterns.md`](Docs/agent/anti-patterns.md) covering the most common ways a migration to `modaal-firebase-wrappers` goes wrong: re-hosting the library behind a local facade that returns raw Firebase types, adding a parallel direct SPM dependency on `firebase-ios-sdk` / `firebase-ios-sdk-xcframeworks`, importing `FirebaseFirestore` / `FirebaseAuth` / `FirebaseStorage` / `FirebaseMessaging` outside the composition root, and over-using the escape hatch.

## [1.2.0] — 2026-04-21

### Added
- **In-code Firebase configuration** — new `ModaalFirebaseOptions` struct + `ModaalFirebase.configure(options:)` overload. Consumers can now configure Firebase without `GoogleService-Info.plist` and without importing `FirebaseCore`.
- **`makeDefault()` factories across every service** — wrap the Firebase SDK's default instance behind one call, no `import Firebase*` needed at the construction site. Three shapes:
  - **Services with an emulator** (Firestore / Auth / Cloud Storage): `makeDefault(emulator: (host: String, port: Int)? = nil)` — optionally pre-configures the emulator endpoint.
  - **Services without an emulator** (Messaging / Remote Config): bare `makeDefault()` — wraps the default SDK instance.
  - **Direct-conformance service** (Crashlytics): protocol-level static factory with `where Self == Crashlytics`; call via implicit-member syntax — `let c: FirebaseCrashlyticsProtocol = .makeDefault()`.
- **Firebase Emulator integration testing** — new `ModaalFirebaseEmulatorTests` bundle hosted by an XcodeGen project (`Tests/EmulatorTests/`), covering:
  - **Smoke tests** (one per wrapper family): `FirestoreWrapperSmokeTests`, `FirebaseAuthWrapperSmokeTests`, `CloudStorageWrapperSmokeTests`, `FirebaseAnalyticsWrapperSmokeTests`, `FirebaseCrashlyticsSmokeTests`, `FirebaseMessagingWrapperSmokeTests`, `FirebaseRemoteConfigWrapperSmokeTests`.
  - **Integration tests** (per-service round-trips): `FirestoreIntegrationTests` (setData, merge vs overwrite, filters, snapshot listeners), `AuthIntegrationTests` (anonymous sign-in, state listener), `CloudStorageIntegrationTests` (put/get/metadata/delete), `RemoteConfigIntegrationTests` (defaults).
  - Every test body is protocol-typed (`FirestoreProtocol`, `FirebaseAuthProtocol`, `CloudStorageProtocol`, etc.); `Shared/EmulatorHarness.swift` + the host app's `init` have zero `import Firebase*` — everything goes through the wrappers.
- **`scripts/run-integration-tests.sh`** — self-sufficient runner: installs `firebase-tools`, `openjdk@21`, starts the emulator, generates the XcodeGen test project, runs tests, tears down on exit.
- **`.github/workflows/integration-tests.yml`** — nightly (03:00 UTC) + `workflow_dispatch`. Intentionally not on every PR.
- **`Examples/RunnableDemo/`** — SwiftUI stock-ticker demo. `CollectionReferenceProtocol.snapshotPublisher()` feeds the UI; a background `Timer.publish` pushes fake market data via `DocumentReferenceProtocol.setData(_:)`. Zero `import Firebase*` in the app.
- **`Examples/SampleApp/README.md`** — documents the compile-only API-surface-verification role of SampleApp vs. RunnableDemo.
- **`Docs/human/emulator-setup.md`** — human-readable setup guide.

### Fixed
- **SampleApp launch screen** — `UILaunchScreen: {}` in Info.plist; previously fell back to a legacy launch image that letterboxed the app.

## [1.1.0] — 2026-04-19

### Added
- **`ModaalFirebaseMocks` SPM product** — 32 pre-generated Sourcery mock classes for all protocols. Zero consumer tooling overhead: `import ModaalFirebaseMocks`, use `FirestoreProtocolMock()`, done.
- **CI pipeline** — GitHub Actions running `build.sh` on Xcode 26.3 with mock freshness validation. README badge.
- **45 tests across 3 targets:**
  - `ModaalFirestoreCombineTests` (17) — Future forwarding, streaming publisher lifecycle, error propagation, cancel cleanup
  - `ModaalFirebaseAuthCombineTests` (6) — sign-in flows, auth state change publisher
  - `ModaalFirestoreTypeMappingTests` (22) — Filter/FieldPath/Source/AggregateSource conversions
- **Version support policy** in README

### Changed
- Xcode requirement clarified to 26.0+ (akaffenberger xcframeworks require Xcode 26.x; was listed as 16+ but never functional)
- Mock generation uses [swift-sourcery-templates](https://github.com/ivanmisuno/swift-sourcery-templates)@`0.2.13` with `@escaping` attribute preservation fix

## [1.0.0] — 2026-04-17

First stable release. 8 Firebase services wrapped behind Swift protocols with full Combine extension layer, escape hatches, and comprehensive documentation.

### Modules

- **ModaalFirebaseCore** — bootstrap (`configure()`) + `FirAppOptions`
- **ModaalFirebaseAuth** — 7 protocols, 40+ methods (sign-in, user management, ID tokens, reauthenticate, link/unlink, state listeners)
- **ModaalFirebaseAnalytics** — logEvent, setUserProperty, setUserID, privacy controls
- **ModaalFirebaseCrashlytics** — setUserID, setCustomValue, log, record (direct extension conformance)
- **ModaalFirestore** — 12 protocols, 70+ methods (CRUD, queries, pagination cursors, snapshot listeners with `includeMetadataChanges`, document changes, transactions, batched writes, aggregation)
- **ModaalCloudStorage** — 5 protocols (download, upload with metadata, delete, list, navigation, metadata operations)
- **ModaalFirebaseMessaging** — FCM token management, APNS token, topic subscribe/unsubscribe
- **ModaalFirebaseRemoteConfig** — fetch/activate, config values, real-time update listener, mirrored enums

### Highlights

- **32 protocols** wrapping the Firebase iOS SDK 12.x surface
- **~170 completion-handler methods** across all modules
- **39 `Future<T, Error>` Combine extensions** for one-shot operations
- **4 streaming publishers** (auth state, document snapshots, query snapshots, config updates)
- **Escape hatches** on every entry-point wrapper (public underlying Firebase type)
- **SampleApp** exercising 100% of protocol surface (completion handlers + Combine)
- **Comprehensive documentation** — README, architecture guide, getting-started guide, agent docs (coverage audit, patterns, anti-patterns, adding-a-wrapper), contributing guide

### Beyond original plan

The v1.0.0 release exceeds the original spec's planned scope:

| Area | Original plan | Delivered |
|------|--------------|-----------|
| Auth methods | ~30 (ported from template) | ~40 (+ signIn email/pw, getIDToken, reauthenticate, unlink, updatePassword, reload, revokeToken) |
| Firestore methods | ~15 (leaky — raw types) | ~70 (fully wrapped, pagination cursors, documentChanges, metadata, source-aware reads) |
| CloudStorage methods | ~10 (leaky entry point) | ~25 (fully wrapped, metadata operations, upload-with-metadata) |
| Combine layer | Not planned | 39 Future + 4 streaming publishers, FirebaseCombineSwift-compatible |
| Escape hatches | Not planned | Public underlying type on every entry-point wrapper |
| Privacy controls | Not planned | Analytics collection toggle + reset, Crashlytics collection via direct access |
| Default parameters | Not planned | `setData` defaults to `.overwrite`, `addSnapshotListener` defaults `includeMetadataChanges` to `false` |
