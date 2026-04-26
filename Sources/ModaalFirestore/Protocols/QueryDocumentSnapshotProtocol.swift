// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Refines `DocumentSnapshotProtocol` with the non-optional `data()` guarantee
/// Firebase encodes for query-result snapshots. Iterating
/// `QuerySnapshotProtocol.documents` yields `[QueryDocumentSnapshotProtocol]`,
/// so consumers can read `doc.data()` without `guard let` — a query result
/// is by definition existent.
///
/// Mirrors the Firebase iOS SDK's `QueryDocumentSnapshot : DocumentSnapshot`
/// class hierarchy.
public protocol QueryDocumentSnapshotProtocol: DocumentSnapshotProtocol {
  /// Non-optional override. The parent protocol's `data() -> [String: Any]?`
  /// remains accessible through `as DocumentSnapshotProtocol` upcast — Swift
  /// resolves the overload by static type.
  func data() -> [String: Any]
}
