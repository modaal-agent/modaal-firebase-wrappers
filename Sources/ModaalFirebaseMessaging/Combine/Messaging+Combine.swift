// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import Foundation

public extension FirebaseMessagingProtocol {

  func token() -> Future<String, Error> {
    Future { promise in self.token { promise($0) } }
  }

  func deleteToken() -> Future<Void, Error> {
    Future { promise in self.deleteToken { promise($0) } }
  }

  func subscribe(toTopic topic: String) -> Future<Void, Error> {
    Future { promise in self.subscribe(toTopic: topic) { promise($0) } }
  }

  func unsubscribe(fromTopic topic: String) -> Future<Void, Error> {
    Future { promise in self.unsubscribe(fromTopic: topic) { promise($0) } }
  }
}
