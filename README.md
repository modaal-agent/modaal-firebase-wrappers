# ModaalFirebase

Swift protocol wrappers for the Firebase iOS SDK. Provides testable, mockable interfaces for Firebase services — no raw `import Firebase*` required in consumer code.

## Modules

| Module | Wraps | Status |
|--------|-------|--------|
| `ModaalFirebaseCore` | Bootstrap (`FirebaseApp.configure()`) + shared types | In progress |
| `ModaalFirebaseAuth` | Firebase Auth | In progress |
| `ModaalFirebaseAnalytics` | Firebase Analytics | In progress |
| `ModaalFirebaseCrashlytics` | Firebase Crashlytics | In progress |
| `ModaalFirestore` | Firebase Firestore | In progress |
| `ModaalCloudStorage` | Firebase Cloud Storage | In progress |
| `ModaalFirebaseMessaging` | Firebase Cloud Messaging | In progress |
| `ModaalFirebaseRemoteConfig` | Firebase Remote Config | In progress |

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/modaal-agent/modaal-firebase-wrappers.git", from: "1.0.0"),
]
```

Then add the products you need to your target's dependencies:

```swift
.target(
  name: "YourApp",
  dependencies: [
    .product(name: "ModaalFirebaseCore", package: "modaal-firebase-wrappers"),
    .product(name: "ModaalFirebaseAuth", package: "modaal-firebase-wrappers"),
    // ... add per-service products as needed
  ]
)
```

## License

MIT — see [LICENSE](LICENSE).
