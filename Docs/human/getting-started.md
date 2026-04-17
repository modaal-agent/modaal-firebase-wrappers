# Getting Started

## Installation

Add ModaalFirebase to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/modaal-agent/modaal-firebase-wrappers.git", from: "0.1.0"),
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

## Bootstrap

Initialize Firebase in your app's entry point:

```swift
import ModaalFirebaseCore

@main
struct MyApp: App {
  init() {
    ModaalFirebase.shared.configure()
  }
  // ...
}
```

## Usage

### Completion Handlers

Every wrapped method uses completion handlers with `Result<T, Error>`:

```swift
import ModaalFirebaseAuth

let auth: FirebaseAuthProtocol = FirebaseAuthWrapper(auth: Auth.auth())

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

let wrapper = FirestoreWrapper(firestore: Firestore.firestore())

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
| `ModaalFirebaseAuth` | `import ModaalFirebaseAuth` | `FirebaseAuthWrapper(auth: Auth.auth())` |
| `ModaalFirebaseAnalytics` | `import ModaalFirebaseAnalytics` | `FirebaseAnalyticsWrapper()` |
| `ModaalFirebaseCrashlytics` | `import ModaalFirebaseCrashlytics` | `Crashlytics.crashlytics()` (direct conformance) |
| `ModaalFirestore` | `import ModaalFirestore` | `FirestoreWrapper(firestore: Firestore.firestore())` |
| `ModaalCloudStorage` | `import ModaalCloudStorage` | `CloudStorageWrapper(storage: Storage.storage())` |
| `ModaalFirebaseMessaging` | `import ModaalFirebaseMessaging` | `FirebaseMessagingWrapper(messaging: Messaging.messaging())` |
| `ModaalFirebaseRemoteConfig` | `import ModaalFirebaseRemoteConfig` | `FirebaseRemoteConfigWrapper(remoteConfig: RemoteConfig.remoteConfig())` |
