// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

// MARK: - Two-tier API surface
//
// Swift-idiomatic `mergeOption: MergeOption` form for transactional
// `setData`, dispatching to the canonical
// `setData(_:forDocument:merge:)` / `setData(_:forDocument:mergeFields:)`
// protocol methods.
// See `Docs/agent/patterns.md` § "Two-tier API surface".

public extension TransactionProtocol {
  func setData(
    _ data: [String: Any],
    forDocument document: DocumentReferenceProtocol,
    mergeOption: MergeOption
  ) {
    switch mergeOption {
    case .overwrite:
      setData(data, forDocument: document)
    case .merge:
      setData(data, forDocument: document, merge: true)
    case .mergeFields(let fields):
      setData(data, forDocument: document, mergeFields: fields)
    }
  }
}
