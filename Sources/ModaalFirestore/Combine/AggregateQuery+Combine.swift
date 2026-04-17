// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension AggregateQueryProtocol {

  func getAggregation(source: FirestoreAggregateSource = .server) -> Future<Int, Error> {
    Future { promise in self.getAggregation(source: source) { promise($0) } }
  }
}
