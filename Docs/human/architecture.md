# Architecture

## Why This Library Exists

Firebase iOS SDK is concrete-class-based — it ships no consumer-facing Swift protocols. This makes unit testing Firebase-dependent code impossible without hitting real Firebase services, requiring a `GoogleService-Info.plist`, or using fragile method-swizzling hacks.

ModaalFirebase wraps every Firebase service behind Swift protocols. Your app code depends on the protocol (e.g., `FirestoreProtocol`), not the concrete `Firestore` class:

```swift
import ModaalFirestore

// Production: inject the real wrapper (no `import FirebaseFirestore` required)
let db: FirestoreProtocol = FirestoreWrapper.makeDefault()
viewModel.configure(firestore: db)

// Unit test: inject a mock
let mock = FirestoreProtocolMock()
mock.collectionHandler = { _ in mockCollectionRef }
viewModel.configure(firestore: mock)
// Assert viewModel behavior without network calls or Firebase initialization
```

This is the standard **dependency-inversion pattern** applied to Firebase: **inject the protocol, mock the protocol, test the logic.**

### Benefits

1. **Unit-testable Firebase code.** Mock any Firebase service via generated mocks (Sourcery, @Mockable, or hand-written). No network, no plist, no `FirebaseApp.configure()` in tests.

2. **No raw Firebase imports in app code.** Consumer modules import `ModaalFirestore`, not `FirebaseFirestore`. This compile-time boundary guarantees no raw Firebase types leak into your architecture.

3. **SDK version isolation.** When Firebase ships a breaking API change, only the wrapper layer needs updating — app code stays untouched.

4. **Combine API for free.** Protocol extensions provide `Future<T, Error>` for one-shot operations and `AnyPublisher` for streaming, compatible with Firebase's own (now-removed) `FirebaseCombineSwift` API.

5. **Escape hatches for the long tail.** Every entry-point wrapper exposes the underlying Firebase type. New SDK features are accessible immediately — no need to wait for a wrapper update.

## What you import

One module per Firebase service. Pull in only the ones your app uses:

| Module | Wraps | Entry point |
|---|---|---|
| `ModaalFirebaseCore` | Bootstrap (`FirebaseApp.configure`) | `ModaalFirebase.shared.configure()` |
| `ModaalFirebaseAuth` | Firebase Auth | `FirebaseAuthWrapper.makeDefault()` |
| `ModaalFirebaseAnalytics` | Firebase Analytics | `FirebaseAnalyticsWrapper()` |
| `ModaalFirebaseCrashlytics` | Firebase Crashlytics | `let c: FirebaseCrashlyticsProtocol = .makeDefault()` |
| `ModaalFirestore` | Cloud Firestore | `FirestoreWrapper.makeDefault()` |
| `ModaalCloudStorage` | Cloud Storage | `CloudStorageWrapper.makeDefault()` |
| `ModaalFirebaseMessaging` | Cloud Messaging | `FirebaseMessagingWrapper.makeDefault()` |
| `ModaalFirebaseRemoteConfig` | Remote Config | `FirebaseRemoteConfigWrapper.makeDefault()` |

Each module ships:

- **Protocols** — the public API your app code depends on (`FirestoreProtocol`, `DocumentReferenceProtocol`, etc.). 1:1 with the Firebase iOS SDK class hierarchy modulo two safety carve-outs (`Result<…, Error>` completion shape; required `completion:` handler).
- **Wrappers** — concrete implementations that bridge to the Firebase SDK. Entry-point wrappers (`FirestoreWrapper`, `FirebaseAuthWrapper`, …) are `public` and ship a `makeDefault()` factory. Sub-wrappers (`DocumentReferenceWrapper`, `QueryWrapper`, …) are internal — you never instantiate them.
- **Combine extensions** — protocol default implementations providing `Future<T, Error>` for one-shot operations and `AnyPublisher<T, Error>` for streaming. Work with both real wrappers and mocks. See [`Docs/agent/patterns.md` § Combine layer](../agent/patterns.md#combine-layer).
- **Swift-idiomatic extensions** — protocol extensions adding ergonomic aliases over the canonical Firebase signatures (`mergeOption: MergeOption`, `child(path:)`, `getDownloadURL`, `canHandleOpenUrl`). Both forms work at the call site; mocks reflect the canonical layer only. See [`Docs/agent/patterns.md` § Two-tier API surface](../agent/patterns.md#two-tier-api-surface).
- **Mirrored enums** — Firebase-specific enum types re-shaped as Modaal types (`FirestoreSource`, `DocumentChangeType`, `ModaalRemoteConfigFetchStatus`, …) so you don't need `import Firebase*` to reference them.

## Wrapper construction

The standard form across every service:

```swift
let firestore: FirestoreProtocol     = FirestoreWrapper.makeDefault()
let auth:      FirebaseAuthProtocol  = FirebaseAuthWrapper.makeDefault()
let storage:   CloudStorageProtocol  = CloudStorageWrapper.makeDefault()

// Crashlytics uses direct extension conformance — implicit-member syntax with an explicit type:
let crashlytics: FirebaseCrashlyticsProtocol = .makeDefault()
```

Services with a Firebase Emulator (Firestore, Auth, Cloud Storage) take an optional `emulator: (host: String, port: Int)?` overload — see [Emulator Setup](emulator-setup.md).

## Combine layer

| Operation type | Return type | Example |
|---|---|---|
| One-shot (single result) | `Future<T, Error>` | `auth.signInAnonymously()` |
| State stream (never fails) | `AnyPublisher<T, Never>` | `auth.authStateDidChangePublisher()` |
| Data stream (can fail) | `AnyPublisher<T, Error>` | `docRef.snapshotPublisher()` |

`Future` is **eager** — the operation starts immediately when the `Future` is created, not when subscribed. Matches Firebase's own (now-removed) `FirebaseCombineSwift` behavior.

Streaming publishers are **lazy** — the listener is added on subscription. **Cancellable retention is the lifecycle binding** — storing the `AnyCancellable` keeps the subscription alive; dropping it cancels and tears down the underlying listener. This is intentional and forces you to bind the listener to a parent's lifecycle (worker, view model, builder).

## Firebase SDK dependency

ModaalFirebase depends on [`akaffenberger/firebase-ios-sdk-xcframeworks`](https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks) — pre-built binary xcframeworks. This avoids compiling the Firebase SDK from source (which adds significant build time).

**Do not add a separate dependency on `firebase-ios-sdk` or `firebase-ios-sdk-xcframeworks` to your app's `Package.swift`** — ModaalFirebase pulls in the xcframeworks transitively at the version it was built against, and a second direct pin causes duplicate-XCFramework link errors when the two diverge. If you need an unwrapped Firebase API, use the escape hatch on the relevant entry-point wrapper (e.g., `firestoreWrapper.firestore`) and `import Firebase*` only at that single call site.
