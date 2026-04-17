// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalFirebaseCrashlytics

/// Exercises every public API on ModaalFirebaseCrashlytics.
/// This function is never called — it only needs to compile.
func exerciseCrashlytics(_ crashlytics: FirebaseCrashlyticsProtocol) {
  // Note: isCrashlyticsCollectionEnabled is accessible directly on the concrete
  // Crashlytics instance (direct extension conformance pattern — the consumer
  // already has the real type).

  crashlytics.setUserID("user-123")
  crashlytics.setUserID(nil)
  crashlytics.setCustomValue("premium", forKey: "account_type")
  crashlytics.setCustomValue(42, forKey: "level")
  crashlytics.setCustomValue(nil, forKey: "cleared_key")
  crashlytics.log("User tapped checkout button")
  crashlytics.record(
    error: NSError(domain: "com.example", code: -1),
    userInfo: ["context": "checkout"]
  )
  crashlytics.record(error: NSError(domain: "com.example", code: -2), userInfo: nil)
}
