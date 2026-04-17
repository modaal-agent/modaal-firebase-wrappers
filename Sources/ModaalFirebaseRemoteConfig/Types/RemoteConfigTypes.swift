// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Mirrored enum so consumers don't need `import FirebaseRemoteConfig`.
public enum ModaalRemoteConfigFetchStatus {
  case noFetchYet
  case success
  case failure
  case throttled
}

/// Mirrored enum so consumers don't need `import FirebaseRemoteConfig`.
public enum ModaalRemoteConfigFetchAndActivateStatus {
  case successFetchedFromRemote
  case successUsingPreFetchedData
  case error
}

/// Mirrored enum so consumers don't need `import FirebaseRemoteConfig`.
public enum ModaalRemoteConfigSource {
  case remote
  case `default`
  case `static`
}
