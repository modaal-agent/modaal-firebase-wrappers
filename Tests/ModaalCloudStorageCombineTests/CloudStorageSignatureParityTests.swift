// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

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
}
