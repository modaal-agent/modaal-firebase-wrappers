// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalFirebaseAuth
final class AuthIntegrationTests: XCTestCase {
  private var auth: FirebaseAuthProtocol!

  override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    try await EmulatorHarness.resetAuth()
    auth = EmulatorHarness.makeAuth()
    // Make sure we're signed out at the start of each test — state carries
    // across runs inside a process even after emulator state reset.
    try? auth.signOut()
  }

  func testSignInAnonymouslyPopulatesCurrentUser() async throws {
    XCTAssertNil(auth.currentUser)

    let dataResult = try await signInAnonymously()
    XCTAssertFalse(dataResult.user.uid.isEmpty)
    XCTAssertTrue(dataResult.user.isAnonymous)

    let current = try XCTUnwrap(auth.currentUser)
    XCTAssertEqual(current.uid, dataResult.user.uid)
  }

  func testSignOutClearsCurrentUser() async throws {
    _ = try await signInAnonymously()
    XCTAssertNotNil(auth.currentUser)

    try auth.signOut()
    XCTAssertNil(auth.currentUser)
  }

  func testStateDidChangeListenerFiresOnSignInAndSignOut() async throws {
    let signInExpectation = expectation(description: "listener observes sign-in")
    let signOutExpectation = expectation(description: "listener observes sign-out")

    var sawSignedOutOnce = false
    let handle = auth.addStateDidChangeListener { _, user in
      if user != nil {
        signInExpectation.fulfill()
      } else if sawSignedOutOnce {
        signOutExpectation.fulfill()
      } else {
        sawSignedOutOnce = true
      }
    }

    _ = try await signInAnonymously()
    await fulfillment(of: [signInExpectation], timeout: 10)

    try auth.signOut()
    await fulfillment(of: [signOutExpectation], timeout: 10)

    auth.removeStateDidChangeListener(handle)
  }

  // MARK: - Protocol-only async helper

  private func signInAnonymously() async throws -> FirebaseAuthDataResultProtocol {
    try await withCheckedThrowingContinuation { cont in
      auth.signInAnonymously { result in
        cont.resume(with: result)
      }
    }
  }
}
