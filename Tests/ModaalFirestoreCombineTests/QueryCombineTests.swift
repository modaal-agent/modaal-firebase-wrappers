// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import XCTest
@testable import ModaalFirestore
@testable import ModaalFirebaseMocks

final class QueryCombineTests: XCTestCase {

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

  private func makeQueryMock() -> QueryProtocolMock {
    QueryProtocolMock(count: AggregateQueryProtocolMock())
  }

  private func makeQuerySnapshotMock(count: Int = 0) -> QuerySnapshotProtocolMock {
    let mock = QuerySnapshotProtocolMock(metadata: SnapshotMetadataProtocolMock())
    mock.count = count
    return mock
  }

  // MARK: - Future: getDocuments

  func testGetDocumentsSuccess() {
    let mock = makeQueryMock()
    let expectedSnapshot = makeQuerySnapshotMock(count: 3)

    mock.getDocumentsSourceCompletionHandler = { _, completion in
      completion(.success(expectedSnapshot))
    }

    let expectation = expectation(description: "getDocuments completes")
    mock.getDocuments()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { snapshot in
          XCTAssertEqual(snapshot.count, 3)
          expectation.fulfill()
        }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.getDocumentsSourceCompletionCallCount, 1)
  }

  func testGetDocumentsFailure() {
    let mock = makeQueryMock()

    mock.getDocumentsSourceCompletionHandler = { _, completion in
      completion(.failure(NSError(domain: "test", code: 13)))
    }

    let expectation = expectation(description: "getDocuments fails")
    mock.getDocuments()
      .sink(
        receiveCompletion: { completion in
          if case .failure(let error) = completion {
            XCTAssertEqual((error as NSError).code, 13)
            expectation.fulfill()
          }
        },
        receiveValue: { _ in XCTFail("Expected failure") }
      )
      .store(in: &cancellables)

    wait(for: [expectation], timeout: 1)
  }

  // MARK: - Streaming: snapshotPublisher

  func testQuerySnapshotPublisherEmitsValue() {
    let mock = makeQueryMock()
    let registration = ListenerRegistrationProtocolMock()
    let snapshot = makeQuerySnapshotMock(count: 5)

    var capturedListener: ((Result<QuerySnapshotProtocol, Error>) -> Void)?

    mock.addSnapshotListenerHandler = { _, listener in
      capturedListener = listener
      return registration
    }

    let valueExpectation = expectation(description: "receives snapshot")
    mock.snapshotPublisher()
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { received in
          XCTAssertEqual(received.count, 5)
          valueExpectation.fulfill()
        }
      )
      .store(in: &cancellables)

    XCTAssertNotNil(capturedListener)
    capturedListener?(.success(snapshot))

    wait(for: [valueExpectation], timeout: 1)
    XCTAssertEqual(mock.addSnapshotListenerCallCount, 1)
  }

  func testQuerySnapshotPublisherRemovesListenerOnCancel() {
    let mock = makeQueryMock()
    let registration = ListenerRegistrationProtocolMock()

    mock.addSnapshotListenerHandler = { _, _ in registration }

    let cancellable = mock.snapshotPublisher()
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

    XCTAssertEqual(registration.removeCallCount, 0)
    cancellable.cancel()
    XCTAssertEqual(registration.removeCallCount, 1)
  }
}
