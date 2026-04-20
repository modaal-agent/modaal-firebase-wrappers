// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Crashlytics is the one service where the conformance is an `extension
// Crashlytics: FirebaseCrashlyticsProtocol`, not a standalone wrapper.
// Instantiation is via `Crashlytics.crashlytics()`, the standard Firebase SDK
// entry point.

import XCTest
import FirebaseCrashlytics
import ModaalFirebaseCrashlytics
final class FirebaseCrashlyticsSmokeTests: XCTestCase {
  override func setUp() {
    super.setUp()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
  }

  func testCrashlyticsProtocolMethodsAreCallable() {
    let crashlytics: FirebaseCrashlyticsProtocol = Crashlytics.crashlytics()
    crashlytics.setUserID("smoke-user")
    crashlytics.setCustomValue("42", forKey: "smokeKey")
    crashlytics.log("smoke-log")
    crashlytics.record(error: NSError(domain: "smoke", code: 1), userInfo: nil)
  }
}
