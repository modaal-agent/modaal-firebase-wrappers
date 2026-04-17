// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import FirebaseFirestore

final class AggregateQueryWrapper: AggregateQueryProtocol {
  let aggregateQuery: FirebaseFirestore.AggregateQuery

  init(aggregateQuery: FirebaseFirestore.AggregateQuery) {
    self.aggregateQuery = aggregateQuery
  }

  func getAggregation(source: FirestoreAggregateSource, completion: @escaping (Result<Int, Error>) -> Void) {
    aggregateQuery.getAggregation(source: source.asFirestoreType) { snapshot, error in
      if let snapshot {
        completion(.success(snapshot.count.intValue))
      } else {
        completion(.failure(error ?? NSError(domain: "Unknown error", code: -1)))
      }
    }
  }
}
