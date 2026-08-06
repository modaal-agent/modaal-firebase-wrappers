# Changelog

## [Unreleased]

### Changed — generated mocks are `final`

- **`scripts/generate-mocks.sh` re-pinned to `swift-sourcery-templates` 0.2.15** (from 0.2.14) and mocks regenerated. The entire diff across the 34 generated mocks is `class XMock` → `final class XMock` — 34 lines, no other change — because none of this package's protocols use the constructs 0.2.15 adds ([its CHANGELOG](https://github.com/ivanmisuno/swift-sourcery-templates/blob/master/CHANGELOG.md#0215--2026-08-06): `async` and actor-isolation preservation, Combine `AnyPublisher` subjects, `@Sendable` closure parameters, `@unchecked Sendable` on `Sendable`-refining protocols).
- **Breaking for anyone subclassing a generated mock** — `final` forbids it. Set the mock's `<method>Handler` closure instead, which is the supported way to control behaviour. No call site in this repo subclasses one.
- **Fixed the mock count printed by `scripts/generate-mocks.sh`.** It matched `^class .*Mock`, which stopped matching once mocks became `final`, so every module reported `0 mocks` while generating correctly. It now matches both forms.

Verified with a library-target build, a SampleApp build, and the package test suite on the regenerated mocks.

## [2.1.0] — 2026-05-18

### Added — ModaalCloudStorage: determinate-progress, cancellable, pause/resume-able uploads

- `CloudFileStoring` gains four progress-aware upload overloads — `putData(_:events:completion:)`, `putData(_:metadata:events:completion:)`, `uploadFromFile(localURL:events:completion:)`, `uploadFromFile(localURL:metadata:events:completion:)` — that report determinate progress via an `events:` callback and return a `CloudStorageUploadTaskProtocol` handle exposing `cancel()`, `pause()`, and `resume()`. The existing fire-and-forget overloads remain for the common case.
- `CloudStorageUploadTaskProtocol` — opaque task handle. `pause()` and `resume()` ship with default no-op implementations on a protocol extension so external conformers that only implement `cancel()` remain source-compatible.
- `CloudStorageUploadEvent` enum carries `.progress(bytesTransferred:totalBytes:)`, `.paused`, and `.resumed` events. **Non-frozen** — switches over this enum MUST use `@unknown default` to remain source-compatible with future versions.
- Combine projections: `putDataWithProgress(_:)` / `putDataWithProgress(_:metadata:)` / `uploadFromFileWithProgress(localURL:)` / `uploadFromFileWithProgress(localURL:metadata:)` return `AnyPublisher<CloudStorageUploadEvent, Error>` emitting events and finishing on success. Cancelling the subscription cancels the underlying upload (no terminal event delivered on cancel — canonical Combine semantic).
- Pause/resume is **programmatic only** — it does not survive app suspension. For uploads that need to survive app suspension, drop down to the underlying `StorageUploadTask` via `CloudStorageReference.reference` and drive the GCS resumable upload protocol from your own `URLSession`.

### Documentation

- **New [`Docs/agent/patterns.md` § "Consuming the upload-progress publisher"](Docs/agent/patterns.md#consuming-upload-progress)** — canonical 8-line consumer pipeline (`compactMap → removeDuplicates → handleEvents → reduce((), { _, _ in () })`), with operator-by-operator rationale, the no-payload-on-completion design (URL shape is consumer policy), and the test-side stub-emit-then-complete mock pattern.
- **Doc-comment coverage** on the new public surface for threading semantics (`Storage.callbackQueue`, default `DispatchQueue.main`), the single-subscription contract on `…WithProgress(…)` publishers (each subscription starts a new upload; re-subscribing leaks the first), event cadence (high-frequency; quantize before driving UI, avoid time-based `.throttle(...)` for testability), and `cancel()` ordering (a `.progress` tick already enqueued on `callbackQueue` may still fire before `completion(.failure(...))`; UI teardown should be idempotent).
- Distilled from pre-release feedback on the first beta-consumer integration; see [`specs/003-determinate-upload-progress`](specs/003-determinate-upload-progress/determinate-upload-progress-spec.md) § "Polish round" for the per-item evaluation.

## [2.0.0] — 2026-05-10

### Changed (formally breaking — see Semver below)

- **Switched from `firebase-ios-sdk-xcframeworks` (binary mirror) to upstream `firebase/firebase-ios-sdk` (source).** [Package.swift](Package.swift) now depends on `https://github.com/firebase/firebase-ios-sdk.git` `from: "12.13.0"`. The old `https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks.git` dep is gone. The upstream SDK is a hybrid: heavy components (gRPC, FirebaseFirestoreInternal, FirebaseAnalytics, GoogleAppMeasurement, abseil) ship as `.binaryTarget` xcframeworks via Google's CDN; the Swift wrapper layers compile from source.

- **`ModaalFirebaseCore` depends on `FirebaseCore` directly.** Pre-2.0 the xcframeworks mirror didn't expose `FirebaseCore` as a standalone product, so `ModaalFirebaseCore` depended on `FirebaseAnalytics` to inherit `_FirebaseCore` transitively. Source SDK exposes `FirebaseCore` as a first-class library product, so the workaround is gone. As a knock-on, `ModaalFirebaseAnalytics` now declares its `FirebaseAnalytics` dependency explicitly (it had been inheriting it through the old Core workaround).

### Removed

- The `FirebaseCore`-via-`FirebaseAnalytics` workaround on `ModaalFirebaseCore`, plus the comment block in [Package.swift](Package.swift) explaining it.
- The "switching to the source SDK requires forking this library" note from [README.md](README.md) — that's exactly what 2.0.0 does. Replaced with a brief note on the source SDK's hybrid binary/source distribution and the SwiftPM cache step.

### Build infrastructure

- **SwiftPM artifact cache** added to both [`.github/workflows/ci.yml`](.github/workflows/ci.yml) and [`.github/workflows/integration-tests.yml`](.github/workflows/integration-tests.yml). Caches `.build/SourcePackages` and `.build/DerivedData` keyed on `Package.swift` content + Xcode major.minor. `restore-keys` fallback lets a `Package.swift` edit partial-restore from the most-recent compatible cache rather than cold-rebuild. Local-arm warm builds land at 105s — well under the 156s migration gate even before factoring in CI cache hits.

### Documentation

- **Doc sweep across 11 files** ([CONTRIBUTING.md](CONTRIBUTING.md), [README.md](README.md), [Docs/human/architecture.md](Docs/human/architecture.md), [Docs/human/emulator-setup.md](Docs/human/emulator-setup.md), [Docs/human/getting-started.md](Docs/human/getting-started.md), [Docs/agent/anti-patterns.md](Docs/agent/anti-patterns.md), [Docs/agent/coverage.md](Docs/agent/coverage.md), [Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml](Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml), [Tests/EmulatorTests/README.md](Tests/EmulatorTests/README.md), [Tests/EmulatorTests/xcodegen.yml](Tests/EmulatorTests/xcodegen.yml), [Sources/ModaalFirebaseCrashlytics/Protocols/FirebaseCrashlyticsProtocol.swift](Sources/ModaalFirebaseCrashlytics/Protocols/FirebaseCrashlyticsProtocol.swift)) for xcframeworks-specific framing.
- **Inverted rule in [CONTRIBUTING.md § Dependencies](CONTRIBUTING.md):** "Never depend on `FirebaseCore` directly" → "`ModaalFirebaseCore` depends on `FirebaseCore` directly. Other modules pull `FirebaseCore` transitively through `ModaalFirebaseCore`." This is the inverse of the v1.x rule, because the source SDK's product surface inverts the constraint.
- **Crashlytics post-build script path updated** in [Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml](Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml): `SourcePackages/checkouts/firebase-ios-sdk-xcframeworks/FirebaseCrashlytics/run` → `SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run`. Consumers using this snippet must update their xcodegen specs.
- **GoogleSignIn coverage gap reframed** in [Docs/agent/coverage.md](Docs/agent/coverage.md): upstream `firebase-ios-sdk` does not re-export `GoogleSignIn` (the xcframeworks mirror did). Consumers add `https://github.com/google/GoogleSignIn-iOS` as a separate SwiftPM dependency until a `ModaalGoogleSignIn` module ships.
- **Anti-patterns rule reworded** in [Docs/agent/anti-patterns.md](Docs/agent/anti-patterns.md): the failure mode for adding a parallel direct `firebase-ios-sdk` pin is now SwiftPM's "multiple similar targets in package X and Y" resolution error, not duplicate-XCFramework link errors. Rule unchanged.

### Migration guide

For app authors:
1. **No source-code changes are required.** The `Modaal*` protocol surface, factory methods, Combine extensions, and mocks are byte-identical to v1.4.x.
2. **Bump the dependency:** `from: "1.0.0"` → `from: "2.0.0"` in your `Package.swift`.
3. **Resolve the new SwiftPM graph.** First build downloads `firebase-ios-sdk` source + binary artifacts (1.2 GB SourcePackages, 2.3 GB DerivedData on a successful build). The Swift wrapper layers compile from source — first build ~50% slower than v1.4.x; subsequent warm builds match v1.4.x.
4. **If you used the [Crashlytics post-build snippet](Docs/consumers/xcodegen-snippets/crashlytics-post-build-script.yml):** update the path from `firebase-ios-sdk-xcframeworks/FirebaseCrashlytics/run` to `firebase-ios-sdk/Crashlytics/run`.
5. **If you used GoogleSignIn through the xcframeworks re-export:** add `https://github.com/google/GoogleSignIn-iOS` as a direct SwiftPM dependency.
6. **CI users:** consider adding the [`actions/cache@v4` step](.github/workflows/ci.yml) to your workflow — keyed on `Package.swift` content + Xcode major.minor — to avoid paying the source-SDK first-build cost on every PR.
7. **iOS deployment target stays at 15.** No change required.

For library contributors:
- The "never depend on `FirebaseCore` directly" rule **inverts** — see [CONTRIBUTING.md](CONTRIBUTING.md). Wrapper modules should depend on the specific Firebase product they wrap (e.g. `FirebaseAuth` on `ModaalFirebaseAuth`); they get `FirebaseCore` transitively through `ModaalFirebaseCore`.

### Why

Phase 0 of the [SQL Connect spike](specs/001-sql-connect/sql-connect-spike-plan.md) demonstrated that the xcframeworks flavour cannot coexist with `firebase/data-connect-ios-sdk` in one SwiftPM dependency graph: SwiftPM rejects the resolution with "multiple similar targets 'Firebase', 'FirebaseAnalyticsTarget', … appear in package 'firebase-ios-sdk-xcframeworks' and 'firebase-ios-sdk'" because the xcframeworks mirror redeclares the same target names as upstream, and `data-connect-ios-sdk` transitively pulls upstream in. Standard SPM workarounds (`mirrors`, `moduleAliases`, version pinning) don't help — the collision is structural. See [Examples/SQLConnectSpike/FINDINGS.md](Examples/SQLConnectSpike/FINDINGS.md) for the full failure-mode analysis. The v2.0.0 source-SDK migration unblocks SQL Connect (and any future Firebase product whose iOS SDK lives in a separate repo with independent versioning).

The full migration plan is at [specs/002-source-sdk-migration/migration-plan.md](specs/002-source-sdk-migration/migration-plan.md); build-time numbers (cold/warm under v1.x and v2.0.0) at [specs/002-source-sdk-migration/build-time-baseline.md](specs/002-source-sdk-migration/build-time-baseline.md).

### Semver

Why a major: consumers' SwiftPM resolution graph changes — a different `Package.swift` URL, a different binary footprint (smaller SourcePackages, larger DerivedData), and a non-trivial first-build time delta. Even though the public API is identical to 1.4.x, the dependency-graph change is severe enough to warrant signalling explicit consent via a major bump. Consumers who disagree can pin `from: "1.4.0"` (the v1.4.x maintenance branch ships from `main`'s last v1 commit; see version-tracking policy in [README.md](README.md)).

## [1.4.1] — 2026-04-27

### Changed

- **`Docs/agent/*.md` and `Docs/human/*.md` reoriented to consumer focus.** Both documentation trees now exclusively cover *consuming* the library; library-implementation patterns, library-side anti-patterns, and the step-by-step guide for adding a new wrapper move to `CONTRIBUTING.md`.
- **`Docs/agent/adding-a-wrapper.md` deleted** — content fully absorbed into `CONTRIBUTING.md § Adding a New Firebase Service Wrapper`.
- **Deprecated direct-init pattern for default instances** — `FirestoreWrapper(firestore: Firestore.firestore())` (and equivalents for Auth / Cloud Storage / Messaging / Remote Config) is now formally deprecated in the docs; use `Wrapper.makeDefault()` / `Wrapper.makeDefault(emulator:)` instead. The direct `init(...)` form remains `public` and documented as the escape hatch for non-default `FirebaseApp` instances only. Surfaced as an explicit antipattern in `Docs/agent/anti-patterns.md § Construction`.

No source/protocol/mock changes. Patch bump.

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
