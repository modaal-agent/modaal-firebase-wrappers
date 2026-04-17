// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation
import ModaalFirebaseRemoteConfig

// MARK: - FirebaseRemoteConfigProtocol

/// Exercises every method/property on FirebaseRemoteConfigProtocol.
/// This function is never called — it only needs to compile.
func exerciseRemoteConfig(_ config: FirebaseRemoteConfigProtocol) {
  // Read-write property
  _ = config.minimumFetchInterval
  config.minimumFetchInterval = 3600

  // Read-only properties
  _ = config.lastFetchTime
  _ = config.lastFetchStatus

  // Fetch
  config.fetch { result in
    switch result {
    case .success(let status): _ = status
    case .failure(let error): _ = error.localizedDescription
    }
  }

  // Fetch and activate
  config.fetchAndActivate { result in
    switch result {
    case .success(let status): _ = status
    case .failure(let error): _ = error.localizedDescription
    }
  }

  // Activate
  config.activate { result in
    switch result {
    case .success(let changed): _ = changed
    case .failure: break
    }
  }

  // Config values
  let value = config.configValue(forKey: "feature_flag")
  exerciseRemoteConfigValue(value)

  // All keys
  _ = config.allKeys(from: .remote)
  _ = config.allKeys(from: .default)
  _ = config.allKeys(from: .static)

  // Defaults
  config.setDefaults(["feature_flag": true as NSObject, "timeout": 30 as NSObject])
  config.setDefaults(nil)
}

// MARK: - RemoteConfigValueProtocol

/// Exercises every property on RemoteConfigValueProtocol.
func exerciseRemoteConfigValue(_ value: RemoteConfigValueProtocol) {
  _ = value.stringValue
  _ = value.numberValue
  _ = value.dataValue
  _ = value.boolValue
  _ = value.jsonValue
  _ = value.source
}

// MARK: - Mirrored enum exercises

/// Exercises all cases of mirrored enums.
func exerciseRemoteConfigEnums() {
  // ModaalRemoteConfigFetchStatus
  let statuses: [ModaalRemoteConfigFetchStatus] = [.noFetchYet, .success, .failure, .throttled]
  _ = statuses

  // ModaalRemoteConfigFetchAndActivateStatus
  let activateStatuses: [ModaalRemoteConfigFetchAndActivateStatus] = [
    .successFetchedFromRemote, .successUsingPreFetchedData, .error,
  ]
  _ = activateStatuses

  // ModaalRemoteConfigSource
  let sources: [ModaalRemoteConfigSource] = [.remote, .default, .static]
  _ = sources
}

// MARK: - Wrapper instantiation

/// Exercises wrapper construction (proves the concrete type compiles).
func exerciseRemoteConfigWrapperInstantiation() {
  let _: FirebaseRemoteConfigWrapper.Type = FirebaseRemoteConfigWrapper.self
}
