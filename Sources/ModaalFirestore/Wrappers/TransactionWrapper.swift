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

  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    transaction.setData(data, forDocument: docRef)
  }

  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, merge: Bool) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    transaction.setData(data, forDocument: docRef, merge: merge)
  }

  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeFields: [Any]) {
    let docRef = (document as! DocumentReferenceWrapper).documentRef
    transaction.setData(data, forDocument: docRef, mergeFields: mergeFields)
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
