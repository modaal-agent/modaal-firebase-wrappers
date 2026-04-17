// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension CollectionReferenceProtocol {

  func addDocument(data: [String: Any]) -> Future<DocumentReferenceProtocol, Error> {
    Future { promise in self.addDocument(data: data) { promise($0) } }
  }
}
