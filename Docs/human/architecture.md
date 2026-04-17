# Architecture

## Why This Library Exists

Firebase iOS SDK is concrete-class-based — it ships no consumer-facing Swift protocols. This makes unit testing Firebase-dependent code impossible without hitting real Firebase services, requiring a `GoogleService-Info.plist`, or using fragile method-swizzling hacks.

ModaalFirebase wraps every Firebase service behind Swift protocols. Your app code depends on the protocol (e.g., `FirestoreProtocol`), not the concrete `Firestore` class:

```swift
// Production: inject the real wrapper
let db: FirestoreProtocol = FirestoreWrapper(firestore: Firestore.firestore())
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

## Module Structure

Each module follows the same structure:

```
Sources/Modaal<Service>/
├── Protocols/          # Swift protocols (the public API contract)
├── Combine/            # Combine extensions on protocols (Future, AnyPublisher)
├── Wrappers/           # Concrete implementations bridging to Firebase SDK
└── Types/              # Mirrored enums and value types (optional)
```

- **Protocols** define the API surface. No Firebase imports, no Combine imports. These are what consumers depend on and what mocks implement.
- **Combine** extensions are default implementations on the protocols. They work with any conformer — wrappers and mocks alike.
- **Wrappers** import Firebase and implement the protocols by forwarding to the SDK. Entry-point wrappers are `public`; sub-wrappers are `internal`.
- **Types** mirror Firebase-specific enums (e.g., `FirestoreSource`, `DocumentChangeType`) so consumers don't need `import Firebase*`.

## Wrapper Patterns

### Wrapper Class (most services)

```
FirebaseAuthProtocol  ←  FirebaseAuthWrapper  →  Auth (Firebase SDK)
```

The wrapper class holds a reference to the Firebase object and forwards every protocol method. The entry-point wrapper's `init` is `public`; consumers create it once and inject it.

### Direct Extension Conformance (Crashlytics)

```
FirebaseCrashlyticsProtocol  ←  extension Crashlytics: FirebaseCrashlyticsProtocol {}
```

When the Firebase class already satisfies the protocol requirements, no wrapper class is needed. The consumer works with `Crashlytics.crashlytics()` directly, typed as `FirebaseCrashlyticsProtocol`.

### Protocol Inheritance (Firestore)

```
CollectionReferenceProtocol: QueryProtocol
CollectionReferenceWrapper: QueryWrapper
```

When the Firebase SDK uses class inheritance (e.g., `CollectionReference: Query`), the wrapper mirrors this with both protocol inheritance and class inheritance.

## Combine Layer

The Combine extensions follow Firebase's own `FirebaseCombineSwift` conventions:

| Operation type | Return type | Example |
|---------------|-------------|---------|
| One-shot (single result) | `Future<T, Error>` | `auth.signInAnonymously()` |
| State stream (never fails) | `AnyPublisher<T, Never>` | `auth.authStateDidChangePublisher()` |
| Data stream (can fail) | `AnyPublisher<T, Error>` | `docRef.snapshotPublisher()` |

`Future` is **eager** — the operation starts immediately when the `Future` is created, not when subscribed. This matches Firebase's behavior and `FirebaseCombineSwift`'s design.

Streaming publishers are **lazy** — the listener is added on subscription and removed on cancellation.

## Firebase SDK Dependency

This library uses [`akaffenberger/firebase-ios-sdk-xcframeworks`](https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks) — pre-built binary xcframeworks. This avoids compiling the Firebase SDK from source (which adds significant build time).

The SPM package identity is `firebase-ios-sdk-xcframeworks` (URL-derived). The package's internal `name: "Firebase"` does NOT work as the `package:` argument in SPM 5.9.

`ModaalFirebaseCore` depends on `FirebaseAnalytics` because `_FirebaseCore` is an internal binary target in the xcframeworks package — not exposed as a standalone product. `FirebaseAnalytics` is the only product that provides it.
