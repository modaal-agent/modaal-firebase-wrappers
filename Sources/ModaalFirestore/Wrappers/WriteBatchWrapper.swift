// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class WriteBatchWrapper: WriteBatchProtocol {
  let batch: FirebaseFirestore.WriteBatch

  init(batch: FirebaseFirestore.WriteBatch) {
    self.batch = batch
  }

  // MARK: - WriteBatchProtocol

  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeOption: MergeOption) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    switch mergeOption {
    case .overwrite:
      batch.setData(data, forDocument: docRef)
    case .merge:
      batch.setData(data, forDocument: docRef, merge: true)
    case .mergeFields(let fields):
      batch.setData(data, forDocument: docRef, mergeFields: fields)
    }
  }

  func updateData(_ fields: [String: Any], forDocument document: DocumentReferenceProtocol) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    batch.updateData(fields, forDocument: docRef)
  }

  func deleteDocument(_ document: DocumentReferenceProtocol) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    batch.deleteDocument(docRef)
  }

  func commit(completion: @escaping (Result<Void, Error>) -> Void) {
    batch.commit { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }
}
