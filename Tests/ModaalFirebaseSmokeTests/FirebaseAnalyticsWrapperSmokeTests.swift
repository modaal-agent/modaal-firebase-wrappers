// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Analytics has no emulator — this smoke test just exercises the protocol
// surface. Analytics calls are no-ops without a real project configuration.

import XCTest
import ModaalFirebaseAnalytics

final class FirebaseAnalyticsWrapperSmokeTests: XCTestCase {
  func testAnalyticsProtocolMethodsAreCallable() {
    let analytics: FirebaseAnalyticsProtocol = FirebaseAnalyticsWrapper()
    analytics.logEvent(name: "smoke_event", parameters: ["key": "value"])
    analytics.setUserProperty("test-group", forName: "cohort")
    analytics.setUserID("smoke-user")
    analytics.setAnalyticsCollectionEnabled(false)
  }
}
