// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol FirestoreProtocol: AnyObject {
  func collection(_ collectionPath: String) -> CollectionReferenceProtocol
  func collectionGroup(_ collectionID: String) -> QueryProtocol
  func document(_ documentPath: String) -> DocumentReferenceProtocol
  func batch() -> WriteBatchProtocol
  func runTransaction(_ updateBlock: @escaping (TransactionProtocol) throws -> Any?,
                      completion: @escaping (Result<Any?, Error>) -> Void)
}
