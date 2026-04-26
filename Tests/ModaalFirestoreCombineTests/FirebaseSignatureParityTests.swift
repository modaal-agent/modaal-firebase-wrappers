// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
@testable import ModaalFirestore
@testable import ModaalFirebaseMocks

/// v1.4.0 "Two-tier API surface" parity tests for ModaalFirestore.
///
/// For each protocol-level method that v1.4.0 renamed to match Firebase iOS SDK
/// canonical signatures, this suite asserts:
/// 1. The canonical method exists and is mockable.
/// 2. The Swift-idiomatic `mergeOption: MergeOption` extension form continues
///    to compile and dispatches to the canonical mock handler.
final class FirebaseSignatureParityTests: XCTestCase {

  // MARK: - Helpers

  private func makeDocRef() -> DocumentReferenceProtocolMock {
    DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
  }

  // MARK: - DocumentReferenceProtocol.setData

  func testCanonicalSetDataMergeBoolDispatchesViaMockHandler() {
    let mock = makeDocRef()
    let expectation = expectation(description: "canonical setData(_:merge:completion:)")
    mock.setDataDocumentDataMergeCompletionHandler = { data, merge, completion in
      XCTAssertEqual(data["k"] as? String, "v")
      XCTAssertTrue(merge)
      completion(.success(()))
      expectation.fulfill()
    }
    mock.setData(["k": "v"], merge: true) { _ in }
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataDocumentDataMergeCompletionCallCount, 1)
  }

  func testCanonicalSetDataMergeFieldsDispatchesViaMockHandler() {
    let mock = makeDocRef()
    let expectation = expectation(description: "canonical setData(_:mergeFields:completion:)")
    mock.setDataDocumentDataMergeFieldsCompletionHandler = { data, mergeFields, completion in
      XCTAssertEqual(data["k"] as? String, "v")
      XCTAssertEqual(mergeFields as? [String], ["k"])
      completion(.success(()))
      expectation.fulfill()
    }
    mock.setData(["k": "v"], mergeFields: ["k"]) { _ in }
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataDocumentDataMergeFieldsCompletionCallCount, 1)
  }

  func testExtensionMergeOptionMergeDispatchesToCanonicalMergeBool() {
    let mock = makeDocRef()
    var observed: Bool?
    mock.setDataDocumentDataMergeCompletionHandler = { _, merge, completion in
      observed = merge
      completion(.success(()))
    }
    mock.setData(["k": "v"], mergeOption: .merge) { _ in }
    XCTAssertEqual(observed, true)
    XCTAssertEqual(mock.setDataDocumentDataMergeCompletionCallCount, 1)
  }

  func testExtensionMergeOptionMergeFieldsDispatchesToCanonicalMergeFields() {
    let mock = makeDocRef()
    var observed: [Any]?
    mock.setDataDocumentDataMergeFieldsCompletionHandler = { _, mergeFields, completion in
      observed = mergeFields
      completion(.success(()))
    }
    mock.setData(["k": "v"], mergeOption: .mergeFields(["k"])) { _ in }
    XCTAssertEqual(observed as? [String], ["k"])
    XCTAssertEqual(mock.setDataDocumentDataMergeFieldsCompletionCallCount, 1)
  }

  func testExtensionMergeOptionOverwriteDispatchesToCanonicalNoMerge() {
    let mock = makeDocRef()
    let expectation = expectation(description: "canonical setData(_:completion:)")
    mock.setDataHandler = { _, completion in
      completion(.success(()))
      expectation.fulfill()
    }
    mock.setData(["k": "v"], mergeOption: .overwrite) { _ in }
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataCallCount, 1)
  }

  func testMergeFieldsPayloadAcceptsFieldPathInstances() {
    // Canonical Firebase contract: setData(_:mergeFields: [Any]) accepts both
    // String field names and FieldPath instances. The MergeOption.mergeFields
    // associated value is [Any] (not [String]) to preserve this expressiveness.
    let mock = makeDocRef()
    var observed: [Any]?
    mock.setDataDocumentDataMergeFieldsCompletionHandler = { _, mergeFields, completion in
      observed = mergeFields
      completion(.success(()))
    }
    let path: FieldPath = .field("nested.field")
    let mixed: [Any] = ["plainString", path]
    mock.setData(["k": "v"], mergeOption: .mergeFields(mixed)) { _ in }

    XCTAssertEqual(observed?.count, 2)
    XCTAssertEqual(observed?[0] as? String, "plainString")
    XCTAssertNotNil(observed?[1] as? FieldPath)
  }

  // MARK: - WriteBatchProtocol.setData extension dispatch

  func testWriteBatchExtensionMergeOptionMergeDispatchesToCanonicalMergeBool() {
    let mock = WriteBatchProtocolMock()
    let doc = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    var observed: Bool?
    mock.setDataDataForDocumentDocumentMergeHandler = { _, _, merge in
      observed = merge
    }
    mock.setData(["k": "v"], forDocument: doc, mergeOption: .merge)
    XCTAssertEqual(observed, true)
    XCTAssertEqual(mock.setDataDataForDocumentDocumentMergeCallCount, 1)
  }

  func testWriteBatchExtensionMergeOptionMergeFieldsDispatchesToCanonicalMergeFields() {
    let mock = WriteBatchProtocolMock()
    let doc = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    var observed: [Any]?
    mock.setDataDataForDocumentDocumentMergeFieldsHandler = { _, _, mergeFields in
      observed = mergeFields
    }
    mock.setData(["k": "v"], forDocument: doc, mergeOption: .mergeFields(["k"]))
    XCTAssertEqual(observed as? [String], ["k"])
    XCTAssertEqual(mock.setDataDataForDocumentDocumentMergeFieldsCallCount, 1)
  }

  func testWriteBatchExtensionMergeOptionOverwriteDispatchesToCanonicalNoMerge() {
    let mock = WriteBatchProtocolMock()
    let doc = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    mock.setDataHandler = { _, _ in }
    mock.setData(["k": "v"], forDocument: doc, mergeOption: .overwrite)
    XCTAssertEqual(mock.setDataCallCount, 1)
  }

  // MARK: - TransactionProtocol.setData extension dispatch

  func testTransactionExtensionMergeOptionMergeDispatchesToCanonicalMergeBool() {
    let mock = TransactionProtocolMock()
    let doc = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    var observed: Bool?
    mock.setDataDataForDocumentDocumentMergeHandler = { _, _, merge in
      observed = merge
    }
    mock.setData(["k": "v"], forDocument: doc, mergeOption: .merge)
    XCTAssertEqual(observed, true)
    XCTAssertEqual(mock.setDataDataForDocumentDocumentMergeCallCount, 1)
  }

  func testTransactionExtensionMergeOptionMergeFieldsDispatchesToCanonicalMergeFields() {
    let mock = TransactionProtocolMock()
    let doc = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    var observed: [Any]?
    mock.setDataDataForDocumentDocumentMergeFieldsHandler = { _, _, mergeFields in
      observed = mergeFields
    }
    mock.setData(["k": "v"], forDocument: doc, mergeOption: .mergeFields(["k"]))
    XCTAssertEqual(observed as? [String], ["k"])
    XCTAssertEqual(mock.setDataDataForDocumentDocumentMergeFieldsCallCount, 1)
  }

  func testTransactionExtensionMergeOptionOverwriteDispatchesToCanonicalNoMerge() {
    let mock = TransactionProtocolMock()
    let doc = DocumentReferenceProtocolMock(parent: CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock()))
    mock.setDataHandler = { _, _ in }
    mock.setData(["k": "v"], forDocument: doc, mergeOption: .overwrite)
    XCTAssertEqual(mock.setDataCallCount, 1)
  }
}
