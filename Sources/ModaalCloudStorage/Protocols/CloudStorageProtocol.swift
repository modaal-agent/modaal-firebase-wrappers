// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol CloudStorageProtocol: AnyObject {
  func reference() -> CloudStorageReferencing
  func reference(forURL url: String) -> CloudStorageReferencing
  func reference(withPath path: String) -> CloudStorageReferencing
}
