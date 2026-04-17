// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

public final class FirestoreWrapper: FirestoreProtocol {
  /// The underlying `Firestore` instance. Use for APIs not yet covered by this wrapper.
  /// Requires `import FirebaseFirestore` at the call site.
  public let firestore: Firestore

  public init(firestore: Firestore) {
    self.firestore = firestore
  }

  // MARK: - FirestoreProtocol

  public func collection(_ collectionPath: String) -> CollectionReferenceProtocol {
    CollectionReferenceWrapper(collectionRef: firestore.collection(collectionPath))
  }

  public func collectionGroup(_ collectionID: String) -> QueryProtocol {
    QueryWrapper(query: firestore.collectionGroup(collectionID))
  }

  public func document(_ documentPath: String) -> DocumentReferenceProtocol {
    DocumentReferenceWrapper(documentRef: firestore.document(documentPath))
  }

  public func batch() -> WriteBatchProtocol {
    WriteBatchWrapper(batch: firestore.batch())
  }

  public func runTransaction(_ updateBlock: @escaping (TransactionProtocol) throws -> Any?,
                              completion: @escaping (Result<Any?, Error>) -> Void) {
    firestore.runTransaction({ (transaction, errorPointer) -> Any? in
      let wrapped = TransactionWrapper(transaction: transaction)
      do {
        return try updateBlock(wrapped)
      } catch {
        errorPointer?.pointee = error as NSError
        return nil
      }
    }) { result, error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(result))
      }
    }
  }
}
