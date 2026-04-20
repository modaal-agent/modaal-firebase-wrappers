// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.

import XCTest
import ModaalFirebaseAuth
final class FirebaseAuthWrapperSmokeTests: XCTestCase {
  override func setUp() async throws {
    try await super.setUp()
    try EmulatorHarness.skipIfDisabled()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
    try await EmulatorHarness.resetAuth()
  }

  func testCurrentUserNilBeforeSignIn() {
    let auth: FirebaseAuthProtocol = EmulatorHarness.makeAuth()
    XCTAssertNil(auth.currentUser)
  }
}
