// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class DocumentSnapshotWrapper: DocumentSnapshotProtocol {
  let snapshot: FirebaseFirestore.DocumentSnapshot

  init(snapshot: FirebaseFirestore.DocumentSnapshot) {
    self.snapshot = snapshot
  }

  var documentID: String { snapshot.documentID }
  var exists: Bool { snapshot.exists }
  var reference: DocumentReferenceProtocol { DocumentReferenceWrapper(documentRef: snapshot.reference) }

  func data() -> [String: Any]? { snapshot.data() }
  func get(_ field: String) -> Any? { snapshot.get(field) }
}
