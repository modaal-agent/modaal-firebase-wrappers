// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol FirebaseCrashlyticsProtocol: AnyObject {
  // Note: isCrashlyticsCollectionEnabled is intentionally not part of this
  // protocol. Crashlytics uses direct extension conformance — consumers
  // already hold the concrete `Crashlytics` instance and access privacy
  // toggles on it directly.

  func setUserID(_ userID: String?)
  func setCustomValue(_ value: Any?, forKey key: String)

  func log(_ message: String)
  func record(error: Error, userInfo: [String: Any]?)
}
