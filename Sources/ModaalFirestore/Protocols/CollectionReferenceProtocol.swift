// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol CollectionReferenceProtocol: QueryProtocol {
  var collectionID: String { get }
  var path: String { get }
  var parent: DocumentReferenceProtocol? { get }

  func document() -> DocumentReferenceProtocol
  func document(_ path: String) -> DocumentReferenceProtocol
  func addDocument(data: [String: Any], completion: @escaping (Result<DocumentReferenceProtocol, Error>) -> Void)
}
