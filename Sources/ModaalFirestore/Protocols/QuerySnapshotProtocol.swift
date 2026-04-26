// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol QuerySnapshotProtocol: AnyObject {
  var documents: [QueryDocumentSnapshotProtocol] { get }
  var documentChanges: [DocumentChangeProtocol] { get }
  var count: Int { get }
  var isEmpty: Bool { get }
  var metadata: SnapshotMetadataProtocol { get }
}
