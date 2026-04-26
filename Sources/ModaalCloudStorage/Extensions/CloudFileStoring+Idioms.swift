// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

// MARK: - Two-tier API surface
//
// `CloudFileStoring` mirrors `firebase-ios-sdk`'s `StorageReference`
// download-URL accessor exactly (`downloadURL(completion:)`). The
// `getDownloadURL(completion:)` form lives here as a Swift-idiomatic
// alias that delegates to the canonical method.
// See `Docs/agent/patterns.md` § "Two-tier API surface".

public extension CloudFileStoring {
  func getDownloadURL(completion: @escaping (Result<URL, Error>) -> Void) {
    downloadURL(completion: completion)
  }
}
