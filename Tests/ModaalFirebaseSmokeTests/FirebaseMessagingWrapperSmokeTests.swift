// Copyright (c) 2026 Modaal.dev
// Licensed under the MIT License. See LICENSE file for details.
//
// Firebase Emulator Suite has no FCM emulator, so this smoke test is
// instantiation-only — we verify that the wrapper constructs, binds to its
// protocol, and one trivial property toggle round-trips through the protocol.

import XCTest
import FirebaseMessaging
import ModaalFirebaseMessaging
final class FirebaseMessagingWrapperSmokeTests: XCTestCase {
  override func setUp() {
    super.setUp()
    EmulatorHarness.configureFirebaseForEmulatorIfNeeded()
  }

  func testMessagingProtocolAutoInitToggle() {
    let messaging: FirebaseMessagingProtocol = FirebaseMessagingWrapper(messaging: Messaging.messaging())
    let original = messaging.isAutoInitEnabled
    messaging.isAutoInitEnabled = !original
    XCTAssertEqual(messaging.isAutoInitEnabled, !original)
    messaging.isAutoInitEnabled = original
  }
}
