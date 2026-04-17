// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension WriteBatchProtocol {

  func commit() -> Future<Void, Error> {
    Future { promise in self.commit { promise($0) } }
  }
}
