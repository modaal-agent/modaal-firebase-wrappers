// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol DocumentReferenceProtocol: AnyObject {
  var documentID: String { get }
  var path: String { get }
  var parent: CollectionReferenceProtocol { get }

  func collection(_ path: String) -> CollectionReferenceProtocol

  func getDocument(completion: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void)
  func setData(_ data: [String: Any], mergeOption: MergeOption, completion: @escaping (Result<Void, Error>) -> Void)
  func updateData(_ fields: [String: Any], completion: @escaping (Result<Void, Error>) -> Void)
  func delete(completion: @escaping (Result<Void, Error>) -> Void)

  func addSnapshotListener(_ listener: @escaping (Result<DocumentSnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol
}
