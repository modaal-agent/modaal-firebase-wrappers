# Changelog

## [Unreleased]

### Added
- **In-code Firebase configuration** — new `ModaalFirebaseOptions` struct + `ModaalFirebase.configure(options:)` overload. Consumers can now configure Firebase without `GoogleService-Info.plist` and without importing `FirebaseCore`.
- **Emulator-aware factories** — `FirestoreWrapper.makeDefault(emulator:)`, `FirebaseAuthWrapper.makeDefault(emulator:)`, `CloudStorageWrapper.makeDefault(emulator:)`. Each returns a wrapper around the default SDK instance, optionally pre-configured to hit a local Firebase Emulator host:port. Parallel signatures across all three services.
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
