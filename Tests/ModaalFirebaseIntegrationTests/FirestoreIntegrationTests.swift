// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalFirestore
final class FirestoreIntegrationTests: XCTestCase {
  private var firestore: FirestoreProtocol!

  override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    try await EmulatorHarness.resetFirestore()
    firestore = EmulatorHarness.makeFirestore()
  }

  // MARK: - Write/read round-trip

  func testSetDataThenGetDocumentRoundTrip() async throws {
    let doc: DocumentReferenceProtocol = firestore.document("integ/round-trip")
    try await setData(doc, ["name": "ada", "score": 42])

    let snapshot = try await getDocument(doc)
    XCTAssertTrue(snapshot.exists)
    XCTAssertEqual(snapshot.get("name") as? String, "ada")
    XCTAssertEqual(snapshot.get("score") as? Int, 42)
  }

  // MARK: - merge vs overwrite

  func testMergeVsOverwriteSemantics() async throws {
    let doc: DocumentReferenceProtocol = firestore.document("integ/merge")
    try await setData(doc, ["a": 1, "b": 2])

    // .merge keeps "a", updates "b"
    try await setData(doc, ["b": 20, "c": 3], mergeOption: .merge)
    var snap = try await getDocument(doc)
    XCTAssertEqual(snap.get("a") as? Int, 1)
    XCTAssertEqual(snap.get("b") as? Int, 20)
    XCTAssertEqual(snap.get("c") as? Int, 3)

    // .overwrite drops "a" and "c"
    try await setData(doc, ["b": 200], mergeOption: .overwrite)
    snap = try await getDocument(doc)
    XCTAssertNil(snap.get("a"))
    XCTAssertEqual(snap.get("b") as? Int, 200)
    XCTAssertNil(snap.get("c"))
  }

  // MARK: - whereFilter.equalTo

  func testWhereFilterEqualToReturnsMatchingDocuments() async throws {
    let collection: CollectionReferenceProtocol = firestore.collection("integ-filter")
    try await setData(collection.document("a"), ["tag": "red"])
    try await setData(collection.document("b"), ["tag": "blue"])
    try await setData(collection.document("c"), ["tag": "red"])

    let query: QueryProtocol = collection.whereFilter(.equalTo(.field("tag"), value: "red"))
    let querySnap = try await getDocuments(query)
    XCTAssertEqual(querySnap.count, 2)
    let ids = Set(querySnap.documents.map { $0.documentID })
    XCTAssertEqual(ids, ["a", "c"])
  }

  // MARK: - Snapshot listener fires on external write

  func testSnapshotListenerFiresOnExternalWrite() async throws {
    let doc: DocumentReferenceProtocol = firestore.document("integ/listener")
    try await setData(doc, ["v": 0])

    let changeExpectation = expectation(description: "listener observes new value")
    var registration: ListenerRegistrationProtocol?
    registration = doc.addSnapshotListener { result in
      if case .success(let snap) = result, snap.get("v") as? Int == 99 {
        changeExpectation.fulfill()
      }
    }

    // External write from another wrapper instance to simulate a separate
    // client mutating the document.
    let externalFirestore: FirestoreProtocol = EmulatorHarness.makeFirestore()
    try await setData(externalFirestore.document("integ/listener"), ["v": 99], mergeOption: .merge)

    await fulfillment(of: [changeExpectation], timeout: 10)
    registration?.remove()
  }

  // MARK: - Protocol-only async helpers

  private func setData(_ doc: DocumentReferenceProtocol,
                       _ data: [String: Any],
                       mergeOption: MergeOption = .overwrite) async throws {
    try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
      doc.setData(data, mergeOption: mergeOption) { result in
        cont.resume(with: result)
      }
    }
  }

  private func getDocument(_ doc: DocumentReferenceProtocol) async throws -> DocumentSnapshotProtocol {
    try await withCheckedThrowingContinuation { cont in
      doc.getDocument { result in
        cont.resume(with: result)
      }
    }
  }

  private func getDocuments(_ query: QueryProtocol) async throws -> QuerySnapshotProtocol {
    try await withCheckedThrowingContinuation { cont in
      query.getDocuments { result in
        cont.resume(with: result)
      }
    }
  }
}
