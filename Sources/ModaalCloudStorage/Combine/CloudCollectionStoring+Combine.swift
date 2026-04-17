// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension CloudCollectionStoring {

  func listAll() -> Future<CloudStorageListResultProtocol, Error> {
    Future { promise in self.listAll { promise($0) } }
  }
}
