# Getting Started

## Installation

Add ModaalFirebase to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/modaal-agent/modaal-firebase-wrappers.git", from: "1.0.0"),
]
```

Then add the products you need:

```swift
.target(
  name: "YourApp",
  dependencies: [
    .product(name: "ModaalFirebaseCore", package: "modaal-firebase-wrappers"),
    .product(name: "ModaalFirebaseAuth", package: "modaal-firebase-wrappers"),
    .product(name: "ModaalFirestore", package: "modaal-firebase-wrappers"),
    // Add only the services you use
  ]
)
```

### XcodeGen

If you use XcodeGen, add the package and per-service products:

```yaml
packages:
  ModaalFirebase:
    url: https://github.com/modaal-agent/modaal-firebase-wrappers.git
    from: 1.0.0

targets:
  YourApp:
    dependencies:
      - package: ModaalFirebase
        product: ModaalFirebaseCore
      - package: ModaalFirebase
        product: ModaalFirebaseAuth
      - package: ModaalFirebase
        product: ModaalFirestore
```

### Required: `-ObjC` Linker Flag

The underlying Firebase xcframeworks package requires the `-ObjC` linker flag for Objective-C category loading. Add it to your **app target** (not the library):

**Package.swift:**
```swift
.target(
  name: "YourApp",
  linkerSettings: [.unsafeFlags(["-ObjC"])]
)
```

**XcodeGen:**
```yaml
settings:
  base:
    OTHER_LDFLAGS: ["-ObjC"]
```

## Migrating from Firebase

Already using the Firebase SDK? Every service has a **`makeDefault()`** factory (or a `configure()` variant for Core) that wraps the SDK's default instance and hands you back a protocol — **`import Firebase*` is not required in consumer code**. Swap the constructor, rebuild, done.

| What you want | Standard Firebase | ModaalFirebase |
|---|---|---|
| Configure (plist in bundle) | `FirebaseApp.configure()` | `ModaalFirebase.shared.configure()` |
| Configure (plist at path) | `FirebaseApp.configure(options: FirebaseOptions(contentsOfFile: path)!)` | `ModaalFirebase.shared.configure(plistPath: path)` |
| Configure (in-code, no plist) | `FirebaseApp.configure(options: FirebaseOptions(googleAppID: …, gcmSenderID: …))` | `ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(googleAppID: …, gcmSenderID: …))` |
| Firestore | `Firestore.firestore()` | `FirestoreWrapper.makeDefault()` |
| Firestore (emulator) | Set `Firestore.firestore().settings = …` with host / SSL / cache | `FirestoreWrapper.makeDefault(emulator: (host: "localhost", port: 8080))` |
| Auth | `Auth.auth()` | `FirebaseAuthWrapper.makeDefault()` |
| Auth (emulator) | `Auth.auth().useEmulator(withHost: "localhost", port: 9099)` | `FirebaseAuthWrapper.makeDefault(emulator: (host: "localhost", port: 9099))` |
| Cloud Storage | `Storage.storage()` | `CloudStorageWrapper.makeDefault()` |
| Cloud Storage (emulator) | `Storage.storage().useEmulator(host: "localhost", port: 9199)` | `CloudStorageWrapper.makeDefault(emulator: (host: "localhost", port: 9199))` |
| Analytics | `Analytics.logEvent(…)` (static methods) | `FirebaseAnalyticsWrapper()` |
| Crashlytics | `Crashlytics.crashlytics()` | `let c: FirebaseCrashlyticsProtocol = .makeDefault()` (protocol-level static factory) |
| Messaging | `Messaging.messaging()` | `FirebaseMessagingWrapper.makeDefault()` |
| Remote Config | `RemoteConfig.remoteConfig()` | `FirebaseRemoteConfigWrapper.makeDefault()` |
| Apple Sign-In credential | `OAuthProvider.appleCredential(withIDToken: …, rawNonce: …, fullName: …)` | `let c: FirebaseAuthCredentialProtocol = .apple(idToken: …, rawNonce: …, fullName: …)` (protocol-level static factory, implicit-member syntax) |
| Google Sign-In credential | `GoogleAuthProvider.credential(withIDToken: …, accessToken: …)` | `let c: FirebaseAuthCredentialProtocol = .google(idToken: …, accessToken: …)` |
| OIDC / generic OAuth credential (Microsoft, Yahoo, custom OIDC) | `OAuthProvider.credential(providerID: .custom("oidc.my-provider"), idToken: …, rawNonce: …, accessToken: …)` | Escape hatch — `import FirebaseAuth` at the credential-construction call site only; not yet wrapped (would need a `ModaalAuthProviderID` enum). |
| Firestore `Timestamp` (write payload) | `Timestamp(date: …)` (requires `import FirebaseFirestore`) | `Timestamp(date: …)` (re-exported under `import ModaalFirestore`) |
| Firestore `FieldValue` (write helpers) | `FieldValue.serverTimestamp() / .delete() / .arrayUnion(_:) / .arrayRemove(_:) / .increment(_:)` (requires `import FirebaseFirestore`) | Same — `FieldValue` re-exported under `import ModaalFirestore` |
| Custom instance (e.g. secondary `FirebaseApp`) | `Firestore.firestore(app: secondaryApp)` | `FirestoreWrapper(firestore: Firestore.firestore(app: secondaryApp))` (requires `import FirebaseFirestore`) |

Notes:

- **Crashlytics** uses direct extension conformance on the Firebase SDK type (no wrapper class), so the factory lives on `FirebaseCrashlyticsProtocol`. Swift's protocol-static dispatch requires an expected-type context — call it via implicit-member syntax: `let c: FirebaseCrashlyticsProtocol = .makeDefault()`.
- **Messaging / Remote Config** have no `makeDefault(emulator:)` overload — the Firebase Emulator Suite doesn't cover them. For local Remote Config testing use `setDefaults(_:)` on the protocol.
- **Non-default instance** (custom `FirebaseApp`, a pre-configured service handle, etc.): use the wrapper's public `init(...)` directly — that path requires `import Firebase*` for the SDK type name, but only at the composition root.

## Bootstrap

Three ways to configure Firebase, all via `ModaalFirebase.shared` — no `import FirebaseCore` needed in your app:

```swift
import ModaalFirebaseCore

@main
struct MyApp: App {
  init() {
    // 1. Default: reads `GoogleService-Info.plist` from the main bundle.
    ModaalFirebase.shared.configure()

    // 2. Custom plist path:
    //    ModaalFirebase.shared.configure(plistPath: "/path/to/GoogleService-Info.plist")

    // 3. In-code options (no plist — useful for demos + emulator / test harnesses):
    //    ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(
    //      googleAppID: "1:1234567890:ios:…",
    //      gcmSenderID: "1234567890",
    //      projectID: "demo-project",
    //      storageBucket: "demo-project.appspot.com"
    //    ))
  }
  // ...
}
```

For running against the local Firebase Emulator Suite, see [Emulator Setup](emulator-setup.md).

## Usage

### Completion Handlers

Every wrapped method uses completion handlers with `Result<T, Error>`:

```swift
import ModaalFirebaseAuth

// Wraps `Auth.auth()` — no `import FirebaseAuth` needed in your app.
let auth: FirebaseAuthProtocol = FirebaseAuthWrapper.makeDefault()

auth.signIn(withEmail: "user@example.com", password: "password") { result in
  switch result {
  case .success(let data):
    print("Signed in as \(data.user.uid)")
  case .failure(let error):
    print("Error: \(error.localizedDescription)")
  }
}
```

### Combine

Every completion-handler method has a Combine extension returning `Future<T, Error>`:

```swift
import Combine
import ModaalFirebaseAuth

auth.signIn(withEmail: "user@example.com", password: "password")
  .sink(
    receiveCompletion: { completion in
      if case .failure(let error) = completion {
        print("Error: \(error)")
      }
    },
    receiveValue: { data in
      print("Signed in as \(data.user.uid)")
    }
  )
  .store(in: &cancellables)
```

Streaming publishers are available for real-time data:

```swift
// Auth state changes
auth.authStateDidChangePublisher()
  .sink { user in
    if let user {
      print("User signed in: \(user.uid)")
    } else {
      print("User signed out")
    }
  }
  .store(in: &cancellables)

// Firestore document listener
docRef.snapshotPublisher(includeMetadataChanges: true)
  .sink(
    receiveCompletion: { _ in },
    receiveValue: { snapshot in
      print("Document data: \(snapshot.data() ?? [:])")
    }
  )
  .store(in: &cancellables)
```

### Escape Hatches

Every entry-point wrapper exposes the underlying Firebase type as a `public` property. Use this for APIs not yet covered by the wrapper:

```swift
import FirebaseFirestore  // explicit opt-in to raw Firebase types
import ModaalFirestore

let wrapper = FirestoreWrapper.makeDefault()

// Wrapped API (no Firebase import needed)
wrapper.collection("users").document("alice").getDocument { ... }

// Escape hatch for unwrapped API
wrapper.firestore.settings.isPersistenceEnabled = false
wrapper.firestore.clearPersistence { error in ... }
```

## Available Modules

| Module | Import | Entry Point |
|--------|--------|-------------|
| `ModaalFirebaseCore` | `import ModaalFirebaseCore` | `ModaalFirebase.shared` |
| `ModaalFirebaseAuth` | `import ModaalFirebaseAuth` | `FirebaseAuthWrapper.makeDefault()` |
| `ModaalFirebaseAnalytics` | `import ModaalFirebaseAnalytics` | `FirebaseAnalyticsWrapper()` |
| `ModaalFirebaseCrashlytics` | `import ModaalFirebaseCrashlytics` | `let c: FirebaseCrashlyticsProtocol = .makeDefault()` (protocol-level factory, implicit-member syntax) |
| `ModaalFirestore` | `import ModaalFirestore` | `FirestoreWrapper.makeDefault()` |
| `ModaalCloudStorage` | `import ModaalCloudStorage` | `CloudStorageWrapper.makeDefault()` |
| `ModaalFirebaseMessaging` | `import ModaalFirebaseMessaging` | `FirebaseMessagingWrapper.makeDefault()` |
| `ModaalFirebaseRemoteConfig` | `import ModaalFirebaseRemoteConfig` | `FirebaseRemoteConfigWrapper.makeDefault()` |

> `FirestoreWrapper`, `FirebaseAuthWrapper`, and `CloudStorageWrapper` also expose a `makeDefault(emulator: (host: String, port: Int)?)` overload for emulator-backed setups — see [Emulator Setup](emulator-setup.md). Messaging and Remote Config don't have the emulator overload: the Firebase Emulator Suite has no emulator for those services.
