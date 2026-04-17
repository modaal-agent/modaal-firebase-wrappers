// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public enum Filter {
  case equalTo(FieldPath, value: Any)
  case notEqualTo(FieldPath, value: Any)
  case greaterThan(FieldPath, value: Any)
  case greaterThanOrEqualTo(FieldPath, value: Any)
  case lessThan(FieldPath, value: Any)
  case lessThanOrEqualTo(FieldPath, value: Any)
  case arrayContains(FieldPath, value: Any)
  case arrayContainsAny(FieldPath, values: [Any])
  case fieldIn(FieldPath, value: [Any])
  case fieldNotIn(FieldPath, values: [Any])
  case any([Filter])
  case all([Filter])
}
