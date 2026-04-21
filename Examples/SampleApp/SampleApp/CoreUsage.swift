// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import ModaalFirebaseCore

/// Exercises every public API on ModaalFirebaseCore.
/// This function is never called — it only needs to compile.
func exerciseCore() {
  // Singleton access
  let firebase = ModaalFirebase.shared

  // Default configure (uses GoogleService-Info.plist from main bundle)
  firebase.configure()

  // Configure from a custom plist path
  let options: FirAppOptions? = firebase.configure(plistPath: "/path/to/GoogleService-Info.plist")
  _ = options?.clientID

  // Configure in-code via ModaalFirebaseOptions (no plist required)
  firebase.configure(options: ModaalFirebaseOptions(
    googleAppID: "1:1234567890:ios:abcdef1234567890abcdef",
    gcmSenderID: "1234567890",
    apiKey: "A" + String(repeating: "z", count: 38),
    projectID: "demo-project",
    storageBucket: "demo-project.appspot.com",
    clientID: "test-client-id",
    bundleID: "dev.example.app"
  ))

  // Minimal ModaalFirebaseOptions (only required fields)
  let minimalOptions = ModaalFirebaseOptions(
    googleAppID: "1:1234567890:ios:abcdef1234567890abcdef",
    gcmSenderID: "1234567890"
  )
  _ = minimalOptions.googleAppID
  _ = minimalOptions.gcmSenderID
  _ = minimalOptions.apiKey
  _ = minimalOptions.projectID
  _ = minimalOptions.storageBucket
  _ = minimalOptions.clientID
  _ = minimalOptions.bundleID

  // FirAppOptions direct construction
  let manualOptions = FirAppOptions(clientID: "test-client-id")
  _ = manualOptions.clientID
}
