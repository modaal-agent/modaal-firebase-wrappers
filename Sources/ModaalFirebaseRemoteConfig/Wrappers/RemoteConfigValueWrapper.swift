// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseRemoteConfig

final class RemoteConfigValueWrapper: RemoteConfigValueProtocol {
  let value: FirebaseRemoteConfig.RemoteConfigValue

  init(value: FirebaseRemoteConfig.RemoteConfigValue) {
    self.value = value
  }

  // MARK: - RemoteConfigValueProtocol

  var stringValue: String { value.stringValue }
  var numberValue: NSNumber { value.numberValue }
  var dataValue: Data { value.dataValue }
  var boolValue: Bool { value.boolValue }
  var jsonValue: Any? { value.jsonValue }

  var source: ModaalRemoteConfigSource {
    switch value.source {
    case .remote: return .remote
    case .default: return .default
    case .static: return .static
    @unknown default: return .static
    }
  }
}
