// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol CloudStorageReferencing: CloudCollectionStoring, CloudFileStoring {
  var fullPath: String { get }
  var name: String { get }
  var bucket: String { get }

  func child(path: String) -> CloudStorageReferencing
  func parent() -> CloudStorageReferencing?
  func root() -> CloudStorageReferencing
}
