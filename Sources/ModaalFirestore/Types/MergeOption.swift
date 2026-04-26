// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

/// Swift-idiomatic merge selector consumed by the `setData(_:mergeOption:…)`
/// extensions. Mirrors Firebase iOS SDK's three `setData` overloads:
/// - `.overwrite` → `setData(_:completion:)`
/// - `.merge` → `setData(_:merge: true, completion:)`
/// - `.mergeFields([…])` → `setData(_:mergeFields: [Any], completion:)`
///
/// The associated value is `[Any]` (not `[String]`) to match Firebase's
/// `setData(_:mergeFields:)` contract: each element may be a `String` field
/// name or a `FieldPath` instance — both are accepted and routed identically
/// by the canonical method.
public enum MergeOption {
  case overwrite
  case merge
  case mergeFields([Any])
}
