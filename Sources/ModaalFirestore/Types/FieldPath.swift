// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public enum FieldPath {
  case documentId
  case fields([String])

  public static func field(_ name: String) -> FieldPath {
    .fields([name])
  }
}
