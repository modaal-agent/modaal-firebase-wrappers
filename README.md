# ModaalFirebase

Swift protocol wrappers for the Firebase iOS SDK. Inject the protocol, mock the protocol, test the logic — without network calls, without `GoogleService-Info.plist`, without Firebase initialization.

## Why

Firebase iOS SDK is concrete-class-based — no consumer-facing Swift protocols. This makes unit testing Firebase-dependent code impossible without hitting real services. ModaalFirebase wraps every Firebase service behind Swift protocols:

```swift
// Production: inject the real wrapper
let auth: FirebaseAuthProtocol = FirebaseAuthWrapper(auth: Auth.auth())

// Unit test: inject a mock (generated or hand-written)
let auth: FirebaseAuthProtocol = FirebaseAuthProtocolMock()
```

Your app code depends on the protocol, not the concrete class. In tests, a mock provides a controllable substitute — no network, no plist, no `FirebaseApp.configure()`.

## Modules

| Module | Wraps | Protocols | Combine |
|--------|-------|-----------|---------|
| `ModaalFirebaseCore` | Bootstrap + shared types | `ModaalFirebase` class | — |
| `ModaalFirebaseAuth` | Firebase Auth | 7 protocols (Auth, User, Credential, etc.) | 14 Future + 1 stream |
| `ModaalFirebaseAnalytics` | Firebase Analytics | `FirebaseAnalyticsProtocol` | — (sync API) |
| `ModaalFirebaseCrashlytics` | Firebase Crashlytics | `FirebaseCrashlyticsProtocol` | — (sync API) |
| `ModaalFirestore` | Cloud Firestore | 12 protocols (Firestore, Document, Query, etc.) | 7 Future + 2 streams |
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

## Usage

### Completion Handlers

```swift
import ModaalFirestore

let db: FirestoreProtocol = FirestoreWrapper(firestore: Firestore.firestore())

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

let wrapper = FirestoreWrapper(firestore: Firestore.firestore())
wrapper.firestore.settings.isPersistenceEnabled = false  // escape hatch
```

## Documentation

- [Getting Started](Docs/human/getting-started.md) — Installation, bootstrap, usage examples
- [Architecture](Docs/human/architecture.md) — Why this library exists, module structure, wrapper patterns
- [Contributing](CONTRIBUTING.md) — Development rules, code style, how to add a new service

## Requirements

- iOS 15+
- Swift 5.9+
- Xcode 16+

## License

MIT — see [LICENSE](LICENSE).
