// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class DocumentChangeWrapper: DocumentChangeProtocol {
  let change: FirebaseFirestore.DocumentChange

  init(change: FirebaseFirestore.DocumentChange) {
    self.change = change
  }

  var type: DocumentChangeType {
    switch change.type {
    case .added: return .added
    case .modified: return .modified
    case .removed: return .removed
    }
  }

  var document: DocumentSnapshotProtocol {
    DocumentSnapshotWrapper(snapshot: change.document)
  }

  var oldIndex: UInt { change.oldIndex }
  var newIndex: UInt { change.newIndex }
}
