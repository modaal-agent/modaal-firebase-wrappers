// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public enum FirestoreAggregateSource {
  case server
}

public enum FirestoreSource {
  case `default`
  case server
  case cache
}

public protocol AggregateQueryProtocol: AnyObject {
  func getAggregation(source: FirestoreAggregateSource, completion: @escaping (Result<Int, Error>) -> Void)
}
