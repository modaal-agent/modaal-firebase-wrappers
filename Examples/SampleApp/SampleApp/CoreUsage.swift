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

  // FirAppOptions direct construction
  let manualOptions = FirAppOptions(clientID: "test-client-id")
  _ = manualOptions.clientID
}
