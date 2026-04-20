// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Minimal host app that bundles the emulator-backed unit test targets. The
// host exists for two reasons:
//
//   1. Firebase's internal initializers need LaunchServices metadata that's
//      only present inside a real app process (not the bare xctest agent).
//   2. `FirebaseApp.configure(...)` must run on the main thread before any
//      service is used. Doing it here (in `init`) guarantees both, and it
//      uses only `ModaalFirebase*` wrappers — zero Firebase-SDK imports.

import SwiftUI
import ModaalFirebaseCore
import ModaalFirebaseAuth
import ModaalFirestore
import ModaalCloudStorage

@main
struct EmulatorTestHostApp: App {
  init() {
    let env = ProcessInfo.processInfo.environment
    let host = env["MODAAL_EMULATOR_HOST"] ?? "localhost"
    let firestorePort = Int(env["MODAAL_FIRESTORE_PORT"] ?? "") ?? 8080
    let authPort = Int(env["MODAAL_AUTH_PORT"] ?? "") ?? 9099
    let storagePort = Int(env["MODAAL_STORAGE_PORT"] ?? "") ?? 9199

    ModaalFirebase.shared.configure(options: ModaalFirebaseOptions(
      googleAppID: "1:1234567890:ios:abcdef1234567890abcdef",
      gcmSenderID: "1234567890",
      apiKey: "A" + String(repeating: "z", count: 38),
      projectID: "demo-modaal",
      storageBucket: "demo-modaal.appspot.com"
    ))

    _ = FirestoreWrapper.makeDefault(emulator: (host: host, port: firestorePort))
    _ = FirebaseAuthWrapper.makeDefault(emulator: (host: host, port: authPort))
    _ = CloudStorageWrapper.makeDefault(emulator: (host: host, port: storagePort))
  }

  var body: some Scene {
    WindowGroup {
      Text("Emulator test host — \(ProcessInfo.processInfo.environment["MODAAL_EMULATOR_HOST"] ?? "disabled")")
    }
  }
}
