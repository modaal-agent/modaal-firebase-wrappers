// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol FirebaseRemoteConfigProtocol: AnyObject {
  var minimumFetchInterval: TimeInterval { get set }
  var lastFetchTime: Date? { get }
  var lastFetchStatus: ModaalRemoteConfigFetchStatus { get }

  func fetch(completionHandler: @escaping (Result<ModaalRemoteConfigFetchStatus, Error>) -> Void)
  func fetchAndActivate(completionHandler: @escaping (Result<ModaalRemoteConfigFetchAndActivateStatus, Error>) -> Void)
  func activate(completion: @escaping (Result<Bool, Error>) -> Void)

  func configValue(forKey key: String) -> RemoteConfigValueProtocol
  func allKeys(from source: ModaalRemoteConfigSource) -> [String]
  func setDefaults(_ defaults: [String: NSObject]?)

  func addOnConfigUpdateListener(_ listener: @escaping (Result<RemoteConfigUpdateProtocol, Error>) -> Void) -> RemoteConfigListenerRegistration
}

public protocol RemoteConfigListenerRegistration: AnyObject {
  func remove()
}

public protocol RemoteConfigUpdateProtocol {
  var updatedKeys: Set<String> { get }
}
