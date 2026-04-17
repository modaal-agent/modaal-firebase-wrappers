// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol SnapshotMetadataProtocol {
  var hasPendingWrites: Bool { get }
  var isFromCache: Bool { get }
}
