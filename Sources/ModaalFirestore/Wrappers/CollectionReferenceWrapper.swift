// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class CollectionReferenceWrapper: QueryWrapper, CollectionReferenceProtocol {
  let collectionRef: FirebaseFirestore.CollectionReference

  init(collectionRef: FirebaseFirestore.CollectionReference) {
    self.collectionRef = collectionRef
    super.init(query: collectionRef)
  }

  // MARK: - CollectionReferenceProtocol

  var collectionID: String { collectionRef.collectionID }
  var path: String { collectionRef.path }

  var parent: DocumentReferenceProtocol? {
    collectionRef.parent.map { DocumentReferenceWrapper(documentRef: $0) }
  }

  func document() -> DocumentReferenceProtocol {
    DocumentReferenceWrapper(documentRef: collectionRef.document())
  }

  func document(_ path: String) -> DocumentReferenceProtocol {
    DocumentReferenceWrapper(documentRef: collectionRef.document(path))
  }

  func addDocument(data: [String: Any], completion: @escaping (Result<DocumentReferenceProtocol, Error>) -> Void) {
    var ref: DocumentReference?
    ref = collectionRef.addDocument(data: data) { error in
      if let error {
        completion(.failure(error))
      } else if let ref {
        completion(.success(DocumentReferenceWrapper(documentRef: ref)))
      }
    }
  }
}
