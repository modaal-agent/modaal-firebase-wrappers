# ModaalFirebase

[![CI](https://github.com/modaal-agent/modaal-firebase-wrappers/actions/workflows/ci.yml/badge.svg)](https://github.com/modaal-agent/modaal-firebase-wrappers/actions/workflows/ci.yml)

Swift protocol wrappers for the Firebase iOS SDK. Inject the protocol, mock the protocol, test the logic — without network calls, without `GoogleService-Info.plist`, without Firebase initialization.

## Why

Firebase iOS SDK is concrete-class-based — no consumer-facing Swift protocols. This makes unit testing Firebase-dependent code impossible without hitting real services. ModaalFirebase wraps every Firebase service behind Swift protocols:

```swift
import ModaalFirebaseAuth

// Production: inject the real wrapper (no `import FirebaseAuth` required)
let auth: FirebaseAuthProtocol = FirebaseAuthWrapper.makeDefault()

// Unit test: inject a mock (generated or hand-written)
let auth: FirebaseAuthProtocol = FirebaseAuthProtocolMock()
```

Your app code depends on the protocol, not the concrete class. In tests, a mock provides a controllable substitute — no network, no plist, no `FirebaseApp.configure()`.

## Modules

| Module | Wraps | Protocols | Combine |
|--------|-------|-----------|---------|
| `ModaalFirebaseCore` | Bootstrap + shared types | `ModaalFirebase` class | — |
| `ModaalFirebaseAuth` | Firebase Auth | 7 protocols (Auth, User, Credential, etc.) | 16 Future + 1 stream |
| `ModaalFirebaseAnalytics` | Firebase Analytics | `FirebaseAnalyticsProtocol` | — (sync API) |
| `ModaalFirebaseCrashlytics` | Firebase Crashlytics | `FirebaseCrashlyticsProtocol` | — (sync API) |
| `ModaalFirestore` | Cloud Firestore | 12 protocols (Firestore, Document, Query, etc.) | 9 Future + 2 streams |
| `ModaalCloudStorage` | Cloud Storage | 5 protocols + list result | 11 Future |
| `ModaalFirebaseMessaging` | Cloud Messaging | `FirebaseMessagingProtocol` | 4 Future |
| `ModaalFirebaseRemoteConfig` | Remote Config | 4 protocols (Config, Value, Listener, Update) | 3 Future + 1 stream |

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/modaal-agent/modaal-firebase-wrappers.git", from: "1.0.0"),
]
```

Then add only the products you need:

```swift
.target(
  name: "YourApp",
  dependencies: [
    .product(name: "ModaalFirebaseCore", package: "modaal-firebase-wrappers"),
    .product(name: "ModaalFirebaseAuth", package: "modaal-firebase-wrappers"),
    .product(name: "ModaalFirestore", package: "modaal-firebase-wrappers"),
  ]
)
```

**Required:** Add the `-ObjC` linker flag to your app target. See [Getting Started](Docs/human/getting-started.md) for details.

## Migrating from Firebase

If you already know Firebase, ModaalFirebase is a drop-in substitute. Every service has a **`makeDefault()`** factory (or a `configure()` variant for Core) that wraps the Firebase SDK's default instance and hands you back a protocol — so **`import Firebase*` is not required in consumer code**. Swap the constructor, rebuild, done.

| What you want | Standard Firebase | ModaalFirebase |
|---|---|---|
| Configure Firebase (plist in bundle) | `FirebaseApp.configure()` | `ModaalFirebase.shared.configure()` |
| Configure Firebase (plist at path) | `FirebaseApp.configure(options: FirebaseOptions(contentsOfFile: path)!)` | `ModaalFirebase.shared.configure(plistPath: path)` |
| Configure Firebase (in-code, no plist) | `FirebaseApp.configure(options: FirebaseOptions(googleAppID: …, gcmSenderID: …))` | `ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(googleAppID: …, gcmSenderID: …))` |
| Firestore instance | `Firestore.firestore()` | `FirestoreWrapper.makeDefault()` |
| Firestore against emulator | `Firestore.firestore().settings = { host = "localhost:8080"; isSSLEnabled = false; cacheSettings = MemoryCacheSettings() }` | `FirestoreWrapper.makeDefault(emulator: (host: "localhost", port: 8080))` |
| Auth instance | `Auth.auth()` | `FirebaseAuthWrapper.makeDefault()` |
| Auth against emulator | `Auth.auth().useEmulator(withHost: "localhost", port: 9099)` | `FirebaseAuthWrapper.makeDefault(emulator: (host: "localhost", port: 9099))` |
| Cloud Storage instance | `Storage.storage()` | `CloudStorageWrapper.makeDefault()` |
| Cloud Storage against emulator | `Storage.storage().useEmulator(host: "localhost", port: 9199)` | `CloudStorageWrapper.makeDefault(emulator: (host: "localhost", port: 9199))` |
| Analytics | `Analytics.logEvent(…)` (static methods on `Analytics`) | `FirebaseAnalyticsWrapper()` |
| Crashlytics | `Crashlytics.crashlytics()` | `let c: FirebaseCrashlyticsProtocol = .makeDefault()` (protocol-level static factory) |
| Messaging | `Messaging.messaging()` | `FirebaseMessagingWrapper.makeDefault()` |
| Remote Config | `RemoteConfig.remoteConfig()` | `FirebaseRemoteConfigWrapper.makeDefault()` |

Every wrapper hands back a protocol (`FirestoreProtocol` / `FirebaseAuthProtocol` / `FirebaseMessagingProtocol` / …) that mirrors the Firebase SDK's surface 1:1 — collection / document / query / batch / transaction / snapshot listener / … are all there.

> **Why is Crashlytics different?** `Crashlytics` from the Firebase SDK conforms to `FirebaseCrashlyticsProtocol` directly (no wrapper class), so the factory lives on the protocol itself. Swift's protocol-static lookup requires an expected-type context, which is why the call reads `let c: FirebaseCrashlyticsProtocol = .makeDefault()` — the implicit-member form the compiler can dispatch.
>
> **Why no `makeDefault(emulator:)` on Messaging / Remote Config?** The Firebase Emulator Suite doesn't cover these services. Their `makeDefault()` wraps the default SDK instance; for local testing of Remote Config use `setDefaults(_:)`.
>
> **Need a non-default instance?** (custom `FirebaseApp`, a pre-configured instance, etc.) Construct via the wrapper's public `init(...)` directly — e.g. `FirestoreWrapper(firestore: Firestore.firestore(app: secondaryApp))`. That's the one path that still requires `import FirebaseFirestore` on an otherwise-fully-wrapped service.

## Usage

### Completion Handlers

```swift
import ModaalFirestore

let db: FirestoreProtocol = FirestoreWrapper.makeDefault()

db.collection("users").document("alice").getDocument { result in
  switch result {
  case .success(let snapshot):
    print("Name: \(snapshot.get("name") ?? "unknown")")
  case .failure(let error):
    print("Error: \(error)")
  }
}
```

### Combine

Every async method has a Combine extension returning `Future<T, Error>`:

```swift
import Combine

db.collection("users").document("alice").getDocument()
  .sink(
    receiveCompletion: { _ in },
    receiveValue: { snapshot in
      print("Name: \(snapshot.get("name") ?? "unknown")")
    }
  )
  .store(in: &cancellables)
```

Streaming publishers for real-time data:

```swift
db.collection("users")
  .snapshotPublisher()
  .sink(
    receiveCompletion: { _ in },
    receiveValue: { snapshot in
      for change in snapshot.documentChanges {
        print("\(change.type): \(change.document.documentID)")
      }
    }
  )
  .store(in: &cancellables)
```

### Escape Hatches

Every entry-point wrapper exposes the underlying Firebase type for APIs not yet wrapped:

```swift
import FirebaseFirestore  // explicit opt-in

let wrapper = FirestoreWrapper.makeDefault()
wrapper.firestore.settings.isPersistenceEnabled = false  // escape hatch
```

### Firebase Emulator

`FirestoreWrapper`, `FirebaseAuthWrapper`, and `CloudStorageWrapper` each expose a `makeDefault(emulator:)` factory that wraps the default SDK instance and points it at a local emulator — no `import Firebase*` required in your app. Combined with in-code configuration (`ModaalFirebase.configure(options:)` + `ModaalFirebaseOptions`), a full emulator-backed bootstrap fits in a handful of lines. See [Emulator setup](Docs/human/emulator-setup.md).

## Documentation

- [Getting Started](Docs/human/getting-started.md) — Installation, bootstrap, usage examples
- [Emulator Setup](Docs/human/emulator-setup.md) — Running against the Firebase Emulator Suite
- [Architecture](Docs/human/architecture.md) — Why this library exists, module structure, wrapper patterns
- [Contributing](CONTRIBUTING.md) — Development rules, code style, how to add a new service

## Requirements

- iOS 15+
- Swift 5.9+
- Xcode 26.0+

> **Note:** This library depends on [firebase-ios-sdk-xcframeworks](https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks) (pre-built binaries) for faster build times. These binaries are built with Xcode 26.x and cannot be linked with Xcode 16.x. The Firebase source SDK supports Xcode 16+, but switching to it requires forking this library (see [wrapper plan §3.4](https://github.com/modaal-agent/modaal-agent/blob/main/specs/066-integrations-firebase/firebase-shared-wrapper-plan.md)).

## Version Support

**Supported Firebase SDK versions:** 12.x (12.12.0+)

**Version tracking policy:** ModaalFirebase tracks the latest Firebase major version. When Firebase ships a new major version (e.g., 13.0), we release a corresponding major version of ModaalFirebase within 4 weeks. The previous Firebase major version receives critical bug fixes on a maintenance branch for 6 months after the new major version ships.

**Minor/patch versions:** `Package.swift` uses `.upToNextMajor(from: "12.12.0")` for the Firebase SDK dependency. Consumers are free to resolve to any Firebase 12.x version within that range.

## License

MIT — see [LICENSE](LICENSE).
