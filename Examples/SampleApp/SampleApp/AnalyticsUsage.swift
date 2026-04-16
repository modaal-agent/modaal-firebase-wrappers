// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import ModaalFirebaseAnalytics

/// Exercises every public API on ModaalFirebaseAnalytics.
/// This function is never called — it only needs to compile.
func exerciseAnalytics(_ analytics: FirebaseAnalyticsProtocol) {
  analytics.logEvent(name: "screen_view", parameters: ["screen_name": "Home"])
  analytics.logEvent(name: "purchase", parameters: nil)
  analytics.setUserProperty("premium", forName: "account_type")
  analytics.setUserID("user-123")
  analytics.setUserID(nil)
}

/// Exercises wrapper instantiation.
func exerciseAnalyticsWrapper() {
  let wrapper = FirebaseAnalyticsWrapper()
  exerciseAnalytics(wrapper)
}
