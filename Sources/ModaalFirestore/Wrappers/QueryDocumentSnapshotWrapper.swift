// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

/// Wraps `FirebaseFirestore.QueryDocumentSnapshot` for query-result iteration.
/// Conforms to both `QueryDocumentSnapshotProtocol` (non-optional `data()`) and
/// the parent `DocumentSnapshotProtocol` (optional `data()`); Swift resolves the
/// overload by static type at the call site.
final class QueryDocumentSnapshotWrapper: QueryDocumentSnapshotProtocol {
  let snapshot: FirebaseFirestore.QueryDocumentSnapshot

  init(snapshot: FirebaseFirestore.QueryDocumentSnapshot) {
    self.snapshot = snapshot
  }

  // DocumentSnapshotProtocol
  var documentID: String { snapshot.documentID }
  var exists: Bool { true }
  var reference: DocumentReferenceProtocol { DocumentReferenceWrapper(documentRef: snapshot.reference) }
  var metadata: SnapshotMetadataProtocol { snapshot.metadata }
  func get(_ field: String) -> Any? { snapshot.get(field) }

  // Dual `data()` — Swift treats the optional/non-optional pair as distinct
  // overloads; one wrapper class satisfies both protocols' requirements.
  func data() -> [String: Any]? { snapshot.data() }
  func data() -> [String: Any] { snapshot.data() }
}
