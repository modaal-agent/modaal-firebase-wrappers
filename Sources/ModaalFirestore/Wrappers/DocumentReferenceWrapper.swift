// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class DocumentReferenceWrapper: DocumentReferenceProtocol {
  let documentRef: FirebaseFirestore.DocumentReference

  init(documentRef: FirebaseFirestore.DocumentReference) {
    self.documentRef = documentRef
  }

  // MARK: - DocumentReferenceProtocol

  var documentID: String { documentRef.documentID }
  var path: String { documentRef.path }

  var parent: CollectionReferenceProtocol {
    CollectionReferenceWrapper(collectionRef: documentRef.parent)
  }

  func collection(_ path: String) -> CollectionReferenceProtocol {
    CollectionReferenceWrapper(collectionRef: documentRef.collection(path))
  }

  func getDocument(completion: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void) {
    getDocument(source: .default, completion: completion)
  }

  func getDocument(source: FirestoreSource, completion: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void) {
    documentRef.getDocument(source: source.asFirestoreType) { snapshot, error in
      if let snapshot {
        completion(.success(DocumentSnapshotWrapper(snapshot: snapshot)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func setData(_ data: [String: Any], mergeOption: MergeOption, completion: @escaping (Result<Void, Error>) -> Void) {
    let handler: (Error?) -> Void = { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
    switch mergeOption {
    case .overwrite:
      documentRef.setData(data, completion: handler)
    case .merge:
      documentRef.setData(data, merge: true, completion: handler)
    case .mergeFields(let fields):
      documentRef.setData(data, mergeFields: fields, completion: handler)
    }
  }

  func updateData(_ fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void) {
    documentRef.updateData(fields) { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func delete(completion: @escaping (Result<Void, Error>) -> Void) {
    documentRef.delete { error in
      if let error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
  }

  func addSnapshotListener(_ listener: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol {
    let registration = documentRef.addSnapshotListener { snapshot, error in
      if let snapshot {
        listener(.success(DocumentSnapshotWrapper(snapshot: snapshot)))
      } else {
        listener(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
    return ListenerRegistrationWrapper(registration: registration)
  }
}
