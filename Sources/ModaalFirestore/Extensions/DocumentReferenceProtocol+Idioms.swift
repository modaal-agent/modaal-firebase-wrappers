// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

// MARK: - Two-tier API surface
//
// `DocumentReferenceProtocol` mirrors `firebase-ios-sdk`'s
// `DocumentReference` exactly at the protocol-declaration level
// (`setData(_:merge: Bool)`, `setData(_:mergeFields: [Any])`). The
// Swift-idiomatic `setData(_:mergeOption: MergeOption)` form lives here
// as a protocol extension that switches on the enum and delegates to the
// canonical Firebase-shaped methods.
//
// Mocks reflect the protocol layer only — Sourcery does not generate from
// extensions — so consumers writing tests use the canonical handlers
// (`setDataDocumentDataMergeCompletionHandler`,
// `setDataDocumentDataMergeFieldsCompletionHandler`). The no-merge
// `setData(_:completion:)` canonical form is mocked as `setDataHandler`.
// See `Docs/agent/patterns.md` § "Two-tier API surface".

public extension DocumentReferenceProtocol {
  func setData(
    _ documentData: [String: Any],
    mergeOption: MergeOption,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    switch mergeOption {
    case .overwrite:
      setData(documentData, completion: completion)
    case .merge:
      setData(documentData, merge: true, completion: completion)
    case .mergeFields(let fields):
      setData(documentData, mergeFields: fields, completion: completion)
    }
  }
}
