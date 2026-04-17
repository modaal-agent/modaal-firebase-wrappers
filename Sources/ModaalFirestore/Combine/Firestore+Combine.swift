// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension FirestoreProtocol {

  func runTransaction(_ updateBlock: @escaping (TransactionProtocol) throws -> Any?) -> Future<Any?, Error> {
    Future { promise in self.runTransaction(updateBlock) { promise($0) } }
  }
}
