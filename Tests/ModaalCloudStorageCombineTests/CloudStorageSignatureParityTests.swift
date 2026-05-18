// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import Combine
import XCTest
@testable import ModaalCloudStorage
@testable import ModaalFirebaseMocks

/// v1.4.0 "Two-tier API surface" parity tests for ModaalCloudStorage.
///
/// Asserts:
/// 1. Canonical Firebase iOS SDK methods (`child(_)` positional,
///    `downloadURL(completion:)`) exist on the protocol layer and are
///    mockable.
/// 2. Swift-idiomatic aliases (`child(path:)`, `getDownloadURL(completion:)`)
///    in `Extensions/CloudStorageReferencing+Idioms.swift` and
///    `Extensions/CloudFileStoring+Idioms.swift` continue to compile and
///    dispatch to the canonical mock handlers.
final class CloudStorageSignatureParityTests: XCTestCase {

  // MARK: - CloudStorageReferencing.child

  func testCanonicalChildPositionalDispatchesViaMockHandler() {
    let mock = CloudStorageReferencingMock()
    var observed: String?
    mock.childHandler = { path in
      observed = path
      return mock
    }
    _ = mock.child("subdir/file.png")
    XCTAssertEqual(observed, "subdir/file.png")
    XCTAssertEqual(mock.childCallCount, 1)
  }

  func testExtensionChildPathDispatchesToCanonicalChild() {
    let mock = CloudStorageReferencingMock()
    var observed: String?
    mock.childHandler = { path in
      observed = path
      return mock
    }
    _ = mock.child(path: "subdir/file.png")
    XCTAssertEqual(observed, "subdir/file.png")
    XCTAssertEqual(mock.childCallCount, 1)
  }

  // MARK: - CloudFileStoring.downloadURL

  func testCanonicalDownloadURLDispatchesViaMockHandler() {
    let mock = CloudStorageReferencingMock()
    let expectation = expectation(description: "canonical downloadURL(completion:)")
    mock.downloadURLHandler = { completion in
      completion(.success(URL(string: "https://example.com/file")!))
      expectation.fulfill()
    }
    mock.downloadURL { _ in }
    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(mock.downloadURLCallCount, 1)
  }

  func testExtensionGetDownloadURLDispatchesToCanonicalDownloadURL() {
    let mock = CloudStorageReferencingMock()
    var captured: URL?
    mock.downloadURLHandler = { completion in
      completion(.success(URL(string: "https://example.com/file")!))
    }
    mock.getDownloadURL { result in
      if case .success(let url) = result {
        captured = url
      }
    }
    XCTAssertEqual(captured?.absoluteString, "https://example.com/file")
    XCTAssertEqual(mock.downloadURLCallCount, 1)
  }

  // MARK: - Upload with progress (Wave 1)
  //
  // Combine cannot deliver values synchronously from inside
  // `handleEvents(receiveSubscription:)` because PassthroughSubject drops
  // sends that arrive before downstream demand is registered. The tests
  // capture the Tier-1 handlers and invoke them after the subscription is
  // fully established — same pattern as Firestore's snapshotPublisher tests.

  func testPutDataWithProgressEmitsProgressThenFinishes() {
    let mock = CloudStorageReferencingMock()
    let taskMock = CloudStorageUploadTaskProtocolMock()
    var captured: ((CloudStorageUploadEvent) -> Void, (Result<Void, Error>) -> Void)?
    mock.putDataDataEventsCompletionHandler = { _, events, completion in
      captured = (events, completion)
      return taskMock
    }

    var received: [CloudStorageUploadEvent] = []
    var finished = false
    let cancellable = mock.putDataWithProgress(Data())
      .sink(
        receiveCompletion: { c in if case .finished = c { finished = true } },
        receiveValue: { received.append($0) }
      )

    XCTAssertNotNil(captured, "Tier-1 method should have been invoked")
    captured?.0(.progress(bytesTransferred: 50, totalBytes: 100))
    captured?.1(.success(()))

    XCTAssertEqual(received.count, 1)
    guard case .progress(let sent, let total) = received[0] else {
      XCTFail("Expected .progress, got \(received[0])"); return
    }
    XCTAssertEqual(sent, 50)
    XCTAssertEqual(total, 100)
    XCTAssertTrue(finished)
    XCTAssertEqual(mock.putDataDataEventsCompletionCallCount, 1)
    _ = cancellable
  }

  func testPutDataWithProgressMetadataDispatchesToCanonical() {
    let mock = CloudStorageReferencingMock()
    let taskMock = CloudStorageUploadTaskProtocolMock()
    var captured: ((Result<Void, Error>) -> Void)?
    mock.putDataDataMetadataEventsCompletionHandler = { _, _, _, completion in
      captured = completion
      return taskMock
    }

    let cancellable = mock
      .putDataWithProgress(Data(), metadata: CloudStorageMetadata(contentType: "image/png"))
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    captured?(.success(()))
    XCTAssertEqual(mock.putDataDataMetadataEventsCompletionCallCount, 1)
    _ = cancellable
  }

  func testUploadFromFileWithProgressDispatchesToCanonical() {
    let mock = CloudStorageReferencingMock()
    let taskMock = CloudStorageUploadTaskProtocolMock()
    var captured: ((Result<Void, Error>) -> Void)?
    mock.uploadFromFileLocalURLEventsCompletionHandler = { _, _, completion in
      captured = completion
      return taskMock
    }

    let cancellable = mock
      .uploadFromFileWithProgress(localURL: URL(fileURLWithPath: "/tmp/file"))
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    captured?(.success(()))
    XCTAssertEqual(mock.uploadFromFileLocalURLEventsCompletionCallCount, 1)
    _ = cancellable
  }

  func testUploadFromFileWithProgressMetadataDispatchesToCanonical() {
    let mock = CloudStorageReferencingMock()
    let taskMock = CloudStorageUploadTaskProtocolMock()
    var captured: ((Result<Void, Error>) -> Void)?
    mock.uploadFromFileLocalURLMetadataEventsCompletionHandler = { _, _, _, completion in
      captured = completion
      return taskMock
    }

    let cancellable = mock
      .uploadFromFileWithProgress(
        localURL: URL(fileURLWithPath: "/tmp/file"),
        metadata: CloudStorageMetadata(contentType: "image/png")
      )
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    captured?(.success(()))
    XCTAssertEqual(mock.uploadFromFileLocalURLMetadataEventsCompletionCallCount, 1)
    _ = cancellable
  }

  func testPutDataWithProgressFailurePropagates() {
    struct UploadError: Error {}
    let mock = CloudStorageReferencingMock()
    let taskMock = CloudStorageUploadTaskProtocolMock()
    var captured: ((Result<Void, Error>) -> Void)?
    mock.putDataDataEventsCompletionHandler = { _, _, completion in
      captured = completion
      return taskMock
    }

    var receivedFailure = false
    let cancellable = mock.putDataWithProgress(Data())
      .sink(
        receiveCompletion: { c in if case .failure = c { receivedFailure = true } },
        receiveValue: { _ in }
      )
    captured?(.failure(UploadError()))
    XCTAssertTrue(receivedFailure)
    _ = cancellable
  }

  func testPutDataWithProgressCancellationPropagatesToTask() {
    let mock = CloudStorageReferencingMock()
    let taskMock = CloudStorageUploadTaskProtocolMock()
    // Hold completion so the publisher doesn't finish before we cancel.
    mock.putDataDataEventsCompletionHandler = { _, _, _ in taskMock }

    let cancellable = mock.putDataWithProgress(Data())
      .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    cancellable.cancel()
    XCTAssertEqual(taskMock.cancelCallCount, 1)
  }
}
