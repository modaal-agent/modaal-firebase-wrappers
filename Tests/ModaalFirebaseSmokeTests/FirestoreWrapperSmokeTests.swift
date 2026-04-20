// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// One round-trip through the wrapper family — setData → getDocument. This
// single test transitively exercises CollectionReference, DocumentReference,
// DocumentSnapshot, and the Query machinery via whereFilter + getDocuments.

import XCTest
import ModaalFirestore
final class FirestoreWrapperSmokeTests: XCTestCase {
  override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    try await EmulatorHarness.resetFirestore()
  }

  func testFirestoreRoundTripThroughProtocol() async throws {
    let firestore: FirestoreProtocol = EmulatorHarness.makeFirestore()

    let collection: CollectionReferenceProtocol = firestore.collection("smoke")
    XCTAssertEqual(collection.collectionID, "smoke")

    let document: DocumentReferenceProtocol = collection.document("doc1")
    XCTAssertEqual(document.documentID, "doc1")
    XCTAssertEqual(document.path, "smoke/doc1")

    let writeExpectation = expectation(description: "setData")
    document.setData(["field": "value", "n": 42]) { result in
      if case .failure(let error) = result { XCTFail("setData: \(error)") }
      writeExpectation.fulfill()
    }
    await fulfillment(of: [writeExpectation], timeout: 10)

    let readExpectation = expectation(description: "getDocument")
    var snapshot: DocumentSnapshotProtocol?
    document.getDocument { result in
      switch result {
      case .success(let s): snapshot = s
      case .failure(let error): XCTFail("getDocument: \(error)")
      }
      readExpectation.fulfill()
    }
    await fulfillment(of: [readExpectation], timeout: 10)

    let s = try XCTUnwrap(snapshot)
    XCTAssertTrue(s.exists)
    XCTAssertEqual(s.get("field") as? String, "value")
    XCTAssertEqual(s.get("n") as? Int, 42)

    let query: QueryProtocol = collection.whereFilter(.equalTo(.field("field"), value: "value"))
    let queryExpectation = expectation(description: "getDocuments")
    var querySnap: QuerySnapshotProtocol?
    query.getDocuments { result in
      if case .success(let q) = result { querySnap = q }
      queryExpectation.fulfill()
    }
    await fulfillment(of: [queryExpectation], timeout: 10)
    XCTAssertEqual(try XCTUnwrap(querySnap).count, 1)
  }

  func testWriteBatchAndTransactionThroughProtocol() async throws {
    let firestore: FirestoreProtocol = EmulatorHarness.makeFirestore()

    let batch: WriteBatchProtocol = firestore.batch()
    let docA: DocumentReferenceProtocol = firestore.document("smoke/batch-a")
    let docB: DocumentReferenceProtocol = firestore.document("smoke/batch-b")
    batch.setData(["x": 1], forDocument: docA, mergeOption: .overwrite)
    batch.setData(["x": 2], forDocument: docB, mergeOption: .overwrite)

    let commitExp = expectation(description: "batch.commit")
    batch.commit { result in
      if case .failure(let e) = result { XCTFail("batch.commit: \(e)") }
      commitExp.fulfill()
    }
    await fulfillment(of: [commitExp], timeout: 10)

    let txExp = expectation(description: "runTransaction")
    firestore.runTransaction({ tx -> Any? in
      // TransactionProtocol surface: update a document within the tx.
      tx.setData(["x": 99], forDocument: docA, mergeOption: .merge)
      return nil
    }) { result in
      if case .failure(let e) = result { XCTFail("runTransaction: \(e)") }
      txExp.fulfill()
    }
    await fulfillment(of: [txExp], timeout: 10)
  }

  func testSnapshotListenerThroughProtocol() async throws {
    let firestore: FirestoreProtocol = EmulatorHarness.makeFirestore()
    let doc: DocumentReferenceProtocol = firestore.document("smoke/listener-doc")

    let exp = expectation(description: "listener fires")
    exp.expectedFulfillmentCount = 1
    let registration: ListenerRegistrationProtocol = doc.addSnapshotListener { result in
      if case .success(let snap) = result, snap.exists {
        exp.fulfill()
      }
    }

    doc.setData(["a": 1]) { _ in }
    await fulfillment(of: [exp], timeout: 10)
    registration.remove()
  }
}
