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

extension FieldPath: ExpressibleByStringLiteral {
  /// Maps a string literal to `.fields([literal])` — i.e. a single-segment
  /// path. For multi-segment paths use `.fields(["a", "b"])` explicitly.
  /// (No `ExpressibleByArrayLiteral` conformance is provided; it would be
  /// ambiguous with `.fields([…])` and offers no expressive gain.)
  public init(stringLiteral value: String) {
    self = .fields([value])
  }
}
