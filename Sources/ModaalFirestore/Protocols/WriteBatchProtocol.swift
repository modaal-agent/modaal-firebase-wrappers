// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Foundation

public protocol WriteBatchProtocol: AnyObject {
  // Canonical Firebase iOS SDK signatures.
  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol)
  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, merge: Bool)
  func setData(_ data: [String: Any], forDocument document: DocumentReferenceProtocol, mergeFields: [Any])

  func updateData(_ fields: [String: Any], forDocument document: DocumentReferenceProtocol)
  func deleteDocument(_ document: DocumentReferenceProtocol)
  func commit(completion: @escaping (Result<Void, Error>) -> Void)
}
