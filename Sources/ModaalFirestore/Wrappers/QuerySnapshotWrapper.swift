// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class QuerySnapshotWrapper: QuerySnapshotProtocol {
  let snapshot: FirebaseFirestore.QuerySnapshot

  init(snapshot: FirebaseFirestore.QuerySnapshot) {
    self.snapshot = snapshot
  }

  var documents: [QueryDocumentSnapshotProtocol] {
    snapshot.documents.map { QueryDocumentSnapshotWrapper(snapshot: $0) }
  }

  var documentChanges: [DocumentChangeProtocol] {
    snapshot.documentChanges.map { DocumentChangeWrapper(change: $0) }
  }

  var count: Int { snapshot.count }
  var isEmpty: Bool { snapshot.isEmpty }
  var metadata: SnapshotMetadataProtocol { snapshot.metadata }
}
