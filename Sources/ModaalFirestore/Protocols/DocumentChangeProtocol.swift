// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public enum DocumentChangeType {
  case added
  case modified
  case removed
}

public protocol DocumentChangeProtocol {
  var type: DocumentChangeType { get }
  var document: DocumentSnapshotProtocol { get }
  var oldIndex: UInt { get }
  var newIndex: UInt { get }
}
