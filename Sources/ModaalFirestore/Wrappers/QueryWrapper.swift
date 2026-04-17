// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

class QueryWrapper: QueryProtocol {
  let query: FirebaseFirestore.Query

  init(query: FirebaseFirestore.Query) {
    self.query = query
  }

  // MARK: - QueryProtocol

  func whereFilter(_ filter: Filter) -> QueryProtocol {
    QueryWrapper(query: query.whereFilter(filter.asFirestoreFilter))
  }

  func order(by field: FieldPath, descending: Bool) -> QueryProtocol {
    QueryWrapper(query: query.order(by: field.asFirestoreFieldPath, descending: descending))
  }

  func limit(to value: Int) -> QueryProtocol {
    QueryWrapper(query: query.limit(to: value))
  }

  func limit(toLast value: Int) -> QueryProtocol {
    QueryWrapper(query: query.limit(toLast: value))
  }

  // MARK: - Pagination cursors (document-based)

  func start(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
    QueryWrapper(query: query.start(atDocument: (document as! DocumentSnapshotWrapper).snapshot))
  }

  func start(afterDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
    QueryWrapper(query: query.start(afterDocument: (document as! DocumentSnapshotWrapper).snapshot))
  }

  func end(atDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
    QueryWrapper(query: query.end(atDocument: (document as! DocumentSnapshotWrapper).snapshot))
  }

  func end(beforeDocument document: DocumentSnapshotProtocol) -> QueryProtocol {
    QueryWrapper(query: query.end(beforeDocument: (document as! DocumentSnapshotWrapper).snapshot))
  }

  // MARK: - Pagination cursors (field-value-based)

  func start(at fieldValues: [Any]) -> QueryProtocol {
    QueryWrapper(query: query.start(at: fieldValues))
  }

  func start(after fieldValues: [Any]) -> QueryProtocol {
    QueryWrapper(query: query.start(after: fieldValues))
  }

  func end(at fieldValues: [Any]) -> QueryProtocol {
    QueryWrapper(query: query.end(at: fieldValues))
  }

  func end(before fieldValues: [Any]) -> QueryProtocol {
    QueryWrapper(query: query.end(before: fieldValues))
  }

  // MARK: - Get documents

  func getDocuments(completion: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void) {
    query.getDocuments { snapshot, error in
      if let snapshot {
        completion(.success(QuerySnapshotWrapper(snapshot: snapshot)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func getDocuments(source: FirestoreSource, completion: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void) {
    query.getDocuments(source: source.asFirestoreType) { snapshot, error in
      if let snapshot {
        completion(.success(QuerySnapshotWrapper(snapshot: snapshot)))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }

  func addSnapshotListener(includeMetadataChanges: Bool, _ listener: @escaping (Result<QuerySnapshotProtocol, Error>) -> Void) -> ListenerRegistrationProtocol {
    let registration = query.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { snapshot, error in
      if let snapshot {
        listener(.success(QuerySnapshotWrapper(snapshot: snapshot)))
      } else {
        listener(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
    return ListenerRegistrationWrapper(registration: registration)
  }

  var count: AggregateQueryProtocol {
    AggregateQueryWrapper(aggregateQuery: query.count)
  }
}
