// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol FirebaseAnalyticsProtocol {
  func logEvent(name: String, parameters: [String: Any]?)
  func setUserProperty(_ value: String?, forName name: String)
  func setUserID(_ userID: String?)
  func setAnalyticsCollectionEnabled(_ enabled: Bool)
  func resetAnalyticsData()
}
