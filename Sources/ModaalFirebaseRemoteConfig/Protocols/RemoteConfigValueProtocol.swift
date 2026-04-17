// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol RemoteConfigValueProtocol {
  var stringValue: String { get }
  var numberValue: NSNumber { get }
  var dataValue: Data { get }
  var boolValue: Bool { get }
  var jsonValue: Any? { get }
  var source: ModaalRemoteConfigSource { get }
}
