// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import XCTest
@testable import ModaalFirestore
@testable import ModaalFirebaseMocks

final class FirestoreCombineTests: XCTestCase {

  private var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellables = []
  }

  override func tearDown() {
    cancellables = nil
    super.tearDown()
  }

  // MARK: - WriteBatch: commit

  func testWriteBatchCommitSuccess() {
    let mock = WriteBatchProtocolMock()

    mock.commitHandler = { completion in
      completion(.success(()))
    }

    let expectation = expectation(description: "commit completes")
    mock.commit()
      .sink(
        receiveCompletion: { completion in
          if case .failure = completion { XCTFail("Expected success") }
          expectation.fulfill()
        },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.commitCallCount, 1)
  }

  func testWriteBatchCommitFailure() {
    let mock = WriteBatchProtocolMock()
    let expectedError = NSError(domain: "test", code: 77)

    mock.commitHandler = { completion in
      completion(.failure(expectedError))
    }

    let expectation = expectation(description: "commit fails")
    mock.commit()
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            XCTAssertEqual((error as NSError).code, 77)
            expectation.fulfill()
          }
        },
        receiveValue: { }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Firestore: runTransaction

  func testRunTransactionSuccess() {
    let mock = FirestoreProtocolMock()

    mock.runTransactionHandler = { updateBlock, completion in
      completion(.success("result-value"))
    }

    let expectation = expectation(description: "transaction completes")
    mock.runTransaction { _ in "result-value" }
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { result in
          XCTAssertEqual(result as? String, "result-value")
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.runTransactionCallCount, 1)
  }

  // MARK: - CollectionReference: addDocument

  func testAddDocumentSuccess() {
    let parentMock = CollectionReferenceProtocolMock(count: AggregateQueryProtocolMock())
    let newDocMock = DocumentReferenceProtocolMock(parent: parentMock)
    newDocMock.documentID = "new-doc-id"

    parentMock.addDocumentHandler = { data, completion in
      XCTAssertEqual(data["title"] as? String, "Hello")
      completion(.success(newDocMock))
    }

    let expectation = expectation(description: "addDocument completes")
    parentMock.addDocument(data: ["title": "Hello"])
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { docRef in
          XCTAssertEqual(docRef.documentID, "new-doc-id")
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(parentMock.addDocumentCallCount, 1)
  }

  // MARK: - AggregateQuery: getAggregation

  func testGetAggregationSuccess() {
    let mock = AggregateQueryProtocolMock()

    mock.getAggregationHandler = { source, completion in
      completion(.success(42))
    }

    let expectation = expectation(description: "aggregation completes")
    mock.getAggregation()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { count in
          XCTAssertEqual(count, 42)
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.getAggregationCallCount, 1)
  }
}
