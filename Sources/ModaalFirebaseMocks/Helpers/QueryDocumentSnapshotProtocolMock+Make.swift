// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import ModaalFirestore

// MARK: - Test ergonomics
//
// Sourcery-generated `QueryDocumentSnapshotProtocolMock` (and its parent
// `DocumentSnapshotProtocolMock`) requires `metadata:` and `reference:` at
// construction but exposes `documentID` / `exists` as bare `var` defaults
// with no init params. Tests that want to assert on `documentID` end up
// writing a four-step ceremony.
//
// This convenience factory removes the ceremony for the common test case.
// Add similar helpers for any other Sourcery-generated mock with an
// awkward init shape; keep them additive (extension on the generated mock).

extension QueryDocumentSnapshotProtocolMock {
  /// Construct a `QueryDocumentSnapshotProtocolMock` with optional overrides
  /// for the bare-default properties (`documentID`, `exists`) and sensible
  /// `SnapshotMetadataProtocolMock` / `DocumentReferenceProtocolMock` defaults
  /// for the init-required dependencies.
  static func make(
    documentID: String = "test-doc-id",
    exists: Bool = true,
    metadata: SnapshotMetadataProtocol = SnapshotMetadataProtocolMock(),
    reference: DocumentReferenceProtocol = DocumentReferenceProtocolMock(
      parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock())
    )
  ) -> QueryDocumentSnapshotProtocolMock {
    let mock = QueryDocumentSnapshotProtocolMock(metadata: metadata, reference: reference)
    mock.documentID = documentID
    mock.exists = exists
    return mock
  }
}

extension DocumentSnapshotProtocolMock {
  /// Construct a `DocumentSnapshotProtocolMock` with optional overrides for
  /// the bare-default properties.
  static func make(
    documentID: String = "test-doc-id",
    exists: Bool = true,
    metadata: SnapshotMetadataProtocol = SnapshotMetadataProtocolMock(),
    reference: DocumentReferenceProtocol = DocumentReferenceProtocolMock(
      parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock())
    )
  ) -> DocumentSnapshotProtocolMock {
    let mock = DocumentSnapshotProtocolMock(metadata: metadata, reference: reference)
    mock.documentID = documentID
    mock.exists = exists
    return mock
  }
}
