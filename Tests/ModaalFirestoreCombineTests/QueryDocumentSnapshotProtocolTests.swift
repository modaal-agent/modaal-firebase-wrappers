// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
@testable import ModaalFirestore
@testable import ModaalFirebaseMocks

/// Verifies the v1.4.0 refining `QueryDocumentSnapshotProtocol` and its dual
/// `data()` overload resolution. Restores the type-level existence guarantee
/// Firebase encodes via `QueryDocumentSnapshot : DocumentSnapshot`.
///
/// Exercises the Sourcery-generated `QueryDocumentSnapshotProtocolMock`
/// directly — the mock template (SwiftMockTemplates 0.2.14+) appends a
/// return-type-derived suffix to disambiguate the two `data()` overloads:
/// `dataStringAnyHandler` (non-optional) vs `dataStringAnyOptionalHandler`
/// (optional). Consumers writing their own tests against
/// `QueryDocumentSnapshotProtocolMock` use the same naming convention.
final class QueryDocumentSnapshotProtocolTests: XCTestCase {

  // MARK: - Helpers

  private func makeMock() -> QueryDocumentSnapshotProtocolMock {
    let metadata = SnapshotMetadataProtocolMock()
    let reference = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    return QueryDocumentSnapshotProtocolMock(metadata: metadata, reference: reference)
  }

  // MARK: - Overload resolution

  func testNonOptionalDataResolvesUnderQueryDocumentSnapshotProtocolTyping() {
    let mock = makeMock()
    mock.dataStringAnyHandler = { ["name": "Alice", "age": 30] }

    let typed: QueryDocumentSnapshotProtocol = mock
    let data: [String: Any] = typed.data()
    XCTAssertEqual(data["name"] as? String, "Alice")
    XCTAssertEqual(data["age"] as? Int, 30)
    XCTAssertEqual(mock.dataStringAnyCallCount, 1)
  }

  func testOptionalDataResolvesUnderDocumentSnapshotProtocolUpcast() {
    let mock = makeMock()
    mock.dataStringAnyOptionalHandler = { ["name": "Alice"] }

    let upcast: DocumentSnapshotProtocol = mock
    let data: [String: Any]? = upcast.data()
    XCTAssertEqual(data?["name"] as? String, "Alice")
    XCTAssertEqual(mock.dataStringAnyOptionalCallCount, 1)
  }

  func testProtocolInheritanceAssignmentWorks() {
    let mock = makeMock()
    let _: DocumentSnapshotProtocol = mock
    let _: QueryDocumentSnapshotProtocol = mock
  }

  func testCallCountsTrackedIndependentlyPerOverload() {
    let mock = makeMock()
    mock.dataStringAnyHandler = { [:] }
    mock.dataStringAnyOptionalHandler = { nil }

    let typed: QueryDocumentSnapshotProtocol = mock
    _ = typed.data() as [String: Any]
    _ = typed.data() as [String: Any]

    let upcast: DocumentSnapshotProtocol = mock
    _ = upcast.data()

    XCTAssertEqual(mock.dataStringAnyCallCount, 2)
    XCTAssertEqual(mock.dataStringAnyOptionalCallCount, 1)
  }

  func testIterationWithoutGuardLet() {
    let snapshot = QuerySnapshotProtocolMock(metadata: SnapshotMetadataProtocolMock())
    let first = makeMock()
    first.dataStringAnyHandler = { ["field": "first"] }
    let second = makeMock()
    second.dataStringAnyHandler = { ["field": "second"] }
    snapshot.documents = [first, second]

    var collected: [String] = []
    for doc in snapshot.documents {
      let data: [String: Any] = doc.data()
      if let value = data["field"] as? String {
        collected.append(value)
      }
    }
    XCTAssertEqual(collected, ["first", "second"])
  }

  func testDocumentChangesIterationExposesNonOptionalData() {
    // The other half of the B3 narrowing: DocumentChangeProtocol.document is
    // typed QueryDocumentSnapshotProtocol — change events always reference an
    // existent query-context document, so data() is non-optional too.
    let added = makeMock()
    added.dataStringAnyHandler = { ["status": "added"] }
    let modified = makeMock()
    modified.dataStringAnyHandler = { ["status": "modified"] }

    let changeAdded = DocumentChangeProtocolMock(document: added, type: .added)
    let changeModified = DocumentChangeProtocolMock(document: modified, type: .modified)

    let snapshot = QuerySnapshotProtocolMock(metadata: SnapshotMetadataProtocolMock())
    snapshot.documentChanges = [changeAdded, changeModified]

    var collected: [(DocumentChangeType, String)] = []
    for change in snapshot.documentChanges {
      // Non-optional data() — no `guard let` needed.
      let data: [String: Any] = change.document.data()
      if let status = data["status"] as? String {
        collected.append((change.type, status))
      }
    }
    XCTAssertEqual(collected.count, 2)
    XCTAssertEqual(collected[0].0, .added)
    XCTAssertEqual(collected[0].1, "added")
    XCTAssertEqual(collected[1].0, .modified)
    XCTAssertEqual(collected[1].1, "modified")
  }
}
