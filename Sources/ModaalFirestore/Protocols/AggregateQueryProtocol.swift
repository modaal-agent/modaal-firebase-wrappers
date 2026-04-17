// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public enum FirestoreAggregateSource {
  case server
}

public protocol AggregateQueryProtocol: AnyObject {
  func getAggregation(source: FirestoreAggregateSource, completion: @escaping (Result<Int, Error>) -> Void)
}
