// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol DocumentSnapshotProtocol: AnyObject {
  var documentID: String { get }
  var exists: Bool { get }
  var reference: DocumentReferenceProtocol { get }
  func data() -> [String: Any]?
  func get(_ field: String) -> Any?
}
