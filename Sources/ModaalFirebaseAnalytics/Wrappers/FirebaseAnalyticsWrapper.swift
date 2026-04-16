// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseAnalytics

public final class FirebaseAnalyticsWrapper: FirebaseAnalyticsProtocol {
  public init() {}

  public func logEvent(name: String, parameters: [String: Any]?) {
    Analytics.logEvent(name, parameters: parameters)
  }

  public func setUserProperty(_ value: String?, forName name: String) {
    Analytics.setUserProperty(value, forName: name)
  }

  public func setUserID(_ userID: String?) {
    Analytics.setUserID(userID)
  }
}
