// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class TransactionWrapper: TransactionProtocol {
  let transaction: FirebaseFirestore.Transaction

  init(transaction: FirebaseFirestore.Transaction) {
    self.transaction = transaction
  }

  // MARK: - TransactionProtocol

  func getDocument(_ document: DocumentReferenceProtocol) throws -> DocumentSnapshotProtocol {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    let snapshot = try transaction.getDocument(docRef)
    return DocumentSnapshotWrapper(snapshot: snapshot)
  }

  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeOption: MergeOption) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    switch mergeOption {
    case .overwrite:
      transaction.setData(data, forDocument: docRef)
    case .merge:
      transaction.setData(data, forDocument: docRef, merge: true)
    case .mergeFields(let fields):
      transaction.setData(data, forDocument: docRef, mergeFields: fields)
    }
  }

  func updateData(_ fields: [String: Any], forDocument document: DocumentReferenceProtocol) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    transaction.updateData(fields, forDocument: docRef)
  }

  func deleteDocument(_ document: DocumentReferenceProtocol) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    transaction.deleteDocument(docRef)
  }
}
