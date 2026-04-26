# Changelog

## [1.4.0] — 2026-04-26

### Added

- **`ExpressibleByStringLiteral` conformance on `FieldPath`** — string-literal call sites such as `query.order(by: "createdAt", descending: true)` now work directly. Existing `.field("...")` and `.fields([...])` call sites continue to compile unchanged. Three-line additive change in `Sources/ModaalFirestore/Types/FieldPath.swift`.
- **Refining `QueryDocumentSnapshotProtocol`** — new protocol in `Sources/ModaalFirestore/Protocols/QueryDocumentSnapshotProtocol.swift` refines `DocumentSnapshotProtocol` by overriding `data() -> [String: Any]?` with non-optional `data() -> [String: Any]`. Mirrors Firebase iOS SDK's `QueryDocumentSnapshot : DocumentSnapshot` class hierarchy. New concrete `QueryDocumentSnapshotWrapper` and Sourcery-annotated `QueryDocumentSnapshotProtocolMock` (with both `data()` overloads disambiguated as `dataStringAnyHandler` / `dataStringAnyOptionalHandler`).
- **Two-tier API surface (B4-alt revised)** — protocol declarations now mirror Firebase iOS SDK signatures exactly (modulo the documented safety carve-outs); Swift-idiomatic ergonomic forms live as protocol *extensions* under `Sources/<Module>/Extensions/*+Idioms.swift`, delegating to the canonical methods. Mocks reflect the protocol layer only — no doubled mock surface.
- **`Sources/ModaalFirestore/Extensions/`** — new `DocumentReferenceProtocol+Idioms.swift`, `WriteBatchProtocol+Idioms.swift`, `TransactionProtocol+Idioms.swift` preserving `setData(_:mergeOption: MergeOption, completion:)` as a Swift-idiomatic extension dispatching to canonical `setData(_:merge: Bool, completion:)` / `setData(_:mergeFields: [Any], completion:)`.
- **`Sources/ModaalCloudStorage/Extensions/`** — new `CloudStorageReferencing+Idioms.swift`, `CloudFileStoring+Idioms.swift` preserving labeled `child(path:)` and `getDownloadURL(completion:)` as Swift-idiomatic aliases delegating to canonical `child(_)` and `downloadURL(completion:)`.
- **`Sources/ModaalFirebaseAuth/Extensions/`** — new `FirebaseAuthProtocol+Idioms.swift` preserving `canHandleOpenUrl(_:)` and `canHandleRemoteNotification(_:)` as Swift-idiomatic aliases delegating to canonical `canHandle(_:)` and `canHandleNotification(_:)`.
- **Combine variants of canonical signatures** — `setData(_:merge: Bool)`, `setData(_:mergeFields: [Any])`, `downloadURL()` Combine extensions added alongside the existing `setData(_:mergeOption:)` and `getDownloadURL()` aliases.
- **New SPM test target `ModaalCloudStorageCombineTests`** — hosts `CloudStorageSignatureParityTests`.
- **`FirebaseSignatureParityTests`** in `Tests/ModaalFirestoreCombineTests/` — verifies Firestore `setData(_:merge:)` and `setData(_:mergeFields:)` mocks; verifies the `mergeOption: MergeOption` extension dispatches to the canonical mock handlers.
- **`AuthSignatureParityTests`** in `Tests/ModaalFirebaseAuthCombineTests/` — verifies Auth `canHandle(_)` and `canHandleNotification(_)` mocks; verifies the legacy `canHandleOpenUrl(_)` / `canHandleRemoteNotification(_)` aliases dispatch to the canonical mock handlers.
- **`QueryDocumentSnapshotProtocolTests`** in `Tests/ModaalFirestoreCombineTests/` — verifies dual `data()` overload resolution (non-optional under `QueryDocumentSnapshotProtocol` typing; optional under `DocumentSnapshotProtocol` upcast); iteration without `guard let`.
- **`FieldPathExpressibleByStringLiteralTests`** in `Tests/ModaalFirestoreTypeMappingTests/` — string-literal conformance produces same `FirebaseFirestore.FieldPath` as `.field(_:)`.

### Changed (formally breaking — see Semver below)

- **`QuerySnapshotProtocol.documents`** return type narrows from `[DocumentSnapshotProtocol]` to `[QueryDocumentSnapshotProtocol]`. Type-inferred call sites (`for doc in snapshot.documents`) are unaffected; explicit `[DocumentSnapshotProtocol]` ascriptions need updating.
- **`DocumentChangeProtocol.document`** return type narrows from `DocumentSnapshotProtocol` to `QueryDocumentSnapshotProtocol`.

### Changed (below-the-strict-semver-line under this library's interpretation)

These changes are protocol-declaration changes preserved at the call site via the extension layer. Manual protocol conformers (vanishingly rare) need to add the new methods; consumer call sites are unaffected.

- **`DocumentReferenceProtocol`**: replaces `setData(_:mergeOption: MergeOption, completion:)` with canonical `setData(_:completion:)` + `setData(_:merge: Bool, completion:)` + `setData(_:mergeFields: [Any], completion:)`. The `mergeOption:` form lives in `Extensions/DocumentReferenceProtocol+Idioms.swift`.
- **`WriteBatchProtocol`**, **`TransactionProtocol`**: same pattern for `setData(_:forDocument:...)`.
- **`CloudStorageReferencing.child(path:)`** renamed to canonical `child(_)` (positional). Labeled form preserved as extension.

  > ⚠️ Mock-handler rename: pre-v1.4.0 the labeled-arg overload generated `childPathHandler`; v1.4.0 generates `childHandler` for the canonical positional form. Tests that stubbed `mock.childPathHandler = ...` must migrate to `mock.childHandler = ...`. The default behavior when no handler is set is `fatalError` — silently-unstubbed call sites trap loudly.
- **`CloudFileStoring.getDownloadURL(completion:)`** renamed to canonical `downloadURL(completion:)`. Old name preserved as extension.

  > ⚠️ Mock-handler rename: pre-v1.4.0 generated `getDownloadURLHandler`; v1.4.0 generates `downloadURLHandler`. Same migration pattern.
- **`FirebaseAuthProtocol.canHandleOpenUrl(_)`** and **`canHandleRemoteNotification(_)`** renamed to canonical `canHandle(_)` and `canHandleNotification(_)`. Old names preserved as extensions.

  > ⚠️ Mock-handler renames: `canHandleOpenUrlHandler` → `canHandleHandler`; `canHandleRemoteNotificationHandler` → `canHandleNotificationHandler`.
- **Sourcery mock-handler renames** following the protocol-method renames: tests that stub mock handlers by name need to update.

  > ⚠️ **Subtle rebind risk for `setDataHandler` stubs.** Pre-v1.4.0 the only `setData` overload on `DocumentReferenceProtocol` was `setData(_:mergeOption:completion:)`, and its mock handler was `setDataHandler` with closure shape `((data, mergeOption, completion) -> Void)?`. After v1.4.0:
  > - `setDataHandler` is now bound to the new no-merge canonical `setData(_:completion:)` with closure shape `((data, completion) -> Void)?`.
  > - The merge case maps to `setDataDocumentDataMergeCompletionHandler` with shape `((data, merge, completion) -> Void)?`.
  > - The merge-fields case maps to `setDataDocumentDataMergeFieldsCompletionHandler` with shape `((data, mergeFields, completion) -> Void)?`.
  >
  > Stubs of the old 3-arg `setDataHandler` must be migrated to whichever canonical handler matches the SUT's call site. Stubs that are not migrated may fail to compile (the closure-shape change is detected) — but if a test only assigns a closure of the form `{ _, _, _ in … }` that happens to match a different overload's handler closure-shape, the rebind can be silent. Audit any pre-v1.4.0 `mock.setDataHandler = ...` stub against the new mapping.

  Same pattern applies to `WriteBatchProtocol`/`TransactionProtocol`: pre-v1.4.0 `setDataHandler` accepted `(data, document, mergeOption)`; v1.4.0 binds it to the new no-merge `setData(_:forDocument:)` with shape `(data, document)`. Merge variants map to `setDataDataForDocumentDocumentMergeHandler` and `setDataDataForDocumentDocumentMergeFieldsHandler`.

### Documentation

- **`Docs/agent/patterns.md`** — three new sections: `#two-tier-api-surface` (the codified principle: protocols 1:1 with Firebase, ergonomic forms as extensions), `#iterating-query-snapshots` (the new two-protocol structure), `#combine-layer` (when to prefer Combine variants + cancellable retention as lifecycle binding).
- **`Docs/agent/anti-patterns.md`** — new bullet under "Protocol Design": wrapper-idiomatic methods declared on the *protocol* that diverge from Firebase signatures are wrapper bugs and revert in code review.
- **`Docs/agent/coverage.md`** — `setData`, `child`, `downloadURL`, `canHandle*` rows annotated with the canonical protocol surface plus the Swift-idiomatic extension aliases. New `QueryDocumentSnapshot` row in `ModaalFirestore` table. New "When to prefer" preamble on the Combine Extension Layer section.
- **`Docs/human/getting-started.md`** — three new subsections: "Migrating from raw Firebase iOS SDK code" (the three intentional differences), "Iterating query snapshots" (the two-protocol structure), "Swift-idiomatic extensions" (canonical vs alias forms).

### Build infrastructure

- **`scripts/generate-mocks.sh`** pinned to `swift-sourcery-templates` `0.2.14` (was `0.2.13`). The 0.2.14 release adds return-type-only-overload disambiguation in the mock template — required so `QueryDocumentSnapshotProtocolMock` can expose both `data()` overloads as distinct handlers.
- **`scripts/build.sh`** gains a `SKIP_MOCK_FRESHNESS_CHECK=1` env override for local iteration when the regen produces expected diffs that haven't been committed yet (the freshness check still runs by default).

### Why

Two drivers:

1. **The library's primary promise is "protocol surface 1:1 with `firebase-ios-sdk`".** The `wikimemory-dgra0` migration surfaced several wrapper-idiomatic protocol-declaration divergences (`mergeOption:` enum instead of `merge: Bool`/`mergeFields:`, `child(path:)` instead of positional `child(_)`, `getDownloadURL` instead of `downloadURL`, `canHandleOpenUrl`/`canHandleRemoteNotification` instead of `canHandle`/`canHandleNotification`). v1.4.0 moves these to the extension layer so the protocol declarations match Firebase exactly while consumer call sites built on the wrapper-idiomatic forms continue to compile unchanged.
2. **Restoring Firebase's `QueryDocumentSnapshot : DocumentSnapshot` type-level guarantee.** The friction report flagged that iterating `snapshot.documents` required a redundant `guard let data = doc.data() else { continue }` even though query results are by definition existent. The new refining `QueryDocumentSnapshotProtocol` mirrors Firebase's class hierarchy and removes the spurious guard.

### Semver

This release contains exactly one formally-breaking change (B3's protocol return-type narrowing) plus a class of below-the-line changes (protocol-declaration changes preserved via the extension layer; Sourcery mock-handler renames following protocol method renames). Under this library's interpretation:

1. **Protocol-declaration changes that preserve call-site behavior via the extension layer are non-breaking.** Manual protocol conformers (vanishingly rare) need to add the new methods; consumer call sites are unaffected.
2. **Mock handler-closure renames following protocol-method renames are non-breaking.** The mock surface is an implementation detail of the testing layer — when a protocol method renames, its associated mock handler renames in lockstep. Tests that stub mock handlers by name need to update; tests that exercise the mock through call-site syntax don't.

This puts B3's protocol return-type narrowing as the only formally-breaking change. Single narrow break = minor bump (1.4.0). Consumers who disagree with this interpretation can pin `from: "1.3.0"`.

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
