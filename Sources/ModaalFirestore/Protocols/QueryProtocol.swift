// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol QueryProtocol: AnyObject {
  func whereFilter(_ filter: Filter) -> QueryProtocol
  func order(by field: FieldPath, descending: Bool) -> QueryProtocol
  func limit(to value: Int) -> QueryProtocol
  func limit(toLast value: Int) -> QueryProtocol

  // Pagination cursors (document-based)
  func start(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol
  func start(afterDocument document: DocumentSnapshotProtocol) -> QueryProtocol
  func end(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol
  func end(beforeDocument document: DocumentSnapshotProtocol) -> QueryProtocol

  // Pagination cursors (field-value-based)
  func start(at fieldValues: [Any]) -> QueryProtocol
  func start(after fieldValues: [Any]) -> QueryProtocol
  func end(at fieldValues: [Any]) -> QueryProtocol
  func end(before fieldValues: [Any]) -> QueryProtocol

  func getDocuments(completion: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void)
  func getDocuments(source: FirestoreSource, completion: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void)
  func addSnapshotListener(_ listener: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol

  var count: AggregateQueryProtocol { get }
}
