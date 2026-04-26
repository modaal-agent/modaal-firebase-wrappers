// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol DocumentReferenceProtocol: AnyObject {
  var documentID: String { get }
  var path: String { get }
  var parent: CollectionReferenceProtocol { get }

  func collection(_ path: String) -> CollectionReferenceProtocol

  func getDocument(completion: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void)
  func getDocument(source: FirestoreSource, completion: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void)

  // Canonical Firebase iOS SDK signatures.
  // Note: the no-arg `setData(_:completion:)` form is the *overwrite* case —
  // semantically equivalent to `setData(_:merge: false, completion:)`. Use
  // `setData(_:merge: true, completion:)` for shallow merges or
  // `setData(_:mergeFields: [Any], completion:)` for selective merges.
  func setData(_ documentData: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
  func setData(_ documentData: [String: Any], merge: Bool, completion: @escaping (Result<Void, Error>) -> Void)
  func setData(_ documentData: [String: Any], mergeFields: [Any], completion: @escaping (Result<Void, Error>) -> Void)

  func updateData(_ fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
  func delete(completion: @escaping (Result<Void, Error>) -> Void)

  func addSnapshotListener(includeMetadataChanges: Bool, _ listener: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol
}

public extension DocumentReferenceProtocol {
  func addSnapshotListener(_ listener: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol {
    addSnapshotListener(includeMetadataChanges: false, listener)
  }
}
