// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import XCTest
@testable import ModaalFirestore
@testable import ModaalFirebaseMocks

final class DocumentReferenceCombineTests: XCTestCase {

  private var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellables = []
  }

  override func tearDown() {
    cancellables = nil
    super.tearDown()
  }

  // MARK: - Helpers

  private func makeDocRefMock() -> DocumentReferenceProtocolMock {
    let parentMock = CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock())
    return DocumentReferenceProtocolMock(parent: parentMock)
  }

  private func makeSnapshotMock() -> DocumentSnapshotProtocolMock {
    let metadataMock = SnapshotMetadataProtocolMock()
    let refMock = makeDocRefMock()
    let snapshot = DocumentSnapshotProtocolMock(metadata: metadataMock, reference: refMock)
    snapshot.documentID = "test-doc"
    snapshot.exists = true
    return snapshot
  }

  // MARK: - Future: getDocument

  func testGetDocumentSuccess() {
    let mock = makeDocRefMock()
    let expectedSnapshot = makeSnapshotMock()

    mock.getDocumentSourceCompletionHandler = { _, completion in
      completion(.success(expectedSnapshot))
    }

    let expectation = expectation(description: "getDocument completes")
    mock.getDocument()
      .sink(
        receiveCompletion: { completion in
          if case .failure = completion { XCTFail("Expected success") }
        },
        receiveValue: { snapshot in
          XCTAssertEqual(snapshot.documentID, "test-doc")
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.getDocumentSourceCompletionCallCount, 1)
  }

  func testGetDocumentFailure() {
    let mock = makeDocRefMock()
    let expectedError = NSError(domain: "test", code: 42)

    mock.getDocumentSourceCompletionHandler = { _, completion in
      completion(.failure(expectedError))
    }

    let expectation = expectation(description: "getDocument fails")
    mock.getDocument()
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            XCTAssertEqual((error as NSError).code, 42)
            expectation.fulfill()
          }
        },
        receiveValue: { _ in XCTFail("Expected failure") }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Future: setData

  func testSetDataSuccess() {
    let mock = makeDocRefMock()

    mock.setDataHandler = { data, completion in
      XCTAssertEqual(data["name"] as? String, "Alice")
      completion(.success(()))
    }

    let expectation = expectation(description: "setData completes")
    mock.setData(["name": "Alice"])
      .sink(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataCallCount, 1)
  }

  func testSetDataWithMerge() {
    let mock = makeDocRefMock()

    // The `mergeOption: .merge` extension dispatches to canonical
    // `setData(_:merge:completion:)` — stub the corresponding mock handler.
    mock.setDataDocumentDataMergeCompletionHandler = { _, merge, completion in
      XCTAssertTrue(merge)
      completion(.success(()))
    }

    let expectation = expectation(description: "setData merge completes")
    mock.setData(["name": "Alice"], mergeOption: .merge)
      .sink(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataDocumentDataMergeCompletionCallCount, 1)
  }

  func testSetDataCanonicalMergeBoolCombineForm() {
    let mock = makeDocRefMock()

    // The Future-returning canonical `setData(_:merge:)` extension dispatches
    // directly to the canonical mock handler — no MergeOption involved.
    mock.setDataDocumentDataMergeCompletionHandler = { _, merge, completion in
      XCTAssertTrue(merge)
      completion(.success(()))
    }

    let expectation = expectation(description: "canonical setData(_:merge:) Combine completes")
    mock.setData(["name": "Alice"], merge: true)
      .sink(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataDocumentDataMergeCompletionCallCount, 1)
  }

  func testSetDataCanonicalMergeFieldsCombineForm() {
    let mock = makeDocRefMock()

    mock.setDataDocumentDataMergeFieldsCompletionHandler = { _, mergeFields, completion in
      XCTAssertEqual(mergeFields as? [String], ["name"])
      completion(.success(()))
    }

    let expectation = expectation(description: "canonical setData(_:mergeFields:) Combine completes")
    mock.setData(["name": "Alice"], mergeFields: ["name"])
      .sink(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.setDataDocumentDataMergeFieldsCompletionCallCount, 1)
  }

  // MARK: - Future: delete

  func testDeleteSuccess() {
    let mock = makeDocRefMock()

    mock.deleteHandler = { completion in
      completion(.success(()))
    }

    let expectation = expectation(description: "delete completes")
    mock.delete()
      .sink(
        receiveCompletion: { _ in expectation.fulfill() },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.deleteCallCount, 1)
  }

  // MARK: - Future: updateData

  func testUpdateDataFailure() {
    let mock = makeDocRefMock()
    let expectedError = NSError(domain: "test", code: 99)

    mock.updateDataHandler = { _, completion in
      completion(.failure(expectedError))
    }

    let expectation = expectation(description: "updateData fails")
    mock.updateData(["age": 30])
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            XCTAssertEqual((error as NSError).code, 99)
            expectation.fulfill()
          }
        },
        receiveValue: { XCTFail("Expected failure") }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Streaming: snapshotPublisher

  func testSnapshotPublisherEmitsValues() {
    let mock = makeDocRefMock()
    let snapshot1 = makeSnapshotMock()
    snapshot1.documentID = "doc-1"
    let snapshot2 = makeSnapshotMock()
    snapshot2.documentID = "doc-2"
    let registration = ListenerRegistrationProtocolMock()

    var capturedListener: ((Result<DocumentSnapshotProtocol, Error>) -> Void)?

    mock.addSnapshotListenerHandler = { includeMetadata, listener in
      XCTAssertFalse(includeMetadata)
      capturedListener = listener
      return registration
    }

    var receivedIDs: [String] = []
    let expectation = expectation(description: "receives 2 snapshots")
    expectation.expectedFulfillmentCount = 2

    mock.snapshotPublisher()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { snapshot in
          receivedIDs.append(snapshot.documentID)
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    XCTAssertNotNil(capturedListener)
    XCTAssertEqual(mock.addSnapshotListenerCallCount, 1)

    capturedListener?(.success(snapshot1))
    capturedListener?(.success(snapshot2))

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(receivedIDs, ["doc-1", "doc-2"])
  }

  func testSnapshotPublisherIncludeMetadataChanges() {
    let mock = makeDocRefMock()
    let registration = ListenerRegistrationProtocolMock()

    mock.addSnapshotListenerHandler = { includeMetadata, _ in
      XCTAssertTrue(includeMetadata)
      return registration
    }

    mock.snapshotPublisher(includeMetadataChanges: true)
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
      .store(in: &cancellables)

    XCTAssertEqual(mock.addSnapshotListenerCallCount, 1)
  }

  func testSnapshotPublisherPropagatesError() {
    let mock = makeDocRefMock()
    let registration = ListenerRegistrationProtocolMock()
    let expectedError = NSError(domain: "firestore", code: 7)

    var capturedListener: ((Result<DocumentSnapshotProtocol, Error>) -> Void)?

    mock.addSnapshotListenerHandler = { _, listener in
      capturedListener = listener
      return registration
    }

    let expectation = expectation(description: "error propagated")
    mock.snapshotPublisher()
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            XCTAssertEqual((error as NSError).code, 7)
            expectation.fulfill()
          }
        },
        receiveValue: { _ in }
      )
      .store(in: &cancellables)

    capturedListener?(.failure(expectedError))
    wait(for: [expectation], timeout: 1)
  }

  func testSnapshotPublisherRemovesListenerOnCancel() {
    let mock = makeDocRefMock()
    let registration = ListenerRegistrationProtocolMock()

    mock.addSnapshotListenerHandler = { _, _ in registration }

    let cancellable = mock.snapshotPublisher()
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

    XCTAssertEqual(registration.removeCallCount, 0)
    cancellable.cancel()
    XCTAssertEqual(registration.removeCallCount, 1)
  }
}

