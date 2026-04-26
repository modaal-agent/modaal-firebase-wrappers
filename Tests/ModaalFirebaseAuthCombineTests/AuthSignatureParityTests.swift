// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
@testable import ModaalFirebaseAuth
@testable import ModaalFirebaseMocks

/// v1.4.0 "Two-tier API surface" parity tests for ModaalFirebaseAuth.
///
/// Asserts the canonical Firebase iOS SDK signatures exist on the protocol
/// layer (`canHandle(_)`, `canHandleNotification(_)`) and the legacy
/// Swift-idiomatic aliases (`canHandleOpenUrl(_)`,
/// `canHandleRemoteNotification(_)`) in
/// `Extensions/FirebaseAuthProtocol+Idioms.swift` continue to compile and
/// dispatch to the canonical mock handlers.
final class AuthSignatureParityTests: XCTestCase {

  // MARK: - FirebaseAuthProtocol.canHandle

  func testCanonicalCanHandleDispatchesViaMockHandler() {
    let mock = FirebaseAuthProtocolMock()
    var observed: URL?
    mock.canHandleHandler = { url in
      observed = url
      return true
    }
    let url = URL(string: "https://example.com/oauth")!
    XCTAssertTrue(mock.canHandle(url))
    XCTAssertEqual(observed, url)
    XCTAssertEqual(mock.canHandleCallCount, 1)
  }

  func testExtensionCanHandleOpenUrlDispatchesToCanonicalCanHandle() {
    let mock = FirebaseAuthProtocolMock()
    mock.canHandleHandler = { _ in true }
    XCTAssertTrue(mock.canHandleOpenUrl(URL(string: "https://example.com")!))
    XCTAssertEqual(mock.canHandleCallCount, 1)
  }

  // MARK: - FirebaseAuthProtocol.canHandleNotification

  func testCanonicalCanHandleNotificationDispatchesViaMockHandler() {
    let mock = FirebaseAuthProtocolMock()
    mock.canHandleNotificationHandler = { _ in true }
    XCTAssertTrue(mock.canHandleNotification(["k": "v"]))
    XCTAssertEqual(mock.canHandleNotificationCallCount, 1)
  }

  func testExtensionCanHandleRemoteNotificationDispatchesToCanonicalCanHandleNotification() {
    let mock = FirebaseAuthProtocolMock()
    mock.canHandleNotificationHandler = { _ in true }
    XCTAssertTrue(mock.canHandleRemoteNotification(["k": "v"]))
    XCTAssertEqual(mock.canHandleNotificationCallCount, 1)
  }
}
