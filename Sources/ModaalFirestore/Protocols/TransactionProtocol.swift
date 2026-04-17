// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol TransactionProtocol: AnyObject {
  func getDocument(_ document: DocumentReferenceProtocol) throws -> DocumentSnapshotProtocol
  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeOption: MergeOption)
  func updateData(_ fields: [String: Any], forDocument document: DocumentReferenceProtocol)
  func deleteDocument(_ document: DocumentReferenceProtocol)
}
