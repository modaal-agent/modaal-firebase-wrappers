// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol QueryProtocol: AnyObject {
  func whereFilter(_ filter: Filter) -> QueryProtocol
  func order(by field: FieldPath, descending: Bool) -> QueryProtocol
  func limit(to value: Int) -> QueryProtocol
  func limit(toLast value: Int) -> QueryProtocol

  func getDocuments(completion: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void)
  func addSnapshotListener(_ listener: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol

  var count: AggregateQueryProtocol { get }
}
