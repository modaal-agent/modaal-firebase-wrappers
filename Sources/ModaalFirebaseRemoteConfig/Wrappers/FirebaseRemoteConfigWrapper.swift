// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseRemoteConfig

public final class FirebaseRemoteConfigWrapper: FirebaseRemoteConfigProtocol {
  /// The underlying `RemoteConfig` instance. Use for APIs not yet covered by this wrapper.
  /// Requires `import FirebaseRemoteConfig` at the call site.
  public let remoteConfig: RemoteConfig

  public init(remoteConfig: RemoteConfig) {
    self.remoteConfig = remoteConfig
  }

  /// Build a wrapper around the default `RemoteConfig.remoteConfig()` instance.
  ///
  /// Saves consumers from having to `import FirebaseRemoteConfig` at the
  /// construction site. No emulator variant — the Firebase Emulator Suite
  /// has no Remote Config emulator; use `setDefaults(_:)` for local testing.
  public static func makeDefault() -> FirebaseRemoteConfigWrapper {
    FirebaseRemoteConfigWrapper(remoteConfig: RemoteConfig.remoteConfig())
  }

  // MARK: - FirebaseRemoteConfigProtocol

  public var minimumFetchInterval: TimeInterval {
    get { remoteConfig.configSettings.minimumFetchInterval }
    set {
      let settings = RemoteConfigSettings()
      settings.minimumFetchInterval = newValue
      remoteConfig.configSettings = settings
    }
  }

  public var lastFetchTime: Date? { remoteConfig.lastFetchTime }

  public var lastFetchStatus: ModaalRemoteConfigFetchStatus {
    switch remoteConfig.lastFetchStatus {
    case .noFetchYet: return .noFetchYet
    case .success: return .success
    case .failure: return .failure
    case .throttled: return .throttled
    @unknown default: return .noFetchYet
    }
  }

  public func fetch(completionHandler: @escaping (Result<ModaalRemoteConfigFetchStatus, Error>) -> Void) {
    remoteConfig.fetch { status, error in
      if let error {
        completionHandler(.failure(error))
      } else {
        let mapped: ModaalRemoteConfigFetchStatus
        switch status {
        case .noFetchYet: mapped = .noFetchYet
        case .success: mapped = .success
        case .failure: mapped = .failure
        case .throttled: mapped = .throttled
        @unknown default: mapped = .noFetchYet
        }
        completionHandler(.success(mapped))
      }
    }
  }

  public func fetchAndActivate(completionHandler: @escaping (Result<ModaalRemoteConfigFetchAndActivateStatus, Error>) -> Void) {
    remoteConfig.fetchAndActivate { status, error in
      if let error {
        completionHandler(.failure(error))
      } else {
        let mapped: ModaalRemoteConfigFetchAndActivateStatus
        switch status {
        case .successFetchedFromRemote: mapped = .successFetchedFromRemote
        case .successUsingPreFetchedData: mapped = .successUsingPreFetchedData
        case .error: mapped = .error
        @unknown default: mapped = .error
        }
        completionHandler(.success(mapped))
      }
    }
  }

  public func activate(completion: @escaping (Result<Bool, Error>) -> Void) {
    remoteConfig.activate { changed, error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(changed))
      }
    }
  }

  public func configValue(forKey key: String) -> RemoteConfigValueProtocol {
    RemoteConfigValueWrapper(value: remoteConfig.configValue(forKey: key))
  }

  public func allKeys(from source: ModaalRemoteConfigSource) -> [String] {
    remoteConfig.allKeys(from: source.asRemoteConfigType)
  }

  public func setDefaults(_ defaults: [String: NSObject]?) {
    remoteConfig.setDefaults(defaults)
  }

  public func addOnConfigUpdateListener(_ listener: @escaping (Result<RemoteConfigUpdateProtocol, Error>) -> Void) -> RemoteConfigListenerRegistration {
    let registration = remoteConfig.addOnConfigUpdateListener { update, error in
      if let update {
        listener(.success(RemoteConfigUpdateWrapper(update: update)))
      } else {
        listener(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
    return RemoteConfigListenerRegistrationWrapper(registration: registration)
  }
}

private final class RemoteConfigListenerRegistrationWrapper: RemoteConfigListenerRegistration {
  let registration: ConfigUpdateListenerRegistration

  init(registration: ConfigUpdateListenerRegistration) {
    self.registration = registration
  }

  func remove() { registration.remove() }
}

private final class RemoteConfigUpdateWrapper: RemoteConfigUpdateProtocol {
  let update: RemoteConfigUpdate

  init(update: RemoteConfigUpdate) {
    self.update = update
  }

  var updatedKeys: Set<String> { update.updatedKeys }
}

extension ModaalRemoteConfigSource {
  var asRemoteConfigType: RemoteConfigSource {
    switch self {
    case .remote: return .remote
    case .default: return .default
    case .static: return .static
    }
  }
}
