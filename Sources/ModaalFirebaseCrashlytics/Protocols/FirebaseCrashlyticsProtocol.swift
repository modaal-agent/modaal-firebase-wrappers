// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol FirebaseCrashlyticsProtocol: AnyObject {
  // Note: isCrashlyticsCollectionEnabled is available on the concrete Crashlytics
  // instance directly. It's not part of this protocol because Crashlytics uses
  // direct extension conformance, and the xcframeworks binary doesn't expose
  // the property in a protocol-conformable way.

  func setUserID(_ userID: String?)
  func setCustomValue(_ value: Any?, forKey key: String)

  func log(_ message: String)
  func record(error: Error, userInfo: [String: Any]?)
}
