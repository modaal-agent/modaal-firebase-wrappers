// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

// MARK: - Two-tier API surface
//
// `CloudStorageReferencing` mirrors `firebase-ios-sdk`'s `StorageReference`
// exactly at the protocol-declaration level (`child(_)` positional). The
// labeled `child(path:)` form lives here as a Swift-idiomatic protocol
// extension that delegates to the canonical method.
// See `Docs/agent/patterns.md` § "Two-tier API surface".

public extension CloudStorageReferencing {
  /// Swift-idiomatic labeled alias for the canonical positional `child(_)`.
  ///
  /// **Dispatch invariant**: Swift resolves the unlabeled `child(path)` call
  /// inside the body to the *protocol method* `func child(_ pathString: String)`
  /// (an extension never shadows a protocol requirement of the same base name).
  /// If a future change ever drops or renames the canonical protocol method,
  /// the call here would silently rebind to *this* extension and recurse
  /// infinitely. Keep the canonical protocol method or rename this extension
  /// in lockstep.
  func child(path: String) -> CloudStorageReferencing {
    child(path)
  }
}
