// swift-tools-version:5.9

// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import PackageDescription

// SPM 5.9 identifies packages by URL (last path component), not the internal `name` field.
let firebaseSDK = "firebase-ios-sdk-xcframeworks"

let package = Package(
  name: "ModaalFirebase",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(name: "ModaalFirebaseCore", targets: ["ModaalFirebaseCore"]),
    .library(name: "ModaalFirebaseAuth", targets: ["ModaalFirebaseAuth"]),
    .library(name: "ModaalFirebaseAnalytics", targets: ["ModaalFirebaseAnalytics"]),
    .library(name: "ModaalFirebaseCrashlytics", targets: ["ModaalFirebaseCrashlytics"]),
    .library(name: "ModaalFirestore", targets: ["ModaalFirestore"]),
    .library(name: "ModaalCloudStorage", targets: ["ModaalCloudStorage"]),
    .library(name: "ModaalFirebaseMessaging", targets: ["ModaalFirebaseMessaging"]),
    .library(name: "ModaalFirebaseRemoteConfig", targets: ["ModaalFirebaseRemoteConfig"]),
    .library(name: "ModaalFirebaseMocks", targets: ["ModaalFirebaseMocks"]),
  ],
  dependencies: [
    .package(url: "https://github.com/akaffenberger/firebase-ios-sdk-xcframeworks.git", from: "12.12.0"),
  ],
  targets: [
    // MARK: - Core
    // The xcframeworks package does not expose FirebaseCore as a standalone
    // product — _FirebaseCore is an internal binary target, bundled into the
    // FirebaseAnalytics product. Since ModaalFirebaseCore needs `import
    // FirebaseCore` for FirebaseApp.configure(), FirebaseAnalytics is the
    // only available product that provides it.

    .target(
      name: "ModaalFirebaseCore",
      dependencies: [
        .product(name: "FirebaseAnalytics", package: firebaseSDK),
      ]
    ),

    // MARK: - Auth

    .target(
      name: "ModaalFirebaseAuth",
      dependencies: [
        "ModaalFirebaseCore",
        .product(name: "FirebaseAuth", package: firebaseSDK),
      ]
    ),

    // MARK: - Analytics

    .target(
      name: "ModaalFirebaseAnalytics",
      dependencies: [
        "ModaalFirebaseCore",
      ]
    ),

    // MARK: - Crashlytics

    .target(
      name: "ModaalFirebaseCrashlytics",
      dependencies: [
        "ModaalFirebaseCore",
        .product(name: "FirebaseCrashlytics", package: firebaseSDK),
      ]
    ),

    // MARK: - Firestore

    .target(
      name: "ModaalFirestore",
      dependencies: [
        "ModaalFirebaseCore",
        .product(name: "FirebaseFirestore", package: firebaseSDK),
      ]
    ),

    // MARK: - Cloud Storage

    .target(
      name: "ModaalCloudStorage",
      dependencies: [
        "ModaalFirebaseCore",
        .product(name: "FirebaseStorage", package: firebaseSDK),
      ]
    ),

    // MARK: - Messaging

    .target(
      name: "ModaalFirebaseMessaging",
      dependencies: [
        "ModaalFirebaseCore",
        .product(name: "FirebaseMessaging", package: firebaseSDK),
      ]
    ),

    // MARK: - Remote Config

    .target(
      name: "ModaalFirebaseRemoteConfig",
      dependencies: [
        "ModaalFirebaseCore",
        .product(name: "FirebaseRemoteConfig", package: firebaseSDK),
      ]
    ),

    // MARK: - Pre-generated Mocks

    .target(
      name: "ModaalFirebaseMocks",
      dependencies: [
        "ModaalFirebaseAuth",
        "ModaalFirebaseAnalytics",
        "ModaalFirebaseCrashlytics",
        "ModaalFirestore",
        "ModaalCloudStorage",
        "ModaalFirebaseMessaging",
        "ModaalFirebaseRemoteConfig",
      ]
    ),

    // MARK: - Tests

    .testTarget(
      name: "ModaalFirestoreCombineTests",
      dependencies: ["ModaalFirestore", "ModaalFirebaseMocks"]
    ),
    .testTarget(
      name: "ModaalFirebaseAuthCombineTests",
      dependencies: ["ModaalFirebaseAuth", "ModaalFirebaseMocks"]
    ),
    .testTarget(
      name: "ModaalFirestoreTypeMappingTests",
      dependencies: [
        "ModaalFirestore",
        .product(name: "FirebaseFirestore", package: firebaseSDK),
      ]
    ),

    // MARK: - Emulator-backed tests
    // Smoke tests run against the Firebase Emulator when `MODAAL_EMULATOR_HOST`
    // is set; otherwise they XCTSkip. Integration tests require the emulator.
    // Both are invoked by `scripts/run-integration-tests.sh`.

    .testTarget(
      name: "ModaalFirebaseSmokeTests",
      dependencies: [
        "ModaalFirebaseCore",
        "ModaalFirebaseAuth",
        "ModaalFirebaseAnalytics",
        "ModaalFirebaseCrashlytics",
        "ModaalFirestore",
        "ModaalCloudStorage",
        "ModaalFirebaseMessaging",
        "ModaalFirebaseRemoteConfig",
        .product(name: "FirebaseAuth", package: firebaseSDK),
        .product(name: "FirebaseFirestore", package: firebaseSDK),
        .product(name: "FirebaseStorage", package: firebaseSDK),
        .product(name: "FirebaseMessaging", package: firebaseSDK),
        .product(name: "FirebaseRemoteConfig", package: firebaseSDK),
        .product(name: "FirebaseCrashlytics", package: firebaseSDK),
      ]
    ),
    .testTarget(
      name: "ModaalFirebaseIntegrationTests",
      dependencies: [
        "ModaalFirebaseCore",
        "ModaalFirebaseAuth",
        "ModaalFirestore",
        "ModaalCloudStorage",
        "ModaalFirebaseRemoteConfig",
        .product(name: "FirebaseAuth", package: firebaseSDK),
        .product(name: "FirebaseFirestore", package: firebaseSDK),
        .product(name: "FirebaseStorage", package: firebaseSDK),
        .product(name: "FirebaseRemoteConfig", package: firebaseSDK),
      ]
    ),
  ]
)
